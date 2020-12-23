Configuration
=============

Once you have installed the module, you may add a custom configuration, specific to your environment, by adding a `stachebox` configuration object to your `moduleSettings` inside your `Coldbox.cfc` configuration file.

By default the following are in place, without additional configuration:

```
moduleSettings = {
    "stachebox" = {
			// The index to be used to store the module settings overrides
			"settingsIndex" : getSystemSetting( "STACHEBOX_SETTINGS_INDEX", ".stachebox_settings" ),
			// The index used to to manage user accounts ( if using the StacheBox users service for cbSecurity and cbAuth )
			"usersIndex" : getSystemSetting( "STACHEBOX_USERS_INDEX", ".stachebox_users" ),
			// A default index pattern for logstash logs ( e.g. application exceptions). May be overriden in the UI settings admin
			"logIndexPattern" : "logstash-*",
			// A default index pattern for filebeat logs ( e.g. server log files/entries ). May be overriden in the UI settings admin
			"beatIndexPattern" : "filebeat-*",
			// An initial admin email address. When present, it will create the initial login.
			"adminEmail" : getSystemSetting( "STACHEBOX_ADMIN_EMAIL", "" ),
			// An initial admin password to login
			"adminPassword" : getSystemSetting( "STACHEBOX_ADMIN_PASSWORD", "" ),
			// Whether to promote the module UI to the root URLS of the application
			"isStandalone" : false,
			// The cbSecurity configuration overrides for this module
			"cbsecurity" : {
				"userService" : "UserService@stachebox",
				// Module Relocation when an invalid access is detected, instead of each rule declaring one.
				"invalidAuthenticationEvent" 	: "stachebox:api.v1.BaseAPIHandler.onAuthenticationFailure",
				// Default Auhtentication Action: override or redirect when a user has not logged in
				"defaultAuthenticationAction"	: "override",
				// Module override event when an invalid access is detected, instead of each rule declaring one.
				"invalidAuthorizationEvent"		: "stachebox:api.v1.BaseAPIHandler.onAuthorizationFailure",
				// Default Authorization Action: override or redirect when a user does not have enough permissions to access something
				"defaultAuthorizationAction"	: "override",
				"validator" : "JWTService@cbsecurity",
				// You can define your security rules here
				"rules"							: [],
				"jwt" : {
					"customAuthHeader" : "x-auth-token",
					"expiration"       : 20
				}
			},
			// the cbauth overrides for this module
			"cbauth" : {
				"userServiceClass" : "UserService@stachebox"
			}
		} connectionTimeout      = getSystemSetting( "ELASTICSEARCH_CONNECT_TIMEOUT", 3000 )
    }
};
```
## Web Server Configuration

In order to implement JWT authentication ( used by Stachebox ) in your application, you may need to modify some web server settings. Most web servers have default content length restrictions on the size of an individual header.  If your web server platform has such default enabled, you will need to increase the buffer size to accommodate the presence of JTW tokens in both the request and response headers.  The size of a JWT token header, encrypted via the default cbSecurity HMAC512 algorithm, is around 44 kilobytes.  As such you will need to allow for at least that size.   Below are some examples for common web server configurations
### NGINX
The following configuration may be applied to the main NGINX `http` configuration block to allow for the presence of tokens in both the request and response headers:
```
http {
	# These settings affect outbound headers via proxy server
	proxy_buffer_size   64k;
	proxy_buffers   4 128k;
	proxy_busy_buffers_size   128k;
	# These settings affect the http client request headers
	client_body_buffer_size     128k;
	client_header_buffer_size   64k;
	large_client_header_buffers 8 128k;
	# These settings affect HTTP/2 headers, however some versions of NGINX will throw an error on HTTP/1 requests if these are not present
	http2_max_header_size 128k;
	http2_max_field_size 1000m;
}
```
### IIS
You will need to modify two registry keys:
1. `HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\HTTP\Parameters\MaxFieldLength` - Sets an upper limit, in bytes, for each header. The default value is 65534 bytes and the maximum value is 65534 bytes ( 64kb )
2. `HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\HTTP\Parameters\MaxRequestBytes` - Sets the upper limit for the request line and the headers, combined.  As such 128K should allow for both long URLs, as well as JWT tokens in the headers. The default value is 16384 bytes and the maximum value is 16777216 bytes ( 16 MB )
### Apache
You will need to add a `LimitRequestFieldSize` setting in each `<VirtualHost...>` entry in order increase the default header size from the default 8 kilobytes.  Example, with a setting of 128 kilobytes:
```
<VirtualHost 10.10.50.50:80>
	ServerName www.mysite.com
	
	LimitRequestFieldSize 128000
	
	RewriteEngine On
	...
	...
</VirtualHost>
```

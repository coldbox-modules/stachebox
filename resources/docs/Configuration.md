Configuration
=============
### Dependency Configuration

Stachebox utilizes the `cbElasticsearch` module as a dependency.  When configuring the module you will first need to [configure your `cbElasticsearch` connection](https://cbelasticsearch.ortusbooks.com/configuration).  If you plan to use the the API to securely log error message from other sources ( e.g. [via the Stachebox NPM module](https://www.npmjs.com/package/stachebox) ), you will also need to apply the [configuration for the the logstash module](https://github.com/coldbox-modules/logstash#configuration).   

### Module/Standalone Configuration

Once once the dependencies are configuration, you may add a custom configuration for the stachebox, specific to your environment, by adding a `stachebox` configuration object to your `moduleSettings` inside your `Coldbox.cfc` configuration file.  Of note is that the module may also be deployed as a solo application by turning the `isStandalone` configuration to `true`.  When this setting is enabled, the module routes are promoted to the root of the application.

The following module options ( with defaults listed below ) are in place, without additional configuration:

```
moduleSettings = {
    "stachebox" = {
			// The index to be used to store the module settings overrides
			"settingsIndex" : getSystemSetting( "STACHEBOX_SETTINGS_INDEX", ".stachebox_settings" ),
			// The index used to to manage user accounts ( if using the StacheBox users service for cbSecurity and cbAuth )
			"usersIndex" : getSystemSetting( "STACHEBOX_USERS_INDEX", ".stachebox_users" ),
			// A default index pattern for logstash logs ( e.g. application exceptions). May be overriden in the UI settings admin
			"logIndexPattern" : "logs-coldbox-*",
			// A default index pattern for filebeat logs ( e.g. server log files/entries ). May be overriden in the UI settings admin
			"beatIndexPattern" : "filebeat-*",
			// An initial admin email address. When present, it will create the initial login.
			"adminEmail" : getSystemSetting( "STACHEBOX_ADMIN_EMAIL", "" ),
			// An initial admin password to login
			"adminPassword" : getSystemSetting( "STACHEBOX_ADMIN_PASSWORD", "" ),
			// A username/email to use for the default token reporter ( no login privileges )
			"tokenReporter" : getSystemSetting( "STACHEBOX_TOKEN_REPORTER", "nologin@stachebox.io" ),
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

### Environment Variables

The following environment ( or Java system property ) values are supported for configuring your Stachebox instance at runtime:

* `STACHEBOX_SETTINGS_INDEX` - The name of the index used to store settings for the stachebox module.  This defaults to `.stachebox_settings`
* `STACHEBOX_USERS_INDEX` - If using the module's user service class, this setting names the index used to store user credentials and information.  This defaults to `.stachebox_users`
* `STACHEBOX_ADMIN_EMAIL` - When using the internal authentication, this is the email address of the default stachebox admin user.  If starting the application for the first time, without using your own customized user service, this variable must be configured.
* `STACHEBOX_ADMIN_PASSWORD` - This is the password for the default `STACHEBOX_ADMIN_EMAIL` account.  See the note above on initial configuration.  Once this variable has been provided and the initial admin account is created, both keys may be removed from the environment, unless the settings index name changes.

### Index templates and mappings

By default, Stachebox ( and the [logstash module](https://github.com/coldbox-modules/logstash/blob/master/readme.md) ) adhere to the [default logstash index template for Elasticsearch 7.x](https://github.com/logstash-plugins/logstash-output-elasticsearch/blob/master/lib/logstash/outputs/elasticsearch/templates/ecs-disabled/elasticsearch-7x.json), with one notable exception.  On the load of the module, a `stachebox` key mapping is added to all indices matching the `logIndexPattern` setting ( e.g. `logstash-*` ).  This key allows for the additional grouping and suppression functionality provided by the module.  If your Elasticsearch instance contains index data which does not adhere to the default template linked above, those indices will either return no data ( best case ) or will throw an error when attempting to retreive log entries.


### Authentication

By default, Stachebox provides its own internal authentication mechanisms, leveraging [the `cbSecurity` module](https://coldbox-security.ortusbooks.com/).  You may utilize the existing authentication services, or you may provide your own - as long as they implement a fully implemented `cbSecurity` [user service](https://coldbox-security.ortusbooks.com/getting-started/first-chapter#user-services) and [the JWT user service methods](https://coldbox-security.ortusbooks.com/jwt/jwt-services#user-service).  The `cbSecurity` and `cbSecurity.jwt` configuration blocks may be modified to match your custom user service classes. 

Example:

```
moduleSettings = {
	"stachebox" : {
		...
		"cbSecurity" : {
			"userService" : "UserService@myapp"
		},
		"cbAuth" : {
			"userServiceClass" : "UserService@myApp"
		}
	}
}
```

When using a custom security service, the `StacheboxUser` role will need to be assigned to any user who will be allowed access to the Stachebox logs API.   In addition, any users you wish to allow to administer the StacheBox module configuration will need to have the permission `Stachebox:Administer` in order to modify settings like index search patterns or  settings index names ( which may be also configured via the environment ). The permissions are retrieved from the JWT that the user API endpoint supplies so ensure that these permissions are provided in the JWT interface methods in your User entity:

```javascript
	 /**
     * A struct of custom claims to add to the JWT token
     */
    struct function getJwtCustomClaims(){
		return getMemento();
	}

    /**
     * This function returns an array of all the scopes that should be attached to the JWT token that will be used for authorization.
     */
    array function getJwtScopes(){
		return getPermissions();
	}
```

## Web Server Configuration

In order to implement JWT authentication ( used by Stachebox ) in your application, you may need to modify some web server settings. Most web servers have default content length restrictions on the size of an individual header.  If your web server platform has such default enabled, you will need to increase the buffer size to accommodate the presence of JTW tokens in both the request and response headers.  The size of a JWT token header, encrypted via the default cbSecurity HMAC512 algorithm, is around 44 kilobytes.  As such you will need to allow for at least that size.   Below are some examples for common web server configurations.
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
You will need to modify three registry keys:

1. `HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\HTTP\Parameters\MaxFieldLength` - Sets an upper limit, in bytes, for each header. The default value is 16384 bytes and the maximum value is 65534 bytes ( 64kb )

2. `HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\HTTP\Parameters\MaxRequestBytes` - Sets the upper limit for the request line and the headers, combined.  As such 128K should allow for both long URLs, as well as JWT tokens in the headers. The default value is 16384 bytes and the maximum value is 16777216 bytes ( 16 MB )

3. `HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\HTTP\Parameters\Http2MaxConcurrentClientStreams` - If HTTP2 is enabled on IIS, this will prevent AJAX errors on concurrent return/responses

The recommended value for these settings are:

* `Http2MaxConcurrentClientStreams` : 100
* `MaxFieldLength`: 415028
* `MaxRequestBytes` : 16777216

The PowerShell commands ( all run as Administrator ) to add these settings are:

```
New-Item –path "HKLM:\System\CurrentControlSet\Services\HTTP\Parameters" -PropertyType DWORD  –Name MaxFieldLength
Set-Itemproperty -path 'HKLM:\System\CurrentControlSet\Services\HTTP\Parameters' -Name MaxFieldLength -value 415028

New-Item –path "HKLM:\System\CurrentControlSet\Services\HTTP\Parameters" -PropertyType DWORD  –Name MaxRequestBytes
Set-Itemproperty -path 'HKLM:\System\CurrentControlSet\Services\HTTP\Parameters' -Name MaxRequestBytes -value 16777216

New-Item –path "HKLM:\System\CurrentControlSet\Services\HTTP\Parameters" -PropertyType DWORD  –Name Http2MaxConcurrentClientStreams
Set-Itemproperty -path 'HKLM:\System\CurrentControlSet\Services\HTTP\Parameters' -Name Http2MaxConcurrentClientStreams -value 100
```

Note:  If you encounter additional 500 errors from IIS after applying these machine keys, the following articles may assist in mitigating compression-related, and individual site-related header settings-related issues:

* [IIS acting as reverse proxy : Where the problems start](https://techcommunity.microsoft.com/t5/iis-support-blog/iis-acting-as-reverse-proxy-where-the-problems-start/ba-p/846259)
* [IIS Header Limits Configuration](https://docs.microsoft.com/en-us/iis/configuration/system.webserver/security/requestfiltering/requestlimits/headerlimits/)

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

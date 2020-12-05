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

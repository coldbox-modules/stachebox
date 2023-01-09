/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 */
component {

    // Module Properties
    this.title 				= "stachebox";
    this.author 			= "Ortus Solutions";
    this.webURL 			= "https://github.com/coldbox-modules/stachebox";
    this.description 		= "A Logstash and Bug Management Platform for Coldbox";

    // Model Namespace
	this.modelNamespace		= "stachebox";

	this.entrypoint         = "stachebox";

    // CF Mapping
    this.cfmapping			= "stachebox";

    // Dependencies
	this.dependencies 		= [ "logstash", "BCrypt", "cbrestbasehandler", "cbsecurity", "cbvalidation", "mementifier", "JSONToRC" ];

	// App Helpers
	this.applicationHelper = [
		"models/mixins/elixirPath.cfm"
	];

    /**
     * Configure Module
     */
    function configure(){
		var applicationName = server.coldfusion.productname == "Lucee" ? getApplicationSettings().name : getApplicationMetadata().name;

        settings = {
			// The index to be used to store the module settings overrides
			"settingsIndex" : getSystemSetting( "STACHEBOX_SETTINGS_INDEX", ".stachebox_settings" ),
			// The index used to to manage user accounts ( if using the StacheBox users service for cbSecurity and cbAuth )
			"usersIndex" : getSystemSetting( "STACHEBOX_USERS_INDEX", ".stachebox_users" ),
			// A default index pattern for logstash logs ( e.g. application exceptions). May be overriden in the UI settings admin
			"logIndexPattern" : "logstash-*",
			// A default index pattern for filebeat logs ( e.g. server log files/entries ). May be overriden in the UI settings admin
			"beatsIndexPattern" : "filebeat-*",
			// An initial admin email address. When present, it will create the initial login.
			"adminEmail" : getSystemSetting( "STACHEBOX_ADMIN_EMAIL", "" ),
			// An initial admin password to login
			"adminPassword" : getSystemSetting( "STACHEBOX_ADMIN_PASSWORD", "" ),
			// Whether to promote the module UI to the root URLS of the application
			"isStandalone" : getSystemSetting( "STACHEBOX_STANDALONE", false ),
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
		};

        // Try to look up the release based on a box.json
        if( !isNull( appmapping ) ) {
            var boxJSONPath = expandPath( '/' & appmapping & '/box.json' );
            if( fileExists( boxJSONPath ) ) {
                var boxJSONRaw = fileRead( boxJSONPath );
                if( isJSON( boxJSONRaw ) ) {
                    var boxJSON = deserializeJSON( boxJSONRaw );
                    if( boxJSON.keyExists( 'version' ) ) {
                        settings.release = boxJSON.version;
                        if( boxJSON.keyExists( 'slug' ) ) {
                            settings.release = boxJSON.slug & '@' & settings.release;
                        } else if( boxJSON.keyExists( 'name' ) ) {
                            settings.release = boxJSON.name & '@' & settings.release;
                        }
                    }
                }
            }
        }

        interceptors = [
            { class="stachebox.interceptors.Stachebox" },
            { class="stachebox.interceptors.BasicAuthentication" }
		];

		interceptorSettings = {
			customInterceptionPoints = [
				"onStacheboxSettingUpdate",
				"ensureStacheboxMappings"
			]
		};

		resources = [
			{
				resource : "/api/v1/users",
				handler : "api.v1.Users"

			},
			{
				resource : "/api/v1/settings",
				handler : "api.v1.Settings"

			},
			{
				resource : "/api/v1/beats",
				handler : "api.v1.Beats"

			}
		];

		routes = [
			{
				pattern : "/api/v1/logs/suppress/:field/:id",
				handler : "api.v1.Logs",
				action : {
					"DELETE" : "suppress"
				}
			},
			{
				pattern : '/api/v1/logs/:id',
				handler : "api.v1.Logs",
				action : {
					"HEAD" : "show",
					"GET" : "show",
					"PUT" : "update",
					"PATCH" : "update",
					"DELETE" : "delete",
					"POST" : "onInvalidHTTPMethod"
				}
			},
			{
				pattern : '/api/v1/logs',
				handler : "api.v1.Logs",
				action : {
					"POST" : "create",
					"GET" : "index",
					"HEAD" : "index",
					"PUT" : "onInvalidHTTPMethod",
					"PATCH" : "onInvalidHTTPMethod",
					"DELETE" : "onInvalidHTTPMethod"
				}
			},
			{
				pattern : "/api/v1/authentication",
				handler : "api.v1.Authentication",
				action : {
					"HEAD" : "check",
					"POST" : "login",
					"DELETE" : "logout"
				}
			},
			{ pattern = "/", handler = "Main", action = "index" },
			// Convention Route
			{ pattern="(.*?)", handler = "Main", action = "index" }
		];

    }

    /**
     * Fired when the module is registered and activated.
     */
    function onLoad(){

		if( settings.isStandalone ){
			scopeRoutingToRoot();
		}

		if( url.keyExists( "seed" ) && url.seed ){
			controller.getWirebox().getInstance( "migrationService:elasticsearch" ).seed( "Seed-Test-Data" );
		}

	}

    /**
     * Fired when the module is unregistered and unloaded
     */
	function onUnload(){}


	/**
	*  Sets the module as the main application
	*  Snipped and morphed from contentbox-ui:ModuleConfig.cfc:onLoad()
	*/
	private function scopeRoutingToRoot(){
		// Get ses handle
		try{
			//Coldbox 5
			var ses = controller.getInterceptorService().getInterceptor('SES',true);
		} catch( any e ){
			var ses = controller.getRoutingService().getRouter();
		}

		// get parent routes so we can re-mix them later
		var parentRoutes 		= ses.getRoutes();
		var newRoutes			= [];

		// iterate and only keep module routing
		for(var x=1; x lte arrayLen(parentRoutes); x++){
			if( parentRoutes[ x ].pattern NEQ ":handler/" AND
			    parentRoutes[ x ].pattern NEQ ":handler/:action/" ){
				arrayAppend(newRoutes, parentRoutes[ x ]);
			}
		}
		// override new cleaned routes
		ses.setRoutes( newRoutes );

		// Add routes manually to take over parent routes
		for(var x=1; x LTE arrayLen( variables.routes ); x++){
			// append module location to it so the route is now system wide
			var args = duplicate( variables.routes[ x ] );
			// Check if handler defined
			if( structKeyExists(args,"handler" ) ){
				args.handler = "stachebox:#args.handler#";
			}
			// add it as main application route.
			ses.addRoute(argumentCollection=args);
		}

		// change the default event of the entire app
		controller.setSetting( "DefaultEvent","stachebox:index" );

	}


}

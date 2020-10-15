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
    this.description 		= "A stachebox module for the Coldbox Platform";

    // Model Namespace
	this.modelNamespace		= "stachebox";

	this.entrypoint         = "stachebox";

    // CF Mapping
    this.cfmapping			= "stachebox";

    // Dependencies
    this.dependencies 		= [ "cbelasticsearch" ];

    /**
     * Configure Module
     */
    function configure(){
		var applicationName = server.coldfusion.productname == "Lucee" ? getApplicationSettings().name : getApplicationMetadata().name;

        settings = {
			// Whether to enable the API endpoints to receive log messages
			"enableAPI" 		: getSystemSetting( "stachebox_ENABLE_API", true ),
			// Whether to automatically enabled log appenders
			"enableAppenders" 	: getSystemSetting( "stachebox_ENABLE_APPENDERS", true ),
			// The type of transmission mode for this module - `direct` or `api`
			"transmission" 		: getSystemSetting( "stachebox_TRANSMISSION_METHOD", "direct" ),
			// only used if the transmission setting is `api`
			"apiUrl" 			: getSystemSetting( "stachebox_API_URL", "" ),
			// Regex used to whitelist remote addresses allowed to transmit to the API - by default only 127.0.0.1 is allowed to transmit messages to the API
			"apiWhitelist" 		: getSystemSetting( "stachebox_API_WHITELIST", "127.0.0.1" ),
			// a user-provided API token - which must match the token configured on the remote API microservice leave empty if using IP whitelisting
			"apiAuthToken" 		: getSystemSetting( "stachebox_API_TOKEN", "" ),
			// Min/Max levels for the appender
			"levelMin" 			: getSystemSetting( "stachebox_LEVEL_MIN", "FATAL" ),
			"levelMax" 			: getSystemSetting( "stachebox_LEVEL_MAX", "ERROR" ),
			// A closure, which may be used in the configuration to provide custom information. Will be stored in the `userinfo` key in your stachebox logs
			"userInfoUDF"       : function(){ return {}; },
			// A custom prefix for indices used by the module for logging
			"indexPrefix"       : getSystemSetting( "stachebox_INDEX_PREFIX", ".stachebox-" & lcase( REReplaceNoCase( applicationName, "[^0-9A-Z_]", "_", "all" ) ) )
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
            //API Security Interceptor
            { class="stachebox.interceptors.APISecurity" }
		];

		if( settings.enableAPI ){
			routes = [
				// Module Entry Point
				{
					pattern = "/api/logs",
					handler = "API",
					action = {
						"HEAD"		: "onInvalidHTTPMethod",
						"OPTIONS"	: "onInvalidHTTPMethod",
						"GET"   	: "onInvalidHTTPMethod",
						"POST"  	: "create",
						"DELETE"	: "onInvalidHTTPMethod",
						"PUT"   	: "create",
						"PATCH" 	: "onInvalidHTTPMethod"
					}
				}
			];
		}

    }

    /**
     * Fired when the module is registered and activated.
     */
    function onLoad(){}

    /**
     * Fired when the module is unregistered and unloaded
     */
	function onUnload(){}

	function afterConfigurationLoad(){
        if( settings.enableAppenders ){
            loadAppenders();
        }
	}
    /**
     * Load LogBox Appenders
     */
    private function loadAppenders(){
        // Get config
		var logBoxConfig 	= logBox.getConfig();

		var appenderProperties = duplicate( settings );
		appenderProperties.index = settings.indexPrefix;

		logBox.registerAppender(
            name 		= 'stachebox_appender',
            class 		= settings.transmission == "direct" ? "cbelasticsearch.models.logging.stacheboxAppender" : "stachebox.models.logging.APIAppender",
            properties  = appenderProperties,
            levelMin 	= logBox.logLevels[ settings.levelMin ],
            levelMax 	= logBox.logLevels[ settings.levelMax ]
		);

		var appenders = logBox.getAppendersMap( 'stachebox_appender' );
    	// Register the appender with the root loggger, and turn the logger on.
	    var root = logBox.getRootLogger();
	    root.addAppender( appenders[ 'stachebox_appender' ] );
    }

}

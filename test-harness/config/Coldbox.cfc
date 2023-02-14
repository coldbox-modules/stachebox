component{

	// Configure ColdBox Application
	function configure(){

		// coldbox directives
		coldbox = {
			//Application Setup
			appName 				= "Module Tester",

			//Development Settings
			reinitPassword			= "",
			handlersIndexAutoReload = true,
			modulesExternalLocation = [],

			//Implicit Events
			defaultEvent			= "",
			requestStartHandler		= "",
			requestEndHandler		= "",
			applicationStartHandler = "",
			applicationEndHandler	= "",
			sessionStartHandler 	= "",
			sessionEndHandler		= "",
			missingTemplateHandler	= "",

			//Error/Exception Handling
			exceptionHandler		= "",
			onInvalidEvent			= "",
			customErrorTemplate 	= "/coldbox/system/exceptions/Whoops.cfm",

			//Application Aspects
			handlerCaching 			= false,
			eventCaching			= false,
			jsonPayloadToRC 		= true
		};

		// environment settings, create a detectEnvironment() method to detect it yourself.
		// create a function with the name of the environment so it can be executed if that environment is detected
		// the value of the environment is a list of regex patterns to match the cgi.http_host.
		environments = {
			development = "localhost,127\.0\.0\.1"
		};

		// Module Directives
		modules = {
			// An array of modules names to load, empty means all of them
			include = [],
			// An array of modules names to NOT load, empty means none
			exclude = []
		};

		//Register interceptors as an array, we need order
		interceptors = [];

		//LogBox DSL
		logBox = {
			// Define Appenders
			appenders : {
				files : {
					class      : "coldbox.system.logging.appenders.RollingFileAppender",
					properties : { filename : "tester", filePath : "/#appMapping#/logs" }
				},
				console : { class : "coldbox.system.logging.appenders.ConsoleAppender" }
			},
			// Root Logger
			root  : { levelmax : "DEBUG", appenders : "*" },
			error : [ "coldbox.system.web.context.InterceptorState", "coldbox.system.ioc.Injector" ],
			fatal : [ "coldbox.system.web.context.InterceptorState", "coldbox.system.ioc.Injector" ]
		};

		moduleSettings = {
			"cbsecurity" : {
				"userService" : "UserService@stachebox"
			},
			"cbauth" : {
				"userServiceClass" : "UserService@stachebox"
			},
			"logstash" : {
				"enableAppenders" : true
			},
			"cfmigrations" : {
				"managers": {
                    "elasticsearch": {
                        "manager": "cbelasticsearch.models.migrations.Manager",
                        "migrationsDirectory": "/resources/migrations/elasticsearch",
                        "seedsDirectory": "/resources/migrations/seeds"
                    }
                }
			},
			"cbMailServices" : {
                // Default protocol to use, it must be defined in the mailers configuration
                "defaultProtocol" : "file",
                // Here you can register one or many mailers by name
                "mailers" : {
                    "file" : {
						class : "File",
						properties : {
							"filePath"  : "/includes/mail",
							"autoExpand": true
						}
					}
                },
                // The defaults for all mail config payloads and protocols
                "defaults" : {
                    "from" : "no-reply@stachebox-io",
                    "type" : "html"
                }
            }
		};

	}

	/**
	 * Load the Module you are testing
	 */
	function afterConfigurationLoad( event, interceptData, rc, prc ){
		controller.getModuleService()
			.registerAndActivateModule(
				moduleName 		= request.MODULE_NAME,
				invocationPath 	= "moduleroot"
			);
	}

}
component{
	function run( searchClient, mockData ){
		var logBox = application.cbController.getLogbox();
		var registry = logbox.getAppenderRegistry();
		var appender = registry[ "logstash_appender" ];

		var testApps = mockData.mock( $num=3, $type="words" );
		var testEnvironments = [ "development", "staging", "production" ];
		for( var app in TestApps ){
			var runTime = now();
			var startDate = dateAdd( "d", -7, now() );
			var time = duplicate( startDate );

			appender.setProperty( "applicationName", app );

			var testErrors = [];

			for( i = 1; i <= 20; i++ ){
				try{
					throw( type="stachebox.mockData.error", message=mockData.sentence()  )
				} catch( any e ){
					testErrors.append( e );
				}
			}

			while( time < runTime ){
				var activeError = testErrors[ randRange( 1, testErrors.len() ) ];

				var logEvent = new coldbox.system.logging.LogEvent(
									message=activeError.message,
									severity=1,
									extraInfo=activeError,
									category="mockData"
								);

				logEvent.setTimestamp( time );

				application.cbController.setSetting( "environment", testEnvironments[ randRange( 1, testEnvironments.len() )] );

				appender.logMessage( logEvent );

				time = dateAdd( "n", randRange( 1, 60 ), time );
			}

		}

		appender.setProperty( "applicationName", "stachebox-dev" );
		application.cbController.setSetting( "environment", "development" );


	}
}
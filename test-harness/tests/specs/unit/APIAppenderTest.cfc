/**
* The base model test case will use the 'model' annotation as the instantiation path
* and then create it, prepare it for mocking and then place it in the variables scope as 'model'. It is your
* responsibility to update the model annotation instantiation path and init your model.
*/
component extends="coldbox.system.testing.BaseTestCase"{

	/*********************************** LIFE CYCLE Methods ***********************************/
	this.loadColdbox = true;

	function beforeAll(){
		super.beforeAll();


		variables.model = new stachebox.models.logging.APIAppender(
			"APIAppenderTest",
			{
				"index" : ".stachebox-api-appender-tests",
				"releaseVersion" : "1.0.0",
				"userInfoUDF" : function(){
					return {
						"username" : "tester"
					};
				}
			}
		);

		makePublic( variables.model, "getRotationalIndexName", "getRotationalIndexName" );

		getInstance( "Client@cbelasticsearch" ).deleteIndex( variables.model.getRotationalIndexName() );

		debug( variables.model.getRotationalIndexName() );

		variables.model.onRegistration();

		variables.loge = getMockBox().createMock(className="coldbox.system.logging.LogEvent");

		// create an error message
		try{
			var a = b;
		} catch( any e ){

			variables.loge.init(
				message = len( e.detail ) ? e.detail : e.message,
				severity = 0,
				extraInfo = e.StackTrace,
				category = e.type
			);
		}

	}

	function afterAll(){
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){

		describe( "stachebox.models.logging.APIAppender Suite", function(){
			it( "Can create a log message", function(){
				// create a test error
				variables.model.logMessage( variables.loge );

				sleep( 1100 );

				debug( variables.model.getRotationalIndexName() );

				var documents = getWirebox().getInstance( "SearchBuilder@cbElasticsearch" ).new( variables.model.getRotationalIndexName() ).setQuery( { "match_all" : {} }).execute().getHits();

				expect( documents.len() ).toBeGT( 0 );

				var logMessage = documents[ 1 ].getMemento();

				debug( logMessage  );

				expect( logMessage )
					.toHaveKey( "application" )
					.toHaveKey( "release" )
					.toHaveKey( "userinfo" );


				expect( isJSON( logMessage.userInfo ) ).toBeTrue();
				expect( deserializeJSON( logMessage.userinfo ) ).toHaveKey( "username" );

			});

		});

	}

}

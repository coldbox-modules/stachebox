/*******************************************************************************
*	Integration Test as BDD (CF10+ or Railo 4.1 Plus)
*
*	Extends the integration class: coldbox.system.testing.BaseTestCase
*
*	so you can test your ColdBox application headlessly. The 'appMapping' points by default to
*	the '/root' mapping created in the test folder Application.cfc.  Please note that this
*	Application.cfc must mimic the real one in your root, including ORM settings if needed.
*
*	The 'execute()' method is used to execute a ColdBox event, with the following arguments
*	* event : the name of the event
*	* private : if the event is private or not
*	* prePostExempt : if the event needs to be exempt of pre post interceptors
*	* eventArguments : The struct of args to pass to the event
*	* renderResults : Render back the results of the event
*******************************************************************************/
component extends="coldbox.system.testing.BaseTestCase"{
	this.loadColdbox = true;
	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
		// do your own stuff here

		debug( application.cbController.getModuleService().isModuleRegistered( "stachebox" ) );

		var moduleSettings = application.cbController.getSettingStructure().moduleSettings.stachebox;
		variables.baseSettings = duplicate( application.cbController.getSettingStructure().moduleSettings.stachebox );

		// create an error message
		try{
			var a = b;
		} catch( any e ){
			variables.errorEntry = e;
		}

		var stacheboxAppender = createMock( "cbelasticsearch.models.logging.stacheboxAppender" );
		stacheboxAppender.init( "MockstacheboxAppender" );
		makePublic( stacheboxAppender, "getRotationalIndexName", "getRotationalIndexName" );

		variables.logEntry = {
			"application"  : "stachebox-test-suite",
			"index"        :  stacheboxAppender.getRotationalIndexName(),
			"release"      : "1",
			"type"         : "api",
			"level"        : "ERROR" ,
			"severity"     : 1,
			"category"     : "tests",
			"timestamp"    : dateTimeFormat( now(), "yyyy-mm-dd'T'hh:nn:ssZZ" ),
			"component"    : getMetadata( this ).name,
			"message"      : errorEntry.message,
			"stacktrace"   : errorEntry.stacktrace,
			"extrainfo"    : errorEntry.stacktrace,
			"snapshot"     : {},
			"userinfo"     : { "username" : "tester" },
			"event"        : { "foo" : "bar" }
		};

	}

	function afterAll(){
		// do your own stuff here
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){

		describe( "API Suite", function(){

			beforeEach(function( currentSpec ){
				setup();
			});

			afterEach( function( currentSpec ){
				application.cbController.getSettingStructure().moduleSettings.stachebox = variables.baseSettings;
			} );

			it( "Tests that the create method will return an invalid event if the configuration is set to disable the API", function(){
				application.cbController.getSettingStructure().moduleSettings.stachebox.enableAPI = false;

				var testEvent = newEventArgs( "POST" );
				testEvent.rc.entry = logEntry;


				var event = execute(
					route="/stachebox/api/logs",
					eventArgs=testEvent,
					renderResults=false
				);

				var prc = event.getCollection( private=true );
				expect( prc ).toHaveKey( "response" );
				debug( prc.response );
				expect( prc.response.getStatusCode() ).toBe( 405 );


			} );

			xit( "Tests that the create method will return Authorization failure if the IP address is incorrect", function(){

				var testEvent = newEventArgs( "POST" );
				testEvent.rc.entry = logEntry;


				var event = execute(
					route="/stachebox/api/logs",
					eventArgs=testEvent,
					renderResults=false
				);

				var prc = event.getCollection( private=true );
				expect( prc ).toHaveKey( "response" );
				debug( prc.response );
				expect( prc.response.getStatusCode() ).toBe( 403 );
			} );

			it( "Tests that the create method will return Authentication failure if the token is incorrect", function(){
				application.cbController.getSettingStructure().moduleSettings.stachebox.enableAPI = true;
				application.cbController.getSettingStructure().moduleSettings.stachebox.apiAuthToken = createUUID();

				var testEvent = newEventArgs( "POST" );
				testEvent.rc.entry = logEntry;

				var event = execute(
					route="/stachebox/api/logs",
					eventArgs=testEvent,
					renderResults=false
				);

				var prc = event.getCollection( private=true );
				expect( prc ).toHaveKey( "response" );
				debug( prc.response );
				expect( prc.response.getStatusCode() ).toBe( 401 );
			} );

			it( "Tests that the create method can create a log entry", function(){
				application.cbController.getSettingStructure().moduleSettings.stachebox.enableAPI = true;
				application.cbController.getSettingStructure().moduleSettings.stachebox.apiAuthToken = "";

				var testEvent = newEventArgs( "POST" );
				testEvent.rc.entry = logEntry;


				var event = execute(
					route="/stachebox/api/logs",
					eventArgs=testEvent,
					renderResults=false
				);

				var prc = event.getCollection( private=true );
				expect( prc ).toHaveKey( "response" );
				expect( prc.response.getStatusCode() ).toBe( 201 );
				debug( prc.response.getData() );
				expect( prc.response.getData() ).toBeStruct()
												.toHaveKey( "accepted" );


			} );


		});

	}

	function newEventArgs( method = "GET" ) {

		//clear out all request keys
		for( var key in request ){
			if( findNoCase( "wirebox:", key ) ){
				structDelete( REQUEST, key );
			}
		}

		setup();

		var event = getRequestContext();
		prepareMock( event )
			.$( "getHTTPMethod", arguments.method )
			.$( method = "getHTTPHeader", callback = function( string name ) {
				if ( arguments.name == "X-Requested-With" ){
					return "XMLHttpRequest";
				}
				return "";
			} );

		var rc = event.getCollection();
		var prc = event.getCollection( private=true );


		return {
			"event":event,
			"rc":rc,
			"prc":prc
		};
	}

}

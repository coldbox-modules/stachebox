/**
* My BDD Test
*/
component extends="tests.resources.BaseAPITestHelper"{

	property name="moduleSettings" inject="coldbox:moduleSettings:stachebox";

/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		this.loadColdbox = true;
		this.unloadColdbox = false;

		super.beforeAll();

		getWirebox().autowire( this );

		variables.baseSettings = duplicate( variables.moduleSettings );

		//create some test log entries
		for( var i = 1; i <= 20; i++ ){
			// create an error message
			try{
				var a = b;
			} catch( any e ){
				var errorEntry = e;
			}

			variables.logstashAppender = createMock( "cbelasticsearch.models.logging.LogstashAppender" );
			logstashAppender.init( "MockLogstashAppender" );
			makePublic( logstashAppender, "getRotationalIndexName", "getRotationalIndexName" );

			variables.logEntry = {
				"application"  : "stachebox-test-suite",
				"index"        : logstashAppender.getRotationalIndexName(),
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

		// create a test user for API access
		variables.userModel = getWirebox().getInstance( "UserService@stachebox" );
		variables.userMemento = {
			"firstName" : "Joe",
			"lastName" : "Blow",
			"email" : "Joe@blow.com",
			"password" : "Testing1234$",
			"isAdministrator" : true
		};
		variables.testUser = variables.userModel.getUser()
											.new( userMemento )
											.encryptPassword()
											.save();

		variables.authService = getWirebox().getInstance( "AuthenticationService@cbauth" );
		variables.jwtService = getWirebox().getInstance( "JWTService@cbsecurity" );
		sleep( 1000 );


	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		structAppend(
			variables.moduleSettings,
			variables.baseSettings,
			true
		);

		getWirebox().getInstance( "Client@cbelasticsearch" )
					.deleteByQuery(
						getWirebox().getInstance( "SearchBuilder@cbelasticsearch" )
									.new( variables.logstashAppender.getRotationalIndexName() )
									.filterTerm( "category", "tests" )
					);


		getWirebox().getInstance( "Client@cbelasticsearch" )
					.deleteByQuery(
						getWirebox().getInstance( "SearchBuilder@cbElasticsearch" )
									.new( getWirebox().getInstance( "User@stachebox" ).getSearchIndexName() )
									.filterTerm( "email", "Joe@blow.com" )
					);


	}

/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Log API specs", function(){

			beforeEach( function(){
				variables.authService.authenticate( variables.testUser.getEmail(), variables.userMemento.password );
			});
			afterEach( function(){
				variables.authService.logout();
			});

			it( "Will not allow access to an unauthenticated user", function(){
				variables.authService.logout();
				var testEventArgs = newEventArgs( "GET" );

				var event = execute(
					route="/stachebox/api/v1/logs",
					eventArgs=testEventArgs,
					renderResults=false
				);

				var prc = event.getPrivateCollection();

				expect( prc ).toHaveKey( "response" );
				expect( prc.response.getStatusCode() ).toBe( 401 );

			});

			xit( "Can conduct an open search", function(){
				expect( variables ).toHaveKey( "testUser" );

				var testEventArgs = newEventArgs( "GET" );

				prepareMock( testEventArgs.event );

				var token = jwtService.fromUser( testUser );

				testEventArgs.event.$( method = "getHTTPHeader", callback = function( string name ) {
					if ( arguments.name == "Authorization" ){
						return "Bearer " & token;
					}
					return "";
				} );

				var event = execute(
					route="/stachebox/api/v1/logs",
					eventArgs=testEventArgs,
					renderResults=false
				);

				var prc = event.getPrivateCollection();

				expect( prc ).toHaveKey( "response" );

				debug( prc.response.getData() );

				expect( prc.response.getStatusCode() ).toBe( 200 );

				expect( prc.response.getData() )
							.toBeStruct()
							.toHaveKey( "results" )
							.toHaveKey( "total" )
							.toHaveKey( "start" )
							.toHaveKey( "limit" )
							.toHaveKey( "aggregations" );

				expect( prc.response.getData().results.len() ).toBeGT( 0 );
			});

			xit( "Can Retrieve a single Log message", function(){

				var logId = getWirebox().getInstance( "SearchBuilder@cbElasticsearch" )
												.new( moduleSettings.logIndexPattern )
												.filterTerm( "level", "ERROR" )
												.setMaxRows( 1 )
												.execute()
												.getHits()
												.reduce( function( acc, doc ){
													acc = doc.getId();
													return acc;
												}, "" );

				expect( len( logId ) ).toBeGT( 0 );

				var testEventArgs = newEventArgs( "GET" );

				prepareMock( testEventArgs.event );

				var token = jwtService.fromUser( testUser );

				testEventArgs.event.$( method = "getHTTPHeader", callback = function( string name ) {
					if ( arguments.name == "Authorization" ){
						return "Bearer " & token;
					}
					return "";
				} );

				var event = execute(
					route="/stachebox/api/v1/logs/#logId#",
					eventArgs=testEventArgs,
					renderResults=false
				);

				var prc = event.getPrivateCollection();

				expect( prc ).toHaveKey( "response" );
				expect( prc.response.getStatusCode() ).toBe( 200 );

				expect( prc.response.getData() ).toBeStruct()
												.toHaveKey( "id" )
												.toHaveKey( "level" );

				expect( prc.response.getData().level ).toBe( "ERROR" );

			} );

			try{
				var foo = bar;
			} catch( any e ){
				var errorEntry = e;
			}

			it( "Can create a new log message", function(){
				var logEntry = {
					"application"  : "stachebox-test-suite",
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

				var testEventArgs = newEventArgs( "POST" );
				testEventArgs.rc.entry = logEntry;

				var event = execute(
					route="/stachebox/api/v1/logs",
					eventArgs=testEventArgs,
					renderResults=false
				);

				var prc = event.getPrivateCollection();
			} );


		});
	}

}


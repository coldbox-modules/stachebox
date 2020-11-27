/**
* My BDD Test
*/
component extends="coldbox.system.testing.BaseTestCase"{

/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		this.loadColdbox = true;
		this.unloadColdbox = false;

		super.beforeAll();

		variables.interceptor = new stachebox.interceptors.TokenAuthentication();

		prepareMock( interceptor )
			.$(
				method="jwtAuth",
				returns=getWirebox().getInstance( "JWTService@cbsecurity" )
			)
			.$(
				method = "auth",
				returns = getWirebox().getInstance( "AuthenticationService@cbAuth" )
			);

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
		sleep( 1000 );
	}

	// executes after all suites+specs in the run() method
	function afterAll(){

		getWirebox().getInstance( "SearchBuilder@cbElasticsearch" )
					.new( getWirebox().getInstance( "User@stachebox" ).getSearchIndexName() )
					.filterTerm( "email", "Joe@blow.com" )
					.execute()
					.getHits()
					.each( function( doc ){
						doc.delete()
					} );

	}

/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Token Authentication Tests", function(){

			it( "Can validate an inbound JWT token", function(){
				var authService = interceptor.auth();
				var jwtService = interceptor.jwtAuth();

				try{
					authService.logout();
				}catch( any e ){}

				var event =  prepareMock( getRequestContext() );

				var token = jwtService.fromUser( testUser );

				event.$( method = "getHTTPHeader", callback = function( string name ) {
					if ( arguments.name == "Authorization" ){
						return "Bearer " & token;
					}
					return "";
				} );


				interceptor.preProcess( event, {} );

				expect( interceptor.auth().check() ).toBeTrue();


			});

			it( "Will not validate an invalid token", function(){
				var authService = interceptor.auth();
				var jwtService = interceptor.jwtAuth();

				try{
					authService.logout();
				}catch( any e ){}

				var event =  prepareMock( getRequestContext() );

				var token = createUUID();

				event.$( method = "getHTTPHeader", callback = function( string name ) {
					if ( arguments.name == "Authorization" ){
						return "Bearer " & token;
					}
					return "";
				} );


				interceptor.preProcess( event, {} );

				expect( interceptor.auth().check() ).toBeFalse();


			});

		});
	}

}


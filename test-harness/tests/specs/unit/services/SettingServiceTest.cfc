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

		variables.model = prepareMock( new stachebox.models.services.SettingService() );
		variables.jwtService = getWirebox().getInstance( "JWTService@cbsecurity" );
		var userService = getWirebox().getInstance( "UserService@stachebox" );

		getWirebox().autowire( variables.model );

		variables.userMemento = {
			"firstName" : "Joe",
			"lastName" : "Blow",
			"email" : "Joe@blow.com",
			"password" : "Testing1234$",
			"isAdministrator" : true
		};
		variables.testUser = userService.getUser()
											.new( userMemento )
											.encryptPassword()
											.save( refresh=true );
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
		describe( "API Tokens", function(){
			it( "Can generate a reset token for a user", function(){
				var token = variables.model.generateAPIToken( user=variables.testUser, expiration=dateAdd( "h", 1, now() ) );
				var parsedToken = jwtService.decode( token );
				debug( parsedToken );
				expect( jwtService.parseToken( token, false, false ) ).toBe( parsedToken );
			} );
		});
	}
}
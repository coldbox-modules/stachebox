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

		variables.model = getWirebox().getInstance( "UserService@stachebox" );
		variables.userMemento = {
			"firstName" : "Joe",
			"lastName" : "Blow",
			"email" : "#createUUID()#@blow.com",
			"password" : "Testing1234$",
			"isAdministrator" : true
		};
		variables.testUser = variables.model.getUser()
											.new( userMemento )
											.encryptPassword()
											.save();
		sleep( 500 );
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		getWirebox().getInstance( "SearchBuilder@cbElasticsearch" )
					.new( getWirebox().getInstance( "User@stachebox" ).getSearchIndexName() )
					.filterTerm( "email", variables.userMemento.email )
					.execute()
					.getHits()
					.each( function( doc ){
						doc.delete()
					} );
	}

/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "cbAuth Interface Method Specs", function(){

			it( "Tests isValidCredentials()", function(){
				expect( variables ).toHaveKey( "userMemento" );
				expect( variables.model.isValidCredentials( userMemento.email, userMemento.password ) ).toBeTrue();
			});

			it( "Tests retrieveUserById()", function(){
				expect( variables ).toHaveKey( "TestUser" );
				expect( isNull( variables.model.retrieveUserById( variables.testUser.getId() ) ) ).toBeFalse();
			});

			it( "Tests retrieveUserByUsername()", function(){
				expect( variables ).toHaveKey( "TestUser" );
				expect( isNull( variables.model.retrieveUserByUsername( variables.testUser.getEmail() ) ) ).toBeFalse();
			});

		});

	}

}


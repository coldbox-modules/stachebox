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

		variables.searchClient = getWirebox().getInstance( "Client@cbelasticsearch" );

	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		getWirebox().getInstance( "SearchBuilder@cbElasticsearch" )
					.new( getWirebox().getInstance( "User@stachebox" ).getSearchIndexName() )
					.filterTerm( "email", "#createUUID()#@blow.com" )
					.execute()
					.getHits()
					.each( function( doc ){
						doc.delete();
					} );


	}

/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "User CRUD Actions", function(){

			it( "Can create a new user", function(){
				var model = getWirebox().getInstance( "User@stachebox" );
				model.new(
					{
						"firstName" : "Joe",
						"lastName" : "Blow",
						"email" : "#createUUID()#@blow.com",
						"password" : "Testing1234$",
						"isAdministrator" : true
					}
				);

				model.save();

				var memento = model.getMemento();

				expect( isNull( model.get( model.getId() ) ) ).toBeFalse();

				variables.testUser = model;

			});

			it( "Can update an existing user", function(){
				expect( variables ).toHaveKey( "testUser" );

				variables.testUser.populate(
					{
						"lastName" : "Blowhard"
					}
				);

				variables.testUser.save();

				sleep( 1000 );

				var updatedUser = getWirebox().getInstance( "User@stachebox" ).get( variables.testUser.getId() );

				expect( updatedUser.getLastName() ).toBe( "Blowhard" );
			});

			it( "Can validate and fail if an email is already in the index", function(){
				expect( variables ).toHaveKey( "testUser" );

				var testMemento = variables.testUser.getMemento();
				structDelete( testMemento, "id" );


				expect(	function(){
					getWirebox.getInstance( "User@stachebox" ).new( testMemento ).validateOrFail();
				} ).toThrow();


			} );



			it( "Can delete a user", function(){
				expect( variables ).toHaveKey( "testUser" );

				variables.testUser.delete();

				sleep( 1000 );

				expect( isNull( getWirebox().getInstance( "User@stachebox" ).get( variables.testUser.getId() ) ) ).toBeTrue();

			});


		});

	}

}


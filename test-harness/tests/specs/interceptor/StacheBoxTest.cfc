/**
* My BDD Test
*/
component extends="coldbox.system.testing.BaseTestCase"{

/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		super.beforeAll();
		variables.model = prepareMock( new stachebox.interceptors.Stachebox() );
		getWirebox().autowire( variables.model );
		variables.authenticationService = getWirebox().getInstance( "AuthenticationService@cbauth" );
		variables.model.$( method="auth", callback=function(){ return variables.authenticationService; } );
		variables.model.$( method="getInstance", callback=function( dsl ){ return getWirebox().getInstance( dsl ) } );
		variables.model.$( method="getWirebox", callback=function(){ return getWirebox() } );
		variables.moduleSettings = getWirebox().getInstance( "coldbox:moduleSettings:stachebox" );
		variables.model.$( method="getModuleSettings", callback=function( moduleName ){ return getController().getSetting( "modules" )[ moduleName ].settings; } );

	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		super.afterAll();
	}

/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Stachebox Lifecycle Methods", function(){

			beforeEach( function(){
				setup();
				// we can't use a mock due to module settings in use
				variables.event = getRequestContext();
			} );

			it( "tests postModuleLoad", function(){
				variables.model.postModuleLoad( event=variables.event, interceptData={ "moduleName" : "stachebox" } );
				var searchClient = getInstance( "Client@cbelasticsearch" );
				expect( searchClient.indexExists( moduleSettings.settingsIndex ) ).toBeTrue();
				expect( searchClient.indexExists( moduleSettings.usersIndex ) ).toBeTrue();
			});

			it( "tests onRequestCapture", function(){
				variables.model.onRequestCapture( event=variables.event, rc=variables.event.getCollection(), prc=variables.event.getPrivateCollection() );
				expect( variables.event.getPrivateCollection() ).toHaveKey( "globalData" );
			} );

		});
	}

}


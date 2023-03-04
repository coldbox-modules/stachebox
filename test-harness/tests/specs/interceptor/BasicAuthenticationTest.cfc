/**
* My BDD Test
*/
component extends="coldbox.system.testing.BaseTestCase"{

	/*********************************** LIFE CYCLE Methods ***********************************/

		// executes before all suites+specs in the run() method
		function beforeAll(){
			super.beforeAll();
			variables.model = prepareMock( new stachebox.interceptors.BasicAuthentication() );
			getWirebox().autowire( variables.model );
			variables.authenticationService = getWirebox().getInstance( "AuthenticationService@cbauth" );
			variables.model.$( method="auth", callback=function(){ return variables.authenticationService; } );
			variables.model.$( method="getInstance", callback=function( dsl ){ return getWirebox().getInstance( dsl ) } );
			variables.moduleSettings = getWirebox().getInstance( "coldbox:moduleSettings:stachebox" );

			variables.userMemento = {
				"firstName" : "Joe",
				"lastName" : "Blow",
				"email" : "#createUUID()#@blow.com",
				"password" : "Testing1234$",
				"isAdministrator" : true
			};

			variables.testUser = getWirebox().getInstance( "UserService@stachebox" )
												.getUser()
												.new( userMemento )
												.encryptPassword()
												.save();
		}

		// executes after all suites+specs in the run() method
		function afterAll(){
			getWirebox().getInstance( "SearchBuilder@cbElasticsearch" )
						.new( getWirebox().getInstance( "User@stachebox" ).getSearchIndexName() )
						.filterTerm( "email", "#createUUID()#@blow.com" )
						.execute()
						.getHits()
						.each( function( doc ){
							doc.delete()
						} );
		}

	/*********************************** BDD SUITES ***********************************/

		function run( testResults, testBox ){
			// all your suites go here.
			describe( "Basic Authentication", function(){

				beforeEach( function(){
					variables.authenticationService.logout();
				});

				it( "It can use basic authentication for a valid user", function(){
					var testContext = getMockRequestContext();
					testContext.$(
						"getHttpHeader",
						"Basic " & ToBase64( variables.userMemento.email & ":" & variables.userMemento.password )
					);
					variables.model.onRequestCapture( event=testContext, rc=testContext.getCollection(), prc=testContext.getPrivateCollection() );
					expect( variables.authenticationService.check() ).toBeTrue();

					// Make sure we are logged out a the end of the request
					variables.model.postProcess( event=testContext, rc=testContext.getCollection(), prc=testContext.getPrivateCollection() );
					expect( variables.authenticationService.check() ).toBeFalse();

				});

			});
		}

	}


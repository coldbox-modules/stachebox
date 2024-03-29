/**
* My BDD Test
*/
component extends="coldbox.system.testing.BaseTestCase"{

	/*********************************** LIFE CYCLE Methods ***********************************/

		// executes before all suites+specs in the run() method
		function beforeAll(){
			super.beforeAll();
			variables.model = prepareMock( new stachebox.interceptors.TokenAuthentication() );
			getWirebox().autowire( variables.model );
			variables.authenticationService = getWirebox().getInstance( "AuthenticationService@cbauth" );
			variables.model.$( method="auth", callback=function(){ return variables.authenticationService; } );
			variables.model.$( method="getInstance", callback=function( dsl ){ return getWirebox().getInstance( dsl ) } );
			variables.moduleSettings = getWirebox().getInstance( "coldbox:moduleSettings:stachebox" );
			variables.deployUser = getWirebox().getInstance( "UserService@stachebox" ).retrieveUserByUsername( moduleSettings.tokenReporter );
			var tokenSetting = getWirebox().getInstance( "SettingService@stachebox" ).getByName( "apiTokens" );
			variables.APITokens = tokenSetting.getMemento().value;
			if( !variables.APITokens.len() ){
				var settingService = getInstance( "SettingService@stachebox" );
				variables.APITokens.append( settingService.generateAPIToken() );
				tokenSetting.getMemento().value = tokenSetting.getClient().getUtil().toJSON( variables.APITokens );
				tokenSetting.save( refresh=true );
			}
		}

		// executes after all suites+specs in the run() method
		function afterAll(){

		}

	/*********************************** BDD SUITES ***********************************/

		function run( testResults, testBox ){
			// all your suites go here.
			describe( "Token Authentication", function(){

				beforeEach( function(){
					variables.authenticationService.logout();
				});


				it( "It can authenticate a valid token", function(){
					expect( variables.APITokens ).toBeArray();
					expect( variables.APITokens.len() ).toBeGTE( 1 );
					var testContext = getMockRequestContext();
					var testToken = variables.APITokens[ 1 ];
					testContext.$(
						"getHttpHeader",
						"Bearer " & testToken
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


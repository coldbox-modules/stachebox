/**
* The base model test case will use the 'model' annotation as the instantiation path
* and then create it, prepare it for mocking and then place it in the variables scope as 'model'. It is your
* responsibility to update the model annotation instantiation path and init your model.
*/
component extends="coldbox.system.testing.BaseTestCase" model="stachebox.models.logging.APIEventAppender"{

	/*********************************** LIFE CYCLE Methods ***********************************/
	this.loadColdbox = true;

	function beforeAll(){
		super.beforeAll();

		// init the model object
		variables.model = new stachebox.models.logging.APIEventAppender(
			"EventAppenderTest",
			{}
		);
	}

	function afterAll(){
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){

		describe( "stachebox.models.APIEventAppender Suite", function(){
			it( "Can create a log message", function(){
				// create an error for our tests
				try{
					var a = b;
				} catch( any e ){
					variables.testError = e;
				}

				debug( testError );

				variables.model.logMessage(
					{
						"type"         : "api",
						"level"        : "ERROR" ,
						"severity"     : 1,
						"category"     : "test",
						"timestamp"    : dateTimeFormat( now(), "yyyy-mm-dd'T'hh:nn:ssZZ" ),
						"component"    : "tests",
						"message"      : "This was an error message",
						"stacktrace"   : testError.stacktrace
					}
				);
			});

		});

	}

}

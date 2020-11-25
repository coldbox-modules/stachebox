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

	}

	// executes after all suites+specs in the run() method
	function afterAll(){

	}

/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "User CRUD Actions", function(){

			it( "Can create a new user", function(){


			});

		});
	}

}


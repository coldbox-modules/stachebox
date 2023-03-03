component extends="coldbox.system.EventHandler" {

	function index( event, rc, prc ){}

	function emailTest( event, rc, prc ){
		var user = getInstance( "UserService@stachebox" ).retrieveUserByUsername( "jclausen@ortussolutions.com" );
		event.setView(
			layout = "Email",
			view = "email/passwordReset",
			args = {
				"user" : user.getMemento(),
				"token" : "blah"
			}
		);
	}
}
component extends="coldbox.system.EventHandler" {

	function index( event, rc, prc ){}

	function emailTest( event, rc, prc ){
		var project = getInstance( "SettingService@stachebox" ).getByName( "projects" ).getMemento().value[ 1 ];
		var searchParams = {
			"labels.application" : project.applications,
			"stachebox.isSuppressed" : false,
			"collapse" : "stachebox.signature",
			"maxRows" : 25,
			"minDate" : dateAdd( "m", -1, now() )
		};
		var searchResults = getInstance( "LogSearchService@stachebox" ).search( searchParams );
		event.setView(
			layout = "Email",
			view = "email/projectNotification",
			args = {
				"errors" : searchResults,
				"project" : project,
				"reportPeriod" : "month",
				"frequency" : "monthly",
				"baseURL" : event.getHTMLBaseURL()
			}
		);
	}
}
component {
	property name="wirebox" inject="wirebox";

    function up( searchClient ) {
		var moduleSettings = wirebox.getInstance( "coldbox:moduleSettings:stachebox" );

		if( findNoCase( "@stachebox", moduleSettings.cbsecurity.userService ) ){
			var searchBuilder = searchClient.newSearchBuilder()
									.new( moduleSettings.usersIndex )
									.mustNotExist( "allowLogin" );
			if( searchBuilder.count() ){
				client.updateByQuery(
					searchBuilder,
					{
						"lang" : "painless",
						"source" : "ctx._source.allowLogin = true"
					},
					true
				);
			}
		}

		var indexPattern = wirebox.getInstance( "SettingService@stachebox" ).getByName( "logIndexPattern" ).getMemento();
		if( findNoCase( "logstash-", indexPattern.value ) ){
			indexPattern.value = "logs-*";
			searchClient.newDocument().new( moduleSettings.settingsIndex ).populate( indexPattern ).setId( indexPattern.id ).save();
		}
    }

    function down( searchClient ) {

    }

}

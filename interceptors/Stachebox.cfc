component{
	property name="moduleSettings" inject="coldbox:moduleSettings:stachebox";
	property name="searchClient" inject="Client@cbelasticsearch";

	function postModuleLoad( event, interceptData ){
		if( interceptData.moduleName == "stachebox" ){
			ensureSettingsIndex()
				.ensureUserIndex()
				.ensureDefaultAdminUser();
		}
	}

	function ensureSettingsIndex(){
		if( !searchClient.indexExists( variables.moduleSettings.settingsIndex ) ){
			getInstance( "IndexBuilder@cbelasticsearch" )
				.new(
					name=variables.moduleSettings.settingsIndex,
					properties=new stachebox.models.config.indices.Settings().getConfig()
				).save();
		}

		return this;
	}

	function ensureUserIndex(){

		if( findNoCase( "@stachebox", variables.moduleSettings.cbsecurity.userService ) && !searchClient.indexExists( variables.moduleSettings.usersIndex ) ){
			getInstance( "IndexBuilder@cbelasticsearch" )
				.new(
					name=variables.moduleSettings.usersIndex,
					properties=new stachebox.models.config.indices.Users().getConfig()
				).save();
		}

		return this;

	}

	function ensureDefaultAdminUser(){
		if( findNoCase( "@stachebox", variables.moduleSettings.cbsecurity.userService ) && len( variables.moduleSettings.adminEmail ) ){
			var logoFile = expandPath( '/stachebox/resources/assets/images/stachebox-icon.png' );
			var adminUser = getInstance( "User@stachebox" )
										.new(
											{
												"firstName" : "Stachebox",
												"lastName"  : "Admin",
												"email"     : variables.moduleSettings.adminEmail,
												"password"  : variables.moduleSettings.adminPassword,
												"avatar"    : "data:image/png;base64,#toBase64( fileReadBinary( logoFile ) )#"
											}
										).save();
		}
	}
}
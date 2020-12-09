component{
	property name="moduleSettings" inject="coldbox:moduleSettings:stachebox";
	property name="searchClient" inject="Client@cbelasticsearch";
	property name="wirebox" inject="wirebox";
	property name="moduleService" inject="coldbox:ModuleService";

	function postModuleLoad( event, interceptData ){
		if( interceptData.moduleName == "stachebox" ){
			ensureSettingsIndex()
				.applyCustomSettings()
				.ensureUserIndex()
				.ensureDefaultAdminUser();

			ensureStacheboxMappings();
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



		var defaults = [
			{ "name" : "applicationAliases", "value" : '{}' },
			{ "name" : "logIndexPattern", "value" : variables.moduleSettings.logIndexPattern },
			{ "name" : "beatsIndexPattern", "value" : variables.moduleSettings.beatsIndexPattern },
			{ "name" : "neverExpose", "value" : "password|cookie|JSessionID|CFIDE" }
		];

		var searchBuilder = getInstance( "SearchBuilder@cbelasticsearch" ).new( variables.moduleSettings.settingsIndex );
		var uuidLib = createobject("java", "java.util.UUID");
		defaults.each( function( setting ){
			searchBuilder.setQuery( { "term" : { "#setting.name#" : setting.value } } );
			if( !searchBuilder.count() ){
				setting[ "id" ] = uuidLib.randomUUID().toString();
				getInstance( "Document@cbelasticsearch" )
					.new( index = variables.moduleSettings.settingsIndex, properties = setting )
					.save();
			}
		} );

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
		if(
			findNoCase( "@stachebox", variables.moduleSettings.cbsecurity.userService )
			&&
			len( variables.moduleSettings.adminEmail )
			&& isNull( getInstance( "User@stachebox" ).findByEmail( variables.moduleSettings.adminEmail ) )
		){
			var logoFile = expandPath( '/stachebox/resources/assets/images/stachebox-icon.png' );
			var adminUser = getInstance( "User@stachebox" )
										.new(
											{
												"firstName" : "Stachebox",
												"lastName"  : "Admin",
												"email"     : variables.moduleSettings.adminEmail,
												"password"  : variables.moduleSettings.adminPassword,
												"avatar"    : "data:image/png;base64,#toBase64( fileReadBinary( logoFile ) )#",
												"isAdministrator" : true
											}
										).encryptPassword().save();
		}
		return this;
	}

	function applyCustomSettings(){
		var searchBuilder = getInstance( "SearchBuilder@cbelasticsearch" ).new( variables.moduleSettings.settingsIndex ).setQuery( { "match_all" : {} } );
		searchBuilder.setMaxRows( searchBuilder.count() );

		searchBuilder.execute().getHits().each( function( doc ){
			var memento = doc.getMemento();
			if( isJSON( memento.value ) ){
				memento.value = deserializeJSON( memento.value );
			}
			variables.moduleSettings[ memento.name ] = memento.value;
		} );

		return this;

	}

	function onRequestCapture( event, rc, prc ){
		prc.globalData = {
			"stachebox" : {
				"baseHref" : event.getModuleRoot( "stachebox" ),
				"isStandalone" : getModuleSettings( "stachebox", "isStandalone", false ),
				"logIndexPattern" : getModuleSettings( "stachebox", "logIndexPattern" ),
				"beatsIndexPattern" : getModuleSettings( "stachebox", "beatsIndexPattern" )
			}
		};
	}

	function ensureStacheboxMappings(){
		var mapping = new cbelasticsearch.models.logging.LogstashAppender( name="sample" ).getIndexConfig();
		structDelete( mapping, "settings" )

		getInstance( "IndexBuilder@cbelasticsearch" ).new(
            name=variables.moduleSettings.logIndexPattern,
            properties=mapping
		).save();

		getInstance( "IndexBuilder@cbelasticsearch" ).new(
			name=variables.moduleSettings.beatsIndexPattern,
			properties = {
				"mappings" : {
					"properties" :{
						"stachebox" : mapping.mappings.properties.stachebox
					}
				}
			}
		).save();

	}

	function onStacheboxSettingUpdate( event, interceptData ){
		lock scope="application" type="exclusive" throwontimeout="true" timeout="20"{
			variables.moduleSettings[ interceptData.setting.name ] = interceptData.setting.value;
			var allModuleSettings = getSetting( "moduleSettings" );
			structAppend( allModuleSettings.stachebox, variables.moduleSettings, true );
			setSetting( "moduleSettings", allModuleSettings );
			variables.wirebox.clearSingletons();
			variables.moduleService.reload( "stachebox" );
		}
	}
}
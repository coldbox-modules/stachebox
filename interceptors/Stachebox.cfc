component{
	property name="moduleSettings" inject="coldbox:moduleSettings:stachebox";
	property name="searchClient" inject="Client@cbelasticsearch";
	property name="wirebox" inject="wirebox";
	property name="moduleService" inject="coldbox:ModuleService";
	property name="settingServce" inject="SettingService@stachebox";
	property name="userService" inject="UserService@stachebox";

	function postModuleLoad( event, interceptData ){
		if( interceptData.moduleName == "stachebox" ){
			ensureSettingsIndex()
				.applyCustomSettings()
				.ensureUserIndex()
				.ensureDefaultAdminUser()
				.ensureTokenReporter();
			runMigrations();
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
			{ "name" : "neverExpose", "value" : "password|cookie|JSessionID|CFIDE" },
			{ "name" : "projects", "value" : "[]"},
			{ "name" : "apiTokens", "value" : "[]"}
		];

		var searchBuilder = getInstance( "SearchBuilder@cbelasticsearch" ).new( variables.moduleSettings.settingsIndex );
		var uuidLib = createobject("java", "java.util.UUID");
		defaults.each( function( setting ){
			searchBuilder.setQuery( { "term" : { "name.keyword" : "#setting.name#" } } );
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

		if( findNoCase( "@stachebox", variables.moduleSettings.cbsecurity.authentication.userService ) && !searchClient.indexExists( variables.moduleSettings.usersIndex ) ){
			getInstance( "IndexBuilder@cbelasticsearch" )
				.new(
					name=variables.moduleSettings.usersIndex,
					properties=new stachebox.models.config.indices.Users().getConfig()
				).save();
		}

		return this;

	}

	function ensureTokenReporter(){
		if( findNoCase( "@stachebox", variables.moduleSettings.cbsecurity.authentication.userService ) ){
			var reporterUsername = moduleSettings.tokenReporter;
			if( isNull( userService.retrieveUserByUsername( reporterUsername ) ) ){
				var logoFile = expandPath( '/stachebox/includes/images/stachebox-icon.png' );
				var adminUser = getInstance( "User@stachebox" )
											.new(
												{
													"firstName" : "Token",
													"lastName"  : "Reporter",
													"email"     : reporterUsername,
													"password"  : createUUID(),
													"avatar"    : "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAgAAAAIAQMAAAD+wSzIAAAABlBMVEX///+/v7+jQ3Y5AAAADklEQVQI12P4AIX8EAgALgAD/aNpbtEAAAAASUVORK5CYII",
													"isAdministrator" : false,
													"allowLogin" : false
												}
											).encryptPassword().save();
			}
		}
		return this;
	}

	function ensureDefaultAdminUser(){
		if(
			findNoCase( "@stachebox", variables.moduleSettings.cbsecurity.authentication.userService )
			&&
			len( variables.moduleSettings.adminEmail )
			&& isNull( userService.retrieveUserByUsername( variables.moduleSettings.adminEmail ) )
		){
			var logoFile = expandPath( '/stachebox/includes/images/stachebox-icon.png' );
			var adminUser = getInstance( "User@stachebox" )
										.new(
											{
												"firstName" : "stachebox",
												"lastName"  : "Admin",
												"email"     : variables.moduleSettings.adminEmail,
												"password"  : variables.moduleSettings.adminPassword,
												"avatar"    : "data:image/png;base64,#toBase64( fileReadBinary( logoFile ) )#",
												"isAdministrator" : true,
												"allowLogin" : true
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

		var cbSecuritySettings = getModuleSettings( "cbsecurity" );
		param moduleSettings.isStandalone = false;

		var i18nBundles = getInstance( "i18n@cbi18n" ).getResourceService().getBundles().stachebox;
		var locales = {};
		i18nBundles.keyArray().each( function( locale){
			locales[ locale ] = i18nBundles[ locale ];
		} );

		var javaURI = createObject( "java", "java.net.URI" );
		var basePath = javaURI.create( event.getSESBaseURL() ).getPath();
		var stacheboxBasePath = basePath & "stachebox";
		var loginUrl = !findNoCase( "@stachebox", variables.moduleSettings.cbsecurity.authentication.userService )
							? cbSecuritySettings.keyExists( "invalidAuthenticationEvent" ) ? cbSecuritySettings.invalidAuthenticationEvent : stacheboxBasePath & "/login"
							: stacheboxBasePath & "/login";


		prc.globalData = {
			"stachebox" : {
				"sesBaseURL" : stacheboxBasePath,
				"sesBasePath" : stacheboxBasePath,
				"baseHref" : event.getModuleRoot( "stachebox" ),
				"apiBaseHref" : stacheboxBasePath,
				"isStandalone" : moduleSettings.isStandalone,
				"logIndexPattern" : moduleSettings.logIndexPattern,
				"beatsIndexPattern" : moduleSettings.beatsIndexPattern,
				"internalSecurity" :  javacast( "boolean", findNoCase( "@stachebox",  moduleSettings.cbsecurity.authentication.userService ) ),
				"loginURL" :  loginUrl,
				"i18nLocales" : locales,
				"projects" : settingServce.getByName( "projects" ).getMemento().value.reduce(
					function( acc, value ){
						structDelete( value, "owner" );
						structDelete( value, "emailDistributionList" );
						structDelete( value, "summaryEmails" );
						structDelete( value, "frequency" );
						acc.append( value );
						return acc;
					},
					[]
				)
			}
		};
	}

	function onstacheboxSettingUpdate( event, interceptData ){
		lock scope="application" type="exclusive" throwontimeout="true" timeout="20"{
			variables.moduleSettings[ interceptData.setting.name ] = interceptData.setting.value;
			var allModuleSettings = getSetting( "moduleSettings" );
			structAppend( allModuleSettings.stachebox, variables.moduleSettings, true );
			setSetting( "moduleSettings", allModuleSettings );
			variables.wirebox.clearSingletons();
			variables.moduleService.reload( "stachebox" );
		}
	}

	function runMigrations(){
		var migrationService = new cfmigrations.models.MigrationService(
			manager = "cbelasticsearch.models.migrations.Manager",
			migrationsDirectory = "/stachebox/models/migrations",
			properties = {
				migrationsIndex : ".stachebox-migrations"
			}
		);
		getWirebox().autowire( migrationService );
		migrationService.runAllMigrations( "up" );
	}
}

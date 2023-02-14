component extends="BaseAPIHandler" secured="Administer:Settings"{

	property name="moduleSettings" inject="coldbox:moduleSettings:stachebox";
	property name="settingService" inject="SettingService@stachebox";
	property name="ESUtil" inject="Util@cbelasticsearch";

	// ( GET ) /api/v1/settings
	function index( event, rc, prc ){
		prc.response.setData(
			settingService.getAllSettings()
		);
	}

	// ( GET ) /api/v1/settings/:id
	function show( event, rc, prc ){

		var entry = settingService.getById( rc.id );

		if( isNull( entry ) ){
			return onEntityNotFoundException( argumentCollection=arguments );
		}

		prc.response.setData( entry.getMemento() );

	}

	// ( POST ) /api/v1/settings
	function create( event, rc, prc ){
		if( !len( event.getValue( "name", "" ) ) || !event.valueExists( "value" ) ){
			return this.onExpectationFailed(
				event,
				rc,
				prc,
				"An expected key was not present in the request body.  Could not continue."
			)
		} else if(
			getInstance( "SearchBuilder@cbElasticsearch" )
						.new( moduleSettings.settings.index )
						.term( "name.keyword", rc.name )
						.count()
		){
			throw(
				type 			= "ValidationException",
				message 		= "The setting #rc.name# is already in use.  Please update to change this setting",
				extendedInfo 	= []
			);
		}

		var uuidLib = createobject("java", "java.util.UUID");
		var memento = {
			"id" : uuidLib.randomUUID().toString(),
			"name" : rc.name,
			"value" : rc.value
		};

		if( !isSimpleValue( memento.value ) ){
			memento.value = ESUtil.toJSON( memento.value )
		}

		prc.response.setData(
			expandDoc( getInstance( "Document@cbelaticsearch" )
				.new(
					index = moduleSettings.settingsIndex,
					properties = memento
				).save() ).getMemento()
		);

		announce( "onStacheboxSettingUpdate", { setting : prc.response.getData() } );


	}


	// ( PUT||PATCH ) /api/v1/settings/:id
	function update( event, rc, prc ){
		var entry = settingService.getById( rc.id );

		if( isNull( entry ) ){
			return onEntityNotFoundException( argumentCollection=arguments );
		}

		entry.getMemento().value = isSimpleValue( rc.value ) ? rc.value : ESUtil.toJSON( rc.value ) ;

		prc.response.setData( expandDoc( entry.save() ).getMemento() );
	}


	// ( DELETE ) /api/v1/settings/:id
	function delete( event, rc, prc ) secured="StacheboxAdministrator"{
		var entry = settingService.getById( rc.id );

		if( isNull( entry ) ){
			return onEntityNotFoundException( argumentCollection=arguments );
		}

		entry.delete();

		prc.response.setStatusCode( STATUS.NO_CONTENT );
	}

	// ( POST ) /api/v1/settings/token
	function generateToken( event, rc, prc ) secured="StacheboxAdministrator"{
		prc.response.setData( { "token" : settingService.generateAPIToken() } ).setStatusCode( STATUS.CREATED )
	}

	function expandDoc( required Document doc ){
		return settingService.expandDoc( arguments.doc );
	}

}
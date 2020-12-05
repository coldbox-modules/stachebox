component extends="BaseAPIHandler" secured="Administer:Settings"{

	property name="moduleSettings" inject="coldbox:moduleSettings:stachebox";
	property name="ESUtil" inject="Util@cbelasticsearch";

	// ( GET ) /api/v1/settings
	function index( event, rc, prc ){

		var searchBuilder = getInstance( "SearchBuilder@cbelasticsearch" )
									.new( moduleSettings.settingsIndex )
									.setQuery( { "match_all" : {} } );
		searchBuilder.setMaxRows( searchBuilder.count() );

		prc.response.setData(
			searchBuilder.execute().getHits().map( function( entry ){
				return expandDoc( entry ).getMemento();
			} )
		);

	}

	// ( GET ) /api/v1/settings/:id
	function show( event, rc, prc ){

		var entry = getInstance( "Client@cbelasticsearch" ).get( rc.id, moduleSettings.settingsIndex );

		if( isNull( entry ) ){
			return onEntityNotFoundException( argumentCollection=arguments );
		}

		prc.response.setData( expandDoc( entry ).getMemento() );

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
						.term( "name", rc.name )
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

		announceInterception( "onStacheboxSettingUpdate", { setting : prc.response.getData() } );


	}


	// ( PUT||PATCH ) /api/v1/settings/:id
	function update( event, rc, prc ){
		var entry = getInstance( "Client@cbelasticsearch" ).get( rc.id, moduleSettings.settingsIndex );

		if( isNull( entry ) ){
			return onEntityNotFoundException( argumentCollection=arguments );
		}

		entry.getMemento().value = isSimpleValue( rc.value ) ? rc.value : ESUtil.toJSON( rc.value ) ;

		prc.response.setData( expandDoc( entry.save() ).getMemento() );
	}


	// ( DELETE ) /api/v1/settings/:id
	function delete( event, rc, prc ) secured="Stachebox:Administrator"{
		var entry = getInstance( "Client@cbelasticsearch" ).get( rc.id, moduleSettings.settingsIndex );

		if( isNull( entry ) ){
			return onEntityNotFoundException( argumentCollection=arguments );
		}

		entry.delete();

		prc.response.setStatusCode( STATUS.NO_CONTENT );
	}

	function expandDoc( required Document doc ){
		var entryMemento = arguments.doc.getMemento();
		entryMemento[ "id" ] = arguments.doc.getId();
		if( isJSON( entryMemento.value ) ){
			entryMemento.value = deserializeJSON( entryMemento.value )
		}
		return arguments.doc;
	}

}
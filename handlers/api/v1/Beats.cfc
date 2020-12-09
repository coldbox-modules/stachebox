component extends="BaseAPIHandler" secured{

	property name="moduleSettings" inject="coldbox:moduleSettings:stachebox";

	// ( GET ) /api/v1/logs
	function index( event, rc, prc ){

		var searchResult = getInstance( "BeatSearchService@stachebox" ).search( rc );
		searchResult.results = searchResult.results.map( function( item ){ return expandEntry( item ); } );

		prc.response.setData( searchResult );

	}

	// ( GET ) /api/v1/logs/:id
	function show( event, rc, prc ){

		var entry = getInstance( "SearchBuilder@cbElasticsearch" )
							.new( variables.moduleSettings.beatsIndexPattern )
							.term( "_id", rc.id )
							.setMaxRows( 1 )
							.execute()
							.getHits()
							.reduce( function( acc, doc ){
								return doc;
							} );

		if( isNull( entry ) ){
			return onEntityNotFoundException( argumentCollection=arguments );
		}

		var entryMemento = entry.getMemento();
		entryMemento[ "id" ] = entry.getId();
		param entryMemento.stachebox = {};
		entryMemento[ "occurrences" ] = entryMemento.stachebox.keyExists( "signature" )
											? getInstance( "SearchBuilder@cbElasticsearch" )
												.new( variables.moduleSettings.beatsIndexPattern )
												.term( "stachebox.signature", entryMemento.stachebox.signature )
												.count()
											: 1;

		prc.response.setData(
			expandEntry( entry.getMemento() )
		);

	}

	// ( POST ) /api/v1/logs - not implemented
	function create( event, rc, prc ){
		return onInvalidHTTPMethod( argumentCollection = arguments )
	}


	// ( PUT||PATCH ) /api/v1/logs/:id
	function update( event, rc, prc ){
		if( !event.valueExists( "entry" ) ){
			prc.response.setError( true )
						.setStatusCode( status.BAD_REQUEST )
						.addMessage( "The key `entry` does not exist in the request body payload" );
			return;
		}

		announceInterception( "ensureStacheboxMappings" );
		// we cannot use `get()` because we are searching across multiple indices
		var entry = getInstance( "SearchBuilder@cbElasticsearch" )
							.new( variables.moduleSettings.beatsIndexPattern )
							.term( "_id", rc.id )
							.setMaxRows( 1 )
							.execute()
							.getHits()
							.reduce( function( acc, doc ){
								return doc;
							} );

		if( isNull( entry ) ){
			return onEntityNotFoundException( argumentCollection=arguments );
		}

		entry.populate( rc.entry ).save();
		entry.getMemento()[ "id" ] = entry.getId();
		prc.response.setData( expandEntry( entry.getMemento() ) );
	}

	// ( DELETE ) /api/v1/logs/suppress/:field/:id
	function suppress( event, rc, prc ){
		announceInterception( "ensureStacheboxMappings" );
		if( rc.field == 'signature' ){
			rc.field = "stachebox.signature";
		}

		var updateResult = getInstance( "Client@cbelasticsearch" )
			.updateByQuery(
				getInstance( "SearchBuilder@cbElasticsearch" )
						.new( variables.moduleSettings.beatsIndexPattern )
						.filterTerm(
							rc.field,
							rc.id
						),
				{
					"lang" : "painless",
					"source" : "if( ctx._source.stachebox == null ) ctx._source.stachebox = new HashMap(); ctx._source.stachebox.isSuppressed = true"
				},
				true
			);
		if( !updateResult.failures.len() ){
			prc.response.setStatusCode( status.NO_CONTENT );
		} else {
			prc.response.setError( true )
						.setMessages(
							updateResult.failures
						)
						.setStatusCode( STATUS.INTERNAL_ERROR );
		}

	}

	// ( DELETE ) /api/v1/logs/:id
	function delete( event, rc, prc ) secured="Stachebox:Administrator"{
		var entry = getInstance( "SearchBuilder@cbElasticsearch" )
							.new( variables.moduleSettings.beatsIndexPattern )
							.term( "_id", rc.id )
							.setMaxRows( 1 )
							.execute()
							.getHits()
							.reduce( function( acc, doc ){
								return doc;
							} );

		if( isNull( entry ) ){
			return onEntityNotFoundException( argumentCollection=arguments );
		}

		entry.delete();

		prc.response.setStatusCode( STATUS.NO_CONTENT );
	}

	function expandEntry( required struct entry ){
		arguments.entry.keyArray().each(
			function( key ){
				if( !isNull( entry[ key ] ) && isSimpleValue( entry[ key ] ) && isJSON( entry[ key ] ) ){
					entry[ key ] = deserializeJSON( entry[ key ] );
				}
			}
		);

		return arguments.entry;
	}

}
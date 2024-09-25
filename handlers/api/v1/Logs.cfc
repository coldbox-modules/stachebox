component extends="BaseAPIHandler" secured="StacheboxUser,StacheboxLog"{

	property name="moduleSettings" inject="coldbox:moduleSettings:stachebox";

	// ( GET ) /api/v1/logs
	function index( event, rc, prc ){

		var searchResult = getInstance( "LogSearchService@stachebox" ).search( rc, event.getValue( "includeAggregations", false ) );
		searchResult.results = searchResult.results.map( function( item ){ return expandEntry( item ); } );

		prc.response.setData( searchResult );

	}

	// ( GET ) /api/v1/logs/:id
	function show( event, rc, prc ){

		var entry = getInstance( "SearchBuilder@cbElasticsearch" )
							.new( variables.moduleSettings.logIndexPattern )
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
												.new( variables.moduleSettings.logIndexPattern )
												.term( "stachebox.signature", entryMemento.stachebox.signature )
												.count()
											: 1;

		prc.response.setData(
			expandEntry( entry.getMemento() )
		);

	}

	// ( POST ) /api/v1/logs
	function create( event, rc, prc ){
		runEvent( "logstash:API.create" );
	}


	// ( PUT||PATCH ) /api/v1/logs/:id
	function update( event, rc, prc ){
		// we cannot use `get()` because we are searching across multiple indices
		var entry = getInstance( "SearchBuilder@cbElasticsearch" )
							.new( variables.moduleSettings.logIndexPattern )
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

		entry.populate( rc ).save();
		entry.getMemento()[ "id" ] = entry.getId();
		prc.response.setData( expandEntry( entry.getMemento() ) );
	}

	// ( DELETE ) /api/v1/logs/suppress/:field/:id
	function suppress( event, rc, prc ){
		if( rc.field == 'signature' ){
			rc.field = "stachebox.signature";
		}

		// Update by query will not work on a data stream so we need to run it through the index
		var searchBuilder = getInstance( "SearchBuilder@cbElasticsearch" )
							.new( ".ds-" & variables.moduleSettings.logIndexPattern )
							.filterTerm(
								rc.field,
								rc.id
							);
		if( rc.keyExists( "environment" ) && len( rc.environment ) ){
			searchBuilder.filterTerm(
				"labels.environment",
				rc.environment
			);
		}

		var updateResult = getInstance( "Client@cbelasticsearch" )
			.updateByQuery(
				searchBuilder,
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
	function delete( event, rc, prc ) secured="StacheboxAdministrator"{
		var entry = getInstance( "SearchBuilder@cbElasticsearch" )
							.new( ".ds-" & variables.moduleSettings.logIndexPattern )
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
				if( key == "message" ){
					processHTMLFormattedMessages( entry, key );
				}
			}
		);
		var nested = [ "error", "user" ];
		nested.each( function( path ){
			if( entry.keyExists( path ) ){
				entry[ path ].keyArray().each(
					function( key ){
						if( !isNull( entry[ path ][ key ] ) && isSimpleValue( entry[ path ][ key ] ) && isJSON( entry[ path ][ key ] ) ){
							entry[ path ][ key ] = deserializeJSON( entry[ path ][ key ] );
						}
						if( key == "message" ){
							processHTMLFormattedMessages( entry[ path ], key );
						}
					}
				);
			}
		} );

		if( !arguments.entry.keyExists( "@timestamp" ) && arguments.entry.keyExists( "timestamp" ) ){
			arguments.entry[ "@timestamp" ] = arguments.entry.timestamp;
		}

		return arguments.entry;
	}


	function processHTMLFormattedMessages( required struct entry, string key="message" ){
		return getInstance( "Util@cbelasticsearch" ).processHTMLFormattedMessages( argumentCollection=arguments );
	}

}
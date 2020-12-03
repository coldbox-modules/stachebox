component {

	property name="moduleSettings" inject="coldbox:moduleSettings:stachebox";

	this.timestampFormatter = createObject( "java", "java.text.SimpleDateFormat" ).init( "yyyy-MM-dd'T'HH:mm:ssXXX" );

	function search(
		required struct searchCollection,
		boolean includeAggregations = true
	){
		param searchCollection.index = moduleSettings.logIndexPattern;
		param searchCollection.sortOrder = "timestamp DESC";
		param searchCollection.maxRows = 25;
		param searchCollection.startRow = 0;

		if( searchCollection.keyExists( "page" ) ){
			searchCollection.page = javacast( "int", searchCollection.page );
			searchCollection.startRow =  ( searchCollection.page * searchCollection.maxRows ) - searchCollection.maxRows;
		} else {
			searchCollection.page = arguments.searchCollection.maxRows && arguments.searchCollection.startRow ? ceiling( (  arguments.searchCollection.maxRows / arguments.searchCollection.startRow ) + 1 ) : 1
		}

		var builder = searchBuilder()
						.new( searchCollection.index )
						.setMaxRows( searchCollection.maxRows )
						.setStartRow( searchCollection.startRow )
						.sort( searchCollection.sortOrder );

		applyCommonSearchArgs( builder, arguments.searchCollection );


		if( structIsEmpty( builder.getQuery() ) ){
			builder.setQuery( { "match_all" : {} } );
		}

		if( searchCollection.keyExists( "page" ) ){
			builder.setStartRow( ( searchCollection.page * searchCollection.maxRows ) - searchCollection.maxRows );
		}

		if( arguments.searchCollection.keyExists( "collapse" ) ){
			builder.collapseToField( field=searchCollection.collapse, includeOccurrences=true );
		} else if( arguments.includeAggregations ){
			applyCommonAggregations( builder, arguments.searchCollection );
		}

		var searchResults = builder.execute();

		if( searchCollection.keyExists( "collapse" ) ){
		}

		var results = searchResults.getHits().map(
			function( doc ){
				var docMemento = doc.getMemento();
				docMemento[ "id"] = doc.getId();
				if( searchCollection.keyExists( "collapse" ) ){
					var occurrences = searchResults.getCollapsedOccurrences();
					var nestedPath = docMemento;
					var fieldValue = listToArray( searchCollection.collapse, "." ).reduce( function( result ,path ){
						if( nestedPath.keyExists( path ) && isSimpleValue( nestedPath[ path ] ) ){
							result = nestedPath[ path ];
						} else if( nestedPath.keyExists( path ) ){
							nestedPath = nestedPath[ path ];
						}
						return result;
					}, '' );
					docMemento[ "occurrences" ] = occurrences.keyExists( fieldValue ) ? occurrences[ fieldValue ] : 1;
				}
				return docMemento;
			} );

		var recordCount = arguments.searchCollection.keyExists( "collapse" ) ? searchResults.getCollapsedCount() : searchResults.getHitCount();

		return {
				"pagination" : {
					"total" : recordCount,
					"page" : searchCollection.page,
					"pages" : arguments.searchCollection.maxRows ? ceiling( recordCount / arguments.searchCollection.maxRows ) : 0,
					"startRow" : builder.getStartRow(),
					"maxRows" : javacast( "int", arguments.searchCollection.maxrows )
				},
				"debug" : searchResults.getCollapsedOccurrences(),
				"results" : results,
				"aggregations" : !arguments.searchCollection.keyExists( "collapse" ) && arguments.includeAggregations && !isNull( searchResults.getAggregations() )
									? searchResults.getAggregations().reduce( function( result, key, value ){
										result[ key ] = parseAggregationData( value );
										return result;
									}, {} )
									: {}
		};

	}

	function parseAggregationData( required struct aggData ){

		return aggData.buckets.reduce( function( acc, val ){
			acc[ val.key ] = {
				"count" : val.doc_count
			};
			if( val.keyArray().len() > 2 ){
				val.keyArray().filter( function( k ){ return ![ "key", "doc_count" ].contains( arguments.k );} )
								.each( function( k ){
									acc[ val.key ][ arguments.k ] = parseAggregationData( val[ arguments.k ] )
								} );
			}
			return acc;
		}, {} )

	}


	function applyCommonAggregations( required SearchBuilder builder, required struct searchCollection ){
		builder.setAggregations(
            {
				"types" : {
					"terms" : {
                        "field" : "type",
                        "size" : 20000,
                        "order" : { "_key" : "asc" }
					}
				},
				"applications" : {
					"terms" : {
                        "field" : "application",
                        "size" : 20000,
                        "order" : { "_key" : "asc" }
					},
					"aggs" : {
						"releases" : {
							"terms" : {
								"field" : "release",
								"size" : 500
							}

						},
						"groups" : {
							"terms" : {
								"field" : "stachebox.signature",
								"size" : 500
							}
						}
					}
				}
            }
        );
	}

	function applyGroupedAggregations( required searchBuilder builder, required struct searchCollection ){

		var groupAggregations = {
			"groupedResults": {
				"terms": {
					"field": "#searchCollection.collapse#"
				},
				"aggs": {
					"limitResults": {
						"bucket_sort": {
							"sort": [
								{
									"last_occurrence_time": {
										"order": "desc"
									}
								}
							],
							"size": searchCollection.maxRows,
							"from": searchCollection.startRow
						}
					},
					"last_occurrence_time": {
						"max": {"field": "timestamp"}
					},
					"last_ocurrence": {
						"top_hits": {
							"sort": builder.getSorting(),
							"size": 1
						}
					}
				}
			}
		};

		builder.setAggregations( groupAggregations );
	}

	function applyCommonSearchArgs( required SearchBuilder builder, required struct searchCollection ){

		if( arguments.searchCollection.keyExists( "query" ) ){
			arguments.searchCollection.setQuery( arguments.searchCollection.query );
		} else {

			if( !searchCollection.keyExists( "stachebox.isSuppressed" ) ){
				searchCollection[ "stachebox.isSuppressed" ] = false;
			}

			if( structKeyExists( searchCollection, "search" ) ){
				applyDynamicSearchArgs( builder, searchCollection );
			}

			var termFilters = [  "type", "application", "release", "level", "category", "appendername", "event.name", "route", "routed_url", "layout", "module", "view", "environment", "stachebox.signature", "stachebox.isSuppressed" ];

			termFilters.each( function( term ){
				if( searchCollection.keyExists( term ) && len( searchCollection[ term ] ) ){
					builder.filterTerm( term, searchCollection[ term ] )
				}
			} );

			if( searchCollection.keyExists( "minDate" ) && len( searchCollection.minDate ) ){

				param searchCollection.maxDate = now();
				searchCollection.minDate = parseDateTime( searchCollection.minDate );
				seaerchCollection.maxDate = parseDateTime( searchCollection.maxDate );

				search.dateMatch(
                    name = "timestamp",
                    start = variables.timestampFormatter.format( searchCollection.minDate ),
                    end = variables.timestampFormatter.format( searchCollection.maxDate ),
                    boost = 20
				);

			} else if( searchCollection.keyExists( "maxDate" ) && len( searchCollection.maxDate ) ){
				searchCollection.maxDate = parseDateTime( searchCollection.maxDate );
				search.dateMatch(
                    name = "timestamp",
                    end = variables.timestampFormatter.format( searchCollection.maxDate ),
                    boost = 20
				);
			}
		}

	}

	function applyDynamicSearchArgs( required SearchBuilder builder, required struct searchCollection ){
		if( !searchCollection.keyExists( "search" ) ) return;
		var searchString = ""
		listToArray( searchCollection.search, "+" )
							.each( function( item ){
								var scopedArgs = listToArray( item, ":" );
								if( len( scopedArgs ) == 1 ){
									searchString &= " " & item;
								} else {
									searchCollection[ scopedArgs[ 1 ] ] = scopedArgs[ 2 ]
								}
							} );
		// Note the `^` boosts the field by the following multiplier
		var matchText = [
			"message^10",
			"stacktrace",
			"frames"
		];

		search.multiMatch(
			matchText,
			trim( searchString ),
			20.00
		);


	}


	function searchBuilder() provider="SearchBuilder@cbelasticsearch"{}

}
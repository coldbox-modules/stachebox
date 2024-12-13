component {

	property name="moduleSettings" inject="coldbox:moduleSettings:stachebox";

	variables.timestampFormatter = createObject( "java", "java.text.SimpleDateFormat" ).init( "yyyy-MM-dd'T'HH:mm:ssXXX" );

	function search(
		required struct searchCollection,
		boolean includeAggregations = true
	){
		param searchCollection.index = moduleSettings.logIndexPattern;
		param searchCollection.sortOrder = "@timestamp DESC";
		param searchCollection.maxRows = 25;
		param searchCollection.startRow = 0;
		param searchCollection.tzOffset = numberFormat( getTimezoneInfo().utcHourOffset, "00" ) & ":00";
		var isOccurrenceSort = searchCollection.keyExists( "sortOrder" ) && listFirst( searchCollection.sortOrder, " " ) == "occurrences";
		if( searchCollection.tzOffset == "00:00" ){
			searchCollection.tzOffset = "Z";
		}

		if( searchCollection.keyExists( "page" ) ){
			searchCollection.page = javacast( "int", searchCollection.page );
			searchCollection.startRow =  ( searchCollection.page * searchCollection.maxRows ) - searchCollection.maxRows;
		} else {
			searchCollection.page = arguments.searchCollection.maxRows && arguments.searchCollection.startRow ? ceiling( (  arguments.searchCollection.maxRows / arguments.searchCollection.startRow ) + 1 ) : 1
		}

		var builder = searchBuilder()
						.new( searchCollection.index )
						.setMaxRows( searchCollection.maxRows )
						.setStartRow( searchCollection.startRow );

		if( searchCollection.keyExists( "sortOrder" ) ){
			if( !isOccurrenceSort ){
				builder.sort( searchCollection.sortOrder );
			}
		}

		applyCommonSearchArgs( builder, arguments.searchCollection );

		if( structIsEmpty( builder.getQuery() ) ){
			builder.setQuery( { "match_all" : {} } );
		}

		if( searchCollection.keyExists( "page" ) ){
			builder.setStartRow( ( searchCollection.page * searchCollection.maxRows ) - searchCollection.maxRows );
		}

		if( arguments.searchCollection.keyExists( "collapse" ) ){
			builder.collapseToField( field=searchCollection.collapse, includeOccurrences=true );
		}

		if( arguments.includeAggregations ){
			applyCommonAggregations( builder, arguments.searchCollection );
		}

		var searchResults = builder.execute();

		var results = searchResults.getHits().map(
			function( doc ){
				var docMemento = doc.getMemento();
				docMemento[ "id"] = doc.getId();
				docMemento[ "@search" ] = {
					"score" : doc.getScore()
				};
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

		// TODO: find a way to do this with a script sort on the query as this only sorts the page of results retrieved
		if( isOccurrenceSort ){
			if( findNoCase( "ASC", searchCollection.sortOrder ) ){
				results = results.sort( ( a, b ) => compare( a.occurrences, b.occurrences ) );
			} else {
				results = results.sort( ( a, b ) => compare( b.occurrences, a.occurrences) );
			}
		}

		var recordCount = arguments.searchCollection.keyExists( "collapse" ) ? searchResults.getCollapsedCount() : searchResults.getHitCount();

		return {
				"pagination" : {
					"total" : recordCount,
					"page" : searchCollection.page,
					"pages" : arguments.searchCollection.maxRows ? ceiling( recordCount / arguments.searchCollection.maxRows ) : 0,
					"startRow" : builder.getFrom(),
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

	function parseAggregationData( required any aggData ){

		if( isSimpleValue( aggData ) ) return aggData;

		return aggData.buckets.reduce( function( acc, val ){

			// if( right( val.key, 12 ) === "_occurrences" ){}
			var keyName = val.keyExists( "key_as_string" ) ? val.key_as_string : val.key;
			acc[ keyName ] = {
				"count" : val.doc_count
			};
			if( val.keyArray().len() > 2 ){
				var excludeKeys = [ "key", "key_as_string", "doc_count" ];
				val.keyArray().filter( function( k ){ return !excludeKeys.contains( arguments.k );} )
								.each( function( k ){
									acc[ val.key ][ arguments.k ] = parseAggregationData( val[ arguments.k ] );
								} );
			}
			return acc;
		}, {} )

	}


	function applyCommonAggregations( required SearchBuilder builder, required struct searchCollection ){
		var applicationAggs = {
			"terms" : {
				"field" : "labels.application",
				"size" : 20000,
				"order" : { "_key" : "asc" }
			},
			"aggs" : {
				"daily_occurrences": {
					"date_histogram": {
						"min_doc_count": 0,
						"field": "@timestamp",
						"calendar_interval": "day",
						"time_zone": searchCollection.tzOffset
					}
				},
				"hourly_occurrences": {
					"date_histogram": {
						"min_doc_count": 0,
						"field": "@timestamp",
						"calendar_interval": "hour",
						"time_zone": searchCollection.tzOffset
					}
				},
				"releases" : {
					"terms" : {
						"field" : "package.version",
						"size" : 500
					}
				},
				"groups" : {
					"terms" : {
						"field" : "stachebox.signature",
						"size" : 500
					}
				},
				"levels" : {
					"terms" : {
						"field" : "log.level",
						"size" : 500
					}
				}
			}
		};
		builder.setAggregations(
            {
				"types" : {
					"terms" : {
                        "field" : "error.type",
                        "size" : 20000,
                        "order" : { "_key" : "asc" }
					}
				},
				"applications" : applicationAggs,
				"environments" : {
					"terms" : {
                        "field" : "labels.environment",
                        "size" : 20000,
                        "order" : { "_key" : "asc" }
					},
					"aggs" : {
						"applications" : applicationAggs
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
						"max": {"field": "@timestamp"}
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

			if( structKeyExists( searchCollection, "search" ) && len( searchCollection.search ) ){
				applyDynamicSearchArgs( builder, searchCollection );
			}

			if( searchCollection.keyExists( "terms" ) ){
				searchCollection.terms.each( function( term ){
					var key = term.key;
					var value = term.value;
					var operator = term.operator ?: "must";

					switch( operator ){
						case "wildcard" : {
							builder.wildCard(
								key,
								value
							);
							break;
						}
						case "lt":
						case "gt":
						case "lte":
						case "gte":{
							var matchProperties = {
								"#operator#" : value
							}
							builder.match(
								key,
								matchProperties,
								"range"
							);
							break;

						}
						default : {
							if( isArray( value ) ){
								builder.filterTerms(
									key,
									value,
									operator
								);
							} else {
								builder.filterTerm(
									key,
									value,
									operator
								);
							}
						}
					}
				} );
			} else {
				var termFilters = [  "error.type", "labels.application", "package.version", "log.level", "error.level", "log.category", "log.logger", "event.name", "event.route", "event.url", "event.layout", "module", "view", "labels.environment", "stachebox.signature", "stachebox.isSuppressed", "trace.id", "span.id" ];

				termFilters.each( function( term ){
					if( searchCollection.keyExists( term ) && ( ( isArray( searchCollection[ term ] ) && searchCollection[ term ].len() ) || len( searchCollection[ term ] ) ) ){
						if( isArray( searchCollection[ term ] ) ){
							builder.filterTerms(
								term,
								searchCollection[ term ]
							);
						} else {
							builder.filterTerm( term, searchCollection[ term ] );
						}
					}
				} );
			}

			if( searchCollection.keyExists( "minDate" ) && len( searchCollection.minDate ) ){

				param searchCollection.maxDate = now();
				searchCollection.minDate = parseDateTime( searchCollection.minDate );
				searchCollection.maxDate = parseDateTime( searchCollection.maxDate );

				builder.dateMatch(
                    name = "@timestamp",
                    start = variables.timestampFormatter.format( searchCollection.minDate ),
                    end = variables.timestampFormatter.format( searchCollection.maxDate ),
                    boost = 20
				);

			} else if( searchCollection.keyExists( "maxDate" ) && len( searchCollection.maxDate ) ){
				searchCollection.maxDate = parseDateTime( searchCollection.maxDate );
				builder.dateMatch(
                    name = "@timestamp",
                    end = variables.timestampFormatter.format( searchCollection.maxDate ),
                    boost = 20
				);
			}

			if( searchCollection.keyExists( "exclude" ) ){
				builder.filterTerms(
					"_id",
					searchCollection.exclude,
					"must_not"
				);
			}
		}

	}

	function applyDynamicSearchArgs( required SearchBuilder builder, required struct searchCollection ){
		if( !searchCollection.keyExists( "search" ) || !len( searchCollection.search ) ) return;
		// Note the `^` boosts the field by the following multiplier
		var looseMatches = [
			"message^5",
			"error.stack_trace",
			"error.frames",
			"event.url.path",
			"error.extrainfo^3",
			"error.stack_trace.text^2"
		];
		var phraseMatches = [
			"message^5",
			"error.extrainfo^2"
		];
		listToArray( searchCollection.search, "+" )
							.each( function( item ){
								var matchType = "match";
								var scopedArgs = listToArray( item, ":" );
								if( scopedArgs.len() > 1 ){
									searchCollection[ scopedArgs[ 1 ] ] = scopedArgs[ 2 ]
								} else {
									if( left( item , 1 ) == '"' ){
										matchType = "phrase";
									}
									builder.match(
										name=matchType == "match" ? looseMatches : phraseMatches,
										value=item,
										boost=1,
										matchType=matchType,
										type= matchType == "match" ? "best_fields" : "phrase"
									)
								}
							} );

	}


	function searchBuilder() provider="SearchBuilder@cbelasticsearch"{}

}
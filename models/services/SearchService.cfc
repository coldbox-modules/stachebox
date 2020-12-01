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

		var builder = searchBuilder()
						.new( searchCollection.index )
						.setMaxRows( searchCollection.maxRows )
						.setStartRow( searchCollection.startRow )
						.sort( searchCollection.sortOrder );

		applyCommonSearchArgs( builder, arguments.searchCollection );
		if( arguments.searchCollection.keyExists( "aggregationGroup" ) ){
			builder.setMaxRows( 0 );
			applyGroupedAggregations( builder, arguments.searchCollection );
		} else if( arguments.includeAggregations ){
			applyCommonAggregations( builder, arguments.searchCollection );
		}


		if( structIsEmpty( builder.getQuery() ) ){
			builder.setQuery( { "match_all" : {} } );
		}

		var searchResults = builder.execute();

		if( arguments.searchCollection.keyExists( "aggregationGroup" ) ){
			var results = searchResults.getAggregations().groupedResults.buckets.reduce( function( acc, bucket ){
				var last = bucket.last_ocurrence.hits.hits[ 1 ]._source;
				last[ "id" ] = bucket.last_ocurrence.hits.hits[ 1 ]._id;
				last[ "occurrences" ] = bucket.last_ocurrence.hits.total.value;
				acc.append( last );
				return acc;
			}, [] );
		} else {
			var results = searchResults.getHits().map( function( doc ){ doc.getMemento()[ "id"] = doc.getId(); return doc.getMemento(); } );
		}


		return {
				"total" : searchResults.getHitCount(),
				"start" : arguments.searchCollection.startRow,
				"limit" : arguments.searchCollection.maxrows,
				"results" : results,
				"aggregations" : !arguments.searchCollection.keyExists( "aggregationGroup" ) && arguments.includeAggregations && !isNull( searchResults.getAggregations() )
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
					"field": "#searchCollection.aggregationGroup#"
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


	function searchBuilder() provider="SearchBuilder@cbelasticsearch"{}

}
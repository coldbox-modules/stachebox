component singleton {

	property name="moduleSettings" inject="coldbox:moduleSettings:stachebox";
	property name="searchClient" inject="Client@cbelasticsearch";

	function newSearchBuilder() provider="SearchBuilder@cbelasticsearch"{}

	/**
	 * Retreives all configured settings
	 **/
	function getAllSettings(){

		var searchBuilder = newSearchBuilder().new( moduleSettings.settingsIndex )
									.setQuery( { "match_all" : {} } );
		searchBuilder.setMaxRows( searchBuilder.count() );

		return searchBuilder.execute().getHits().map( function( entry ){
			return expandDoc( entry ).getMemento();
		} );

	}

	/**
	 * Retreives a setting by name
	 *
	 * @name
	 */
	function getByName( required string name ){
		return newSearchBuilder()
				.new( moduleSettings.settingsIndex )
				.setQuery( { "term" : { "name" : arguments.name } } )
				.execute().getHits().reduce(
					( acc, item ) => {
						if( isNull( acc ) ){
							acc = expandDoc( item ).getMemento();
						}
						return acc;
					}
					,javacast( "null", 0 )
				);
	}

	function getById( required string id ){
		var setting = getInstance( "Client@cbelasticsearch" ).get( arguments.id, moduleSettings.settingsIndex );
		if( isNull( setting ) ){
			return;
		} else {
			return expandDoc( setting ).getMemento();
		}
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
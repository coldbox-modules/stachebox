const globalFilters = {
    truncate : function ( text, stop, clamp ) {
        return text.slice( 0, stop ) + ( stop < text.length ? clamp || "..." : "" );
    },
    datasetName : function ( text ) {
		return text.split( '.' ).map( segment => segment.toTitleCase() ).join( ' ' )
	}

}
export default globalFilters;
/**
* Formats a raw JSON string
* @jsonData     The raw JSON string to format
* @return       string
**/
export const formatJSONRaw = function( jsonData ){
    if( !jsonData.length ){ return ''; }
    try{
        return JSON.stringify( JSON.parse( jsonData ), null, 4 ).replace(/\\\\/g, "\\");
    }
    catch(e){
        return jsonData;
    }
}
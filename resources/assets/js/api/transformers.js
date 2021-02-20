import Axios from "axios";

if( typeof( JSONPrefix ) === "undefined" ){
	var JSONPrefix = '//';
}

let transformers = {
	transformResponse: [
		function (data) {
			if( typeof( data ) === "string" && data.trim().substring( 0, 2 ) === JSONPrefix ){
				return data.trim().substring( 2, data.length );
			} else {
				return data;
			}
		},
		...Axios.defaults.transformResponse
	]
};

export default transformers;
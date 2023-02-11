import Axios from "axios";

const urlRoot = "/stachebox/api/v1";

const defaultAPI = Axios.create({
	baseURL: urlRoot,
	headers : {
	  "Content-Type" : "application/json"
	},
	...require( "./transformers.js" ).default
});

export const finalAPI = {
	apiInstance : defaultAPI,
	newToken : ( token ) => defaultAPI.post( '/tokens', {} ,{ headers : { 'Authorization' : 'Bearer ' + token } } )
};

export default finalAPI;
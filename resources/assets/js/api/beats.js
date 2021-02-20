import Axios from "axios";

const urlRoot = "/stachebox/api/v1/beats";

const defaultAPI = Axios.create({
	baseURL: urlRoot,
	headers : {
	  "Content-Type" : "application/json"
	},
	...require( "./transformers.js" ).default
});

export const finalAPI = {
	apiInstance : defaultAPI,
	list :( params, token ) => defaultAPI.get( '', { params : params, headers : { 'Authorization' : 'Bearer ' + token } } ),
	fetch :( id, params, token ) => defaultAPI.get( '/' + id, { params : params, headers : { 'Authorization' : 'Bearer ' + token } } ),
	update : ( params, token ) => defaultAPI.put( '/' + params.id, JSON.stringify( params ), { headers : { 'Authorization' : 'Bearer ' + token } }  ),
	suppress : ( field, id , token ) => defaultAPI.delete( `/suppress/${field}/${id}`,  { headers : { 'Authorization' : 'Bearer ' + token } }  ),
	patch : ( params, token ) => defaultAPI.patch( '/' + params.id,  JSON.stringify( params ), { headers : { 'Authorization' : 'Bearer ' + token } }  ),
	delete : ( params, token ) => defaultAPI.put( '/' + id  ),
};

export default finalAPI;
import Axios from "axios";

const urlRoot = "/stachebox/api/v1/settings";

const defaultAPI = Axios.create({
	baseURL: urlRoot,
	headers : {
	  "Content-Type" : "application/json"
	}
});

export const finalAPI = {
	apiInstance : defaultAPI,
	fetch :( id, params, token ) => defaultAPI.get( '/' + id, { params : params, headers : { 'Authorization' : 'Bearer ' + token } } ),
	list :( params, token ) => defaultAPI.get( '', { params : params, headers : { 'Authorization' : 'Bearer ' + token } } ),
	update : ( params, token ) => defaultAPI.put( '/' + params.id,  JSON.stringify( params ) , { headers : { 'Authorization' : 'Bearer ' + token } }  ),
	patch : ( params, token ) => defaultAPI.patch( '/' + params.id, JSON.stringify( params ),  { headers : { 'Authorization' : 'Bearer ' + token } }  ),
	delete : ( params, token ) => defaultAPI.put( '/' + id  ),
};

export default finalAPI;
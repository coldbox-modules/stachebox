import Axios from "axios";

const urlRoot = "/stachebox/api/v1/authentication";

const defaultAPI = Axios.create({
	baseURL: urlRoot,
	headers : {
	  "Content-Type" : "application/json"
	}
});

export const finalAPI = {
	apiInstance : defaultAPI,
	check: () => defaultAPI( { method : "HEAD" } ),
	login: (params) => defaultAPI({ method: 'POST', data: JSON.stringify(params) }),
	logout: ( params ) => defaultAPI( {  method: 'DELETE', data : JSON.stringify( params ) } )
};

export default finalAPI;
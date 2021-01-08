import Axios from "axios";
import store from "@/store/index";

const urlRoot = "/stachebox/api/v1/authentication";

const defaultAPI = Axios.create({
	baseURL: urlRoot,
	headers : {
	  "Content-Type" : "application/json"
	},
	...require( "./transformers.js" ).default
});

export const finalAPI = {
	apiInstance : defaultAPI,
	check: () => defaultAPI( { method : "HEAD" } ),
	login: (params) => defaultAPI({ method: 'POST', data: JSON.stringify(params) }),
	logout: ( params ) => defaultAPI( {  method: 'DELETE', data : JSON.stringify( params ), headers : { 'Authorization' : 'Bearer ' + store.state.authToken } } )
};

export default finalAPI;
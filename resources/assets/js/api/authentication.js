import Axios from "axios";
import store from "@/store/index";

const urlRoot = window.globalData.stachebox.apiBaseHref + "/api/v1/authentication";

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
	logout: ( params ) => defaultAPI( {  method: 'DELETE', data : JSON.stringify( params ), headers : { 'Authorization' : 'Bearer ' + store.state.authToken } } ),
	requestReset: ( params ) => defaultAPI.post( '/reset', JSON.stringify( params ) ),
	completeReset: ( params ) => defaultAPI.put( '/reset', JSON.stringify( params ) )

};

export default finalAPI;
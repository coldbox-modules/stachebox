import Vue from "vue";
import Vuex from "vuex";
import authAPI from "../api/authentication";
import usersAPI from "../api/users";
import logsAPI from "../api/logs";

Vue.use(Vuex);

export default new Vuex.Store({
	state: {
		authId: null,
		authToken: null,
		authUser : null,
		navAggregations : null
	},
	getters:{
		hasPermission: ( state,getters ) => ( permission ) =>{
			return state.authUser && state.authUser.isAdministrator;
		}
	},
	mutations: {
		processLoginSuccess: (state, response) => {
			state.authId = response.headers["x-auth-user"];
			state.authToken = response.headers["x-auth-token"];
		},
		updateState : ( state, key, value ) => {
			state[ key ] = value;
		}
	},
	actions: {
		authenticate : (context, payload) => {
			return new Promise((resolve, reject) => {
				authAPI
					.login( payload )
					.then( response => {
						context.commit( "processLoginSuccess", response );
						context.dispatch( "fetchAuthUser" );
						resolve( response );
					} )
					.catch( (response) => { reject( response ) } );
			});
		},
		logout : ( context ) => {
			return new Promise( ( resolve, reject ) => {
				authAPI.logout()
					.finally( ( response ) => {
						context.state.authId = null;
						context.state.authToken = null;
						context.state.authuser = null;
						resolve( response );
					});
			} );
		},
		fetchAuthUser : ( context, params = {} ) => {
			return new Promise( ( resolve, reject ) => {
				// if( !context.state.authId ) reject();
				usersAPI.fetch( context.state.authId, params, context.state.authToken )
						.then( ( response ) => {
							context.state.authUser = response.data;
							resolve( response )
						}  )
						.catch( ( response ) => {
							reject( response );
						} )
			} );
		},
		fetchLogs : ( context, params = {} ) => {
			return logsAPI.list( params, context.state.authToken )
		},
		fetchLogEntry : ( context, id, params= {} ) => {
			return logsAPI.fetch( id, params, context.state.authToken )
		},
		fetchNavAggregations : ( context ) => {
			context.dispatch( "fetchLogs", { maxrows : 0 } )
					.then( ( result ) => {
						context.state.navAggregations = result.data.aggregations;
						context.state.navAggregations.logCount = result.data.pagination.total;
					} );
		},
		suppressEntry : ( context, { field, id } ) => {
			return logsAPI.suppress( field, id, context.state.authToken );
		}
	}
});

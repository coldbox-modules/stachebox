import Vue from "vue";
import Vuex from "vuex";
import authAPI from "../api/authentication";
import usersAPI from "../api/users";

Vue.use(Vuex);

export default new Vuex.Store({
	state: {
		authId: null,
		authToken: null,
		authUser : null
	},
	mutations: {
		processLoginSuccess: (state, response) => {
			state.authId = response.headers["x-auth-user"];
			state.authToken = response.headers["x-auth-token"];
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
		}
	}
});

import dayjs from "dayjs";
import timezone from "dayjs/plugin/timezone";
import utc from "dayjs/plugin/utc";
import VueJwtDecode from "vue-jwt-decode";
import { createStore } from "vuex";
import authAPI from "../api/authentication";
import beatsAPI from "../api/beats";
import logsAPI from "../api/logs";
import usersAPI from "../api/users";
dayjs.extend( utc );
dayjs.extend( timezone );
dayjs.tz.setDefault( dayjs.tz.guess() );

export default createStore({
	state: {
		authId: null,
		authToken: null,
		authUser : null,
		navAggregations : null,
		beatsEnabled : true,
		globals : window ? window.globalData : {}
	},
	getters:{
		hasPermission: ( state,getters ) => ( permission ) =>{
			return state.authUser && state.authUser.isAdministrator;
		},
		orderedApplications : ( state, getters ) =>  state.navAggregations && state.navAggregations.applications
														? Object.keys( state.navAggregations.applications ).sort( ( a, b ) => a.localeCompare( b ) )
														: null
	},
	mutations: {
		processLoginSuccess: (state, response) => {
			state.authId = response.headers["x-auth-user"];
			state.authToken = response.headers["x-auth-token"];
		},
		updateState : ( state, payload ) => {
			state[ payload.key ] = payload.value;
		},
		removeFromState : ( state, key ) => {
			delete state[ key ];
		},
		updateGlobal : ( state, payload ) => {
			state.globals.stachebox[ payload.key ] = payload.value;
		},
		setBeatsEnabled : ( state, value ) => {
			state.beatsEnabled = value;
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
			if( !context.state.globals.stachebox.internalSecurity ) {
				return new Promise( ( resolve, reject ) => {
					let userRecord = VueJwtDecode.decode( context.state.authToken );
					if( userRecord.scope.indexOf( "Admin" ) > -1 ){
						userRecord.isAdministrator = true;
					}
					context.state.authUser = userRecord;
					resolve( context.state.authUser );
				} );
			}
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
		fetchBeats : ( context, params = {} ) => {
			let beatsParams = Object.assign( {}, params );
			delete beatsParams.collapse;
			return beatsAPI.list( beatsParams, context.state.authToken )
		},
		fetchBeatsEntry : ( context, id, params= {} ) => {
			return beatsAPI.fetch( id, params, context.state.authToken )
		},
		fetchLogEntry : ( context, id, params= {} ) => {
			return logsAPI.fetch( id, params, context.state.authToken )
		},
		fetchNavAggregations : ( context ) => {
			context.dispatch( "fetchLogs", { maxrows : 0, includeAggregations: true, minDate: dayjs( new Date() ).subtract( "14", "days" ).toISOString(), tzOffset : dayjs().format( "Z" ) } )
					.then( ( result ) => {
						context.state.navAggregations = result.data.aggregations;
						context.state.navAggregations.logCount = result.data.pagination.total;
						// TODO: Move log aggregations to separate key so that beats can dispatch independently
						context.dispatch( "fetchBeats", { maxrows : 0, includeAggregations : true } )
								.then( ( result ) => {
									context.state.navAggregations.beatsCount = result.data.pagination.total;
									context.state.navAggregations.beatsAggregations = result.data.aggregations;
								} );
					} );
		},
		fetchMappings( params ){
			return logsAPI.mappings( params, context.state.authToken );
		},
		suppressEntry : ( context, { field, id, environment } ) => {
			return logsAPI.suppress( field, id, context.state.authToken, environment );
		}
	}
});

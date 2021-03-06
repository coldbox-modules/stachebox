import VueRouter from "vue-router";
import Vue from "vue";
import auth from "../api/authentication";

Vue.use( VueRouter );

import Dashboard from "@/views/Dashboard.vue";
import Login from "@/views/Login.vue";
import Blank from "@/views/Blank.vue";
import NotFound from "@/views/NotFound.vue";
import LogEntry from "@/views/LogEntry.vue";
import BeatsEntry from "@/views/BeatsEntry.vue";
import ApplicationLogs from "@/views/ApplicationLogs.vue";
import DatasetLogs from "@/views/DatasetLogs.vue";
import BeatsLogs from "@/views/BeatsLogs.vue";
import LogSearch from "@/views/LogSearch.vue";
import Settings from "@/views/Settings.vue";
import UserDirectory from "@/views/UserDirectory.vue";
import UserForm from "@/views/UserForm.vue";

import store from "@/store/index";

const routes = [
  {
    path: "/",
    name: "Landing",
    component: Dashboard
  },
  {
    path: "/login",
    name: "Login",
    component: Login,
    meta: { layout: "empty" },
  },
  {
    path: "/dashboard",
    name: "Dashboard",
    component: Dashboard,
  },
  {
    path: "/logs/entry/:id",
    name: "LogEntry",
    component: LogEntry,
  },
  {
    path: "/beats/entry/:id",
    name: "BeatsEntry",
    component: BeatsEntry,
  },
  {
    path: "/logs/application/:id",
    name: "ApplicationLogs",
    component: ApplicationLogs,
  },
  {
    path: "/logs/dataset/:id",
    name: "DatasetLogs",
    component: DatasetLogs,
  },
  {
    path: "/logs/type/:id",
    name: "BeatsLogs",
    component: BeatsLogs,
  },
  {
    path: "/logs/search",
    name: "LogSearch",
    component: LogSearch,
  },
  {
    path: "/settings",
    name: "Settings",
	component: Settings,
	meta : {
		permission : "Administer:Settings"
	}
  },
  {
    path: "/directory",
    name: "Directory",
    component: UserDirectory,
  },
  {
    path: "/users/edit/:id",
    name: "EditUser",
	component: UserForm,
	meta : {
		permission : "Edit:User"
	}
  },
  {
    path: "/users/create",
    name: "NewUser",
	component: UserForm,
	meta : {
		permission : "Administer:Users"
	}
  },
  {
    path: "/profile/:id",
    name: "Profile",
    component: UserForm,
	meta : {
		permission : "Edit:User"
	}
  },
  { path: '*', component: NotFound }
];

const router = new VueRouter({
  mode: 'history',
  base: store.state.globals && store.state.globals.stachebox.isStandalone ? '' : '/stachebox',
  routes
})

router.beforeEach((to, from, next) => {

	if (to.name !== 'Login') {
		auth.check()
			.then( ( response ) => {
				store.commit( "processLoginSuccess", response );
				store.dispatch( "fetchAuthUser" ).then(
					() => {
						if( !store.state.navAggregations ){
							store.dispatch( "fetchNavAggregations" );
						}
						if( to.meta && to.meta.permission && to.meta.permission == "Edit:User" ){
							if( store.getters.hasPermission( to.meta.permission ) || to.params.id === store.state.authId ){
								next();
							} else {
								next( "/permission-denied" );
							}
						}
						else if( to.meta && to.meta.permission && !store.getters.hasPermission( to.meta.permission ) ){
							next( '/permission-denied' );
						} else {
							next();
						}
					}
				);
			} )
			.catch(() => {
				console.log( store );
				if( store.state.globals.stachebox.internalSecurity ){
					next({ name: "Login" });
				} else {
					window.location.assign( store.state.globals.stachebox.loginURL )
				}
			} );
	} else {
		next()
	}
})

export default router
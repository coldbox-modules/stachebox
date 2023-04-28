import { createRouter, createWebHistory } from "vue-router";
import auth from "../api/authentication";

import Dashboard from "@/views/Dashboard.vue";
import Login from "@/views/Login.vue";
import ForgotPassword from "@/views/ForgotPassword.vue";
import ResetPassword from "@/views/ResetPassword.vue";
import NotFound from "@/views/NotFound.vue";
import LogEntry from "@/views/LogEntry.vue";
import BeatsEntry from "@/views/BeatsEntry.vue";
import ApplicationLogs from "@/views/ApplicationLogs.vue";
import ProjectSnapshot from "@/views/ProjectSnapshot.vue";
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
    meta: { layout: "empty", whitelist : true },
  },
  {
    path: "/login/forgot-password",
    name: "ForgotPassword",
    component: ForgotPassword,
    meta: { layout: "empty", whitelist : true },
  },
  {
    path: "/login/password-reset",
    name: "ResetPassword",
    component: ResetPassword,
    meta: { layout: "empty", whitelist : true },
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
    path: "/projects/:id",
    name: "ProjectSnapshot",
    component: ProjectSnapshot,
  },
  {
    path: "/logs/application/:id/:environment",
    name: "ApplicationEnvironmentLogs",
    component: ApplicationLogs,
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
  { path: "/:catchAll(.*)", component: NotFound }
];

const router = createRouter({
  history : createWebHistory( store.state.globals && store.state.globals.stachebox.isStandalone ? '' : store.state.globals.stachebox.apiBaseHref.replace( store.state.globals.stachebox.sesBaseURL, "/" ) ),
  routes
});

router.beforeEach((to, from, next) => {

	if ( !to.meta || !to.meta.whitelist ) {
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
				if( store.state.globals.stachebox.internalSecurity ){
					if( !to.name || to.name != "Landing" ){
						store.commit( "updateState", { key : "loginReferer", value : to } );
					}
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
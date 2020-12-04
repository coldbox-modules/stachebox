import VueRouter from "vue-router";
import Vue from "vue";
import auth from "../api/authentication";

Vue.use( VueRouter );

import Dashboard from "@/views/Dashboard.vue";
import Login from "@/views/Login.vue";
import Blank from "@/views/Blank.vue";
import NotFound from "@/views/NotFound.vue";
import LogEntry from "@/views/LogEntry.vue";
import ApplicationLogs from "@/views/ApplicationLogs.vue";
import LogSearch from "@/views/LogSearch.vue";
import Settings from "@/views/Settings.vue";

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
    path: "/logs/application/:id",
    name: "ApplicationLogs",
    component: ApplicationLogs,
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
    path: "/profile",
    name: "Profile",
    component: Blank,
  },
  { path: '*', component: NotFound }
];

const router = new VueRouter({
  mode: 'history',
  base: store.state.globalData && store.state.globalData.stachebox.isStandalone ? '' : '/stachebox',
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
						if( to.meta && to.meta.permission && !store.getters.hasPermission( to.meta.permission ) ){
							next( '/permission-denied' );
						} else {
							next();
						}
					}
				);
			} )
			.catch(() => { next({ name: "Login" }); });
	} else {
		next()
	}
})

export default router
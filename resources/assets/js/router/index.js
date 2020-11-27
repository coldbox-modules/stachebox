import VueRouter from "vue-router";
import Vue from "vue";
import auth from "../api/authentication";

Vue.use( VueRouter );

import Dashboard from "@/views/Dashboard.vue";
import Forms from "@/views/Forms.vue";
import Tables from "@/views/Tables.vue";
import UIElements from "@/views/UIElements.vue";
import Login from "@/views/Login.vue";
import Modal from "@/views/Modal.vue";
import Card from "@/views/Card.vue";
import Blank from "@/views/Blank.vue";
import NotFound from "@/views/NotFound.vue";

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
    path: "/forms",
    name: "Forms",
    component: Forms,
  },
  {
    path: "/cards",
    name: "Cards",
    component: Card,
  },
  {
    path: "/tables",
    name: "Tables",
    component: Tables,
  },
  {
    path: "/ui-elements",
    name: "UIElements",
    component: UIElements,
  },
  {
    path: "/directory",
    name: "Directory",
    component: Modal,
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
  base: '/stachebox',
  routes
})

router.beforeEach((to, from, next) => {
	if (to.name !== 'Login') {
		auth.check()
			.then( ( response ) => {
				store.commit( "processLoginSuccess", response );
				store.dispatch( "fetchAuthUser" )
				next();
			} )
			.catch(() => { next({ name: "Login" }); });
	} else {
		next()
	}
})

export default router
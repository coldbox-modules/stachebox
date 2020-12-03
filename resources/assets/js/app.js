import Vue from 'vue';
import App from './App.vue';
import router from './router';
import store from './store';
import VueTailwind from 'vue-tailwind';
import { library } from '@fortawesome/fontawesome-svg-core';
import { fas } from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
library.add( fas );
Vue.component('fa-icon', FontAwesomeIcon)

import Empty from "./layouts/EmptyLayout";
Vue.component("empty-layout", Empty);

import Dashboard from "./layouts/DashboardLayout";
Vue.component("dashboard-layout", Dashboard);

import VTooltip from "v-tooltip";
Vue.use( VTooltip );

// String prototype extensions
import '@/extensions/String';

Vue.config.productionTip = false;

Vue.filter( "truncate", function ( text, stop, clamp ) {
    return text.slice( 0, stop ) + ( stop < text.length ? clamp || "..." : "" );
} );

new Vue({
	router,
	store,
	VueTailwind,
	render: h => h(App)
}).$mount('#app')

import Vue from 'vue';
import App from './App.vue';
import router from './router';
import store from './store';
import VueTailwind from 'vue-tailwind';

import Empty from "./layouts/EmptyLayout";
Vue.component("empty-layout", Empty);

import Dashboard from "./layouts/DashboardLayout";
Vue.component("dashboard-layout", Dashboard);


Vue.config.productionTip = false;

new Vue({
	router,
	store,
	VueTailwind,
	render: h => h(App)
}).$mount('#app')

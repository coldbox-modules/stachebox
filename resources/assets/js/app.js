import EventBus from "@/events/EventBus";
import { library } from '@fortawesome/fontawesome-svg-core';
import { fas } from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { createApp } from "vue";
import { createI18n } from 'vue-i18n';
import App from './App.vue';
import filters from './filters';
import router from './router';
import store from './store';

// String prototype extensions
import '@/extensions/String';

const app = createApp( App );

library.add( fas );

app.component('fa-icon', FontAwesomeIcon);

import Empty from "./layouts/EmptyLayout";
app.component("empty-layout", Empty);

import Dashboard from "./layouts/MainLayout";
app.component("dashboard-layout", Dashboard);

app.config.productionTip = false;

app.config.globalProperties.$filters = filters;

import dayjs from "dayjs";
import localizedFormat from "dayjs/plugin/localizedFormat";
import timezone from "dayjs/plugin/timezone";
import utc from "dayjs/plugin/utc";
dayjs.extend( utc );
dayjs.extend( timezone );
dayjs.extend( localizedFormat );
dayjs.tz.setDefault( dayjs.tz.guess() );

app.config.globalProperties.dayjs = dayjs;

// Global event bus
window.Event = new EventBus();

// require( "./util/make-errors" );

const i18n = createI18n({
    locale: "en_US",
    messages: window.globalData.stachebox.i18nLocales
});

app.use( i18n );
app.use( store );
app.use( router );

import FloatingVue from 'floating-vue';
app.use(
    FloatingVue,
    {
        themes: {
            tooltip: {
                placement : 'bottom'
            },
            "dropdown-info" : {
                $extend: "dropdown"
            },
            "dropdown-success" : {
                $extend: "dropdown"
            },
            "dropdown-warning" : {
                $extend: "dropdown"
            },
            "dropdown-caution" : {
                $extend: "dropdown"
            },
            "dropdown-danger" : {
                $extend: "dropdown"
            },
            "dropdown-help" : {
                $extend: "dropdown"
            }
        }
    }
);

router.isReady().then(() => {
	app.mount('#app')
})

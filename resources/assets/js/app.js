import Vue, { createApp } from "vue";
import App from './App.vue';
import store from './store';
import router from './router';
import filters from './filters';
import { createI18n } from 'vue-i18n';
import { library } from '@fortawesome/fontawesome-svg-core';
import { fas } from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import EventBus from "@/events/eventBus";

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
app.mount( "#app" );

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

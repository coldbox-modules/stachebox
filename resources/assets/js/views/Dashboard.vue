<template>
  <div>
    <div class="mt-4" v-if="aggregations">
      <div class="flex flex-wrap -mx-6">
        <div class="w-full px-6 sm:w-1/2 xl:w-1/3">
          <div
            class="flex items-center px-5 py-6 shadow-sm rounded-md bg-white"
          >
            <div class="p-3 rounded-full bg-cyan-600 bg-opacity-75">
				<fa-icon class="text-white h-9" size="2x" icon="list" fixed-width />
            </div>

            <div class="mx-5">
              <h4 class="text-2xl font-semibold text-gray-700">{{aggregations.logCount}}</h4>
              <div class="text-gray-500">Log Entries</div>
            </div>
          </div>
        </div>

		<div class="w-full px-6 sm:w-1/2 xl:w-1/3">
          <div
            class="flex items-center px-5 py-6 shadow-sm rounded-md bg-white"
          >
            <div class="p-3 rounded-full bg-red-600 bg-opacity-75">
				<fa-icon class="text-white h-9" size="2x" icon="server" fixed-width />
            </div>

            <div class="mx-5">
              <h4 class="text-2xl font-semibold text-gray-700">{{applicationCount}}</h4>
              <div class="text-gray-500">Applications</div>
            </div>
          </div>
        </div>

		<div class="w-full px-6 sm:w-1/2 xl:w-1/3">
          <div
            class="flex items-center px-5 py-6 shadow-sm rounded-md bg-white"
          >
            <div class="p-3 rounded-full bg-indigo-600 bg-opacity-75">
				<fa-icon class="text-white h-9" size="2x" icon="code" fixed-width />
            </div>

            <div class="mx-5">
              <h4 class="text-2xl font-semibold text-gray-700">{{typeCount}}</h4>
              <div class="text-gray-500">Log Types</div>
            </div>
          </div>
        </div>
      </div>
    </div>

	<div v-else class="mt-4 text-center items-center">
		<fa-icon size="3x" class="text-gray-400" icon="circle-notch" spin fixed-width />
		<p class="mt-4 text-gray-400">Loading log data. Please wait...</p>
	</div>

    <div class="mt-8"></div>

    <div class="flex flex-col mt-8" v-if="applications">
		<h3 class="text-gray-500 text-xl font-medium pb-2 border-gray-300 border-b">Recent Entries by Application</h3>
      <div class="-my-2 py-2 overflow-x-auto sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">

        <div
          class="align-middle inline-block min-w-full"
        >
		<template
			v-for="(application, index) in applications"
		>
			<h4 :key="application" class="text-theme text-lg font-medium mt-5 pb-o"><router-link :to="`/logs/application/${application}`">{{application.toTitleCase()}}</router-link></h4>
			<entry-list
				wrapper-class="mt-5"
				:key="index"
				:initialFilters='{ sortOrder : "timestamp DESC", collapse : "stachebox.signature", "application": application, maxrows: 5 }'
				:displayApplication="false"
				:loaderMessage="`Fetching recent log data for application: ${application}. Please stand by...`"
				:emptyStateMessage="`No new log data for application: ${application}`"
			></entry-list>
		</template>

        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Stachebox from "@/errors/Stachebox";
import EntryList from "@/components/entries/EntryList";
import logsAPI from "../api/logs";
import { mapState } from "vuex";
export default {
  components : {
	  EntryList
  },
  computed : {
	  ...mapState( {
		  aggregations : state => state.navAggregations
	  } ),
	  applicationCount(){
		  return this.aggregations && this.aggregations.applications ? Object.keys( this.aggregations.applications ).length : 0
	  },
	  typeCount(){
		  return this.aggregations && this.aggregations.types ? Object.keys( this.aggregations.types ).length : 0
	  },
	  applications(){
		  return this.aggregations ? Object.keys( this.aggregations.applications ) : null;
	  }
  },
  created(){
	  var self = this;

		//   Error log generation
		//   setInterval( function(){
		// 	  // javascript error
		// 	  let errMsg  = 'Boom goes the UI #' + Math.floor( Math.random() * Math.floor(1000) );
		// 	  new Stachebox( { token : self.$store.state.authToken } ).log( new Error( errMsg ) );
		// 	  // Add a grouped error
		// 	  new Stachebox( { token : self.$store.state.authToken } ).log( new Error( "Boom goes the javascript" ) );
		// 	  // cfml error
		// 	  self.$store.dispatch( "fetchLogs", { minDate : "I am not a date" } );
		//   }, 5000)

  }

};
</script>

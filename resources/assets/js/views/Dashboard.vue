<template>
  <div>
    <div class="mt-4" v-if="aggregations">
      <div class="grid grid-cols-3 gap-2 sm:gap-6">
        <div class="flex flex-col items-center px-2 py-3 sm:flex-row sm:px-5 sm:py-6 shadow-sm rounded-md bg-white text-center sm:text-left">
          <div class="p-2 sm:p-3 rounded-full bg-cyan-600 bg-opacity-75 mb-1 sm:mb-0">
            <fa-icon class="text-white" size="lg" icon="list" fixed-width />
          </div>
          <div class="sm:mx-5">
            <h4 class="text-lg sm:text-2xl font-semibold text-gray-700">{{aggregations.logCount.toLocaleString()}}</h4>
            <div class="text-xs sm:text-base text-gray-500">{{ $t( "Log Entries" ) }}</div>
          </div>
        </div>

        <div class="flex flex-col items-center px-2 py-3 sm:flex-row sm:px-5 sm:py-6 shadow-sm rounded-md bg-white text-center sm:text-left">
          <div class="p-2 sm:p-3 rounded-full bg-red-600 bg-opacity-75 mb-1 sm:mb-0">
            <fa-icon class="text-white" size="lg" icon="server" fixed-width />
          </div>
          <div class="sm:mx-5">
            <h4 class="text-lg sm:text-2xl font-semibold text-gray-700">{{applicationCount}}</h4>
            <div class="text-xs sm:text-base text-gray-500">{{ $t( "Applications" ) }}</div>
          </div>
        </div>

        <div class="flex flex-col items-center px-2 py-3 sm:flex-row sm:px-5 sm:py-6 shadow-sm rounded-md bg-white text-center sm:text-left">
          <div class="p-2 sm:p-3 rounded-full bg-indigo-600 bg-opacity-75 mb-1 sm:mb-0">
            <fa-icon class="text-white" size="lg" icon="code" fixed-width />
          </div>
          <div class="sm:mx-5">
            <h4 class="text-lg sm:text-2xl font-semibold text-gray-700">{{typeCount}}</h4>
            <div class="text-xs sm:text-base text-gray-500">{{ $t( "Log Types" ) }}</div>
          </div>
        </div>
      </div>
    </div>

	<div v-else class="mt-4 text-center items-center">
		<fa-icon size="3x" class="text-gray-400" icon="circle-notch" spin fixed-width />
		<p class="mt-4 text-gray-400">{{ $t( "Loading log data. Please wait..." ) }}</p>
	</div>

    <div class="flex items-center justify-end mt-4 mb-2" v-if="orderedApplications">
      <span class="inline-flex rounded-md shadow-sm">
        <button
          type="button"
          @click="chartView = 'per-app'"
          :class="chartView === 'per-app' ? 'bg-cyan-600 text-white' : 'bg-white text-gray-700 hover:text-gray-500'"
          class="px-4 py-2 text-sm font-medium border border-gray-300 rounded-l-md focus:outline-none"
        >{{ $t( "Per App" ) }}</button>
        <button
          type="button"
          @click="chartView = 'unified'"
          :class="chartView === 'unified' ? 'bg-cyan-600 text-white' : 'bg-white text-gray-700 hover:text-gray-500'"
          class="-ml-px px-4 py-2 text-sm font-medium border border-gray-300 rounded-r-md focus:outline-none"
        >{{ $t( "Unified" ) }}</button>
      </span>
    </div>

    <div class="flex flex-col" v-if="orderedApplications">
      <div class="py-2 sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">

        <div
          class="align-middle inline-block w-full"
        >
			<unified-snapshot v-if="chartView === 'unified'"></unified-snapshot>
			<template
				v-else
				v-for="(application, index) in orderedApplications"
				:key="`application-${application}`"
			>
				<application-snapshot :application="application"></application-snapshot>
			</template>

        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapState } from "vuex";
import ApplicationSnapshot from "./ApplicationSnapshot";
import UnifiedSnapshot from "./UnifiedSnapshot";
export default {
  components : {
	  ApplicationSnapshot,
	  UnifiedSnapshot
  },
  data(){
	  return {
		  chartView: localStorage.getItem( "stachebox.chartView" ) || "per-app"
	  }
  },
  watch: {
	  chartView( val ){
		  localStorage.setItem( "stachebox.chartView", val );
	  }
  },
  computed : {
	  ...mapState( {
		  aggregations : state => state.navAggregations
	  } ),
	  ...mapGetters( [ "orderedApplications" ] ),
	  applicationCount(){
		  return this.aggregations && this.aggregations.applications ? Object.keys( this.aggregations.applications ).length : 0
	  },
	  typeCount(){
		  return this.aggregations && this.aggregations.types ? Object.keys( this.aggregations.types ).length : 0
	  }
  },
  created(){
	  var self = this;
  }

};
</script>

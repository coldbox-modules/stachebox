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
		<p class="mt-4 text-gray-400">{{ $t( "Loading log data. Please wait..." ) }}</p>
	</div>

    <div class="mt-8"></div>

    <div class="flex flex-col mt-8" v-if="orderedApplications">
      <div class="-my-2 py-2 overflow-x-auto sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">

        <div
          class="align-middle inline-block min-w-full"
        >
			<template
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
import ApplicationSnapshot from "./ApplicationSnapshot";
import { mapGetters, mapState } from "vuex";
export default {
  components : {
	  ApplicationSnapshot
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

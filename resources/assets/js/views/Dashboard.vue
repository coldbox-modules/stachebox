<template>
  <div>
    <h3 class="text-gray-700 text-3xl font-medium">Dashboard</h3>

    <div class="mt-4" v-if="recentLogs">
      <div class="flex flex-wrap -mx-6">
        <div class="w-full px-6 sm:w-1/2 xl:w-1/3">
          <div
            class="flex items-center px-5 py-6 shadow-sm rounded-md bg-white"
          >
            <div class="p-3 rounded-full bg-teal-600 bg-opacity-75">
				<fa-icon class="text-white h-9" size="2x" icon="list" fixed-width />
            </div>

            <div class="mx-5">
              <h4 class="text-2xl font-semibold text-gray-700">{{recentLogs.total}}</h4>
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

    <div class="flex flex-col mt-8" v-if="recentLogs">
      <div class="-my-2 py-2 overflow-x-auto sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
        <div
          class="align-middle inline-block min-w-full"
        >
          <entry-list
		  	v-for="(group, index) in Object.keys( groupedLogs )"
			:key="index"
			:application="group"
			:logs="groupedLogs[ group ]"
		  ></entry-list>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Stachebox from "@/errors/Stachebox";
import EntryList from "@/components/entries/EntryList";
export default {
  components : {
	  EntryList
  },
  props : {},
  data(){
	  return {
		  recentLogs : null
	  }
  },
  computed : {
	  applicationCount(){
		  return this.recentLogs && this.recentLogs.aggregations.applications ? Object.keys( this.recentLogs.aggregations.applications ).length : 0
	  },
	  typeCount(){
		  return this.recentLogs && this.recentLogs.aggregations.types ? Object.keys( this.recentLogs.aggregations.types ).length : 0
	  },
	  groupedLogs(){
		  return this.recentLogs
					  ? this.recentLogs.results.reduce( ( acc, entry ) => {
						  if( !entry.application ){
							  if( !acc.unknown ){
								acc.unknown = [];
							  }
							  acc.unnknown.push( entry );
						  } else {
							  if( !acc[ entry.application ] ) acc[ entry.application ] = [];
							  acc[ entry.application ].push( entry)
						  }
						  return acc;
					  }, {} )
					  : null
	  }
  },
  methods : {
	  fetchRecent(){
		  this.$store.dispatch( "fetchLogs", { sortOrder : "timestamp DESC", aggregationGroup : "stachebox.signature" } )
		  	.then( ( result ) => this.recentLogs = result.data )
	  }
  },
  created(){
	  this.fetchRecent();




	// new Stachebox( { token : this.$store.state.authToken } ).log( new Error('BOOM Chacka Wow Wow') );

}
};
</script>

<template>
	<div class="application-logs">
		<h2 class="text-gray-500 text-2xl font-medium pb-2 border-gray-300 border-b"><span v-if="this.$route.params.applicationId">{{ this.$route.params.applicationId }} </span>{{ $t( "Application Log Results" ) }}</h2>
		<div class="entry-list">
			<entry-list
				:initialFilters="searchParams"
				:displayApplication="!this.$route.params.applicationId"
			></entry-list>
		</div>
		<h2 class="mt-6 text-gray-500 text-2xl font-medium pb-2 border-gray-300 border-b">{{ $t( "Filebeat Results" ) }}<span v-if="this.$route.params.applicationId"> {{ $t( "for" ) }} {{ this.$route.params.applicationId }}</span></h2>
		<div class="entry-list">
			<beats-list
				filter-set="filebeat"
				:initialFilters="beatParams"
			></beats-list>
		</div>
	</div>
</template>
<script>
import BeatsList from "@/components/entries/BeatsList";
import EntryList from "@/components/entries/EntryList";
export default{
	components : {
		EntryList,
		BeatsList
	},
	data(){
		return {
			searchResult : null,
			searchParams : {
				sortOrder : "@timestamp DESC",
				collapse : "stachebox.signature",
				maxrows : 10
			},
			beatParams : {
				sortOrder : "@timestamp DESC",
				maxrows : 10
			}
		}
	},
	computed : {
		applicationName(){
			return this.$route.params.id;
		}
	},
	created(){
		if( this.$route.params.search ){
			this.searchParams.search = this.$route.params.search;
			this.beatParams.search = this.$route.params.search;
		}
		if( this.$route.params.applicationId ){
			this.searchParams[ "labels.application" ] = this.$route.params.applicationId;
			this.beatParams[ "labels.application" ] = this.$route.params.applicationId;
		}
	}
}
</script>
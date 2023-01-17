<template>
	<div class="application-logs">
		<h3 class="text-gray-500 text-xl font-medium pb-2 border-gray-300 border-b">{{ $t( "Application Log Results" ) }}</h3>
		<div class="entry-list">
			<entry-list
				:initialFilters="searchParams"
				:displayApplication="false"
			></entry-list>
		</div>
		<h3 class="mt-6 text-gray-500 text-xl font-medium pb-2 border-gray-300 border-b">{{ $t( "Filebeat Results" ) }}</h3>
		<div class="entry-list">
			<beats-list
				filter-set="filebeat"
				:initialFilters="beatParams"
			></beats-list>
		</div>
	</div>
</template>
<script>
import EntryList from "@/components/entries/EntryList";
import BeatsList from "@/components/entries/BeatsList";
export default{
	components : {
		EntryList,
		BeatsList
	},
	data(){
		return {
			searchResult : null,
			searchParams : {
				sortOrder : "timestamp DESC",
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
	}
}
</script>
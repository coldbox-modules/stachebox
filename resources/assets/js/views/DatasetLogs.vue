<template>
	<div class="dataset-logs">
		<h1 class="text-gray-500 text-3xl font-medium pb-2 border-gray-300 border-b"> {{ $t( "Filebeat Dataset Logs for: {dataset}", { dataset : $filters.datasetName( $route.params.id ) } ) }}</h1>
		<div class="entry-list">
			<beats-list
				:initialFilters="searchParams"
			></beats-list>
		</div>
	</div>
</template>
<script>
import BeatsList from "@/components/entries/BeatsList";
export default{
	components : {
		BeatsList
	},
	data(){
		return {
			searchResult : null,
			searchParams : {
				'event.dataset' : this.$route.params.id
			}
		}
	},
	computed : {
		datasetName(){
			return this.$route.params.id;
		}
	},
	watch : {
		datasetName : function( oldApp, newApp  ){
			if( oldApp != newApp ){
				window.Event.$emit(
					"on-search-filter-change",
					{
						'event.dataset' : this.$route.params.id
					}
				);
			}
		}
	}
}
</script>
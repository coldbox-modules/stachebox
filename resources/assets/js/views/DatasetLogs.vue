<template>
	<div class="dataset-logs">
		<h3 class="text-gray-500 text-xl font-medium pb-2 border-gray-300 border-b">Filebeat Dataset Logs for: {{$filters.datasetName( $route.params.id )}}</h3>
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
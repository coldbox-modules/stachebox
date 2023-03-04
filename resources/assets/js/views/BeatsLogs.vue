<template>
	<div class="dataset-logs">
		<h1 class="text-gray-500 text-3xl font-medium pb-2 border-gray-300 border-b">{{ $t( "Filebeat Entries for for type: {type}", { type: $route.params.id.toTitleCase() } ) }}</h1>
		<div class="entry-list">
			<beats-list
				filter-set="filebeat"
				:initialFilters="searchParams"
				:displayDataset="true"
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
				'input.type' : this.$route.params.id
			}
		}
	},
	computed : {
		typeName(){
			return this.$route.params.id;
		}
	},
	watch : {
		typeName : function( oldApp, newApp  ){
			if( oldApp != newApp ){
				window.Event.$emit(
					"on-search-filter-change",
					{
						'input.type' : this.$route.params.id
					}
				);
			}
		}
	}
}
</script>
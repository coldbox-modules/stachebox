<template>
	<div class="dataset-logs">
		<h3 class="text-gray-500 text-xl font-medium pb-2 border-gray-300 border-b">Filebeat Entries for for type: {{$route.params.id.toTitleCase()}}</h3>
		<div class="entry-list">
			<beats-list
				filter-set="filebeat"
				:initialFilters="searchParams"
				:displayDataset="false"
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
<template>
	<div class="application-logs">
		<h3 class="text-gray-500 text-xl font-medium pb-2 border-gray-300 border-b">Log Search Results</h3>
		<div class="entry-list">
			<entry-list
				:initialFilters="searchParams"
				:displayApplication="false"
			></entry-list>
		</div>
	</div>
</template>
<script>
import EntryList from "@/components/entries/EntryList";
export default{
	components : {
		EntryList
	},
	data(){
		return {
			searchResult : null,
			searchParams : {
				sortOrder : "timestamp DESC",
				collapse : "stachebox.signature"
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
		}
	}
}
</script>
<template>
	<div class="application-logs">
		<h3 class="text-gray-500 text-xl font-medium pb-2 border-gray-300 border-b">Application Logs For {{$route.params.id}}</h3>
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
				application : this.$route.params.id,
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
	watch : {
		applicationName : function( oldApp, newApp  ){
			if( oldApp != newApp ){
				window.Event.$emit(
					"on-search-filter-change",
					{
						application : this.$route.params.id,
						sortOrder : "timestamp DESC",
						collapse : "stachebox.signature"
					}
				);
			}
		}
	}
}
</script>
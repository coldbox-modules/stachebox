<template>
	<div class="application-logs">
		<div class="flex flex-col mt-8">
			<div class="-my-2 py-2 overflow-x-auto sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
				<div
				class="align-middle inline-block min-w-full"
				>
					<application-snapshot :application="$route.params.id" :chartsOnly="true"></application-snapshot>
				</div>
			</div>
		</div>
		<h3 class="text-gray-500 text-xl font-medium pb-2 border-gray-300 border-b">Recent Entries For {{$route.params.id.toTitleCase()}} <em v-if="$route.params.environment">({{ $route.params.environment.toTitleCase() }})</em></h3>
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
import ApplicationSnapshot from "./ApplicationSnapshot";
export default{
	components : {
		EntryList,
		ApplicationSnapshot
	},
	data(){
		return {
			searchResult : null,
			searchParams : {
				environment : this.$route.params.environment,
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
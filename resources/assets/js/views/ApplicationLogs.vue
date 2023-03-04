<template>
	<div class="application-logs">
		<div class="flex flex-col">
			<div class="-my-2 py-2 overflow-x-auto sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
				<div
				class="align-middle inline-block min-w-full"
				>
					<application-snapshot heading-class="h2" heading-size="3xl" :application="$route.params.id" :chartsOnly="true"></application-snapshot>
				</div>
			</div>
		</div>
		<h2 class="text-gray-500 text-xl font-medium pb-2 border-gray-300 border-b">{{ $t( "Recent Entries For {application}", { application: $route.params.id.toTitleCase() } )}} <em v-if="$route.params.environment">({{ $route.params.environment.toTitleCase() }})</em></h2>
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
				"labels.environment" : this.$route.params.environment,
				"labels.application" : this.$route.params.id,
				sortOrder : "@timestamp DESC",
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
						"labels.application" : this.$route.params.id,
						sortOrder : "@timestamp DESC",
						collapse : "stachebox.signature"
					}
				);
			}
		}
	}
}
</script>
<template>
	<div class="entry-list">
		<entry-list
			v-if="searchResult"
			:application="$route.params.id"
			:logs="searchResult.results"
			:pagination="pagination"
		></entry-list>
		<div v-else class="mt-4 text-center items-center">
			<fa-icon size="3x" class="text-gray-400" icon="circle-notch" spin fixed-width />
			<p class="mt-4 text-gray-400">Loading application logs. Please wait...</p>
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
				aggregationGroup : "stachebox.signature"
			}
		}
	},
	computed : {
		pagination(){
			return {
				page : 1,
				pages : 1,
				maxRows : this.searchResult.limit,
				startRow : this.searchResult.start,
				total : this.searchResult.total
			}
		},
		applicationName(){
			return this.$route.params.id;
		}
	},
	methods : {
		fetchLogs(){
			this.$store.dispatch( "fetchLogs", this.searchParams )
						.then( ( result ) => this.searchResult = result.data )
		}
	},
	created(){
		this.fetchLogs()
	},
	watch : {
		applicationName : function( oldApp, newApp  ){
			if( oldApp != newApp ){
				this.$set( this, "searchResult", null );
				this.fetchLogs();
			}
		}
	}
}
</script>
<template>
	<div class="application-logs">
		<h2 class="text-gray-500 text-2xl font-medium pb-2 border-gray-300 border-b"><span v-if="this.$route.params.applicationId">{{ this.$route.params.applicationId }}</span> {{ $t( "Application Log Results" ) }}</h2>
		<div class="entry-list">
			<entry-list
				:initialFilters="searchParams"
				:displayApplication="!this.$route.params.applicationId"
				:allowFilters="false"
			></entry-list>
		</div>
		<h2 v-if="beatsEnabled" class="mt-6 text-gray-500 text-2xl font-medium pb-2 border-gray-300 border-b">{{ $t( "Filebeat Results" ) }}<span v-if="this.$route.params.applicationId"> {{ $t( "for" ) }} {{ this.$route.params.applicationId }}</span></h2>
		<div v-if="beatsEnabled" class="entry-list">
			<beats-list
				filter-set="filebeat"
				:initialFilters="beatParams"
				:allowFilters="false"
			></beats-list>
		</div>
	</div>
</template>
<script>
import BeatsList from "@/components/entries/BeatsList";
import EntryList from "@/components/entries/EntryList";
import { mapState } from "vuex";
export default{
	components : {
		EntryList,
		BeatsList
	},
	data(){
		return {
			searchResult : null,
			searchParams : {
				sortOrder : "@timestamp DESC",
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
		},
		...mapState( {
			beatsEnabled : state => state.beatsEnabled
		} )
	},
	created(){
		if( this.$route.params.search ){
			try{
				this.searchParams = JSON.parse( window.atob( this.$route.params.search ) );
				this.beatParams = this.searchParams;
			} catch( e ) {
				// legacy permalinks catch
				// TODO: remove in future release
				this.searchParams.search = this.$route.params.search;
				this.beatParams.search = this.searchParams.search;
			}
		}
		if( this.$route.params.applicationId ){
			if( !this.searchParams.terms ){
				this.searchParams.terms = [];
			}
			this.searchParams.terms.push( { key: "labels.application", operator: "must", value : this.$route.params.applicationId } );

			if( !this.beatParams.terms ){
				this.beatParams.terms = [];
			}
			this.beatParams.terms.push( { key: "labels.application", operator: "must", value : this.$route.params.applicationId } );
		}
	}
}
</script>
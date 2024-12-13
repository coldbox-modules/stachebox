<template>
	<div :class="wrapperClass">
		<entry-list-filters v-if="allowFilters" v-show="displayFilters" :searchFilters="searchFilters" @apply-filter="updateFilters" @apply-term="updateTerms"></entry-list-filters>
		<table class="min-w-full table-fixed" v-if="logs">
			<thead>
				<tr>
					<th
						v-if="displayApplication"
						class="px-2 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase"
					>
						{{ $t( "Application" ) }}
					</th>
					<th
						class="px-2 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase"
					>
						{{ $t( "Time" ) }} <a @click="toggleTimeSort" class="text-sm ml-3 inline-block"><fa-icon :class="{ 'text-cyan-500' : isTimeSort, 'text-gray-200' : !isTimeSort }" :icon="isAscending ? 'chevron-up' : 'chevron-down'"/></a>
					</th>
					<th
						class="px-2 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase"
					>
						{{ $t( "Type" ) }}
					</th>
					<th
						v-if="displayOccurrences"
						class="px-2 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase"
					>
						{{ $t( "Qty" ) }} <a @click="toggleOccurrenceSort" class="text-sm ml-3 inline-block"><fa-icon :class="{ 'text-cyan-500' : isOccurrenceSort, 'text-gray-200' : !isOccurrenceSort }" :icon="isAscending ? 'chevron-up' : 'chevron-down'"/></a>
					</th>
					<th
						class="px-2 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase"
						style="max-width:400px!important"
					>
						{{ $t( "Message" ) }}
					</th>
					<th class="px-2 py-3 border-b border-gray-200 bg-gray-50 justify-right text-right whitespace-nowrap">
						<a @click="toggleFollow" class="hover:cursor-pointer" v-tooltip="followInterval ? $t( 'Disable auto-refresh' ) : $t( 'Enable auto-refresh' )" ><fa-icon icon="sync" :spin="isSyncing" :class="{ 'text-gray-300' : !followInterval, 'text-theme' : followInterval }"></fa-icon></a>&nbsp;
						<a v-if="allowFilters" @click="toggleFilters" class="hover:cursor-pointer" v-tooltip="$t( 'Toggle filter options' )"><fa-icon class="text-gray-400" icon="filter"/></a>
					</th>
				</tr>
			</thead>

			<tbody class="bg-white" v-if="logs.length">
				<tr v-show="!followInterval && isSyncing">
					<td :colspan="currentColspan" class="px-3 py-2 border-b border-gray-200 text-xs text-center text-gray-500">
						<fa-icon size="1x" class="text-gray-400" icon="spinner" spin fixed-width />
						<p class="mt-4 text-gray-400">{{loaderMessage}}</p>
					</td>
				</tr>
				<tr v-for="(entry, index) in logs" :key="index" class="hover:bg-gray-50 cursor-pointer" :class="{ 'opacity-60' : entry.stachebox && entry.stachebox.isSuppressed  }" tabindex="0" @keyup.enter="$router.push( { name: 'LogEntry', params: { id: entry.id, search : $route.params.search } } )">
				<td
					v-if="displayApplication"
					class="px-3 py-2 border-b border-gray-200 text-sm text-gray-500 whitespace-nowrap"
					style="width: 150px"
					@click="$router.push( { name: 'LogEntry', params: { id: entry.id, search : $route.params.search } } )"
				>
					{{entry.labels.application || $t( 'N/A' )}}
				</td>

				<td
					class="px-3 py-2 border-b border-gray-200 text-sm text-gray-500 whitespace-nowrap"
					style="width: 175px"
					@click="$router.push( { name: 'LogEntry', params: { id: entry.id, search : $route.params.search } } )"
				>
				{{ dayjs( entry['@timestamp' ] ).format('MM/DD/YYYY HH:mm') }}
				</td>
				<td
					class="px-3 py-2 border-b border-gray-200 text-sm text-gray-500"
					style="width: 150px"
					@click="$router.push( { name: 'LogEntry', params: { id: entry.id, search : $route.params.search } } )"
				>
					{{entry.error.type ? entry.error.type.toTitleCase() : ( entry.log.level || "unknown" ) }}
				</td>
				<td
					v-if="displayOccurrences"
					class="px-3 py-2 border-b border-gray-200 text-sm text-gray-500"
					@click="$router.push( { name: 'LogEntry', params: { id: entry.id, search : $route.params.search } } )"
				>
					<span class="inline-flex items-center justify-center px-2 py-1 text-xs leading-none text-white bg-theme rounded-full">{{ entry.occurrences || 1 }}</span>
				</td>
				<td
					class="px-3 py-2 border-b border-gray-200 text-sm leading-5 text-gray-500"
				>
					<router-link :to="{ name: 'LogEntry', params: { id: entry.id, search : $route.params.search } }"><code class="text-yellow-600 text-xs">{{ $filters.truncate( entry.message.replace(/,(?=[^\s])/g, ", "), truncate ? 200 : entry.message.length + 1 ) }}</code></router-link>
				</td>

				<td
					class="px-3 py-2 text-right border-b border-gray-200 text-sm leading-5 font-medium whitespace-nowrap"
				>
					<confirmation-button
						v-if="allowSuppress"
						@confirmed="suppress( entry )"
						:confirmation-message="$t( 'Click to Suppress' )"
						class-string="text-gray-300 hover:text-cyan-900"
					>
						<template #icon>
							<fa-icon icon="eye-slash" v-tooltip="$t( 'Suppress this log entry from future results' )" fixed-width></fa-icon>
						</template>
					</confirmation-button>
					<router-link class="sr-only" :to="{ path: `/logs/entry/${entry.id}`}">{, params: this.$route.params { $t( "View Entry" ) }}</router-link>
				</td>
				</tr>
			</tbody>
			<tbody v-else class="bg-white">
				<tr>
					<td :colspan="currentColspan" class="px-3 py-2 border-b border-gray-200 text-lg text-center text-gray-500">
						<em>{{emptyStateMessage}}</em>
					</td>
				</tr>
			</tbody>

		</table>
		<pagination v-if="pagination && logs.length != pagination.total" :pagination="pagination" @update-maxrows="updateMax" @paginate="paginate"></pagination>
		<div v-if="!logs" class="mt-4 text-center items-center">
			<fa-icon size="3x" class="text-gray-400" icon="circle-notch" spin fixed-width />
			<p class="mt-4 text-gray-400">{{loaderMessage}}</p>
		</div>
	</div>

</template>
<script>
import ConfirmationButton from "@/components/ConfirmationButton";
import Pagination from "@/components/Pagination";
import EntryListFilters from "@/components/entries/EntryListFilters";
export default {
	components : {
		Pagination,
		EntryListFilters,
		ConfirmationButton
	},
	props : {
		initialFilters : {
			type : Object,
			default : () => { return { sortOrder : "@timestamp DESC", "stachebox.isSuppressed" : false } }
		},
		truncate : {
			type : Boolean,
			default : true
		},
		displayOccurrences : {
			type : Boolean,
			default : true
		},
		allowSuppress : {
			type : Boolean,
			default : true
		},
		displayApplication : {
			type : Boolean,
			default : true
		},
		allowFilters : {
			type : Boolean,
			default : true
		},
		wrapperClass : {
			type : String,
			default : ''
		},
		loaderMessage : {
			type : String,
			default : "Loading log data. Please wait..."
		},
		emptyStateMessage : {
			type : String,
			default : "No records matched your search criteria"
		}
	},
	data(){
		return {
		  logs : null,
		  pagination : null,
		  searchFilters : Object.assign( {}, this.initialFilters ),
		  followInterval : null,
		  intervalMilliseconds : 5000,
		  isSyncing : false,
		  displayFilters : false
		};
	},
	computed : {
		currentColspan(){
			let colspan = 4;
			if( this.displayOccurrences ) colspan++;
			if( this.displayApplication ) colspan++;
			return colspan;
		},
		isAscending(){
			return this.searchFilters.sortOrder && this.searchFilters.sortOrder.includes( "ASC" );
		},
		isTimeSort(){
			return this.searchFilters.sortOrder && this.searchFilters.sortOrder.includes( "@timestamp" );
		},
		isOccurrenceSort(){
			return this.searchFilters.sortOrder && this.searchFilters.sortOrder.includes( "occurrences" );
		},
	},
	methods : {
		fetchLogs(){
			var self = this;
			self.isSyncing = true;
			if( !this.searchFilters.tzOffset ){
				this.searchFilters.tzOffset = this.dayjs().format( "Z" );
			}
			if( this.searchFilters.terms && Object.keys( this.searchFilters.terms ).length === 0 ){
				delete this.searchFilters.terms;
			}
			this.$store.dispatch( "fetchLogs", this.searchFilters )
						.then( ( result ) => {
							self.isSyncing = false
							self.logs = result.data.results;
							self.pagination = result.data.pagination;
						} )
		},
		toggleFollow(){
			if( this.followInterval ){
				clearInterval( this.followInterval );
				this.followInterval = null;
			} else {
				this.followInterval= setInterval( this.fetchLogs, this.intervalMilliseconds )
			}
		},
		toggleFilters(){
			this.displayFilters = !this.displayFilters;
		},
		toggleTimeSort(){
			this.searchFilters.sortOrder = ( !this.isTimeSort || this.isAscending ) ? "@timestamp DESC" : "@timestamp ASC";
			this.fetchLogs();
		},
		toggleOccurrenceSort(){
			this.searchFilters.sortOrder = ( !this.isOccurrenceSort || this.isAscending ) ? "occurrences DESC" : "occurrences ASC";
			this.fetchLogs();
		},
		paginate( pageNumber ){
			if( !pageNumber || pageNumber === this.pagination.page ) return;
			let refreshEnabled = !!this.followInterval;
			if( refreshEnabled ) this.toggleFollow();
			delete this.searchFilters[ "startRows" ];
			this.searchFilters.page = pageNumber;
			this.fetchLogs();
			if( refreshEnabled ) this.toggleFollow();
		},
		updateFilters( args ){
			let refreshEnabled = !!this.followInterval;
			if( refreshEnabled ) this.toggleFollow();
			Object.keys( args ).forEach( ( key ) => this.searchFilters[ key ] = args[ key ] || null );
			this.fetchLogs();
			if( refreshEnabled ) this.toggleFollow();
		},
		updateTerms( args ){
			let refreshEnabled = !!this.followInterval;
			if( refreshEnabled ) this.toggleFollow();
			if( !this.searchFilters.terms ){
				this.searchFilters.terms = {};
			}
			Object.keys( args ).forEach( ( key ) => args[ key ] ? this.searchFilters.terms[ key ] = args[ key ] : delete this.searchFilters.terms[ key ] );
			this.fetchLogs();
			if( refreshEnabled ) this.toggleFollow();
		},
		updateMax( val ){
			this.updateFilters( { maxrows : val } );
		},
		suppress( entry ){
			let args;
			if( entry.stachebox && entry.stachebox.signature ){
				args = { field : "signature", id : entry.stachebox.signature };
			} else {
				args = { field : "id", id : entry.id };
			}

			args[ "environment" ] = this.$route.params.environment;

			this.$store.dispatch( "suppressEntry", args )
							.then( () => this.logs.splice( this.logs.findIndex( item => item.id == entry.id ), 1 ) );

			this.pagination.total--;

			// refresh the page after our index is updated to display new logs
			if( !this.followInterval ){
				setTimeout( this.fetchLogs, 5100 );
			}

			entry.stachebox.isSuppressed = true;
		}
	},
	mounted(){
		if( this.$route.params.search ){
			try{
				this.searchFilters = JSON.parse( window.atob( this.$route.params.search ) );
			} catch( e ) {
				// legacy permalinks catch
				// TODO: remove in future release
				this.searchFilters.search = this.$route.params.search;
			}
		}
		this.fetchLogs();
		window.Event.$on( "on-search-filter-change", this.updateFilters );
	}
}
</script>
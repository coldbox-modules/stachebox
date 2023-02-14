<template>
	<div :class="wrapperClass">
		<entry-list-filters v-show="displayFilters" :searchFilters="searchFilters" @apply-filter="updateFilters"></entry-list-filters>
		<table class="min-w-full" style="table-layout:fixed" v-if="logs">
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
						{{ $t( "Time" ) }}
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
						{{ $t( "Qty" ) }}
					</th>
					<th
						class="px-2 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase"
						style="max-width:400px!important"
					>
						{{ $t( "Message" ) }}
					</th>
					<th class="px-2 py-3 border-b border-gray-200 bg-gray-50 justify-right text-right">
						<a @click="toggleFollow" v-tooltip="followInterval ? $t( 'Disable auto-refresh' ) : $t( 'Enable auto-refresh' )" ><fa-icon icon="sync" :spin="isSyncing" :class="{ 'text-gray-300' : !followInterval, 'text-theme' : followInterval }"></fa-icon></a>
						<a @click="toggleFilters" v-tooltip="$t( 'Toggle filter options' )"><fa-icon class="text-gray-400" icon="filter"/></a>
					</th>
				</tr>
			</thead>

			<tbody class="bg-white" v-if="logs.length">
				<tr v-for="(entry, index) in logs" :key="index" class="hover:bg-gray-50 cursor-pointer" :class="{ 'opacity-60' : entry.stachebox && entry.stachebox.isSuppressed  }">
				<td
					v-if="displayApplication"
					class="px-3 py-2 border-b border-gray-200 text-sm text-gray-500"
					style="width: 150px"
					@click="$router.push( `/logs/entry/${entry.id}` )"
				>
					{{entry.labels.application || $t( 'N/A' )}}
				</td>

				<td
					class="px-3 py-2 border-b border-gray-200 text-sm text-gray-500"
					style="width: 175px"
					@click="$router.push( `/logs/entry/${entry.id}` )"
				>
				{{ dayjs( entry['@timestamp' ] ).format('MM/DD/YYYY HH:mm') }}
				</td>
				<td
					class="px-3 py-2 border-b border-gray-200 text-sm text-gray-500"
					style="width: 150px"
					@click="$router.push( `/logs/entry/${entry.id}` )"
				>
					{{entry.error.type ? entry.error.type.toTitleCase() : ( entry.log.level || "unknown" ) }}
				</td>
				<td
					v-if="displayOccurrences"
					class="px-3 py-2 border-b border-gray-200 text-sm text-gray-500"
					@click="$router.push( `/logs/entry/${entry.id}` )"
				>
					<span class="inline-flex items-center justify-center px-2 py-1 text-xs leading-none text-white bg-theme rounded-full">{{ entry.occurrences || 1 }}</span>
				</td>
				<td
					class="px-3 py-2 border-b border-gray-200 text-sm leading-5 text-gray-500"
					style="max-width:400px!important"
					@click="$router.push( `/logs/entry/${entry.id}` )"
				>
					<code class="text-yellow-600 text-xs">{{ $filters.truncate( entry.message, truncate ? 200 : entry.message.length + 1 ) }}</code>
				</td>

				<td
					class="px-3 py-2 text-right border-b border-gray-200 text-sm leading-5 font-medium"
				>
					<confirmation-button
						@confirmed="suppress( entry )"
						:confirmation-message="$t( 'Click to Suppress' )"
						class-string="text-gray-300 hover:text-cyan-900"
					>
						<template #icon>
							<fa-icon icon="eye-slash" v-tooltip="$t( 'Suppress this log entry from future results' )" fixed-width></fa-icon>
						</template>
					</confirmation-button>
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
		<pagination v-if="pagination" :pagination="pagination" @update-maxrows="updateMax" @paginate="paginate"></pagination>
		<div v-if="!logs" class="mt-4 text-center items-center">
			<fa-icon size="3x" class="text-gray-400" icon="circle-notch" spin fixed-width />
			<p class="mt-4 text-gray-400">{{loaderMessage}}</p>
		</div>
	</div>

</template>
<script>
import Pagination from "@/components/Pagination";
import EntryListFilters from "@/components/entries/EntryListFilters";
import ConfirmationButton from "@/components/ConfirmationButton";
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
		displayApplication : {
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
		}
	},
	methods : {
		fetchLogs(){
			var self = this;
			self.isSyncing = true;
			this.$store.dispatch( "fetchLogs", this.searchFilters )
						.then( ( result ) => {
							if( !self.logs ){
								self.isSyncing = false
							} else {
								setTimeout( () => self.isSyncing = false, 1500 );
							}
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
		paginate( pageNumber ){
			if( !pageNumber || pageNumber === this.pagination.page ) return;
			let refreshEnabled = !!this.followInterval;
			if( refreshEnabled ) this.toggleFollow();
			this.$delete( this.searchFilters, "startRows" );
			this.searchFilters.page = pageNumber;
			this.fetchLogs();
			if( refreshEnabled ) this.toggleFollow();
		},
		updateFilters( args ){
			let refreshEnabled = !!this.followInterval;
			if( refreshEnabled ) this.toggleFollow();
			Object.keys( args ).forEach( ( key ) => this.searchFilters[ key ] = args[ key ] );
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
		this.fetchLogs();
		window.Event.$on( "on-search-filter-change", this.updateFilters );
	}
}
</script>
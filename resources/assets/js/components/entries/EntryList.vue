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
						Application
					</th>
					<th
						class="px-2 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase"
					>
						Time
					</th>
					<th
						class="px-2 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase"
					>
						Type
					</th>
					<th
						v-if="displayOccurrences"
						class="px-2 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase"
					>
						Qty
					</th>
					<th
						class="px-2 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase"
						style="max-width:400px!important"
					>
						Message
					</th>
					<th class="px-2 py-3 border-b border-gray-200 bg-gray-50 justify-right text-right">
						<a @click="toggleFollow" v-tooltip="followInterval ? 'Disable auto-refresh' : 'Enable auto-refresh'" ><fa-icon icon="sync" :spin="isSyncing" :class="{ 'text-gray-300' : !followInterval, 'text-theme' : followInterval }"></fa-icon></a>
						<a @click="toggleFilters" v-tooltip="'Toggle filter options'"><fa-icon class="text-gray-400" icon="filter"/></a>
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
					{{entry.application || 'N/A'}}
				</td>

				<td
					class="px-3 py-2 border-b border-gray-200 text-sm text-gray-500"
					style="width: 175px"
					@click="$router.push( `/logs/entry/${entry.id}` )"
				>
				{{ dayjs( entry['@timestamp' ] ).format('DD/MM/YYYY HH:mm') }}
				</td>
				<td
					class="px-3 py-2 border-b border-gray-200 text-sm text-gray-500"
					style="width: 150px"
					@click="$router.push( `/logs/entry/${entry.id}` )"
				>
					{{entry.type.toTitleCase()}}
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
					<code class="text-yellow-600 text-xs">{{ entry.message | truncate( truncate ? 200 : entry.message.length + 1 ) }}</code>
				</td>

				<td
					class="px-3 py-2 text-right border-b border-gray-200 text-sm leading-5 font-medium"
				>
					<a @click="suppress( entry )" v-tooltip="'Suppress this entry and its occurrences, to date, from future log results'" class="text-teal-600 hover:text-teal-900">
						<fa-icon icon="eye-slash"></fa-icon>
					</a>
				</td>
				</tr>
			</tbody>
			<tbody v-else class="bg-white">
				<tr>
					<td :colspan="currentColspan" class="px-3 py-2 border-b border-gray-200 text-lg text-center text-gray-500">
						<em>No records matched your search criteria</em>
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
import dayjs from "dayjs";
import utc from "dayjs/plugin/utc";
import timezone from "dayjs/plugin/timezone";
dayjs.extend( utc );
dayjs.extend( timezone );
dayjs.tz.setDefault( dayjs.tz.guess() );
import Pagination from "@/components/Pagination";
import EntryListFilters from "@/components/entries/EntryListFilters";
export default {
	components : {
		Pagination,
		EntryListFilters
	},
	props : {
		initialFilters : {
			type : Object,
			default : () => { return { sortOrder : "timestamp DESC", "stachebox.isSuppressed" : false } }
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
		}
	},
	data(){
		return {
		  dayjs : dayjs,
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
								self.$set( self, "isSyncing", false )
							} else {
								setTimeout( () => self.$set( self, "isSyncing", false ), 1500 );
							}
							self.$set( self, "logs", result.data.results );
							self.$set( self, "pagination", result.data.pagination );


						} )
		},
		toggleFollow(){
			if( this.followInterval ){
				clearInterval( this.followInterval );
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
			this.$set( this.searchFilters, "page", pageNumber );
			this.fetchLogs();
			if( refreshEnabled ) this.toggleFollow();
		},
		updateFilters( args ){
			let refreshEnabled = !!this.followInterval;
			if( refreshEnabled ) this.toggleFollow();
			Object.keys( args ).forEach( ( key ) => this.$set( this.searchFilters, key, args[ key ] ) );
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
	}
}
</script>
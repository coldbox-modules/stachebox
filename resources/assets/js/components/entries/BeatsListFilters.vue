<template>
	<div class="grid bg-white grid-cols-3 gap-2">
		<div class="my-2">
			<div class="px-3 py-2 mt-2">
				<label class="text-gray-400 text-xs uppercase leading-5">Date Range:</label>
				<date-time-picker
					v-model="dateRange"
					:range="true"
					color="#159CBF"
					label="Select a minimum date or range"
					:max-date="new Date().toISOString()"
					@validate="updateDateRangeFilters"
					@input="checkDateRangeClear"
					format="YYYY-MM-DDTHH:mm:ss.sssZ"
				></date-time-picker>
			</div>
			<!-- <div class="px-3 py-2 mt-2">
				<label class="text-gray-400 text-xs uppercase leading-5">Error Type:</label>
			</div> -->

		</div>

		<div class="my-2 pl-5 border-l border-gray-300">
			<template v-if="filterSet == 'dataset'">
				<div class="px-3 py-2 mt-2" v-if="!searchFilters['event.dataset']">
					<label class="text-gray-400 text-xs uppercase leading-5">Dataset:</label>
					<select
						id="application"
						name="application"
						v-model="searchFilters['event.dataset']"
						:value="'all'"
						@change="onFilterChange( 'event.dataset', searchFilters[ 'event.dataset' ] )"
						class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-cyan-500 focus:border-cyan-500 sm:text-sm rounded-md"
					>
						<option :value="undefined">All Datasets</option>
						<option v-for="dataset in datasets" :key="dataset" :value="dataset">{{ dataset | datasetName }}</option>
					</select>
				</div>

			</template>
			<div v-else class="px-3 py-2 mt-2">
				<label class="text-gray-400 text-xs uppercase leading-5">Host Name:</label>
				<select
					id="environment"
					name="environment"
					v-model="searchFilters[ 'host.hostname' ]"
					:value="'all'"
					@change="onFilterChange( 'host.hostname', searchFilters[ 'host.hostname' ] )"
					class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-cyan-500 focus:border-cyan-500 sm:text-sm rounded-md"
				>
					<option :value="undefined">All Hosts</option>
					<option
						v-for="hostname in hostNames"
						:key="hostname"
						:value="hostname"
					>{{hostname}}</option>
				</select>
			</div>
		</div>


		<div class="my-2 pl-5 border-l border-gray-300" >
			<div class="px-3 py-2 mt-2">
				<label class="text-gray-400 text-xs uppercase leading-5">Log Level:</label>
				<select
					v-if="filterSet == 'dataset'"
					id="level"
					name="level"
					v-model="searchFilters[ 'event.type' ]"
					:value="'all'"
					@change="onFilterChange( 'event.type', searchFilters[ 'event.type' ] )"
					class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-cyan-500 focus:border-cyan-500 sm:text-sm rounded-md"
				>
					<option :value="undefined">No Level</option>
					<option value="fatal">Fatal</option>
					<option value="error">Error</option>
					<option value="warn">Warning</option>
					<option value="info">Informational</option>
					<option value="debug">Debug</option>
				</select>

				<select
					v-else
					id="level"
					name="level"
					v-model="searchFilters[ 'search' ]"
					:value="'all'"
					@change="onFilterChange( 'search', searchFilters[ 'search' ] )"
					class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-cyan-500 focus:border-cyan-500 sm:text-sm rounded-md"
				>
					<option :value="undefined">No Level</option>
					<option value="[FATAL">Fatal</option>
					<option value="[ERR">Error</option>
					<option value="[WARN">Warning</option>
					<option value="[INFO">Informational</option>
					<option value="[DEBUG">Debug</option>
				</select>

			</div>
		</div>
	</div>
</template>
<script>
import DateTimePicker from 'vue-ctk-date-time-picker';
import { mapState } from "vuex";
import dayjs from "dayjs";
export default {
	components : {
		DateTimePicker
	},
	props : {
		searchFilters : {
			type : Object,
			required : true
		},
		filterSet : {
			type : String,
			default : "dataset"
		}
	},
	data(){
		return {
			dateRange : null
		}
	},
	computed : {
		...mapState({
			applications : ( state ) => state.navAggregations ? Object.keys( state.navAggregations.datasets ) : [],
			navAggregations : ( state ) => state.navAggregations,
			hostNames( state ){
				if( !state.navAggregations ) return;
				if( this.searchFilters[ 'event.dataset' ] ){
					return Object.keys( state.navAggregations.datasets[ this.searchFilters['event.dataset'] ].hostnames )
				} else if( state.navAggregations.hostnames ) {
					return Object.keys( state.navAggregations.hostnames );
				}
			}
		})
	},
	methods: {
		onFilterChange( key, val ){
			this.$emit( "apply-filter", { [key] :  val && val !== 'all' ? val : undefined } )
		},
		checkDateRangeClear( val ){
			this.$emit( "apply-filter", {
					minDate : undefined,
					maxDate: undefined
				} );
		},
		updateDateRangeFilters(){
			this.$emit(
				"apply-filter", {
					minDate : this.dateRange.start,
					maxDate: this.dateRange.end
				}
			);
		}
	}

}
</script>
<template>
	<div class="grid bg-white grid-cols-3 gap-2">
		<div class="my-2">
			<div class="px-3 py-2 mt-2">
				<label class="text-gray-400 text-xs uppercase leading-5">{{ $t( "Date Range" ) }}:</label>
				<date-time-picker
					v-model="dateRange"
					:range="true"
					color="#374151"
					:label="$t( 'Select a minimum date or range' )"
					:noHeader="true"
					:max-date="new Date().toISOString()"
					position="bottom"
					@validate="updateDateRangeFilters"
					@input="checkDateRangeClear"
					format="YYYY-MM-DDTHH:mm:ss.sssZ"
				></date-time-picker>
			</div>
		</div>

		<div class="my-2 pl-5 border-l border-gray-300">
			<div class="px-3 py-2 mt-2" v-if="!searchFilters.application">
				<label class="text-gray-400 text-xs uppercase leading-5">{{ $t( "Application" ) }}:</label>
				<select
					id="application"
					name="application"
					v-model="searchFilters.application"
					:value="'all'"
					@change="onFilterChange( 'labels.application', searchFilters.application )"
					class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-cyan-500 focus:border-cyan-500 sm:text-sm rounded-md"
				>
					<option :value="undefined">{{ $t( "All Applications" ) }}</option>
					<option v-for="application in applications" :key="application" :value="application">{{application.toTitleCase()}}</option>
				</select>
			</div>
			<div v-else-if="availableEnvironments" class="px-3 py-2 mt-2">
				<label class="text-gray-400 text-xs uppercase leading-5">{{ $t( "Environment" ) }}:</label>
				<select
					id="environment"
					name="environment"
					v-model="searchFilters.environment"
					:value="'all'"
					@change="onFilterChange( 'labels.environment', searchFilters.environment )"
					class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-cyan-500 focus:border-cyan-500 sm:text-sm rounded-md"
				>
					<option :value="undefined">All Environments</option>
					<option v-for="environment in availableEnvironments" :value="environment.toLowerCase()">{{ environment.toTitleCase() }}</option>
				</select>
			</div>
		</div>

		<div class="my-2 pl-5 border-l border-gray-300" >
			<div class="px-3 py-2 mt-2">
				<label class="text-gray-400 text-xs uppercase leading-5">{{ $t( "Log Level" ) }}:</label>
				<select
					id="level"
					name="level"
					v-model="searchFilters.level"
					:value="'all'"
					@change="onFilterChange( 'log.level', searchFilters.level )"
					class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-cyan-500 focus:border-cyan-500 sm:text-sm rounded-md"
				>
					<option :value="undefined">{{ $t( "All Levels" ) }}</option>
					<option value="fatal">{{ $t( "Fatal" ) }}</option>
					<option value="error">{{ $t( "Error" ) }}</option>
					<option value="warn">{{ $t( "Warning" ) }}</option>
					<option value="info">{{ $t( "Informational" ) }}</option>
					<option value="debug">{{ $t( "Debug" ) }}</option>
				</select>

			</div>
		</div>
	</div>
</template>
<script>
import DateTimePicker from 'vue-ctk-date-time-picker';
import { mapState } from "vuex";
export default {
	components : {
		DateTimePicker
	},
	props : {
		searchFilters : {
			type : Object,
			required : true
		}
	},
	data(){
		return {
			dateRange : null
		}
	},
	computed : {
		...mapState({
			applications : ( state ) => state.navAggregations ? Object.keys( state.navAggregations.applications ) : [],
			availableEnvironments : state => state.navAggregations ? Object.keys( state.navAggregations.environments ) : null
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
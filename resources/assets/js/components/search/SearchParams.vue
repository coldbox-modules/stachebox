<template>
	<div class="entry-search-filters grid grid-cols-4">
		<div class="my-1">
			<div class="px-3 py-2">
				<label class="text-gray-400 text-xs uppercase leading-5">{{ $t( "Date Range" ) }}:</label>
				<date-time-picker
					v-model="dateRange"
					@update:modelValue="updateDateRangeFilters"
				></date-time-picker>
			</div>
		</div>

		<div class="my-1 pl-5">
			<div class="px-3 py-2">
				<label class="text-gray-400 text-xs uppercase leading-5">{{ $t( "Application" ) }}:</label>
				<select
					id="application"
					name="application"
					:disabled="this.$route.params.applicationId || null"
					@change="onTermChange( 'labels.application', $event.target.value != 'all' ? $event.target.value : null )"
					class="mt-1 block w-full pl-3 pr-10 py-2 border-gray-300 focus:outline-none focus:ring-cyan-500 focus:border-cyan-500 text-xs rounded-md"
				>
					<option value="all" :selected="selectedApplication == 'all'">{{ $t( "All Applications" ) }}</option>
					<option v-for="application in applications" :key="application" :value="application" :selected="( selectedApplication == application ? true : null )">{{application.toTitleCase()}}</option>
				</select>
			</div>
		</div>

		<div class="my-1 pl-5">
			<div class="px-3 py-2">
				<label class="text-gray-400 text-xs uppercase leading-5">{{ $t( "Environment" ) }}:</label>
				<select
					id="environment"
					name="environment"
					:disabled="this.$route.params.environment || null"
					@change="onTermChange( 'labels.environment', $event.target.value != 'all' ? $event.target.value : null )"
					class="mt-1 block w-full pl-3 pr-10 py-2 border-gray-300 focus:outline-none focus:ring-cyan-500 focus:border-cyan-500 text-xs rounded-md"
				>
					<option value="all" :selected="selectedEnvironment == 'all'">All Environments</option>
					<option v-for="environment in availableEnvironments" :value="environment.toLowerCase()" :selected="( selectedEnvironment == environment.toLowerCase() ? true : null )">{{ environment.toTitleCase() }}</option>
				</select>
			</div>
		</div>

		<div class="my-1 pl-5" >
			<div class="px-3 py-2">
				<label class="text-gray-400 text-xs uppercase leading-5">{{ $t( "Log Level" ) }}:</label>
				<select
					id="level"
					name="level"
					:value="selectedLevel"
					@change="onTermChange( 'log.level', $event.target.value != 'all' ? $event.target.value : null )"
					class="mt-1 block w-full pl-3 pr-10 py-2 border-gray-300 focus:outline-none focus:ring-cyan-500 focus:border-cyan-500 text-xs rounded-md"
				>
					<option value="all" :selected="selectedLevel == 'all'">{{ $t( "All Levels" ) }}</option>
					<option value="fatal" :selected="selectedLevel == 'fatal'">{{ $t( "Fatal" ) }}</option>
					<option value="error" :selected="selectedLevel == 'error'">{{ $t( "Error" ) }}</option>
					<option value="warn" :selected="selectedLevel == 'warn'">{{ $t( "Warning" ) }}</option>
					<option value="info" :selected="selectedLevel == 'info'">{{ $t( "Informational" ) }}</option>
					<option value="debug" :selected="selectedLevel == 'debug'">{{ $t( "Debug" ) }}</option>
				</select>

			</div>
		</div>
	</div>
</template>
<script>
import DateTimePicker from '@/components/DatePicker';
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
		}),
		selectedApplication(){
			if( this.$route.params.applicationId ){
				return this.$route.params.applicationId;
			} else {
				var existingTerm = this.searchFilters.terms.findIndex( term => term.key === 'labels.application' );
				if( existingTerm > -1 ){
					return this.searchFilters.terms[ existingTerm ].value;
				} else {
					return 'all';
				}
			}
		},
		selectedEnvironment(){
			var existingTerm = this.searchFilters.terms.findIndex( term => term.key === 'labels.environment' );
			if( existingTerm > -1 ){
				return this.searchFilters.terms[ existingTerm ].value;
			} else {
				return 'all';
			}
		},
		selectedLevel(){
			var existingTerm = this.searchFilters.terms.findIndex( term => term.key === 'log.level' );
			if( existingTerm > -1 ){
				return this.searchFilters.terms[ existingTerm ].value;
			} else {
				return 'all';
			}
		}
	},
	watch : {
		searchFilters : {
			handler( val ){
				if( val.minDate || val.maxDate ){
					if( !this.dateRange ){
						this.dateRange = [];
					}
					this.dateRange.splice( 0, 2, new Date( val.minDate ), new Date( val.maxDate ) );
				}
			},
			deep : true
		}
	},
	methods: {
		onTermChange( key, val ){
			this.$emit( "apply-term", { [key] :  val && val !== 'all' ? val : undefined } )
		},
		onFilterChange( key, val ){
			this.$emit( "apply-filter", { [key] :  val && val !== 'all' ? val : undefined } )
		},
		updateDateRangeFilters( e ){
			this.$emit(
				"apply-filter", {
					minDate : e[ 0 ] || null,
					maxDate: e[ 1 ] || null
				}
			);
		}
	}

}
</script>
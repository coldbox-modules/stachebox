<template>
	<div class="border-gray-600 mb-7">
		<component :is="headingClass" :class="`${headingColorClass} text-${headingSize} font-medium pb-2`">
			<router-link :to="`/logs/application/${application}`">
				{{ $t( "Application" ) }}: {{ application.toTitleCase() }}
				<em v-if="$route.params.environment">({{ $route.params.environment.toTitleCase() }})</em>
			</router-link>
		</component>
		<tabs class="mt-2">
			<tab :name="$t( 'Past 24 Hours' )" class="bg-white">
				<BarChart v-if="aggregations" style="max-height:350px" :chartData="hourlyData" :options="chartOptions"></BarChart>
			</tab>
			<tab :name="$t( 'Past 7 Days' )" class="bg-white">
				<BarChart v-if="aggregations" style="max-height:350px" :chartData="dailyData" :options="chartOptions"></BarChart>
			</tab>
			<tab v-if="!chartsOnly" :name="$t( 'Recent Entries' )" class="bg-gray-100">
				<entry-list
					wrapper-class="mt-0"
					:initialFilters='{ sortOrder : "@timestamp DESC", collapse : "stachebox.signature", "application": application, maxrows: 5 }'
					:displayApplication="false"
					:loaderMessage="$t( 'Fetching recent log data for application', { application: application } )"
					:emptyStateMessage="$t( 'No new log data for application: {application}', { application: application } )"
				></entry-list>
			</tab>
		</tabs>
	</div>
</template>
<script>
import { Chart, registerables } from 'chart.js';
Chart.register(...registerables);
import { BarChart } from 'vue-chart-3';
import { mapState } from "vuex";
import ColorScheme from "color-scheme";
import Tab from "@/components/Tab";
import Tabs from "@/components/Tabs";
import EntryList from '@/components/entries/EntryList';
export default {
	components: {
		BarChart,
		Tab,
		Tabs,
		EntryList
	},
	props : {
		headingClass: {
			required: false,
			default : "h3"
		},
		headingSize: {
			required: false,
			default: "xl"
		},
		headingColorClass: {
			required: false,
			default: "text-gray-500"
		},
		application: {
			required : true
		},
		chartsOnly : {
			default: false
		}
	},
	data(){
		return {
			hourRange : 24,
			dayRange : 7,
			chartColors: null,
			chartOptions : {
				responsive: true,
				maintainAspectRatio: false,
				plugins: {
					legend: {
						display: false
					}
				}
			}
		}
	},
	beforeMount(){
		let scheme = new ColorScheme;
		let hues = [ 255, 100, 180 ];
		this.chartColors = hues.reduce( function( agg, hue ) {
			return agg.concat(
				scheme.from_hue( hue )
					.scheme( "analogic" )
					.variation( "soft" )
					.colors()
			);
		}, [] ).map( ( color ) => "#" + color );
	},
	computed : {
		...mapState({
			aggregations( state ){
				return state.navAggregations
						? this.$route.params.environment ? state.navAggregations.environments[this.$route.params.environment].applications[ this.application ] : state.navAggregations.applications[ this.application ] : null;
			}
		}),
		hourlyData(){
			if( !this.aggregations ) return;

			var hourStart = this.dayjs( new Date() ).subtract( this.hourRange, "hours" ).startOf( "hour" );
			var aggs = this.aggregations.hourly_occurrences;

			var chartData = {
				labels: [],
				datasets: [
					{
						label: 'Totals',
						data: [],
						backgroundColor: [],
					},
				]
			};

			for( var i = 0; i <= this.hourRange; i++ ){
				var thisHour = hourStart.clone().add( i, "hours" );
				chartData.labels.push( thisHour.format( "M/D " ) + thisHour.format( "hA" ) + "-" + thisHour.clone().add( 1, "hour" ).format( "hA" )   );
				let hourKey = thisHour.utc().format( "YYYY-MM-DDTHH:mm:ss.SSS[Z]" );
				chartData.datasets[ 0 ].data.push( aggs[ hourKey ] ? aggs[ hourKey ].count : 0 );
				chartData.datasets[ 0 ].backgroundColor.push( this.chartColors[ i ] );
			}

			return chartData;
		},
		dailyData(){
			if( !this.aggregations ) return;

			var dayStart = this.dayjs( new Date() ).subtract( this.dayRange, "days" ).startOf( "day" );
			var aggs = this.aggregations.daily_occurrences;

			var chartData = {
				labels: [],
				datasets: [
					{
						label: 'Totals',
						data: [],
						backgroundColor: [],
					},
				]
			};

			for( var i = 0; i <= this.dayRange; i++ ){
				var thisDay = dayStart.clone().add( i, "days" );
				chartData.labels.push( thisDay.format( "ddd M/D" ) );
				let dayKey = thisDay.format( "YYYY-MM-DDTHH:mm:ss.SSS[Z]" );
				chartData.datasets[ 0 ].data.push( aggs[ dayKey ] ? aggs[ dayKey ].count : 0 );
				chartData.datasets[ 0 ].backgroundColor.push( this.chartColors[ i ] );
			}

			return chartData;
		}
	}

}
</script>
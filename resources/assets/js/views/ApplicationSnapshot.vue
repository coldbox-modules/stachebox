<template>
	<div class="border-gray-600 mb-3">
		<h3 class="text-gray-500 text-xl font-medium pb-2 border-gray-300 border-b">
			<router-link :to="`/logs/application/${application}`">
				{{ application.toTitleCase() }}
				<em v-if="$route.params.environment">({{ $route.params.environment.toTitleCase() }})</em>
			</router-link>
		</h3>
		<tabs class="mt-2">
			<tab name="Past 24 Hours">
				<BarChart v-if="aggregations" style="max-height:350px" :chartData="hourlyData" :options="chartOptions"></BarChart>
			</tab>
			<tab name="Past 7 Days">
				<BarChart v-if="aggregations" style="max-height:350px" :chartData="dailyData" :options="chartOptions"></BarChart>
			</tab>
			<tab v-if="!chartsOnly" name="Recent Entries">
				<entry-list
					wrapper-class="mt-0"
					:initialFilters='{ sortOrder : "timestamp DESC", collapse : "stachebox.signature", "application": application, maxrows: 5 }'
					:displayApplication="false"
					:loaderMessage="`Fetching recent log data for application: ${application}. Please stand by...`"
					:emptyStateMessage="`No new log data for application: ${application}`"
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
import dayjs from "dayjs";
import utc from "dayjs/plugin/utc";
import timezone from "dayjs/plugin/timezone";
import ColorScheme from "color-scheme";
dayjs.extend( utc );
dayjs.extend( timezone );
dayjs.tz.setDefault( dayjs.tz.guess() );
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
						position: 'bottom',
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

			var hourStart = dayjs( new Date() ).subtract( this.hourRange, "hours" ).startOf( "hour" );
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
				let hourKey = thisHour.utc().format( "YYYY-MM-DDTHH:mm:ss[Z]" )
				chartData.datasets[ 0 ].data.push( aggs[ hourKey ] ? aggs[ hourKey ].count : 0 );
				chartData.datasets[ 0 ].backgroundColor.push( this.chartColors[ i ] );
			}

			return chartData;
		},
		dailyData(){
			if( !this.aggregations ) return;

			var dayStart = dayjs( new Date() ).subtract( this.dayRange, "days" ).startOf( "day" );
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
				let dayKey = thisDay.format( "YYYY-MM-DDTHH:mm:ss[Z]" );
				console.log( dayKey );
				console.log( Object.keys( aggs ) );
				console.log( aggs[ dayKey ] );
				chartData.datasets[ 0 ].data.push( aggs[ dayKey ] ? aggs[ dayKey ].count : 0 );
				chartData.datasets[ 0 ].backgroundColor.push( this.chartColors[ i ] );
			}

			return chartData;
		}
	}

}
</script>
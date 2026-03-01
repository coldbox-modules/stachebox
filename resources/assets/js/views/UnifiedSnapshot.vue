<template>
	<div class="border-gray-600 mb-7">
		<h3 class="text-gray-500 text-xl font-medium pb-2">{{ $t( "All Applications" ) }}</h3>
		<tabs class="mt-2">
			<tab :name="$t( 'Past 24 Hours' )" class="bg-white">
				<BarChart v-if="hourlyData" style="max-height:350px" :chartData="hourlyData" :options="chartOptions"></BarChart>
			</tab>
			<tab :name="$t( 'Past 7 Days' )" class="bg-white">
				<BarChart v-if="dailyData" style="max-height:350px" :chartData="dailyData" :options="chartOptions"></BarChart>
			</tab>
		</tabs>
	</div>
</template>
<script>
import { Chart, registerables } from 'chart.js';
Chart.register(...registerables);
import { BarChart } from 'vue-chart-3';
import { mapState, mapGetters } from "vuex";
import ColorScheme from "color-scheme";
import Tab from "@/components/Tab";
import Tabs from "@/components/Tabs";
export default {
	components: {
		BarChart,
		Tab,
		Tabs
	},
	data(){
		return {
			hourRange : 24,
			dayRange : 7,
			chartColors: null,
			chartOptions : {
				responsive: true,
				maintainAspectRatio: false,
				scales: {
					x: { stacked: true },
					y: { stacked: true }
				},
				plugins: {
					legend: {
						display: true
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
			applications : state => state.navAggregations ? state.navAggregations.applications : null
		}),
		...mapGetters( [ "orderedApplications", "dateFormats" ] ),
		appColors(){
			if( !this.orderedApplications || !this.chartColors ) return {};
			var colors = {};
			var total = this.chartColors.length;
			var count = this.orderedApplications.length;
			var step = Math.max( 1, Math.floor( total / count ) );
			this.orderedApplications.forEach( ( app, i ) => {
				colors[ app ] = this.chartColors[ ( i * step ) % total ];
			});
			return colors;
		},
		hourlyData(){
			if( !this.applications || !this.orderedApplications ) return null;

			var hourStart = this.dayjs( new Date() ).subtract( this.hourRange, "hours" ).startOf( "hour" );
			var labels = [];
			for( var i = 0; i <= this.hourRange; i++ ){
				var thisHour = hourStart.clone().add( i, "hours" );
				labels.push( thisHour.format( this.dateFormats.chartShort + " " ) + thisHour.format( this.dateFormats.hourFormat ) + " - " + thisHour.clone().add( 1, "hour" ).format( this.dateFormats.hourFormat ) );
			}

			var datasets = this.orderedApplications.map( ( app ) => {
				var aggs = this.applications[ app ] && this.applications[ app ].hourly_occurrences ? this.applications[ app ].hourly_occurrences : {};
				var data = [];
				for( var i = 0; i <= this.hourRange; i++ ){
					var thisHour = hourStart.clone().add( i, "hours" );
					var hourKey = thisHour.format( "YYYY-MM-DDTHH:mm:ss.SSSZ" );
					data.push( aggs[ hourKey ] ? aggs[ hourKey ].count : 0 );
				}
				return {
					label: app,
					data: data,
					backgroundColor: this.appColors[ app ]
				};
			});

			return { labels: labels, datasets: datasets };
		},
		dailyData(){
			if( !this.applications || !this.orderedApplications ) return null;

			var dayStart = this.dayjs( new Date() ).subtract( this.dayRange, "days" ).startOf( "day" );
			var labels = [];
			for( var i = 0; i <= this.dayRange; i++ ){
				var thisDay = dayStart.clone().add( i, "days" );
				labels.push( thisDay.format( this.dateFormats.chartDaily ) );
			}

			var datasets = this.orderedApplications.map( ( app ) => {
				var aggs = this.applications[ app ] && this.applications[ app ].daily_occurrences ? this.applications[ app ].daily_occurrences : {};
				var data = [];
				for( var i = 0; i <= this.dayRange; i++ ){
					var thisDay = dayStart.clone().add( i, "days" );
					var dayKey = thisDay.format( "YYYY-MM-DDTHH:mm:ss.SSSZ" );
					data.push( aggs[ dayKey ] ? aggs[ dayKey ].count : 0 );
				}
				return {
					label: app,
					data: data,
					backgroundColor: this.appColors[ app ]
				};
			});

			return { labels: labels, datasets: datasets };
		}
	}
}
</script>

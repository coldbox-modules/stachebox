<template>
	<div class="pr-5">
		<vue-date-picker
			v-model="dateRange"
			:range="true"
			:multi-calendars="true"
			:auto-apply="true"
			:preset-dates="filterRanges"
			:clearable="true"
			:label="$t( 'Select a minimum date or range' )"
			:max-date="endOfWeek"
			@update:model-value="$emit('update:modelValue', $event || [ null, null ] )"
		>
		</vue-date-picker>
	</div>
</template>
<script>
import VueDatePicker from '@vuepic/vue-datepicker';
export default {
	components: {
		VueDatePicker
	},
	props: {
		modelValue : {
			required : false,
			twoWay : true
		}
	},
	emits: ['update:modelValue'],
	watch: {
		modelValue : {
			handler( val ){
				if( Array.isArray( val ) && val.length == 2 && (  val[ 0 ] || val[ 1 ] ) ){
					this.dateRange = val;
				} else {
					this.dateRange = null;
				}
			}
		}
	},
	computed : {
		endOfWeek(){
			return this.dayjs(new Date()).endOf( "week" ).toDate();
		}
	},
	data(){
		return {
			dateRange: this.modelValue,
			filterRanges : [
				{
					label: 'Today',
					value: [
						this.dayjs(new Date()).startOf( "day" ).toDate(),
						new Date()
					]
				},
				{
					label: 'Yesterday',
					value: [
						this.dayjs(new Date()).subtract( 1, "day" ).startOf( "day" ).toDate(),
						this.dayjs(new Date()).endOf( "day" ).toDate()
					]
				},
				{
					label: 'Last 2 days',
					value: [
						this.dayjs(new Date()).subtract( 2, "day" ).startOf( "day" ).toDate(),
						this.dayjs(new Date()).subtract( 1, "day" ).endOf( "day" ).toDate()
					]
				},
				{
					label: 'This week',
					value: [
						this.dayjs(new Date()).startOf( "week" ).toDate(),
						this.dayjs(new Date()).endOf( "week" ).toDate()
					]
				},
				{
					label: 'This month',
					value: [
						this.dayjs(new Date()).startOf( "month" ).toDate(),
						new Date()
					]
				},
				{
					label: 'Last month',
					value: [
						this.dayjs(new Date()).subtract( 1, "month" ).startOf( "month" ).toDate(),
						this.dayjs(new Date()).subtract( 1, "month" ).endOf( "month" ).toDate()
					]
				},
				{
					label: 'This year',
					range: [
						this.dayjs(new Date()).startOf( "year" ).toDate(),
						this.dayjs(new Date()).endOf( "year" ).toDate()
					]
				},
				{
					label: 'Last Year',
					range: [
						this.dayjs(new Date()).subtract( 1, "year" ).startOf( "year" ).toDate(),
						this.dayjs(new Date()).subtract( 1, "year" ).endOf( "year" ).toDate()
					]
				}
			]
		}
	}
}
</script>
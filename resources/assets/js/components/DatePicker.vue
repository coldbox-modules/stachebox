<template>
	<div class="pr-5">
		<date-time-picker
			v-model="dateRange"
			:range="true"
			:auto-apply="true"
			:preset-ranges="filterRanges"
			:label="$t( 'Select a minimum date or range' )"
			:max-date="new Date().toISOString()"
			@update:model-value="$emit('update:modelValue', $event || [ null, null ] )"
		>
			<template #clear-icon="{ clear }">
				<fa-icon icon="undo" size="sm" fixed-width class="text-red-500 hover:cursor-pointer absolute" style="right:-25px;top:-7px" @click="clear"/>
			</template>
		</date-time-picker>
	</div>
</template>
<script>
import DateTimePicker from '@vuepic/vue-datepicker';
export default {
	components: {
		DateTimePicker
	},
	props: {
		modelValue : {
			required : false
		}
	},
	emits: ['update:modelValue'],
	beforeMount(){
		this.dateRange = this.modelValue;
	},
	data(){
		return {
			dateRange: null,
			filterRanges : [
				{
					label: 'Today',
					range: [
						this.dayjs(new Date()).startOf( "day" ).toDate(),
						new Date()
					]
				},
				{
					label: 'Yesterday',
					range: [
						this.dayjs(new Date()).subtract( 1, "day" ).startOf( "day" ).toDate(),
						this.dayjs(new Date()).subtract( 1, "day" ).endOf( "day" ).toDate()
					]
				},
				{
					label: 'This month',
					range: [
						this.dayjs(new Date()).startOf( "month" ).toDate(),
						new Date()
					]
				},
				{
					label: 'Last month',
					range: [
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
<template>
	<div class="flex w-full">
		<div class="flex w-full rounded-md">
			<simple-typeahead
				ref="keyInput"
				class="h-10 text-gray-700 border-none p-2 text-xs block rounded-l-md rounded-r-none mr-0 focus:border-gray-300 focus:ring-gray-300"
				placeholder="Key"
				:items="indexFields"
				:minInputLength="3"
				@selectItem="( item ) => this.filter.key = item"
			/>
			<select v-model="filter.operator" class="h-10 border-none p-2 pr-0 text-xs  text-cyan-700 inline-block items-center w-1/4 rounded-none ml-0 mr-0 focus:border-gray-100 focus:ring-gray-100">
				<option value="must" selected>{{ $t( 'equals' ) }}</option>
				<option value="must_not">{{ $t( 'does not equal' ) }}</option>
				<option value="wildcard" selected>{{ $t( 'contains' ) }}</option>
				<option value="gt">{{ $t( 'is greater than' ) }}</option>
				<option value="lt">{{ $t( 'is less than' ) }}</option>
				<option value="gte">{{ $t( 'is gte' ) }}</option>
				<option value="lte">{{ $t( 'is lte' ) }}</option>
			</select>
			<input type="text" v-model="filter.value" class="h-10 text-gray-700 border-none p-2 text-xs block w-1/2 rounded-l-none rounded-r-md ml-0 focus:border-gray-300 focus:ring-gray-300" placeholder="Value" @keydown.enter="$emit( 'applyFilter', this.filter )" />
			<a @click="$emit( 'removeFilter' )" class="float-right block ml-2" v-tooltip="$t( 'Remove Filter' )">
				<fa-icon class="text-red-600 h-9 text-xs" icon="circle-xmark" fixed-width />
			</a>
		</div>
	</div>
</template>
<script>
import SimpleTypeahead from 'vue3-simple-typeahead';
export default{
	components : {
		SimpleTypeahead
	},
	props : {
		initialIndexPattern: {
			type: String,
			required: false
		},
		indexFields: {
			type: Array,
			required: true
		},
		filter : {
			type : Object,
			required : true,
			twoWay : true
		}
	},
	methods: {

	},
	mounted(){
		if( this.filter.key ){
			this.$ref.keyInput.value.value = this.filter.key;
		}
	}
}
</script>
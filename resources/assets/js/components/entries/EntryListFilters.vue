<template>
	<div class="log-filters">

	</div>
</template>
<script>
export default {
	props : {
		searchFilters : {
			type : Object,
			required : true
		}
	},
	methods: {
		onFilterChange( key, val ){
			this.$emit( "apply-filter", { key : val } )
		}
	}

}
</script>
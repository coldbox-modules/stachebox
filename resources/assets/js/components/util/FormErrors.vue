<template>
	<span v-for="error of errors" :key="error.$uid">
		<fa-icon class="h-5 w-5 text-red-500" icon="warning"/>
		<span class="text-red-500">{{ error.$property.toTitleCase() }}: {{ error.$message }}</span>
	</span>
</template>
<script>
export default {
	props : {
		errors : {
			type : Array,
			required : true
		}
	}
}
</script>
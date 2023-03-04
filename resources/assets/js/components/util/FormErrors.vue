<template>
	<span v-if="errors && errors.length" class="block">
		<fa-icon class="h-5 w-5 text-red-500 mr-2" icon="exclamation-triangle"/>
		<span v-if="showFieldName" class="text-red-500">{{ fieldName || errors[0].$property.toTitleCase() }}: </span>
		<span class="text-red-500" v-for="( error, index ) of errors" :key="error.$uid"><span v-if="index > 0">, </span>{{ error.$message }}</span>
	</span>
</template>
<script>
export default {
	props : {
		errors : {
			type : Array,
			required : true
		},
        showFieldName : {
            type : Boolean,
            default : true
        },
        fieldName : {
            type : String,
            required: false
        }
	}
}
</script>
<template>
	<div class="mt-4 text-center items-center">
		<fa-icon size="3x" class="text-gray-300" icon="circle-notch" spin fixed-width />
		<p class="mt-4 text-gray-300">{{ message }}</p>
	</div>
</template>
<script>
	export default {
		props: {
			message : {
				default : "Loading data. Please wait..."
			}
		}
	}
</script>
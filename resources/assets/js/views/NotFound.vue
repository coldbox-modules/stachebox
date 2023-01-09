<template>
	<div>

		<router-link to="Dashboard">
			<img style="display:block;margin-left:auto;margin-right:auto" :src="`${baseHref}/includes/images/stachebox-logo.png`" width="500"/>
		</router-link>

		<h1 class="text-gray-700 text-5xl font-medium text-center mt-5">Oopsie Daisy!</h1>

		<h4 class="text-gray-700 font-medium text-center mt-10">The requested resource could not be found.</h4>
	</div>
</template>

<script>
import { mapState } from "vuex";
export default {
	computed : {
		...mapState({
			baseHref : ( state ) => state.globals.stachebox.baseHref
		})
	}
}
</script>

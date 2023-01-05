<template>
  <component :is="layout">
	<transition name="fade">
		<router-view :key="$route.fullPath" />
	</transition>
  </component>
</template>

<script>
	import { mapState } from "vuex";
	export default {
		computed : {
			...mapState( {
				authUser : state => state.authUser
			}),
			layout(){
				var defaultLayout = this.authUser ? 'dashboard' : 'empty';
				return  `${this.$route.meta.layout || defaultLayout}-layout`
			}
		}
	}
</script>

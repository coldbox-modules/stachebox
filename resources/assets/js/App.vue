<template>
  <component :is="layout">
	<router-view :key="$route.fullPath" v-slot="{ Component }">
		<transition name="fade">
			<component :is="Component" />
		</transition>
	</router-view>
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

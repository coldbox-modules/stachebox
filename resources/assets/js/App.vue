<template>
  <component :is="layout">
	<transition name="fade">
		<router-view :key="$route.fullPath" />
	</transition>
  </component>
</template>

<script>
	const defaultLayout = "dashboard";
	export default {
		computed : {
			layout(){ return  `${this.$route.meta.layout || defaultLayout}-layout` }
		}
	}
</script>

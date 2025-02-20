<template>
	<div>
		<Header v-on:toggle-sidebar="sidebarIsOpen = !sidebarIsOpen" :sidebarOpen="sidebarIsOpen" />
		<div class="flex h-screen bg-gray-200 font-roboto">
			<Sidebar :isOpen="sidebarIsOpen" />

			<div class="flex-1 flex flex-col">
				<main
					class="flex-1 bg-gray-200"
				>
					<div class="container mx-auto px-6 py-8">
						<slot />
					</div>
				</main>
			</div>
		</div>
	</div>
</template>
<script>
import Header from "./inc/Header.vue";
import Sidebar from "./inc/Sidebar.vue";

export default {
	components: {
		Header,
		Sidebar
	},
	data() {
		return {
			sidebarIsOpen: true
		};
	}
};
</script>

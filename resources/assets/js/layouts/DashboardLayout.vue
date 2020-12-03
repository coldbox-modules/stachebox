<template>
  <div class="flex h-screen bg-gray-200 font-roboto">
    <Sidebar />

    <div class="flex-1 flex flex-col overflow-hidden">
      <Header />

      <main class="flex-1 overflow-x-hidden overflow-y-auto bg-gray-200">
		<button
			@click="isOpen = true"
			class="text-gray-500 focus:outline-none lg:hidden"
		>
			<svg
			class="h-6 w-6"
			viewBox="0 0 24 24"
			fill="none"
			xmlns="http://www.w3.org/2000/svg"
			>
			<path
				d="M4 6H20M4 12H20M4 18H11"
				stroke="currentColor"
				stroke-width="2"
				stroke-linecap="round"
				stroke-linejoin="round"
			/>
			</svg>
		</button>
        <div class="container mx-auto px-6 py-8">
          <slot />
        </div>
      </main>
    </div>
  </div>
</template>
<script>

import Sidebar from "./inc/Sidebar.vue";
import Header from "./inc/Header.vue";

export default {
  components: {
    Header,
    Sidebar,
  }
};
</script>

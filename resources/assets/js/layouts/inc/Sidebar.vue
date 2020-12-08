<template>
  <div class="flex">
    <!-- Backdrop -->
    <div
      :class="isOpen ? 'block' : 'hidden'"
      @click="isOpen = false"
      class="fixed z-20 inset-0 bg-black opacity-50 transition-opacity lg:hidden"
    ></div>
    <!-- End Backdrop -->

    <div
      :class="isOpen ? 'translate-x-0 ease-out' : '-translate-x-full ease-in'"
      class="fixed z-30 inset-y-0 left-0 w-64 transition duration-300 transform bg-gray-800 overflow-y-auto lg:translate-x-0 lg:static lg:inset-0"
    >
      <div class="flex items-center justify-center pt-4 pb-6 bg-gray-100 border-b-2">
        <div class="flex items-center">

		  <router-link :to="{ name : 'Dashboard'}">
			  <img :src="`${baseHref}/includes/images/stachebox-logo-h.png`" width="200px"/>
		  </router-link>

        </div>
      </div>

      <nav class="mt-10">
        <router-link
          class="flex items-center duration-200 mt-4 py-2 px-6 border-l-4"
          :class="[$route.name === 'Dashboard' ? activeClass : inactiveClass]"
          to="/dashboard"
        >
          <fa-icon icon="chart-pie" fixed-width/>
          <span class="mx-4">Dashboard</span>
        </router-link>

		<template v-if="this.aggregations && this.aggregations.applications">
			<h3 class="ml-5 mr-5 pl-2 mt-10 mb-5 pb-1 uppercase text-gray-600 border-gray-600 border-b">Applications</h3>
			<router-link
				v-for="(application,index) in Object.keys( this.aggregations.applications )"
				:key="index"
				class="flex items-center duration-200 mt-4 py-2 px-6 border-l-4"
				:class="[$route.name === 'ApplicationLogs' && $route.params.id == application ? activeClass : inactiveClass]"
				:to="`/logs/application/${application}`"
			>
				<fa-icon icon="server" fixed-width/>
				<span class="mx-4">{{application.toTitleCase() | truncate( 15 ) }}</span>
			</router-link>
		</template>

		<template v-if="hasPermission( 'Administer:Settings' )">
			<h3 class="ml-5 mr-5 pl-2 mt-10 mb-5 pb-1 uppercase text-gray-600 border-gray-600 border-b">Administration</h3>

			<router-link
			class="flex items-center duration-200 mt-4 py-2 px-6 border-l-4"
			:class="[$route.name === 'Settings' ? activeClass : inactiveClass]"
			:to="{ name : 'Settings' }"
			>
				<fa-icon icon="cogs" fixed-width/>
				<span class="mx-4">Settings</span>
			</router-link>

		</template>

      </nav>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapState } from "vuex";
export default{
	data(){
		return {
			activeClass : "bg-gray-600 bg-opacity-25 text-gray-100 border-gray-100",
			inactiveClass : "border-gray-900 text-gray-500 hover:bg-gray-600 hover:bg-opacity-25 hover:text-gray-100",
			isOpen: false
		}
	},
	computed : {
		...mapGetters({
			hasPermission : "hasPermission"
		}),
		...mapState({
			authToken : ( state ) => state.authToken,
			aggregations : ( state ) => state.navAggregations,
			baseHref : ( state ) => state.globals.stachebox.baseHref
		})
	}
}

</script>

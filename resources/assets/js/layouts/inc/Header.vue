<template>
  <header
    class="flex justify-between items-start py-5 px-6 bg-gray-100 border-b-2 border-gray-800"
  >
	<div class="flex items-center">
		<div class="flex items-start justify-center bg-gray-100">
			<div class="flex items-start">
				<router-link :to="{ name : 'Dashboard'}" class="hover:cursor-pointer">
					<img :src="sidebarOpen ? `${baseHref}/includes/images/stachebox-logo-h.png` : `${baseHref}/includes/images/stachebox-logo.png`" :style="sidebarOpen ? `width:200px` : `width: 75px`"/>
				</router-link>
			</div>
		</div>
		<div class="relative ml-2">
			<button
				@click="$emit( 'toggle-sidebar' )"
				class="text-gray-500 focus:outline-none hover:cursor-pointer hover:text-gray-600"
				v-tooltip="'Toggle the sidebar menu'"
			>
				<fa-icon icon="bars" fixed-width/>
			</button>
		</div>
	</div>
    <div class="flex items-start w-2/3">
		<search-form :initialParams="searchFilters" @onSearchUpdate="sendToSearchPage" />
    </div>

    <div class="flex items-start" v-if="internalSecurityEnabled">

      <div class="relative" v-if="user">
        <button
          @click="dropdownOpen = !dropdownOpen"
          class="relative z-10 block h-8 w-8 rounded-full overflow-hidden shadow focus:outline-none hover:cursor-pointer"
        >
          <img
            class="h-full w-full object-cover"
            :src="user.avatar"
            alt="Your avatar"
          />
        </button>

        <div
          v-show="dropdownOpen"
          @click="dropdownOpen = false"
          class="fixed inset-0 h-full w-full z-10"
        ></div>

        <div
          v-show="dropdownOpen"
          class="absolute right-0 mt-2 py-2 w-48 bg-white rounded-md shadow-xl z-20"
        >
			<router-link
				:to="`/profile/${user.id}`"
				class="block px-4 py-2 text-sm text-gray-700 hover:bg-cyan-600 hover:text-white hover:cursor-pointer"
			>Profile</router-link>

			<router-link
				:to="{name : 'Directory'}"
				class="block px-4 py-2 text-sm text-gray-700 hover:bg-cyan-600 hover:text-white hover:cursor-pointer"
			>Directory</router-link>
			<a
				@click="logout"
				class="block px-4 py-2 text-sm text-gray-700 hover:bg-cyan-600 hover:text-white hover:cursor-pointer"
			>
				Log out
			</a>
        </div>
      </div>
    </div>
  </header>
</template>

<script>
import SearchForm from "@/components/search/SearchForm";
import { mapState } from "vuex";

export default {
	components : {
		SearchForm
	},
	props: {
		sidebarOpen : {
			type : Boolean,
			default : false
		}
	},
	data(){
		return {
			dropdownOpen : false,
			isOpen : false,
			searchText : '',
			searchFilters : {
				search : "",
				terms : []
			}
		}
	},
	computed : {
		...mapState({
			user : ( state ) => state.authUser,
			baseHref : ( state ) => state.globals.stachebox.baseHref,
			internalSecurityEnabled : ( state ) => state.globals.stachebox.internalSecurity
		})
	},
	mounted(){
		if( this.$route.params.search ){
			try{
				this.searchFilters = JSON.parse( window.atob( this.$route.params.search ) );
			} catch( e ) {
				// legacy permalinks catch
				// TODO: remove in future release
				this.searchFilters.search = this.$route.params.search;
			}
		}
	},
	methods : {
		logout(){
			this.$store.dispatch( "logout" )
						.finally(
							() => this.$router.push( { name : "Login" } )
						)
		},
		sendToSearchPage( params ){
			let searchRoute = "LogSearch";
			let isApplicationFocus = this.$route.name == "ApplicationLogs" || this.$route.name == "ApplicationEnvironmentLogs";
			let routeParams = { search: window.btoa( JSON.stringify( params ) ) };
			if( isApplicationFocus && this.$route.params.id ){
				routeParams.applicationId = this.$route.params.id;
				searchRoute = "ApplicationLogSearch";
			}

			if( this.$route.name != 'LogSearch' && this.$route.name != 'ApplicationLogSearch' ){
				this.$router.push( { name : searchRoute, params : routeParams, state : routeParams } );
			} else {
				this.$router.push( { name : this.$route.name, params : routeParams, state : routeParams } );
			}
		}
	}
};
</script>

<template>
  <header
    class="flex justify-between items-center py-5 px-6 bg-gray-100 border-b-2 border-gray-800"
  >
	<div class="flex items-center">
		<div class="flex items-center justify-center bg-gray-100">
			<div class="flex items-center">
				<router-link :to="{ name : 'Dashboard'}" class="hover:cursor-pointer">
					<img :src="`${baseHref}/includes/images/stachebox-logo-h.png`" style="width:200px"/>
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
    <div class="flex items-center w-2/3">
      <div class="relative mx-4 lg:mx-0 w-full">
        <span class="absolute inset-y-0 left-0 pl-3 flex items-center">
			<fa-icon class="text-gray-400 h-9 text-xs" icon="search" fixed-width />
        </span>

        <input
          class="form-input rounded-none block w-5/6 py-2 px-2 pl-10 pr-4 focus:border-cyan-600"
          type="text"
          placeholder="Search"
		  v-model="searchText"
		  @keyup.enter="sendToSearchPage"
        />
      </div>
    </div>

    <div class="flex items-center" v-if="internalSecurityEnabled">

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
import { mapState } from "vuex";
export default {
	data(){
		return {
			dropdownOpen : false,
			isOpen : false,
			searchText : ''
		}
	},
	computed : {
		...mapState({
			user : ( state ) => state.authUser,
			baseHref : ( state ) => state.globals.stachebox.baseHref,
			internalSecurityEnabled : ( state ) => state.globals.stachebox.internalSecurity
		})
	},
	methods : {
		logout(){
			this.$store.dispatch( "logout" )
						.finally(
							() => this.$router.push( { name : "Login" } )
						)
		},
		sendToSearchPage( e ){
			if( this.$route.name != 'LogSearch' ){
				this.$router.push( { name : 'LogSearch', params : { search : this.searchText } } );
			} else {
				window.Event.$emit( "on-search-filter-change", { search : this.searchText } )
			}
		}
	}
};
</script>

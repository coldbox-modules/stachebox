<template>
  <div class="flex justify-center items-center h-screen px-6">
    <div class="p-6 max-w-sm w-full bg-white shadow-lg shadow-cyan-500/40">
      <div class="flex justify-center items-center">
        <img :src="`${baseHref}/includes/images/stachebox-logo-h.png`" style="width:300px"/>
      </div>

      <form class="mt-4" @submit.prevent="login">

		<p v-for="(error, index) in errors" :key="`error-${index}`"  class="text-red-500 justify-center items-center">{{error}}</p>

        <label class="block">
          <span class="text-gray-700 text-sm" v-text="$t( 'Email' )"></span>
          <input
            type="email"
            class="form-input rounded-none mt-1 block w-full focus:border-cyan-600"
            v-model="email"
			tabindex="1"
          />
        </label>

        <label class="block mt-3">
          <span class="text-gray-700 text-sm" v-text="$t( 'Password' )"></span>
          <input
            type="password"
            class="form-input rounded-none mt-1 block w-full focus:border-cyan-600"
            v-model="password"
			tabindex="2"
          />
        </label>

        <div class="flex justify-between items-center mt-4">

          <div>
            <a
              class="block text-sm fontme text-theme hover:underline"
              href="#"
              >{{$t("Forgot your password?")}}</a
            >
          </div>
        </div>

        <div class="mt-6">
          <button
            type="submit"
            class="py-2 px-4 text-center bg-theme w-full text-white text-sm"
			tabindex="3"
          >
            {{ $t("Sign in") }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import authAPI from "../api/authentication";
import { mapState } from "vuex";

export default {
	name : "login",
	data(){
		return {
			email : "",
			password : "",
			isProcessing : false,
			errors : []
		}
	},
	computed : {
		...mapState({
			baseHref : ( state ) => state.globals.stachebox.baseHref,
			loginReferer: ( state ) => state.loginReferer
		})
	},
	methods:{
		login(){
			var self = this;
			self.isProcessing = true;
			this.$store.dispatch( "authenticate", { email: self.email, password: self.password } )
				.then( ( response ) => {
					let referer = { name : "Dashboard" };
					if( self.loginReferer ){
						referer = self.loginReferer.name ? { ...self.loginReferer } : self.loginReferer.fullPath;
						self.$store.commit( "removeFromState", "loginReferer" );
					}
					self.$router.push( referer );
				}  )
				.catch( ( err ) => {
					console.log( err );
					self.errors.splice( 0, self.errors.length );
					if( err.response ){
						err.response.data.messages.forEach( message => self.errors.push( message ) );
					}
				} )
				.finally( () => self.isProcessing = false )

		}
	},
	created(){
	}

}
</script>

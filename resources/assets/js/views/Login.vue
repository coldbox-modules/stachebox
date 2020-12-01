<template>
  <div class="flex justify-center items-center h-screen bg-gray-200 px-6">
    <div class="p-6 max-w-sm w-full bg-white shadow-md">
      <div class="flex justify-center items-center">
        <img :src="`${baseHref}/includes/images/stachebox-logo-h.png`" width="300px"/>
      </div>

      <form class="mt-4" @submit.prevent="login">

		<p v-for="(error, index) in errors" :key="`error-${index}`"  class="text-red-500 justify-center items-center">{{error}}</p>

        <label class="block">
          <span class="text-gray-700 text-sm">Email</span>
          <input
            type="email"
            class="form-input rounded-none mt-1 block w-full focus:border-teal-600"
            v-model="email"
			tabindex="1"
          />
        </label>

        <label class="block mt-3">
          <span class="text-gray-700 text-sm">Password</span>
          <input
            type="password"
            class="form-input rounded-none mt-1 block w-full focus:border-teal-600"
            v-model="password"
			tabindex="2"
          />
        </label>

        <div class="flex justify-between items-center mt-4">

          <div>
            <a
              class="block text-sm fontme text-theme hover:underline"
              href="#"
              >Forgot your password?</a
            >
          </div>
        </div>

        <div class="mt-6">
          <button
            type="submit"
            class="py-2 px-4 text-center bg-theme w-full text-white text-sm"
			tabindex="3"
          >
            Sign in
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import authAPI from "../api/authentication";

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
		baseHref(){ return this.$router.options.base }
	},
	methods:{
		login(){
			var self = this;
			self.isProcessing = true;
			this.$store.dispatch( "authenticate", { email: self.email, password: self.password } )
				.then( ( response ) => {
					self.$router.push( { name : "Dashboard" } );
				}  )
				.catch( ( {response, request, message} ) => {
					self.errors.splice( 0, self.errors.length );
					response.data.messages.forEach( message => self.errors.push( message ) );
				} )
				.finally( () => self.isProcessing = false )

		}
	},
	created(){
	}

}
</script>

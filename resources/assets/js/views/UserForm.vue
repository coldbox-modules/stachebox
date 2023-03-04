<template>
	<div class="user-form">
		<h1
			class="text-gray-500 text-3xl font-medium pb-2 border-gray-300 border-b"
			v-if="user"
		>
			{{ user && user.id ? $t( "Edit" ) : $t( "Create" ) }} {{ $t( "User" ) }}
		</h1>
		<form v-if="user" class="space-y-8 divide-y divide-gray-300">
			<div class="space-y-8 divide-y divide-gray-300">
				<div>
					<div class="pt-8">
						<div>
							<h2
								class="text-xl leading-6 font-medium uppercase text-gray-500 border-gray-500 border-b"
							>
								{{ $t( "Personal Information" ) }}
							</h2>
						</div>
						<div
							class="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6"
						>
							<div class="sm:col-span-4">
								<label
									for="firstName"
									class="block text-sm font-medium text-gray-700"
								>
									{{ $t( "First name" ) }}: <fa-icon size="xs" class="text-red-500" icon="asterisk"/>
								</label>
								<div class="mt-1">
									<input
										type="text"
										name="firstName"
										id="firstName"
										autocomplete="given-name"
										class="shadow-sm focus:ring-cyan-500 focus:border-cyan-500 block w-full sm:text-sm border-gray-300 rounded-none"
										@blur="v$.user.firstName.$touch"
										v-model="user.firstName"
									/>
									<form-errors :errors="v$.user.firstName.$errors" :fieldName="$t( 'First name' )"></form-errors>
								</div>
							</div>

							<div class="sm:col-span-4">
								<label
									for="lastName"
									class="block text-sm font-medium text-gray-700"
								>
									{{ $t( "Last name" ) }}: <fa-icon size="xs" class="text-red-500" icon="asterisk"/>
								</label>
								<div class="mt-1">
									<input
										type="text"
										name="lastName"
										id="lastName"
										autocomplete="family-name"
										class="shadow-sm focus:ring-cyan-500 focus:border-cyan-500 block w-full sm:text-sm border-gray-300 rounded-none"
										v-model="user.lastName"
										@blur="v$.user.lastName.$touch"
									/>
									<form-errors :errors="v$.user.lastName.$errors" :fieldName="$t( 'Last name' )"></form-errors>
								</div>
							</div>

							<div class="sm:col-span-4">
								<label
									for="email"
									class="block text-sm font-medium text-gray-700"
								>
									{{ $t( "Email address" ) }}: <fa-icon size="xs" class="text-red-500" icon="asterisk"/>
								</label>
								<div class="mt-1">
									<input
										id="email"
										name="email"
										type="email"
										autocomplete="email"
										class="shadow-sm focus:ring-cyan-500 focus:border-cyan-500 block w-full sm:text-sm border-gray-300 rounded-none"
										v-model="user.email"
										@blur="v$.user.email.$touch"
									/>
									<form-errors :errors="v$.user.email.$errors" :fieldName="$t( 'Email address' )"></form-errors>
								</div>
							</div>

							<div class="sm:col-span-4">
								<label
									for="lastName"
									class="block text-sm font-medium text-gray-700"
								>
									{{ $t( "Title" ) }}
								</label>
								<div class="mt-1">
									<input
										type="text"
										name="title"
										id="title"
										class="shadow-sm focus:ring-cyan-500 focus:border-cyan-500 block w-full sm:text-sm border-gray-300 rounded-none"
										v-model="user.title"
									/>
								</div>
							</div>

							<div class="sm:col-span-4 items-center" v-if="hasPermission( 'Administer:Users' )">
								<toggle-switch :isActive="user.allowLogin" @toggle="toggleLogin"></toggle-switch>
								<span class="ml-3">
									<span class="text-sm font-medium text-gray-900" v-tooltip="$t( 'allowLogin.tooltip' )">{{ $t( "Allow Login" ) }}</span>
								</span>
							</div>

							<div class="sm:col-span-4 items-center" v-if="hasPermission( 'Administer:Users' )">
								<toggle-switch :isActive="user.isAdministrator" @toggle="toggleAdmin"></toggle-switch>
								<span class="ml-3">
									<span class="text-sm font-medium text-gray-900">{{ $t( "User is Administrator" ) }}</span>
								</span>
							</div>
						</div>
					</div>
					<div class="mt-10">
						<h2
							class="text-xl leading-6 font-medium uppercase text-gray-500 border-gray-500 border-b"
						>
							{{ $t( "Avatar" ) }}
						</h2>
					</div>
					<div
						class="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6"
					>

						<div class="sm:col-span-6">
							<div class="mt-2 flex items-center">
								<div class="relative z-10 block h-200 w-200 rounded-full overflow-hidden shadow">
									<img
										class="h-full w-full object-cover"
										:src="user.avatar"
										:alt="$t( 'Your avatar' )"
									/>
								</div>
								<button
									type="button"
									class="ml-5 bg-white py-2 px-3 border border-gray-300 rounded-none shadow-sm text-sm leading-4 font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-cyan-500"
									@click="showFileSelect"
								>
									{{ $t( "Change" ) }}
								</button>

								<input
									id="avatar-input"
									name="avatar-input"
									type="file"
									class="sr-only"
									@change="updateAvatar"
								/>

								<input type="hidden" name="avatar" v-model="user.avatar">
							</div>
						</div>
					</div>
					<div class="mt-10">
						<h2
							v-if="user.id"
							class="text-xl leading-6 font-medium uppercase text-gray-500 border-gray-500 border-b"
						>
							{{ $t( "Change Password" ) }}
						</h2>
						<div
							class="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6"
						>
							<div class="sm:col-span-4">
								<label
									for="password"
									class="block text-sm font-medium text-gray-700"
								>
									{{ $t( "Password" ) }}: <fa-icon v-if="!user.id" size="xs" class="text-red-500" icon="asterisk"/>
								</label>
								<div class="mt-1">
									<input
										type="password"
										autocomplete="never-complete"
										name="password"
										id="password"
										class="shadow-sm focus:ring-cyan-500 focus:border-cyan-500 block w-full sm:text-sm border-gray-300 rounded-none"
										v-model="user.password"
										@change="v$.user.password.$touch"
									/>
								</div>
							</div>
						</div>
						<div
							class="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6"
						>
							<div class="sm:col-span-4">
								<label
									for="confirmPassword"
									class="block text-sm font-medium text-gray-700"
								>
									{{ $t( "Verify Password" ) }}: <fa-icon v-if="!user.id" size="xs" class="text-red-500" icon="asterisk"/>
								</label>
								<div class="mt-1">
									<input
										type="password"
										autocomplete="never-complete"
										name="confirmPassword"
										id="confirmPassword"
										class="shadow-sm focus:ring-cyan-500 focus:border-cyan-500 block w-full sm:text-sm border-gray-300 rounded-none"
										v-model="user.confirmPassword"
										@change="v$.user.confirmPassword.$touch"
									/>
								</div>
								<form-errors :errors="v$.user.confirmPassword.$errors" :fieldName="$t( 'Password confirmation' )"></form-errors>
							</div>
						</div>
					</div>
				</div>
			</div>

			<div class="pt-5">
				<div class="rounded-md bg-green-50 p-4 mb-5 fade-slow" v-if="saveSuccess">
					<div class="flex">
						<div class="flex-shrink-0">
							<fa-icon class="h-5 w-5 text-green-400" icon="check-circle"/>
						</div>
						<div class="ml-3">
							<p class="text-sm font-medium text-green-800">
								{{ $t( "Profile successfully saved" ) }}
							</p>
						</div>
						<div class="ml-auto pl-3">
							<div class="-mx-1.5 -my-1.5">
								<button type="button" @click="saveSuccess=false" class="inline-flex bg-green-50 rounded-md p-1.5 text-green-500 hover:bg-green-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-green-50 focus:ring-green-600">
									<span class="sr-only">{{ $t( "Dismiss" ) }}</span>
									<fa-icon class="h5 w5" icon="times"/>
								</button>
							</div>
						</div>
					</div>
				</div>
				<div class="flex justify-end">
					<button
						type="button"
						class="bg-white py-2 px-4 border border-gray-300 rounded-none shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-cyan-500"
						@click="$router.push( { name : 'Directory' } )"
					>
						<fa-icon class="mr-5" icon="undo"/>
						{{ $t( "Cancel" ) }}
					</button>
					<button
						type="button"
						class="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-none text-white bg-cyan-600 hover:bg-cyan-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-cyan-500 disabled:opacity-50"
						:class="{'cursor-not-allowed' : !isValid }"
						@click="saveUser"
						:disabled="!isValid || null"
					>
						<fa-icon class="mr-5" v-if="isSaving" icon="spinner" spin/>
						<fa-icon v-else  class="mr-5" icon="save"/>
						{{ $t( "Save" ) }}
					</button>
					<button
						v-if="hasPermission( 'Administer:Users' ) && user.id && user.id != authUser.id"
						type="button"
						class="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-none text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-cyan-500 disabled:opacity-50"
						@click="confirmDeleteUser"
					>
						<fa-icon class="mr-5" v-if="isSaving" icon="spinner" spin/>
						<fa-icon v-else  class="mr-5" icon="trash"/>
						{{ $t( "Delete User" ) }}
					</button>
				</div>
			</div>
		</form>
		<div v-else class="mt-4 text-center items-center">
			<fa-icon size="3x" class="text-gray-400" icon="circle-notch" spin fixed-width />
			<p class="mt-4 text-gray-400">{{ $t( "Loading User Data" ) }}...</p>
		</div>
		<dialog></dialog>
	</div>
</template>
<script>
import usersAPI from "@/api/users";
const canvasProcessor = require( "canvas_image_processing" );
import Dialog from "@/components/Dialog";
import ToggleSwitch from "@/components/ToggleSwitch";
import FormErrors from "@/components/util/FormErrors";
import useVuelidate from "@vuelidate/core";
import { required, email, requiredIf, sameAs, helpers } from "@vuelidate/validators";
import { mapState,mapGetters } from "vuex";
export default {
	components : {
		Dialog,
		ToggleSwitch,
		FormErrors
	},
	setup(){
        return {
            v$ : useVuelidate()
        };
    },
    validations(){
        return {
            "user" : {
                "firstName" : { required },
                "lastName" : { required },
                "email" : { required, email },
				"password" : { "requireIfNew" : requiredIf( this.isExistingUser ) },
                "confirmPassword" : { requiredIfSetting : helpers.withMessage('This field is required', requiredIf( this.user && this.user.password )), sameAsPassword: helpers.withMessage('The passwords must match', sameAs( this.user ? this.user.password : "" ) ), $lazy: true }
            }
        };
    },
	data(){
		return {
			user : null,
			isSaving : false,
			saveSuccess : false,
			validation : {
				errors : []
			}
		};
	},
	computed : {
		...mapState({
			authToken : state => state.authToken,
			authUser: state => state.authUser
		}),
		...mapGetters({
			hasPermission : "hasPermission"
		}),
		isPasswordVerified(){
			return this.user.password === this.user.confirmPassword;
		},
		isExistingUser(){
			return !( this.user && this.user.id );
		},
		isValid(){
			return this.isPasswordVerified && !this.v$.$invalid
		}
	},
	methods : {
		toggleAdmin(){
			this.user.isAdministrator = !this.user.isAdministrator
		},
		toggleLogin(){
			this.user.allowLogin = !this.user.allowLogin
		},
		fetchUser(){
			usersAPI.fetch( this.$route.params.id, {}, this.authToken ).then( result => this.user = result.data )
		},
		saveUser(){
			var self = this;
			this.isSaving = true;
			let saveAction;
			if( this.user.id ){
				saveAction = usersAPI.update;
			} else {
				saveAction = usersAPI.create;
			}
			saveAction( this.user, this.authToken )
				.then(
					result => {
						if( self.user.id ){
							self.user = result.data
							self.saveSuccess = true;
							setTimeout(() => {
								self.saveSuccess = false;
							}, 6000);
						} else {
							self.$router.push( `/users/edit/${result.data.id}` )
						}
					}
				).finally( () => {
					self.isSaving = false;
				} )
		},
		confirmDeleteUser(){

		},
		updateAvatar( event ){
			var self = this;
			let getImageDimensions =  ( file ) => new Promise (function (resolved, rejected) {
					var i = new Image()
					i.onload = function(){
						resolved({w: i.width, h: i.height})
					};
					i.src = file
				} );

			if (event.target.files[0]) {
				const file = event.target.files[0];
				const reader = new FileReader();
				var dimensions;
				reader.onload = function(e) {
					let base64_image = e.target.result;

					var i = new Image();

					i.onload = function(){
						dimensions = {
							"width" : i.width,
							"height" : i.height
						}

						var maxWidth = 200;
						var maxHeight = 200;
						var ratio = 0;
						var width = dimensions.width;
						var height = dimensions.height;
						var newWidth = width;
						var newHeight = height;

						// Check if the current width is larger than the max
						if(width > maxWidth){
							ratio = maxWidth / width;   // get ratio for scaling image
							newHeight = height * ratio;    // Reset height to match scaled image
							newWidth = width * ratio;    // Reset width to match scaled image
						}

						// Check if current height is larger than max
						if(height > maxHeight){
							ratio = maxHeight / height; // get ratio for scaling image
							newWidth = width * ratio;    // Reset width to match scaled image
							newHeight = height * ratio;    // Reset height to match scaled image
						}

						canvasProcessor.resizeImage64(base64_image, newWidth, newHeight).then(
							( resized_image ) => canvasProcessor.cropImage64( resized_image, 0, 0, 200, 200)
																.then( cropped_image => {
																	self.user.avatar = cropped_image;
																})
						);


					};

					i.src = base64_image;

				};

				reader.readAsDataURL(file);
			}
		},
		showFileSelect( event ){
			document.getElementById( 'avatar-input' ).click();
		}
	},
	mounted(){
		if( this.$route.params && this.$route.params.id ){
			this.user = null;
			this.fetchUser();
		} else {
			this.user = {
				"isAdministrator": false,
				"isActive": true,
				"allowLogin" : true,
				"lastName": "",
				"avatar": "data:image/jpeg;base64,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",
				"firstName": "",
				"middleName": "",
				"title": "",
				"email": ""
			}
		}
	}

};
</script>

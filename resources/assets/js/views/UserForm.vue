<template>
	<div class="user-form">
		<h3
			class="text-gray-500 text-xl font-medium pb-2 border-gray-300 border-b"
			v-if="user"
		>
			{{ user.id ? "Edit" : "Create" }} User
		</h3>
		<form v-if="user" class="space-y-8 divide-y divide-gray-200">
			<div class="space-y-8 divide-y divide-gray-200">
				<div>
					<div class="pt-8">
						<div>
							<h3
								class="text-lg leading-6 font-medium uppercase text-gray-500 border-gray-500 border-b"
							>
								Personal Information
							</h3>
						</div>
						<div
							class="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6"
						>
							<div class="sm:col-span-4">
								<label
									for="firstName"
									class="block text-sm font-medium text-gray-700"
								>
									First name
								</label>
								<div class="mt-1">
									<input
										type="text"
										name="firstName"
										id="firstName"
										autocomplete="given-name"
										class="shadow-sm focus:ring-cyan-500 focus:border-cyan-500 block w-full sm:text-sm border-gray-300 rounded-none"
										v-model="user.firstName"
									/>
								</div>
							</div>

							<div class="sm:col-span-4">
								<label
									for="lastName"
									class="block text-sm font-medium text-gray-700"
								>
									Last name
								</label>
								<div class="mt-1">
									<input
										type="text"
										name="lastName"
										id="lastName"
										autocomplete="family-name"
										class="shadow-sm focus:ring-cyan-500 focus:border-cyan-500 block w-full sm:text-sm border-gray-300 rounded-none"
										v-model="user.lastName"
									/>
								</div>
							</div>

							<div class="sm:col-span-4">
								<label
									for="email"
									class="block text-sm font-medium text-gray-700"
								>
									Email address
								</label>
								<div class="mt-1">
									<input
										id="email"
										name="email"
										type="email"
										autocomplete="email"
										class="shadow-sm focus:ring-cyan-500 focus:border-cyan-500 block w-full sm:text-sm border-gray-300 rounded-none"
										v-model="user.email"
									/>
								</div>
							</div>

							<div class="sm:col-span-4">
								<label
									for="lastName"
									class="block text-sm font-medium text-gray-700"
								>
									Title
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
						</div>
					</div>
					<div class="mt-10">
						<h3
							class="text-lg leading-6 font-medium uppercase text-gray-500 border-gray-500 border-b"
						>
							Avatar
						</h3>
					</div>
					<div
						class="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6"
					>

						<div class="sm:col-span-6">
							<div class="mt-2 flex items-center">
								<button
								@click="dropdownOpen = !dropdownOpen"
								class="relative z-10 block h-200 w-200 rounded-full overflow-hidden shadow focus:outline-none"
								>
									<img
										class="h-full w-full object-cover"
										:src="user.avatar"
										alt="Your avatar"
									/>
								</button>
								<button
									type="button"
									class="ml-5 bg-white py-2 px-3 border border-gray-300 rounded-none shadow-sm text-sm leading-4 font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-cyan-500"
									@click="showFileSelect"
								>
									Change
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
						<h3
							class="text-lg leading-6 font-medium uppercase text-gray-500 border-gray-500 border-b"
						>
							Change Password
						</h3>
						<div
							class="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6"
						>
							<div class="sm:col-span-4">
								<label
									for="firstName"
									class="block text-sm font-medium text-gray-700"
								>
									Password
								</label>
								<div class="mt-1">
									<input
										type="password"
										autocomplete="never-complete"
										name="firstName"
										id="firstName"
										class="shadow-sm focus:ring-cyan-500 focus:border-cyan-500 block w-full sm:text-sm border-gray-300 rounded-none"
										v-model="user.password"
										@change="validatePassword"
									/>
								</div>
							</div>
						</div>
						<div
							class="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6"
						>
							<div class="sm:col-span-4">
								<label
									for="firstName"
									class="block text-sm font-medium text-gray-700"
								>
									Verify Password
								</label>
								<div class="mt-1">
									<input
										type="password"
										autocomplete="never-complete"
										name="firstName"
										id="firstName"
										class="shadow-sm focus:ring-cyan-500 focus:border-cyan-500 block w-full sm:text-sm border-gray-300 rounded-none"
										v-model="user.confirmPassword"
										@change="validatePassword"
									/>
								</div>
								<div v-if="!isPasswordVerified && validation.errors.length" class="rounded-md bg-red-50 p-4">
									<div class="flex">
										<div class="flex-shrink-0">
											<fa-icon icon="times-circle" class="h-5 w-5 text-red-400"/>
										</div>
										<div class="ml-3">
											<h3 class="text-sm font-medium text-red-800">
												This form has errors and cannot be saved
											</h3>
											<div class="mt-2 text-sm text-red-700">
												<ul class="list-disc pl-5 space-y-1">
													<li v-for="error in validation.errors">
														{{ error }}
													</li>
												</ul>
											</div>
										</div>
									</div>
								</div>
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
								Profile successfully saved!
							</p>
						</div>
						<div class="ml-auto pl-3">
							<div class="-mx-1.5 -my-1.5">
								<button type="button" @click="saveSuccess=false" class="inline-flex bg-green-50 rounded-md p-1.5 text-green-500 hover:bg-green-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-green-50 focus:ring-green-600">
									<span class="sr-only">Dismiss</span>
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
						Cancel
					</button>
					<button
						type="button"
						class="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-none text-white bg-cyan-600 hover:bg-cyan-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-cyan-500"
						:class="{'cursor-not-allowed' : !isValid }"
						@click="saveUser"
						:disabled="!isValid"
					>
						<fa-icon class="mr-5" v-if="isSaving" icon="spinner" spin/>
						<fa-icon v-else  class="mr-5" icon="save"/>
						Save
					</button>
				</div>
			</div>
		</form>
		<div v-else class="mt-4 text-center items-center">
			<fa-icon size="3x" class="text-gray-400" icon="circle-notch" spin fixed-width />
			<p class="mt-4 text-gray-400">Loading User Data...</p>
		</div>
	</div>
</template>
<script>
import usersAPI from "@/api/users";
const canvasProcessor = require( "canvas_image_processing" );
import { mapState } from "vuex";
export default {
	data(){
		return {
			user : {},
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
		isPasswordVerified(){
			return this.user.password === this.user.confirmPassword;
		},
		isValid(){
			return this.isPasswordVerified
		}
	},
	methods : {
		fetchUser(){
			usersAPI.fetch( this.$route.params.id, {}, this.authToken ).then( result => this.$set( this, "user", result.data ) )
		},
		saveUser(){
			var self = this;
			this.isSaving = true
			usersAPI.update( this.user, this.authToken )
				.then(
					result => {
						self.$set( self, "user", result.data )
						self.saveSuccess = true;
						setTimeout(() => {
							self.saveSuccess = false;
						}, 6000);
					}
				).finally( () => {
					self.isSaving = false;
				} )
		},
		validatePassword(){
			if( this.validation.errors.length ){
				this.validation.errors.splice( 0, this.validation.errors.length );
			}
			if( this.user.password.length && (!this.user.confirmPassword || !this.user.confirmPassword.length ) ) return;
			if( this.user.password !== this.user.confirmPassword ){
				this.validation.errors.push( "The two passwords do not match.  Please re-confirm your new password.");
			}
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
																	self.$set( self.user, "avatar", cropped_image );
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
			this.$set( this, "user", null )
			this.fetchUser();
		}
	}

};
</script>

<template>
	<div class="user-form">
		<h3
			class="text-gray-500 text-xl font-medium pb-2 border-gray-300 border-b"
			v-if="user"
		>
			{{ user.id ? "Edit" : "Create" }} User
		</h3>
		<form v-if="user" class="space-y-8 divide-y divide-gray-300">
			<div class="space-y-8 divide-y divide-gray-300">
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

							<div class="sm:col-span-4 items-center">
								<button
									type="button"
									:aria-pressed="user.isAdministrator"
									@click="user.isAdministrator = !user.isAdministrator"
									aria-labelledby="toggleLabel"
									class="bg-gray-200 relative inline-flex flex-shrink-0 h-6 w-11 border-2 border-transparent rounded-full cursor-pointer transition-colors ease-in-out duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-cyan-500"
									:class="user.isAdministrator ? 'bg-cyan-600' : 'bg-gray-200'"
								>
									<!-- On: "bg-cyan-600", Off: "bg-gray-200" -->
									<span class="sr-only">Use setting</span>
									<!-- On: "translate-x-5", Off: "translate-x-0" -->
									<span
										aria-hidden="true"
										class="translate-x-0 inline-block h-5 w-5 rounded-full bg-white shadow transform ring-0 transition ease-in-out duration-200"
										:class="user.isAdministrator ? 'translate-x-5' : 'translate-x-0'"
									></span>
								</button>
								<span class="ml-3" id="toggleLabel">
									<span class="text-sm font-medium text-gray-900">User is Administrator</span>
								</span>
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
					<button
						v-if="hasPermission( 'Administer:Users' ) && user.id != authUser.id"
						type="button"
						class="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-none text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-cyan-500"
						:class="{'cursor-not-allowed' : !isValid }"
						@click="confirmDeleteUser"
					>
						<fa-icon class="mr-5" v-if="isSaving" icon="spinner" spin/>
						<fa-icon v-else  class="mr-5" icon="save"/>
						Delete User
					</button>
				</div>
			</div>
		</form>
		<div v-else class="mt-4 text-center items-center">
			<fa-icon size="3x" class="text-gray-400" icon="circle-notch" spin fixed-width />
			<p class="mt-4 text-gray-400">Loading User Data...</p>
		</div>
		<dialog></dialog>
	</div>
</template>
<script>
import usersAPI from "@/api/users";
const canvasProcessor = require( "canvas_image_processing" );
import Dialog from "@/components/Dialog";
import { mapState,mapGetters } from "vuex";
export default {
	components : {
		Dialog
	},
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
		...mapGetters({
			hasPermission : "hasPermission"
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
							self.$set( self, "user", result.data )
							self.saveSuccess = true;
							setTimeout(() => {
								self.saveSuccess = false;
							}, 6000);
						} else {
							self.$router.push( `/users/edit/${result.id}` )
						}
					}
				).finally( () => {
					self.isSaving = false;
				} )
		},
		confirmDeleteUser(){

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
		} else {
			this.user = {
				"isAdministrator": false,
				"isActive": true,
				"lastName": "",
				"avatar": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQEw8QEBD/2wBDAQMDAwQDBAgEBAgQCwkLEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBD/wAARCADIAMgDASIAAhEBAxEB/8QAHQAAAAYDAQAAAAAAAAAAAAAAAAECBgcIAwQFCf/EAD8QAAEDAwIEBQMCBAQEBgMAAAECAwQABREGIQcSMUEIEyJRYTJxgRSRFSNCoVJiscEWJNHwCRcYM3LxU4Lh/8QAGwEAAQUBAQAAAAAAAAAAAAAABgABAgQFAwf/xAA2EQABBAECBAMGBgIBBQAAAAABAAIDEQQFIRIxQVETYXEGIjKBkdEUobHB4fAHIxUWJDQ18f/aAAwDAQACEQMRAD8A85nUqJUnuPc+1IhsKlymIrf1PupbT9ycD/WspUFuocCBlaQB7EgYNben7Vcrpqa2Wi1Ri9NlzWWYyEj6nFLASP3qLzTSVJotwVwNUawk6QZiadhNwv0lubaEdDw5m1OKz/N5U9UNpW2kA7ZSB0JyxbRD1FqW4vWZuO9IfeeLkkkFS1kbkHHVRJ+9MuOm66i1Y1YocGRMlzpQhNxwC4txHNjy0pxkYPT25c/NWma4o8GfC/aV2W8TkX/WJRiXDtCkqEZX0ltbxylKwAAs5Jz0SBQg7EdAKibxOP8AbRIMlsgJcaAXR0VwBi25UabrGU4pbQUEW6KshZPstwY5cb7D1HA3Tg5mW2accgWxq3Wu1x7fAYJUG04Q2jJyST75wSTudz33o5rfxycSr1KdRoq3W3TcTmV5Sm2g/ICSdsuOZGfskdahTUvELX2tpX6rVWrLrc1bhIkyluJQCSSEgnAG/QCucei5WQLndXkuL85g2YLXpbqbizwg0AFo1jr+zodQFKTFiOF90qHVJDYPKc/4uUb9t6hC7+Jh/jhqWDws4ZxjZbXcXFMzbnKOHDFAyvpsnKQfT3OBk5qkDjSlOAHKif3qyvBS3Q+H1jGpFwUybrcyGYzf9acHPp777Z9sVPNwINPg4ubjsPX+FpaHFLqOSGjZrdyV6V8NrDa7Tb7dZLbHZEG2RkttNjfGw9XyTuSfc5qSmlttp5UpAHsBVMuDvETV1zvrDCZEqSp5JSEx3EyWm1ZwUKcQSBgg9dv9atNYpd2ShIuDCkkjKgTvVPSc0NuMtIN8+is65pboJOIvBsWnK9LbHXNMfiZw6tHFGxG0XNxUd9lwPxJbacrZWPjuCMj807eT9RuAAeuDS0p8tOFA/tWzKPH914sFYuJkSYMrZoHU9psHso20Vou6Wi03DTGqbpHujKeaOyl1GVGOoEYJPuMbfFVp1tpeXoXVc7Tzp9CFc8ZeMc7St0/nsfnNXYnNqeZ52UJU6gZCVbc/xmo3vuh7PxgtM5cu0yLRdre4qPElvIIUhYHQj+tGf+oO9DHtBow1CARQ/G3lfUdRf6Ir03WniZ+TP8Lquq2Peu3dQRBLzobCWlrLiQAAPeuqph5laPObKef6fkjP3rl3Ti3ozRWrhwc1tapujr22y7AiammwUPwluOnDT62gtKnGuwUFgdebG+G/L8L/AI62NTyIdq4u6blWOaoumRyJbjhPMCB5BQVIIGCAnI2Pq9x7F/xucrEdK+bhk6NqxXmbtQzfag4+UGNZbOpvf5DlVJ8JSrmCSk5AwQO1ZkAk45SOXcYA2qsXig8PfiL4VWj/AMwtY8Vm71BhKbQ0m3qdjpbUpYHMEbAEHlOeu/xVe4PGji8ytDkbiJqE+XjCXJzjjYwMDKVEpxjbpU4/8V5EjA7x231FH9bXF/tdAx1Fhr5K5niH0Lp6Zwj1ddYOmLcLmiIZipjcVCX8oUFrVzgZ+kKz7150OFRWQpSjv3NTx/6juK0rT03TV7vES4wbjDehPpkRgVlt1JSo8ycHOCcGonesEGQpTjU1SM/0lPN/evQfZD2fztDx34+W4Ot1tIJO1AdapDGualBqMrZYbG1G03TjtRAjPTFOBGl2FEc05wnONm8f71nOj44QlSrgcqGcBIPX80Y/h3HkFhcQTXB7dqOnCvSjIHonkHP9TZrANOLSlSi6VBP+FOSf9KiYXN5hLiC4eDQreciBtXKtJB9iKFRvyTrovXK2JaYRFgqBY+kFeUg5zncZP2zUh+HG92Cy8T27/qBDSlW62zpFvQsZCpvkKS3tg7jmURtsQD1FRMAdjjrXV02hxF6iSUOlv9MoyVKCsHkbSVqwfchJA+SKrTM44nNvmFOF3BICpS1BrOXwqjSGNO3Ao1Ve2FJmTm1ALt8VzcNNEfS6tJytecpCgkcqueoe81+W4p990rWokkk96O5z5NymPzpTpW484VqUTnJJzQjY5RXOGERN359V2dJxu8lssNlRCex6/Ndu027zV7t5x8Vo26MX3AlI71I2mdPreCYsdhS3X8JGQck/H/faqebkiFvNbelae7MkAATYt+mnpt5QAOVvzAo43GAc077tdb09cf0NqbW6mHHUtTSFEJXkjIIG5B2BA6gH3qXtIeHXWdyssy8RojWIbJdWhbmVYAJOB0zjfrvTT0/obV9ivzGq0pUwASPLbHmOuA5SBgdAc75rAdqUU7uJxB4RtfUozg0OWCPwYiQ5xHFXQdLVjvCz4gNTDRs+Xrm326BDtv8AylpSzEbiuLbyTghICVE4SBgAek+9Wl0hrUXyImfNeDYWeVCBg7e+e/8Ab7VSLTmmb9dH4796SIzTJ52Y47kkZUoDOSPb8VO2l7wmyWRcV1SvRukjbBwAKHptVe3IL2/D26LUyPZuJuK1oJL+RJ5n7Ky6Z7IaK0yUgkZHqrnNawhiWYrzwyB1JG9QvbeI3lscj0gr225uuPeu/YJ0e6Ey8KSoq/q77dq6v1uR/CYxSHZfZ84wc6XkpgMtl1IcbWMEbYpcd9Cjuds0y4U9URvZfmIPVOdxXZ/iCW0pcC/SqtfH1Bsw4jseqxJMMs2CaXH7w4cO/EHYWIWrLfy3C3hRgXBpRS6znqkkEcyDgek7Z3G9Ozg7/F4OgLPZL4ornWdn+GPrJz5hYJbC85OchIP5rt2+el5kY+9N1F6u+nNV3GI7alPWeUhqWzJb3KXVZS42QcYA5ArOf68Y2314pwx7ZL907LOlYTG6NwFjcd/S0jj7Y9M3zgvrWJqkMpt6bJMdW66AQyUMqUlYJBwQQD+K8KzKfIHMcfAr1G/8SXi5KsfAiPpG1+ZHVq66IiPKCsKMVkB1Y27KUlAO/TIPWvLZgjmDisnFEeOQ4cQ6rFmsUCtxr9Q5gqQDnbr1rY/UGKg+e402T0BRk1pP3D9M2Ag/zT1PsK1YrRkr86S4cHcD3q5xVsFXortNXHzCUshxYJ3JAAFZTIc7LwT9q1jIYYTyYwE/0g7UkSHHDyobCRnp3Ndw6uZSWyZMgHClJWn/AF/NGmUFjl3BPbetVa1pGCN6wqUCDgHB/FMXUkt2Qlp8ALSNx1HahWml1Z2Ud096FcXblJYo9vLzYCEZOAetdlm3oh2ac+toeY9Fw2SM4HmJyR+EkfmuXbr2m3sFtCkha0FCjjOd8j/pRNXdx1P6UBxxKk8memAdjtVF24XRporhrOxGa2IayRynYDrWN5strUgg+k4O1Y0LU2sFIyfakRYUwaKcVvnmKpKWcc2epPSps4damh2CAm5LjrWVAAqV/ttt1O1RLoS1QJ92S7NaU800OdTQOOb4/epJioD+nLvrOfalvw7bNYt7MNhJLTHOCVuqSMc5CUgJBIHMsZ22OFqEbJ3eEf7fRFuiZEmG05IPeh6cyrQcCPEVpyXMcseFJ5ifNiujBUMdRjY/IFWDmcHdMavU3eIiJFoMjC1oZxg9/pOyaoBoNTZYst/RYINtubxLyRHbKS62leUc4JI3x0GMjrV+OCPE1vV9qT5ykodCRkE9SNlD4OaFX48EWT4ThbeXofVGj5ct2IM6P3X9SOoPKweqPVnCy1absiJFkRMkvx05U2Ul1bo77AbfioX1Hrxq2yXbQmy3N2RGILjSoykK3GRsdx0q1upNU2PSdjn6qvlwQxBt8dch7IyoIQkqVgd9hVfrHrDUXGi4wdayLBG0sy4HExosreY/E5wEOOJH0bhXKCc9T0wTw1DT4mf7IvLZWND1OaUFuSLABPET17clFVw4lzITyTK05cWmlL9KFMY2A6bb1JXD7izpye01bpav0bowORbamsnP+bfPxUrI0JoNEVyXqJAdDSMuuvOeW2kdzsRj8mqg8XOMPBzSmtTZ7LfBcIql5U43GK2459ubGVAbbjfaqA0+WQAxNs9hv9Qrk2qYWWC2a2tHU7C/Iq3y35sZpEyEv9VHUMhQ9R5acmnLszd2fKLmD0GT0NV94dcQ3bIzFcclGbapjKXmVJUFJUhYykg/YjFSywqHI5dSaakpU0BzSWEq3G3XHY96qY8r4JL7c2/b7LEzcEs26Hk4cj6qSYinLa4Wl5KVYKTW3MuMRLTi5S0paDKi4tR2SBuc/uT+K4tku8fUFuDSVp80Jyg9Ki7j9r9GjNISVSFutrlRZkQcpwAvyFLGTg9kmi/CyQeEM3aeX2Qnl45cHcWzhzVDPHHxWf4icR7bZY0km1WKDzx2jn0uyFc6ic/5A0Pfaq7EiOxzq6npW/e7m5fb9NvMh0q85wqyrryjZI+2AK4kyQX3DjIHYe1HsDBHGAhCV3iPJRJy+4SrGAcmt8v/AKdA6c/YewrTYHlp5iNh0+TRtFTrhUo5JNdQVzO622AXFeY4T171tLlBCAE7bda1Xn0sAJTuo9fitUOqX9u5qXFSarW/5iFn1KOcbmgVJGckAe9aaXPbJNIWtROFKzS4ylS3StnOEu5I+M0K0gSO+1ClxlLZZ2oYIAT5X3KhWf8ASFIBLjX4WDWWy2e43uYi322Ot55w4SlKSSf2FSxD4IxbEyzP19fI1nS8eZEd4KcklG/q/To/mfYr8tJIxkVmzZcUHxHft1+isxY0s590bd1D06K65/zKCFgABZSDgH52708eF3BbV3EoyJ1raYi2uGoIkXGY+liO0T/nWQCRjcJyRttU2WSbo63sJhaH00J7iW2y5IvLKHByHbmTHT6EnIO6+YjGfktDirIvrt7hsvvhENsGPGhMHDTSEpQUkNJwkHlWnJA3IPvWOdVfO8xRjhPc/ZbLdKETBLIbHYfdbmn9EcKtGPzmGNW3HU99bYUGW7QlLURpzcep50HzU7D6E4+TXQszNytKnnWn3IjMockuMlOeYgZwU9D1xv0zTXiWVGmZ6LlKdYkB9AcaYQoF0qBOR5YypX7V27jxCi2q6IffgltLzaA+06sF3/5JQnIScY2UQcdt6zJvFkd7pLrHM10RDpssGM3/AG00A8u3mpE0HbZV21O7fZLCmWo7XlxUL9WEb4ye59z/ANKlzTLszR8mPdY77bceSHStvJT7kf3zTD0LdId3gC4WeV50daU7AYU2fZYzkH708NUBMzTv8pwnLHlEJykgjYEY/NDOTI4ykPFV+S9MxhE6ABjgWu697TM1h4mnJ19kNOocmwoYUy7EWhYCzuCAo7du3uKy8IuKuoblLmatugS1HfkkeWFEeU0gghCScbAEjf4phNaQt9+jrafdUzPb5gHF5KVj5z3wNq1LjJjadegaAcuSGWZCQuW6HPLCkqJJRn3/ANvar5ijkZwRA8XU8+XVUBK7GeXT0I6IobAkkVam7WGr5nE2x37VuoJMm16E0/Edkxjt5c59AwltQ3KgVenm91YHsaS3AT+LGtnbmizwLWZxTiHAQUMMIQkDCEqJPbPXqT0p/cXOLtt1FaIvC7h9OljTsRQXJJcIRIWk5SgD+pAI5t9irB/pBPe4M6Xg2m0yb/d3WY61lBjOY/mDl5vpyRsSRv25RuK19Ojfp8DppRTnHYdQPPzKF2Yx9pNRbjRn/U3c1y8/XsrAeHvQ1wvnC1u2SJB/ienJki2NodBBWhGFBKiRsUhzl36YxT605cbzoy+qhPFxoN5D0fH198/Ix3FavBxDei9N26ZdnBFfu8+TO8hX1BlbbaULUDuMhII9xg08tV3zTV+DE62zWV3GL9CkLByn/Cod/tQtqMTDI6Zpp13XqiZ8Lsd34Th4o+QPatufZdaNd0Wi5RrlF5hbrmSWuZWPKf6lGO2cZH5FRD46tSRXODzs1rlD/wCqaSMJyQtSVoJHsCFj/s1MirWi96DfQ2pCHnmedpJOOV1PqScjcbgdO1UV8ZuvTd7Hp+zNO+l579W4gjB50oKT/dXT4HtWj7PxuOSxnQ7oR1hkYxJZuTm7et7BVXkOpS2G0/mtVpHOvb3pLiiskmszKQ22Vkdeleojla8y5I3l5wgdE7Cs7ShGaDgwFKG3xWq0At0A9B1o3Vl1wjflFIFRpK5itXMo4FLSnm6DCaQlIUcbhIpTrn9CfpFMNkkFLH0pxjtQCcd/mkIG9KpG+qSUQQN6FAdelCkmoKb2eMFw0xHSxomx2zTrEd3zAYbRW7IPTDr68uKT/lBCT7Ds27VdEypMuTf5jst6SQ8p9SytTi1dSok5O+OvzRyNI3luU+xd2W7WyVLx+pSpLhHMr6Gsc53SQMgD5FalofskK6sxv0JnMIeSlTk7YAE45w0lWMjOcKKxWA2OMtPBz6n+Vu8cgcOLYdP/AIura50tEoPWhDikFxLfmJXhHOo7JKzgZO+BnPUYqR7ppqO/pi2X66X8SFvRXS8zCXuSVuKCQ4vc+lIyAkdBgkCoVu8mVPUqa7NW85Hd5EoxhIR1BSB6Up6bD9qcFq1JdJOnY+n2GS9IbUryWWEqU44FKUcqHQYzt02x161Ty8Rx4ZGGqO/pXdXcPKY0uZICRW3rstGTdZCfNi29aoiQ8EBDGyyPZbn1L7fUcDsBS9a3dcnUK3JrJSpz1AJT1J+B1yfvUveHvwicQuP13luMz2LFare6EzJj7KnORwD/ANpAxyqWNsjOwIOe1egXDXwOcEtDtNzL/Zk6svSQ3m4XJAyCjoUtpwnr3OSdqtxMDiHRi/P6fVUJpi0FrzXkoO8IXhsVaNCu6m17HlR7xqJoKahOpU2qKwCS2VI7LOeYhQ22GBg5VxT4cXrSE5xuMtMuEPWVNnHLnGyk9R3/AGq9H8KitRBFitIZQlIQkISAAB0G1MS/aN/irhQ/b2JSE5BKsZT8g9qxNU0p7z4oHvH+0tnRdekwnUD7g6FefL1rU2ovIR5bgyrmT2B9xTT1nwRuOt0qeQ6y4G8qC0rAcR8YPUZ/771b7jF4aL5K02q8cILkkXuGn+bbLgeZmYO/KsYKF46b8p6Ed6o/qTiprjh/eE2nXWkpdsnAc6kk7qTkjIG2R171Qgw82JwdHXF6oxl17Ts+Esmvh62DX5Lho8PiLA+mUdSuGQHEgsiLtj2Kirr2qU9MxCzOivXOMl+JDUCGkJylWOgOcjFN6w8edF31Dca+qCy4f5nmowoe3b47e9SNZ9F6T1pHU9pLVi4yljAZ87Iz9sgn+/SumVNlmhkgjzrZa+iZenYLXOwao86P87LT1/xEVAb5hKW7Pf2b6YaQdgBjbYD+1Ofw+aXuerLh/FLm+6YrSg7IWMjmHUJH3x+2/tTc/wDTxq2Fc25V0ZivwebmEhtxSuYdirI2+29TEnUWkOFukfKRPaR5aAogK9Tq8Vl5HhmmN95x5/ZW5c6aVjntIF7ADoOpKeXEPXGntDaeU6ZKUI5VEpK8EDHQZ7Ad68quKet5Gt9SrlqyiNHK0sN5zyhSyo/ncD/9akvxA8eLprW4vQI0paYqfShAVjPyrFQESScqOSdyaM/Z/THYoM8oou5DsF5T7Ramx/8A2cDraDbj3P2CUlJUoAd62XvSA2DgJrGwAk857Ue6jhVFJFoQJQKi22R3V/pRNpPLsPUaSo+a58Cs2eUYAOT1NMUyBVyJ5Rv71jA70O+5JpYAA+1Ru90kD096AOR1os+1AEVPoklc34oUWfnahUUlL0iYxKbWGyla3G1LLiSdvf8A/tOHhPwJ13xlvBe0lanP4dESBKuLqSiOlQP0hZ2UrvgH7/PM0rZbU++zZ2rR/FJst0NMSJyy1FYUCCtamk7KHLvzKVhOFZBxV0tScddI8M+D1l03pq8JECOlcZLsNotqnPAlK1oTjCElSTsSeVOBk9xGfJ8EcEd2eX9+6KY8c5DgTXn2Cz8PfBRwiiW6SzrO4tXa8TWU/QSlLGDvhOfV2GSBUncIvC/w+0quQxqfS1ivDcV0qt8v9IlpRQf/AMiE+krA25sb5qvfB3X/ABH1zqZF2sMZpq3try868AvlTseUkg5Vv0G/Spk4q+IWLZOCmoZlmubf/ECGFw20o+tt1S/LCgPjcjttWbHMXSBs43HnYPSjauZeC+FvFEbB6gclYXT170XpxuPCj3ew2mDLyi1wkONseZg+tSRkc5JI6D79aeinwWg40QoHuNxXm3pLwYQ+H1hgeJTjvxdTJskK2tXKZb/4O3Ne5CUqYjtOSedKSolAyGwfUpIKQSodG6f+Klbrclq1aX4Khq1R0oZjB+9JZUEAbDy0MKSnbAACsUUwMeyMNbyr0/oQvKQXEleiK5SUNqKgfSMnequ8e9OeKviFJj6S4QX+Npm0PPS5Eu8oeCHFAJR5DKlZ50pKi7zFCSR6euMHP4e/FPafEYi4NaVtblnulvZQ5JgyngsAKKgClQA5xt1wMZG1TVp66zHpJhTmUNPNk86OY4z7pz1FUJ8m5mNfYonpsVaji4IyRRv8k0dB6FuPC7h1adGPamuF9vbjyZFyucyW6+p6QrBdKPMUVJbGMJSDsB7kmqg+Kax2K8TYWodV2yOtld+fiMb4UqLyq5j7/UM9u9Xp1FcUMiQiOB5xbUhK8fTnvVUPFJH09YbbDjSIkaVImW99LKHBzFsjly4BnYgqH7msLPe85LXMPLt9Nv3RFocTZT4bwLPfy3VAOKvDA6VlOXazJUqzuOfyiVFRAPTfAyMEb0zbZq/VWnX25VnvUlhTe6CFZKfsT0qZrrN/4i0LItNwmoTMt7yg5Hycq/wlPxg7fY1Glm0PIvjTQ/UJi+cVIQt5J5CoHGMjpvtRHhT+JCW5O9bb9QqOpYhhygcOxYvboeoT80940eNlhjfonrhAubBABRNYKzgf5goHP3zTX1zx/wBY6+Wp64ohxFLABEdKtyOpGScZphX+xT9P3F233FgtutKIO2x+Qe4rm4x3q5Hp2IXCVjBfQ0suTVM9jXQve6uoSnFqcWXFklSjkk96TjJFDYisjaMkk9q1BQWWSsgGAADRkgJKvfak74onD6QkZxSaoc0TWxye+9LyFDmBpKRnIz2GN6Udhyg9KcmwkUMY60OvvvRJTvk0ZwB0xTV3SR5IGKG/Uik7mjBJ/FRPNJKz2GcUKKhU+FJW+8P9ok6p0pqmdFiRP0jDUeFcJjqMiDGWHFOuJJ2CilJRtk4WrptWLROhrDxy4nwYNtebc0vBeTboTKXVNlqK2cn0qwSo5KifkZ7VwWoOrNQ2KRZbdOfgwJhSHW4bhYjONp3TzNo5UkAknoQN8U4+E3Cy4MyBH0sibfrkytSnHWFFmNGXjfLnTOQe+2M47V5zk5sMfFIH07oO3zXoWJpmQ4tDwA3ueX06q6GotMf8BacFt0RpNpiLDY8ttuK2E4GMA5PUnuTk9epqGuHvAZGoha9T8QLFJbiN3oSBBWClt1LSHSPMQTlSS5yHlIGeXcEGupI1Dxo0q2mUdfC9lBRHTaWofnRWnRnmHn8vmLxjt+3tJvC3U2u71pu9StdWt1PmvFQfQptLSEAelCEp3SRvnqfck1msy4pCXMdv+mytBmRDGY6BBPPuPmm947NH3DUXhwg2Gzyp6Q3NauiojWVB1ptCk+UMnCUpSvmCcH1JG21eVggyDLTGMQrIPpQvIr2J4hccdGWbgZe5dymRZ9yssLyXoiQFryslLain2I6noDkZ2rywuV1l6mvMi/wbbb7ay6S6j9Y8GgpPTCUgFRz1/ejnTcgvjAbu2gR61yQdnYhY88YIcCbHcd1b/wABHCN2CpOs1XpcB95ZQuM0gEOoRuRzBWSMqScdNh1FXtTcIN5eftroXFfiALQ4VArKffboPivIHRfG3jdZoqtPaQkMtNuZQ2htr18yuhQT6gcgEY7gVZDhvqLxz62dRabPpqDp7zmGxJu9ygqbT5YynmBUfWsAg8oB6HONs1MkSNeeKiCd9+ldl0axjmAtvby/dWv1vf026W2yq6RiUoW8prnAWW0jJcI6hI9+gzVZuLtpla1tDeqXXiJNuQ7ITtkLSUkFvHsQB+RUoq4Yaf4MaMvr921NN1HrfVTLcedc5y+ZxaN8htOf5TWCrYHH0jsK4WljbF2mWxMWH3kpDLCOoyevxQTqBdDlAtd5+nkirSaZF4lcjV91QzWFgesE5i8tvhxL4Hmjtk7Y/wBv707bdag1o10tNl1mNIFxbAGCptwJDiQe2xSoD3T81l4uWy3t3W82uNIEpUOWr9Olr6AT9XT2J/3rNpmFNt1hiRbyHAiU2tpaFE5acbWAUkH45ftymiUzl0DHE7/39lYhxWuyn0NiLvsf5KY/Eiyt3GwwLuUIW7HSEOLAwXWzulXz6SKhiXHMaQpnsN0n3HarMaj08+xYS1FaDjEcshQSnokDqfYEKB/HxUR660gzAkrbjL50pSHWFjfnQoZwfscj8VsaTmtI8Mnuhz2g057H+M0dBfqmCEDINL6Y2pKc75GCOtDqaIAhIpSsAVjcxz4rKQCR8ViWeZXQbGpDskOaWkbk0YGKDeCN9vzSgP7UiExKIdKI57UokdiTSfT7imJ6JgjA+KMe5FADbfrRFWBgb0qTofYUKNOT1NCpAlJejELhlp/TUxlPEGc7e7jzDyrREHlRArGSVEfUE/JwfY067zEucmyvsWaXHszbCUobt7ADDJb6YUsq9WQT0wM71Amo/FnoZD6hFXdNQPtOKWhUqOotKJ9supwOp2RjtjvTdufjBgrUVRuG8day2lJcdfGfMzuvHKQPgdsA79K8Jd7P61lODxGfnQ/IkL1d2s4MJDnSgu+ZCtNar1py0QhYIOmL0HGWkuKbZbS4SrlClHmKgDvuVZ+3tXSg6r1FOtK9Padt09mJPJ535DJUGDjBUoJGMfYnGO9VbtHjjFuaVHb4VIkOO5Utx29K9R7nAax+2KNfjsvxQtCOHsRlRAHour/JjuOXGD2qxB7M6zDJxiOvmN/zVP8A6hwQ6wb3vezv3XQ194bOJt01QzP1haZA08JobmT4ElvmSwcFSmwsjmGPjtjGdqtJqjw28K9Y8KYSdHOyH4cWE23FbjFsKdWgBAKthhQ3Ktxvnp0qLOEvGzVPiM4a3yxNqgRNS2dzzlW9vm/5iGr6VtlRJ5kk8pzt9PvUKO8QeLvBG5vzLVc5bdtkPrMuC+T5LyjhJJT/AErwOox0GaLceaeM/hpmgFo2HLfyPJLIjjzoTnxOtxO9bivMc1ZnhZwI4a8Grk5e5iHrnPZCP04fIc8pwAcxSMdebPUZAqRrhxE1LIBXY2xHSpOEFRCSj/N7dKhThTxssHEeK0l64pYuZGVx3F5IPfGfv/epRfZbeaLLjoUhY3HXYUOajm5YkLHktr6/VcY8aNoBIB/RM3Wbl4kqRLmyV3CbKwkk5KU9dyfYf6imrbkSITy5FykrU2whW2MoUo5wSO+AR+d6eN+n2u3tqaVKDAOSc98VFet78wsoZiyMRljnWUncqwR6vwnpVDHD5TR6rYjfwR1Wyim9QJNt1W/eWwhyNNk5CC3lCSfbGxHXbb9sU7ZttkG0/wA5lTnOlRQXTkqUTzFeQOpUSfwOmM00+NeooOn7NZGrTNakTEThLkRmwVn9OlBBWewHMQPnIqWm5Fp1zpe3Xy1qZKlMBwY3GOXofkURz+LHCyZ42O305KenZEEkr4Wncb/XmuNw0iPXJmS1eYaSh8LIC0dsE/Y42NRVrbRjzVpZmmNh1IUv6c/y1EkJJA6kYwD0yPnFl9MaYfmwP16wqPHZbDa+UJ+nYr/BGx+5qKta2q7p/Uz5Ehl6E7zqQ+8OUYPRavjGCO2Paq+n5x/EksNX0VvNx454XMdvQVRtQ2R+3SFPllaW1HclOMGuNjvt8VIetdZ2QMyLNp6KiW6o8rtwdGUY7hpPft6j84B2VUdqGDXpmK98kYc8UvIM2OOKYtidYRpzkZrGs70tJ3Gc0hwZVgVabzVQI2lErCT0NZyAM1roGDnvms+SBtU7TFJIyc0YAosHO1A570qSRKUTRpSo70Agq2TWTKWtgcn3qPCkgEhIJUN6FY1rKj1oUuKuSSyokJQvJ7CtxpuRLI/TsKVtknoP3NdVq1xo/KUx2853508x/vWZxOT/AC/TgbADAqqXg8l3DO65LbEpC+XlTn2BrKhh9tX8xk777EK/0rqMradHlKKgpIxj/X/6rGtjzSUoVkc2MJ6n2wPemJrmn4ey6OhOIWpOGeq4erdLTFxrhBXlJAPK4n+ptY/qQroR/vV/uG2q+DviGVL1ncNL+c0mMpmTbJACvLlhKT22VgH0qI3+4IHnUlLLayG2VrcBwEkEEGn5wU4oTODvEaFcpk0Isd1WmLd2k5UEN59LgH+JBPMCN8cw71jatgjLj8SL427jz8ls6RqLsGXhcfddsfJSxrrhnOjaudumj9OuW9LLnmx3IzflqSMkgnHX8+1OPTHiRTY4j1s4lXNECUz6UPOtOELHvypBOfgfipkmtSJ9xansNtTYUrCostpfmMyWlDKVoWk4WCDkEE7EVBnia4Iag1NNtz2mbA8482hx6Y6pHIgJHQZO2aEMd8eY8Y+YKA2vqPqjLUpGsiM+PXEd65grlXrxBcPrndVK/wCKHJQWrkbWY7qEJG4/qSMdtz+9MbVOsdR6yS9E0+lxqCzzyXHC+2y6+02MrKAsgBOObCzsc4HNuDHTWiNSaNvkVepdHusecjz4aJsIuMPlKh88ihgk4PMCQkEYJqbNO8LLxqWXBu1002zDjOvLd/SOMLDkkKVhKXiQhawpRxzKxyg+hKAkA7/4HTtNqZrr7WQfpSGfx2dnAxEV5AEJm8NOFkziRfI8SMh+3sQ8fxCalzmBSFcwAT0KcoTyjqSS4rYpFWh09wCuejrG3O0A4t+LIWpLtsfV1GThSFHofdJ2O3zWXgRolvSt3kWtpLbtrZZdW8lckLK3UrQOdOTzK3UoHHberRabt6HVISlvDKBzD2OfasjLzn6hN4TD7nb9yr+PWkjjaPf6n9lAOhdYWi8Wq4adlRXI8qIpTcyI7s6kEkHKfY4IBxgiqb+KTjtI4i6mf0tYCYlitKzGcDZA/VvIVgqVy9UAgBI6HGfavRDiPwyav5uarIExLk7HdEeS2kBSXikhJJ7jJGa8h9RWi62K/XCy32M4xcoUl1iU24MKS6lRCgfzmtD2c0yLx3zOG7dgP3VbXNXdJAGRWOL4vt81z0qI27UZOSdqAz3oYyMjtR0BaDCUWCNvakqJG+KXjG5NJzk+kZFNyThYxzEjY1s8pA3IrEnOdzShlazk4FSBSO6X6MepX7URU3jYfvRcozigQAdhSs9EySp1R2x/ak8yumDvSyBQABpjZSRJT+1CjwB3oUySejamFHPTB65NE/MjpGEbHbm5QOtchd5QU8v6ZGD/AJjWNy8O4BaQhv7JHSqYbvatcVKQbTwb4lah09/xZZ9KvqtHIpwS3XW2m1JH1KBWoEpHc9Kcdi4iaP4QWZh3Sdit9x12WvMXfHXBJagLKwQhlpQUySEJGV4KsrUAQMgw3Ovl2u3kquV0lShHbSy0HnVLDbadghIJ9IA6AbU6uEvC+98V9QybJZVJQmFDXOkvuKSlDTSVJSVKUogJHMtOTvgZODjBrzxgsLsh3ujft9e66RSe9UQ94q0nDvjtpzxABfDviPYtINzdSQHrZ+r/AIWhibGn4JZkMuJHK4k7ZR6VBacbpVVXuKvB7X3CO7OWHX1hfhrVzLjSUpKo0lAOOdpzGFDcZHUZGQM1bbQ3CDh3waaVK0jdla41dKjrTBkW8KdiRZRGAtTqeVBCPUQlW6ieblylPLI+nNUcUVar07P1jxh0mNOygtqVYGQqa8slCwthZSlSXEpxlThVgkEYIxQ43V24k58H4Ox23HZapwHzRgv+LyVUPAVDv+qfEnpCxPXacq3WxciaqKpxxbSQ2ysj0bpT6uXcgAHHfFexdwtkF5kpXb2XTjGFNg5/emDwQ4N8KeG9gbuPDfStvt6LsVSzKZRzLdQ4eYAOK9Xl4I5U5wBjFSgtI+qiIMjyG+IG1xALLL3xkMvkmPcuHNlnQ1MrhMhwnKAEDla+U+xpp3Tg/aGbXc2ChxK7gytlbyccyUlJHp9upqYSkHtvWtIYDyFNqGyhis2fSMd+4AtWoM+WN3xbLzZ0g27oCz3fVNtgpjvRJiY12/UMhI8tJIW2ggY5wTnGQDjc1cjh/erZqDTMS72qUh9p9seoYBGw2Psc11td8M03C03OPpWLCjTLjFXHdWtv6yU8vNkf1Y7mmxwd4c33QlldtN4PJhYKEhWQNsH7UNxYs2Jk8DwXXe/Sum6Ic3Px8+EyMAaRW3fungISVL8woBKhVRPF34SI/FB1/WmiWG42p20jnRnlbmpHZXsv2P4O3S6UaEVueXg4rVuOn1KjSngkKKR6citiPxoSJIuiwXFr7a9eDd0tNwsdzk2e7w3YkyG4pl5l1OFIWDggitVQx3r0p8RXg3TxXjTtU6bW3C1LFQVNjkwmZ/kc/A2UOnzXm7dIkm3SnoExlTMiO4pl1tQwULScKB+QQRRPg5wzI7AojmFlZOP4TquwtTGcnGRRHHtRqyCEg0YSebftVxcEkBIHMd80tA9xQ6q5sbDb80MgbmpjdMUZ26UWB3ozufii7HH70j2SCKgPfFChzfuKaqTo/uKFJz7f3oVEpKZtM6b1dqDKbJoS53AvpKkJhW1RbIHX6U4OPvUj6Z8LvFvX7iLbbuAN0C1qQlc644t0dlGQCorWU82M5wnmUQNgelesVs0RZrW+qQyZDmcYS6sFKcdMAAV1p0hi3QJM55bbbUZlbq1OK5UpSlJJJPYbdaGcc5UgL5wGeQJJ+u36LYdNG0cLN/UBeRvBLgFwIkX+W9xTu9/uKYjqW4llt7ayJa+VZWpam0+aWxygYQEkHBJxU5aismnLrpq58MvDFwUTBGokIj3u6yErjsxUpSE8q3FZ5l+tacAkg85xk5qFuA+tNJ/+aVy1Jq020wYkKbKjtyG2yHnknLbTKV7KcWfSge5HTtcKVxF1KbJP0zwnsFta1bamkSk2SdhMhSS2lwJMfmbLQKVowpWAAoHfNYGoZGa2RoeHOYfKxfnXbzWpHHjUTEAD60mTYeCWjuDGn7taFt27S9tcaRBuOqpWH7jdVONoLojE/wDst+pSAABuASDykq1tDai4daAeb07obiG9LaaacbRerpBMoqjpUoiNHbGP5aSPU6r0knCSThImA+HuXx3s1mvfGSDMsrf6EOpsibgrniyV/WpQQAM425SokZI2qUdJcDuHejLMzZYNih/pY+zTbbCWkJGc/wBPqOTuSpRycn4pf8XmZY43CiTzJqq9PyTDPghHDz9P5XR4ZXz+P6Ot9yE9c1C2+USVRyx52D9QQfpB7f79ad3OSMVqx2mWUFDLYQjJISO1Zuce1F+K0wwtjcbIFWsKVwe8uApLrG6oJBI9qBdA/wDutZx8KVyk996nI8AJgLRgJwD1PvReQlzIUAfvRhQ5RisqAcdOtcg0FSJpYkxW0glDYBHtWGQ2EQnSR9RxXQUjlRjua1ZyctIYAzzGmkYGtNJg6yuQ1bmmoqlhCedZyCR3rxe8Y3C+78L+OupIk5l0w73Mdu8F8owl1t5ZWoA9MpWVJI+B717braCWwgDoKhHxL+GnSfiH0g5ZrugRrzEQty0XJGyo7xHRX+JCsAKT7bjBANPju/Dkdkz6kC8TepbUcYxvSkghVSvxr8MPFngPKUzrKxl22KXhi6w8uRnD7E9UK+FAfGailPqAV+9bDJBILaVTcC3YogMk/ekpPMrONhWXB5in33FYWxgkGuhNKPNHkqGQNx1oDB3BoA4J22oKSFb5wadPsgdjih/tScKHXNFk9M1z2SSjj5oUXMaFMkvVTSPix8UPiG8+28EeEdl05BZV5cjUt6nLlRmlhQyEAIQCvlOSjlWQDnbYmTrlwD13ry2Kt/F3xFatu7D6SmTb7CyxZYLiFJwptSWwp1xJ3yFuEHP0jpUqWq2WbTNoh6d05bmLdbIDYZjRY6eVDaR2A/uT1JJJ3NZ1vrAJxgUKZ2oxvld4Apl7A7mum61YYXNaOPd3VQdp/wAC3hnsJCnNESLutLgcSu43J9zBByBypUlJGexBqY4+ntOWSY7dbPp62w57rSGXJTEVDby20JCEJUsDmISlKUgE7AADYVr3S5z4kRbkQgvEHGegFYrTflT4oW6OZYAJI6Gsd+sNMnhEkEj5K2Mc1xDkummM5KzLuEgoaSM5Ksbfeot1PxoQu5zbHoe5PhNlWESnG1+dzLI+lIJI96jjxQcW9XwJ8DQmnH1xU3NlRcfbyFbEApT/AG369aTwz0WjRmnpKHnC7LmEOPLdIUc/f3yTv9qxM/U3tZURIvr1NfoFqY+E3h8STfsFbDh1en9SaPt15lBfmSWypXOAFZCiNwOnSnEr0imTwXfdd0JFL31IeeTtttzHH+tPR9Wx+K9A0+UyYccjtyWj9EO5LQ2dzRysrSefPMcJ74FEwypxZKvxSktlaweXvW8y0EjYfmpsjMjrKi53CNljTHxjm7dq2EIH1HtRqxgAUatkDNW2sAC4F1rXdWVLAFJKPMeCidk1kSj1c/asmAB0G9c+Hi3KcGtkhSAdsVhVGSdz23FbAPcUSumKVAp00deaWsGsNOT9N36AxMgzmFMvMvI5kqChj8H5G9eKnH/gvP4Ma9uNhbDz9qS8TFkLbKcoOeUH56jOd8H5r3FnNeYVJGxwfzVbuM3CrS1/vDk7UluYmW6a2qFOjvYwEKGziSd0qScEEEY+DXE5Rxngnl1UmxCUEdV4/wDLkA4zitdQKVZByKmTxG8ALrwI1Q1DVMblWe5KW7bngrK/KzsFj3Axv0qIikKB2rcY4StDmqm5pYaKxEg7jIzSTnFKKSnIOdqSQfbekmRheNjSjyKOyaxnPehv9qa0qWQoT03FCkcxHfahTWkvftYIcDeMlI3PzWpKfKEqIUNjihQrzfJ91przW/HuRabdzn8zS8uhKO5PfrsK52kp3PInwwDysoLiQOwPahQoUEjnZTb8/wBFqBo8NygzjlGDOu9GasejH+Hx5MiNKe2PllbZLW3/AMkn8ke4rr23UUa7wG5EJaizzKQoJO+Unoe4PQ/mhQrnk+8xtrRhA8JWR4HrDmh0tgjLMlxB377H/en4tINChXqmk/8ArovQIOzP/Id6rG2gAk1mCiBsaFCtFnJVzujT9Qo1+o8ooUK7dFA80rASnAxtWM79aFCmKZqI4FJKtutChVcrotSWkhPOnqRTF1hYl3SO6pBAKknA5QQDjHTv1oUKp5LQ8UV1j2Oyp5419LC+8EiqegIuWn3g+wVZOW+ik7bZIxj7V5vBTgxvQoVe0pxMO/f9guWUBxJQcSr6wR8npRKRkZSetChWqSaVSkMb7UkjFChUUkXf8UKFCkkv/9k=",
				"firstName": "",
				"middleName": "",
				"title": "",
				"email": ""
			}
		}
	}

};
</script>

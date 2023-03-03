<template>
	<div class="flex justify-center items-center h-screen px-6">
		<div class="p-6 max-w-sm w-full bg-white shadow-lg shadow-cyan-500/40">
			<div class="flex justify-center items-center">
				<img
					:src="`${baseHref}/includes/images/stachebox-logo-h.png`"
					style="width: 300px"
				/>
			</div>
			<GenericLoader v-if="isProcessing" :message="$t( 'Validating token. Please wait' )"></GenericLoader>
			<form
				v-else-if="user"
				class="mt-4"
				@submit.prevent="saveUser"
			>
				<p
					v-for="(error, index) in errors"
					:key="`error-${index}`"
					class="text-red-500 justify-center items-center"
				>
					{{ error }}
				</p>
				<div class="mt-10">
					<h3
						class="text-lg leading-6 font-medium uppercase text-gray-500 border-gray-500 border-b"
					>
						{{ $t("Change Your Password") }}
					</h3>
					<div
						class="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6"
					>
						<div class="sm:col-span-4">
							<label
								for="firstName"
								class="block text-sm font-medium text-gray-700"
							>
								{{ $t("Password") }}
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
								{{ $t("Verify Password") }}
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
							<div
								v-if="
									!isPasswordVerified &&
									validation.errors.length
								"
								class="rounded-md bg-red-50 p-4"
							>
								<div class="flex">
									<div class="flex-shrink-0">
										<fa-icon
											icon="times-circle"
											class="h-5 w-5 text-red-400"
										/>
									</div>
									<div class="ml-3">
										<h3
											class="text-sm font-medium text-red-800"
										>
											{{
												$t(
													"This form has errors and cannot be saved"
												)
											}}
										</h3>
										<div class="mt-2 text-sm text-red-700">
											<ul
												class="list-disc pl-5 space-y-1"
											>
												<li
													v-for="error in validation.errors"
												>
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

				<div class="mt-6">
					<button
						type="submit"
						:disabled="!isValid || null"
						class="py-2 px-4 text-center bg-theme w-full text-white text-sm"
						tabindex="3"
					>
						<span v-if="!isProcessing">{{
							$t("Request Password Reset")
						}}</span>
						<span v-else
							>{{ $t("Requesting Password Reset") }}...
							<fa-icon icon="spinner" spin></fa-icon
						></span>
					</button>
				</div>
			</form>
			<p class="text-red-400 justify-center items-center" v-else>
				{{ $t("reset.request.token.invalid") }}
				<br /><br />
				<button
					type="button"
					class="py-2 px-4 text-center bg-theme w-full text-white text-sm"
					tabindex="3"
					@click="$router.push({ name: 'ForgotPassword' })"
				>
					{{ $t("Request a new Reset Token") }}
				</button>
			</p>
		</div>
	</div>
</template>

<script>
import GenericLoader from "@/components/GenericLoader";
import VueJwtDecode from "vue-jwt-decode";
import usersAPI from "@/api/users";
import { mapState } from "vuex";

export default {
	components: {
		GenericLoader,
	},
	data() {
		return {
			email: "",
			isProcessing: false,
			errors: [],
			user: null,
		};
	},
	computed: {
		...mapState({
			baseHref: (state) => state.globals.stachebox.baseHref,
		}),
		isPasswordVerified() {
			return this.user.password === this.user.confirmPassword;
		},
		isValid() {
			return this.isPasswordVerified;
		},
	},
	methods: {
		validatePassword() {
			if (this.validation.errors.length) {
				this.validation.errors.splice(0, this.validation.errors.length);
			}
			if (
				this.user.password.length &&
				(!this.user.confirmPassword ||
					!this.user.confirmPassword.length)
			)
				return;
			if (this.user.password !== this.user.confirmPassword) {
				this.validation.errors.push(
					"The two passwords do not match.  Please re-confirm your new password."
				);
			}
		},
		saveUser() {
			var self = this;
			this.isSaving = true;
			usersAPI
				.patch(
					{ id: this.user.id, password: this.user.confirmPassword },
					this.$route.query.token
				)
				.then((result) => {
					self.$router.push({
						name: "Login",
						params: { resetComplete: true },
					});
				})
				.finally(() => {
					self.isSaving = false;
				});
		},
	},
	mounted() {
		let query = this.$route.query;
		console.log(query);
		if(	query.token ) {
			try{
				var requestUser = VueJwtDecode.decode( query.token );
			} catch( e ){
				return;
			}
			console.log( requestUser );
			this.isProcessing = true;
			usersAPI.fetch( requestUser.id, {}, query.token )
					.then( response => this.user = response.data )
					.catch( err => console.error( err ) )
					.finally( () => this.isProcessing = false );
		}

	}
};
</script>

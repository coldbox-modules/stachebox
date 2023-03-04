<template>
	<div class="project-form">
		<h3
			class="text-gray-500 text-xl font-medium pb-2 border-gray-300 border-b"
			v-if="project"
		>
			{{ $t( "{action} Project", { action : project.name ? "Edit" : "Create" } ) }} Project
		</h3>
		<form v-if="project" class="space-y-8 divide-y divide-gray-300">
			<div class="space-y-8 divide-y divide-gray-300">
				<div>
					<div class="pt-8">
						<div>
							<h3
								class="text-lg leading-6 font-medium uppercase text-gray-500 border-gray-500 border-b"
							>
								{{ $t( "Project Information" ) }}
							</h3>
						</div>
						<div
							class="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6"
						>
							<div class="sm:col-span-4">
								<label
									for="name"
									class="block text-sm font-medium text-gray-700"
								>
									{{ $t( "Name" ) }}: <fa-icon size="xs" class="text-red-500" icon="asterisk"/>
								</label>
								<div class="mt-1">
									<input
										type="text"
										name="name"
										id="name"
										:placeholder="$t( 'Enter a name for the project' )"
										class="shadow-sm focus:ring-cyan-500 focus:border-cyan-500 block w-full sm:text-sm border-gray-300 rounded-none"
										v-model="project.name"
										@change="reSlugify"
									/>
									<form-errors :errors="v$.project.name.$errors" :fieldName="$t( 'Project name' )"></form-errors>
								</div>
							</div>

							<div class="sm:col-span-4">
								<label
									for="url"
									class="block text-sm font-medium text-gray-700"
								>
									{{ $t( "Project URL" ) }}
								</label>
								<div class="mt-1">
									<input
										type="text"
										name="url"
										id="url"
										:placeholder="$t( 'Enter the URL for the project or website' )"
										class="shadow-sm focus:ring-cyan-500 focus:border-cyan-500 block w-full sm:text-sm border-gray-300 rounded-none"
										v-model="project.url"
									/>
									<form-errors :errors="v$.project.url.$errors"></form-errors>
								</div>
							</div>

							<div class="sm:col-span-4">
								<label
									for="description"
									class="block text-sm font-medium text-gray-700"
								>
									{{ $t( "Description" ) }}
								</label>
								<div class="mt-1">
									<textarea
										type="text"
										name="description"
										id="description"
										class="shadow-sm focus:ring-cyan-500 focus:border-cyan-500 block w-full sm:text-sm border-gray-300 rounded-none"
										v-model="project.description"
									></textarea>
								</div>
							</div>
						</div>
						<div
							class="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6"
						>
							<div class="sm:col-span-12">
								<label
									for="icon"
									class="block text-sm font-medium text-gray-700"
								>
									{{ $t( "Project Icon" ) }}
								</label>
								<div class="mt-2 flex items-center">
									<div class="relative z-10 block h-200 w-200 rounded-full overflow-hidden shadow">
										<img
											v-if="project.icon"
											class="h-full w-full object-cover"
											:src="project.icon"
											:alt="$t( 'Your project icon' )"
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
										id="icon-input"
										name="icon-input"
										type="file"
										class="sr-only"
										@change="updateIcon"
									/>

									<input type="hidden" name="icon" v-model="project.icon">
								</div>
							</div>
						</div>
					</div>

					<div class="mt-5">
						<h3
							class="text-lg leading-6 font-medium uppercase text-gray-500 border-gray-500 border-b"
						>
							{{ $t( "Project Assignments" ) }}
						</h3>
						<div
							class="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6"
							v-if="applications.length"
						>
							<div class="sm:col-span-12">
								<label
									for="applications"
									class="block text-sm font-medium text-gray-700"
								>
									{{ $t( "Applications" ) }}: <fa-icon size="xs" class="text-red-500" icon="asterisk"/>
								</label>
								<div class="mt-1">
									<VueMultiselect
										v-model="project.applications"
										:options="applications"
										:multiple="true"
										placeholder="Choose Application Logs to Associate to your project"
										:custom-label="(val) => val.toTitleCase()"
									/>
								</div>
							</div>
						</div>
						<div
							class="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6"
							v-if="beatsApplications.length"
						>
							<div class="sm:col-span-12">
								<label
									for="beats"
									class="block text-sm font-medium text-gray-700"
								>
									{{ $t( "FileBeats" ) }}
								</label>
								<div class="mt-1">
									<VueMultiselect
										v-model="project.beats"
										:options="beatsApplications"
										:multiple="true"
										:placeholder="$t( 'Choose Filebeat Apps to Associate to your project' )"
										:custom-label="(val) => val.toTitleCase()"
									/>
								</div>
							</div>
						</div>
					</div>

					<div class="mt-5">
						<h3
							class="text-lg leading-6 font-medium uppercase text-gray-500 border-gray-500 border-b"
						>
							{{ $t( "Notification Settings" ) }}
						</h3>
						<div
							class="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6"
						>
							<div class="sm:col-span-12">
								<label
									for="applications"
									class="block text-sm font-medium text-gray-700"
								>
									{{ $t( "Enable Notifications" ) }}
								</label>
								<div class="mt-1">
									<toggle-switch :isActive="project.summaryEmails" @toggle="toggleNotifications"></toggle-switch>
								</div>
							</div>
						</div>
						<div
							v-if="project.summaryEmails"
							class="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6"
						>
							<div class="sm:col-span-12">
								<label
									for="applications"
									class="block text-sm font-medium text-gray-700"
								>
									{{ $t( "Notification Frequency" ) }}
								</label>
								<div class="mt-1">
									<VueMultiselect
										v-model="project.frequency"
										:options="frequencies"
										:placeholder="$t( 'Choose a frequency at which notifications will occur' )"
									/>
								</div>
							</div>
						</div>
						<div
							v-if="project.summaryEmails"
							class="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6"
						>
							<div class="sm:col-span-12">
								<label
									for="applications"
									class="block text-sm font-medium text-gray-700"
								>
									{{ $t( "Notification Recipients" ) }}
								</label>
								<div class="mt-1">
									<VueMultiselect
										:loading="!users"
										v-model="v$.project.recipients.$model"
										:options="users"
										track-by="id"
										:multiple="true"
										:custom-label="(val) => val.firstName + ' ' + val.lastName"
										:placeholder="$t( 'Choose users to receive notification emails' )"
									/>
									<form-errors :errors="v$.project.recipients.$errors" :fieldName="$t( 'Notification Recipients' )"></form-errors>
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
								{{ $t( "Project successfully saved!" ) }}
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
						@click="$emit( 'cancel-edit' )"
					>
						<fa-icon class="mr-5" icon="undo"/>
						{{ $t( "Cancel" ) }}
					</button>
					<button
						type="button"
						class="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-none text-white bg-cyan-600 hover:bg-cyan-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-cyan-500 disabled:opacity-50"
						:class="{'cursor-not-allowed' : !isValid }"
						@click="saveProject"
						:disabled="!isValid"
					>
						<fa-icon class="mr-5" v-if="isSaving" icon="spinner" spin/>
						<fa-icon v-else  class="mr-5" icon="save"/>
						{{ $t( "Save" ) }}
					</button>
					<VDropdown placement="left" distance="6">
						<button
							type="button"
							class="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-none text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-cyan-500"
						>
						<fa-icon class="mr-5" v-if="isSaving" icon="spinner" spin/>
						<fa-icon v-else  class="mr-5" icon="trash"/>
						{{ $t( "Delete Project" ) }}
						</button>
						<template #popper>
							<div class="p-5">
								<p class="text-gray-700 text-sm" style="max-width:350px">{{ $t( 'project.delete.confirm.message' ) }}</p>
								<div class="mt-2 text-right">
									<button class="py-2 px-4 mr-1 text-center bg-gray-400 text-gray-100 text-sm" type="button" v-close-popper>Cancel</button>
									<button class="py-2 px-4 text-center bg-green-600 text-gray-100 text-sm" type="button" v-close-popper @click="deleteProject">Yes</button>
								</div>
							</div>
						</template>
					</VDropdown>
				</div>
			</div>
		</form>
	</div>
</template>
<script>
import { createBase64ImageFromFile } from "@/util/image";
import VueMultiselect from 'vue-multiselect';
import useVuelidate from "@vuelidate/core";
import FormErrors from "@/components/util/FormErrors";
import ToggleSwitch from "@/components/ToggleSwitch";
import { required, url, requiredIf, helpers } from "@vuelidate/validators";
import usersAPI from "@/api/users";
import { mapState } from "vuex";
export default {
	components: {
		FormErrors,
		VueMultiselect,
		ToggleSwitch
	},
    setup(){
        return {
            v$ : useVuelidate()
        };
    },
    validations(){
        return {
            "project" : {
                "name" : { required },
				"url": {  url },
				"applications" : { required },
				"recipients": { requiredIfEmails : helpers.withMessage( this.$t( 'Recipients must be assigned if summary emails are configured' ), requiredIf( this.project && this.project.summaryEmails )) }
            }
        };
    },
	props : {
		data : {
			required : true,
			type : Object
		},
		index : {
			required : true,
			type : Number
		}
	},
	data(){
		return {
			project : null,
			dropdownOpen : false,
			isSaving : false,
			saveSuccess : false,
			frequencies : [
				"hourly",
				"daily",
				"weekly",
				"monthly"
			]
		}
	},
	computed : {
		isValid(){ return !this.v$.$invalid },
		...mapState({
			authUser : ( state ) => state.authUser,
			authToken : ( state ) => state.authToken,
			applications : ( state ) => Object.keys( state.navAggregations.applications ),
			beatsApplications : ( state ) => state.navAggregations.beatsAggregations.applications ? Object.keys( state.navAggregations.beatsAggregations.applications ) : [],
			users : ( state ) => state.stacheboxUsers
		})
	},
	beforeMount(){
		this.project = this.data;
		if( !this.project.owner ){
			this.project.owner = { ...this.authUser };
		}
		this.fetchUsers();
	},
	beforeUnmount() {
		this.project = null;
	},
	methods : {
		reSlugify( e ){
			this.project.id = this.project.name.slugify();
		},
		saveProject(){
			if( !this.v$.$invalid ){
				this.$emit( "save-project", { data : this.project, index : this.index } );
			}
		},
		setIconIfEmpty( e ){
			var self = this;
			if( e.target.value && !this.v$.project.url.$invalid && !this.project.icon ){
				fetch(
					`https://t3.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,url&url=${e.target.value}&size=64`,
					{
						mode : "no-cors",
						headers: {
							"Accept" : "image/png"
						}
					}
				).then( response => console.log( response ) )
				.then( blob => {
					var reader = new FileReader() ;
					reader.onload = function(){ console.log( this.result ) }; // <--- `this.result` contains a base64 data URI
					reader.readAsDataurl( blob );
				})
				.catch( err => console.error( err ) );
			}
		},
		showFileSelect( event ){
			document.getElementById( 'icon-input' ).click();
		},
		updateIcon( event ){
			if (event.target.files.length ) {
				createBase64ImageFromFile( event.target.files[0] ).then( base64 => this.project.icon = base64 );
			}
		},
		fetchUsers(){
			if( !this.users ){
				usersAPI.list( { "sortOrder" : "lastName DESC, firstName DESC", "allowLogin" : true }, this.authToken )
						.then( result => this.$store.commit( "updateState", { key : "stacheboxUsers", value : result.data.results } ) )
			}
		},
		toggleNotifications(){
			this.project.summaryEmails = ! this.project.summaryEmails;
			this.v$.project.recipients.$touch();
		},
		deleteProject(){
			this.$emit( "delete-project", { data : this.project, index : this.index } );
		}
	}
}
</script>
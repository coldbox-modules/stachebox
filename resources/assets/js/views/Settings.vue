<template>
	<div class="settings-admin">
		<h3 class="text-gray-700 text-3xl font-medium">StacheBox Custom Settings</h3>
		<table v-if="settings" class="text-left table-fixed border-collapse mt-5">
			<tbody>
				<tr class="border-b">
					<th class="py-3 px-3 w-1/3 text-medium text-gray-600">Logstash Log Index Pattern: <a v-tooltip="'The index pattern to search for application-provided log entries'"><fa-icon class="text-theme text-xs" icon="info-circle"/></a></th>
					<td class="py-3 px-3 w-2/3">
						<input class="form-input rounded-none mt-1 w-full focus:border-teal-600" v-model="settings.logIndexPattern.value"/>
					</td>
				</tr>
				<tr class="border-b">
					<th class="py-3 px-3 w-1/3 text-medium text-gray-600">Filebeats Log Index Pattern: <a v-tooltip="'The index pattern to search for filebeat ( e.g. machine ) log entries'"><fa-icon class="text-theme text-xs" icon="info-circle"/></a></th>
					<td class="py-3 px-3 w-2/3">
						<input class="form-input rounded-none mt-1 w-full focus:border-teal-600" v-model="settings.beatsIndexPattern.value"/>
					</td>
				</tr>
				<tr class="border-b">
					<th class="py-3 px-3 w-1/3 text-medium text-gray-600">Omit from entry data: <a v-tooltip="'Regex pattern which denotes any fields which should be omitted from log API output'"><fa-icon class="text-theme text-xs" icon="info-circle"/></a></th>
					<td class="py-3 px-3 w-2/3">
						<input class="form-input rounded-none mt-1 w-full focus:border-teal-600" v-model="settings.neverExpose.value"/>
					</td>
				</tr>
				<tr>
					<td colspan="2 items-right">
						<button
						@click="applySettings"
						class="block mt-10 float-right items-center px-3 py-2 border border-transparent shadow-sm text-sm leading-4 font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
						><fa-icon icon="save"></fa-icon> Update Settings</button>
					</td>
				</tr>
			</tbody>
		</table>
		<div v-else class="mt-4 text-center items-center">
			<fa-icon size="3x" class="text-gray-400" icon="circle-notch" spin fixed-width />
			<p class="mt-4 text-gray-400">Loading module settings...</p>
		</div>
	</div>
</template>
<script>
import settingsAPI from "@/api/settings";
import { mapGetters, mapState } from "vuex";
export default {

	data(){
		return {
			settings : null,
			isLoading : false,
			isSaving : false,
			searchFilters : {}
		}
	},
	computed : {
		...mapGetters({
			hasPermission : "hasPermission"
		}),
		...mapState({
			authToken : ( state ) => state.authToken
		})
	},
	methods : {
		fetchSettings(){
			settingsAPI.list( this.searchFilters, this.authToken )
						.then( result => this.settings = result.data.reduce( ( all, setting ) => { all[ setting.name ] = setting; return all }, {} ) );
		},
		applySettings(){
			Object.keys( this.settings ).forEach( setting => this.updateSetting( setting ) )
		},
		updateSetting( key ){
			settingsAPI.patch( this.settings[ key ], this.authToken )
		}
	},
	created(){ this.fetchSettings() }
}
</script>
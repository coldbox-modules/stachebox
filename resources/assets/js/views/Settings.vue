<template>
	<div class="settings-admin">
		<Tabs v-if="settings">
			<Tab name="Logging">
				<logs :settings="settings" @update-settings="applySettings"></logs>
			</Tab>
			<Tab name="API Tokens">
				<tokens :settings="settings" @update-tokens="updateTokens"></tokens>
			</Tab>
			<Tab name="Projects">
				<projects :settings="settings" @update-projects="updateProjects"></projects>
			</Tab>
		</Tabs>

		<div v-else class="mt-4 text-center items-center">
			<fa-icon size="3x" class="text-gray-400" icon="circle-notch" spin fixed-width />
			<p class="mt-4 text-gray-400">Loading module settings...</p>
		</div>
	</div>
</template>
<script>
import settingsAPI from "@/api/settings";
import { mapGetters, mapState } from "vuex";
import Tabs from "@/components/Tabs";
import Tab from "@/components/Tab";
import Logs from "@/components/settings/Logs";
import Tokens from "@/components/settings/Tokens";
import Projects from "@/components/settings/Projects";
export default {
	components: {
		Tabs,
		Tab,
		Logs,
		Tokens,
		Projects
	},
	data(){
		return {
			settings : null,
			isLoading : false,
			isSaving : false,
			searchFilters : {}
		}
	},
	computed : {
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
			settingsAPI.patch( this.settings[ key ], this.authToken );
		},
		updateProjects( projects ){
			this.settings.projects.value = projects;
			this.updateSetting( "projects" );
		},
		updateTokens( tokens ){
			this.settings.apiTokens.value = tokens;
			this.updateSetting( "apiTokens" );
		}
	},
	beforeMount(){ this.fetchSettings() }
}
</script>
<template>
	<div>
		<h3 class="text-gray-700 text-3xl font-medium flex mb-3">
			<span class="flex-1">{{ $t( "Projects" ) }}</span>
			<button type="button" @click="createProject" class="flex-2 justify-center p-2 border border-transparent shadow-sm text-sm font-medium rounded-none text-white bg-cyan-600 hover:bg-cyan-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-cyan-500">
				<fa-icon icon="plus" fixed-width></fa-icon> {{ $t( "Create" ) }}
			</button>
			</h3>
		<table v-if="!showForm" class="min-w-full divide-y divide-gray-200">
			<thead class="bg-gray-50">
				<tr>
					<th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
						{{ $t( "Name" ) }}
					</th>
					<th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
						{{ $t( "URL" ) }}
					</th>
					<th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
						{{ $t( "Applications" ) }}
					</th>
					<th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
						{{ $t( "FileBeats" ) }}
					</th>
					<th scope="col" class="relative"></th>
				</tr>
			</thead>
			<tbody v-if="!projects.length">
				<tr>
					<td colspan="5" class="text-sm text-gray-400 align-center text-center" v-text="$t( 'No projects have currently been configured' )"></td>
				</tr>
			</tbody>
			<tbody v-else class="bg-white divide-y divide-gray-200">
				<tr v-for="( project, index ) in projects" :key="project.name" >
					<td class="px-6 py-4 whitespace-nowrap">
						<div class="flex items-center">
							<div class="flex-shrink-0 h-10 w-10">
								<img class="h-10 w-10 rounded-full" :src="project.avatar" alt="">
							</div>
							<div class="ml-4">
								<div class="text-sm font-medium text-gray-900">
								{{ project.name }}
								</div>
							</div>
						</div>
					</td>
					<td class="px-6 py-4 whitespace-nowrap">
						<a class="text-sm" :href="project.URL" target="_blank">{{ project.URL }}</a>
					</td>
					<td class="px-6 py-4 whitespace-nowrap">
						<span v-for="application in project.applications" class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
							<router-link :to="`/logs/application/${application}`">{{ application.toTitleCase() }}</router-link>
						</span>
						<span v-if="!project.applications.length" class="text-sm text-gray-400">{{ $t( "No applications have been assigned" ) }}</span>
					</td>
					<td class="px-6 py-4 whitespace-nowrap text-sm">
						<span v-for="application in project.beats" class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
							<router-link :to="`/logs/application/${application}`">{{ application.toTitleCase() }}</router-link>
						</span>
						<span v-if="!project.beats.length" class="text-sm text-gray-400">{{ $t( "No applications have been assigned" ) }}</span>
					</td>
					<td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
						<a @click="editProject( index )">{{ $t( "Edit" ) }}</a>
					</td>
				</tr>
			</tbody>
		</table>
		<project-form v-else :project="this.projects[ editIndex ]"></project-form>
	</div>
</template>
<script>
import ProjectForm from "./ProjectForm";
export default {
	components:{
		ProjectForm
	},
	data(){
		return{
			showForm: false
		}
	},
	props : {
		settings : {
			required : true
		}
	},
	computed : {
		projects(){
			return this.settings.projects || [];
		}
	},
	methods: {
		editProject( index ){

			this.showForm = true;
		},
		getURLIcon( url ){
			//https://t3.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=http://ortussolutions.com&size=64
		},
		saveProjects(){
			this.$emit( "update-projects", this.projects )
		}
	}
}
</script>
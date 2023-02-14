<template>
	<div>
		<h3 class="text-gray-700 text-3xl font-medium flex mb-3">
			<span class="flex-1">{{ $t( "Projects" ) }}</span>
			<button v-if="hasPermission( 'Administer:Projects' )" type="button" @click="createProject" class="flex-2 justify-center p-2 border border-transparent shadow-sm text-sm font-medium rounded-none text-white bg-cyan-600 hover:bg-cyan-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-cyan-500">
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
					<th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
						{{ $t( "Notifications" ) }}
					</th>
					<th scope="col" class="relative"></th>
				</tr>
			</thead>
			<tbody v-if="!activeProjects.length">
				<tr>
					<td colspan="5" class="text-sm text-gray-400 align-center text-center" v-text="$t( 'No projects have currently been configured' )"></td>
				</tr>
			</tbody>
			<tbody v-else class="bg-white divide-y divide-gray-200">
				<tr v-for="( project, index ) in activeProjects" :key="project.name" >
					<td class="px-6 py-4 whitespace-nowrap">
						<div class="flex items-center">
							<div class="flex-shrink-0 h-10 w-10">
								<img v-if="project.icon" class="h-10 w-10 rounded-full" :src="project.icon" alt="">
								<fa-icon class="text-gray-500 font-normal" size="2x" v-else icon="cubes" fixed-width></fa-icon>
							</div>
							<div class="ml-4">
								<div class="text-sm font-medium text-gray-900">
								{{ project.name }}
								</div>
							</div>
						</div>
					</td>
					<td class="px-6 py-4 whitespace-nowrap">
						<a class="text-sm" :href="project.url" target="_blank">{{ project.url }}</a>
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
					<td class="px-6 py-4 whitespace-nowrap text-sm">
						<span class="font-semibold" v-if="project.summaryEmails">{{ project.frequency.toTitleCase() }}</span>
						<span v-else class="font-semibold">{{ $t( "None" ) }}</span>
						<ul v-if="project.summaryEmails" class="list-none">
							<span v-for="email in project.summaryEmails" class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-cyan-100 text-cyan-800">
								<a :href="`mailto:${email}`">{{ email }}</a>
							</span>
						</ul>
					</td>
					<td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
						<a v-if="hasPermission( 'Administer:Projects' )" @click="editProject( index )">{{ $t( "Edit" ) }}</a>
					</td>
				</tr>
			</tbody>
		</table>
		<project-form v-else :data="projects[ editIndex ]" :index="editIndex" @save-project="updateProject" @cancel-edit="resetForm"></project-form>
	</div>
</template>
<script>
import ProjectForm from "./ProjectForm";
import { mapGetters } from "vuex";
export default {
	components:{
		ProjectForm
	},
	data(){
		return{
			projects : [],
			showForm: false,
			newProject : {
				"name" : null,
				"description" : null,
				"url" : null,
				"icon" : null,
				"applications" : [],
				"beats" : [],
				"owner" : null,
				"summaryEmails" : false,
				"frequency" : "daily",
				"emailDistributionList" : []
			}
		}
	},
	props : {
		settings : {
			required : true
		}
	},
	computed : {
		activeProjects(){
			return this.projects.filter( item => !! item.name ).sort( (a,b) => a.name.localeCompare( b.name ) );
		},
		...mapGetters({
			hasPermission : "hasPermission"
		})
	},
	mounted(){
		this.projects = this.settings.projects.value || [];
		// this.projects = [];
		// this.saveProjects();
	},
	methods: {
		resetForm(){
			this.showForm = false;
			if( !this.projects[ this.editIndex ].name ){
				this.projects.splice( this.editIndex, 1 );
			}
			this.editIndex = null;
		},
		createProject(){
			this.projects.push( { ...this.newProject } );
			this.editIndex = this.projects.length - 1;
			this.$nextTick( () => this.showForm = true );
		},
		editProject( index ){
			this.editIndex = index;
			this.showForm = true;
		},
		updateProject( payload ){
			if( !payload.data.id ){
				payload.data.id = payload.data.name.slugify();
			}
			this.projects.splice( payload.index, 1, payload.data );
			this.saveProjects();
			this.$store.commit( "updateGlobal", { key : "projects", value : this.projects } );
			this.showForm = false;
		},
		saveProjects(){
			this.$emit( "update-projects", this.projects )
		}
	}
}
</script>
<template>
	<div class="border-gray-600 mb-3 project-snapshot">
		<h1 class="text-gray-600 text-3xl font-medium pb-2">
		{{ $t( "Project" ) }}: {{ project.name }}
		</h1>
		<h2 class="text-gray-600 text-2xl pb-2 mb-7 mt-7  border-gray-300 border-b">{{ $t( "Applications" ) }}:</h2>
		<template
			v-for="(application, index) in project.applications"
			:key="`application-${application}`"
		>
			<application-snapshot heading-class="h3" heading-size="lg" heading-color-class="text-teal-700" :application="application"></application-snapshot>
		</template>

		<template v-if="project.beats.length">
			<h2 class="text-gray-600 text-2xl font-medium pb-2 border-gray-300 border-b mt-7">{{ $t( "FileBeats" ) }}:</h2>
			<template v-for="(application, index) in project.beats">
				<h3 class="text-teal-700 text-lg font-medium pb-2 border-gray-300 border-b mt-5">{{ application.toTitleCase() }}</h3>
				<beats-list
					:initialFilters='{ "fields.application" : application, sortOrder : "@timestamp DESC" }'
				></beats-list>
			</template>
		</template>


	</div>
</template>
<script>
import ApplicationSnapshot from "./ApplicationSnapshot";
import BeatsList from "@/components/entries/BeatsList";
import { mapState } from "vuex";
export default {
	components: {
		ApplicationSnapshot,
		BeatsList
	},
    computed: {
        ...mapState({
            project( state ){
				return state.globals.stachebox.projects.find( project => project.id == this.$route.params.id );
			}
        })
    }
}
</script>
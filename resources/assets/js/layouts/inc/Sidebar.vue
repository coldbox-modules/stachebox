<template>
  <div class="flex transform" :class="isOpen ? 'opacity-100' : 'opacity-0 hidden'">
    <div
      :class="isOpen ? 'translate-x-0 ease-out' : '-translate-x-full ease-in'"
      class="fixed z-30 inset-y-0 left-0 w-64 transition duration-300 transform bg-gray-800 overflow-y-auto lg:translate-x-0 lg:static lg:inset-0"
    >
      <nav class="mt-10">
		<h2
			class="flex items-center duration-200 mt-2 py-2 px-4 border-l-4 text-gray-400"
			:class="[$route.name === 'Dashboard' ? activeClass : inactiveClass]"
		>
			<router-link
			to="/dashboard"
			>
			<fa-icon icon="chart-pie" fixed-width/>
			<span class="mx-4">{{ $t( "Dashboard" ) }}</span>
			</router-link>
		</h2>

		<template v-if="projects.length">
			<details class="group" open>
				<summary class="flex flex-wrap focus-visible:outline-none focus-visible:ring
				rounded group-open:rounded-b-none group-open:z-[1] relative
				">
					<h3 class="flex flex-1 items-center ml-5 mr-5 pt-4 pb-1 pr-1 pl-1 text-gray-400">
					<span class="flex-1"><fa-icon icon="cubes" class="mr-1" fixed-width/>{{ $t( "Projects" ) }}</span>
					<div class="flex-2">
						<div class="border-8 border-transparent border-l-gray-600 ml-2
						group-open:rotate-90 transition-transform origin-left
						"></div>
					</div>
					</h3>
				</summary>
				<div>
					<router-link
						v-for="( projects, index ) in project"
						:key="index"
						class="flex items-center duration-200 mt-2 py-1 px-8"
						:class="[$route.name === 'ProjectSnapshot' && $route.params.id == project.id ? activeClass : inactiveClass]"
						:to="`/project/${project.id}`"
					>
						<div
							v-if="project.icon"
							class="relative z-10 block h-8 w-8 rounded-full overflow-hidden shadow"
						>
							<img
								class="h-full w-full object-cover"
								:src="project.icon"
								:alt="`Icon for ${project.name}`"
							/>
						</div>
						<fa-icon v-else icon="cube" fixed-width/>
						<span class="mx-4">{{ project.name }}</span>
					</router-link>
				</div>
			</details>
		</template>

		<template v-if="orderedApplications">
			<details class="group">
				<summary class="flex flex-wrap focus-visible:outline-none focus-visible:ring
				rounded group-open:rounded-b-none group-open:z-[1] relative
				">
					<h3 class="flex flex-1 items-center ml-5 mr-5 pt-4 pb-1 pr-1 pl-1 text-gray-400">
					<span class="flex-1"><fa-icon icon="cubes" class="mr-1" fixed-width/>{{ $t( "Applications" ) }}</span>
					<div class="flex-2">
						<div class="border-8 border-transparent border-l-gray-600 ml-2
						group-open:rotate-90 transition-transform origin-left
						"></div>
					</div>
					</h3>
				</summary>
				<div>
					<router-link
						v-for="( application, index ) in orderedApplications"
						:key="index"
						class="flex items-center duration-200 mt-2 py-1 px-8"
						:class="[$route.name === 'ApplicationLogs' && $route.params.id == application && !$route.params.environment ? activeClass : inactiveClass]"
						:to="`/logs/application/${application}`"
					>
						<fa-icon icon="cube" fixed-width/>
						<span class="mx-4">{{ $filters.truncate( application.toTitleCase(), 15 ) }}</span>
					</router-link>
				</div>
			</details>
		</template>

		<template v-if="aggregations && aggregations.environments && Object.keys( aggregations.environments ).length">
			<details class="group">
				<summary class="flex flex-wrap focus-visible:outline-none focus-visible:ring
				rounded group-open:rounded-b-none group-open:z-[1] relative
				">
					<h3 class="flex flex-1 items-center ml-5 mr-5 pt-4 pb-1 pr-1 pl-1 text-gray-400">
					<span class="flex-1"><fa-icon icon="leaf" class="mr-1" fixed-width/>{{ $t( "Environments" ) }}</span>
					<div class="flex-2">
						<div class="border-8 border-transparent border-l-gray-600 ml-2
						group-open:rotate-90 transition-transform origin-left
						"></div>
					</div>
					</h3>
				</summary>
				<div>
					<template v-for="environment in Object.keys( aggregations.environments )" :key="`environment-${environment}`">
						<h4 class="ml-7 mr-5 pl-1 mt-5 pb-1 text-gray-600 border-gray-800"><fa-icon icon="globe" class="mr-1" fixed-width/>{{ environment.toTitleCase() }}</h4>
						<router-link
							v-for="(application,index) in Object.keys( aggregations.environments[ environment ].applications ).sort( (a,b) => a.localeCompare( b ) )"
							:key="index"
							class="flex items-center duration-200 mt-2 py-1 px-8"
							:class="[$route.name === 'ApplicationLogs' && $route.params.id == application && $route.params.environment == environment ? activeClass : inactiveClass]"
							:to="`/logs/application/${application}/${environment.toLowerCase()}`"
						>
							<fa-icon icon="cube" fixed-width/>
							<span class="mx-4">{{ $filters.truncate( application.toTitleCase(), 15 ) }}</span>
						</router-link>
					</template>
				</div>
			</details>
		</template>

		<template v-if="beatsAggregations && ( beatsAggregations.datasets || beatsAggregations.inputTypes )">
			<details class="group">
				<summary class="flex flex-wrap focus-visible:outline-none focus-visible:ring
				rounded group-open:rounded-b-none group-open:z-[1] relative
				">
					<h3 class="flex flex-1 items-center ml-5 mr-5 pt-4 pb-1 pr-1 pl-1 text-gray-400">
						<span class="flex-1"><fa-icon icon="heartbeat" class="mr-1" fixed-width/> {{ $t( "FileBeats" ) }}</span>
						<div class="flex-2">
							<div class="border-8 border-transparent border-l-gray-600 ml-2
							group-open:rotate-90 transition-transform origin-left
							"></div>
						</div>
					</h3>
				</summary>
				<div>
					<template v-if="Object.keys( beatsAggregations.datasets ).length">
						<router-link
							v-for="(dataset) in Object.keys( beatsAggregations.datasets )"
							:key="dataset"
							class="flex items-center duration-200 mt-2 py-2 px-6 border-l-4"
							:class="[$route.name === 'DatasetLogs' && $route.params.id == dataset ? activeClass : inactiveClass]"
							:to="`/logs/dataset/${dataset}`"
						>
							<span class="mx-4">{{ $filters.truncate( $filters.datasetName( dataset ), 15 ) }}</span>
						</router-link>
					</template>
					<template v-if="Object.keys( beatsAggregations.inputTypes ).length">
						<router-link
							v-for="(type) in Object.keys( beatsAggregations.inputTypes )"
							:key="type"
							class="flex items-center duration-200 mt-2 py-2 px-6 border-l-4"
							:class="[$route.name === 'DatasetLogs' && $route.params.id == type ? activeClass : inactiveClass]"
							:to="`/logs/type/${type}`"
						>
							<fa-icon icon="heartbeat" fixed-width/>
							<span class="mx-4">{{$t( "All {type} Entries", { type: type.toTitleCase() } )}}</span>
						</router-link>
					</template>
				</div>
			</details>
		</template>

		<template v-if="hasPermission( 'Administer:Settings' )">
			<details class="group">
				<summary class="flex flex-wrap focus-visible:outline-none focus-visible:ring
				rounded group-open:rounded-b-none group-open:z-[1] relative
				">
					<h3 class="flex flex-1 items-center ml-5 mr-5 pt-4 pb-1 pr-1 pl-1 text-gray-400">
						<span class="flex-1"><fa-icon icon="cogs" class="mr-1" fixed-width/>{{ $t( "Administration" ) }}</span>
						<div class="flex-2">
							<div class="border-8 border-transparent border-l-gray-600 ml-2
							group-open:rotate-90 transition-transform origin-left
							"></div>
						</div>
					</h3>
				</summary>
				<div>
					<router-link
					class="flex items-center duration-200 mt-2 py-2 px-6 border-l-4"
					:class="[$route.name === 'Settings' ? activeClass : inactiveClass]"
					:to="{ name : 'Settings' }"
					>
						<fa-icon icon="cogs" fixed-width/>
						<span class="mx-4">{{ $t( "Settings" ) }}</span>
					</router-link>

					<router-link
					class="flex items-center duration-200 mt-2 py-2 px-6 border-l-4"
					:class="[$route.name === 'Directory' ? activeClass : inactiveClass]"
					:to="{ name : 'Directory' }"
					>
						<fa-icon icon="users" fixed-width/>
						<span class="mx-4">{{ $t( "Users" ) }}</span>
					</router-link>
				</div>
			</details>
		</template>

      </nav>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapState } from "vuex";
export default{
	props:{
		isOpen : {
			type: Boolean,
			default : true
		}
	},
	data(){
		return {
			activeClass : "bg-gray-600 bg-opacity-25 text-gray-100 border-gray-100",
			inactiveClass : "border-gray-900 text-gray-500 hover:bg-gray-600 hover:bg-opacity-25 hover:text-gray-100",
		}
	},
	computed : {
		...mapGetters({
			hasPermission : "hasPermission",
			orderedApplications: "orderedApplications"
		}),
		...mapState({
			authToken : ( state ) => state.authToken,
			aggregations : ( state ) => state.navAggregations,
			beatsAggregations : ( state ) => state.navAggregations ? state.navAggregations.beatsAggregations : null,
			baseHref : ( state ) => state.globals.stachebox.baseHref,
			projects : ( state ) => state.globals.stachebox.projects
		})
	}
}

</script>

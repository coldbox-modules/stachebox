<template>
    <div>
		<div class="user-directory">
			<h3 class="text-gray-500 text-xl font-medium pb-2 border-gray-300 border-b">{{ $t( "User Directory" ) }}</h3>
		</div>
        <section>
			<div class="float-right" v-if='hasPermission( "Administer:Users" )'>
                <button
                    type="button"
                    class="py-2 px-4 text-center bg-green-600 w-full text-white text-sm"
                    @click="$router.push( { name : 'NewUser' } )">
                    <fa-icon icon="plus"/> {{ $t( "New User" ) }}
                </button>
            </div>
			<table v-if="users" class="min-w-full divide-y divide-gray-200">
				<thead class="bg-gray-50">
					<tr>
						<th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
							Name
						</th>
						<th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
							Title
						</th>
						<th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
							Status
						</th>
						<th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
							Role
						</th>
						<th scope="col" class="relative px-6 py-3">
							<span class="sr-only">Edit</span>
						</th>
					</tr>
				</thead>
				<tbody class="bg-white divide-y divide-gray-200">
					<tr v-for="user in users" :key="user.id" >
						<td class="px-6 py-4 whitespace-nowrap">
							<div class="flex items-center">
							<div class="flex-shrink-0 h-10 w-10">
								<img class="h-10 w-10 rounded-full" :src="user.avatar" alt="">
							</div>
							<div class="ml-4">
								<div class="text-sm font-medium text-gray-900">
								{{ user.firstName }} {{ user.lastName }}
								</div>
								<div class="text-sm text-gray-500">
								{{ user.email }}
								</div>
							</div>
							</div>
						</td>
						<td class="px-6 py-4 whitespace-nowrap">
							<div class="text-sm text-gray-900">{{ user.title || 'N/A' }}</div>
						</td>
						<td class="px-6 py-4 whitespace-nowrap">
							<span v-if="user.isActive" class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
							Active
							</span>
							<span v-else class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
							Inactive
							</span>
						</td>
						<td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
							{{ user.isAdministrator ? 'Admin' : 'User' }}
						</td>
						<td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
							<router-link :to="`/users/edit/${user.id }`" class="text-cyan-600 hover:text-cyan-900">Edit</router-link>
						</td>
					</tr>
				</tbody>
			</table>
			<div v-else class="mt-4 text-center items-center">
				<fa-icon size="3x" class="text-gray-400" icon="circle-notch" spin fixed-width />
				<p class="mt-4 text-gray-400">Loading User Directory...</p>
			</div>
        </section>
    </div>
</template>

<script>
import { mapState, mapGetters } from "vuex";
import usersAPI from "@/api/users";
export default {
	data(){
		return {
			usersData : undefined
		}
	},
	computed :{
		...mapGetters({
			hasPermission : "hasPermission"
		}),
		...mapState({
			authUser : state => state.authUser,
			authToken : state => state.authToken
		}),
		users(){
			return this.usersData ? this.usersData.results : undefined;
		}
	},
	methods : {
		fetchUsers(){
			usersAPI.list( { "sortOrder" : "lastName DESC, firstName DESC" }, this.authToken )
				.then( result => this.usersData = result.data )
		}
	},
	created(){
		this.fetchUsers();
	}

};
</script>

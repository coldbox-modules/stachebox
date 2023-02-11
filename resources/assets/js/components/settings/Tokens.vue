<template>
	<div>
		<h3 class="text-gray-700 text-3xl font-medium">{{ $t( "API Tokens" ) }}</h3>
		<table class="min-w-full divide-y mt-10 divide-gray-200">
				<thead class="bg-gray-50">
					<tr>
						<th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
							{{ $t( "Created" ) }}
						</th>
						<th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
							{{ $t( "Permissions" ) }}
						</th>
						<th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
							{{ $t( "Expires" ) }}
						</th>
						<th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
							{{ $t( "Token Value" ) }}
						</th>
						<th scope="col" class="relative px-6 py-3">
							<span class="sr-only">{{ $t( "Actions" ) }}</span>
						</th>
					</tr>
				</thead>
				<tbody v-if="tokens.length" class="bg-white divide-y divide-gray-200">
					<tr v-for="item in tokenList" :key="item.token" >
						<td class="px-6 py-4 whitespace-nowrap text-gray-500">
							{{ dayjs( new Date( item.claims.iat * 1000 ) ).format('L LT') }}
						</td>
						<td class="px-6 py-4 whitespace-nowrap text-gray-500">
							<ul class="list-unstyled">
								<li v-for="perm in item.claims.scope.split( ' ' )" key="perm">
									<span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-teal-100 text-teal-800">
									{{ perm }}
									</span>
								</li>
							</ul>
						</td>
						<td class="px-6 py-4 whitespace-nowrap text-gray-500">
							{{ item.claims.exp ? dayjs( new Date( item.claims.exp ) ).format('LLL') : $t( "Never" ) }}
						</td>
						<td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
							<code>{{ item.token.substring( 0, 25 ) }}...</code> <a class="text-teal-800" @click="clip( item.token )"><fa-icon icon="share" v-tooltip="$t( 'Copy token' )"></fa-icon></a>
						</td>
						<td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
							<VDropdown placement="left" distance="6">
								<button
									type="button"
									class="text-red-400 hover:text-red-600"
								>
									<fa-icon icon="trash" v-tooltip="$t( 'Delete this token' )" fixed-width></fa-icon>
								</button>
								<template #popper>
									<div class="p-5">
										<p class="text-gray-700 text-sm" style="max-width:350px">{{ $t( 'tokens.confirmation.message' ) }}</p>
										<div class="mt-2 text-right">
											<button class="py-2 px-4 mr-1 text-center bg-gray-400 text-gray-100 text-sm" type="button" v-close-popper>Cancel</button>
											<button class="py-2 px-4 text-center bg-green-600 text-gray-100 text-sm" type="button" v-close-popper @click="deleteToken( item.token )">Yes</button>
										</div>
									</div>
								</template>
							</VDropdown>
						</td>
					</tr>
				</tbody>
				<tbody v-else>
					<tr>
					<td colspan="5" class="text-sm text-gray-400 align-center text-center" v-text="$t( 'tokens.emptyState' )"></td>
					</tr>
				</tbody>
			</table>

			<p class="align-center">

				<VDropdown distance="6">
					<button
						type="button"
						class="py-2 px-4 mt-10 text-center bg-theme w-full text-white text-sm"
					>
						<span v-if="!isGenerating"><fa-icon icon="plus" v-tooltip="$t( 'Create a new token' )" fixed-width></fa-icon> {{ $t( "Generate New API Token" ) }}</span>
						<span v-else><fa-icon icon="spinner" spin></fa-icon> {{ $t( "Creating New API Token" ) }}...</span>
					</button>
					<template #popper>
						<div class="p-5">
							<p class="text-gray-700 text-sm">{{ $t( 'tokenGenerateConfirm' ) }}</p>
							<div class="mt-2 text-right">
								<button class="py-2 px-4 mr-1 text-center bg-gray-400 text-gray-100 text-sm" type="button" v-close-popper>Cancel</button>
								<button class="py-2 px-4 text-center bg-green-600 text-gray-100 text-sm" type="button" v-close-popper @click="generateNewToken">Yes</button>
							</div>
						</div>
					</template>
				</VDropdown>
			</p>

	</div>
</template>
<script>
import ConfirmationButton from "@/components/ConfirmationButton";
import api from "@/api/index";
import VueJwtDecode from 'vue-jwt-decode';
import { mapState } from "vuex";
export default {
	components : {
		ConfirmationButton
	},
	data(){
		return {
			isGenerating : false,
			tokens : []
		}
	},
	props : {
		settings : {
            required: true,
            twoWay  : true
		}
	},
	computed: {
		...mapState({
			authToken : ( state ) => state.authToken
		}),
		tokenList(){
			return this.tokens.map(
				token => ({
					"token" : token,
					"claims" : VueJwtDecode.decode( token )
				})
			);
		}
	},
	mounted(){
		this.tokens = this.settings.apiTokens.value;
	},
	methods : {
		generateNewToken(){
			this.isGenerating = true;
			api.newToken( this.authToken ).then( result => this.tokens.push( result.data.token ) ).then( () => this.$emit( "update-tokens", this.tokens ) ).finally( () => this.isGenerating = false );
		},
		clip( token ){
			navigator.clipboard.writeText( token );
		},
		deleteToken( token ){
			this.tokens.splice( this.tokens.findIndex( item => item.token == token ) );
			this.$emit( "update-tokens", this.tokens );
		}
	}
}
</script>
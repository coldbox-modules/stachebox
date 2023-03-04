<template>
	<div>
		<h2 class="text-gray-700 text-2xl font-medium">{{ $t( "Logging Settings" ) }}</h2>
		<table v-if="settings" class="text-left table-fixed border-collapse mt-5">
			<tbody>
				<tr class="border-b">
					<th class="py-3 px-3 w-1/3 text-medium text-gray-600">{{ $t( "Logstash Log Index Pattern" ) }}: <a v-tooltip="$t( 'The index pattern to search for application-provided log entries' )"><fa-icon class="text-theme text-xs" icon="info-circle"/></a></th>
					<td class="py-3 px-3 w-2/3">
						<input class="form-input rounded-none mt-1 w-full focus:border-cyan-600" v-model="settings.logIndexPattern.value"/>
					</td>
				</tr>
				<tr class="border-b">
					<th class="py-3 px-3 w-1/3 text-medium text-gray-600">{{ $t( "Filebeats Log Index Pattern" ) }}: <a v-tooltip="$t( 'beatIndexPatternSearchTip' )"><fa-icon class="text-theme text-xs" icon="info-circle"/></a></th>
					<td class="py-3 px-3 w-2/3">
						<input class="form-input rounded-none mt-1 w-full focus:border-cyan-600" v-model="settings.beatsIndexPattern.value"/>
					</td>
				</tr>
				<tr class="border-b">
					<th class="py-3 px-3 w-1/3 text-medium text-gray-600">{{ $t( "Omit from entry data" ) }}: <a v-tooltip="$t( 'Regex pattern which denotes any fields which should be omitted from log API output' )"><fa-icon class="text-theme text-xs" icon="info-circle"/></a></th>
					<td class="py-3 px-3 w-2/3">
						<input class="form-input rounded-none mt-1 w-full focus:border-cyan-600" v-model="settings.neverExpose.value"/>
					</td>
				</tr>
				<tr>
					<td colspan="2 items-right">
						<button
						@click="$emit( 'update-settings' )"
						class="float-right mt-10 justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-none text-white bg-cyan-600 hover:bg-cyan-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-cyan-500 disabled:opacity-50"
						><fa-icon icon="save"></fa-icon> {{ $t( "Update Settings" ) }}</button>
					</td>
				</tr>
			</tbody>
		</table>
	</div>
</template>
<script>
import settingsAPI from "@/api/settings";
import { mapGetters } from "vuex";
export default {
	props : {
		settings : {
            required: true,
            twoWay  : true
		}
	},
	computed: {
		...mapGetters({
			hasPermission : "hasPermission"
		})
	}
}
</script>
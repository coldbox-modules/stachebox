<template>
	<div>
		<h3 class="text-gray-700 text-3xl font-medium">Logging Settings</h3>
		<table v-if="settings" class="text-left table-fixed border-collapse mt-5">
			<tbody>
				<tr class="border-b">
					<th class="py-3 px-3 w-1/3 text-medium text-gray-600">Logstash Log Index Pattern: <a v-tooltip="'The index pattern to search for application-provided log entries'"><fa-icon class="text-theme text-xs" icon="info-circle"/></a></th>
					<td class="py-3 px-3 w-2/3">
						<input class="form-input rounded-none mt-1 w-full focus:border-cyan-600" v-model="settings.logIndexPattern.value"/>
					</td>
				</tr>
				<tr class="border-b">
					<th class="py-3 px-3 w-1/3 text-medium text-gray-600">Filebeats Log Index Pattern: <a v-tooltip="'The index pattern to search for filebeat ( e.g. machine ) log entries'"><fa-icon class="text-theme text-xs" icon="info-circle"/></a></th>
					<td class="py-3 px-3 w-2/3">
						<input class="form-input rounded-none mt-1 w-full focus:border-cyan-600" v-model="settings.beatsIndexPattern.value"/>
					</td>
				</tr>
				<tr class="border-b">
					<th class="py-3 px-3 w-1/3 text-medium text-gray-600">Omit from entry data: <a v-tooltip="'Regex pattern which denotes any fields which should be omitted from log API output'"><fa-icon class="text-theme text-xs" icon="info-circle"/></a></th>
					<td class="py-3 px-3 w-2/3">
						<input class="form-input rounded-none mt-1 w-full focus:border-cyan-600" v-model="settings.neverExpose.value"/>
					</td>
				</tr>
				<tr>
					<td colspan="2 items-right">
						<button
						@click="$emit( 'update-settings' )"
						class="block mt-10 float-right items-center px-3 py-2 border border-transparent shadow-sm text-sm leading-4 font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
						><fa-icon icon="save"></fa-icon> Update Settings</button>
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
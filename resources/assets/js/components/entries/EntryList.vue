<template>
	<div class="mt-10">
		<h3 class="text-xl font-medium text-gray-500 mb-5" v-if="application">Application: {{application.toTitleCase()}}</h3>
		<table class="min-w-full">
			<thead>
				<tr>
				<th
					v-if="!application"
					class="px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider"
				>
					Application
				</th>
				<th
					class="px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider"
				>
					Time
				</th>
				<th
					class="px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider"
				>
					Type
				</th>
				<th
					v-if="displayOccurrences"
					class="px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider"
				>
					Occurrences
				</th>
				<th
					class="px-6 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase tracking-wider"
				>
					Message
				</th>
				<th class="px-6 py-3 border-b border-gray-200 bg-gray-50"></th>
				</tr>
			</thead>

			<tbody class="bg-white">
				<tr v-for="(entry, index) in logs" :key="index">
				<td
					v-if="!application"
					class="px-6 py-4 whitespace-no-wrap border-b border-gray-200 text-sm text-gray-500"
				>
					{{entry.application || 'N/A'}}
				</td>

				<td
					class="px-6 py-4 whitespace-no-wrap border-b border-gray-200 text-sm text-gray-500"
				>
				{{ dayjs( entry['@timestamp' ] ).format('YYYY-MM-DD HH:mm:ss') }}
				</td>
				<td
					class="px-6 py-4 whitespace-no-wrap border-b border-gray-200 text-sm text-gray-500"
				>
					{{entry.type.toTitleCase()}}
				</td>
				<td
					v-if="displayOccurrences"
					class="px-6 py-4 whitespace-no-wrap border-b border-gray-200 text-sm text-gray-500"
				>
					<span class="inline-flex items-center justify-center px-2 py-1 text-xs leading-none text-white bg-theme rounded-full">{{ entry.occurrences || 1 }}</span>
				</td>
				<td
					class="px-6 py-4 border-b border-gray-200 text-sm leading-5 text-gray-500"
				>
					<code class="text-yellow-500 text-xs">{{ entry.message | truncate( truncate ? 250 : entry.message.length + 1 ) }}</code>
				</td>

				<td
					class="px-6 py-4 whitespace-no-wrap text-right border-b border-gray-200 text-sm leading-5 font-medium"
				>
					<router-link :to="`/logs/entry/${entry.id}`" class="text-teal-600 hover:text-teal-900">
					View
					</router-link>
				</td>
				</tr>
			</tbody>
		</table>

	</div>

</template>
<script>
import dayjs from "dayjs";
import utc from "dayjs/plugin/utc";
import timezone from "dayjs/plugin/timezone";
dayjs.extend( utc );
dayjs.extend( timezone );
dayjs.tz.setDefault( dayjs.tz.guess() );
export default {
	props : {
		logs : {
			type : Array,
			required : true
		},
		application : {
			type : String,
			required : false
		},
		truncate : {
			type : Boolean,
			default : true
		},
		displayOccurrences : {
			type : Boolean,
			default : true
		}
	},
	data(){
		return {
		  dayjs : dayjs
		};
	}
}
</script>
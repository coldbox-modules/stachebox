<template>
	<div class="entry default-entry">
		<div class="entry-info text-sm">

			<!----------------------------------------------------------------------------------------->
			<!--- Top Left Exception Area --->
			<!----------------------------------------------------------------------------------------->
			<h2 class="text-3xl font-medium text-gray-500"><fa-icon icon="file-alt" fixed-width /> Log Entry Info</h2>
			<table class="text-left table-fixed border-collapse mt-5">
				<tbody>
					<tr v-if="entry.application">
						<th class="w-1/3 align-top">Application ID:</th>
						<td class="w-2/3">{{ entry.application }}</td>
					</tr>
					<tr>
						<th class="w-1/3 align-top">Release Version:</th>
						<td class="w-2/3">{{ entry.release || 'N/A' }}</td>
					</tr>
					<tr>
						<th class="w-1/3 align-top">Level:</th>
						<td class="w-2/3">{{entry.level || 'N/A'}} <span v-if="entry.severity">( Severity {{entry.severity}} )</span></td>
					</tr>
					<tr v-if="entry.type">
						<th class="w-1/3 align-top">Type:</th>
						<td class="w-2/3">{{entry.type}}</td>
					</tr>
					<tr>
						<th class="w-1/3 align-top">Occurred At:</th>
						<td class="w-2/3">{{ dayjs( entry[ '@timestamp' ] ).format('YYYY-MM-DD HH:mm:ss') }}</td>
					</tr>
					<tr v-if="entry.category">
						<th class="w-1/3 align-top">Category:</th>
						<td class="w-2/3">{{ entry.category }}</td>
					</tr>
					<tr v-if="entry.component">
						<th class="w-1/3 align-top">Component:</th>
						<td class="w-2/3">{{ entry.component }}</td>
					</tr>
					<tr v-if="entry.appendername">
						<th class="w-1/3 align-top">Appender:</th>
						<td class="w-2/3">{{ entry.appendername }}</td>
					</tr>
					<!-- if we have a verb key, it's an Apache/NGINX log format -->
					<tr v-if="!entry.verb">
						<th class="w-1/3 align-top">Message:</th>
						<td class="w-2/3">
							<code class="language-javastacktrace">{{ entry.message }}</code>
						</td>
					</tr>
				</tbody>
			</table>

			<!-- Apache/NGINX log format -->
			<h2 v-if="entry.verb" class="text-3xl font-medium text-gray-500"><fa-icon icon="file-alt" fixed-width /> HTTP Request Info</h2>
			<table v-if="entry.verb" class="text-left table-fixed border-collapse mt-5">
				<tbody>
					<tr v-if="entry.request">
						<th class="w-1/3 align-top">Request:</th>
						<td class="w-2/3">{{ entry.request }}</td>
					</tr>
					<tr v-if="entry.verb">
						<th class="w-1/3 align-top">HTTP Verb:</th>
						<td class="w-2/3">{{ entry.verb }}</td>
					</tr>
					<tr v-if="entry.response">
						<th class="w-1/3 align-top">Response Code:</th>
						<td class="w-2/3">{{ entry.response }}</td>
					</tr>
					<tr v-if="entry.agent">
						<th class="w-1/3 align-top">User Agent:</th>
						<td class="w-2/3">{{ entry.agent }}</td>
					</tr>
					<tr v-if="entry.referrer">
						<th class="w-1/3 align-top">Referrer:</th>
						<td class="w-2/3">{{ entry.referrer }}</td>
					</tr>
					<tr v-if="entry.name">
						<th class="w-1/3 align-top">Machine Name:</th>
						<td class="w-2/3">{{ entry.name }}</td>
					</tr>
					<tr v-if="entry.hostname">
						<th class="w-1/3 align-top">Hostname:</th>
						<td class="w-2/3">{{ entry.hostname }}</td>
					</tr>
					<tr v-if="entry.clientip">
						<th class="w-1/3 align-top">Client IP:</th>
						<td class="w-2/3">{{ entry.clientip }}</td>
					</tr>
					<tr v-if="!entry.message">
						<th class="w-1/3 align-top">Raw Log Message:</th>
						<td class="w-2/3">
							<code class="language-javastacktrace">{{ entry.message }}</code>
						</td>
					</tr>
				</tbody>
			</table>

		</div>

	</div>
</template>
<script>
import dayjs from "dayjs";
import Prism from "prismjs";
import { formatJSONRaw } from "@/util/udf";
import 'prismjs/components/prism-javascript';
import 'prismjs/components/prism-json';
import 'prismjs/components/prism-sql';
import 'prismjs/components/prism-javastacktrace';
import Tab from "../../components/Tab";
import Tabs from "../../components/Tabs";

export default {
	components : {
		Tab,
		Tabs
	},
	props : {
		entry : {
			type : Object,
			required : true
		}
	},
	data(){
		return {
			dayjs : dayjs,
			activeTab : 0
		}
	},
	methods : {
		formatJSON : formatJSONRaw
	},
	mounted() {
		Prism.highlightAll()
	}

}
</script>
<template>
	<div class="entry default-entry">
		<div class="entry-info text-sm">

			<!----------------------------------------------------------------------------------------->
			<!--- Top Left Exception Area --->
			<!----------------------------------------------------------------------------------------->
			<h2 class="text-3xl font-medium text-gray-500"><fa-icon icon="file-alt" fixed-width />
				Entry Summary
				<entry-export-button :entry="entry"/>
			</h2>
			<table class="ml-4 text-left table-fixed border-collapse mt-5">
				<tbody>
					<template v-if="entry.event">
						<tr v-if="entry.event.dataset">
							<th class="w-1/3 align-top">Dataset:</th>
							<td class="w-2/3">{{ $filters.datasetName( entry.event.dataset ) }}</td>
						</tr>
					</template>
					<template v-if="entry.agent">
						<tr v-if="entry.agent.type">
							<th class="w-1/3 align-top">Log Agent Type:</th>
							<td class="w-2/3">{{ entry.agent.type.toTitleCase() }}</td>
						</tr>
						<tr v-if="entry.agent.hostname">
							<th class="w-1/3 align-top">Log Agent Host:</th>
							<td class="w-2/3">{{ entry.agent.hostname }}</td>
						</tr>
					</template>
					<template v-if="entry.host">
						<tr v-if="entry.host.ip && entry.host.ip.length">
							<th class="w-1/3 align-top">Host IP Address:</th>
							<td class="w-2/3">{{ entry.host.ip[ 0 ] }}</td>
						</tr>
					</template>
					<template v-if="entry.log">
						<tr v-if="entry.log.level">
							<th class="w-1/3 align-top">Level:</th>
							<td class="w-2/3">{{entry.log.level.toUpperCase() || 'N/A'}}</td>
						</tr>
						<tr v-if="entry.log.file">
							<th class="w-1/3 align-top">Machine File Path:</th>
							<td class="w-2/3">{{ entry.log.file.path }}</td>
						</tr>
					</template>
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
							<code class="text-yellow-600 text-xs">{{ entry.message }}</code>
						</td>
					</tr>
				</tbody>
			</table>

			<!-- Apache log format -->
			<h2 v-if="entry.verb" class="text-3xl font-medium text-gray-500 mt-20"><fa-icon icon="file-alt" fixed-width /> HTTP Request Info</h2>
			<table v-if="entry.verb" class="ml-4 text-left table-fixed border-collapse mt-5">
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

			<!-- NGINX access log format -->
			<h2 v-if="entry.http" class="text-3xl font-medium text-gray-500 mt-20"><fa-icon icon="file-alt" fixed-width /> HTTP Request Info</h2>
			<table v-if="entry.http" class="ml-4 text-left table-fixed border-collapse mt-5">
				<tbody>
					<template v-if="entry.url && entry.url.original">
						<tr>
							<th class="w-1/3 align-top">URL:</th>
							<td class="w-2/3">{{ entry.url.original }}</td>
						</tr>
					</template>
					<template v-if="entry.http.request">
						<tr v-if="entry.http.request.method">
							<th class="w-1/3 align-top">HTTP Verb:</th>
							<td class="w-2/3">{{ entry.http.request.method }}</td>
						</tr>
					</template>
					<template v-if="entry.http.response">
						<tr v-if="entry.http.response.status_code">
							<th class="w-1/3 align-top">Response Status Code:</th>
							<td class="w-2/3">{{ entry.http.response.status_code }}</td>
						</tr>
						<tr v-if="entry.http.response.body && entry.http.response.body.bytes">
							<th class="w-1/3 align-top">Response Body Size:</th>
							<td class="w-2/3">{{ entry.http.response.body.bytes }} bytes</td>
						</tr>
					</template>
					<tr v-if="entry.http.version">
						<th class="w-1/3 align-top">HTTP Version:</th>
						<td class="w-2/3">{{ entry.http.version }}</td>
					</tr>
				</tbody>
			</table>

			<div class="entry-detail mt-20">
				<h2 class="text-3xl font-medium text-gray-500">
					<fa-icon icon="search" fixed-width />
					Entry Detail
				</h2>

				<tabs class="mt-5">
					<tab v-if="entry.event" name="Event Detail">
						<pre><code class="language-json">{{formatJSON( JSON.stringify( entry.event ) )}}</code></pre>
					</tab>
					<tab v-if="entry.host" name="Host Detail">
						<pre><code class="language-json">{{formatJSON( JSON.stringify( entry.host ) )}}</code></pre>
					</tab>
					<tab v-if="entry.agent" name="Agent Detail">
						<pre><code class="language-json">{{formatJSON( JSON.stringify( entry.agent ) )}}</code></pre>
					</tab>
					<tab name="Raw Entry Data">
						<pre><code class="language-json">{{formatJSON( JSON.stringify( entry ) )}}</code></pre>
					</tab>
				</tabs>

			</div>

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
import EntryExportButton from './EntryExportButton';


export default {
	components : {
		Tab,
		Tabs,
		EntryExportButton
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
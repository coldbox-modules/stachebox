<template>
	<div class="entry default-entry">
		<div class="entry-info text-sm">

			<!----------------------------------------------------------------------------------------->
			<!--- Top Left Exception Area --->
			<!----------------------------------------------------------------------------------------->
			<h2 class="text-3xl font-medium text-gray-500"><fa-icon icon="bomb" fixed-width />
				Log Entry Information
				<entry-export-button :entry="entry"/>
			</h2>
			<table class="ml-4 text-left table-fixed border-collapse mt-5">
				<tbody>
					<tr class="border-b" v-if="entry.application">
						<th class="w-1/3 align-top">Application ID:</th>
						<td class="w-2/3">{{ entry.application }}</td>
					</tr>
					<tr class="border-b">
						<th class="w-1/3 align-top">Release Version:</th>
						<td class="w-2/3">{{ entry.release || 'N/A' }}</td>
					</tr>
					<tr class="border-b">
						<th class="w-1/3 align-top">Environment:</th>
						<td class="w-2/3">{{ entry.environment || 'N/A' }}</td>
					</tr>
					<tr class="border-b">
						<th class="w-1/3 align-top">Level:</th>
						<td class="w-2/3">{{entry.level || 'N/A'}} <span v-if="entry.severity">( Severity {{entry.severity}} )</span></td>
					</tr>
					<tr class="border-b" v-if="entry.type">
						<th class="w-1/3 align-top">Type:</th>
						<td class="w-2/3">{{entry.type}}</td>
					</tr>
					<tr class="border-b">
						<th class="w-1/3 align-top">Occurred At:</th>
						<td class="w-2/3">{{ dayjs( entry[ '@timestamp' ] ).format('YYYY-MM-DD HH:mm:ss') }}</td>
					</tr>
					<tr class="border-b" v-if="entry.category">
						<th class="w-1/3 align-top">Category:</th>
						<td class="w-2/3">{{ entry.category }}</td>
					</tr>
					<tr class="border-b" v-if="entry.component">
						<th class="w-1/3 align-top">Component:</th>
						<td class="w-2/3">{{ entry.component }}</td>
					</tr>
					<tr class="border-b" v-if="entry.appendername">
						<th class="w-1/3 align-top">Appender:</th>
						<td class="w-2/3">{{ entry.appendername }}</td>
					</tr>
					<tr class="border-b">
						<th class="w-1/3 align-top">Message:</th>
						<td class="w-2/3">
							<code class="text-yellow-600 text-xs">{{ entry.message }}</code>
						</td>
					</tr>
				</tbody>
			</table>
		</div>


		<div class="entry-detail mt-20" v-if="entry.extrainfo || entry.event || entry.snapshot || entry.stacktrace">
			<h2 class="text-3xl font-medium text-gray-500">
				<fa-icon icon="search" fixed-width />
				Exception Detail
			</h2>

			<tabs class="mt-5">
				<tab name="Stack Frames" v-if="entry.frames && entry.frames.length">
					<ul class="stackframes-list">
						<li
							v-for="( frame, index ) in reversedFrames"
							:key="index"
							class="stackframe"
						>
							<span class="badge">{{ index + 1 }}</span>
							<div class="stacktrace-info">
								<h3 class="stacktrace-location">
									{{frame.filename}}:<span class="stacktrace-line-number">{{frame.lineno}}</span>
								</h3>
								<pre><code class="language-javascript" v-html="frameContext( frame )"></code></pre>
							</div>
						</li>
					</ul>
				</tab>
				<tab name="Event Details" v-if="entry.event && Object.keys( entry.event ).length">
					<!-- Coldbox Event Information -->
					<table v-if="entry.event.name" class="text-left table-fixed border-collapse">
						<tbody>
							<tr class="border-b">
								<th class="w-1/3 align-top">Environment:</th>
								<td class="w-2/3">{{entry.event.environment}}</td>
							</tr>
							<tr v-if="entry.event.name" class="border-b">
								<th class="w-1/3 align-top">Name:</th>
								<td class="w-2/3">{{entry.event.name}}</td>
							</tr>
							<tr v-if="entry.event.route" class="border-b">
								<th class="w-1/3 align-top">Route:</th>
								<td class="w-2/3">{{entry.event.route}}</td>
							</tr>
							<tr v-if="entry.event.routed_url" class="border-b">
								<th class="w-1/3 align-top">URL:</th>
								<td class="w-2/3">{{entry.event.routed_url}}</td>
							</tr>
							<tr v-if="entry.event.layout" class="border-b">
								<th class="w-1/3 align-top">Layout:</th>
								<td class="w-2/3">{{entry.event.layout}}</td>
							</tr>
							<tr v-if="entry.event.module" class="border-b">
								<th class="w-1/3 align-top">Module:</th>
								<td class="w-2/3">{{entry.event.module}}</td>
							</tr>
							<tr v-if="entry.event.view" class="border-b">
								<th class="w-1/3 align-top">View:</th>
								<td class="w-2/3">{{entry.event.view}}</td>
							</tr>
						</tbody>
					</table>
					<!-- Other Event Information -->
					<pre v-else><code class="language-json">{{formatJSON( JSON.stringify( entry.event ) )}}</code></pre>
				</tab>
				<tab name="Framework Snapshot" v-if="entry.snapshot && Object.keys( entry.snapshot ).length">
					<table class="text-left table-fixed border-collapse">
						<tbody>
							<tr v-if="entry.snapshot.path" class="border-b">
								<th class="w-1/3 align-top">Path:</th>
								<td class="w-2/3">{{entry.snapshot.path}}</td>
							</tr>
							<tr v-if="entry.snapshot.host" class="border-b">
								<th class="w-1/3 align-top">Host:</th>
								<td class="w-2/3">{{entry.snapshot.host}}</td>
							</tr>
							<tr v-if="entry.snapshot.referrer" class="border-b">
								<th class="w-1/3 align-top">Referrer:</th>
								<td class="w-2/3">{{entry.snapshot.referrer}}</td>
							</tr>
							<tr v-if="entry.snapshot.browser" class="border-b">
								<th class="w-1/3 align-top">Browser:</th>
								<td class="w-2/3">{{entry.snapshot.browser}}</td>
							</tr>
							<tr v-if="entry.snapshot.remote_address" class="border-b">
								<th class="w-1/3 align-top">Referrer:</th>
								<td class="w-2/3">{{entry.snapshot.remote_address}}</td>
							</tr>
						</tbody>
					</table>
				</tab>

				<tab name="Database" v-if="entry.extrainfo && entry.extrainfo.database && Object.keys( entry.extrainfo.database ).length">
					<table class="text-left table-fixed border-collapse">
						<tbody>
							<tr v-if="entry.extrainfo.database.nativeErrorCode" class="border-b">
								<th class="w-1/3 align-top">Native Error Code:</th>
								<td class="w-2/3">{{entry.extrainfo.database.nativeErrorCode}}</td>
							</tr>
							<tr v-if="entry.extrainfo.database.SQLState" class="border-b">
								<th class="w-1/3 align-top">SQL State:</th>
								<td class="w-2/3">{{entry.extrainfo.database.SQLState}}</td>
							</tr>
							<tr v-if="entry.extrainfo.database.queryError" class="border-b">
								<th class="w-1/3 align-top">Query Error:</th>
								<td class="w-2/3">{{entry.extrainfo.database.queryError}}</td>
							</tr>
							<tr v-if="entry.extrainfo.database.SQL" class="border-b">
								<th class="w-1/3 align-top">SQL:</th>
								<td class="w-2/3">
									<pre><code class="language-sql">{{entry.extrainfo.database.SQL}}</code></pre>
								</td>
							</tr>
							<tr v-if="entry.extrainfo.database.where" class="border-b">
								<th class="w-1/3 align-top">Where Clause(s):</th>
								<td class="w-2/3">
									<pre><code class="language-sql">{{entry.extrainfo.database.where}}</code></pre>
								</td>
							</tr>
						</tbody>
					</table>
				</tab>

				<tab name="Locks" v-if="entry.extrainfo && entry.extrainfo.lock && Object.keys( entry.extrainfo.lock ).length">
					<table class="text-left table-fixed border-collapse">
						<tbody>
							<tr v-if="entry.extrainfo.lock.name" class="border-b">
								<th class="w-1/3 align-top">Lock Name:</th>
								<td class="w-2/3">{{entry.extrainfo.lock.name}}</td>
							</tr>
							<tr v-if="entry.extrainfo.lock.operation" class="border-b">
								<th class="w-1/3 align-top">Lock Operation:</th>
								<td class="w-2/3">{{entry.extrainfo.lock.operation}}</td>
							</tr>
						</tbody>
					</table>
				</tab>

				<tab name="HTTP Request Data" v-if="entry.extrainfo && entry.extrainfo.httpData && Object.keys( entry.extrainfo.httpData ).length">
					<table class="text-left table-fixed border-collapse">
						<tbody>
							<tr v-if="entry.extrainfo.httpData.protocol" class="border-b">
								<th class="w-1/3 align-top">Protocol:</th>
								<td class="w-2/3">{{entry.extrainfo.httpData.protocol}}</td>
							</tr>
							<tr v-if="entry.extrainfo.httpData.method" class="border-b">
								<th class="w-1/3 align-top">Protocol:</th>
								<td class="w-2/3">{{entry.extrainfo.httpData.method}}</td>
							</tr>
							<tr v-if="entry.extrainfo.httpData.content" class="border-b">
								<th class="w-1/3 align-top">Content Body:</th>
								<td class="w-2/3">
									<pre><code class="language-json">{{formatJSON( entry.extrainfo.httpData.content )}}</code></pre>
								</td>
							</tr>
							<tr v-if="entry.extrainfo.httpData.headers && Object.keys( entry.extrainfo.httpData.headers ).length" class="border-b">
								<th class="w-1/3 align-top">Headers:</th>
								<td class="w-2/3">
									<table class="text-left table-fixed border-collapse">
										<tbody>
											<tr v-for="(key, index) in Object.keys( entry.extrainfo.httpData.headers )" :key="index" class="border-b">
												<th class="w-1/3 align-top">{{key}}</th>
												<td class="w-2/3">{{entry.extrainfo.httpData.headers[ key ]}}</td>
											</tr>
										</tbody>
									</table>
								</td>
							</tr>
						</tbody>
					</table>
				</tab>

				<tab name="Raw Stack Trace" v-if="entry.extrainfo && entry.extrainfo.javaStackTrace && entry.extrainfo.javaStackTrace.length">
					<code class="language-javastacktrace">{{entry.extrainfo.javaStackTrace}}</code>
				</tab>

				<tab name="Raw Stack Trace" v-else-if="entry.extrainfo && !entry.extrainfo.javaStackTrace && entry.extrainfo._stacktrace">
					<code class="language-javastacktrace">{{entry.extrainfo._stacktrace}}</code>
				</tab>

				<tab name="Raw Stack Trace" v-else-if="entry.stacktrace">
					<pre v-if="Array.isArray( entry.stacktrace )"><code class="language-javastacktrace">{{entry.stacktrace.join( "\n" )}}</code></pre>
					<pre v-else><code class="language-javastacktrace">{{entry.stacktrace}}</code></pre>
				</tab>

				<tab v-if="multipleOccurrences" name="Occurrences">
					<entry-list
						v-if="multipleOccurrences"
						:initialFilters='{ "stachebox.signature" : entry.stachebox.signature, sortOrder : "timestamp DESC" }'
						:displayOccurrences="false"
						:displayApplication="false"
					></entry-list>
				</tab>

			</tabs>
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
import EntryList from './EntryList';
import EntryExportButton from './EntryExportButton';

export default {
	components : {
		Tab,
		Tabs,
		EntryList,
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
			activeTab : 0,
		}
	},
	computed : {
		reversedFrames(){
			return this.entry.frames ? this.entry.frames.reverse() : []
		},
		multipleOccurrences(){
			return this.entry.occurrences && this.entry.occurrences > 1;
		}
	},
	methods : {
		formatJSON : formatJSONRaw,
		frameContext( frame ){
			return frame.pre_context.join( "\n" ) + "\n" + frame.context_line + "\n" + frame.post_context.join( "\n" );
		}
	},
	mounted() {
		Prism.highlightAll();
	}

}
</script>
<template>
	<div class="entry default-entry">
		<div class="entry-info text-sm">

			<!----------------------------------------------------------------------------------------->
			<!--- Top Left Exception Area --->
			<!----------------------------------------------------------------------------------------->
			<h2 class="text-3xl font-medium text-gray-500"><fa-icon icon="bomb" fixed-width />
				{{ $t( "Error Information" ) }}
				<entry-export-button :entry="entry"/>
			</h2>
			<table class="ml-4 text-left table-fixed border-collapse mt-5">
				<tbody>
					<tr v-if="entry.labels.application">
						<th class="w-1/3 align-top">{{ $t( "Application ID" ) }}:</th>
						<td class="w-2/3">{{ entry.labels.application }}</td>
					</tr>
					<tr>
						<th class="w-1/3 align-top">{{ $t( "Release Version" ) }}:</th>
						<td class="w-2/3">{{ entry.package.version || 'N/A' }}</td>
					</tr>
					<tr>
						<th class="w-1/3 align-top">{{ $t( "Level" ) }}:</th>
						<td class="w-2/3">{{entry.log.level || 'N/A'}} <span v-if="entry.event.severity">( Severity {{entry.event.severity}} )</span></td>
					</tr>
					<tr v-if="entry.error.type">
						<th class="w-1/3 align-top">{{ $t( "Type" ) }}:</th>
						<td class="w-2/3">{{entry.error.type}}</td>
					</tr>
					<tr>
						<th class="w-1/3 align-top">{{ $t( "Occurred At" ) }}:</th>
						<td class="w-2/3">{{ dayjs( entry[ '@timestamp' ] ).format('YYYY-MM-DD HH:mm:ss') }}</td>
					</tr>
					<tr v-if="entry.log.category">
						<th class="w-1/3 align-top">{{ $t( "Category" ) }}:</th>
						<td class="w-2/3">{{ entry.log.category }}</td>
					</tr>
					<tr v-if="entry.component">
						<th class="w-1/3 align-top">{{ $t( "Component" ) }}:</th>
						<td class="w-2/3">{{ entry.component }}</td>
					</tr>
					<tr v-if="entry.log.logger">
						<th class="w-1/3 align-top">{{ $t( "Appender" ) }}:</th>
						<td class="w-2/3">{{ entry.log.logger }}</td>
					</tr>
					<tr>
						<th class="w-1/3 align-top">{{ $t( "Message" ) }}:</th>
						<td class="w-2/3">
							<code class="text-yellow-600 text-xs">{{ entry.message }}</code>
						</td>
					</tr>
				</tbody>
			</table>
		</div>


		<div class="entry-detail mt-20" v-if="entry.error.extrainfo || entry.event || entry.snapshot || entry.error.stack_trace">
			<h2 class="text-3xl font-medium text-gray-500">
				<fa-icon icon="search" fixed-width />
				{{ $t( "Exception Detail" ) }}
			</h2>

			<tabs class="mt-5">
				<tab :name="$t( 'Stack Frames' )" v-if="entry.error.frames && entry.error.frames.length">
					<ul class="stackframes-list">
						<li
							v-for="( frame, index ) in entry.error.frames"
							:key="index"
							class="stackframe"
						>
							<span class="badge">{{ entry.error.frames.length - ( index ? index  : 0 ) }}</span>
							<div class="stacktrace-info">
								<h3 class="stacktrace-location">
									{{frame.fileName}}:<span class="stacktrace-line-number">{{frame.lineNumber}}</span>
								</h3>
								<pre><code class="language-javascript" v-html="frame.source"></code></pre>
							</div>
						</li>
					</ul>
				</tab>
				<tab :name="$t( 'Event Details' )" v-if="entry.event && Object.keys( entry.event ).length">
					<!-- Coldbox Event Information -->
					<table v-if="entry.event.environment" class="text-left table-fixed border-collapse">
						<tbody>
							<tr class="border-b">
								<th class="w-1/3 align-top">{{ $t( "Environment" ) }}:</th>
								<td class="w-2/3">{{entry.event.environment}}</td>
							</tr>
							<tr v-if="entry.event.name" class="border-b">
								<th class="w-1/3 align-top">{{ $t( "Name" ) }}:</th>
								<td class="w-2/3">{{entry.event.name}}</td>
							</tr>
							<tr v-if="entry.event.route" class="border-b">
								<th class="w-1/3 align-top">{{ $t( "Route" ) }}:</th>
								<td class="w-2/3">{{entry.event.route}}</td>
							</tr>
							<tr v-if="entry.event.url" class="border-b">
								<th class="w-1/3 align-top">{{ $t( "URL" ) }}:</th>
								<td class="w-2/3">{{entry.event.url}}</td>
							</tr>
							<tr v-if="entry.event.layout" class="border-b">
								<th class="w-1/3 align-top">{{ $t( "Layout" ) }}:</th>
								<td class="w-2/3">{{entry.event.layout}}</td>
							</tr>
							<tr v-if="entry.event.module" class="border-b">
								<th class="w-1/3 align-top">{{ $t( "Module" ) }}:</th>
								<td class="w-2/3">{{entry.event.module}}</td>
							</tr>
							<tr v-if="entry.event.view" class="border-b">
								<th class="w-1/3 align-top">{{ $t( "View" ) }}:</th>
								<td class="w-2/3">{{entry.event.view}}</td>
							</tr>
						</tbody>
					</table>
					<!-- Other Event Information -->
					<pre v-else><code class="language-json">{{formatJSON( JSON.stringify( entry.event ) )}}</code></pre>
				</tab>
				<tab :name="$t( 'Framework Snapshot' )" v-if="entry.snapshot && Object.keys( entry.snapshot ).length">
					<table class="text-left table-fixed border-collapse">
						<tbody>
							<tr v-if="entry.file.path" class="border-b">
								<th class="w-1/3 align-top">{{ $t( "Path" ) }}:</th>
								<td class="w-2/3">{{entry.file.path}}</td>
							</tr>
							<tr v-if="entry.host.hostname" class="border-b">
								<th class="w-1/3 align-top">{{ $t( "Host" ) }}:</th>
								<td class="w-2/3">{{entry.host.hostname}}</td>
							</tr>
							<tr v-if="entry.http.request.referer" class="border-b">
								<th class="w-1/3 align-top">{{ $t( "Referrer" ) }}:</th>
								<td class="w-2/3">{{entry.http.request.referer}}</td>
							</tr>
							<tr v-if="entry.user_agent.original" class="border-b">
								<th class="w-1/3 align-top">{{ $t( "Browser" ) }}:</th>
								<td class="w-2/3">{{entry.user_agent.original}}</td>
							</tr>
							<tr v-if="entry.client.ip" class="border-b">
								<th class="w-1/3 align-top">{{ $t( "Referrer" ) }}:</th>
								<td class="w-2/3">{{entry.client.ip}}</td>
							</tr>
						</tbody>
					</table>
				</tab>

				<tab name="Database" v-if="entry.error.extrainfo && entry.error.extrainfo.database && Object.keys( entry.error.extrainfo.database ).length">
					<table class="text-left table-fixed border-collapse">
						<tbody>
							<tr v-if="entry.error.extrainfo.database.nativeErrorCode" class="border-b">
								<th class="w-1/3 align-top">Native Error Code:</th>
								<td class="w-2/3">{{entry.error.extrainfo.database.nativeErrorCode}}</td>
							</tr>
							<tr v-if="entry.error.extrainfo.database.SQLState" class="border-b">
								<th class="w-1/3 align-top">SQL State:</th>
								<td class="w-2/3">{{entry.error.extrainfo.database.SQLState}}</td>
							</tr>
							<tr v-if="entry.error.extrainfo.database.queryError" class="border-b">
								<th class="w-1/3 align-top">Query Error:</th>
								<td class="w-2/3">{{entry.error.extrainfo.database.queryError}}</td>
							</tr>
							<tr v-if="entry.error.extrainfo.database.SQL" class="border-b">
								<th class="w-1/3 align-top">SQL:</th>
								<td class="w-2/3">
									<pre><code class="language-sql">{{entry.error.extrainfo.database.SQL}}</code></pre>
								</td>
							</tr>
							<tr v-if="entry.error.extrainfo.database.where" class="border-b">
								<th class="w-1/3 align-top">Where Clause(s):</th>
								<td class="w-2/3">
									<pre><code class="language-sql">{{entry.error.extrainfo.database.where}}</code></pre>
								</td>
							</tr>
						</tbody>
					</table>
				</tab>

				<tab name="Locks" v-if="entry.error.extrainfo && entry.error.extrainfo.lock && Object.keys( entry.error.extrainfo.lock ).length">
					<table class="text-left table-fixed border-collapse">
						<tbody>
							<tr v-if="entry.error.extrainfo.lock.name" class="border-b">
								<th class="w-1/3 align-top">Lock Name:</th>
								<td class="w-2/3">{{entry.error.extrainfo.lock.name}}</td>
							</tr>
							<tr v-if="entry.error.extrainfo.lock.operation" class="border-b">
								<th class="w-1/3 align-top">Lock Operation:</th>
								<td class="w-2/3">{{entry.error.extrainfo.lock.operation}}</td>
							</tr>
						</tbody>
					</table>
				</tab>

				<tab name="HTTP Request Data" v-if="entry.error.extrainfo && entry.error.extrainfo.httpData && Object.keys( entry.error.extrainfo.httpData ).length">
					<table class="text-left table-fixed border-collapse">
						<tbody>
							<tr v-if="entry.error.extrainfo.httpData.protocol" class="border-b">
								<th class="w-1/3 align-top">Protocol:</th>
								<td class="w-2/3">{{entry.error.extrainfo.httpData.protocol}}</td>
							</tr>
							<tr v-if="entry.error.extrainfo.httpData.method" class="border-b">
								<th class="w-1/3 align-top">Protocol:</th>
								<td class="w-2/3">{{entry.error.extrainfo.httpData.method}}</td>
							</tr>
							<tr v-if="entry.error.extrainfo.httpData.content" class="border-b">
								<th class="w-1/3 align-top">Content Body:</th>
								<td class="w-2/3">
									<pre><code class="language-json">{{formatJSON( entry.error.extrainfo.httpData.content )}}</code></pre>
								</td>
							</tr>
							<tr v-if="entry.error.extrainfo.httpData.headers && Object.keys( entry.error.extrainfo.httpData.headers ).length" class="border-b">
								<th class="w-1/3 align-top">Headers:</th>
								<td class="w-2/3">
									<table class="text-left table-fixed border-collapse">
										<tbody>
											<tr v-for="(key, index) in Object.keys( entry.error.extrainfo.httpData.headers )" :key="index" class="border-b">
												<th class="w-1/3 align-top">{{key}}</th>
												<td class="w-2/3">{{entry.error.extrainfo.httpData.headers[ key ]}}</td>
											</tr>
										</tbody>
									</table>
								</td>
							</tr>
						</tbody>
					</table>
				</tab>

				<tab name="Raw Stack Trace" v-if="entry.error.extrainfo && entry.error.extrainfo.javaStackTrace && entry.error.extrainfo.javaStackTrace.length">
					<code class="language-javastacktrace">{{entry.error.extrainfo.javaStackTrace}}</code>
				</tab>

				<tab name="Raw Stack Trace" v-else-if="entry.error.extrainfo && !entry.error.extrainfo.javaStackTrace && entry.error.extrainfo._stacktrace">
					<code class="language-javastacktrace">{{entry.error.extrainfo._stacktrace}}</code>
				</tab>

				<tab name="Raw Stack Trace" v-else-if="entry.error.stack_trace">
					<pre v-if="Array.isArray( entry.error.stack_trace )"><code class="language-javastacktrace">{{entry.error.stack_trace.join( "\n" )}}</code></pre>
					<pre v-else><code class="language-javastacktrace">{{entry.error.stack_trace}}</code></pre>
				</tab>

				<tab v-if="multipleOccurrences" name="Occurrences">
					<entry-list
						v-if="occurrences"
						:logs="occurrences.results"
						:pagination="occurrencePagination"
						:displayOccurrences="false"
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
import EntryList from './EntryList.vue';
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
	computed : {
		multipleOccurrences(){
			return this.entry.stachebox.signature && this.entry.occurrences && this.entry.occurrences > 1;
		},
		occurrencePagination(){
			if( !this.occurrences ) return null;
			return {
				page : 1,
				pages : 1,
				maxRows : this.occurrences.limit,
				startRow : this.occurrences.start,
				total : this.occurrences.total
			};
		}
	},
	data(){
		return {
			dayjs : dayjs,
			activeTab : 0,
			occurrences : null
		}
	},
	methods : {
		formatJSON : formatJSONRaw
	},
	mounted() {
		Prism.highlightAll()
		if( this.multipleOccurrences ){
			this.$store.dispatch( "fetchLogs", { "stachebox.signature" : this.entry.stachebox.signature, sortOrder : "@timestamp DESC" } )
				.then( ( result ) => this.occurrences = result.data )
		}
	}

}
</script>
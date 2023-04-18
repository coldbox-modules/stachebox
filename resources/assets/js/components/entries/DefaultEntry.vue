<template>
	<div class="entry default-entry">
		<div class="entry-info text-sm">

			<!----------------------------------------------------------------------------------------->
			<!--- Top Left Exception Area --->
			<!----------------------------------------------------------------------------------------->
			<h2 class="text-3xl font-medium text-gray-500"><fa-icon icon="bomb" fixed-width />
				{{ $t( "Log Entry Information" ) }}
				<entry-export-button :entry="entry"/>
			</h2>
			<table class="ml-4 text-left table-fixed border-collapse mt-5">
				<tbody>
					<tr v-if="entry.labels.application">
						<th class="w-1/3 align-top py-1">{{ $t( "Application ID" ) }}:</th>
						<td class="w-2/3 py-1">{{ entry.labels.application }}</td>
					</tr>
					<tr>
						<th class="w-1/3 align-top py-1">{{ $t( "Release Version" ) }}:</th>
						<td class="w-2/3 py-1">{{ entry.package.version || $t( 'N/A' ) }}</td>
					</tr>
					<tr>
						<th class="w-1/3 align-top py-1">{{ $t( "Environment" ) }}:</th>
						<td class="w-2/3 py-1">{{ entry.labels.environment ? entry.labels.environment.toTitleCase() : $t( 'N/A' ) }}</td>
					</tr>
					<tr>
						<th class="w-1/3 align-top py-1">{{ $t( "Level" ) }}:</th>
						<td class="w-2/3 py-1">{{entry.log.level ? entry.log.level.toUpperCase() : $t( 'N/A' )}} <span v-if="entry.event.severity">( {{ $t( "Severity" ) }} {{entry.event.severity}} )</span></td>
					</tr>
					<tr v-if="entry.error.type">
						<th class="w-1/3 align-top py-1">{{ $t( "Type" ) }}:</th>
						<td class="w-2/3 py-1">{{entry.error.type}}</td>
					</tr>
					<tr>
						<th class="w-1/3 align-top py-1">{{ $t( "Occurred At" ) }}:</th>
						<td class="w-2/3 py-1">{{ dayjs( entry[ '@timestamp' ] ).local().format('YYYY-MM-DD HH:mm:ss') }}</td>
					</tr>
					<tr v-if="entry.log.category">
						<th class="w-1/3 align-top py-1">{{ $t( "Category" ) }}:</th>
						<td class="w-2/3 py-1">{{ entry.log.category }}</td>
					</tr>
					<tr v-if="entry.package.path">
						<th class="w-1/3 align-top py-1">{{ $t( "Application Path" ) }}:</th>
						<td class="w-2/3 py-1">{{ entry.package.path }}</td>
					</tr>
					<tr v-if="entry.package.reference">
						<th class="w-1/3 align-top py-1">{{ $t( "Base URL" ) }}:</th>
						<td class="w-2/3 py-1">{{ entry.package.reference }}</td>
					</tr>
					<tr v-if="entry.log.logger">
						<th class="w-1/3 align-top py-1">{{ $t( "Appender" ) }}:</th>
						<td class="w-2/3 py-1">{{ entry.log.logger }}</td>
					</tr>
					<tr>
						<th class="w-1/3 align-top py-1">{{ $t( "Message" ) }}:</th>
						<td class="w-2/3 py-1">
							<code class="text-yellow-600 text-xs">{{ entry.message }}</code>
						</td>
					</tr>
				</tbody>
			</table>
		</div>


		<div class="entry-detail mt-20" v-if="entry.error.extrainfo || entry.event || entry.snapshot || entry.error.stacktrace">
			<h2 class="text-3xl font-medium text-gray-500">
				<fa-icon icon="search" fixed-width />
				{{ $t( "Exception Detail" ) }}
			</h2>

			<tabs class="mt-5 bg-gray-100">
				<tab :name="$t( 'Event Details' )">
					<!-- Coldbox Event Information -->
					<table class="text-left table-fixed border-collapse">
						<tbody>
							<tr>
								<th class="w-1/3 align-top py-1">{{ $t( "Environment" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.labels.environment ? entry.labels.environment.toTitleCase() : 'Unknown'}}</td>
							</tr>
							<tr v-if="entry.event.name">
								<th class="w-1/3 align-top py-1">{{ $t( "Name" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.event.name}}</td>
							</tr>
							<tr v-if="entry.event.created">
								<th class="w-1/3 align-top py-1">{{ $t( "Occurrence Time" ) }}:</th>
								<td class="w-2/3 py-1">{{dayjs( entry.event.created ).local().format('YYYY-MM-DD HH:mm:ss')}}</td>
							</tr>
							<tr v-if="entry.event.route">
								<th class="w-1/3 align-top py-1">{{ $t( "Route" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.event.route}}</td>
							</tr>
							<tr v-if="entry.event.url">
								<th class="w-1/3 align-top py-1">{{ $t( "URL" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.event.url}}</td>
							</tr>
							<tr v-if="entry.event.layout">
								<th class="w-1/3 align-top py-1">{{ $t( "Layout" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.event.layout}}</td>
							</tr>
							<tr v-if="entry.event.module">
								<th class="w-1/3 align-top py-1">{{ $t( "Module" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.event.module}}</td>
							</tr>
							<tr v-if="entry.event.view">
								<th class="w-1/3 align-top py-1">{{ $t( "View" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.event.view}}</td>
							</tr>
							<tr v-if="entry.file.path">
								<th class="w-1/3 align-top py-1">{{ $t( "Path" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.file.path}}</td>
							</tr>
							<tr v-if="entry.host && entry.host.name">
								<th class="w-1/3 align-top py-1">{{ $t( "Host" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.host.name}}</td>
							</tr>
							<tr v-if="entry.http.request.referer">
								<th class="w-1/3 align-top py-1">{{ $t( "Referrer" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.http.request.referer}}</td>
							</tr>
							<tr v-if="entry.user_agent.original">
								<th class="w-1/3 align-top py-1">{{ $t( "Browser" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.user_agent.original}}</td>
							</tr>
							<tr v-if="entry.client.ip">
								<th class="w-1/3 align-top py-1">{{ $t( "Remote Address" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.client.ip}}</td>
							</tr>
						</tbody>
					</table>
				</tab>
				<tab :name="$t( 'Database' )" v-if="entry.error.extrainfo && entry.error.extrainfo.database && Object.keys( entry.error.extrainfo.database ).length">
					<table class="text-left table-fixed border-collapse">
						<tbody>
							<tr v-if="entry.error.extrainfo.database.nativeErrorCode">
								<th class="w-1/3 align-top py-1">{{ $t( "Native Error Code" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.error.extrainfo.database.nativeErrorCode}}</td>
							</tr>
							<tr v-if="entry.error.extrainfo.database.SQLState">
								<th class="w-1/3 align-top py-1">{{ $t( "SQL State" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.error.extrainfo.database.SQLState}}</td>
							</tr>
							<tr v-if="entry.error.extrainfo.database.queryError">
								<th class="w-1/3 align-top py-1">{{ $t( "Query Error" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.error.extrainfo.database.queryError}}</td>
							</tr>
							<tr v-if="entry.error.extrainfo.database.SQL">
								<th class="w-1/3 align-top py-1">{{ $t( "SQL" ) }}:</th>
								<td class="w-2/3 py-1">
									<pre><code class="language-sql">{{entry.error.extrainfo.database.SQL}}</code></pre>
								</td>
							</tr>
							<tr v-if="entry.error.extrainfo.database.where">
								<th class="w-1/3 align-top py-1">{{ $t( "Where Clause" ) }}:</th>
								<td class="w-2/3 py-1">
									<pre><code class="language-sql">{{entry.error.extrainfo.database.where}}</code></pre>
								</td>
							</tr>
						</tbody>
					</table>
				</tab>

				<tab :name="$t( 'Locks' )" v-if="entry.error.extrainfo && entry.error.extrainfo.lock && Object.keys( entry.error.extrainfo.lock ).length">
					<table class="text-left table-fixed border-collapse">
						<tbody>
							<tr v-if="entry.error.extrainfo.lock.name">
								<th class="w-1/3 align-top py-1">{{ $t( "Lock Name" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.error.extrainfo.lock.name}}</td>
							</tr>
							<tr v-if="entry.error.extrainfo.lock.operation">
								<th class="w-1/3 align-top py-1">{{ $t( "Lock Operation" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.error.extrainfo.lock.operation}}</td>
							</tr>
						</tbody>
					</table>
				</tab>

				<tab :name="$t( 'HTTP Request Data' )" v-if="entry.error.extrainfo && entry.error.extrainfo.httpData && Object.keys( entry.error.extrainfo.httpData ).length">
					<table class="text-left table-fixed border-collapse">
						<tbody>
							<tr v-if="entry.error.extrainfo.httpData.protocol">
								<th class="w-1/3 align-top py-1">{{ $t( "Protocol" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.error.extrainfo.httpData.protocol}}</td>
							</tr>
							<tr v-if="entry.error.extrainfo.httpData.method">
								<th class="w-1/3 align-top py-1">{{ $t( "HTTP Method" ) }}:</th>
								<td class="w-2/3 py-1">{{entry.error.extrainfo.httpData.method}}</td>
							</tr>
							<tr v-if="entry.error.extrainfo.httpData.content">
								<th class="w-1/3 align-top py-1">{{ $t( "Content Body" ) }}:</th>
								<td class="w-2/3 py-1">
									<pre><code class="language-json">{{formatJSON( entry.error.extrainfo.httpData.content )}}</code></pre>
								</td>
							</tr>
							<tr v-if="entry.error.extrainfo.httpData.headers && Object.keys( entry.error.extrainfo.httpData.headers ).length">
								<th class="w-1/3 align-top py-1">{{ $t( "Headers" ) }}:</th>
								<td class="w-2/3 py-1">
									<table class="text-left table-fixed border-collapse">
										<tbody>
											<tr v-for="(key, index) in Object.keys( entry.error.extrainfo.httpData.headers )" :key="index">
												<th class="w-1/3 align-top py-1">{{key}}</th>
												<td class="w-2/3 py-1">{{entry.error.extrainfo.httpData.headers[ key ]}}</td>
											</tr>
										</tbody>
									</table>
								</td>
							</tr>
						</tbody>
					</table>
				</tab>
				<tab :name="$t( 'Extra Info' )" v-else-if="entry.error.extrainfo">
					<pre v-if="!extraInfoIsHTML"><code class="language-json">{{formatJSON( JSON.stringify( entry.error.extrainfo ) )}}</code></pre>
					<iframe v-else class="error-iframe" ref="errorIframe" @load="loadExtraInfoFrame" style="flex: 1; width: 100%; border: none; min-height:800px" />
				</tab>

				<tab :name="$t( 'User Info' )" v-if="entry.user && entry.user.info && Object.keys( entry.user.info ).length">
					<pre><code class="language-json">{{formatJSON( JSON.stringify( entry.user.info ) )}}</code></pre>
				</tab>

				<tab :name="$t( 'Raw Stack Trace' )" v-if="entry.error.extrainfo && entry.error.extrainfo.javaStackTrace && entry.error.extrainfo.javaStackTrace.length">
					<code class="language-javastacktrace">{{entry.error.extrainfo.javaStackTrace}}</code>
				</tab>

				<tab :name="$t( 'Raw Stack Trace' )" v-else-if="entry.error.extrainfo && !entry.error.extrainfo.javaStackTrace && entry.error.extrainfo._stacktrace">
					<code class="language-javastacktrace">{{entry.error.extrainfo._stacktrace}}</code>
				</tab>

				<tab :name="$t( 'Raw Stack Trace' )" v-else-if="entry.error.stack_trace">
					<pre v-if="Array.isArray( entry.error.stack_trace )"><code class="language-javastacktrace">{{entry.error.stack_trace.join( "\n" )}}</code></pre>
					<pre v-else><code class="language-javastacktrace">{{entry.error.stack_trace}}</code></pre>
				</tab>

				<tab :name="$t( 'Stack Frames' )" v-if="entry.error.frames && entry.error.frames.length">
					<ol class="stackframes-list list-decimal pl-3">
						<li
							v-for="( frame, index ) in reversedFrames"
							:key="index"
							class="stackframe"
						>
							<div class="stacktrace-info">
								<h3 class="stacktrace-location">
									{{frame.filename}}:<span class="stacktrace-line-number">{{frame.lineno}}</span>
								</h3>
								<pre><code class="language-javascript" v-html="frameContext( frame )"></code></pre>
							</div>
						</li>
					</ol>
				</tab>

				<tab :name="$t( 'Raw Entry Data' )">
					<pre><code class="language-json">{{formatJSON( JSON.stringify( entry ) )}}</code></pre>
				</tab>

				<tab v-if="multipleOccurrences" :name="$t( 'Other Occurrences' )">
					<entry-list
						v-if="multipleOccurrences"
						:initialFilters='{ "stachebox.signature" : entry.stachebox.signature, exclude : entry.id, sortOrder : "@timestamp DESC" }'
						:displayOccurrences="false"
						:displayApplication="false"
					></entry-list>
				</tab>

			</tabs>
		</div>
	</div>
</template>
<script>
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
			activeTab : 0,
		}
	},
	computed : {
		reversedFrames(){
			return this.entry.error.frames ? this.entry.error.frames.reverse() : []
		},
		multipleOccurrences(){
			return this.entry.occurrences && this.entry.occurrences > 1;
		},
		extraInfoIsHTML(){
			return this.entry.error
					&& this.entry.error.extrainfo
					&& typeof( this.entry.error.extrainfo ) == "string"
					&& this.entry.error.extrainfo.toLowerCase().substring(0,30) == '</td></td></td></th></th></th>';
		}
	},
	methods : {
		formatJSON : formatJSONRaw,
		frameContext( frame ){
			return frame.pre_context.join( "\n" ) + "\n" + frame.context_line + "\n" + frame.post_context.join( "\n" );
		},
		loadExtraInfoFrame(){
			this.$nextTick( () => this.$refs.errorIframe.contentDocument.body.innerHTML = this.entry.error.extrainfo );
		}
	},
	mounted() {
		Prism.highlightAll();
	}

}
</script>
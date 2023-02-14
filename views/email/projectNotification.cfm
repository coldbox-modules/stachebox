<cfscript>
	errorDocs = args.errors.results;
	baseURL = args.baseURL & ( getModuleSettings( "stachebox", "isStandalone" ) ? '' : 'stachebox/' );
</cfscript>
<div>
<cfoutput>
	<h1 class="masthead mb-7 mt-7"><span class="sr-only">#$r( resource="Stachebox.notification.header", values={ "reportPeriod" : args.reportPeriod }, bundle="stachebox" )#</span></h1>
	<p class="text-center mb-5"><a href="#baseURL#projects/#args.project.id#">#$r( resource="Stachebox.project.errors.received.message", values={ "project" : args.project.name, "errorCount" : args.errors.pagination.total, "reportPeriod" : args.reportPeriod }, bundle="stachebox" )#</a></p>
	<h3 class="mb-5">#$r( resource="Occurrences", bundle="stachebox" )#:</h3>
	<table class="min-w-full mb-7" style="table-layout:fixed" v-if="logs">
		<thead>
			<tr>
				<th
					class="px-2 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase"
				>
					#$r( resource="Application", bundle="stachebox" )#
				</th>
				<th
					class="px-2 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase"
				>
					#$r( resource="Time", bundle="stachebox" )#
				</th>
				<th
					class="px-2 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase"
				>
					#$r( resource="Type", bundle="stachebox" )#
				</th>
				<th
					class="px-2 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase"
				>
					#$r( resource="Qty", bundle="stachebox" )#
				</th>
				<th
					class="px-2 py-3 border-b border-gray-200 bg-gray-50 text-left text-xs leading-4 font-medium text-gray-500 uppercase"
					style="max-width:400px!important"
				>
					#$r( resource="Message", bundle="stachebox" )#
				</th>
				<th></th>
			</tr>
		</thead>

		<tbody class="bg-white">
			<cfloop array="#errorDocs#" index="index" item="entry">
				<tr class="hover:bg-gray-50">
					<td
						v-if="displayApplication"
						class="px-3 py-2 border-b border-gray-200 text-sm text-gray-500"
						style="width: 150px"
					>
						<a href="#baseURL#logs/application/#entry.labels.application#">#entry.labels.application#</a>
					</td>

					<td
						class="px-3 py-2 border-b border-gray-200 text-sm text-gray-500"
						style="width: 175px"
					>
						#lsDateFormat( parseDateTime( entry[ "@timestamp" ], "yyyy-MM-dd'T'HH:nn:ssX" ), "MM/DD/YYYY HH:mm" )#
					</td>
					<td
						class="px-3 py-2 border-b border-gray-200 text-sm text-gray-500"
						style="width: 150px"
					>
						#( entry.error.keyExists( "type" ) ? entry.error.type : ( entry.log.level ?: "unknown" ) )#
					</td>
					<td
						class="px-3 py-2 border-b border-gray-200 text-sm text-gray-500"
					>
						<span class="inline-flex items-center justify-center px-2 py-1 text-xs leading-none text-white bg-theme rounded-full">#( entry.occurrences ?: 1 )#</span>
					</td>
					<td
						class="px-3 py-2 border-b border-gray-200 text-sm leading-5 text-gray-500"
						style="max-width:400px!important"
					>
						<code class="text-yellow-600 text-xs">#left( entry.message, 200 )#...</code>
					</td>

					<td
						class="px-3 py-2 text-right border-b border-gray-200 text-sm leading-5 font-medium"
					>
						<a href="#baseURL#logs/entry/#entry.id#">#$r( resource="View Entry", bundle="stachebox" )#</a>
					</td>
				</tr>
			</cfloop>
		</tbody>
	</table>

	<p class="text-center">
		<em>#$r( resource="Stachebox.project.nofication.why", values={ "frequency" : args.frequency, "projectLink" : "#baseURL#projects/#args.project.id#", "projectName" : args.project.name, "ownerEmail" : args.project.owner.email }, bundle="stachebox" )#</em>
	</p>
</cfoutput>
</div>
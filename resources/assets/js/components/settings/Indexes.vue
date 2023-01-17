<template>
	<div>
		<h3 class="text-gray-700 text-3xl font-medium">Active Indices</h3>
		<div class="mt-4 items-center">
			<div
				class="col-xs-12"
			>
				<table id="index-list" class="table table-striped table-hover" v-if="indexMap">
					<thead>
						<tr>
							<th style="width:20%">{{ $t( 'Index' ) }}</th>
							<th style="width:20%">{{ $t( 'Aliases' ) }}</th>
							<th style="width:10%">{{ $t( 'Documents' ) }}</th>
							<th style="width:10%">{{ $t( 'Storage' ) }}</th>
							<th style="width:20%">{{ $t( 'Description' ) }}</th>
							<th></th>
						</tr>
					</thead>
					<tbody>
						<tr
							v-for="indexName in Object.keys( indexMap.indices )"
							:key="indexName"
						>
							<td>{{indexName}}</td>
							<td>
								<ul class="list-unstyled" v-if="indexMap.indices[ indexName ].aliases.length">
									<li
										v-for="alias in indexMap.indices[ indexName ].aliases"
										:key="`${indexName}_${alias}`"
									>{{alias}}</li>
								</ul>
								<span v-else><em class="text-muted">{{ $t( 'none', 'None' ) }}</em></span>
							</td>
							<td>{{indexMap.indices[ indexName ].docs}}</td>
							<td>{{(indexMap.indices[ indexName ].size_in_bytes / 1048576).toFixed( 2 )}} MB</td>
							<td>
								<span v-if="indexMap.indices[ indexName ].isPrimary">
									{{ $t( 'primary_Application_Index', 'Primary application index for' ) }} {{ primaryIndexType( indexName ) }}
								</span>
								<span v-else>{{ $t( 'Unknown/Unassigned Index' ) }}</span>
							</td>
							<td>
								<div class="flex-container">
									<confirmable-button
										:isDisabled="indexName.indexOf('.') == 0"
										v-tooltip="indexName.indexOf('.') == 0 ? 'This is a system index and cannot be deleted' : `Delete ${indexName}`"
										v-if="!indexMap.indices[ indexName ].isPrimary"
										class-string="btn btn-sm"
										@confirmed="deleteIndex( indexName )">
										<i class="fa fa-trash"></i> {{ $t( 'Delete Index' ) }}
									</confirmable-button>
									<button v-else class="btn btn-default btn-sm"
											:disabled="isReindexing || !isReindexingAllowed( indexName ) || null"
											v-tooltip="( isReindexing || !isReindexingAllowed( indexName ) ) ? 'Re-indexing is currently disabled' : 'Reindex existing data to a newly created index'"
											@click="reindex( indexName )">
										<i class="fa fa-exchange"></i> {{ $t( 'reindex', 'Reindex' ) }}
									</button>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
				<generic-loader v-else message="Loading index data..."></generic-loader>
			</div>
		</div>
	</div>
</template>
<script>
import GenericLoader from "../GenericLoader";
export default {
	components: {
		GenericLoader
	},
	data(){
		return {
			indexMap : null
		}
	},
	beforeMount(){

	}

}
</script>
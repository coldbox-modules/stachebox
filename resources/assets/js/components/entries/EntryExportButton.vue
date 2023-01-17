<template>
	<button
		@click="exportEntry"
		class="text-gray-500 focus:outline-none float-right"
		v-tooltip="$t( 'Download this log entry to a JSON file on your local machine' )"
	>
		<fa-icon icon="download" size="xs" fixed-width/>
	</button>
</template>
<script>
	import FileSaver from "file-saver";
	import { formatJSONRaw } from "@/util/udf";
	export default {
		props : {
			entry : {
				type : Object,
				required : true
			}
		},
		methods : {
			exportEntry(){
					var file = new Blob( [ formatJSONRaw( JSON.stringify( this.entry ) ) ], { type: "application/json" } );
                    FileSaver.saveAs( file, `logstash-entry-${this.entry.id}.json` );
			}
		}
	}
</script>
<template>
	<div class="stachebox-log-entry">
		<logger-entry v-if="logEntry && !Object.keys( logEntry ).indexOf( 'stacktrace' ) == -1" :entry="logEntry"></logger-entry>
		<javascript-entry v-else-if="logEntry && logEntry.type && logEntry.type == 'javascript'" :entry="logEntry"></javascript-entry>
		<default-entry v-else-if="logEntry" :entry="logEntry"></default-entry>
		<div v-else class="mt-4 text-center items-center">
			<fa-icon size="3x" class="text-gray-300" icon="circle-notch" spin fixed-width />
			<p class="mt-4 text-gray-300">{{ $t( "Loading log data. Please wait..." ) }}</p>
		</div>
	</div>
</template>
<script>
import DefaultEntry from "@/components/entries/DefaultEntry";
import JavascriptEntry from "@/components/entries/JavascriptEntry";
import LoggerEntry from "@/components/entries/LoggerEntry";
export default {
	components : {
		DefaultEntry,
		LoggerEntry,
		JavascriptEntry
	},
	data(){
		return {
			logEntry : null,
			entryId : this.$route.params.id
		}
	},
	methods : {
		fetchEntry(){
			this.$store.dispatch( "fetchLogEntry", this.entryId )
				.then( (result) => this.logEntry = result.data );
		}
	},
	mounted(){
		this.fetchEntry();
	}

}
</script>
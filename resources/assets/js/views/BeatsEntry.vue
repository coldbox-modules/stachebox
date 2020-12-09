<template>
	<div class="stachebox-log-entry">
		<logger-entry v-if="logEntry" :entry="logEntry"></logger-entry>
		<div v-else class="mt-4 text-center items-center">
			<fa-icon size="3x" class="text-gray-300" icon="circle-notch" spin fixed-width />
			<p class="mt-4 text-gray-300">Loading log entry data. Please wait...</p>
		</div>
	</div>
</template>
<script>
import LoggerEntry from "@/components/entries/LoggerEntry";
export default {
	components : {
		LoggerEntry
	},
	data(){
		return {
			logEntry : null,
			entryId : this.$route.params.id
		}
	},
	methods : {
		fetchEntry(){
			this.$store.dispatch( "fetchBeatsEntry", this.entryId )
				.then( (result) => this.logEntry = result.data );
		}
	},
	mounted(){
		this.fetchEntry();
	}

}
</script>
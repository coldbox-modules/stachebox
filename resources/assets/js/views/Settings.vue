<template>
	<div class="settings-admin">
		<h3 class="text-gray-700 text-3xl font-medium">Custom Settings</h3>

		<table class="text-left table-fixed border-collapse mt-5">
			<tbody>
				<tr class="border-b">
					<th class="w-1/3 align-top">Application ID:</th>
					<td class="w-2/3"></td>
				</tr>
			</tbody>
		</table>
	</div>
</template>
<script>
import { mapGetters } from "vuex";
export default {

	computed : {
		...mapGetters({
			hasPermission : "hasPermission"
		})
	}
}
</script>
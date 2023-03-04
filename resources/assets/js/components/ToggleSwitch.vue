<template>
	<button
		type="button"
		:aria-pressed="isActive"
		@click="$emit( 'toggle' )"
		aria-labelledby="toggleLabel"
		:class="buttonClass"
	>
		<span class="sr-only">{{ SRText }}</span>
		<span
			aria-hidden="true"
			:class="toggleClass"
		></span>
	</button>
</template>
<script>
export default {
	props: {
		isActive : {
			required : true
		},
		SRText : {
			type: String,
			default: "Use setting"
		},
		onColor:{
			type : String,
			default : "gray"
		}
	},
	computed : {
		buttonClass(){
			let btnClass = `relative inline-flex flex-shrink-0 h-6 w-11 border-2 border-transparent rounded-full cursor-pointer transition-colors ease-in-out duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-${this.onColor}-500 `;
			btnClass += this.isActive ? `bg-${this.onColor}-600` : `bg-${this.onColor}-300`;
			return btnClass;
		},
		toggleClass(){
			let toggleClass = "inline-block h-5 w-5 rounded-full bg-white shadow transform ring-0 transition ease-in-out duration-200 "
			toggleClass += this.isActive ? 'translate-x-5' : 'translate-x-0';
			return toggleClass

		}
	}
}
</script>
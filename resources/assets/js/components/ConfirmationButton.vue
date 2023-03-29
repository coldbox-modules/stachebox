<template>
    <div class="confirmation-wrap">
        <button
            :disabled="isDisabled"
            type="button"
            v-if="!confirmOn"
            :class="classString"
            :tabindex="tabIndex"
            @click="setConfirm( true )"
        >
            <slot name="icon"></slot>
            <slot></slot>
        </button>

        <div v-if="confirmOn" class="confirm-options absolute" style="margin-top: -18px;margin-left: -188px">
            <button
                type="button"
                :class="confirmClassString"
                @click="proceed()"
            >
                <slot name="icon"></slot>
                <span class="pl-2">{{ confirmationMessage }}</span>
				<slot></slot>
            </button>
            <button
                type="button"
                :class="cancelClassString"
                @click="cancel()"
            >
				{{ cancelMessage }}
            </button>
        </div>
    </div>
</template>

<script>
export default {
    props: {
        // is button disabled?
        isDisabled: {
            default: false
        },
        // the default button class to use
        classString: {
            default: "disabled:opacity-50"
		},
		confirmClassString : {
			type : String,
			default : "ml-3 inline-flex justify-center py-2 px-2 border border-transparent shadow-sm text-xs font-medium rounded-none text-white bg-cyan-600 hover:bg-cyan-700"
		},
		cancelClassString : {
			type : String,
			default : "bg-white py-2 px-2 border border-gray-300 rounded-none shadow-sm text-xs font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2"
		},
		confirmationMessage : {
			type : String,
			default : "Click to Confirm"
		},
		cancelMessage : {
			type : String,
			default : "Cancel"
		},
        tabIndex : {
            type : Number,
            default : 0
        }
    },
    data() {
        return {
            confirmOn: false
        };
    },
    methods: {
        setConfirm( value ){
            this.confirmOn = value;
        },
        cancel() {
            this.setConfirm( false );
        },
        proceed(){
            this.$emit( "confirmed", true );
            this.setConfirm( false );
        }
    }
};
</script>
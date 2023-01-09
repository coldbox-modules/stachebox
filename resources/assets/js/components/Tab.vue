<template>
    <div v-show="isActive" class="pt-5 pb-5 pl-5 pr-5 border-gray-300 border-l border-r border-b"><slot></slot></div>
</template>

<script>
export default {
    props: {
        name: { required: true },
        selected: { default: false }
    },
    data() {
        return {
            isActive: false
        };
    },
    computed: {
        href() {
            return '#' + this.name.toLowerCase().replace(/ /g, '-');
        }
    },
    beforeMount(){
        this.$parent.tabs.push( this );
    },
    beforeUnmount(){
        let self = this;
        this.$parent.tabs.splice( this.$parent.tabs.findIndex( tab => tab.name === self.name ), 1 );
    },
    mounted() {
        this.isActive = this.selected;
    }
}
</script>
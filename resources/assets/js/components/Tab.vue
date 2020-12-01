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
    mounted() {
        this.isActive = this.selected;
    },
}
</script>
<template>
     <div>
         <nav class="px-8 pt-2 shadow-md">
            <div class="-mb-px flex">
                <a v-for="tab in tabs"
                   class="no-underline border-b-2 border-transparent uppercase tracking-wide font-bold text-xs py-3 mr-8"
                   :class="{ 'text-gray-200': tab.isActive, 'text-theme': tab.isActive == false, 'bg-theme': tab.isActive == true, 'border-l pl-3 pr-3' : true }"
                   @click="selectTab(tab)"
                   :key="tab.name"
                >
                    {{ tab.name }}
                </a>
            </div>
        </nav>
        <div class="tabs-details">
            <slot></slot>
        </div>
    </div>
</template>

<script>
export default {
    data() {
        return { tabs: [] };
    },
    created() {
        this.tabs = this.$children;
    },
    methods: {
        selectTab(selectedTab) {
            this.tabs.forEach(tab => {
                tab.isActive = (tab.href == selectedTab.href);
            });
        }
	},
	mounted(){
		this.selectTab( this.tabs[0] );
	}
}
</script>
<template>
     <div>
         <nav class="px-8 shadow-md bg-gray-100">
            <div class="-mb-px pt-2 flex">
                <button v-for="tab in tabs"
				   type="button"
				   tabindex="0"
                   class="no-underline border-transparent uppercase tracking-wide font-bold text-xs py-3 mr-8 py-3 hover:cursor-pointer"
                   :class="{ 'text-gray-200': tab.isActive, 'text-theme': tab.isActive == false, 'bg-theme': tab.isActive == true, 'border-l pl-3 pr-3' : true }"
                   @click="selectTab(tab)"
                   :key="tab.name"
                >
                    {{ tab.name }}
                </button>
            </div>
        </nav>
        <div class="tabs-details block">
            <slot></slot>
        </div>
    </div>
</template>

<script>
export default {
    data() {
        return { tabs: [] };
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
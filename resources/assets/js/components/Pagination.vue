<template>
	<div
		class="bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200 sm:px-6"
	>
		<div class="flex-1 flex justify-between sm:hidden">
			<a
				href="#"
				class="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:text-gray-500 hover:cursor-pointer"
			>
				{{ $t( "Previous" ) }}
			</a>
			<a
				href="#"
				class="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:text-gray-500 hover:cursor-pointer"
			>
				{{ $t( "Next" ) }}
			</a>
		</div>
		<div
			class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between"
		>
			<div>
				<p class="text-sm text-gray-700">
					Showing
					<span class="font-medium">{{ pagination.startRow || 1 }}</span>
					to
					<span class="font-medium">{{ pagination.total > pagination.maxRows ? pagination.startRow + pagination.maxRows - ( pagination.startRow ? 1 : 0 ) : pagination.total }}</span>
					of
					<span class="font-medium">{{ pagination.total }}</span>
					results
				</p>
			</div>
			<div>
				<label for="maxRows" class="inline-block text-sm font-medium text-gray-700 mr-2">Max:</label>
				<select
					id="maxRows"
					name="maxRows"
					v-model="pagination.maxRows"
					@change="setMaxRows"
					class="mt-1 inline-block pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-cyan-500 focus:border-cyan-500 sm:text-sm rounded-md hover:cursor-pointer"
				>
					<option v-for="qty in maxRowOptions" :key="qty" :value="qty">{{qty}}</option>
				</select>
			</div>
			<div>
				<nav
					v-if="displayedPages.length > 1"
					class="relative z-0 inline-flex shadow-sm -space-x-px"
					aria-label="Pagination"
				>
					<a
						@click="$emit( 'paginate', pagination.page - 1 )"
						class="disabled:opacity-50 relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 hover:cursor-pointer"
						:disabled="pagination.page == 1"
					>
						<span class="sr-only">Previous</span>
						<fa-icon icon="chevron-left"/>
					</a>
					<a
						v-for="page in displayedPages"
						:key="page"
						@click="$emit( 'paginate', page )"
						class="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium hover:cursor-pointer "
						:class="{ 'bg-gray-700 text-gray-200 hover:bg-gray-600' : page === pagination.page, 'bg-white text-gray-700 hover:bg-gray-50' : page !== pagination.page }"
					>
						{{ page || '...' }}
					</a>
					<a
						@click="$emit( 'paginate', pagination.page + 1 )"
						class="disabled:opacity-50 relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 hover:cursor-pointer"
						:disabled="pagination.page == pagination.pages"
					>
						<span class="sr-only">Next</span>
						<fa-icon icon="chevron-right"/>
					</a>
				</nav>
			</div>
		</div>
	</div>
</template>
<script>
export default {
	props : {
		pagination : {
			type : Object,
			required : true
		}
	},
	data(){
		return {
			maxRowOptions : [
				5,
				10,
				25,
				50,
				75,
				100,
				150,
				200,
				250
			]
		}
	},
	computed : {
		displayedPages(){
			var totalPages = this.pagination.pages;
			var page = this.pagination.page;
			var maxLength = 7;

			if( totalPages <= maxLength ){
				return Array.from( Array( totalPages ).keys(), ( key ) => key+1 );
			}

			function range(start, end) {
				return Array.from(Array(end - start + 1), (_, i) => i + start);
			}

			var sideWidth = maxLength < 9 ? 1 : 2;
			var leftWidth = (maxLength - sideWidth*2 - 3) >> 1;
			var rightWidth = (maxLength - sideWidth*2 - 2) >> 1;
			if (totalPages <= maxLength) {
				// no breaks in list
				return range(1, totalPages);
			}
			if (page <= maxLength - sideWidth - 1 - rightWidth) {
				// no break on left of page
				return range(1, maxLength - sideWidth - 1)
					.concat(0, range(totalPages - sideWidth + 1, totalPages));
			}
			if (page >= totalPages - sideWidth - 1 - rightWidth) {
				// no break on right of page
				return range(1, sideWidth)
					.concat(0, range(totalPages - sideWidth - 1 - rightWidth - leftWidth, totalPages));
			}
			// Breaks on both sides
			return range(1, sideWidth)
				.concat(0, range(page - leftWidth, page + rightWidth),
						0, range(totalPages - sideWidth + 1, totalPages));
		}
	},
	methods : {
		setMaxRows( event ){
			this.$emit( 'update-maxrows', parseInt( event.target.value ) );
		}
	}
};
</script>

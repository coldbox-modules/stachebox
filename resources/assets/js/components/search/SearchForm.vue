<template>
	<div class="relative w-full">
		<div class="relative mx-4 lg:mx-0 w-5/6">
			<a @click="$emit( 'onSearchUpdate', searchParams )" class="absolute inset-y-0 left-0 pl-3 flex items-center" v-tooltip="$t( 'Click to search' )">
				<fa-icon class="text-cyan-600 h-9 text-xs" icon="search" fixed-width />
			</a>

			<textarea
				class="form-input rounded-none block w-full h-10 py-2 px-2 pl-10 pr-4 focus:border-cyan-600"
				placeholder="Enter Text to Search"
				style="resize: none;"
				@keypress="suggest"
				v-model="searchParams.search"
				@keydown.enter.prevent="$emit( 'onSearchUpdate', searchParams )"
			></textarea>

			<a @click="filtersOpen = !filtersOpen" class="absolute inset-y-0 right-0 pr-5 flex items-center" v-tooltip="$t( 'Toggle Filters' )">
				<fa-icon class="text-cyan-600 h-9 text-xs fa-rotate-90" icon="sliders" fixed-width />
			</a>
		</div>

		<div v-show="filtersOpen" class="w-5/6 my-4">
			<h4 class="text-md text-gray-400 w-full clear-both pb-1 border-b">
			{{ $t( "Search Filters" ) }}
			<a @click="newFilter" class="inline float-right text-lg text-cyan-600 hover:cursor-pointer"><fa-icon icon="plus-circle" v-tooltip="$t( 'New Filter' )" /></a>
			<a @click="resetFilters" class="inline float-right text-lg text-gray-300 hover:cursor-pointer mr-5"><fa-icon icon="undo" v-tooltip="$t( 'Reset Filters' )" /></a>
			</h4>
			<search-params :searchFilters="searchParams" @apply-filter="updateParams" @apply-term="updateTerms"></search-params>
			<div ref="active-filters" class="search-filters mt-2">
				<div class="w-full relative">
					<SearchFilter v-for="( filter, index ) in availableTerms" :key="index" :filter="searchParams.terms[index]" :indexFields="indexFields" @removeFilter="removeFilter( index )"/>
				</div>
				<button class="bg-cyan-500 hover:bg-cyan-600 text-white text-xs font-bold py-1 px-3 rounded float-right" @click="$emit( 'onSearchUpdate', searchParams )">{{ $t( "Apply Filters" ) }}</button>
			</div>
		</div>
	</div>
</template>
<script>
import logsAPI from "@/api/logs";
import { mapState } from "vuex";
import SearchFilter from './SearchFilter.vue';
import SearchParams from "./SearchParams";
export default{
	components : {
		SearchFilter,
		SearchParams
	},
	props : {
		initialParams : {
			type : Object,
			required : false,
			default : function(){
				return {
					search : "",
					terms : [],
					minDate : null,
					maxDate : null
				}
			}
		}
	},
	data(){
		return {
			filtersOpen : false,
			indexMappings: {},
			indexFields : [],
			searchParams : {
				search : "",
				terms : [],
				minDate : null,
				maxDate : null
			}
		}
	},
	computed : {
		...mapState({
			authToken : ( state ) => state.authToken
		}),
		availableTerms(){
			let restrictedTerms = [
				"labels.application",
				"labels.environment",
				"log.level"
			]
			return this.searchParams.terms.filter( term => !restrictedTerms.includes( term.key ) );
		}
	},
	beforeMount(){
		var self = this;
		logsAPI.mappings( {}, this.authToken ).then( result => {
			self.indexFields = Object.keys( result.data ).filter( key => {
				var mappingKeys = Object.keys( result.data[ key ].mapping );
				return mappingKeys.length && result.data[ key ].mapping[ mappingKeys[ 0 ] ].type == "keyword";
			} );
		} );
	},
	watch : {
		initialParams : {
			handler( val ){
				this.searchParams = val;
			},
			deep : true
		}
	},
	methods : {
		newFilter(){
			this.searchParams.terms.push( { key : '', operator : 'must', value : '' } );
		},
		resetFilters(){
			this.searchParams.terms.splice( 0, this.searchParams.terms.length );
			this.searchParams.search = '';
			this.filtersOpen = false;
			this.$emit( 'onSearchUpdate', this.searchParams );

		},
		removeFilter( index ){
			this.searchParams.terms.splice( index, 1 );
		},
		updateParams( args ){
			var self = this;
			Object.keys( args ).forEach( ( key ) => this.searchParams[ key ] = args[ key ] || null );
			this.$emit( 'onSearchUpdate', this.searchParams );
		},
		updateTerms( args ){
			var self = this;
			Object.keys( args ).forEach( ( key ) => {
				if( ! args[ key ] ){
					self.searchParams.terms = self.searchParams.terms.filter( t => t.key != key );
					return;
				}
				let newTerm = { key : key, operator : 'must', value : args[ key ] || null };
				let exists = self.searchParams.terms.findIndex( t => t.key == key );
				if( exists > -1 ){
					self.searchParams.terms.splice( exists, 1, newTerm );
				} else {
					self.searchParams.terms.push( newTerm );
				}
			} );
		}
	}
}
</script>
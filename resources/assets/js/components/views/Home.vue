<template>
  <section>
	  <div class="bg-gray-800 pt-3">
			<div class="rounded-tl-3xl bg-gradient-to-r from-blue-900 to-gray-800 p-4 shadow text-2xl text-white">
				<h3 class="font-bold pl-2">Analytics</h3>
			</div>
		</div>

		<div class="flex flex-wrap">
			<div class="w-full md:w-1/2 xl:w-1/3 p-6">
				<!--Metric Card-->
				<div class="bg-gradient-to-b from-green-200 to-green-100 border-b-4 border-green-600 rounded-lg shadow-xl p-5">
					<div class="flex flex-row items-center">
						<div class="flex-shrink pr-4">
							<div class="rounded-full p-5 bg-green-600"><i class="fa fa-wallet fa-2x fa-inverse"></i></div>
						</div>
						<div class="flex-1 text-right md:text-center">
							<h5 class="font-bold uppercase text-gray-600">Total Revenue</h5>
							<h3 class="font-bold text-3xl">$3249 <span class="text-green-500"><i class="fas fa-caret-up"></i></span></h3>
						</div>
					</div>
				</div>
				<!--/Metric Card-->
			</div>
			<div class="w-full md:w-1/2 xl:w-1/3 p-6">
				<!--Metric Card-->
				<div class="bg-gradient-to-b from-pink-200 to-pink-100 border-b-4 border-pink-500 rounded-lg shadow-xl p-5">
					<div class="flex flex-row items-center">
						<div class="flex-shrink pr-4">
							<div class="rounded-full p-5 bg-pink-600"><i class="fas fa-users fa-2x fa-inverse"></i></div>
						</div>
						<div class="flex-1 text-right md:text-center">
							<h5 class="font-bold uppercase text-gray-600">Total Users</h5>
							<h3 class="font-bold text-3xl">249 <span class="text-pink-500"><i class="fas fa-exchange-alt"></i></span></h3>
						</div>
					</div>
				</div>
				<!--/Metric Card-->
			</div>
			<div class="w-full md:w-1/2 xl:w-1/3 p-6">
				<!--Metric Card-->
				<div class="bg-gradient-to-b from-yellow-200 to-yellow-100 border-b-4 border-yellow-600 rounded-lg shadow-xl p-5">
					<div class="flex flex-row items-center">
						<div class="flex-shrink pr-4">
							<div class="rounded-full p-5 bg-yellow-600"><i class="fas fa-user-plus fa-2x fa-inverse"></i></div>
						</div>
						<div class="flex-1 text-right md:text-center">
							<h5 class="font-bold uppercase text-gray-600">New Users</h5>
							<h3 class="font-bold text-3xl">2 <span class="text-yellow-600"><i class="fas fa-caret-up"></i></span></h3>
						</div>
					</div>
				</div>
				<!--/Metric Card-->
			</div>
			<div class="w-full md:w-1/2 xl:w-1/3 p-6">
				<!--Metric Card-->
				<div class="bg-gradient-to-b from-blue-200 to-blue-100 border-b-4 border-blue-500 rounded-lg shadow-xl p-5">
					<div class="flex flex-row items-center">
						<div class="flex-shrink pr-4">
							<div class="rounded-full p-5 bg-blue-600"><i class="fas fa-server fa-2x fa-inverse"></i></div>
						</div>
						<div class="flex-1 text-right md:text-center">
							<h5 class="font-bold uppercase text-gray-600">Server Uptime</h5>
							<h3 class="font-bold text-3xl">152 days</h3>
						</div>
					</div>
				</div>
				<!--/Metric Card-->
			</div>
			<div class="w-full md:w-1/2 xl:w-1/3 p-6">
				<!--Metric Card-->
				<div class="bg-gradient-to-b from-teal-200 to-teal-100 border-b-4 border-teal-500 rounded-lg shadow-xl p-5">
					<div class="flex flex-row items-center">
						<div class="flex-shrink pr-4">
							<div class="rounded-full p-5 bg-teal-600"><i class="fas fa-tasks fa-2x fa-inverse"></i></div>
						</div>
						<div class="flex-1 text-right md:text-center">
							<h5 class="font-bold uppercase text-gray-600">To Do List</h5>
							<h3 class="font-bold text-3xl">7 tasks</h3>
						</div>
					</div>
				</div>
				<!--/Metric Card-->
			</div>
			<div class="w-full md:w-1/2 xl:w-1/3 p-6">
				<!--Metric Card-->
				<div class="bg-gradient-to-b from-red-200 to-red-100 border-b-4 border-red-500 rounded-lg shadow-xl p-5">
					<div class="flex flex-row items-center">
						<div class="flex-shrink pr-4">
							<div class="rounded-full p-5 bg-red-600"><i class="fas fa-inbox fa-2x fa-inverse"></i></div>
						</div>
						<div class="flex-1 text-right md:text-center">
							<h5 class="font-bold uppercase text-gray-600">Issues</h5>
							<h3 class="font-bold text-3xl">3 <span class="text-red-500"><i class="fas fa-caret-up"></i></span></h3>
						</div>
					</div>
				</div>
				<!--/Metric Card-->
			</div>
		</div>
  </section>
</template>

<script>
export default {
  name: 'default',
  props: {
    msg: String
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>

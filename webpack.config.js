const elixir = require("coldbox-elixir");

elixir.config.mergeConfig({
    plugins: [],
	// pack all of our images and fonts in as base64 to prevent URL pathing issues
	module: {
		rules: [
			{
				test: /\.(woff2?|eot|ttf|otf)(\?.*)?$/,
				loader: "url-loader",
				options: {
					limit: 100000,
					name: global.elixir.versioning
						? "includes/fonts/[name].[hash:7].[ext]"
						: "includes/fonts/[name].[ext]"
				}
			},
			{
				test: /\.(png|jpe?g|gif|svg)(\?.*)?$/,
				loader: "url-loader",
				options: {
					limit: 100000,
					name: global.elixir.versioning
						? "includes/images/[name].[hash:7].[ext]"
						: "includes/images/[name].[ext]"
				}
			}
		]
	}
});

module.exports = elixir(function(mix) {
	mix.sass( "app.scss" )
		.vue( "app.js" );

});

const elixir = require("coldbox-elixir");
const fs = require('fs-extra');

elixir.config.mergeConfig({
	plugins: [
		{
			// Copy static images over after emit
			apply: (compiler) => {
				compiler.hooks.afterEmit.tap('AfterEmitPlugin', (compilation) => {
					fs.copySync('resources/assets/images/stachebox-icon.png', 'includes/images/stachebox-icon.png')
					fs.copySync('resources/assets/images/stachebox-logo.png', 'includes/images/stachebox-logo.png')
					fs.copySync('resources/assets/images/stachebox-logo-h.png', 'includes/images/stachebox-logo-h.png')
				})
			}
		}
	],
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

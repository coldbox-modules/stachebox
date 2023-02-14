const elixir = require("coldbox-elixir");
const fs = require('fs-extra');

elixir.base64SourceSize = 10000000000000;

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
	]
});

module.exports = elixir(function(mix) {
	mix.css( "app.css" )
		.css( "email.css" )
		.vue( "app.js" );

});

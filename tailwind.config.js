const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  theme: {
    extend: {
      fontFamily: {
		sans: ['Source Sans', ...defaultTheme.fontFamily.sans],
		mono: [ "Menlo", "Monaco", "Consolas", "Liberation Mono", "Courier New", ...defaultTheme.fontFamily.mono ],
		serif: [ 'Georgia', 'Cambria', 'Times New Roman', ...defaultTheme.fontFamily.serif]
      },
	}
  }
}
const defaultTheme = require('tailwindcss/defaultTheme');
const plugin = require('tailwindcss/plugin');

module.exports = {
   purge: [
	  "./resources/**/*.vue",
	  "./resources/**/*.js",
	  "./views/**/*.cfm",
	  "./layouts/**/*.cfm",
  ],
  theme: {
	colors: {
		current: "currentColor",
		transparent: "transparent",
		white: "#ffffff",
		black: "#000000",
		gray: {
			50: "#f9fafb",
			100: "#f4f5f7",
			200: "#e5e7eb",
			300: "#d2d6dc",
			400: "#9fa6b2",
			500: "#6b7280",
			600: "#4b5563",
			700: "#374151",
			800: "#252f3f",
			900: "#161e2e",
		},
		red: {
			50: "#fdf2f2",
			100: "#fde8e8",
			200: "#fbd5d5",
			300: "#f8b4b4",
			400: "#f98080",
			500: "#f05252",
			600: "#e02424",
			700: "#c81e1e",
			800: "#9b1c1c",
			900: "#771d1d",
		},
		orange: {
			50: "#fff8f1",
			100: "#feecdc",
			200: "#fcd9bd",
			300: "#fdba8c",
			400: "#ff8a4c",
			500: "#ff5a1f",
			600: "#d03801",
			700: "#b43403",
			800: "#8a2c0d",
			900: "#73230d",
		},
		yellow: {
			50: "#fdfdea",
			100: "#fdf6b2",
			200: "#fce96a",
			300: "#faca15",
			400: "#e3a008",
			500: "#c27803",
			600: "#9f580a",
			700: "#8e4b10",
			800: "#723b13",
			900: "#633112",
		},
		green: {
			50: "#f3faf7",
			100: "#def7ec",
			200: "#bcf0da",
			300: "#84e1bc",
			400: "#31c48d",
			500: "#0e9f6e",
			600: "#057a55",
			700: "#046c4e",
			800: "#03543f",
			900: "#014737",
		},
		teal: {
			50: "#edfafa",
			100: "#d5f5f6",
			200: "#afecef",
			300: "#7edce2",
			400: "#16bdca",
			500: "#0694a2",
			600: "#047481",
			700: "#036672",
			800: "#05505c",
			900: "#014451",
		},
		blue: {
			100: "#ebf8ff",
			200: "#d7ebf3",
			300: "#d7ebf3",
			400: "#86c3da",
			500: "#5eafce",
			600: "#369bc2",
			700: "#297492",
			800: "#1b4e61",
			900: "#0e2731",
		},
		indigo: {
			50: "#f0f5ff",
			100: "#e5edff",
			200: "#cddbfe",
			300: "#b4c6fc",
			400: "#8da2fb",
			500: "#6875f5",
			600: "#5850ec",
			700: "#5145cd",
			800: "#42389d",
			900: "#362f78",
		},
		purple: {
			50: "#f6f5ff",
			100: "#edebfe",
			200: "#dcd7fe",
			300: "#cabffd",
			400: "#ac94fa",
			500: "#9061f9",
			600: "#7e3af2",
			700: "#6c2bd9",
			800: "#5521b5",
			900: "#4a1d96",
		},
		pink: {
			50: "#fdf2f8",
			100: "#fce8f3",
			200: "#fad1e8",
			300: "#f8b4d9",
			400: "#f17eb8",
			500: "#e74694",
			600: "#d61f69",
			700: "#bf125d",
			800: "#99154b",
			900: "#751a3d",
		},
		cyan : {
			50: "#ECFEFF",
			100: "#CFFAFE",
			200: "#A5F3FC",
			300: "#67E8F9",
			400: "#22D3EE",
			500: "#06B6D4",
			600: "#0891B2",
			700: "#0E7490",
			800: "#155E75",
			900: "#164E63"
		},
		theme: "#159CBF"
	},
    extend: {
      fontFamily: {
		sans: ['Source Sans', ...defaultTheme.fontFamily.sans],
		mono: [ "Menlo", "Monaco", "Consolas", "Liberation Mono", "Courier New", ...defaultTheme.fontFamily.mono ],
		serif: [ 'Georgia', 'Cambria', 'Times New Roman', ...defaultTheme.fontFamily.serif]
	  }
	}
  },
  plugins: [
	require("@tailwindcss/forms"),
	require("@tailwindcss/typography"),
	require("@tailwindcss/aspect-ratio"),
	plugin(function({ addBase }) {
		addBase({
		   'html': { fontSize: "18px" },
		 })
	})
  ]

}
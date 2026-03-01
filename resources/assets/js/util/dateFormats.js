export const DATE_FORMATS = {
	"MM/DD/YYYY": {
		label: "MM/DD/YYYY",
		listFormat: "MM/DD/YYYY HH:mm",
		chartShort: "M/D",
		chartDaily: "ddd M/D",
		detailFormat: "MM/DD/YYYY HH:mm:ss",
		hourFormat: "hA"
	},
	"DD/MM/YYYY": {
		label: "DD/MM/YYYY",
		listFormat: "DD/MM/YYYY HH:mm",
		chartShort: "D/M",
		chartDaily: "ddd D/M",
		detailFormat: "DD/MM/YYYY HH:mm:ss",
		hourFormat: "H:00"
	},
	"DD.MM.YYYY": {
		label: "DD.MM.YYYY",
		listFormat: "DD.MM.YYYY HH:mm",
		chartShort: "D.M.",
		chartDaily: "ddd D.M.",
		detailFormat: "DD.MM.YYYY HH:mm:ss",
		hourFormat: "H:00"
	},
	"YYYY-MM-DD": {
		label: "YYYY-MM-DD",
		listFormat: "YYYY-MM-DD HH:mm",
		chartShort: "MM-DD",
		chartDaily: "ddd YYYY-MM-DD",
		detailFormat: "YYYY-MM-DD HH:mm:ss",
		hourFormat: "H:00"
	}
};

export function getDateFormats( formatKey ) {
	return DATE_FORMATS[ formatKey ] || DATE_FORMATS[ "MM/DD/YYYY" ];
}

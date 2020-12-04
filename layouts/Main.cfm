<!DOCTYPE html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!-->
<html>
<cfoutput>
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<title>StacheBox - The Coldbox Logging and Bug Tracking Platform</title>
		<!--- favicon --->
		<link href="#event.getModuleRoot()#/includes/images/stachebox-icon.png" rel="shortcut icon" type="image/png" />
		<!--- View Port --->
		<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
		<link rel="stylesheet" href="#elixirPath( "css/app.css" )#"/>
	</head>

	<body class="bg-gray-800 font-sans leading-normal tracking-normal">
		<div id="app"></div>
		<!-- dynamic assets -->
		<script type="application/javascript">
			window.globalData = #getInstance( "Util@cbelasticsearch" ).toJSON( prc.globalData )#;
		</script>
		<script type="application/javascript" src="#elixirPath( "js/runtime.js" )#"></script>
		<script type="application/javascript" src="#elixirPath( "js/vendor.js" )#"></script>
		<script type="application/javascript" src="#elixirPath( "js/app.js" )#"></script>
	</body>
</cfoutput>

</html>
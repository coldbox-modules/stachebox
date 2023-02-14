<!DOCTYPE html>
<html>
<cfoutput>
	<head>
		<meta charset="utf-8">
		<title>StacheBox - Email Notifications</title>
		<!--- View Port --->
		<cfscript>
			mailStyles = fileRead( expandPath( "/stachebox/includes/css/email.css" ) );
		</cfscript>
		<style type="text/css">
		#mailStyles#
		</style>
	</head>

	<body class="font-sans leading-normal tracking-normal flex-none">
		<div class="flex-none container px-0 ml-auto mr-auto">
			#renderView()#
		</div>
	</body>
</cfoutput>

</html>
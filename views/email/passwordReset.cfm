<div>
	<cfoutput>
	<h1 class="masthead mb-7 mt-7"><span class="sr-only">#$r( resource="Stachebox.password.reset.header", bundle="stachebox" )#</span></h1>

	<p class="text-center mb-5">#$r( resource="Stachebox.password.reset.message", bundle="stachebox" )#</a></p>

	<p class="text-center"><a href="#event.getHTMLBaseURL()#login/password-reset?token=#args.token#">#$r( resource="Stachebox.password.reset.create", bundle="stachebox" )#</a></p>

	<p class="text-center mb-5">#$r( resource="Stachebox.password.reset.expiration", bundle="stachebox" )#</a></p>
	</cfoutput>
</div>
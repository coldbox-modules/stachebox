component {
	property name="settingService" inject="SettingService@stachebox";
	property name="logSearchService" inject="LogSearchService@stachebox";
	property name="mailService" inject="MailService@cbmailservices";
	property name="moduleSettings" inject="coldbox:moduleSettings:stachebox";
	property name="requestService" inject="coldbox:RequestService";
	property name="baseURL";

	/**
	 * Configure the ColdBox Scheduler
	 */
	function configure(){
		variables.baseURL = variables.requestService.getContext().getHTMLBaseURL();

		task( "stachebox-hourly-notifications" )
			.call( function(){ processNotifications( "hourly" ); } )
			.everyHour()
			// Don't start it immediately, wait an hour. Especially so tests can pass if enabled in tests.
			.delay( 1, "hours" )
			.onOneServer();

		task( "stachebox-daily-notifications" )
			.call( function(){ processNotifications( "daily" ) } )
			.everyDayAt( "06:00" )
			.onOneServer();

		task( "stachebox-weekly-notifications" )
			.call( function(){ processNotifications( "weekly" ); } )
			.everyWeekOn( 2, "05:00" )
			.onOneServer();

		task( "stachebox-monthly-notifications" )
			.call( function(){ processNotifications( "monthly" ); } )
			.everyMonthOn( 1, "04:00" )
			.onOneServer();
	}

	/**
	 * Called before the scheduler is going to be shutdown
	 */
	function onShutdown(){
	}

	/**
	 * Called after the scheduler has registered all schedules
	 */
	function onStartup(){
		log.info( "√ Stachebox Scheduler started successsfully!" );
	}

	/**
	 * Called whenever ANY task fails
	 *
	 * @task      The task that got executed
	 * @exception The ColdFusion exception object
	 */
	function onAnyTaskError( required task, required exception ){
		log.error(
			"The task (#arguments.task.getName()#) failed to executed. Caused by: #exception.message & exception.detail#",
			{ "exception" : exception }
		);
	}

	/**
	 * Called whenever ANY task succeeds
	 *
	 * @task   The task that got executed
	 * @result The result (if any) that the task produced
	 */
	function onAnyTaskSuccess( required task, result ){
		log.info(
			"√ Task (#arguments.task.getName()#) completed succesfully in #arguments.task.getStats().lastExecutionTime# ms",
			arguments.task.getStats()
		);
	}

	/**
	 * Called before ANY task runs
	 *
	 * @task The task about to be executed
	 */
	function beforeAnyTask( required task ){
		log.info( "Executing scheduled task (#arguments.task.getName()#)..." );
	}

	/**
	 * Called after ANY task runs
	 *
	 * @task   The task that got executed
	 * @result The result (if any) that the task produced
	 */
	function afterAnyTask( required task, result ){
	}


	function processNotifications( required string frequency ){
		var timestamp = now();
		log.debug( "Scheduled task frequency of #frequency# running at #dateFormat( timestamp, "long" )#." );
		var projects = variables.settingService.getByName( "projects" ).getMemento();
		var indexPattern = variables.settingService.getByName( "logIndexPattern" ).getMemento().value;
		if( isNull( projects ) ) return;
		projects.value.filter( ( project ) => project.summaryEmails && project.frequency == frequency )
					.each( function( project ){
						var apps = project.applications;
						var params = {
							"labels.application" : apps,
							"stachebox.isSuppressed" : false,
							"collapse" : "stachebox.signature",
							"maxRows" : 25
						};
						var mailSubject = "[StacheBox] #project.name# @period Summary: @count Unique New Occurences";
						switch( frequency ){
							case "monthly":{
								params[ "minDate" ] = dateAdd( "m", -1, timestamp );
								params[ "maxDate" ] = timestamp;
								mailSubject = replace( mailSubject, "@period", "Monthly" );
								var reportPeriod = "month";
								break;
							}
							case "weekly" : {
								params[ "minDate" ] = dateAdd( "d", -7, timestamp );
								params[ "maxDate" ] = timestamp;
								mailSubject = replace( mailSubject, "@period", "Weekly" );
								var reportPeriod = "7 days";
								break;
							}
							case "daily" : {
								params[ "minDate" ] = dateAdd( "h", -24, timestamp );
								params[ "maxDate" ] = timestamp;
								mailSubject = replace( mailSubject, "@period", "Daily" );
								var reportPeriod = "24 hours";
								break;
							}
							case "hourly" : {
								params[ "minDate" ] = dateAdd( "h", -1, timestamp );
								params[ "maxDate" ] = timestamp;
								mailSubject = replace( mailSubject, "@hourly", "Monthly" );
								var reportPeriod = "hour";
								break;
							}
						}

						log.debug( "Scheduled task requesting all new records from #dateFormat( params.minDate, "long" )# to #dateFormat( timestamp, "long" )#." );

						var searchResults = logSearchService.search( params );

						log.debug( "Scheduled task frequency of #frequency# returned #searchResults.pagination.total# new entries to notify since #dateFormat( params.minDate, "long" )#." );

						if( searchResults.pagination.total ){
							var viewArgs = {
								"errors" : searchResults,
								"project" : project,
								"subject" : mailSubject,
								"reportPeriod" : reportPeriod,
								"frequency" : frequency,
								"baseURL" : variables.baseURL
							}
							mailSubject = replace( mailSubject, "@count", searchResults.pagination.total );
							variables.mailService.newMail(
									to = project.recipients,
									from = moduleSettings.notificationsFrom,
									subject = mailSubject
								).setView(
									view = "email/projectNotification",
									module = "stachebox",
									args = viewArgs,
									layout = "Email",
									layoutModule = "stachebox"
								).send();
						}

					} );
	}

}
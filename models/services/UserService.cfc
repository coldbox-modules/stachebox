/**
 *
 * @displayname User Service
 * @package stachebox.models
 * @description This is the User Service object
 * @author Jon Clausen <jclausen@ortussolutions.com>
 *
 **/
component accessors="true" {


	property name="bCrypt" inject="BCrypt@BCrypt";
	property name="moduleSettings" inject="coldbox:moduleSettings:stachebox";
	property name="settingService" inject="SettingService@stachebox";
	property name="mailService" inject="MailService@cbmailservices";
	property name="resourceService" inject="ResourceService@cbi18n";

    function getUser() provider="User@stachebox"{}

    function getSearchBuilder() provider="SearchBuilder@cbElasticSearch"{}

	function getESClient() provider="Client@cbElasticSearch"{}


    public function isValidCredentials( required string username, required string password ) {

        var user = retrieveUserByUsername( arguments.username );

        if ( isNull( user ) ) {
            return false;
        }

        return variables.bCrypt.checkPassword(
            arguments.password,
            user.getPassword()
        );
    }

    /**
     * Get a single user account by _id value
     *
     * @id The user id to query by.
     */
    public function retrieveUserById( required string id ) {
        return getUser().get( arguments.id );
    }

    /**
     * Get a single user account by email
     *
     * @id The user id to query by.
     */
    public function retrieveUserByUsername( required string username ) {
		var user = getUser().findByEmail( arguments.username );

        // nonexistent emails can not log in!
        if ( isNull( user ) || !user.getIsActive() ){
            return javaCast( "null", 0);
        }
        return user;
	}


	/**
	* Searches user records
	*/
	public function search( required struct searchCollection ){
		param arguments.searchCollection.maxrows = 25;
		param arguments.searchCollection.startrow = 0;
		param arguments.searchCollection.page = 1;
		param arguments.searchCollection.includes = "";
		param arguments.searchCollection.excludes = "";
		param arguments.searchCollection.sortOrder = "lastName ASC";
		param arguments.searchCollection.index = moduleSettings.usersIndex;

		var searchBuilder = getSearchBuilder()
								.new( arguments.searchCollection.index );

		searchBuilder.setMaxRows( arguments.searchCollection.maxrows );
		searchBuilder.setStartRow( arguments.searchCollection.startRow );

		listToArray( arguments.searchCollection.sortOrder ).each( function( sort ){
			searchBuilder.sort( sort );
		} );

		if( arguments.searchCollection.keyExists( "allowLogin" ) ){
			searchBuilder.term( "allowLogin", javacast( "boolean", arguments.searchCollection.allowLogin ) );
		}

		var result = searchBuilder.execute();

		return {
			"pagination" : {
				"total" : result.getHitCount(),
				"page" : searchCollection.page,
				"pages" : arguments.searchCollection.maxRows ? ceiling( result.getHitCount() / arguments.searchCollection.maxRows ) : 0,
				"startRow" : searchBuilder.getStartRow(),
				"maxRows" : javacast( "int", arguments.searchCollection.maxrows )
			},
			"results" : result.getHits().map( function( user ){ var memento = user.getMemento(); memento[ "id" ] = user.getId(); return memento; } )
		};
	}

	function processResetRequest( required User user ){
		// Create a token with a 1 hour timeout
		var resetToken = settingService.generateAPIToken( user=arguments.user, expiration=dateAdd( "h", 1, now() ) );

		arguments.user.setResetToken( resetToken ).save();

		var mailSubject = resourceService.getResource(
			resource="password.reset.request.subject",
			defaultValue="[StacheBox] Your Password Reset Request",
			bundle = "stachebox"
		);

		var viewArgs = {
			"user" : arguments.user.getMemento(),
			"token" : resetToken
		};

		variables.mailService.newMail(
									to = user.getEmail(),
									from = moduleSettings.notificationsFrom,
									subject = mailSubject
								).setView(
									view = "email/passwordReset",
									module = "stachebox",
									args = viewArgs,
									layout = "Email",
									layoutModule = "stachebox"
								).send();
	}

}

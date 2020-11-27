/**
 *
 * @displayname User Service
 * @package stachebox.models
 * @description This is the User Service object
 * @author Jon Clausen <jclausen@ortussolutions.com>
 *
 **/
component singleton accessors="true" {


	property name="bCrypt" inject="BCrypt@BCrypt";

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
		param arguments.searchCollection.includes = "";
		param arguments.searchCollection.excludes = "";

		var searchBuilder = getSearchBuilder()
								.new( getUser().getSearchIndexName() );

		searchBuilder.setMaxRows( arguments.searchCollection.maxrows );
		searchBuilder.setStartRow( arguments.searchCollection.startRow );

		var result = searchBuilder.execute();

		return {
			"results" : result.getHits().map(  )
		}
	}

}

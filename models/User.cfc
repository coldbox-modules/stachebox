/**
 * I model public search user accounts.
*/
component
    accessors="true"
{

    property name="id" type="string";
    property name="email" type="string" default="";
    property name="firstName" type="string" default="";
    property name="middleName" type="string" default="";
    property name="lastName" type="string" default="";
    property name="title" type="string" default="";
    property name="isActive" type="boolean" default="true";
    property name="isAdministrator" type="boolean" default="false";
	property name="avatar" type="string" default="";

	// memento default excluded properties
    property name="password" type="string" default="";
	property name="resetToken" type="string" default="";

	property name="moduleSettings" persistent="false" inject="coldbox:moduleSettings:stachebox";


    this.constraints = {
        "firstName" : {
            "required" : true,
            "type" : "string"
        },
        "lastName" : {
            "required" : true,
            "type" : "string"
        },
        "middleName": { "type": "string" },
        "title": { "type": "string" },
        "password" : {
            "required" : true,
            "type" : "string"
        },
        "email" : {
            "required" : true,
            "validator" : "UniqueFieldValidator@cbelasticsearch",
            "type" : "string"
        },
        "isActive": { "type": "boolean" }
    };

    this.memento = {
        "defaultIncludes" : [
            "id",
            "firstName",
            "middleName",
			"lastName",
			"title",
            "email",
            "isActive",
            "isApproved",
			"isAdministrator",
			"avatar"
		],

        "defaults" :{
            "id" : ""
        },
        "mappers" : {
			"id" : function( val ){ return len( val ) ? val : javacast( "null", 0 ); },
			"avatar" : function( val ){ return len( val ) ? val : javacast( "null", 0 ); }
        }
    };

    public function get( required string id ){
        if( isValid( "GUID", arguments.id ) ){
            var userDoc = getSearchClient().get( arguments.id, getSearchIndexName() );
            if( !isNull( userDoc ) ){
                return populate( userDoc.getMemento() ).setId( userDoc.getId() );
            }
        } else {
            return findByEmail( arguments.id );
        }
    }

	any function getOrFail( required any id ) {

		if ( isNull( id ) || ! len( id ) ) {
			throw(
				type = "EntityNotFoundException",
				message = "Could not find a #getEntityName()# entity with id [#id#]."
			);
        }

        var user = get( arguments.id );

		if ( isNull( user ) ) {
			throw(
				type = "EntityNotFoundException",
				message = "Could not find a #getEntityName()# entity with id [#id#]."
			);
		}

		return user;

	}

    function findByEmail( required string email ){
        var userSearch = newSearchBuilder()
                            .new( getSearchIndexName() )
                            .filterTerm( "email", arguments.email )
                            .execute();

        return userSearch.getHitCount() ? populate( userSearch.getHits()[ 1 ].getMemento() ).setId( userSearch.getHits()[ 1 ].getId() ) : javacast( "null", 0 );
    }

    function new( struct userStruct ){
        if( !isNull( arguments.userStruct ) ){
            return populate( arguments.userStruct );
        } else {
            return application.wirebox.getInstance( "User@WEATPublicSecurity" );
        }
    }

    function populate( required struct userStruct ){
        var beanPopulator = new coldbox.system.core.dynamic.BeanPopulator();

        beanPopulator.populateFromStruct(
            this,
            userStruct
        );

        if( structKeyExists( userStruct, "_id" ) ){
            setId( userStruct[ "_id" ] );
        }

        return this;
    }

    function validateOrFail(){
        getValidationManager().validateOrFail(
            target = this,
            constraints = this.constraints
        );
        return this;
    }

    function save(){
        var userDoc = newDocument().new(
            index=getSearchIndexName()
        ).populate( this.getMemento( includes="password,resetToken" ) );

        if( !isNull( getId() ) && len( getId() ) ){
            userDoc.setId( getId() );
        } else {
            var uuidLib = createobject("java", "java.util.UUID");
			variables[ "id" ] = uuidLib.randomUUID().toString();
			userDoc.getMemento()[ "id" ] = getId();
            userDoc.setId( getId() );
        }

        userDoc.save();

        return this;
    }

    function delete(){
        getSearchClient().get( getId(), getSearchIndexName() ).delete();
    }

    function encryptPassword(){
        variables.password = getBCrypt().hashPassword( variables.password );
        return this;
    }

    function setFirstName( string firstName ){
        variables.firstName = trim( arguments.firstName ?: "" );
        return this;
    }

    function setLastName( string lastName ){
        variables.lastName = trim( arguments.lastName ?: "" );
        return this;
    }

    /**
     * cbguard function to determine whether the current user (instance of this class)
     * has the required permission - e.g. `secured="Administrator"`
     */
    public boolean function hasPermission( required string permission ){
        return getIsAdministrator();
    }

    /**
     * cbguard function to determine whether the current user is in the given role.
     * If this user is an admin, just return true to all role queries.
     * If not, return false to all.
     * Yes, it's crude and rudimentary. Yes, it works.
     */
    public boolean function isInRole( required string role ){
        return getIsAdministrator();
    }

    /**
     * Grab an array of roles for the user.
     * Currently, we only have one role ("StacheboxAdministrator").
     * This is purposely different than the "Administrator" role
     * to avoid conflicting with the internal instance "Administrator" role name.
     */
    public array function getRoles(){
        var roles = [
			{
				"name" : "StacheboxUser"
			}
		];
        if ( getIsAdministrator() ){
            ArrayAppend( roles, { "name": "StacheboxAdministrator" });
        }
        return roles;
    }


    public function getMetadata(){
        return getMetadata( this );
    }

    /**
    * Standardized method to retrieve the search index for the entity
    **/
    public function getSearchIndexName(){
        return variables.moduleSettings.usersIndex;
	}

	/**
	 * JWT Interfaced Methods
	 */
	 /**
     * A struct of custom claims to add to the JWT token
     */
    struct function getJwtCustomClaims(){
		return getMemento();
	}

    /**
     * This function returns an array of all the scopes that should be attached to the JWT token that will be used for authorization.
     */
    array function getJwtScopes(){
		return getRoles().map( function( item ){ return item.name; } );
	}

    private function newDocument() provider="Document@cbelasticsearch"{}

    private function newSearchBuilder() provider="SearchBuilder@cbelasticsearch"{}

    private function getSearchClient() provider="Client@cbelasticsearch"{}

    private function getValidationManager() provider="ValidationManager@cbvalidation"{}

    private function getBcrypt() provider="BCrypt@BCrypt"{}
}
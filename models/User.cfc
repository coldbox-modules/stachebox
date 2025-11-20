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
	property name="allowLogin" type="boolean" default="true";
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
            "validator" : "UniqueFieldValidator@stachebox",
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
			"allowLogin"
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
        ).populate( this.getMemento( includes="password,resetToken,avatar" ) );

        if( !isNull( getId() ) && len( getId() ) ){
            userDoc.setId( getId() );
        } else {
            var uuidLib = createobject("java", "java.util.UUID");
			variables[ "id" ] = uuidLib.randomUUID().toString();
			userDoc.getMemento()[ "id" ] = getId();
            userDoc.setId( getId() );
        }

        userDoc.save( refresh=true );

        return this;
    }

    function delete(){
        getSearchClient().get( getId(), getSearchIndexName() ).delete();
    }

    function encryptPassword(){
        variables.password = getBCrypt().hashPassword( variables.password );
        return this;
    }

    function processAvatar(){
        if( !isNull( variables.avatar ) && len( variables.avatar ) ){
            try {
                // Check if it's a valid data URI
                if( !reFindNoCase( "^data:image/", variables.avatar ) ){
                    throw(
                        type = "ValidationException",
                        message = "Invalid avatar format. Must be a base64-encoded image."
                    );
                }

                // Extract the base64 data (everything after the comma)
                var base64Data = listLast( variables.avatar, "," );

                // Decode base64 to binary
                var imageData = toBinary( base64Data );

                // Validate max upload size (10MB for raw upload)
                var maxUploadSize = 10 * 1024 * 1024; // 10MB
                if( arrayLen( imageData ) > maxUploadSize ){
                    throw(
                        type = "ValidationException",
                        message = "Avatar image is too large. Maximum upload size is 10MB."
                    );
                }

                // Create image object from binary data
                var img = imageNew( imageData );

                // Get image dimensions
                var width = imageGetWidth( img );
                var height = imageGetHeight( img );

                // Resize if necessary (max 200x200, maintaining aspect ratio)
                if( width > 200 || height > 200 ){
                    imageScaleToFit( img, 200, 200 );
                }

                // Ensure it's exactly 200x200 by cropping from center
                var currentWidth = imageGetWidth( img );
                var currentHeight = imageGetHeight( img );

                if( currentWidth != 200 || currentHeight != 200 ){
                    var cropX = max( 0, floor( ( currentWidth - 200 ) / 2 ) );
                    var cropY = max( 0, floor( ( currentHeight - 200 ) / 2 ) );
                    imageCrop( img, cropX, cropY, min( 200, currentWidth ), min( 200, currentHeight ) );
                }

                // Convert to PNG for consistent format (supports transparency, lossless)
                // Write to byte array and convert to base64
                var baos = createObject( "java", "java.io.ByteArrayOutputStream" ).init();

                // Write the image as PNG to the byte array output stream
                var ImageIO = createObject( "java", "javax.imageio.ImageIO" );
                var bufferedImage = imageGetBufferedImage( img );
                ImageIO.write( bufferedImage, "png", baos );

                // Convert to base64 and create data URI
                var processedBase64 = toBase64( baos.toByteArray() );
                variables.avatar = "data:image/png;base64," & processedBase64;

            } catch( any e ){
                // Log the full error for debugging
                writeLog( file="application", text="Avatar processing error: #e.message# - Detail: #e.detail#" );

                throw(
                    type = "ValidationException",
                    message = "Failed to process avatar image: #e.message# #e.detail#",
                    extendedInfo = serializeJSON( { "avatar": ["Failed to process image: #e.message#"] } )
                );
            }
        }
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
	* Determine whether a user has
	*
	* @permission any either a single permission or an array or list of any permissions to match
	*/
    public boolean function hasPermission( required any permission ){
		if( isSimpleValue( arguments.permission ) ){
			arguments.permission = listToArray( arguments.permission );
		}
        return getIsAdministrator()
					? true
					: getPermissions()
						.reduce( function( boolean result, assigned ){
							if( !result ){
								result = permission.containsNoCase( assigned );
							}
							return result;
						}, false );
    }

    /**
	 * Determines whether a user is in a role
	 *
	 * @role string
	 */
    public boolean function isInRole( required string role ){
        return getIsAdministrator()
				? true
				: !! getRoles().findNoCase( ( assigned ) => assigned.name == role );
    }

	public array function getPermissions(){
		return getRoles().reduce(
			function( acc, role ){
				acc.append( role.permissions, true );
				return acc;
			},
			[]
		);
	}


	/**
	 * Returns the roles assigned to the current user
	 */
    public array function getRoles(){
        var roles = [
			{
				"name" : "Reporter",
				"permissions" : [ "StacheboxReporter" ]
			}
		];
		if( getAllowLogin() ){
			roles.append(
				{
					"name" : "User",
					"permissions" : [ "StacheboxUser" ]
				}
			);
		}
        if ( getIsAdministrator() ){
			roles.append(
				{
					"name": "Administrator",
					"permissions" : [ "StacheboxAdministrator" ]
				}
			);
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
        // we don't need avatar in jwt token
		return getMemento( excludes = 'avatar' );
	}

    /**
     * This function returns an array of all the scopes that should be attached to the JWT token that will be used for authorization.
     */
    array function getJwtScopes(){
		return getPermissions();
	}

    private function newDocument() provider="Document@cbelasticsearch"{}

    private function newSearchBuilder() provider="SearchBuilder@cbelasticsearch"{}

    private function getSearchClient() provider="Client@cbelasticsearch"{}

    private function getValidationManager() provider="ValidationManager@cbvalidation"{}

    private function getBcrypt() provider="BCrypt@BCrypt"{}
}
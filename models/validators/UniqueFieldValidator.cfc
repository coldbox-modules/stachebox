/**
 * Validates if the field has a unique value in the Elasticsearch index
 */
component accessors="true" singleton {

	// Properties
    property name="name";
    property name="wirebox" inject="wirebox";

	/**
	 * Constructor
	 */
	UniqueFieldValidator function init(){
		variables.name       = "UniqueFieldValidator";
		return this;
	}

	/**
	 * Will check if an incoming value validates
	 *
	 * @validationResult The result object of the validation
	 * @validationResult_generic cbvalidation.models.result.IValidationResult
	 * @target The target object to validate on
	 * @field The field on the target object to validate on
	 * @targetValue The target value to validate
	 * @validationData The validation data the validator was created with
	 */
	boolean function validate(
		required any validationResult,
		required any target,
		required string field,
		any targetValue,
		any validationData
	){
		// return true if no data to check, type needs a data element to be checked.
		if (
			isNull( arguments.targetValue ) || ( isSimpleValue( arguments.targetValue ) && !len( arguments.targetValue ) )
		) {
			return true;
        }

		var searchBuilder = variables.wirebox.getInstance( "SearchBuilder@cbelasticsearch" )
							.new( arguments.target.getSearchIndexName() )
							.filterTerm( arguments.field, arguments.targetValue );

        if( !isNull( arguments.target.getId() ) && len( arguments.target.getId() ) ){
            searchBuilder.filterTerm( "_id", arguments.target.getId(), "must_not" );
		}

		// validate uniqueness
		if ( searchBuilder.count() ) {
			var args = {
				message        : "The #commonName( arguments.field )# '#arguments.targetValue#' is already in use in the system and must be unique",
				field          : arguments.field,
				validationType : getName(),
				validationData : arguments.validationData,
				rejectedValue  : arguments.targetValue
			};
			validationResult.addError( validationResult.newError( argumentCollection = args ) );
			return false;
		}

		return true;
	}

	/**
	 * Get the name of the validator
	 */
	string function getName(){
		return name;
	}

	string function commonName( field ){
		switch( field ){
			case "email":
				return "Email Address";
			case "username":
				return "Username";
			default:
				return field;

		}
	}

}

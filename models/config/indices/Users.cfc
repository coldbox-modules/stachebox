/**
* Elasticsearch mapping configuration for public search users
**/
component accessors="true"{

    property name="config";

    variables.config = {
		"settings" : {
			"number_of_shards" : 2,
			"number_of_replicas" : 1
		},
        "mappings": {
            "_doc": {
                "properties": {
                    "isActive": { "type": "boolean" },
                    "isAdministrator": { "type": "boolean" },
                    "firstName": { "type": "text" },
                    "lastName": { "type": "text" },
                    "email": { "type": "keyword" },
					"title": { "type": "text" },
					"avatar" : { "type" : "binary" },
                    "password": {
                        "type": "text",
                        "index": false
                    }
                }
            }
        }
    };

}

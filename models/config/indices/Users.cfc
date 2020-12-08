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
                    "firstName": { "type": "keyword" },
                    "lastName": { "type": "keyword" },
                    "email": { "type": "keyword" },
					"title": { "type": "keyword" },
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

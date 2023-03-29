# CFML Error Logging

By default, the [Logstash appender](https://github.com/coldbox-modules/logstash#configuration) becomes enabled with the installation of stachebox into an application.  

To use the defaults while customizing the application name you can either add the `LOGSTASH_APPLICATION_NAME` environment variable, or you can provide the variable in your `config/Coldbox.cfc`:

```javascript
moduleSettings = {
	"logstash" : {
		"applicationName" : "My Application Name",
	}
}
```


In addition, if choosing to run a stachebox instance as a standalone installation, you may install only the `logstash` module in to your application and configure it to log either directly to the elasticsearch server ( the default, will use the [Elasticsearch configuration options] ) or, to log directly to the stachebox instance API, you may a custom API configuration to your Coldbox configuration file, like so:

```javascript
moduleSettings = {
	"logstash" : {
		"transmission" : "api",
		"applicationName" : "My Application Name",
		"apiUrl" : "https://my.logstashmicroservice.com/logstash/api/logs,
		"apiAuthToken : "[My SECRET Token]"
	}
}
```

You may read more about [configuring the logstash module here](https://github.com/coldbox-modules/logstash#configuration).

In addition, you may configure separate appenders with different logging levels.  For example, you might want warn level logging for a custom module, such as authentication.  An example configuration of this type of custom appender:

```javascript
logstash = {
	class="cbelasticsearch.models.logging.LogstashAppender",
	properties = {
		// Provide a unique name for the application ( optional ) - useful for filtering shared log indexes
		"applicationName"  : "App Warnings",
		// Optional release version
		"releaseVersion"   : "1.0.0",
		// the frequency of index rotation
		"levelMin"     : "WARN",
		"levelMax"     : "WARN"
	}
}
```

Then, in your top-level logbox configuration you would simply add:

```
warn = [ "myModule" ]
```

which would log only warnings from that specific module to the separate `-warnings` index configured above.

For more granular control and additional information on appenders, see the [cbElasticsearch Logging documentation](https://cbelasticsearch.ortusbooks.com/logging).
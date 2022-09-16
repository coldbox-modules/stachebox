# Filebeat Logging

Filesystem logging may be implemented, for many different operating systems, via the installation and configuration of the [FileBeat Binary for Logstash/Elasticsearch](https://www.elastic.co/beats/filebeat).

Once this binary is installed on your machine, you can adjust your configuration to ship logs directly to your Elasticsearch server, which will then be available for searching and viewing in Stachebox.

A basic configuration, in your `filebeat.yml` file to send logs directly to an Elasticsearch server is as follows:

```
output.elasticsearch:
  hosts: ["https://[ my ES server hostname or IP]:9200"]
  username: "filebeat"
  password: "[ your filebeat password ]"
```

For more information on configuring connections, [see the official documentation](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-installation-configuration.html#set-connection).

Filebeat provides a variety of [pre-made processors for parsing log files](https://www.elastic.co/guide/en/beats/filebeat/current/configuration-filebeat-options.html), but there are also built in modules.  To see the list of modules, you can run `filebeat modules list`.  For example, to enable the NGINX logging module, you can simply run `filebeat modules enable nginx` and it will auto-configure itself to ingest NGINX site logs.  For more information on modules and settings, [see the documentation](https://www.elastic.co/guide/en/beats/filebeat/current/configuration-filebeat-options.html).


Once you have configured your Elasticsearch connection and start the filebeat service ( `service filebeat start` ), your log files will be ingested in to Elasticsearch and will be visible in Stachebox.
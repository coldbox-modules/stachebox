# Filebeat Logging

Filesystem logging may be implemented, for many different operating systems, via the installation and configuration of the [FileBeat Binary for Logstash/Elasticsearch](https://www.elastic.co/beats/filebeat).

Once this binary is installed on your machine, you can adjust your configuration to ship logs directly to your Elasticsearch server, which will then be available for searching and viewing in Stachebox.

A basic configuration, in your `filebeat.yml` file to send logs directly to an Elasticsearch server is as follows:

```
output.elasticsearch:
  # Array of hosts to connect to.
  hosts: ["127.0.0.1:9200"]

  # Protocol - either `http` (default) or `https`.
  protocol: "http"

  # Authentication credentials - either API key or username/password.
  username: "filebeat"
  password: "[ your filebeat password ]"

  # Ensure older versions of Elasticsearch are supported
  allow_older_versions: "true"
```

Next you will need to configure a filestream to ingest your logs. An example configurations for CommandBox logs would be as follows:

```
filebeat.inputs:

# Each - is an input. Most options can be set at the input level, so
# you can use different inputs for various configurations.
# Below are the input specific configurations.

# filestream is an input for collecting log messages from files.
- type: filestream

  # Unique ID among all inputs, an ID is required.
  id: commandbox.logs

  # Change to true to enable this input configuration.
  enabled: true

  # Paths that should be crawled and fetched. Glob based paths.
  paths:
    - /usr/local/lib/serverHome/logs/server.out.txt

  # Exclude lines. A list of regular expressions to match. It drops the lines that are
  # matching any regular expression from the list.
  exclude_lines: [ '^\[DEBUG', '^\[INFO' ]

  # Include lines. A list of regular expressions to match. It exports the lines that are
  # matching any regular expression from the list.
  include_lines: ['^\[ERR', '^\[WARN', '^\[FATAL']

  # Handle multi-line errors and stack traces
  parsers:
  - multiline:
      type: pattern
      pattern: '^[(\[]'
      negate: true
      match: after

  # Exclude files. A list of regular expressions to match. Filebeat drops the files that
  # are matching any regular expression from the list. By default, no files are dropped.
  prospector.scanner.exclude_files: ['.gz$']

  # Optional additional fields. These fields can be freely picked
  # to add additional information to the crawled log files for filtering
  fields:
   application: my-application-name
```

For more information on configuring connections, [see the official documentation](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-installation-configuration.html#set-connection).

Filebeat provides a variety of [pre-made processors for parsing log files](https://www.elastic.co/guide/en/beats/filebeat/current/configuration-filebeat-options.html), but there are also built in modules.  To see the list of modules, you can run `filebeat modules list`.  For example, to enable the NGINX logging module, you can simply run `filebeat modules enable nginx` and it will auto-configure itself to ingest NGINX site logs.  For more information on modules and settings, [see the documentation](https://www.elastic.co/guide/en/beats/filebeat/current/configuration-filebeat-options.html).


Once you have configured your Elasticsearch connection and start the filebeat service ( `service filebeat start` ), your log files will be ingested in to Elasticsearch and will be visible in Stachebox.
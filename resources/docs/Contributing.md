Contributing
=============

Follow these steps to get started hacking on CBElasticsearch.

1. Clone the module - `git clone git@github.com:coldbox-modules/stachebox.git`
3. Start a new Elasticsearch instance ( from the root of the project ) - `docker-compose up -d --build`
2. Install test harness dependencies - `cd test-harness && box install`
4. Start the StacheBox test harness server ( from the test harness directory ) - `box server start serverConfigFile=server-lucee@5.json`
5. Run tests ( from the test harness directory ) - `box testbox run`
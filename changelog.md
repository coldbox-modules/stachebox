# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

----
## [2.0.2] - 2023-04-18
### Fixed
* Fixed rendering of Lucee HTML messages as extra info
## [2.0.1] - 2023-03-29
### Fixed
* Fixed UI and initialization errors when running with an external User Service
* UI Updates to consolidate redundant fields
* Fixes an issue with suppression of environment-based log data

### Added
* Added attempts to parse a thrown error message where the exception was provided as the message
## [2.0.0] - 2023-03-04
### Changed
- STACHEBOX-14 - Upgraded to VueJS v3
- Updated Logstash/cbElasticsearch dependencies to v2
- Updates All log parsing and display to use [Elastic Common Schema](https://www.elastic.co/guide/en/ecs/8.6/ecs-reference.html)
### Added
- STACHEBOX-10 - Full i18n support for application text
- STACHEBOX-11 - Added Application/Environment Log History Charting to UI
- STACHEBOX-11 - Added Environments Navigation to Sidebar
- STACHEBOX-9 - Added the ability to group applications and beats in to Projects

## [1.0.5] - 2022-09-16

### Fixed
- Fixed permission name on API guards for administrators
- Updated NPM build process and updated outdated JS libraries

### Added
- Added new `StacheboxLog` permission, which can log, but does not allow UI access
- Added additional documentation on CFML, Javascript, and Filebeat logging
## [1.0.4] - 2021-07-14

### Fixed
- Fixed an issue where non-event-based logs would not display in sidebar
## [1.0.3] - 2021-07-14

### Changed
- Changed mapping customization updates to fail quietly, rather than throwing
### Fixed
- Fixed typo reference in invocation path
## [1.0.2] - 2021-02-22

### Fixed
- Add UniqueFieldValidator and fix DSL path
- Fix default avatar and callback


## [1.0.1] - 2021-02-21

### Fixed
- Fix icon path in interceptor

## [1.0.0] - 2021-02-20

## Added
- Official first release
## Fixed
- Fixes a regression in internal/external security redirect
- Fixes a javascript error when no applications were returned from API
### Changed
- Discontinued support for Coldbox 5 due to major differences in module dependencies

## [0.1.0] - 2020-12-25

### Added
- Public Beta release of module



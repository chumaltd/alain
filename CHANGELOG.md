## Alain 0.7.4

* update to tonic 0.10, prost 0.12, once_cell 1.18
* Supress git repo error messages on `--force` option

## Alain 0.7.3

* update tonic-build to 0.7

## Alain 0.7.2

* update to tonic 0.7, prost 0.10

## Alain 0.7.1

* show listening address on startup

## Alain 0.7.0

* `--use-server-conf`` option opt-in support for github.com/chumaltd/server-util/
* show cargo package name/version on startup

## Alain 0.6.0

* update tonic version to 0.6

## Alain 0.5.0

* Move test shutdown trigger setup into common module

## Alain 0.4.1

* Fix: add fully qualified Client name for integration test case

## Alain 0.4.0

* Generate integration test and test helper skeleton
* Add type annotation to request variables in each method.

## Alain 0.3.3

* Include messages not used in rpc

## Alain 0.3.2

* Fixes: fill missing crate / fill missing trait / remove unmatch '}'
* Template indentation with leading 4 spaces.

## Alain 0.3.1

* Requires clean git branch by default for safety.

## Alain 0.3.0

* diff Messages for update .proto case

## Alain 0.2.0

* generate Server implementation
* generate build.rs for tonic-build

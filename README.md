# Heimdall

A web application that lets you share sensitive data in a secure way.

## Use Cases

## Demo

## Installation

## Configurations

### Environment Variables

| env var name                            | description                                                                                        | default     |
|:---------------------------------------:|:--------------------------------------------------------------------------------------------------:|:-----------:|
|`PRUNE_OLD_SECRETS`                      | Deletes expired/stale (past max attempts) secrets                                                  | true        |
|`SECRETS_PRUNER_INTERVAL_MS`             | Time interval in milliseconds between each prune if `PRUNE_OLD_SECRETS` is `true`                  | 30000       |
|`DELETE_QUERY_TIMEOUT_MS`                | Maximum time in milliseconds each prune query should take if `PRUNE_OLD_SECRETS` is `true`         | 1500        |
|`SECRET_EXPIRATION_CHECK_PERIOD_MS`      | Time interval in milliseconds to check whether a secret is expired when trying to decrypt it       | 5000        |

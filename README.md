# Heimdall

A web application that lets you share sensitive data in a secure and easy way.

Whether it's wanting to share a password to a team account or share your health
insurance subscription ID with your doctor, Heimdall has you covered.

## Quick Walkthrough

A sender first navigates to Heimdall to create a new secret. The sender can choose
an encryption algorithm (to encrypt the secret at rest), expiration time and
other parameters before hitting the "Create" button. Upon creation, Heimdall will
give the sender an option to copy a shareable link to the secret. The sender can
then share the link with a receiver, who upon navigatin to the page will be
prompted for a password (or a key) which is needed for decrypting the secret. If
the receiver uses the correct key within the expiration period, the receiver
can get the secret.

[![Diagram](https://mermaid.ink/img/pako:eNqFUr1uwjAQfpWTZ3iBDAxtqmbqQNYsR3wQq_5J7QsIId6954TQFKQ2k-P7_vzZF9UGTapQib4G8i2VBg8RXeNBPmw5RKgBE9TkNcXl9jZvb6klc8yDadRjZNOaHj1DlQEVGafR2udxmcclMu4w0cyvYb3ZQFXAayRkAgRPJ0jURmI4Ge6A2QJ6LVIpnULU90jmmAnV9F_BOguVBdSSlRJwRyDni-eeSc-CxkP5cicIvi7gnTiJbepQEuwsgTX-c8JoWtosA2_FJxMmn8yQRQzDoRMpSyllxyESONJmcH-R53P9CPgg-_GBup2L-sCjOUgkYYdRYEyupxC5KPJM8bf2f52NHTy1tY_BPfQl_iWNsMlgQi4RcrjSpN7i-Rmx7FOtlKPo0Gh5jJc8b5TgHTWqkKWmPQ6WG9X4q0CHXgvrTRu5XFXs0SZaKRw41GffqoLjQDPo9qBvqOs3hAH3NA?type=png)](https://mermaid.live/edit#pako:eNqFUr1uwjAQfpWTZ3iBDAxtqmbqQNYsR3wQq_5J7QsIId6954TQFKQ2k-P7_vzZF9UGTapQib4G8i2VBg8RXeNBPmw5RKgBE9TkNcXl9jZvb6klc8yDadRjZNOaHj1DlQEVGafR2udxmcclMu4w0cyvYb3ZQFXAayRkAgRPJ0jURmI4Ge6A2QJ6LVIpnULU90jmmAnV9F_BOguVBdSSlRJwRyDni-eeSc-CxkP5cicIvi7gnTiJbepQEuwsgTX-c8JoWtosA2_FJxMmn8yQRQzDoRMpSyllxyESONJmcH-R53P9CPgg-_GBup2L-sCjOUgkYYdRYEyupxC5KPJM8bf2f52NHTy1tY_BPfQl_iWNsMlgQi4RcrjSpN7i-Rmx7FOtlKPo0Gh5jJc8b5TgHTWqkKWmPQ6WG9X4q0CHXgvrTRu5XFXs0SZaKRw41GffqoLjQDPo9qBvqOs3hAH3NA)

```mermaid
sequenceDiagram
    actor S as Sender
    actor R as Receiver

    participant H as Heimdall
    participant D as Database

    S ->> H: Create a new secret with ttl and password
    activate H
    H -->> D: Stores the encrypted secret in DB
    H ->> S: Gets a shareable link
    deactivate H

    S ->> R: Shares the link through a less secure medium

    S ->> R: Shares the password through another medium

    R ->> H: Navigates to the shared link and enters the password
    activate H
    H -->> D: Gets encrypted secret from DB
    H ->> H: Decrypts the secret
    H ->> R: Displays the secret
    deactivate H
```



## Use Cases

## Demo

## Installation

## Features

* Ability to share information as a URL with a TLL.
* Ability to encrypt information using encryption algorithms.
* Supported encryption algoritms:
    * `aes_gcm`: Symmetric-key encryption. Can use any (but same) password to encrypt/send and decrypt/receive information
    * `plaintext`: No password needed to encrypt/send or decrypt/receive
    * `rsa`: Asymmetric-key encryption. Use public key to encrypt/send and private key to decrypt/receive information.
* Encryption of secure information at rest (even when sharing using `plaintext` algo)

## Configurations

Heimdall is built with both ease-of-setup and configurability in mind. We know
that people approach security differently and will have their own use cases
that Heimdall could serve, so we added some of the most common configuration
parameters to Heimdall, powered by environment variables that take affect
at container/application start-time.

| env var name                            | description                                                                                        | default     |
|:---------------------------------------:|:--------------------------------------------------------------------------------------------------:|:-----------:|
|`PRUNE_OLD_SECRETS`                      | Deletes expired/stale (past max attempts) secrets                                                  | true        |
|`SECRETS_PRUNER_INTERVAL_MS`             | Time interval in milliseconds between each prune if `PRUNE_OLD_SECRETS` is `true`                  | 30000       |
|`DELETE_QUERY_TIMEOUT_MS`                | Maximum time in milliseconds each prune query should take if `PRUNE_OLD_SECRETS` is `true`         | 1500        |
|`SECRET_EXPIRATION_CHECK_PERIOD_MS`      | Time interval in milliseconds to check whether a secret is expired when trying to decrypt it       | 5000        |

## Naming

> Heimdall, Old Norse Heimdallr, in Norse mythology, the watchman of the gods

Just how Heimdall protects the Norse gods and Bifrost, the bridge between realms,
this app protects your sensitive data while providing a channel to share it with
others.

> ![Heimdall](https://media.giphy.com/media/XbPPSwVMWwisg/giphy.gif)
>
> Credit: giphy/gifs/marvel-thor-idris-elba-XbPPSwVMWwisg

## About the Team

This app was built as part of Spawnfest 2023 by a wife + husband team: Susan Walker and Adi Iyengar.
Susan has always been interested in Elixir and BEAM-based languages, and Adi being comfortable with
them thought it would be a fun couple's activity try to to build Heimdall at Spanwfest.

* [@thebugcatcher](https://github.com/thebugcatcher)
* [@susanwalker](https://github.com/susanwalker)

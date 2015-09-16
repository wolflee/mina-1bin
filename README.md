# mina-1bin

## Introduction

A general template repository to deploy single binary with same static config files on multiple servers. It uses [mina][] (mina-deploy) as the deployer.

## Requirements

- [ruby][] version >= 1.8.7
- remote server is linux 64-bit (if needed rsync upload)

## Installation

run the following in shell:

```bash
git clone git@github.com:wolflee/mina-1bin.git
cd mina-1bin
```
**And then symlink the binary file to deploy under the root path in the repo**

If [bundler][] is installed, then run:

```bash
bundle install
```

If you don't have or don't want to use `bundler`, `gem` installation is also fine:

```bash
gem install mina
gem install mina-multistage
```

## How to configure servers

All server related configuration is under `config/servers`. To add a new server, these actions are needed:

1. Add server name in `config/servers.yml`
2. Add config/servers/[server name].rb file accordingly
3. Modify settings in the file added in step 2

**<a id="config-parameters">Configuration Parameters</a>** are listed in the following table.

| Setting         | Meaning                          | Suggested Value                                          |
| --------------- | -------------------------------- | -------------------------------------------------------- |
| domain          | remote server address            | server ip/hostname or alias set in ssh config            |
| user            | username to ssh login            | ask your sysadmin                                        |
| deploy_to       | path to deploy                   | should be globally set, separated set is not recommended |
| binary_filename | application filename             | should be globally set, separated set is not recommended |
| rsync_options   | options when use rsync to upload | probably no need further configuration                   |

After all the settings are settled, before the first time each server is deploy, `setup` is required to be executed once:

```bash
mina [server name] setup
```

[server name] should be the same as the filename in config/servers/ .

After the execution process, please modify settings in [deploy_to]/shared/config.prod (Optional).

`setup` process is only needed once.

## How to deploy

After all the configuration is done, and `mina setup` is executed once, run 

```bash
./deploy
```
will simply deploy all the servers.

[ruby]: https://www.ruby-lang.org
[mina]: http://mina-deploy.github.io/mina/
[bundler]: http://bundler.io/
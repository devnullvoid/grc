[![Slack Room][slack-badge]][slack-link]

# cGRC

[cgrc](https://github.com/carlonluca/cgrc/tree/master/cgrc-rust) colorizer for fish-shell.

Allows the colorization of commands.

This plugin prefers `cgrc` configs first and falls back to `grc` for commands not supported by `cgrc`.

## Install

With [fisher]

``` 
fisher add orefalo/grc
```

Fisher installs the plugin files and the plugin now copies its bundled `cgrc` configs into `cgrc --location-user` during install and update events.

If `cgrc` is installed after the plugin, the next Fish startup will copy the bundled configs automatically.

If you already had the plugin installed before this change, run:

```
fisher update orefalo/grc
```

## Usage

Install both tools:

* `cgrc`: <https://github.com/carlonluca/cgrc/tree/master/cgrc-rust>
* `grc`: <https://github.com/garabik/grc>

The bundled custom configs are installed into your user `cgrc` config directory, so they appear in:

```
cgrc --list-configurations
```

At runtime the wrapper uses `cgrc` when a matching configuration exists, including bundled custom configs and embedded `cgrc` configs. It falls back to `grc` for the remaining supported commands.

### Default commands

* jobs
* env
* gcc
* ifconfig
* configure
* lsof
* mount
* sysctl
* uptime
* vmstat
* whois

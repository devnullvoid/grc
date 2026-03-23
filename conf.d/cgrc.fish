set -l __grc_plugin_dir (path dirname (status filename))
set -g __grc_asset_config_dir (path resolve $__grc_plugin_dir/../functions/_grc_assets/configs)

set -g __grc_grc_fallback_execs cat cvs df diff dig gcc g++ ls ifconfig \
    make mount mtr netstat ps tail traceroute \
    wdiff blkid du dnf docker docker-compose docker-machine env id ip iostat journalctl kubectl \
    last lsattr lsblk lspci lsmod lsof getfacl getsebool ulimit uptime nmap \
    fdisk findmnt free semanage sar ss sysctl systemctl stat showmount \
    tcpdump tune2fs vmstat w who sockstat whois configure

function __grc_cgrc_user_dir
    command -sq cgrc
    or return 1

    cgrc --location-user
end

function __grc_refresh_cgrc_configs
    set -g __grc_available_cgrc_configs

    command -sq cgrc
    or return 0

    set -g __grc_available_cgrc_configs (
        cgrc --list-configurations \
        | string match -r '^\s*\S+\s+->.*$' \
        | string replace -rf '^\s*(\S+)\s+->.*$' '$1' \
        | path basename
    )
end

function __grc_sync_cgrc_configs
    set -l user_dir (__grc_cgrc_user_dir)
    or return 0

    test -d "$__grc_asset_config_dir"
    or return 0

    command mkdir -p "$user_dir"
    command cp -f $__grc_asset_config_dir/* "$user_dir"/
    __grc_refresh_cgrc_configs
end

function __grc_sync_cgrc_configs_if_needed
    command -sq cgrc
    or return 0

    __grc_refresh_cgrc_configs

    for config_path in $__grc_asset_config_dir/*
        set -l config_name (path basename $config_path)
        contains -- $config_name $__grc_available_cgrc_configs
        or begin
            __grc_sync_cgrc_configs
            return 0
        end
    end
end

function __grc_remove_cgrc_configs
    set -l user_dir (__grc_cgrc_user_dir)
    or return 0

    for config_path in $__grc_asset_config_dir/*
        set -l config_name (path basename $config_path)
        command rm -f "$user_dir/$config_name"
    end
    __grc_refresh_cgrc_configs
end

function __grc_cgrc_conf_for --argument-names executable
    set -l args $argv[2..-1]
    set -l cgrc_configs $__grc_available_cgrc_configs

    switch $executable
        case docker
            switch "$args[1]"
                case ps
                    contains -- dockerps $cgrc_configs
                    and echo dockerps
                    return $status
                case stats
                    contains -- dockerstats $cgrc_configs
                    and echo dockerstats
                    return $status
            end
        case g++
            contains -- gcc $cgrc_configs
            and echo gcc
            return $status
    end

    contains -- $executable $cgrc_configs
    and echo $executable
end

function __grc_should_use_grc --argument-names executable
    contains -- $executable $__grc_grc_fallback_execs
end

function __grc_wrap_command --argument-names executable
    set -l args $argv[2..-1]

    if not isatty 1
        command $executable $args
        return $status
    end

    if command -sq cgrc
        set -l cgrc_conf (__grc_cgrc_conf_for $executable $args)
        if test -n "$cgrc_conf"
            command $executable $args | cgrc "$cgrc_conf"
            return $pipestatus[1]
        end
    end

    if command -sq grc
        and __grc_should_use_grc $executable
        grc $executable $args
        return $status
    end

    command $executable $args
end

function __grc_install --on-event cgrc_install
    __grc_sync_cgrc_configs
end

function __grc_update --on-event cgrc_update
    __grc_sync_cgrc_configs
end

function __grc_uninstall --on-event cgrc_uninstall
    __grc_remove_cgrc_configs
end

__grc_refresh_cgrc_configs
__grc_sync_cgrc_configs_if_needed

set -l __grc_wrapped_execs $__grc_grc_fallback_execs logcat nginx ping prio docker

for executable in (string split ' ' (string join ' ' $__grc_wrapped_execs) | sort -u)
    if type -q $executable
        function $executable --inherit-variable executable --wraps=$executable
            __grc_wrap_command $executable $argv
        end
    end
end

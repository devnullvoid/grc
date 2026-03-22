
set -l grc_plugin_execs configure env gcc ifconfig lsof mount netstat \
    sysctl uptime vmstat whois

if command -s cgrc > /dev/null
    for executable in $grc_plugin_execs
        if type -q $executable
            function $executable --inherit-variable executable --wraps=$executable
                if isatty 1
                    command $executable $argv | cgrc $executable
                else
                    command $executable $argv
                end
            end
        end
    end
end


set -l grc_plugin_execs ping dockerps dockerstats

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

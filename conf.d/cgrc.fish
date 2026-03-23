# Commands with cgrc (rust) embedded configs
# cgrc --list-configurations
# Embedded configurations:
# 	logcat -> parser the android logcat output
# 	nginx -> formats the default nginx log output
# 	dockerps -> formats the output of docker ps.
# 	ping -> formats the output of the ping linux command
# 	prio -> formats the output of logs containing typical words associated to priorities
# 	dockerstats -> formatter for docker stats
set -l cgrc_execs logcat nginx dockerps ping prio dockerstats

# Commands that only grc supports
set -l grc_execs cat cvs df diff dig gcc g++ ls ifconfig \
    make mount mtr netstat ps tail traceroute \
    wdiff blkid du dnf docker docker-compose docker-machine env id ip iostat journalctl kubectl \
    last lsattr lsblk lspci lsmod lsof getfacl getsebool ulimit uptime nmap \
    fdisk findmnt free semanage sar ss sysctl systemctl stat showmount \
    tcpdump tune2fs vmstat w who sockstat whois configure

if command -s cgrc >/dev/null
    for executable in $cgrc_execs
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

if command -s grc >/dev/null
    for executable in $grc_execs
        if type -q $executable
            function $executable --inherit-variable executable --wraps=$executable
                if isatty 1
                    grc $executable $argv
                else
                    command $executable $argv
                end
            end
        end
    end
end

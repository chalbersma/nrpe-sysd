#!/bin/bash

# sysd_check.sh
# Based on the never completed x2go_check

VERSION="0.0.1"
# Save the Original Field Seperator
OIFS=$IFS

# Help Message
help(){
    echo ""
    echo -e "DESCRIPTION:"
    echo ""
    echo -e "\t sysd_check.sh Designed to look at systemd to see if a service or series of services are running and enabled (auotstart). Optionally returns a warning if a given lockfile exists."
    echo ""
    echo -e "SYNOPSIS: "
    echo ""
    echo -e "\t sysd_check.sh  [-r name] [-s service | -s service1,service2.service,service3 ] [ -l /path/to/lockfile | -l /path/to/lockfile1,/path/to/lockfile2 ] [-w x] [-c x] | -v  | -h  | "
    echo ""
    echo -e "SETTINGS: "
    echo ""
    echo -e "\t-r     Name. Name of the Group. Optional. Instead of returning a long list of services you can specify a shorter name to reference that check(s)."
    echo -e "\t-l     Lockfile. Optional Maintenance Lockfile. Will Note the existence of the lockfile and return a warning. Example. System is running a backup on mysql may have a file called mysql_maintenance.lock."
    echo -e "\t-s     Services to Check. Can be specified as name.service or name. Will treat an error on one as an error with all."
    echo -e "\t-w     Warning. Ignored. There for Compatibility with Nagios Check Specification"
    echo -e "\t-c     Critical. Ignored. There for Compatibility with Nagios Check Specification."
    echo -e "\t-v     Display the Version"
    echo -e "\t-h     Display this Help Message"
    echo ""
    echo ""
}

## Getops
while getopts "r:s:l:w:c:vh" OPTIONS; do
    case $OPTIONS in
        r) name=${OPTARG};;
        s) services_raw=${OPTARG};;
        l) lockfiles_raw=${OPTARG};;
        w) warning=${OPTARG};;
        c) critical=${OPTARG};;
        v) echo Version : $VERSION; exit 0;;
        h) help; exit 0;;
    esac
done

if [[ services_raw == "" ]] ; then
    ## Issues need Services to Check
    echo -e "UNKNOWN: No Services Defined. Can't Check Non-existent Services"
    exit 3
else
    OIFS=$IFS
    IFS=$, read -ra services <<< "$services_raw"
    IFS=$OIFS
fi

if [[ name == "" ]] ; then
    ## Set name to services_raw
    name=${services[*]}
fi
# ELSE NAME is NAME from OPTARG

if [[ lockfiles_raw == "" ]] ; then
    ## Is okay no need for Services
    LOCKFILE="false"
else
    # Has Stuff Parse
    OIFS=$IFS
    IFS=$, read -ra lockfiles <<< "$lockfiles_raw"
    IFS=$OIFS
    LOCKFILE="true"
fi

## Lets do Some checks based on that.
## Fist if checks if we have a lockfile at all. If we don't then it continues.
if [[ $LOCKFILE != "false" ]] ; then
    ## Check if the lockfiles existence
    ## Loops through parsed lockfiles and sees if the file exists.
    for lockfile in ${lockfiles[@]}
    do
        if [[ -e $lockfile ]] ; then
            ## This lockfile exists Warn and Exit
            echo -e "WARNING: Lockfile $lockfile exists. Stopping Checks Because of it. Will try again on next run."
            exit 1
        fi
    done
fi

## Lockfiles are good Let's cycle through services and see if everything is good.
for service in ${services[@]}
do
    service_running=$(systemctl is-active $service)
    service_enabled=$(systemctl is-enabled $service)
    if [[ $service_running == "active" ]] ; then
        if [[ $service_enabled == "enabled" ]] ; then
            ## This service is okay Send OKAY email at the end.
            continue;
        else
            echo -e "WARNING: Service $service is Running **BUT NOT ENABLED**."
            exit 1
        fi
    elif [[ $service_running == "inactive" ]] ; then
        echo -e "CRITICAL: Service $service **Not Running**"
        exit 2
    elif [[ $service_running == "unknown" ]] ; then
        echo -e "CRITICAL: $service is unkmown to SystemD. $service may not be installed properly."
        exit 2
    else
        echo -e "CRITICAL: An Unknown error has occured checking $service. Sorry Guys"
    fi
done

## If we've gotten here it's okay on all the services (The continue in the first if statement
echo -e "OK: Service(s): $name enabled and running."
exit 0
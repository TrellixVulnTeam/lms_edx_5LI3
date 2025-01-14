#!/bin/sh

HTTPD_PIDFILE=/opt/lms_edx/edx-ficus.3-3/apache2/logs/httpd.pid



HTTPD="/opt/lms_edx/edx-ficus.3-3/apache2/bin/httpd -f /opt/lms_edx/edx-ficus.3-3/apache2/conf/httpd.conf"
if [ -f "/opt/lms_edx/edx-ficus.3-3/apps/bitnami/banner/disable-banner" ] ; then
   HTTPD="$HTTPD -DDISABLE_BANNER"
fi

                            

STATUSURL="http://localhost/server-status"
HTTPD_STATUS=""
HTTPD_PID=""

ERROR=0
SERVER=both

. /opt/lms_edx/edx-ficus.3-3/apache2/bin/envvars

get_pid() {
    PID=""
    PIDFILE=$1
    # check for pidfile
    if [ -f "$PIDFILE" ] ; then
        PID=`cat $PIDFILE`
    fi
}

get_apache_pid() {
    get_pid $HTTPD_PIDFILE
    if [ ! "$PID" ]; then
        return
    fi
    if [ "$PID" -gt 0 ]; then
        HTTPD_PID=$PID
    fi
}

is_service_running() {
    PID=$1
    if [ "x$PID" != "x" ] && kill -0 $PID 2>/dev/null ; then
        RUNNING=1
    else
        RUNNING=0
    fi
    return $RUNNING
}

is_apache_running() {
    get_apache_pid
    is_service_running $HTTPD_PID
    RUNNING=$?
    if [ $RUNNING -eq 0 ]; then
        HTTPD_STATUS="apache not running"
    else
        HTTPD_STATUS="apache already running"
    fi
    return $RUNNING
}

test_apache_config() {
    if $HTTPD -t; then
        ERROR=0
    else
        ERROR=8
        echo "apache config test fails, aborting"
        exit $ERROR
    fi
}

start_apache() {
    test_apache_config
    is_apache_running
    RUNNING=$?

    if [ $RUNNING -eq 1 ]; then
        echo "$0 $ARG: httpd (pid $HTTPD_PID) already running"
    else
        if $HTTPD ; then
            echo "$0 $ARG: httpd started at port 80"
        else
            echo "$0 $ARG: httpd could not be started"
            ERROR=3
        fi
    fi
}

stop_apache() {
    NO_EXIT_ON_ERROR=$1
    test_apache_config
    is_apache_running
    RUNNING=$?

    if [ $RUNNING -eq 0 ]; then
        echo "$0 $ARG: $HTTPD_STATUS"
        if [ "x$NO_EXIT_ON_ERROR" != "xno_exit" ]; then
            exit
        else
            return
        fi
    fi
    get_apache_pid
    kill $HTTPD_PID
    COUNTER=40
    while [ $RUNNING -eq 1 ] && [ $COUNTER -ne 0 ]; do
        COUNTER=`expr $COUNTER - 1`
        sleep 2
	is_apache_running
        RUNNING=$?
    done
    is_apache_running
    RUNNING=$?
    if [ $RUNNING -eq 0 ]; then
        echo "$0 $ARG: httpd stopped"
    else
        echo "$0 $ARG: httpd could not be stopped"
        ERROR=4
    fi
}

cleanpid() {
    rm -f $HTTPD_PIDFILE
}

if [ "x$1" = "xstart" ]; then
    start_apache
elif [ "x$1" = "xstop" ]; then
    stop_apache
elif [ "x$1" = "xstatus" ]; then
    is_apache_running
    echo "$HTTPD_STATUS"
elif [ "x$1" = "xcleanpid" ]; then
    cleanpid
fi

exit $ERROR

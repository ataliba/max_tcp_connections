#!/bin/bash

# Get the OS type 
OS=$(uname)

case "$OS" in
    'SunOS')
            AWK=/usr/bin/nawk
            ;;
    'Linux')
            AWK=/bin/awk
            ;;
    'AIX')
            AWK=/usr/bin/awk
            ;;
esac

# Get the max number of TCP Connections 
MaxConn=$(eval cat /proc/sys/net/netfilter/nf_conntrack_max)

# get the number of TCP Connections on this moment 
NConnections=$(netstat -an | $AWK -v start=1 -v end=65535 ' $NF ~ /TIME_WAIT|ESTABLISHED/ && $4 !~ /127\.0\.0\.1/ {
    if ($1 ~ /\./)
            {sip=$1}
    else {sip=$4}

    if ( sip ~ /:/ )
            {d=2}
    else {d=5}

    split( sip, a, /:|\./ )

    if ( a[d] >= start && a[d] <= end ) {
            ++connections;
            }
    }
    END {print connections}')


if [ $(echo "(200*100)/65536"| bc) -gt 80 ]; then 
  echo "Your system reached 80% of your tcp connections use";
else
  echo "No problems with your tcp connections "
fi 




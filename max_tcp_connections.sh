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

Status=$(echo "($NConnections*100)/$MaxConn"|bc)

if [ $Status -le 74 ]; then 
   echo "OK - Low number of TCP Connections ( $NConnections connections / $Status % of Total )"
   exit 0
fi

if [ $Status -ge 76 -a $Status -le 89 ]; then 
   echo "WARNING - You number of connections increase ( $NConnections connections /  $Status % of Total )"
   exit 1
fi 

if [ $Status -gt 90 ]; then 
   echo "CRITICAL - High number of tcp Connections ( $NConnections connections / $Status % of Total ) "
   exit 2
fi 

 
if [ $(echo "($NConnections*100)/$MaxConn"| bc) -gt 80 ]; then 
  echo "Your system reached 80% of your tcp connections use";
else
  echo "No problems with your tcp connections "
fi 




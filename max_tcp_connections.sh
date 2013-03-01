#!/bin/bash

# Get the max number of TCP Connections 
MaxConn=$(sysctl -a  | grep net.ipv4.netfilter.ip_conntrack_max | awk -F "=" '{print $2}' | tr -d '[:space:]')

# get the number of TCP Connections on this moment 
NConnections=$(netstat -an | awk  -v start=1 -v end=65535 ' $NF ~ /TIME_WAIT|ESTABLISHED/ && $4 !~ /127\.0\.0\.1/ {
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

if [ $Status -le 60 ]; then 
   echo "OK - Low number of TCP Connections ( $NConnections connections / $Status % of Total )"
   exit 0
fi

if [ $Status -ge 61 -a $Status -le 75 ]; then 
   echo "WARNING - You number of connections increase ( $NConnections connections /  $Status % of Total )"
   exit 1
fi 

if [ $Status -gt 76 ]; then 
   echo "CRITICAL - High number of tcp Connections ( $NConnections connections / $Status % of Total ) "
   exit 2
fi


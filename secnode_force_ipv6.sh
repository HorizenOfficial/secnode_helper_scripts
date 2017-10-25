#!/bin/bash
#Manually add /etc/hosts entries for the zen secure node tracking servers to force IPv6 connections.
#Get list of current servers from API, use defaults if unsuccessful.

DEF_SERVERS=( "ts1.eu.zensystem.io" "ts1.na.zensystem.io" "ts1.sea.zensystem.io" )
API_ENDPNT=( "https://securenodes.zensystem.io/api/srvlist" "https://securenodes.eu.zensystem.io/api/srvlist" "https://securenodes.na.zensystem.io/api/srvlist" "https://securenodes.sea.zensystem.io/api/srvlist" )
BASEDOMAIN=".zensystem.io"
RESULT=""
SERVERS=( )

command -v dig >/dev/null 2>&1 || { echo >&2 "I require \"dig\" from package \"dnsutils\" but it's not installed.  Aborting."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo >&2 "I require \"jq\" from package \"jq\" but it's not installed.  Aborting."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo >&2 "I require \"curl\" from package \"curl\" but it's not installed.  Aborting."; exit 1; }

for URL in "${API_ENDPNT[@]}"
do
    if [ -z "$RESULT" ]
	then
	    RESULT=$(curl -sLf $URL)
    fi
done

LIVE_SERVERS=( $(echo -n $RESULT | jq -r .servers[]) )

if [ ! -z "$LIVE_SERVERS" ]
then
    i=0
    for PREFIX in "${LIVE_SERVERS[@]}"
    do
        LIVE_SERVERS[$i]=$PREFIX$BASEDOMAIN
        #Check for valid FQDN
        if [[ -z `echo ${LIVE_SERVERS[$i]} | grep -P '(?=^.{1,254}$)(^(?>(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)'` ]]
        then
            SERVERS=( "${DEF_SERVERS[@]}" )
            break
        else
            SERVERS[$i]="${LIVE_SERVERS[$i]}"
        fi
        i=$((i+1))
    done
else
    SERVERS=( "${DEF_SERVERS[@]}" )
fi

for SERVER in "${SERVERS[@]}"
do
    IP="$(dig +short -t AAAA "$SERVER" @2001:4860:4860::8888 | tr '\r\n' ' ' | cut -d ' ' -f 1)"
    if [ ! -z "$IP" ] && ! echo "$IP" | grep -q ";"
    then
        sed -i '/'$SERVER'/d' /etc/hosts
        echo $IP $SERVER >> /etc/hosts
    fi
done


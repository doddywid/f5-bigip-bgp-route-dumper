#!/bin/bash

mkdir -p /shared/tmp/.bgproutedump
cp /shared/tmp/.bgproutedump/route.current /shared/tmp/.bgproutedump/route.prev 2> /dev/null
imish -e "show ip bgp" | grep 65444 |  awk  '{print $1}' | cut -c 4- | grep -v "0.0.0.0/0" > /shared/tmp/.bgproutedump/route.current

if [ -f "/shared/tmp/.bgproutedump/route.prev" ]; then
  delta=`cmp /shared/tmp/.bgproutedump/route.prev /shared/tmp/.bgproutedump/route.current`
  if [ "$delta" != "" ] ; then
    load=true
    logger -p local0.info "BGPROUTEDUMPER - found changes, updating datagroup"
  else
    logger -p local0.info "BGPROUTEDUMPER - no changes found, no datagroup upgrade performed"
  fi
else
  load=true
  logger -p local0.info "BGPROUTEDUMPER - initial run, updating datagroup"
fi

if [ $load ]; then
  rm -rf /shared/tmp/.bgproutedump/*.tmp
  sort /shared/tmp/.bgproutedump/route.current | uniq > /shared/tmp/.bgproutedump/sdump.tmp
  while read p; do
    pl=`echo $p | tr "/" " " | awk '{print $2}'`
    if  [ $pl -le 24 ] ; then
      echo "network $p," >> /shared/tmp/.bgproutedump/s2dump.tmp
    fi
  done </shared/tmp/.bgproutedump/sdump.tmp
  tmsh modify /sys file data-group dg_ip_ext_asn source-path file:/shared/tmp/.bgproutedump/s2dump.tmp
  logger -p local0.info "BGPROUTEDUMPER - datagroup upgrade completed"
  rm -rf /shared/tmp/.bgproutedump/*.tmp
fi

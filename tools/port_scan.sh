#!/bin/bash
if [[ -z $1 ]]; then
  echo "port_scan.sh <ip address>"
  exit 1
fi

for i in {1..20}; do
  port_no=$(shuf -i 1-10000 -n 1)
  nc -z -v $1 $port_no -w 3
done
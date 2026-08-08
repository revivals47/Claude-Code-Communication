#!/bin/bash
for i in $(seq 1 150); do
  ts=$(date +%H:%M:%S)
  line=$(timeout 20 gdb-multiarch -batch -x poll.gdb 2>/dev/null | grep '^SAMPLE')
  echo "$ts $line"
  sleep 2
done

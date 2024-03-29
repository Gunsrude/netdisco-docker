#!/bin/ash

mkdir netdisco-mibs
curl -sL https://api.github.com/repos/netdisco/netdisco-mibs/releases/latest | \
  grep browser_download_url | xargs printf "curl -sL %s\n" | tail -1 | \
  sh | tar -C netdisco-mibs --strip-components=1 -zxf -


./bin/netdisco-backend foreground

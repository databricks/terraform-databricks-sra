#!/bin/bash

eval "$(jq -r '@sh "METASTORE_DOMAIN=\(.metastore_domain)"')"

IP=$(dig +short $METASTORE_DOMAIN | tail -n1)
echo "Resolved IP: $IP" >&2

if [ -z "$IP" ]; then
  echo "Error: Failed to resolve IP for $METASTORE_DOMAIN" >&2
  exit 1
fi

jq -n --arg ip "$IP" '{"ip":$ip}'
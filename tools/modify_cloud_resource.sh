#!/bin/bash
appid=""
secret=""
tenant=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -a|--appid)
      appid="$2"
      shift 2
      ;;
    -s|--secret)
      secret="$2"
      shift 2
      ;;
    -t|--tenant)
      tenant="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$appid" || -z "$secret" || -z "$tenant" ]]; then
  echo "Usage: $0 --appid <appid> --secret <secret> --tenant <tenant id>"
  exit 1
fi

az login --service-principal --username $appid --password $secret --tenant $tenant
az group create --name rg-test --location southeastasia
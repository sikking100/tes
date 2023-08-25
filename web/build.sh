#!/bin/bash

if [ -n "$1" ]; then
  if [ "$1" = "production" ]; then
   npm run --prefix apps/landing-page build
   npm run --prefix apps/system-admin build:prod
   npm run --prefix apps/warehouse-admin build:prod
   npm run --prefix apps/branch-admin build:prod
   npm run --prefix apps/finance-admin build:prod
   npm run --prefix apps/sales-admin build:prod
  else
   npm run --prefix apps/landing-page build
   npm run --prefix apps/system-admin build:dev
   npm run --prefix apps/warehouse-admin build:dev
   npm run --prefix apps/branch-admin build:dev
   npm run --prefix apps/finance-admin build:dev
   npm run --prefix apps/sales-admin build:dev
  fi
else
  echo "Usage: $0 <environment>"
  echo "Available environments: development, production"
  exit 1
fi
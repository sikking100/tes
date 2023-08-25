#!/bin/bash

npm run --prefix apps/landing-page build
npm run --prefix apps/system-admin build:prod
npm run --prefix apps/warehouse-admin build:prod
npm run --prefix apps/branch-admin build:prod
npm run --prefix apps/finance-admin build:prod
npm run --prefix apps/sales-admin build:prod

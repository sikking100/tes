#!/bin/bash

npm run --prefix apps/landing-page build
npm run --prefix apps/system-admin build:dev
npm run --prefix apps/warehouse-admin build:dev
npm run --prefix apps/branch-admin build:dev
npm run --prefix apps/finance-admin build:dev
npm run --prefix apps/sales-admin build:dev

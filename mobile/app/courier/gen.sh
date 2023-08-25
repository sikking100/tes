#!/bin/bash

SRC_DIR=./proto
DST_DIR=./lib/data/models
GOOGLE_SRC_DIR=/usr/local/opt/protobuf/include/google/protobuf
GOOGLE_DST_DIR=./lib/data/models/google/protobuf

if [ -d $DST_DIR ]
then
    rm -rf $DST_DIR
    rm -rf $GOOGLE_DST_DIR
fi

mkdir -p $DST_DIR
mkdir -p $GOOGLE_DST_DIR

protoc -I=$SRC_DIR --dart_out=grpc:$DST_DIR $SRC_DIR/*.proto
protoc -I=$GOOGLE_SRC_DIR --dart_out=grpc:$GOOGLE_DST_DIR $GOOGLE_SRC_DIR/timestamp.proto $GOOGLE_SRC_DIR/duration.proto
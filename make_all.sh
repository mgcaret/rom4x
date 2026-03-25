#!/bin/bash

for dir in rom4x rom5x; do
  pushd $dir
  ./make_all.sh
  popd
done
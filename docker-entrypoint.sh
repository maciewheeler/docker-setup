#!/bin/sh
set -eu

# set the ld paths correctly
ldconfig

case ${1:-} in
jupyter)
  $@ --no-browser --ip=0.0.0.0 --allow-root --NotebookApp.token='' --NotebookApp.password=''
  ;;
*)
  exec "$@"
  ;;
esac

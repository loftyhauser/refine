#!/usr/bin/env bash

set -x # echo commands
set -e # exit on first error
set -u # Treat unset variables as error

if [ $# -gt 0 ] ; then
    src=$1/src
else
    src=${HOME}/refine/egads/src
fi

serveCSM -batch poly.csm 

${src}/ref bootstrap poly.egads

rm -rf inflated.b8.ugrid
${src}/ref_inflatable  \
    poly-vol.meshb \
    10 \
    0.1 \
    2.0 \
    1.68 \
    2 3 4 5 6 7 8 9

${src}/ref translate inflated.b8.ugrid surf.meshb

${src}/ref \
      adapt poly-vol.meshb \
      -g poly.egads \
      -x poly-curve.meshb \
      -f poly-curve-prop.tec

rm -rf inflated.b8.ugrid
${src}/ref_inflatable  \
    poly-curve.meshb \
    10 \
    0.1 \
    2.0 \
    1.68 \
    2 3 4 5 6 7 8 9

${src}/ref translate inflated.b8.ugrid curve.meshb

${src}/ref_acceptance -u 5 surf.meshb surf.solb

${src}/ref interp surf.meshb surf.solb curve.meshb curve.solb

exit

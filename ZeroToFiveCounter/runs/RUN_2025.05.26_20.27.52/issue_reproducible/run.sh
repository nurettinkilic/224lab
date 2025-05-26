#!/bin/sh
dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd $dir;
export PACKAGED_SCRIPT_0='openlane/scripts/openroad/resizer.tcl';
export PACKAGED_SCRIPT_1='openlane/designs/ZeroToFiveCounter/src/ZeroToFiveCounter.sdc';
export PACKAGED_SCRIPT_2='./tmp/placement/8-resizer.sdc';
export PNR_SDC_FILE='openlane/designs/ZeroToFiveCounter/src/ZeroToFiveCounter.sdc';
export placement_tmpfiles='./tmp/placement';
TOOL_BIN=${TOOL_BIN:-openroad}
$TOOL_BIN -exit $PACKAGED_SCRIPT_0

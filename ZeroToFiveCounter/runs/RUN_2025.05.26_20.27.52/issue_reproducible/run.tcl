#!/usr/bin/env openroad
set ::env(PACKAGED_SCRIPT_0) "openlane/scripts/openroad/resizer.tcl";
set ::env(PACKAGED_SCRIPT_1) "openlane/designs/ZeroToFiveCounter/src/ZeroToFiveCounter.sdc";
set ::env(PACKAGED_SCRIPT_2) "./tmp/placement/8-resizer.sdc";
set ::env(PNR_SDC_FILE) "openlane/designs/ZeroToFiveCounter/src/ZeroToFiveCounter.sdc";
set ::env(placement_tmpfiles) "./tmp/placement";
source $::env(PACKAGED_SCRIPT_0)

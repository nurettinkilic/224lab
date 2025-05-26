# resizer.tcl - invoked during placement for resizing & buffer insertion

read_def $::env(placement_tmpfiles)/6-detailed.def
read_sdc $::env(PNR_SDC_FILE)

# Timing-driven optimization
repair_design \
  -slew_margin 0.2 \
  -cap_margin 0.2 \
  -setup_margin 0.2

optimize_design \
  -slew_margin 0.2 \
  -cap_margin 0.2 \
  -setup_margin 0.2

write_def $::env(placement_tmpfiles)/8-resizer.def
write_db $::env(placement_tmpfiles)/8-resizer.odb
write_verilog $::env(placement_tmpfiles)/8-resizer.v
write_sdc $::env(placement_tmpfiles)/8-resizer.sdc

# Save powered netlist for later steps
if {[info exists ::env(placement_powered_netlist)]} {
    write_verilog -include_pins -power $::env(placement_powered_netlist)
}

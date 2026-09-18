# OpenROAD routing DRC report
# Re-run to resolve the 0-byte empty report issue
source [file join [file dirname [info script]] paths.tcl]

read_lef $PDK_DIR/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef
read_lef $PDK_DIR/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef
read_def SHA256_15ns.def

# Run DRC check on the routed design
check_drc -output SHA256_15ns_route_drc_signoff.rpt

puts "Route DRC report saved to SHA256_15ns_route_drc_signoff.rpt"
exit

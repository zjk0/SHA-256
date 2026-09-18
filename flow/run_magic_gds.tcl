# Export routed DEF with real standard-cell GDS geometry.
source [file join [file dirname [info script]] paths.tcl]
crashbackups stop
drc off
lef read $TECH_LEF
lef read $CELL_LEF
gds read [file join $LIB_DIR gds sky130_fd_sc_hd.gds]
def read SHA256_15ns.def
load SHA256
select top cell
gds write SHA256_15ns_full.gds
puts "Wrote SHA256_15ns_full.gds"

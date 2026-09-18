source [file join [file dirname [info script]] paths.tcl]
# Magic DRC Signoff Script (16-1)
# Reads DEF directly to avoid GDS layer mapping issues
# Run via ./magic.sh to load the selected PDK technology.

crashbackups stop
drc euclidean on
drc style drc(full)
drc on
snap internal

# Read LEF for std cell definitions
lef read $PDK_DIR/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef
lef read $PDK_DIR/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef

# Read GDS for std cell layouts (for actual DRC)
gds flatglob *__example_*
gds flatten true
gds read $PDK_DIR/libs.ref/sky130_fd_sc_hd/gds/sky130_fd_sc_hd.gds

# Read DEF (Magic maps layers correctly from DEF via LEF)
def read SHA256_15ns.def

# Load the top cell
load SHA256
select top cell
expand

# Run DRC
drc catchup

# Report
set allerrors [drc listall why]
set oscale [cif scale out]
set ofile [open "SHA256_15ns_magic_drc_signoff.rpt" w]
puts $ofile "============================================"
puts $ofile "Magic DRC Signoff Report (DEF-based)"
puts $ofile "============================================"
puts $ofile "Cell: SHA256"
puts $ofile "DEF:  SHA256_15ns.def"
puts $ofile "PDK:  sky130A"
puts $ofile "Magic: see the tool version in the run log"
puts $ofile "============================================"
puts $ofile ""
puts $ofile "DRC errors for cell SHA256"
puts $ofile "--------------------------------------------"
set errcount 0
foreach {whytext rectlist} $allerrors {
    puts $ofile ""
    puts $ofile $whytext
    foreach rect $rectlist {
        set llx [format "%.3f" [expr $oscale * [lindex $rect 0]]]
        set lly [format "%.3f" [expr $oscale * [lindex $rect 1]]]
        set urx [format "%.3f" [expr $oscale * [lindex $rect 2]]]
        set ury [format "%.3f" [expr $oscale * [lindex $rect 3]]]
        puts $ofile "$llx $lly $urx $ury"
        incr errcount
    }
}
puts $ofile ""
puts $ofile "============================================"
puts $ofile "Total DRC violations: $errcount"
puts $ofile "============================================"
close $ofile

puts stdout ""
puts stdout "============================================"
puts stdout "Magic DRC Signoff Report (DEF-based)"
puts stdout "============================================"
puts stdout "Total DRC violations: $errcount"
puts stdout "============================================"
puts stdout "Report saved to SHA256_15ns_magic_drc_signoff.rpt"
if {$errcount > 0} {
    error "Magic DRC failed: $errcount violations"
}

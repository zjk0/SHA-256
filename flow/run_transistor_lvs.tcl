source [file join [file dirname [info script]] paths.tcl]
# Netgen Transistor-Level LVS Script (16-2)
# Run with: netgen -noconsole < run_transistor_lvs.tcl
# Uses 'filename cellname' syntax to ensure correct circuit identification

lvs [list [file join $FLOW_DIR .build lvs layout SHA256] SHA256] \
    [list [file join $FLOW_DIR .build lvs schematic SHA256] SHA256] \
    $NETGEN_SETUP SHA256_15ns_transistor_lvs.report

puts ""
puts "============================================"
puts "Transistor-Level LVS Complete"
puts "============================================"
puts "Report: SHA256_15ns_transistor_lvs.report"
quit

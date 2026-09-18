# Power analysis using this run's library, constraints and extracted parasitics.
# For connectivity use run_power_grid_check.tcl; for IR use run_ir_drop_real.tcl.
source [file join [file dirname [info script]] paths.tcl]
read_lef $TECH_LEF
read_lef $CELL_LEF
read_liberty $LIBERTY
read_def SHA256_15ns.def
read_sdc SHA256_15ns.sdc
read_spef SHA256_15ns.spef
set_propagated_clock [all_clocks]

report_power
report_power > SHA256_15ns_power_ir_signoff.rpt
puts "Power report: SHA256_15ns_power_ir_signoff.rpt"
puts "Activity is estimated by STA; no VCD/SAIF switching activity was loaded."
puts "Run run_ir_drop_real.tcl separately for the power-grid voltage solution."

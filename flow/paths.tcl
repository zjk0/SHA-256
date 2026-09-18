# Shared by OpenROAD, Magic and Netgen; independent of the caller's directory.
set FLOW_DIR [file dirname [file normalize [info script]]]
set PROJECT_ROOT [file dirname $FLOW_DIR]
if {[info exists ::env(PDK_PATH)] && $::env(PDK_PATH) ne ""} {
    set PDK_DIR [file normalize $::env(PDK_PATH)]
} else {
    set pdk_root /usr/local/share/pdk
    if {[info exists ::env(PDK_ROOT)] && $::env(PDK_ROOT) ne ""} {
        set pdk_root $::env(PDK_ROOT)
    }
    set pdk_name sky130A
    if {[info exists ::env(PDK)] && $::env(PDK) ne ""} {
        set pdk_name $::env(PDK)
    }
    set PDK_DIR [file normalize [file join $pdk_root $pdk_name]]
}
set LIB_DIR [file join $PDK_DIR libs.ref sky130_fd_sc_hd]
set NETGEN_SETUP [file join $PDK_DIR libs.tech netgen [file tail $PDK_DIR]_setup.tcl]
set TECH_LEF [file join $LIB_DIR techlef sky130_fd_sc_hd__nom.tlef]
set CELL_LEF [file join $LIB_DIR lef sky130_fd_sc_hd.lef]
set LIBERTY [file join $LIB_DIR lib sky130_fd_sc_hd__tt_025C_1v80.lib]
set PLATFORM_DIR [file join $FLOW_DIR platform sky130hd]
set OPENROAD_THREADS 8
if {[info exists ::env(OPENROAD_THREADS)]} {
    set OPENROAD_THREADS $::env(OPENROAD_THREADS)
}
cd $FLOW_DIR

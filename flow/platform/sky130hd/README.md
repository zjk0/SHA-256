# OpenROAD support files

These four files are copied without modification from
`The-OpenROAD-Project/OpenROAD`, commit
`eb20ea097c3342391028616eeafd098488ba4b29`, directory `test/sky130hd`:

- `sky130hd.tracks`: routing tracks.
- `sky130hd.pdn.tcl`: the reference power grid used by this project.
- `sky130hd.rc`: estimated wire/via RC.
- `sky130hd.rcx_rules`: OpenRCX extraction rules.

Source: https://github.com/The-OpenROAD-Project/OpenROAD/tree/eb20ea097c3342391028616eeafd098488ba4b29/test/sky130hd

See `LICENSE.OpenROAD` for the upstream BSD 3-Clause license. LEF, Liberty,
GDS and SPICE libraries are read from the user's installed open_pdks PDK;
they are not copied here. These reference RC rules are not foundry signoff
qualification for an arbitrary PDK revision. Record the PDK and tool versions
alongside any reproduced results.

"""Paths shared by the Python helpers (same environment contract as env.sh)."""
import os
from pathlib import Path

FLOW_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = FLOW_DIR.parent
PDK_DIR = Path(os.environ.get("PDK_PATH") or (
    Path(os.environ.get("PDK_ROOT", "/usr/local/share/pdk"))
    / os.environ.get("PDK", "sky130A")
)).expanduser().resolve()
LIB_DIR = PDK_DIR / "libs.ref" / "sky130_fd_sc_hd"

// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// tl_dbg package generated by `tlgen.py` tool

package tl_dbg_pkg;

  localparam logic [31:0] ADDR_SPACE_MBX_JTAG__SOC     = 32'h 01460200;
  localparam logic [31:0] ADDR_SPACE_SOCDBG_CTRL__JTAG = 32'h 00000240;

  localparam logic [31:0] ADDR_MASK_MBX_JTAG__SOC     = 32'h 0000001f;
  localparam logic [31:0] ADDR_MASK_SOCDBG_CTRL__JTAG = 32'h 00000003;

  localparam int N_HOST   = 1;
  localparam int N_DEVICE = 2;

  typedef enum int {
    TlMbxJtagSoc = 0,
    TlSocdbgCtrlJtag = 1
  } tl_device_e;

  typedef enum int {
    TlDbg = 0
  } tl_host_e;

endpackage

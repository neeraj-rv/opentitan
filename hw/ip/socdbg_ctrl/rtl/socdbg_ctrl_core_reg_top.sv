// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Top module auto-generated by `reggen`

`include "prim_assert.sv"

module socdbg_ctrl_core_reg_top (
  input clk_i,
  input rst_ni,
  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o,
  // To HW
  output socdbg_ctrl_reg_pkg::socdbg_ctrl_core_reg2hw_t reg2hw, // Write
  input  socdbg_ctrl_reg_pkg::socdbg_ctrl_core_hw2reg_t hw2reg, // Read

  // Integrity check errors
  output logic intg_err_o,

  // Config
  input devmode_i // If 1, explicit error return for unmapped register access
);

  import socdbg_ctrl_reg_pkg::* ;

  localparam int AW = 5;
  localparam int DW = 32;
  localparam int DBW = DW/8;                    // Byte Width

  // register signals
  logic           reg_we;
  logic           reg_re;
  logic [AW-1:0]  reg_addr;
  logic [DW-1:0]  reg_wdata;
  logic [DBW-1:0] reg_be;
  logic [DW-1:0]  reg_rdata;
  logic           reg_error;

  logic          addrmiss, wr_err;

  logic [DW-1:0] reg_rdata_next;
  logic reg_busy;

  tlul_pkg::tl_h2d_t tl_reg_h2d;
  tlul_pkg::tl_d2h_t tl_reg_d2h;


  // incoming payload check
  logic intg_err;
  tlul_cmd_intg_chk u_chk (
    .tl_i(tl_i),
    .err_o(intg_err)
  );

  // also check for spurious write enables
  logic reg_we_err;
  logic [6:0] reg_we_check;
  prim_reg_we_check #(
    .OneHotWidth(7)
  ) u_prim_reg_we_check (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .oh_i  (reg_we_check),
    .en_i  (reg_we && !addrmiss),
    .err_o (reg_we_err)
  );

  logic err_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      err_q <= '0;
    end else if (intg_err || reg_we_err) begin
      err_q <= 1'b1;
    end
  end

  // integrity error output is permanent and should be used for alert generation
  // register errors are transactional
  assign intg_err_o = err_q | intg_err | reg_we_err;

  // outgoing integrity generation
  tlul_pkg::tl_d2h_t tl_o_pre;
  tlul_rsp_intg_gen #(
    .EnableRspIntgGen(1),
    .EnableDataIntgGen(1)
  ) u_rsp_intg_gen (
    .tl_i(tl_o_pre),
    .tl_o(tl_o)
  );

  assign tl_reg_h2d = tl_i;
  assign tl_o_pre   = tl_reg_d2h;

  tlul_adapter_reg #(
    .RegAw(AW),
    .RegDw(DW),
    .EnableDataIntgGen(0)
  ) u_reg_if (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),

    .tl_i (tl_reg_h2d),
    .tl_o (tl_reg_d2h),

    .en_ifetch_i(prim_mubi_pkg::MuBi4False),
    .intg_error_o(),

    .we_o    (reg_we),
    .re_o    (reg_re),
    .addr_o  (reg_addr),
    .wdata_o (reg_wdata),
    .be_o    (reg_be),
    .busy_i  (reg_busy),
    .rdata_i (reg_rdata),
    .error_i (reg_error)
  );

  // cdc oversampling signals

  assign reg_rdata = reg_rdata_next ;
  assign reg_error = (devmode_i & addrmiss) | wr_err | intg_err;

  // Define SW related signals
  // Format: <reg>_<field>_{wd|we|qs}
  //        or <reg>_{wd|we|qs} if field == 1 or 0
  logic intr_state_we;
  logic intr_state_qs;
  logic intr_state_wd;
  logic intr_enable_we;
  logic intr_enable_qs;
  logic intr_enable_wd;
  logic intr_test_we;
  logic intr_test_wd;
  logic alert_test_we;
  logic alert_test_wd;
  logic debug_policy_ctrl_we;
  logic [3:0] debug_policy_ctrl_qs;
  logic [3:0] debug_policy_ctrl_wd;
  logic debug_policy_valid_we;
  logic debug_policy_valid_qs;
  logic debug_policy_valid_wd;
  logic status_mbx_we;
  logic status_mbx_auth_debug_intent_set_qs;
  logic status_mbx_auth_debug_intent_set_wd;
  logic status_mbx_auth_window_open_qs;
  logic status_mbx_auth_window_open_wd;
  logic status_mbx_auth_window_closed_qs;
  logic status_mbx_auth_window_closed_wd;
  logic status_mbx_auth_unlock_success_qs;
  logic status_mbx_auth_unlock_success_wd;
  logic status_mbx_auth_unlock_failed_qs;
  logic status_mbx_auth_unlock_failed_wd;
  logic [3:0] status_mbx_current_policy_qs;
  logic [3:0] status_mbx_current_policy_wd;
  logic [3:0] status_mbx_requested_policy_qs;
  logic [3:0] status_mbx_requested_policy_wd;

  // Register instances
  // R[intr_state]: V(False)
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_intr_state (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (intr_state_we),
    .wd     (intr_state_wd),

    // from internal hardware
    .de     (hw2reg.intr_state.de),
    .d      (hw2reg.intr_state.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.intr_state.q),
    .ds     (),

    // to register interface (read)
    .qs     (intr_state_qs)
  );


  // R[intr_enable]: V(False)
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_intr_enable (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (intr_enable_we),
    .wd     (intr_enable_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.intr_enable.q),
    .ds     (),

    // to register interface (read)
    .qs     (intr_enable_qs)
  );


  // R[intr_test]: V(True)
  logic intr_test_qe;
  logic [0:0] intr_test_flds_we;
  assign intr_test_qe = &intr_test_flds_we;
  prim_subreg_ext #(
    .DW    (1)
  ) u_intr_test (
    .re     (1'b0),
    .we     (intr_test_we),
    .wd     (intr_test_wd),
    .d      ('0),
    .qre    (),
    .qe     (intr_test_flds_we[0]),
    .q      (reg2hw.intr_test.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.intr_test.qe = intr_test_qe;


  // R[alert_test]: V(True)
  logic alert_test_qe;
  logic [0:0] alert_test_flds_we;
  assign alert_test_qe = &alert_test_flds_we;
  prim_subreg_ext #(
    .DW    (1)
  ) u_alert_test (
    .re     (1'b0),
    .we     (alert_test_we),
    .wd     (alert_test_wd),
    .d      ('0),
    .qre    (),
    .qe     (alert_test_flds_we[0]),
    .q      (reg2hw.alert_test.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.alert_test.qe = alert_test_qe;


  // R[debug_policy_ctrl]: V(False)
  prim_subreg #(
    .DW      (4),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (4'h0),
    .Mubi    (1'b0)
  ) u_debug_policy_ctrl (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (debug_policy_ctrl_we),
    .wd     (debug_policy_ctrl_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.debug_policy_ctrl.q),
    .ds     (),

    // to register interface (read)
    .qs     (debug_policy_ctrl_qs)
  );


  // R[debug_policy_valid]: V(False)
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_debug_policy_valid (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (debug_policy_valid_we),
    .wd     (debug_policy_valid_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.debug_policy_valid.q),
    .ds     (),

    // to register interface (read)
    .qs     (debug_policy_valid_qs)
  );


  // R[status_mbx]: V(False)
  //   F[auth_debug_intent_set]: 0:0
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_mbx_auth_debug_intent_set (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (status_mbx_we),
    .wd     (status_mbx_auth_debug_intent_set_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.status_mbx.auth_debug_intent_set.q),
    .ds     (),

    // to register interface (read)
    .qs     (status_mbx_auth_debug_intent_set_qs)
  );

  //   F[auth_window_open]: 4:4
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_mbx_auth_window_open (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (status_mbx_we),
    .wd     (status_mbx_auth_window_open_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.status_mbx.auth_window_open.q),
    .ds     (),

    // to register interface (read)
    .qs     (status_mbx_auth_window_open_qs)
  );

  //   F[auth_window_closed]: 5:5
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_mbx_auth_window_closed (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (status_mbx_we),
    .wd     (status_mbx_auth_window_closed_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.status_mbx.auth_window_closed.q),
    .ds     (),

    // to register interface (read)
    .qs     (status_mbx_auth_window_closed_qs)
  );

  //   F[auth_unlock_success]: 6:6
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_mbx_auth_unlock_success (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (status_mbx_we),
    .wd     (status_mbx_auth_unlock_success_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.status_mbx.auth_unlock_success.q),
    .ds     (),

    // to register interface (read)
    .qs     (status_mbx_auth_unlock_success_qs)
  );

  //   F[auth_unlock_failed]: 7:7
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_mbx_auth_unlock_failed (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (status_mbx_we),
    .wd     (status_mbx_auth_unlock_failed_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.status_mbx.auth_unlock_failed.q),
    .ds     (),

    // to register interface (read)
    .qs     (status_mbx_auth_unlock_failed_qs)
  );

  //   F[current_policy]: 11:8
  prim_subreg #(
    .DW      (4),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (4'h0),
    .Mubi    (1'b0)
  ) u_status_mbx_current_policy (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (status_mbx_we),
    .wd     (status_mbx_current_policy_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.status_mbx.current_policy.q),
    .ds     (),

    // to register interface (read)
    .qs     (status_mbx_current_policy_qs)
  );

  //   F[requested_policy]: 15:12
  prim_subreg #(
    .DW      (4),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (4'h0),
    .Mubi    (1'b0)
  ) u_status_mbx_requested_policy (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (status_mbx_we),
    .wd     (status_mbx_requested_policy_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.status_mbx.requested_policy.q),
    .ds     (),

    // to register interface (read)
    .qs     (status_mbx_requested_policy_qs)
  );



  logic [6:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[0] = (reg_addr == SOCDBG_CTRL_INTR_STATE_OFFSET);
    addr_hit[1] = (reg_addr == SOCDBG_CTRL_INTR_ENABLE_OFFSET);
    addr_hit[2] = (reg_addr == SOCDBG_CTRL_INTR_TEST_OFFSET);
    addr_hit[3] = (reg_addr == SOCDBG_CTRL_ALERT_TEST_OFFSET);
    addr_hit[4] = (reg_addr == SOCDBG_CTRL_DEBUG_POLICY_CTRL_OFFSET);
    addr_hit[5] = (reg_addr == SOCDBG_CTRL_DEBUG_POLICY_VALID_OFFSET);
    addr_hit[6] = (reg_addr == SOCDBG_CTRL_STATUS_MBX_OFFSET);
  end

  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0 ;

  // Check sub-word write is permitted
  always_comb begin
    wr_err = (reg_we &
              ((addr_hit[0] & (|(SOCDBG_CTRL_CORE_PERMIT[0] & ~reg_be))) |
               (addr_hit[1] & (|(SOCDBG_CTRL_CORE_PERMIT[1] & ~reg_be))) |
               (addr_hit[2] & (|(SOCDBG_CTRL_CORE_PERMIT[2] & ~reg_be))) |
               (addr_hit[3] & (|(SOCDBG_CTRL_CORE_PERMIT[3] & ~reg_be))) |
               (addr_hit[4] & (|(SOCDBG_CTRL_CORE_PERMIT[4] & ~reg_be))) |
               (addr_hit[5] & (|(SOCDBG_CTRL_CORE_PERMIT[5] & ~reg_be))) |
               (addr_hit[6] & (|(SOCDBG_CTRL_CORE_PERMIT[6] & ~reg_be)))));
  end

  // Generate write-enables
  assign intr_state_we = addr_hit[0] & reg_we & !reg_error;

  assign intr_state_wd = reg_wdata[0];
  assign intr_enable_we = addr_hit[1] & reg_we & !reg_error;

  assign intr_enable_wd = reg_wdata[0];
  assign intr_test_we = addr_hit[2] & reg_we & !reg_error;

  assign intr_test_wd = reg_wdata[0];
  assign alert_test_we = addr_hit[3] & reg_we & !reg_error;

  assign alert_test_wd = reg_wdata[0];
  assign debug_policy_ctrl_we = addr_hit[4] & reg_we & !reg_error;

  assign debug_policy_ctrl_wd = reg_wdata[3:0];
  assign debug_policy_valid_we = addr_hit[5] & reg_we & !reg_error;

  assign debug_policy_valid_wd = reg_wdata[0];
  assign status_mbx_we = addr_hit[6] & reg_we & !reg_error;

  assign status_mbx_auth_debug_intent_set_wd = reg_wdata[0];

  assign status_mbx_auth_window_open_wd = reg_wdata[4];

  assign status_mbx_auth_window_closed_wd = reg_wdata[5];

  assign status_mbx_auth_unlock_success_wd = reg_wdata[6];

  assign status_mbx_auth_unlock_failed_wd = reg_wdata[7];

  assign status_mbx_current_policy_wd = reg_wdata[11:8];

  assign status_mbx_requested_policy_wd = reg_wdata[15:12];

  // Assign write-enables to checker logic vector.
  always_comb begin
    reg_we_check = '0;
    reg_we_check[0] = intr_state_we;
    reg_we_check[1] = intr_enable_we;
    reg_we_check[2] = intr_test_we;
    reg_we_check[3] = alert_test_we;
    reg_we_check[4] = debug_policy_ctrl_we;
    reg_we_check[5] = debug_policy_valid_we;
    reg_we_check[6] = status_mbx_we;
  end

  // Read data return
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      addr_hit[0]: begin
        reg_rdata_next[0] = intr_state_qs;
      end

      addr_hit[1]: begin
        reg_rdata_next[0] = intr_enable_qs;
      end

      addr_hit[2]: begin
        reg_rdata_next[0] = '0;
      end

      addr_hit[3]: begin
        reg_rdata_next[0] = '0;
      end

      addr_hit[4]: begin
        reg_rdata_next[3:0] = debug_policy_ctrl_qs;
      end

      addr_hit[5]: begin
        reg_rdata_next[0] = debug_policy_valid_qs;
      end

      addr_hit[6]: begin
        reg_rdata_next[0] = status_mbx_auth_debug_intent_set_qs;
        reg_rdata_next[4] = status_mbx_auth_window_open_qs;
        reg_rdata_next[5] = status_mbx_auth_window_closed_qs;
        reg_rdata_next[6] = status_mbx_auth_unlock_success_qs;
        reg_rdata_next[7] = status_mbx_auth_unlock_failed_qs;
        reg_rdata_next[11:8] = status_mbx_current_policy_qs;
        reg_rdata_next[15:12] = status_mbx_requested_policy_qs;
      end

      default: begin
        reg_rdata_next = '1;
      end
    endcase
  end

  // shadow busy
  logic shadow_busy;
  assign shadow_busy = 1'b0;

  // register busy
  assign reg_busy = shadow_busy;

  // Unused signal tieoff

  // wdata / byte enable are not always fully used
  // add a blanket unused statement to handle lint waivers
  logic unused_wdata;
  logic unused_be;
  assign unused_wdata = ^reg_wdata;
  assign unused_be = ^reg_be;

  // Assertions for Register Interface
  `ASSERT_PULSE(wePulse, reg_we, clk_i, !rst_ni)
  `ASSERT_PULSE(rePulse, reg_re, clk_i, !rst_ni)

  `ASSERT(reAfterRv, $rose(reg_re || reg_we) |=> tl_o_pre.d_valid, clk_i, !rst_ni)

  `ASSERT(en2addrHit, (reg_we || reg_re) |-> $onehot0(addr_hit), clk_i, !rst_ni)

  // this is formulated as an assumption such that the FPV testbenches do disprove this
  // property by mistake
  //`ASSUME(reqParity, tl_reg_h2d.a_valid |-> tl_reg_h2d.a_user.chk_en == tlul_pkg::CheckDis)

endmodule

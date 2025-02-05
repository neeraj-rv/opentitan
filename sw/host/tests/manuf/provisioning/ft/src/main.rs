// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

use std::path::PathBuf;
use std::time::Duration;

use anyhow::Result;
use clap::{Args, Parser};

use ft_lib::{run_ft_personalize, run_sram_ft_individualize, test_exit, test_unlock};
use opentitanlib::backend;
use opentitanlib::dif::lc_ctrl::DifLcCtrlState;
use opentitanlib::test_utils::init::InitializeTest;
use opentitanlib::test_utils::load_sram_program::SramProgramParams;
use util_lib::hex_string_to_u32_arrayvec;

/// Provisioning data command-line parameters.
#[derive(Debug, Args, Clone)]
pub struct ManufFtProvisioningDataInput {
    /// TestUnlock token.
    #[arg(long, default_value = "0x11111111_11111111_11111111_11111111")]
    pub test_unlock_token: String,

    /// TestExit token.
    #[arg(long, default_value = "0x11111111_11111111_11111111_11111111")]
    pub test_exit_token: String,

    /// LC state to transition to from TEST_UNLOCKED*.
    #[arg(long, value_parser = DifLcCtrlState::parse_lc_state_str, default_value = "prod")]
    target_mission_mode_lc_state: DifLcCtrlState,

    /// Host (HSM) generated ECC (P256) private key DER file.
    #[arg(long)]
    host_ecc_sk: PathBuf,
}

#[derive(Debug, Parser)]
struct Opts {
    #[command(flatten)]
    init: InitializeTest,

    #[command(flatten)]
    sram_program: SramProgramParams,

    #[command(flatten)]
    provisioning_data: ManufFtProvisioningDataInput,

    /// Second personalization binary to bootstrap.
    #[arg(long)]
    secondary_bootstrap: PathBuf,

    /// Console receive timeout.
    #[arg(long, value_parser = humantime::parse_duration, default_value = "600s")]
    timeout: Duration,
}

fn main() -> Result<()> {
    let opts = Opts::parse();
    opts.init.init_logging();

    // We call the below functions, instead of calling `opts.init.init_target()` since we do not
    // want to perform bootstrap yet.
    let transport = backend::create(&opts.init.backend_opts)?;
    transport.apply_default_configuration()?;
    InitializeTest::print_result("load_bitstream", opts.init.load_bitstream.init(&transport))?;

    let test_unlock_token =
        hex_string_to_u32_arrayvec::<4>(opts.provisioning_data.test_unlock_token.as_str())?;
    let test_exit_token =
        hex_string_to_u32_arrayvec::<4>(opts.provisioning_data.test_exit_token.as_str())?;

    test_unlock(
        &transport,
        &opts.init.jtag_params,
        opts.init.bootstrap.options.reset_delay,
        &test_unlock_token,
    )?;
    run_sram_ft_individualize(
        &transport,
        &opts.init.jtag_params,
        opts.init.bootstrap.options.reset_delay,
        &opts.sram_program,
        opts.timeout,
    )?;
    test_exit(
        &transport,
        &opts.init.jtag_params,
        opts.init.bootstrap.options.reset_delay,
        &test_exit_token,
        opts.provisioning_data.target_mission_mode_lc_state,
    )?;
    run_ft_personalize(
        &transport,
        &opts.init,
        opts.secondary_bootstrap,
        opts.provisioning_data.host_ecc_sk,
        opts.timeout,
    )?;

    Ok(())
}

use std::path::PathBuf;

use embuild::{
    self, bingen,
    build::{CfgArgs, LinkArgs},
    cargo, symgen,
};

fn main() -> anyhow::Result<()> {
    // Necessary because of this issue: https://github.com/rust-lang/cargo/issues/9641
    LinkArgs::output_propagated("ESP_IDF")?;

    let cfg = CfgArgs::try_from_env("ESP_IDF")?;

    if cfg.get("esp32s2").is_some() {
        // Future; might be possible once https://github.com/rust-lang/cargo/issues/9096 hits Cargo nightly:

        let ulp_elf = PathBuf::from("ulp").join("rust-esp32-ulp-blink");
        symgen::run(&ulp_elf, 0x5000_0000)?; // This is where the RTC Slow Mem is mapped within the ESP32-S2 memory space
        bingen::run(&ulp_elf)?;

        cargo::track_file(ulp_elf);
    }

    cfg.output();

    Ok(())
}

use std::{env, thread, time::*};

use anyhow::*;

use esp_idf_hal::prelude::*;

use esp_idf_sys;

fn main() -> Result<()> {
    esp_idf_sys::link_patches();

    // Bind the log crate to the ESP Logging facilities
    esp_idf_svc::log::EspLogger::initialize_default();

    env::set_var("RUST_BACKTRACE", "1");

    let peripherals = Peripherals::take().unwrap();
    let pins = peripherals.pins;

    let mut blinker_pin = pins.gpio4.into_output()?;
    blinker_pin.set_high()?;

    for s in 0..100 {
        print!("Blinking... {}: ", s);

        blinker_pin.set_high()?;
        println!("on, ");

        thread::sleep(Duration::from_millis(500));

        blinker_pin.set_low()?;
        println!("          off");

        thread::sleep(Duration::from_millis(500));
    }

    Ok(())
}

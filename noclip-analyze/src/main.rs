// Copyright 2026 NoClip Auto contributors
// SPDX-License-Identifier: Apache-2.0

mod analyze;
mod batch;

use analyze::analyze_image;
use clap::Parser;
use std::path::PathBuf;

#[derive(Parser)]
#[command(name = "noclip-analyze", about = "Count clipped shadow/highlight pixels in a JPEG/PNG")]
struct Args {
    #[arg(long, required_unless_present = "batch")]
    input: Option<PathBuf>,

    #[arg(long, default_value_t = 2)]
    shadow_threshold: u8,

    #[arg(long, default_value_t = 253)]
    highlight_threshold: u8,

    #[arg(long, num_args = 1..)]
    batch: Option<Vec<PathBuf>>,

    #[arg(long, default_value = "auto")]
    threads: String,
}

fn main() {
    if let Err(e) = run() {
        eprintln!("noclip-analyze error: {e}");
        std::process::exit(1);
    }
}

fn run() -> Result<(), String> {
    let args = Args::parse();

    if let Some(batch_inputs) = args.batch {
        let paths = batch::expand_inputs(&batch_inputs);
        let threads = parse_threads(&args.threads);
        let results = batch::analyze_batch(&paths, args.shadow_threshold, args.highlight_threshold, threads);
        let json = serde_json::to_string(&results).map_err(|e| e.to_string())?;
        println!("{json}");
        return Ok(());
    }

    let input = args.input.ok_or("missing --input")?;
    let img = image::open(&input).map_err(|e| format!("open {}: {e}", input.display()))?;
    let result = analyze_image(&img, args.shadow_threshold, args.highlight_threshold);
    let json = serde_json::to_string(&result).map_err(|e| e.to_string())?;
    println!("{json}");
    Ok(())
}

fn parse_threads(spec: &str) -> usize {
    if spec == "auto" {
        std::thread::available_parallelism()
            .map(|n| n.get())
            .unwrap_or(4)
    } else {
        spec.parse().unwrap_or(4)
    }
}

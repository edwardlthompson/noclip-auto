// Copyright 2026 NoClip Auto contributors
// SPDX-License-Identifier: Apache-2.0

use crate::analyze::{analyze_image, ClipResult};
use rayon::prelude::*;
use std::path::{Path, PathBuf};

pub fn analyze_batch(paths: &[PathBuf], shadow: u8, highlight: u8, threads: usize) -> Vec<(PathBuf, ClipResult)> {
    let pool = rayon::ThreadPoolBuilder::new()
        .num_threads(threads.max(1))
        .build()
        .expect("thread pool");
    pool.install(|| {
        paths
            .par_iter()
            .filter_map(|path| {
                let img = image::open(path).ok()?;
                Some((path.clone(), analyze_image(&img, shadow, highlight)))
            })
            .collect()
    })
}

pub fn expand_inputs(inputs: &[PathBuf]) -> Vec<PathBuf> {
    let mut out = Vec::new();
    for input in inputs {
        if input.is_dir() {
            if let Ok(entries) = std::fs::read_dir(input) {
                for entry in entries.flatten() {
                    let p = entry.path();
                    if is_image(&p) {
                        out.push(p);
                    }
                }
            }
        } else if is_image(input) {
            out.push(input.clone());
        }
    }
    out.sort();
    out
}

fn is_image(path: &Path) -> bool {
    path.extension()
        .and_then(|e| e.to_str())
        .map(|e| matches!(e.to_lowercase().as_str(), "jpg" | "jpeg" | "png"))
        .unwrap_or(false)
}

// Copyright 2026 NoClip Auto contributors
// SPDX-License-Identifier: Apache-2.0

use image::{DynamicImage, GenericImageView};
use serde::Serialize;

const SCHEMA_VERSION: u32 = 2;

#[derive(Debug, Clone, Serialize, PartialEq)]
pub struct ClipResult {
    pub schema_version: u32,
    pub shadow_clip_px: u64,
    pub highlight_clip_px: u64,
    pub shadow_clip_pct: f64,
    pub highlight_clip_pct: f64,
    pub total_px: u64,
    pub mean_luma: f64,
    pub median_luma: f64,
    pub p05_luma: f64,
    pub p50_luma: f64,
    pub p95_luma: f64,
    pub log_avg_luma: f64,
    pub shadow_clip_r_px: u64,
    pub shadow_clip_g_px: u64,
    pub shadow_clip_b_px: u64,
    pub highlight_clip_r_px: u64,
    pub highlight_clip_g_px: u64,
    pub highlight_clip_b_px: u64,
}

pub fn analyze_image(img: &DynamicImage, shadow_threshold: u8, highlight_threshold: u8) -> ClipResult {
    let (width, height) = img.dimensions();
    let total = u64::from(width) * u64::from(height);
    let rgb = img.to_rgb8();
    let mut shadow = 0u64;
    let mut highlight = 0u64;
    let mut shadow_r = 0u64;
    let mut shadow_g = 0u64;
    let mut shadow_b = 0u64;
    let mut highlight_r = 0u64;
    let mut highlight_g = 0u64;
    let mut highlight_b = 0u64;
    let mut hist = [0u64; 256];
    let mut luma_sum = 0f64;
    let mut log_sum = 0f64;
    let mut log_count = 0u64;

    for pixel in rgb.pixels() {
        let r = pixel[0];
        let g = pixel[1];
        let b = pixel[2];
        let luma = luminance(r, g, b);
        hist[usize::from(luma)] += 1;
        let norm = f64::from(luma) / 255.0;
        luma_sum += norm;
        if luma > 0 {
            log_sum += (norm + 1e-6).ln();
            log_count += 1;
        }

        if luma <= shadow_threshold {
            shadow += 1;
            if r <= shadow_threshold {
                shadow_r += 1;
            }
            if g <= shadow_threshold {
                shadow_g += 1;
            }
            if b <= shadow_threshold {
                shadow_b += 1;
            }
        } else if luma >= highlight_threshold {
            highlight += 1;
            if r >= highlight_threshold {
                highlight_r += 1;
            }
            if g >= highlight_threshold {
                highlight_g += 1;
            }
            if b >= highlight_threshold {
                highlight_b += 1;
            }
        }
    }

    let pct = |n: u64| if total == 0 { 0.0 } else { (n as f64 / total as f64) * 100.0 };
    let mean_luma = if total == 0 { 0.0 } else { luma_sum / total as f64 };
    let log_avg_luma = if log_count == 0 {
        0.0
    } else {
        (log_sum / log_count as f64).exp()
    };
    let p05 = percentile_from_hist(&hist, total, 0.05);
    let p50 = percentile_from_hist(&hist, total, 0.50);
    let p95 = percentile_from_hist(&hist, total, 0.95);

    ClipResult {
        schema_version: SCHEMA_VERSION,
        shadow_clip_px: shadow,
        highlight_clip_px: highlight,
        shadow_clip_pct: pct(shadow),
        highlight_clip_pct: pct(highlight),
        total_px: total,
        mean_luma,
        median_luma: p50,
        p05_luma: p05,
        p50_luma: p50,
        p95_luma: p95,
        log_avg_luma,
        shadow_clip_r_px: shadow_r,
        shadow_clip_g_px: shadow_g,
        shadow_clip_b_px: shadow_b,
        highlight_clip_r_px: highlight_r,
        highlight_clip_g_px: highlight_g,
        highlight_clip_b_px: highlight_b,
    }
}

fn percentile_from_hist(hist: &[u64; 256], total: u64, pct: f64) -> f64 {
    if total == 0 {
        return 0.0;
    }
    let target = ((total as f64) * pct).ceil() as u64;
    let mut cumulative = 0u64;
    for (value, count) in hist.iter().enumerate() {
        cumulative += count;
        if cumulative >= target {
            return value as f64 / 255.0;
        }
    }
    1.0
}

#[inline]
fn luminance(r: u8, g: u8, b: u8) -> u8 {
    let luma = (u32::from(r) * 299 + u32::from(g) * 587 + u32::from(b) * 114 + 500) / 1000;
    luma as u8
}

#[cfg(test)]
mod tests {
    use super::*;
    use image::{ImageBuffer, Rgb};

    #[test]
    fn counts_black_as_shadow_clip() {
        let img = ImageBuffer::from_fn(10, 10, |_, _| Rgb([0, 0, 0]));
        let r = analyze_image(&DynamicImage::ImageRgb8(img), 2, 253);
        assert_eq!(r.schema_version, 2);
        assert_eq!(r.shadow_clip_px, 100);
        assert_eq!(r.highlight_clip_px, 0);
        assert_eq!(r.median_luma, 0.0);
    }

    #[test]
    fn counts_white_as_highlight_clip() {
        let img = ImageBuffer::from_fn(10, 10, |_, _| Rgb([255, 255, 255]));
        let r = analyze_image(&DynamicImage::ImageRgb8(img), 2, 253);
        assert_eq!(r.shadow_clip_px, 0);
        assert_eq!(r.highlight_clip_px, 100);
        assert!((r.median_luma - 1.0).abs() < 0.01);
    }

    #[test]
    fn gray_median_near_midpoint() {
        let img = ImageBuffer::from_fn(10, 10, |_, _| Rgb([128, 128, 128]));
        let r = analyze_image(&DynamicImage::ImageRgb8(img), 2, 253);
        assert!((r.median_luma - 0.502).abs() < 0.02);
        assert_eq!(r.shadow_clip_px, 0);
        assert_eq!(r.highlight_clip_px, 0);
    }
}

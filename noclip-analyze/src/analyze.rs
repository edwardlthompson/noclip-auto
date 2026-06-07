// Copyright 2026 NoClip Auto contributors
// SPDX-License-Identifier: Apache-2.0

use image::{DynamicImage, GenericImageView};
use serde::Serialize;

#[derive(Debug, Clone, Serialize, PartialEq)]
pub struct ClipResult {
    pub shadow_clip_px: u64,
    pub highlight_clip_px: u64,
    pub shadow_clip_pct: f64,
    pub highlight_clip_pct: f64,
    pub total_px: u64,
}

pub fn analyze_image(img: &DynamicImage, shadow_threshold: u8, highlight_threshold: u8) -> ClipResult {
    let (width, height) = img.dimensions();
    let total = u64::from(width) * u64::from(height);
    let rgb = img.to_rgb8();
    let mut shadow = 0u64;
    let mut highlight = 0u64;

    for pixel in rgb.pixels() {
        let luma = luminance(pixel[0], pixel[1], pixel[2]);
        if luma <= shadow_threshold {
            shadow += 1;
        } else if luma >= highlight_threshold {
            highlight += 1;
        }
    }

    let pct = |n: u64| if total == 0 { 0.0 } else { (n as f64 / total as f64) * 100.0 };

    ClipResult {
        shadow_clip_px: shadow,
        highlight_clip_px: highlight,
        shadow_clip_pct: pct(shadow),
        highlight_clip_pct: pct(highlight),
        total_px: total,
    }
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
        assert_eq!(r.shadow_clip_px, 100);
        assert_eq!(r.highlight_clip_px, 0);
    }

    #[test]
    fn counts_white_as_highlight_clip() {
        let img = ImageBuffer::from_fn(10, 10, |_, _| Rgb([255, 255, 255]));
        let r = analyze_image(&DynamicImage::ImageRgb8(img), 2, 253);
        assert_eq!(r.shadow_clip_px, 0);
        assert_eq!(r.highlight_clip_px, 100);
    }
}

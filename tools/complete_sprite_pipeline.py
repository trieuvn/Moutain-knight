"""
Complete Sprite Pipeline
Automates the entire workflow: transparency removal → grid resizing → ready for Godot

Usage:
    python complete_sprite_pipeline.py sprite.png 6 4 128
    
This will:
1. Remove background (fake transparency → true transparency)
2. Resize to perfect grid (e.g., 768x512 for 6x4 grid with 128px frames)
3. Output final sprite ready for Godot import
"""

from PIL import Image
import numpy as np
import sys
import os
from collections import Counter


def detect_background(img_array):
	"""Detect background color from edges"""
	height, width = img_array.shape[:2]
	
	edge_pixels = []
	sample_size = min(100, width, height)
	
	edge_pixels.extend(img_array[0, :sample_size, :3].reshape(-1, 3).tolist())
	edge_pixels.extend(img_array[-1, :sample_size, :3].reshape(-1, 3).tolist())
	edge_pixels.extend(img_array[:sample_size, 0, :3].reshape(-1, 3).tolist())
	edge_pixels.extend(img_array[:sample_size, -1, :3].reshape(-1, 3).tolist())
	
	color_counts = Counter(tuple(p) for p in edge_pixels)
	bg_colors = []
	total = len(edge_pixels)
	
	for color, count in color_counts.most_common(5):
		percentage = (count / total) * 100
		if percentage > 1.0:
			bg_colors.append((np.array(color), percentage))
	
	return bg_colors


def remove_background(img_array, tolerance=45):
	"""Remove background with multi-color detection"""
	height, width = img_array.shape[:2]
	
	bg_colors = detect_background(img_array)
	
	print("Detected background colors:")
	for color, pct in bg_colors:
		print(f"  RGB{tuple(color)}: {pct:.1f}%")
	
	alpha = np.ones((height, width), dtype=np.uint8) * 255
	
	for bg_color, _ in bg_colors:
		r, g, b = img_array[:,:,0], img_array[:,:,1], img_array[:,:,2]
		
		diff = np.sqrt(
			(r.astype(float) - bg_color[0]) ** 2 +
			(g.astype(float) - bg_color[1]) ** 2 +
			(b.astype(float) - bg_color[2]) ** 2
		)
		
		fade_alpha = np.clip(255 * (diff / tolerance), 0, 255).astype(np.uint8)
		alpha = np.minimum(alpha, fade_alpha)
	
	transparent = np.sum(alpha == 0)
	print(f"Made {transparent} pixels transparent ({transparent/(height*width)*100:.1f}%)")
	
	return alpha


def process_sprite(input_path, cols, rows, frame_size, output_path=None, tolerance=45):
	"""
	Complete pipeline: load → remove background → resize to grid → save
	
	Args:
		input_path: Input sprite sheet path
		cols: Number of columns in grid
		rows: Number of rows in grid
		frame_size: Size of each frame in pixels
		output_path: Output path (default: auto-generated)
		tolerance: Background removal tolerance
	
	Returns:
		Path to output file
	"""
	
	print("="*70)
	print("COMPLETE SPRITE PROCESSING PIPELINE")
	print("="*70)
	
	# Step 1: Load image
	print(f"\n[1/4] Loading: {input_path}")
	img = Image.open(input_path)
	if img.mode != 'RGBA':
		img = img.convert('RGBA')
	
	data = np.array(img)
	orig_width, orig_height = img.size
	print(f"      Original size: {orig_width}x{orig_height}")
	
	# Step 2: Remove background
	print(f"\n[2/4] Removing background (tolerance={tolerance})...")
	alpha = remove_background(data, tolerance)
	data[:,:,3] = alpha
	
	# Step 3: Resize to perfect grid
	target_width = cols * frame_size
	target_height = rows * frame_size
	
	print(f"\n[3/4] Resizing to perfect grid...")
	print(f"      Target: {target_width}x{target_height} ({cols}x{rows} grid)")
	print(f"      Frame size: {frame_size}x{frame_size} pixels")
	
	img_with_alpha = Image.fromarray(data, 'RGBA')
	img_resized = img_with_alpha.resize((target_width, target_height), Image.Resampling.NEAREST)
	
	# Verify
	verify_w = img_resized.size[0] / cols
	verify_h = img_resized.size[1] / rows
	
	if verify_w == frame_size and verify_h == frame_size:
		print(f"      ✓ Grid perfect! Each frame = {frame_size}x{frame_size}")
	else:
		print(f"      ✗ Warning: Frame size = {verify_w}x{verify_h} (expected {frame_size}x{frame_size})")
	
	# Step 4: Save
	if output_path is None:
		base, _ = os.path.splitext(input_path)
		output_path = f"{base}_final.png"
	
	print(f"\n[4/4] Saving final sprite...")
	img_resized.save(output_path, 'PNG')
	
	file_size = os.path.getsize(output_path) / 1024  # KB
	print(f"      ✓ Saved to: {output_path}")
	print(f"      File size: {file_size:.1f} KB")
	
	# Final summary
	print("\n" + "="*70)
	print("✓ PIPELINE COMPLETE!")
	print("="*70)
	print(f"Input:  {input_path} ({orig_width}x{orig_height})")
	print(f"Output: {output_path} ({target_width}x{target_height})")
	print(f"Grid:   {cols}x{rows} = {cols*rows} frames of {frame_size}x{frame_size}px")
	print(f"\nReady to import into Godot!")
	print("="*70)
	
	return output_path


if __name__ == "__main__":
	if len(sys.argv) < 5:
		print("="*70)
		print("Complete Sprite Processing Pipeline")
		print("="*70)
		print()
		print("Usage:")
		print("  python complete_sprite_pipeline.py <image> <cols> <rows> <frame_size> [options]")
		print()
		print("Arguments:")
		print("  <image>       Input sprite sheet path")
		print("  <cols>        Number of columns in grid")
		print("  <rows>        Number of rows in grid")
		print("  <frame_size>  Size of each frame (e.g., 128 for 128x128)")
		print()
		print("Options:")
		print("  -o <path>     Output file path (default: auto-generated)")
		print("  -t <value>    Tolerance for background removal (default: 45)")
		print()
		print("Examples:")
		print("  python complete_sprite_pipeline.py knight.png 6 4 128")
		print("  python complete_sprite_pipeline.py boss.png 8 6 128 -t 50")
		print("  python complete_sprite_pipeline.py sprite.png 4 3 64 -o output.png")
		print()
		print("Common Grid Sizes:")
		print("  6x4 grid, 128px frames → 768x512 total")
		print("  8x8 grid, 32px frames  → 256x256 total")
		print("  4x3 grid, 64px frames  → 256x192 total")
		print("="*70)
		sys.exit(1)
	
	# Parse arguments
	input_file = sys.argv[1]
	cols = int(sys.argv[2])
	rows = int(sys.argv[3])
	frame_size = int(sys.argv[4])
	
	output_file = None
	tolerance = 45
	
	# Parse options
	for i in range(5, len(sys.argv)):
		if sys.argv[i] == '-o' and i + 1 < len(sys.argv):
			output_file = sys.argv[i + 1]
		elif sys.argv[i] == '-t' and i + 1 < len(sys.argv):
			tolerance = int(sys.argv[i + 1])
	
	# Run pipeline
	try:
		process_sprite(input_file, cols, rows, frame_size, output_file, tolerance)
	except Exception as e:
		print(f"\n✗ Error: {e}")
		import traceback
		traceback.print_exc()
		sys.exit(1)

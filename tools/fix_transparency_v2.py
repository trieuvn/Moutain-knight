"""
Advanced Transparency Fix Tool v2.0
Removes fake transparent backgrounds with intelligent color detection
Handles white, magenta, purple, grey, and multi-color backgrounds
"""

from PIL import Image
import numpy as np
import sys
import os
from collections import Counter


def detect_background_color(img_array, sample_size=100):
	"""
	Intelligently detect background color from image edges
	
	Args:
		img_array: numpy array of image (RGBA)
		sample_size: number of edge pixels to sample
	
	Returns:
		RGB tuple of most common background color
	"""
	height, width = img_array.shape[:2]
	
	# Sample pixels from all four edges
	edge_pixels = []
	
	# Top edge
	edge_pixels.extend(img_array[0, :sample_size, :3].reshape(-1, 3).tolist())
	# Bottom edge
	edge_pixels.extend(img_array[-1, :sample_size, :3].reshape(-1, 3).tolist())
	# Left edge  
	edge_pixels.extend(img_array[:sample_size, 0, :3].reshape(-1, 3).tolist())
	# Right edge
	edge_pixels.extend(img_array[:sample_size, -1, :3].reshape(-1, 3).tolist())
	
	# Sample corners (often solid background)
	edge_pixels.extend(img_array[0:10, 0:10, :3].reshape(-1, 3).tolist())
	edge_pixels.extend(img_array[0:10, -10:, :3].reshape(-1, 3).tolist())
	edge_pixels.extend(img_array[-10:, 0:10, :3].reshape(-1, 3).tolist())
	edge_pixels.extend(img_array[-10:, -10:, :3].reshape(-1, 3).tolist())
	
	# Find most common color
	color_counts = Counter(tuple(p) for p in edge_pixels)
	most_common_color, count = color_counts.most_common(1)[0]
	
	total_samples = len(edge_pixels)
	percentage = (count / total_samples) * 100
	
	print(f"Background color detected: RGB{most_common_color}")
	print(f"Confidence: {percentage:.1f}% ({count}/{total_samples} edge pixels)")
	
	return np.array(most_common_color)


def find_all_background_colors(img_array, top_n=3):
	"""
	Find multiple background colors (for cases with borders/grids)
	
	Returns:
		List of (color, percentage) tuples
	"""
	height, width = img_array.shape[:2]
	
	# Sample more aggressively from edges
	edge_pixels = []
	edge_size = 50
	
	# All four edges
	edge_pixels.extend(img_array[0, :, :3].reshape(-1, 3).tolist())
	edge_pixels.extend(img_array[-1, :, :3].reshape(-1, 3).tolist())
	edge_pixels.extend(img_array[:, 0, :3].reshape(-1, 3).tolist())
	edge_pixels.extend(img_array[:, -1, :3].reshape(-1, 3).tolist())
	
	color_counts = Counter(tuple(p) for p in edge_pixels)
	total = len(edge_pixels)
	
	top_colors = []
	for color, count in color_counts.most_common(top_n):
		percentage = (count / total) * 100
		if percentage > 1.0:  # Only include if > 1% of edge pixels
			top_colors.append((np.array(color), percentage))
			print(f"  Found color RGB{color}: {percentage:.1f}%")
	
	return top_colors


def remove_background_advanced(input_path, output_path=None, tolerance=40, 
							   multi_color=True, smooth_edges=True):
	"""
	Advanced background removal with multiple color detection
	
	Args:
		input_path: Input image path
		output_path: Output path (default: adds '_transparent')
		tolerance: Color similarity threshold (30-60 recommended)
		multi_color: Detect and remove multiple background colors
		smooth_edges: Apply gradual alpha for anti-aliasing
	
	Returns:
		Path to output file
	"""
	
	print(f"Loading: {input_path}")
	img = Image.open(input_path).convert('RGBA')
	data = np.array(img)
	
	height, width = data.shape[:2]
	print(f"Image size: {width}x{height}")
	
	# Detect background colors
	if multi_color:
		print("\nDetecting multiple background colors...")
		bg_colors = find_all_background_colors(data, top_n=5)
	else:
		print("\nDetecting primary background color...")
		primary_bg = detect_background_color(data)
		bg_colors = [(primary_bg, 100.0)]
	
	# Create alpha channel
	alpha = np.ones((height, width), dtype=np.uint8) * 255
	
	# Process each background color
	for bg_color, confidence in bg_colors:
		print(f"\nRemoving color RGB{tuple(bg_color)} (confidence: {confidence:.1f}%)")
		
		r, g, b, a = data[:,:,0], data[:,:,1], data[:,:,2], data[:,:,3]
		
		# Calculate color difference from this background
		diff = np.sqrt(
			(r.astype(float) - bg_color[0]) ** 2 +
			(g.astype(float) - bg_color[1]) ** 2 +
			(b.astype(float) - bg_color[2]) ** 2
		)
		
		if smooth_edges:
			# Gradual alpha based on distance (anti-aliasing)
			# Pixels closer to bg_color get lower alpha
			fade_alpha = np.clip(255 * (diff / tolerance), 0, 255).astype(np.uint8)
			# Keep minimum of current alpha and new fade alpha
			alpha = np.minimum(alpha, fade_alpha)
		else:
			# Binary mask - either fully transparent or fully opaque
			mask = diff <= tolerance
			alpha[mask] = 0
	
	# Apply final alpha
	data[:,:,3] = alpha
	
	# Stats
	transparent = np.sum(alpha == 0)
	semi = np.sum((alpha > 0) & (alpha < 255))
	opaque = np.sum(alpha == 255)
	total = height * width
	
	print(f"\n✓ Processing complete:")
	print(f"  Transparent pixels: {transparent} ({transparent/total*100:.1f}%)")
	print(f"  Semi-transparent: {semi} ({semi/total*100:.1f}%)")
	print(f"  Opaque pixels: {opaque} ({opaque/total*100:.1f}%)")
	
	# Create output image
	result = Image.fromarray(data, 'RGBA')
	
	# Determine output path
	if output_path is None:
		base, ext = os.path.splitext(input_path)
		output_path = f"{base}_transparent.png"
	
	# Save
	result.save(output_path, 'PNG')
	print(f"\n✓ Saved to: {output_path}")
	
	return output_path


def batch_process(input_dir, output_dir=None, tolerance=40, multi_color=True):
	"""Process all images in a directory"""
	
	if output_dir and not os.path.exists(output_dir):
		os.makedirs(output_dir)
	
	processed = 0
	for filename in os.listdir(input_dir):
		if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
			input_path = os.path.join(input_dir, filename)
			
			if output_dir:
				output_name = os.path.splitext(filename)[0] + '_transparent.png'
				output_path = os.path.join(output_dir, output_name)
			else:
				output_path = None
			
			try:
				print(f"\n{'='*60}")
				print(f"Processing: {filename}")
				print('='*60)
				remove_background_advanced(input_path, output_path, tolerance, multi_color)
				processed += 1
			except Exception as e:
				print(f"✗ Error processing {filename}: {e}")
	
	print(f"\n{'='*60}")
	print(f"✓ Batch complete: Processed {processed} images")
	print('='*60)


if __name__ == "__main__":
	if len(sys.argv) < 2:
		print("Advanced Transparency Removal Tool v2.0")
		print("="*60)
		print("\nUsage:")
		print("  python fix_transparency_v2.py <image_path> [options]")
		print("  python fix_transparency_v2.py --batch <directory> [options]")
		print()
		print("Options:")
		print("  -t, --tolerance <value>    Color tolerance (30-60, default: 40)")
		print("  -s, --single-color         Detect only primary bg color")
		print("  -h, --hard-edges           No gradient/smooth edges")
		print()
		print("Examples:")
		print("  python fix_transparency_v2.py knight.png")
		print("  python fix_transparency_v2.py knight.png -t 50")
		print("  python fix_transparency_v2.py --batch ./sprites -t 45")
		print("  python fix_transparency_v2.py sprite.png --single-color --hard-edges")
		sys.exit(1)
	
	# Parse arguments
	args = sys.argv[1:]
	batch_mode = '--batch' in args
	
	if batch_mode:
		batch_idx = args.index('--batch')
		directory = args[batch_idx + 1] if batch_idx + 1 < len(args) else None
		
		if not directory:
			print("✗ Error: --batch requires directory path")
			sys.exit(1)
		
		# Parse options
		tolerance = 40
		multi_color = True
		
		if '-t' in args or '--tolerance' in args:
			t_idx = args.index('-t') if '-t' in args else args.index('--tolerance')
			tolerance = int(args[t_idx + 1])
		
		if '--single-color' in args or '-s' in args:
			multi_color = False
		
		batch_process(directory, tolerance=tolerance, multi_color=multi_color)
	
	else:
		# Single file mode
		input_file = args[0]
		
		# Parse options
		tolerance = 40
		multi_color = True
		smooth_edges = True
		
		if '-t' in args or '--tolerance' in args:
			t_idx = args.index('-t') if '-t' in args else args.index('--tolerance')
			tolerance = int(args[t_idx + 1])
		
		if '--single-color' in args or '-s' in args:
			multi_color = False
		
		if '--hard-edges' in args or '-h' in args:
			smooth_edges = False
		
		remove_background_advanced(input_file, tolerance=tolerance, 
								   multi_color=multi_color, smooth_edges=smooth_edges)

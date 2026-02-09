"""
Sprite Alignment Fixer
Fixes animation jitter by centering sprites and removing background aggressively
"""

from PIL import Image, ImageDraw
import numpy as np
import sys
import os


def get_sprite_bounds(img_array):
	"""
	Find the bounding box of non-transparent pixels
	
	Returns:
		(min_x, min_y, max_x, max_y) or None if all transparent
	"""
	height, width = img_array.shape[:2]
	alpha = img_array[:, :, 3]
	
	# Find rows and cols with any opaque pixels
	rows_with_content = np.any(alpha > 10, axis=1)
	cols_with_content = np.any(alpha > 10, axis=0)
	
	if not rows_with_content.any() or not cols_with_content.any():
		return None
	
	min_y = np.argmax(rows_with_content)
	max_y = height - np.argmax(rows_with_content[::-1]) - 1
	min_x = np.argmax(cols_with_content)
	max_x = width - np.argmax(cols_with_content[::-1]) - 1
	
	return (min_x, min_y, max_x, max_y)


def analyze_sprite_offsets(img_path, cols, rows):
	"""
	Analyze sprite offsets to detect animation jitter
	"""
	print(f"Analyzing: {img_path}")
	img = Image.open(img_path).convert('RGBA')
	data = np.array(img)
	
	width, height = img.size
	frame_width = width // cols
	frame_height = height // rows
	
	print(f"Grid: {cols}x{rows}, Frame size: {frame_width}x{frame_height}")
	print("\nFrame bounding boxes:")
	
	offsets = []
	
	for row in range(rows):
		for col in range(cols):
			# Extract frame
			x = col * frame_width
			y = row * frame_height
			frame = data[y:y+frame_height, x:x+frame_width]
			
			bounds = get_sprite_bounds(frame)
			if bounds:
				min_x, min_y, max_x, max_y = bounds
				center_x = (min_x + max_x) / 2
				center_y = (min_y + max_y) / 2
				sprite_width = max_x - min_x
				sprite_height = max_y - min_y
				
				offsets.append({
					'row': row,
					'col': col,
					'center_x': center_x,
					'center_y': center_y,
					'width': sprite_width,
					'height': sprite_height,
					'bounds': bounds
				})
				
				print(f"  [{row},{col}] Center: ({center_x:.1f}, {center_y:.1f}), "
					  f"Size: {sprite_width}x{sprite_height}")
	
	# Analyze jitter
	if len(offsets) > 1:
		centers_x = [o['center_x'] for o in offsets]
		centers_y = [o['center_y'] for o in offsets]
		
		avg_x = np.mean(centers_x)
		avg_y = np.mean(centers_y)
		std_x = np.std(centers_x)
		std_y = np.std(centers_y)
		
		print(f"\nJitter Analysis:")
		print(f"  Avg center: ({avg_x:.1f}, {avg_y:.1f})")
		print(f"  Std deviation: X={std_x:.1f}px, Y={std_y:.1f}px")
		
		if std_x > 2 or std_y > 2:
			print(f"  WARNING: HIGH JITTER DETECTED! Sprites not centered consistently.")
		else:
			print(f"  OK: Low jitter, sprites well-aligned")
	
	return offsets


def fix_sprite_alignment(img_path, cols, rows, output_path=None, aggressive_bg=True):
	"""
	Fix sprite alignment and remove background aggressively
	"""
	print("="*70)
	print("SPRITE ALIGNMENT FIXER")
	print("="*70)
	
	img = Image.open(img_path).convert('RGBA')
	data = np.array(img)
	
	width, height = img.size
	frame_width = width // cols
	frame_height = height // rows
	
	print(f"\nInput: {width}x{height}")
	print(f"Grid: {cols}x{rows}, Frame: {frame_width}x{frame_height}")
	
	# Step 1: Aggressive background removal
	if aggressive_bg:
		print(f"\n[1/2] Aggressive background removal...")
		
		# Remove white and near-white
		r, g, b, a = data[:,:,0], data[:,:,1], data[:,:,2], data[:,:,3]
		
		# Detect all light colors (white, light grey, light purple)
		brightness = (r.astype(float) + g.astype(float) + b.astype(float)) / 3
		is_light = brightness > 200  # Very aggressive threshold
		
		# Also detect specific problematic colors
		is_white = (r > 240) & (g > 240) & (b > 240)
		is_light_purple = (r > 200) & (b > 200) & (g < 200)
		is_light_grey = (np.abs(r - g) < 20) & (np.abs(g - b) < 20) & (brightness > 180)
		
		# Combine all background detection
		is_background = is_light | is_white | is_light_purple | is_light_grey
		
		data[:,:,3][is_background] = 0
		
		removed = np.sum(is_background)
		total = width * height
		print(f"  Removed {removed} background pixels ({removed/total*100:.1f}%)")
	
	# Step 2: Analyze and re-center each frame
	print(f"\n[2/2] Re-centering sprites...")
	
	offsets = []
	for row in range(rows):
		for col in range(cols):
			x = col * frame_width
			y = row * frame_height
			frame = data[y:y+frame_height, x:x+frame_width]
			
			bounds = get_sprite_bounds(frame)
			if bounds:
				offsets.append({
					'row': row,
					'col': col,
					'bounds': bounds,
					'x': x,
					'y': y
				})
	
	if offsets:
		# Calculate average sprite size
		widths = [o['bounds'][2] - o['bounds'][0] for o in offsets]
		heights = [o['bounds'][3] - o['bounds'][1] for o in offsets]
		avg_width = np.mean(widths)
		avg_height = np.mean(heights)
		
		print(f"  Avg sprite size: {avg_width:.1f}x{avg_height:.1f}")
		
		# Create new image with centered sprites
		new_data = np.zeros_like(data)
		
		for offset in offsets:
			row, col = offset['row'], offset['col']
			x_grid, y_grid = offset['x'], offset['y']
			bounds = offset['bounds']
			
			# Extract sprite
			min_x, min_y, max_x, max_y = bounds
			sprite = data[y_grid:y_grid+frame_height, x_grid:x_grid+frame_width]
			sprite_content = sprite[min_y:max_y+1, min_x:max_x+1]
			
			# Calculate center position in frame
			sprite_w = max_x - min_x + 1
			sprite_h = max_y - min_y + 1
			
			# Center it
			new_x = (frame_width - sprite_w) // 2
			new_y = (frame_height - sprite_h) // 2
			
			# Place centered sprite
			new_data[
				y_grid + new_y : y_grid + new_y + sprite_h,
				x_grid + new_x : x_grid + new_x + sprite_w
			] = sprite_content
		
		data = new_data
		print(f"  OK: Re-centered {len(offsets)} sprites")
	
	# Save result
	result = Image.fromarray(data, 'RGBA')
	
	if output_path is None:
		base, ext = os.path.splitext(img_path)
		output_path = f"{base}_fixed_aligned.png"
	
	result.save(output_path, 'PNG')
	
	print(f"\n{'='*70}")
	print(f"OK: FIXED SPRITE SAVED: {output_path}")
	print(f"{'='*70}")
	
	return output_path


if __name__ == "__main__":
	if len(sys.argv) < 2:
		print("Sprite Alignment Fixer")
		print("="*70)
		print("\nUsage:")
		print("  python fix_sprite_alignment.py <image> <cols> <rows> [options]")
		print()
		print("Options:")
		print("  --analyze-only    Just analyze, don't fix")
		print("  --no-aggressive   Don't use aggressive background removal")
		print("  -o <path>         Output path")
		print()
		print("Examples:")
		print("  python fix_sprite_alignment.py knight.png 6 4")
		print("  python fix_sprite_alignment.py sprite.png 6 4 --analyze-only")
		print("  python fix_sprite_alignment.py knight.png 6 4 -o fixed.png")
		sys.exit(1)
	
	input_file = sys.argv[1]
	cols = int(sys.argv[2]) if len(sys.argv) > 2 else 6
	rows = int(sys.argv[3]) if len(sys.argv) > 3 else 4
	
	analyze_only = '--analyze-only' in sys.argv
	aggressive = '--no-aggressive' not in sys.argv
	
	output_file = None
	if '-o' in sys.argv:
		idx = sys.argv.index('-o')
		if idx + 1 < len(sys.argv):
			output_file = sys.argv[idx + 1]
	
	if analyze_only:
		analyze_sprite_offsets(input_file, cols, rows)
	else:
		fix_sprite_alignment(input_file, cols, rows, output_file, aggressive)

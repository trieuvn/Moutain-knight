"""
Sprite Sheet Grid Fixer
Resizes sprite sheets to exact grid dimensions to avoid frame slicing errors
"""

from PIL import Image
import sys
import os


def fix_grid_dimensions(input_path, cols, rows, target_frame_size, output_path=None):
	"""
	Resize sprite sheet to exact grid dimensions
	
	Args:
		input_path: Path to input sprite sheet
		cols: Number of columns
		rows: Number of rows
		target_frame_size: Size of each frame (e.g., 128 for 128x128)
		output_path: Output path (default: adds '_fixed_grid' suffix)
	
	Returns:
		Path to output file
	"""
	
	print(f"Loading: {input_path}")
	img = Image.open(input_path)
	
	original_width, original_height = img.size
	print(f"Original size: {original_width}x{original_height}")
	
	# Calculate target dimensions
	target_width = cols * target_frame_size
	target_height = rows * target_frame_size
	print(f"Target size: {target_width}x{target_height} ({cols}x{rows} grid, {target_frame_size}px frames)")
	
	# Resize using high-quality resampling
	if img.mode != 'RGBA':
		img = img.convert('RGBA')
	
	resized = img.resize((target_width, target_height), Image.Resampling.NEAREST)
	
	print(f"Resized to: {resized.size[0]}x{resized.size[1]}")
	
	# Determine output path
	if output_path is None:
		base, ext = os.path.splitext(input_path)
		output_path = f"{base}_fixed_grid.png"
	
	# Save
	resized.save(output_path, 'PNG')
	print(f"Saved: {output_path}")
	
	# Verify grid divisions
	verify_w = resized.size[0] / cols
	verify_h = resized.size[1] / rows
	print(f"Frame size verification: {verify_w}x{verify_h} (should be {target_frame_size}x{target_frame_size})")
	
	if verify_w == target_frame_size and verify_h == target_frame_size:
		print("✓ Grid dimensions are PERFECT!")
	else:
		print("✗ Warning: Grid dimensions may have rounding errors")
	
	return output_path


if __name__ == "__main__":
	if len(sys.argv) < 5:
		print("Usage: python fix_sprite_grid.py <image> <cols> <rows> <frame_size>")
		print()
		print("Example:")
		print("  python fix_sprite_grid.py knight.png 6 4 128")
		print("  (Resizes to 768x512 for perfect 6x4 grid with 128px frames)")
		sys.exit(1)
	
	input_file = sys.argv[1]
	cols = int(sys.argv[2])
	rows = int(sys.argv[3])
	frame_size = int(sys.argv[4])
	
	fix_grid_dimensions(input_file, cols, rows, frame_size)

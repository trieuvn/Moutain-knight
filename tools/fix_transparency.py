"""
Transparent Background Fix Tool
Converts fake transparent backgrounds (solid colors) to true PNG transparency
Specifically for fixing Gemini AI generated images with fake transparency
"""

from PIL import Image
import numpy as np
import sys
import os


def make_transparent(input_path, output_path=None, tolerance=30, edge_sample=True):
    """
    Convert fake transparent background to true transparency
    
    Args:
        input_path: Path to input image
        output_path: Path to save output (default: adds '_transparent' suffix)
        tolerance: Color similarity threshold (0-255, higher = more aggressive)
        edge_sample: If True, samples background color from image corners
    
    Returns:
        Path to output file
    """
    
    # Load image
    print(f"Loading: {input_path}")
    img = Image.open(input_path).convert('RGBA')
    data = np.array(img)
    
    # Determine background color
    if edge_sample:
        # Sample from corners (usually background)
        corners = [
            data[0, 0],           # Top-left
            data[0, -1],          # Top-right
            data[-1, 0],          # Bottom-left
            data[-1, -1]          # Bottom-right
        ]
        # Use most common corner color
        bg_color = corners[0][:3]  # RGB only
        print(f"Detected background color from corners: RGB{tuple(bg_color)}")
    else:
        # Use most common color in entire image
        colors, counts = np.unique(data.reshape(-1, 4), axis=0, return_counts=True)
        bg_color = colors[counts.argmax()][:3]
        print(f"Detected most common color: RGB{tuple(bg_color)}")
    
    # Create mask for pixels similar to background
    r, g, b, a = data[:,:,0], data[:,:,1], data[:,:,2], data[:,:,3]
    
    # Calculate color difference from background
    diff = np.sqrt(
        (r.astype(int) - int(bg_color[0])) ** 2 +
        (g.astype(int) - int(bg_color[1])) ** 2 +
        (b.astype(int) - int(bg_color[2])) ** 2
    )
    
    # Pixels within tolerance become transparent
    mask = diff <= tolerance
    
    # Set alpha to 0 for background pixels
    data[:,:,3][mask] = 0
    
    # Count pixels changed
    pixels_changed = np.sum(mask)
    total_pixels = data.shape[0] * data.shape[1]
    print(f"Made {pixels_changed}/{total_pixels} pixels transparent ({pixels_changed/total_pixels*100:.1f}%)")
    
    # Create output image
    result = Image.fromarray(data, 'RGBA')
    
    # Determine output path
    if output_path is None:
        base, ext = os.path.splitext(input_path)
        output_path = f"{base}_transparent.png"
    
    # Save
    result.save(output_path, 'PNG')
    print(f"Saved: {output_path}")
    
    return output_path


def batch_process(input_dir, output_dir=None, tolerance=30):
    """
    Process all PNG files in a directory
    
    Args:
        input_dir: Directory containing images
        output_dir: Output directory (default: same as input)
        tolerance: Color similarity threshold
    """
    
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
                make_transparent(input_path, output_path, tolerance)
                processed += 1
                print()
            except Exception as e:
                print(f"Error processing {filename}: {e}\n")
    
    print(f"Processed {processed} images successfully!")


def advanced_remove_bg(input_path, output_path=None, threshold=30, smooth_edges=True):
    """
    Advanced background removal with edge smoothing
    
    Args:
        input_path: Path to input image
        output_path: Path to save output
        threshold: Background detection threshold
        smooth_edges: Apply anti-aliasing to edges
    """
    
    print(f"Loading: {input_path}")
    img = Image.open(input_path).convert('RGBA')
    data = np.array(img)
    
    # Sample background from multiple edge points
    height, width = data.shape[:2]
    edge_samples = []
    
    # Top edge
    edge_samples.extend(data[0, ::width//10].tolist())
    # Bottom edge
    edge_samples.extend(data[-1, ::width//10].tolist())
    # Left edge
    edge_samples.extend(data[::height//10, 0].tolist())
    # Right edge
    edge_samples.extend(data[::height//10, -1].tolist())
    
    # Get average background color
    edge_samples = np.array(edge_samples)
    bg_color = np.median(edge_samples[:, :3], axis=0)
    print(f"Background color: RGB{tuple(bg_color.astype(int))}")
    
    # Calculate distance from background
    r, g, b, a = data[:,:,0], data[:,:,1], data[:,:,2], data[:,:,3]
    diff = np.sqrt(
        (r.astype(float) - bg_color[0]) ** 2 +
        (g.astype(float) - bg_color[1]) ** 2 +
        (b.astype(float) - bg_color[2]) ** 2
    )
    
    if smooth_edges:
        # Gradual alpha based on distance (anti-aliasing)
        alpha_new = np.clip(255 * (diff / threshold), 0, 255).astype(np.uint8)
        # Keep existing alpha for non-background pixels
        alpha_new = np.minimum(alpha_new, a)
    else:
        # Binary mask
        alpha_new = np.where(diff > threshold, 255, 0).astype(np.uint8)
    
    data[:,:,3] = alpha_new
    
    # Stats
    transparent = np.sum(alpha_new == 0)
    semi = np.sum((alpha_new > 0) & (alpha_new < 255))
    opaque = np.sum(alpha_new == 255)
    total = data.shape[0] * data.shape[1]
    
    print(f"Transparent: {transparent} ({transparent/total*100:.1f}%)")
    print(f"Semi-transparent: {semi} ({semi/total*100:.1f}%)")
    print(f"Opaque: {opaque} ({opaque/total*100:.1f}%)")
    
    result = Image.fromarray(data, 'RGBA')
    
    if output_path is None:
        base, ext = os.path.splitext(input_path)
        output_path = f"{base}_fixed.png"
    
    result.save(output_path, 'PNG')
    print(f"Saved: {output_path}")
    
    return output_path


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python fix_transparency.py <image_path> [tolerance]")
        print("  python fix_transparency.py --batch <directory> [tolerance]")
        print("  python fix_transparency.py --advanced <image_path> [threshold]")
        print()
        print("Examples:")
        print("  python fix_transparency.py knight.png")
        print("  python fix_transparency.py knight.png 50")
        print("  python fix_transparency.py --batch ./sprites")
        print("  python fix_transparency.py --advanced boss.png 40")
        sys.exit(1)
    
    if sys.argv[1] == "--batch":
        if len(sys.argv) < 3:
            print("Error: --batch requires directory path")
            sys.exit(1)
        tolerance = int(sys.argv[3]) if len(sys.argv) > 3 else 30
        batch_process(sys.argv[2], tolerance=tolerance)
    
    elif sys.argv[1] == "--advanced":
        if len(sys.argv) < 3:
            print("Error: --advanced requires image path")
            sys.exit(1)
        threshold = int(sys.argv[3]) if len(sys.argv) > 3 else 30
        advanced_remove_bg(sys.argv[2], threshold=threshold)
    
    else:
        tolerance = int(sys.argv[2]) if len(sys.argv) > 2 else 30
        make_transparent(sys.argv[1], tolerance=tolerance)

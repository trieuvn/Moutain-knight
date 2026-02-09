# Transparent Background Fix Tool

Converts fake transparent backgrounds from AI-generated images into **true PNG transparency** for Godot import.

## Problem Solved

AI image generators (like Gemini) often create images with:
- Solid color backgrounds that **look** transparent
- But are actually **RGB pixels** (magenta #FF00FF, white, etc.)
- Godot cannot import these as valid transparent PNGs

This tool **detects and removes** those fake backgrounds!

---

## Installation

Requires Python 3.7+ and PIL/Pillow:

```bash
pip install Pillow numpy
```

---

## Usage

### 1. Basic Mode (Single Image)

```bash
python tools/fix_transparency.py path/to/image.png [tolerance]
```

**Example:**
```bash
python tools/fix_transparency.py knight.png 50
```

- **tolerance**: Color similarity threshold (0-255)
  - `30` = strict (default)
  - `50` = moderate (recommended for Gemini images)
  - `80` = aggressive (removes more pixels)

**Output:** Creates `knight_transparent.png` in same directory

### 2. Batch Mode (Multiple Images)

```bash
python tools/fix_transparency.py --batch directory_path [tolerance]
```

**Example:**
```bash
python tools/fix_transparency.py --batch ./artifacts/sprites 50
```

Processes **all PNG/JPG files** in directory

### 3. Advanced Mode (Edge Smoothing)

```bash
python tools/fix_transparency.py --advanced image.png [threshold]
```

Features:
- Samples background from multiple edge points
- Anti-aliasing for smooth edges
- Gradual alpha transparency

---

## How It Works

1. **Detects background color** from image corners
2. **Calculates color difference** for each pixel
3. **Replaces similar pixels** with alpha=0 (transparent)
4. **Saves as proper PNG** with alpha channel

**Before:**
```
RGB(255, 0, 255) - Magenta "fake transparent"
RGB(255, 255, 255) - White background
```

**After:**
```
RGBA(x, x, x, 0) - True transparent!
RGBA(x, x, x, 255) - Opaque sprite pixels
```

---

## Workflow: Gemini → Godot

### Step 1: Generate Image
Request from Gemini:
> "Pixel art knight sprite, 64x64, dark armor, magenta background #FF00FF"

### Step 2: Fix Transparency
```bash
python tools/fix_transparency.py knight.png 50
```

Output: `knight_transparent.png`

### Step 3: Import to Godot
```bash
cp knight_transparent.png assets/sprites/player/
```

### Step 4: Open Godot Editor
- Godot imports the sprite
- Creates `.import` file
- Ready to use!

---

## Examples

### Knight Character (Gemini Generated)

**Command:**
```bash
python tools/fix_transparency.py \
  C:/Users/.../knight_single_frame.png 50
```

**Result:**
- Detected: RGB(255, 0, 255) magenta
- Removed: 87.3% pixels (background)
- Created: True transparent PNG ✓

### Skeleton Enemy

**Command:**
```bash
python tools/fix_transparency.py --advanced skeleton.png 40
```

**Result:**
- Edge smoothing applied
- Anti-aliased edges
- Perfect for Godot physics

---

## Tips

### Choosing Tolerance

- **Too low (10-20)**: Leaves background artifacts
- **Just right (30-50)**: Clean removal
- **Too high (80+)**: Removes sprite details!

### Best Practices

1. **Use solid backgrounds** when generating:
   - Pure magenta `#FF00FF`
   - Pure white `#FFFFFF`
   - Pure green `#00FF00` (chroma key)

2. **Check corners**: Background color sampled from edges

3. **Test first**: Run on single image before batch

---

## Troubleshooting

**Problem:** Tool removes too much
- **Fix:** Lower tolerance (try 20-30)

**Problem:** Background still visible
- **Fix:** Increase tolerance (try 60-80)

**Problem:** "No module named PIL"
- **Fix:** `pip install Pillow`

**Problem:** Godot "Not a PNG file" error
- **Fix:** Image might be corrupted, regenerate

---

## License

Free to use for Mountain Knight project and derivatives

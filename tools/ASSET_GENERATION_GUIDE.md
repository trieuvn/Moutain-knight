# Asset Generation Guide for Mountain Knight

Complete guide for generating game assets using Gemini AI + Python tools.

---

## 🎨 Image Generation Prompt Templates

### Knight Character Sprite Sheet

#### ✅ Best Practice Template:
```
Pixel art sprite sheet for 2D platformer knight character. 
STRICT GRID: 6 columns x 4 rows = 24 frames total.
Each frame MUST be square and evenly spaced.

Frame arrangement (left to right, top to bottom):
Row 1: 5 idle animation frames + 1 run start
Row 2: 6 run animation frames  
Row 3: 3 jump frames + 2 fall frames + 1 attack start
Row 4: 5 attack swing frames + 1 pose

STYLE:
- Dark medieval knight with steel armor
- Red/crimson cape flowing
- Sword in hand
- Dark fantasy aesthetic
- Clean pixel art (avoid blur)

TECHNICAL:
- Pure white background (#FFFFFF) 
- Each sprite centered in its cell
- NO overlap between cells
- Consistent character size across all frames
```

**Key Success Factors:**
- ✅ Specify EXACT grid dimensions (6x4, 8x8, etc.)
- ✅ Request white/solid background for easy removal
- ✅ Describe frame sequence clearly
- ✅ Emphasize "NO overlap" between cells

---

### Enemy Sprite Sheets

#### Skeleton Warrior:
```
Pixel art sprite sheet of skeleton warrior enemy.
GRID: 4 columns x 3 rows = 12 frames.

Row 1: 4 walk animation frames
Row 2: 4 attack frames
Row 3: 4 death/defeat frames

STYLE:
- Undead skeleton with rusty sword and shield
- Dark fantasy dungeon crawler aesthetic
- Bone white with brown/rust accents
- 48x64 pixel character size

BACKGROUND: Pure white (#FFFFFF)
LAYOUT: Evenly spaced grid, no frame overlap
```

#### Flying Enemy (Bat/Gargoyle):
```
Pixel art sprite sheet of flying enemy for 2D game.
GRID: 5 columns x 2 rows = 10 frames.

Row 1: 5 flying/flapping animation frames
Row 2: 3 attack frames + 2 hurt frames

STYLE:
- Dark gargoyle or demon bat
- Gothic horror aesthetic  
- Wings spread in flight
- Red eyes glowing

BACKGROUND: Solid white (#FFFFFF)
CHARACTER SIZE: 64x64 pixels per frame
```

---

### Boss Sprite Sheets

#### Large Boss Template:
```
Pixel art sprite sheet of imposing boss character.
GRID: 6 columns x 5 rows = 30 frames.

Frame distribution:
Rows 1-2: Idle and breathing animation (12 frames)
Row 3: Walk/approach (6 frames)
Row 4: Attack animations (6 frames)
Row 5: Special attack + hurt + death (6 frames)

STYLE:
- Fallen templar knight corrupted by darkness
- Massive armor (2x player size)
- Glowing red eyes through helmet
- Tattered black cape
- Large two-handed sword

TECHNICAL:
- 128x128 pixels minimum per frame
- Pure white background
- Centered in each cell
- Dark souls / gothic boss aesthetic
```

---

### Tileset Generation

#### Dungeon Tileset:
```
Pixel art tileset for dark dungeon environment.
GRID: 8 columns x 8 rows = 64 tiles.
Each tile: 32x32 pixels exactly.

Tiles needed:
- Stone floor variations (4 types)
- Stone walls (top, bottom, left, right, corners)
- Doorways and arches
- Torches (2 frames for animation)
- Cracks and damage variations
- Chains and prison bars
- Treasure chest
- Decorative skulls/bones

STYLE:
- Dark medieval dungeon
- Grey/brown stone textures
- Torch lighting glow
- Grimdark atmosphere

BACKGROUND: White (#FFFFFF)
IMPORTANT: Each 32x32 tile must be perfectly aligned to grid
```

#### Village/Safe Zone Tileset:
```
Pixel art tileset for medieval village environment.
GRID: 8x8 = 64 tiles, 32x32px each.

Tiles:
- Cobblestone ground (variations)
- Grass edges and transitions
- Wooden planks (floor)
- Stone walls (building exteriors)
- Windows and doors
- Roof tiles (multiple angles)
- Market stall pieces
- Fence sections
- Flowers/plants

STYLE:
- Cozy medieval village
- Warm earth tones
- Daylight atmosphere
- Stardew Valley meets Dark Souls

BACKGROUND: Transparent white (#FFFFFF)
```

---

### UI Elements

#### Health/Stamina Bars:
```
Pixel art UI elements for game interface.
LAYOUT: Horizontal strip, 10 elements.

Elements (128x64px each):
1. Health bar frame (border)
2. Health bar fill (red)
3. Health bar empty (dark red)
4. Stamina bar frame
5. Stamina bar fill (yellow)
6. Stamina bar empty (orange)
7. Boss health bar (larger)
8. XP bar fill (blue)
9. Portrait frame (circular)
10. Level up indicator

STYLE:
- Dark fantasy UI
- Ornate metal borders
- Glowing effects on fills
- Medieval aesthetic

BACKGROUND: White (#FFFFFF)
SIZE: Total 1280x64 pixels (10×128)
```

---

## 🔧 Processing Pipeline

### Step 1: Generate Image
Use templates above with Gemini `generate_image` tool.

### Step 2: Remove Fake Transparency
```bash
python tools/fix_transparency.py --advanced sprite.png 40
```

**Parameters:**
- `--advanced`: Uses edge smoothing algorithm
- `40`: Tolerance (30-50 recommended)

### Step 3: Resize to Perfect Grid
```bash
python tools/fix_sprite_grid.py sprite_fixed.png 6 4 128
```

**Parameters:**
- `6`: Number of columns
- `4`: Number of rows  
- `128`: Frame size in pixels

### Step 4: Complete Pipeline (Automated)
```bash
python tools/complete_sprite_pipeline.py sprite.png 6 4 128
```

Combines all steps into one command!

---

## 📋 Prompt Engineering Lessons Learned

### ✅ DO:
1. **Specify exact dimensions** - "6 columns x 4 rows"
2. **Request grid lines** - Helps Gemini understand layout
3. **Use solid backgrounds** - White, magenta, green (easy to remove)
4. **Emphasize spacing** - "NO overlap between cells"
5. **Request consistency** - "Character same size in all frames"
6. **Specify pixel size** - "128x128 per frame"
7. **Describe style clearly** - References to existing games help

### ❌ DON'T:
1. **Don't request arbitrary sizes** - Use multiples of 32/64/128
2. **Avoid gradient backgrounds** - Makes transparency removal harder
3. **Don't mix art styles** - Be consistent
4. **Avoid vague layouts** - "Sprite sheet" alone isn't enough
5. **Don't expect perfect first try** - Iterate if needed

### 🎯 Size Recommendations:

**Character Sprites:**
- Small enemies: 48x48 or 64x64
- Player characters: 64x64 or 128x128  
- Bosses: 128x128 or 256x256

**Tilesets:**
- Environment: 32x32 (standard)
- Large tiles: 64x64

**UI Elements:**
- Icons: 32x32 or 64x64
- Bars: 128x32 or 256x32

---

## 🎮 Common Sprite Sheet Layouts

### Small Character (12 frames):
```
4 cols x 3 rows
Row 1: Idle (4)
Row 2: Walk (4)
Row 3: Attack (4)
```

### Medium Character (24 frames):
```
6 cols x 4 rows
Row 1: Idle (5) + Run (1)
Row 2: Run (6)
Row 3: Jump (3) + Fall (2) + Attack (1)
Row 4: Attack (6)
```

### Large Character (48 frames):
```
8 cols x 6 rows
Rows 1-2: Idle + Walk
Rows 3-4: Run + Jump + Fall
Rows 5-6: Attacks + Special + Hurt + Death
```

---

## 🔬 Advanced Techniques

### Multi-Layer Generation:
Generate separate layers for complex sprites:
1. **Base layer**: Character body
2. **Equipment layer**: Armor, weapons
3. **Effects layer**: Glow, particles

Then composite manually in image editor.

### Animation Smoothness:
Request "smooth animation transitions between frames" explicitly.
Mention "consistent arc of motion" for jumps/attacks.

### Color Palette Consistency:
Provide hex colors in prompt:
```
COLOR PALETTE:
- Armor: #2C3E50 (dark steel)
- Cape: #C0392B (crimson red)
- Highlights: #ECF0F1 (light grey)
- Shadows: #1A1A1A (near black)
```

---

## 📝 Checklist for Each Asset

Before importing to Godot:

- [ ] Background removed (transparent PNG)
- [ ] Dimensions are exact multiples (768x512, not 770x513)
- [ ] Grid divisions are perfect (no decimal frame sizes)
- [ ] File size reasonable (<2MB for sprites)
- [ ] No compression artifacts
- [ ] Consistent art style with existing assets
- [ ] Frames properly aligned

---

## 🆘 Troubleshooting

### "Sprites are cut/broken in game"
→ Check frame size is integer (128, not 127.5)
→ Use `fix_sprite_grid.py` to resize

### "Background not fully removed"
→ Increase tolerance in `fix_transparency.py`
→ Try `--advanced` mode
→ Check original has solid background

### "Gemini ignores size request"
→ Normal! Use `fix_sprite_grid.py` after generation
→ Always verify and resize to exact dimensions

### "Animations look jittery"
→ May need more frames
→ Regenerate with "smooth animation" emphasis

---

## 📦 Complete Workflow Example

```bash
# 1. Generate (via tool or manual)
# → knight_sprite.png created

# 2. Full pipeline
python tools/complete_sprite_pipeline.py \
  knight_sprite.png \
  6 4 128 \
  -o assets/sprites/player/knight_final.png

# 3. Copy to project
# Sprite automatically has:
# - Transparent background
# - Perfect 768x512 dimensions  
# - 128x128 frame size
# - Ready for Godot import!
```

---

## 🎯 Next Steps

1. Build asset library with consistent style
2. Create animation documentation for each sprite
3. Export individual frames if needed
4. Test in game engine before finalizing

**Remember:** Iteration is normal! First generation rarely perfect. Use tools to refine.

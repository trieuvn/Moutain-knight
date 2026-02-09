# PixelLab Accounts & Characters Registry
# Dùng file này để theo dõi các tài khoản và assets đã tạo

## Account 1 (Current - Active)
**Account ID:** `4a07474e-ba31-4226-93dd-54211531d211`
**API Token:** `58fbf4f8-c8e6-4e2c-9b7e-c761a3eee60e`
**Purpose:** Main characters (Player, Enemy, Boss)
**Token Status:** Animation trial exhausted, character trial available

### Characters Created:

#### 1. Penitent Knight (Player)
- **Character ID:** `ae1a1014-f115-43e6-a63d-97d70a3e129b`
- **Size:** 64×64px
- **View:** side
- **Directions:** 4 (east, west, north, south)
- **Style:** detailed shading, high detail, black outline
- **Description:** dark penitent knight warrior, gothic holy warrior with blood-stained armor, red tattered cape, pointed helm
- **Animations Completed:**
  - ✅ `breathing-idle` (4 frames, north + south)
- **Animations Needed:**
  - ❌ run
  - ❌ jump
  - ❌ attack
  - ❌ heavy_attack
  - ❌ dodge
- **Download URL:** https://api.pixellab.ai/mcp/characters/ae1a1014-f115-43e6-a63d-97d70a3e129b/download
- **Status:** Downloaded to `assets/sprites/player/penitent_knight/`

---

#### 2. Skeleton Warrior (Enemy)
- **Character ID:** `490229ec-b75a-476e-971f-d815dedd8276`
- **Size:** 48×48px
- **View:** side
- **Directions:** 4
- **Style:** medium shading, medium detail
- **Description:** undead skeleton warrior enemy, rusty sword and broken shield, bone white with dark eye sockets
- **Animations Completed:** None
- **Animations Needed:**
  - ❌ walk
  - ❌ attack
  - ❌ hurt
  - ❌ death
- **Download URL:** https://api.pixellab.ai/mcp/characters/490229ec-b75a-476e-971f-d815dedd8276/download
- **Status:** Downloaded to `assets/sprites/enemies/skeleton_warrior/`

---

#### 3. Corrupted Bishop Boss
- **Character ID:** `e05cb443-1335-4d60-9a33-769aaf4849ea`
- **Size:** 128×128px
- **View:** side
- **Directions:** 4
- **Style:** detailed shading, high detail
- **Description:** corrupted bishop boss, massive fallen religious figure with glowing red eyes, ornate bloody robes, demonic staff
- **Animations Completed:** None
- **Animations Needed:**
  - ❌ idle
  - ❌ walk
  - ❌ attack_slash
  - ❌ attack_overhead
  - ❌ attack_charge
  - ❌ hurt
  - ❌ death
- **Download URL:** https://api.pixellab.ai/mcp/characters/e05cb443-1335-4d60-9a33-769aaf4849ea/download
- **Status:** Downloaded to `assets/sprites/bosses/corrupted_bishop/`

---

### Tilesets Created:

#### Dungeon Sidescroller Tileset
- **Tileset ID:** `b2a03d18-9c6b-4808-ae81-19a12f197979`
- **Base Tile ID:** `a7ddaecb-8a7c-4a0d-88ea-882ed19482fc`
- **Type:** Sidescroller
- **Size:** 32×32px tiles
- **Description:** dark gothic stone dungeon wall, bloody medieval cobblestone, Blasphemous style
- **Status:** ✅ Downloaded to `assets/tilesets/dungeon_tileset.png`

---

## Account 2 (Active)
**Account ID:** `1a2393df-971d-4571-afef-3e1dfea351e1`
**API Token:** `29ee6734-4e1d-4d35-b338-61809e06556e`
**Purpose:** Additional enemies and second boss
**Token Status:** Character trial used, animation trial used for Ghoul

### Characters Created:

#### 1. Ghoul Enemy
- **Character ID:** `2e76a103-4c46-4b6d-954f-ffc400b41c24`
- **Size:** 48×48px
- **View:** side
- **Directions:** 4
- **Description:** ghoul zombie enemy, rotting flesh creature with claws, hunched posture
- **Animations Completed:**
  - ✅ `scary-walk` (walk animation)
- **Download URL:** https://api.pixellab.ai/mcp/characters/2e76a103-4c46-4b6d-954f-ffc400b41c24/download
- **Status:** Processing

---

#### 2. Cultist Enemy
- **Character ID:** `23ced8a3-e847-4a8d-a034-7b05e4e92ca6`
- **Size:** 48×48px
- **View:** side
- **Directions:** 4
- **Description:** dark cultist enemy, hooded figure with glowing red eyes, black robes
- **Animations Completed:** None
- **Download URL:** https://api.pixellab.ai/mcp/characters/23ced8a3-e847-4a8d-a034-7b05e4e92ca6/download
- **Status:** Processing

---

#### 3. Blood Wraith Boss
- **Character ID:** `b2dac78f-415c-48d1-aa87-8874e4f18783`
- **Size:** 128×128px
- **View:** side
- **Directions:** 4
- **Description:** blood wraith boss, floating spectral horror with skeletal face, blood-red robes
- **Animations Completed:** None
- **Download URL:** https://api.pixellab.ai/mcp/characters/b2dac78f-415c-48d1-aa87-8874e4f18783/download
- **Status:** Processing

---

### Tilesets Created:

#### Temple Sidescroller Tileset
- **Tileset ID:** `fecfa7ab-d169-4193-a9e1-f11866320d7d`
- **Base Tile ID:** `a1ef6335-9e4e-43a1-a900-0163209bd19d`
- **Type:** Sidescroller
- **Size:** 32×32px tiles
- **Description:** ancient temple stone floor, cracked holy tiles, Blasphemous cathedral style
- **Status:** Processing

---

## Account 3 (Reserved)
**Purpose:** Additional characters (more enemies, NPCs)
**Token Status:** Not configured yet

### Planned Characters:
- [ ] Ghoul enemy (melee)
- [ ] Cultist enemy (ranged)
- [ ] Village NPC (blacksmith)
- [ ] Village NPC (shopkeeper)

---

## How to Switch Accounts

1. Get new API token from https://api.pixellab.ai/mcp
2. Edit `c:\Users\Administrator.DESKTOP-M0KCUVC\.gemini\antigravity\mcp_config.json`
3. Replace `Authorization` header with new token
4. Restart Cursor IDE to reload MCP config
5. Continue with asset generation

---

## Animation Commands Reference

```
# Queue animation for existing character:
animate_character(
  character_id="<CHARACTER_ID>",
  template_animation_id="<TEMPLATE>",
  animation_name="<NAME>",
  action_description="<DESCRIPTION>"
)

# Available templates for side-scroller:
- breathing-idle (idle)
- running-8-frames (run)
- jumping-1, jumping-2 (jump)
- running-slide (dodge)
- cross-punch (light attack)
- surprise-uppercut (heavy attack)
- falling-back-death (death)
- taking-punch (hurt)
```

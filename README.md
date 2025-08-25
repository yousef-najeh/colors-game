# Candy Game — 2D Platformer (Godot 4.x)

A small, student-built platformer set in a candy world.  
**Goal:** reach the end of the level while maximizing your score.

> Made at An-Najah National University — AI and Games course

![Level preview](docs/screenshots/06-level1-wide.png)

---

## Gameplay

- Loop: run → explore → collect **burgers** for points → avoid **harmful candy** and **enemies** → reach the finish.
- Scoring: burgers **+1**; harmful candy **−1** (never below 0).
- Death/Respawn: touching enemies or falling into hazards respawns the player (start or checkpoint).
- Win: reach the goal with the best score you can.

**Controls** (default):  
`Left/Right` to move, `Space` to jump.

---

## Features

- Two handcrafted levels (Level 1 and Level 2) with increasing difficulty
- Collectibles (burgers), hazards (dangerous sweets), moving/static enemies
- Kill zones and respawn logic
- On-screen score HUD with instant updates
- Windows and Web (HTML5) export ready

---

## Technical Notes (Godot 4.x)

- Engine: **Godot 4.x** (tested on 4.4) — GDScript
- Player: `CharacterBody2D` with tuned gravity and jump timing buffers
- Enemies & Hazards: `Area2D`/`CollisionShape2D` + physics layers
- Score System: a lightweight `Game.gd` updates the HUD (node in group `hud`) and handles death/scene reload
- Scenes: Level1, Level2, Player, Enemies, Collectibles, HUD

**Tip:** If you want score to persist across scene changes, add `Game.gd` as an **Autoload** (Project Settings → Autoload).

---

## Getting Started

1. Install Godot **4.4 (or any 4.x)**.
2. Clone the repository and open the project in Godot.
3. Run the main scene (Level 1) or open and play each level directly.

```bash
git clone https://github.com/<your-user>/<your-repo>.git
cd <your-repo>
# Open with Godot 4.x and press ▶

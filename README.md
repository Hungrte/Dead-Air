# Dead-Air
An experimental horror AI system built in Godot that focuses on creating tense and unpredictable encounters through adaptive behavior rather than scripted events.  Instead of always knowing where the player is, the AI reacts to its surroundings using multiple sensory systems, allowing the player to manipulate its behavior through sound and stealth.

# Adaptive Horror AI
---

## Features

### AI State Machine

* Idle
* Searching
* Chasing
* Attacking

### Adaptive Senses

* Separate hearing and vision systems
* Sense switching with configurable cooldowns
* Suspicion meter that increases when sounds are detected
* Suspicion decay over time

### Dynamic Searching

* Investigates the last known sound location
* Looks around after reaching the investigation point
* Returns to idle if nothing is found

### Chase System

* Gradual acceleration while pursuing the player
* Configurable maximum speed
* Chase timeout after losing sight of the player

### Combat ( Soon )

* Attack state
* Temporary stun after attacking
* Movement locking during attacks

---

## Planned Features

* Raycast-based vision
* Field-of-view detection
* Patrol routes
* Last known player position
* Multiple AI personalities
* Difficulty presets
* Sound occlusion through walls
* Animation state machine
* Save/load support
* Multiplayer compatibility (experimental)

---

## Built With

* Godot 4
* GDScript

---

## Current Status

🚧 Active Development

This project is continuously evolving as I learn more about AI architecture, game programming, and software engineering.

---

## Goals

The goal of this project is to create an AI that feels believable rather than unfair. The player should be able to understand and exploit the monster's behavior through careful observation and strategic use of sound.

Rather than relying on scripted events, the AI makes decisions based on what it can currently hear and see, creating more dynamic and replayable encounters.


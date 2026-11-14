# Good Boy, Come Home

A sideways, Sonic-style platformer about a dog bouncing and climbing a mountain to get back to its owner. Built for the game jam Haven Bengaluru on the theme *"Bounce Back"*.

> Walter and his dog Juno climbed the same peak every autumn. This year a storm hit near the summit and the dog slipped off a ledge. Walter refuses to leave the mountain. The dog has to bounce back before winter closes the pass, and every fall costs it a year of its life.

Made with *Godot 4.3+* (GDScript). All gameplay and visuals are drawn from code in main.gd, using the pixel art in assets/.

---

## Run it

1. Install [Godot 4.3 or newer](https://godotengine.org/download) (the standard build, not .NET).

The first open takes a few seconds while Godot imports the PNGs.

## Controls

| Action | Keys |
|---|---|
| Run | Left key/ Right key or Left / Right |
| Jump (hold for higher) | Space or Up 

Keyboard only.

## How to play

- *Reach the top* at the far right of the level.
- *Years:* you start at age 1. Every death (falling into a pit or touching an enemy) costs one year and sends you back to your last checkpoint. At 12 years the run ends. Older dogs run and jump slightly worse.
- *Porqupines* are meant to be avoided and make you lose a year
- *Mushrooms and tree branches* are springs that launch you high.

### Endings

Your age when you reach the hut decides the ending:

| Age on arrival | Ending |
|---|---|
| 0-3 | *Home at Last*: a joyful reunion |
| 3-9 | *Just in Time*: a bittersweet last night by the stove |
| You hit 12+ | *Out of Years*: Walter finds the collar  |


## Exporting

- *Desktop:* Project > Export, add a Linux, Windows or macOS preset.
- *Web:* Just press play

## Known limitations

- Keyboard only.
- Sounds are simple generated tones, with no recorded audio or real music.

## Credits

Dog sprites, logo and forest background art from google
Created by 
Vineeth Jakin Katti
Aaron Savin Thomas
Sai Nahru Tatavarthi

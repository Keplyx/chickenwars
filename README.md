# Chicken Wars 1.0.2
Counter Strike, but chickens only.

A plugin in which players move like chickens, look like chickens, sound like chickens, BUT, they also have guns.
The goal is simply to kill the enemy team, but as you have very little health and are too slow to evade fire, you must hide with normal chickens scattered across the map.

When you hold your knife, you cannot do damage and are hidden (nobody will see your gun), but as soon as you draw a gun, it will appear at your side, and will become an easy target. To behave like a real chicken, you can make sounds with a command (bind it to a key).
You would think it's easy, because you would just have to kill every chicken and hope you kill a player, but you cannot kill more than one non-player chicken until you kill yourself.

This plugin also modifies the smokes and the decoys: Smokes creates a lot of chickens so you can hide with them, and the decoys creates a chicken with your weapon drawn, to bait the other team.

If the server operator enables it with a cvar, players can choose their own skin and hat with commands, he can also choose the amount of non player chickens to spawn (and more, see convar section)

This plugin is best played in small maps like demolition or arms race, in classic casual or competitive. If you play on these maps, don't forget to set mp_buy_anywhere 1, because they do not have buy-zones. You can also make your own map!

### [See the wiki for more info](https://github.com/Keplyx/chickenwars/wiki)

## Features

   * Player chickens
   * Play chicken sounds
   * Smokes spawns chickens
   * Decoy spawns an armed chicken
   * Chickens can have skins and hats
   * Spawns defined number of chickens in the map
   * Blocks players from killing non-player chickens
   * Hide view model to feel like a real chicken (little buggy with alt+tab and bot controlling, can be re-enabled)
   * Hide radar to help hiding with chickens

## Installation

Simply download chickenwars.smx and place it inside "csgo/addons/sourcemod/plugins/"

## Cvars

See chickenwars.cfg

## Commands

    "cs_play_sound" (Play a sound based on player movement: idle if walking or idle, panic if running)

    If cs_playerstyles "1", players can use:
    "cs_set_skin" (Set player skin)
    "cs_set_hat" (Set player hat)

    Admin only:
    "cs_strip_weapons" (Removes all weapons from a specific player)

## Media

![20170417114527_1](https://cloud.githubusercontent.com/assets/23726131/25240615/93b86fb0-25f3-11e7-81b3-f5cbc9b34b3e.jpg)
![20170417114627_1](https://cloud.githubusercontent.com/assets/23726131/25240660/b1216458-25f3-11e7-8159-e830601399e7.jpg)
![20170417114936_1](https://cloud.githubusercontent.com/assets/23726131/25240671/bb424ace-25f3-11e7-983b-57f50e1cc7d4.jpg)

## Changlelog

* **Version 1.0.2**
  * Removed grenade sounds
  * Forced new syntax
  * Added use of csgocolors.inc
  * User userid for timers
  * Code Cleanup
* **Version 1.0.1**
  * Added a lock rotation feature
  * Added ability to hide player radar with cvar
  * Blocked crouch (not crouch-jump)
  * Fixed player's chicken animation on spawn
  * Improved chicken spawn (based on world origin not on spawns)

### Creator: Keplyx
### Current developers: Keplyx, Zipcore

![chicken wars logo x150](https://cloud.githubusercontent.com/assets/23726131/25303338/cd6c64e2-2750-11e7-8890-daa6a24b3229.png)

### Counter Strike: Global Offensive, but chickens only.

### [Allied Modders Thread](https://forums.alliedmods.net/showthread.php?t=296290)

A plugin in which players move like chickens, look like chickens, sound like chickens, BUT, they also have guns.
The goal is simply to kill the enemy team, but as you have very little health and are too slow to evade fire, you must hide with normal chickens scattered across the map.

When you hold your knife, you cannot do damage and are hidden (nobody will see your gun), but as soon as you **draw a gun, it will appear at your side**, and will become an easy target. To behave like a real chicken, you can make sounds with a menu (show it with the [move right] key).
You would think it's easy, because you would just have to kill every chicken and hope you kill a player, but you **cannot kill more than one non-player** chicken until you kill yourself.

**This plugin also modifies the smokes, the decoys, the molotovs and the he grenades:**
* [Smokes](http://i.imgur.com/czW5vcF.gifv) creates a lot of chickens so you can hide among them.
* [Decoys](http://i.imgur.com/6Z4uDQJ.gifv) creates a chicken with your weapon drawn, to bait the other team.
* [Molotovs](http://i.imgur.com/xyJFF92.gifv) (and incendiaries) turns non-player chickens within range into zombies.
* [He grenades](http://i.imgur.com/qjlB7Wv.gifv) creates a kamikaze chicken which will explode is a player goes near it (including you and your team!).

If the server operator enables it with a cvar, players can choose their own skin and hat with commands, the amount of non player chickens to spawn (and more, see convar section), and the use of a custom buy menu (with custom prices).

This plugin is **best played in small maps like demolition or arms race**, in classic casual or competitive, as they are rather small. You can also make your own map!


### [:globe_with_meridians: See the wiki for more info](https://github.com/Keplyx/chickenwars/wiki)

## Installation

Simply download **[chickenwars.smx](https://github.com/Keplyx/chickenwars/raw/master/chickenwars.smx)** and place it in your server inside "csgo/addons/sourcemod/plugins/".

If you do not own a server yet, I recommend using **[csgosl](https://github.com/lenosisnickerboa/csgosl)**.

## Features

   * Player chickens
   * Play chicken sounds with [move right] key
   * Move forward only (chickens don't walk backwards or sideways)
   * Slow falling speed with [space]
   * Smokes spawns chickens
   * Decoy spawns an armed chicken
   * Molotovs turns chickens into zombies
   * He grenades creates kamikaze chickens
   * Chickens can have skins and hats
   * Spawns defined number of chickens in the map
   * Blocks players from killing non-player chickens
   * Use a custom buy menu to restrict usage of weapon, by pressing [move down] key after spawn (custom prices)
   * Hide view model to feel like a real chicken (little buggy with alt+tab and bot controlling, can be re-enabled)
   * Hide radar to help hiding with chickens
   * FFA mode (play in deathmatch)
   * Customisation through cvars

## [:globe_with_meridians: Incoming Features](https://github.com/Keplyx/chickenwars/issues/1)


## [:globe_with_meridians: Cvars](https://github.com/Keplyx/chickenwars/blob/master/chickenwars.cfg)

## Commands



    If cs_playerstyles "1", players can use:
    "cw_set_skin" (Set player skin)
    "cw_set_hat" (Set player hat)

    Admin only:
    "cw_strip_weapons" (Removes all weapons from a specific player)

## Media

![20170417114527_1](https://cloud.githubusercontent.com/assets/23726131/25240615/93b86fb0-25f3-11e7-81b3-f5cbc9b34b3e.jpg)
![20170417114627_1](https://cloud.githubusercontent.com/assets/23726131/25240660/b1216458-25f3-11e7-8159-e830601399e7.jpg)
![20170417114936_1](https://cloud.githubusercontent.com/assets/23726131/25240671/bb424ace-25f3-11e7-983b-57f50e1cc7d4.jpg)

## [:globe_with_meridians: See More](https://github.com/Keplyx/chickenwars/wiki/Gallery)

## [:globe_with_meridians: Changlelog](https://github.com/Keplyx/chickenwars/blob/master/Changlelog.md)

### Creator: Keplyx
### Current developers: Keplyx, Zipcore

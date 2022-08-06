# Hades Hit Tracker

This mod tracks hits and damage taken, and displays them in the top right corner. It also prints information to the DebugPrint statement.

## Installation

To install this mod, download the latest release from Github, extract it to your `steamapps/common/Hades/Content` folder, and run `modimporter.exe`.

## Dependencies

To use this mod, you must have [ModUtil](https://github.com/SGG-Modding/ModUtil) and [PrintUtil](https://github.com/ellomenop/HadesSpeedrunningModPack/tree/main/PrintUtil) installed. If you download the latest release from Github, these mods will be included.

## Configuration

The HitTracker mod has 4 settings, all pretty self-explanatory.

 - Enabled : if set to `false` the mod will do nothing
 - TrackHits : if set to `false` the mod will not track any hits taken.
 - TrackDamage : if set to `false`, the mod will not track any damage taken.
 - GracePeriodDuration : After getting hit, ignore hits for x seconds.

These settings can all be changed in the `config` section at the top of `HitTracker.lua`

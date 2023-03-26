=================
Hades Hit Tracker
=================

This mod tracks hits and damage taken, and displays them on screen. It is allowed on both the Unmodded and Modded `speedrun leaderboards <https://speedrun.com/hades_ce?h=HitlessDamageless-Hitless__Damageless-Unmodded&x=w20em85d-ylqop678.8104omwl-gnx24w48.9qj364el>`_ and the `Team Hitless leaderboards <https://teamhitless.com/hades>`_.

Installation
============

1. Download the `latest release from Github <https://github.com/Museus/hades-HitTracker/releases>`_.
2. Open your Hades game directory. You can find this by launching Hades, opening Task Manager, finding the Hades process, right-clicking on it, and selecting Open File Location.
3. Unzip the file from Step 1 into the ``.../Hades/Content`` folder. You should now have the standard folders such as Scripts and Game as well as a new folder called Mods.
4. If you are on Windows, run the ``modimporter.exe`` file to install the mods. Otherwise, run the ``modimporter.py`` script.

**Whenever you want to uninstall the mods, simply delete the contents of the Mods folder, and run the ModImporter again.**

Dependencies
============

Hit Tracker relies on the following mods:

- `ModUtil <https://github.com/SGG-Modding/ModUtil>`_: used to wrap in-game functions
- `PrintUtil <https://github.com/Museus/hades-PrintUtil>`_: used to display hits and damage on screen
 
If you download the latest release from Github, these dependencies will be included.

Configuration
=============

To configure HitTracker, open the ``HitTracker.lua`` file in Notepad or another text editor. At the top of the file, there will be a ``config`` section with the following settings available:

Enabled
-------
``true``: enable Hit/Damage Tracking

``false``: the mod will do nothing
  
TrackHits
---------
``true``: track and display Hits taken

``false``: do not track or display Hits taken

TrackDamage
-----------
``true``: track and display Damage taken

``false`` : do not track or display Hits taken

DisplayBiomes
-------------
``true``: display Hits and Damage per-biome as well as Total across run

``false``: only display Total Hits and Damage, not per-biome

BlocksSeparate
--------------
``true``: add an extra line showing how many hits were blocked

``false``: do not add an extra line showing how many hits were blocked

GracePeriodDuration
-------------------
``0+``: After getting hit, ignore hits for x seconds. If 0, do not ignore any hits.

Feedback
========

If you run into any bugs, feel free to `open an issue <https://github.com/Museus/hades-HitTracker/issues>`_!


For more generic feedback, you can email me at ``museus@proton.me`` or ping me on Discord at ``Museus#7777``.
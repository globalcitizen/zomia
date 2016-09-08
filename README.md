# zomia

Roguelike game set in ancient Yunnan: a wild land where the longest and most powerful rivers of Asia emerge from Tibet to flow down through tropics to the world's great oceans. Hemmed in by steep and ancient mountain topography, malarial jungles and hostile neighbouring civilizations, it is a region shattered in to many distinct ethnic and religious groups, each with their own culture and language. Who will unite the peoples of Zomia and bring peace to the land?

## Project background

I twisted my ankle in Vietnam in early August 2016 and decided to use part of the resulting enforced period of immobility to learn me some Lua! A roguelike based on Yunnanese history seemed the obvious project. I don't expect to spend much time on it beyond the current few weeks, so plan to launch an early version of it for the [2016 Annual Roguelike Release Party](http://www.roguebasin.com/index.php?title=2016_ARRP). This gives me approximately nine days to get something playable together. Not a great deal of time... anyway, you can also check out [Zomia's entry on Roguebasin](http://www.roguebasin.com/index.php?title=Zomia).

## Development status

Development began on the 2nd of September, 2016. As of September 8 it is possible to walk around a level, sound and graphics are functional and some back-story is on the way to being generated. There are NPCs you can run in to, they make noises but there is no fighting or interaction yet, and they don't move. There is an awful lot of free audio media prepared as well... almost 1GB so far.

Screenshots will be here shortly.

## How to run

### Get libraries

Zomia relies on quite a few libraries. They have all been placed in this repository as `git submodule` entries, so to get the whole thing working all you have to do is:

```
git checkout --recursive https://github.com/globalcitizen/zomia.git
```

This of course assumes you have `git` and are comfortable with a command line. The command should download everything, and will take awhile. If you check out the code without using recursive mode (ie. without media or libraries), it won't run, but you can tell it to download them afterwards with:

```
git submodule init
git submodule update
```

### Get media

Next, you need to get the music files. To do this:

```
cd music
./download-music
```

Next, you need the audio files. To do this:

```
cd sounds
./download-sounds
```

### Get LÖVE2D

You also need [LÖVE2D](http://love2d.org/), the graphics framework for Lua that the game runs on - v0.10 or later is recommended. Then you're all set! To run the game, change to the base directory and type:

```
love .
```

## Screenshots

### Dungeon

Here is a typical view of a current dungeon level. The whole dungeon is drawn from scratch, no sprites are used. The display is full screen: on my machine that works out to 90 x 56 tiles, which is 1440 x 900 pixels at maximum fullscreen resolution divided by a 16 x 16 pixel tilesize. Doors can be opened and closed.

![Dungeon](https://raw.githubusercontent.com/globalcitizen/zomia/master/screenshots/screenshot-dungeon.jpg)

Here is a brand new field of view output overlay showing working FOV calculcation.

![Field of view](https://raw.githubusercontent.com/globalcitizen/zomia/master/screenshots/screenshot-fov.jpg)

And here is the final FOV implementation showing previously seen tiles, currently seen tiles, and unknown.

![Field of view #2](https://raw.githubusercontent.com/globalcitizen/zomia/master/screenshots/screenshot-fov2.jpg)

### User interface

Here is the inventory screen. As you can see, some work has been done on the generation of human reasonable niceties from hard D&D-style item attribute data.

![Inventory](https://raw.githubusercontent.com/globalcitizen/zomia/master/screenshots/screenshot-inventory.jpg)

There is a list of keyboard commands accessible by pressing 'h', this also shows you about how much is implemented.

![Key Command Help](https://raw.githubusercontent.com/globalcitizen/zomia/master/screenshots/screenshot-help.jpg)

### World generation

This is a separate program I am working on worldgen in. The idea is to procedurally generate a wilderness with general topography, distance and features matching that of ancient Yunnan. This will be used to ensure that every game is different but also similar in a general way, which hopefully should be enough to hang procedural plot features off. Certainly, given the richness of the region's history, this should work. It's low priority right now, however, and the intent right now is to get something out for ARRP2016 which means I am very short on time. Therefore we have a simplified localized worldgen as a placeholder right now.

In the graphic below, the upper river is the Jinshajiang (upper Yangtse), the lower river is the Red River, and the central lake is Erhai.

![World Generation (in Progress)](https://raw.githubusercontent.com/globalcitizen/zomia/master/screenshots/screenshot-worldgen.jpg)


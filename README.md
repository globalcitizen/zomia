# zomia

Roguelike game set in ancient Yunnan: a wild land where the longest and most powerful rivers of Asia emerge from Tibet to flow down through tropics to the world's great oceans. Hemmed in by steep and ancient mountain topography, malarial jungles and hostile neighbouring civilizations, it is a region shattered in to many distinct ethnic and religious groups, each with their own culture and language. Who will unite the peoples of Zomia and bring peace to the land?

## News

### September 2016
* __2016-09-18__ / __v0.0.2 released__: Hooray! This is a the final early version for the [2016 Annual Roguelike Release Party](http://www.roguebasin.com/index.php?title=2016_ARRP). [Get it over here](https://github.com/globalcitizen/zomia/releases/tag/v0.0.2).
* __2016-09-17__ / __v0.0.1 released__: Hooray! This is a very early version for the [2016 Annual Roguelike Release Party](http://www.roguebasin.com/index.php?title=2016_ARRP). Get it on [the releases page](https://github.com/globalcitizen/zomia/releases).

## Project background

I twisted my ankle in Vietnam in early August 2016 and decided to use part of the resulting enforced period of immobility to learn me some Lua! A roguelike based on Yunnanese history seemed the obvious project.  You can also check out [Zomia's entry on Roguebasin](http://www.roguebasin.com/index.php?title=Zomia).

## Development status

Development began on the 2nd of September, 2016. As of September 17 the game is playable and has been released. For more information, take a look at the [issues list](https://github.com/globalcitizen/zomia/issues/) or check out the [development log](https://github.com/globalcitizen/zomia/blob/master/DEVLOG.md).

## How to run

### The easy way

The easiest way to run the game is to download one of the [releases](https://github.com/globalcitizen/zomia/releases).

There are two kinds of releases:
 * Platform-specific releases (Windows, OSX, etc.). These run just like a native application.
 * Love file releases (runs anywhere, but only if you have [Love 0.10.1](https://love2d.org/#download) installed for your system)

With the love file releases, on unix-likes (including OSX), you can execute this from the command-line to start the love file. On graphical systems, you can also just double-click the file.

```
love .
```

### From source (recommended for masochists, puritans and developers only)

Zomia relies on quite a few libraries. They have all been placed in this repository as `git submodule` entries, so to get the whole thing working all you have to do is:

```
git checkout --recursive https://github.com/globalcitizen/zomia.git
```

This of course assumes you have `git` and are comfortable with a command line. The command should download everything, and will take awhile. If you check out the code without using recursive mode (ie. without media or libraries), it won't run, but you can tell it to download them afterwards with:

```
git submodule init
git submodule update
```

Some media is included in the source, other media is not. Currently it is not required but may be later.

To get extra music, do this:

```
cd music
./download-music
```

To get extra audio, do this:

```
cd sounds
./download-sounds
```

## Screenshot

![Dungeon](https://raw.githubusercontent.com/globalcitizen/zomia/master/screenshots/screenshot-dungeon.jpg)

Here is a typical view of a current dungeon level. The whole dungeon is drawn from scratch, no sprites are used. The display is full screen: on my machine that works out to 90 x 56 tiles, which is 1440 x 900 pixels at maximum fullscreen resolution divided by a 16 x 16 pixel tilesize. Doors can be opened and closed.

Note that the dungeon generation is currently under heavy development - I am porting the algorithms from [Brogue](https://sites.google.com/site/broguegame/) as best I can, so hopefully things will be prettier/more walkable/interesting soon.

For screenshots of longer term elements, under development but lying outside of the ARRP 2016 feature set, see [this document](https://github.com/globalcitizen/zomia/blob/master/LONGTERM.md).


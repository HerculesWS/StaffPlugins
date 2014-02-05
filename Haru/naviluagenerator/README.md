Hercules plugin: vimsyntaxgen
=============================

by @MishimaHaruna (Haru)

credits to Yommy for the base version

* * *

Generates a set of `navi_*_krpri.lua` files to be used by the Navigation System
present in recent kRO clients.

Purpose
-------

The purpose of this plugin is to automatically generate the data files used by
the client's Navigation System, so that they're up to date with the current
Hercules scripts.

Configuration
-------------

There are a few known variants of the Navigation LUA files. Configuration
options are provided to generate the variant you want.

### Indentation

The files `navi_link_krpri`, `navi_map_krpri`, `navi_mob_krpri`,
`navi_npc_krpri` may be generated in either compact or long format.

Compact format example:

```
Navi_Link = {
{ "alb_ship", 13350, 200, 99999, "alb_ship_alberta_0", "", 26, 166, "alberta", 170, 168 },
-- ...
}
```

Long format example:

```
Navi_Link = {
	{
		"alb_ship",
		13350,
		200,
		99999,
		"alb_ship_alberta_0",
		"",
		26,
		166,
		"alberta",
		170,
		168
	},
-- ...
}
```

This is simply a visual preference, both variants can be used by any client.

Default is to use the compact format. To change this, comment out the line
`#define COMPACT_OUTPUT` and recompile the plugin.

### Filenames

The filenames used by the Ragexe and RagexeRE clients differ.

Default is to use the Ragexe filenames. To change this, uncomment the line
`#define RAGEXERE`.

### Version

Startign with 2014 clients, there's a slight variation in the `navi_mob_krpri`
file, which now includes the mob spawn amount.

Default is to use the format appropriate for your PACKETVER. If you want to
override the version, uncomment the line `#define CLIENTVER` and edit it to the
desired client version.

How to run it
-------------

- Compile and enable this plugin
- Start your Map Server
- Use the console command `server tools navigationlua` or the @command
  `@createnavigationlua` and wait some minutes (this depends on your server's
  power - an i7-870 computer may need 5+ minutes of full CPU activity). Please
  note that to all online players, the server will appear to be frozen during
  the whole process. Progress information will be displayed on the server
  console.
- You'll find the generated files in the `navigation` folder.

Where to put the generated files
--------------------------------

```
|_ data
  |_ luafiles514
    |_ lua files
      |_ navigation
        |_ navi_link_krpri.lua
        |_ navi_linkdistance_krpri.lua
        |_ navi_map_krpri.lua
        |_ navi_mob_krpri.lua
        |_ navi_npc_krpri.lua
        |_ navi_npcdistance_krpri.lua
```

* * *

- How to Install a Plugin: [Building a Plugin](http://hercules.ws/wiki/HPM#Building_a_plugin)


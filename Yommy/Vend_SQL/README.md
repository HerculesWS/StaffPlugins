Hercules Staff Plugins : Yommy : Vend_Sql
============
Automatically creates a table in your mysql database (and populates it) with all available player/npc shop items,
updates itself every 5 minutes, the data stored is the following:

    `type` tinyint(3) unsigned NOT NULL
    `owner` varchar(23) NOT NULL
	`shop` varchar(79) NOT NULL
	`map` varchar(11) NOT NULL
	`x` smallint(5) unsigned NOT NULL
	`y` smallint(5) unsigned NOT NULL
	`nameid` smallint(6) NOT NULL
	`refine` tinyint(3) unsigned NOT NULL
	`card0` smallint(6) NOT NULL
	`card1` smallint(6) NOT NULL
	`card2` smallint(6) NOT NULL
	`card3` smallint(6) NOT NULL
	`amount` int(10) unsigned NOT NULL
	`price` int(10) unsigned NOT NULL

The plugin will automatically create, update and clear the table, so you have to do nothing.

============
####How to Install a Plugin: [Building a Plugin](http://herc.ws/wiki/HPM#Building_a_plugin)

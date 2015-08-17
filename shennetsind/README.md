Hercules Staff Plugins : @shennetsind Index
============
####How to Install a Plugin: [Building a Plugin](http://herc.ws/wiki/HPM#Building_a_plugin)

Table of Contents
---------
* 1 SkillErrorMessages
* 2 @storeitem

1. SkillErrorMessages
---------
Replaces client-side error messages by custom server-side error messages, for skills.

* 1: Not Enough Spirit Spheres Message

        %d requires a total mind bullets
becomes

        %s requires a total %d spirit spheres
(%s being the skill name, %d the amount of spirit spheres)

2. @storeitem
---------
Implements the @storeitem command, it creates and places items in a any online character storage, very handy for handing out rewards on in-game events.

    @storeitem <item name or ID> <quantity> <refine> <char name>

Designed by Beowulf/Nightroad

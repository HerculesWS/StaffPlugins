Hercules plugin: script_mapquit
===============================

by @MishimaHaruna (Haru)

* * *

Script command to quit the mapserver, returning a chosen exit status to the OS.

Purpose
-------

This command has mainly two purposes of this command:

- Allow automated tests where the mapserver runs some command (timer or
  `OnInit`), and quits afterwards, returning an exit status depending on the
  test results (this can be used by continuous integration bots for example.)
  See [examples/ci_test.txt](examples/ci_test.txt) for an usage example.
- Allow script commands (and by extension, atcommands bound to script commands)
  to restart the server, without having to implement it in the core. See
  [examples/restart.txt](examples/restart.txt) and
  [examples/run.sh](examples/run.sh) for an usage example.

How to run it
-------------

- Compile and enable this plugin
- Start your Map Server
- You can now use `mapquit()` and `mapquit(value)` in your scripts.

* * *

- How to Install a Plugin: [Building a Plugin](http://hercules.ws/wiki/HPM#Building_a_plugin)


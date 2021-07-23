# Wrapper functions for emulating official plugins inside SqMod
SqMod has dropped support for external plugins, however, everything you'll need is **already included** inside the plugin.
With the compatibility layer enabled, you can make scripts written for the official plugin to load inside SqMod.

For other official plugins (SQLite, MySQL, Confloader, INI), these wrapper functions can be used.

<br />

--------------------

<br />

## Loading your scripts
You need to define the scripts you want to compile/execute inside **sqmod.ini**. <br />
Scripts can be loaded from other script files as well.

Either add the following line before you start loading your scripts
```d
dofile <- function(path) { SqCore.LoadScript(true, path); };
```

Or list them all under **Scripts** section of sqmod.ini.

<br />

--------------------

<br />

## Announcing to masterlist
Announcer plugin won't load, but you don't require that. <br />

```d
_Annoucne <- SqUtils.Announcer(60, "http://master.vc-mp.org/announce.php").Run(),
```

If you want to announce to multiple master, simply create more.
```d
_Announcers <-
{
    Official    = SqUtils.Announcer(60, "http://master.vc-mp.org/announce.php"),
    Thijn       = SqUtils.Announcer(60, "http://master.thijn.ovh/")
}

foreach(Announcer in _Announcers)
Announcer.Run();
```
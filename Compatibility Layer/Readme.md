# Wrapper functions for emulating official plugins inside SqMod
SqMod has dropped support for external plugins, however, everything you'll need is **already included** inside the plugin.
With the compatibility layer enabled, you can make scripts written for the official plugin to load inside SqMod.

For other official plugins (SQLite, MySQL, Confloader, INI), these wrapper functions can be used.

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

--------------------

<br />

## Announcing to masterlist
Announcer plugin won't load, but you don't require that. <br />

```d
_Announce <- SqUtils.Announcer(60, "http://master.vc-mp.org/announce.php").Run(),
```

If you want to announce to multiple masterlists, simply create more.
```d
_Announcers <-
{
    Official    = SqUtils.Announcer(60, "http://master.vc-mp.org/announce.php").Run(),
    Thijn       = SqUtils.Announcer(60, "http://master.thijn.ovh/").Run()
}
```

--------------------

<br />

## Notes
SqMod does not port broken code and logic from the official plugin. Some things will still need to be changed.

<br />

- Instance typename are not just "instance" in SqMod. Player instances will have a typename of "SqPlayer", vehicles with "SqVehicle" and so on.

- Returning `false` from events will not disable its functionality. You'll need to use `SqCore.SetState(0)` inside the said event to disable its native functionality.

- You'll need to replace stream constructors `Stream()` with the `Stream` global variable or you can use methods defined in SqMod.

- If using a custom error handler, you'll need to disable SqMod's error handler from sqmod.ini. Although, the recommend course of action will be to not use a custom one when you can bind to console logs.
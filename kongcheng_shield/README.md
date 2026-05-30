# kongcheng_shield

Standalone police shield resource.

Author: kongcheng

## What changed

This version uses the simple riot-shield style implementation:

- networked shield object
- `prop_ballistic_shield`
- video-style left hand/forearm attach
- collision enabled by default
- no custom aim/body positioning layer
- GTA native pistol aim stays untouched, so the gun aims on the right and the shield stays on the left
- prevents vehicle entry while the shield is equipped

## Install

1. Put `kongcheng_shield` into your server `resources` folder.
2. Add this to `server.cfg`:

```cfg
ensure kongcheng_shield
```

3. Add the item to your inventory. The item icon is in `install/icons/police_shield.png`.

## Commands

```text
/shield
/shieldpos bone x y z rx ry rz
```

Default attach data:

```text
/shieldpos 45509 0.35 0.05 -0.1 300.0 180.0 60.0
```

## ox_inventory item example

```lua
['police_shield'] = {
    label = 'Police Shield',
    weight = 250,
    stack = false,
    close = false,
    consume = 0,
    client = {
        event = 'kongcheng_shield:client:toggle'
    }
}
```

## qb-inventory item example

```lua
police_shield = {
    name = 'police_shield',
    label = 'Police Shield',
    weight = 250,
    type = 'item',
    image = 'police_shield.png',
    unique = true,
    useable = true,
    shouldClose = false,
    description = 'Police ballistic shield'
}
```

## Config

- `Config.UseOriginalPPoliceJob`: disabled by default; enable only if you want to call `p_policejob`.
- `Config.Style`: label for the current `video_style` setup.
- `Config.Attach`: shield bone, offset, and rotation.
- `Config.Collision`: keeps shield collision enabled so it can block bullets.
- `Config.PreventVehicleEntry`: prevents entering vehicles while using the shield.
- `Config.ForceUnarmedOnRemove`: optional, disabled by default.

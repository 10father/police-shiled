Config = {}

Config.ItemName = 'police_shield'
Config.Command = 'shield'

Config.UseOriginalPPoliceJob = false

Config.Style = 'video_style'
Config.Model = 'prop_ballistic_shield'

-- Video-style setup: shield rides the left hand/forearm, while GTA keeps the right-hand pistol aim.
Config.Attach = {
    bone = 45509,
    offset = vector3(0.35, 0.05, -0.1),
    rotation = vector3(300.0, 180.0, 60.0)
}

Config.DebugCommand = 'shieldpos'

Config.Collision = true
Config.PreventVehicleEntry = true
Config.ForceUnarmedOnRemove = false

Config.Notify = true
Config.RemoveOnDeath = true
Config.RemoveInVehicle = true

Config.RegisterUsableItem = true
Config.Framework = 'auto' -- auto / qb / qbx / esx / none

Config.Messages = {
    equipped = 'Police shield equipped',
    removed = 'Police shield removed',
    inVehicle = 'You cannot use a police shield in a vehicle',
    modelFailed = 'Failed to load police shield model'
}

local shieldObject = nil
local shieldNetId = nil
local shieldEquipped = false

local function shouldUseOriginalPPoliceJob()
    return Config.UseOriginalPPoliceJob and GetResourceState('p_policejob') == 'started'
end

local function notify(message)
    if not Config.Notify then return end

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, false)
end

local function requestModel(model)
    local modelHash = type(model) == 'number' and model or GetHashKey(model)

    if not IsModelInCdimage(modelHash) or not IsModelValid(modelHash) then
        return nil
    end

    RequestModel(modelHash)

    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(modelHash) do
        Wait(0)

        if GetGameTimer() > timeout then
            return nil
        end
    end

    return modelHash
end

local function currentShieldEntity()
    if shieldNetId then
        local netEntity = NetToObj(shieldNetId)
        if netEntity and DoesEntityExist(netEntity) then
            return netEntity
        end
    end

    if shieldObject and DoesEntityExist(shieldObject) then
        return shieldObject
    end

    return nil
end

local function deleteShield()
    local entity = currentShieldEntity()

    if entity then
        DetachEntity(entity, true, true)
        DeleteEntity(entity)
    end

    shieldObject = nil
    shieldNetId = nil
    shieldEquipped = false

    if Config.ForceUnarmedOnRemove then
        SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true)
    end
end

local function equipShield()
    local ped = PlayerPedId()

    if Config.RemoveInVehicle and IsPedInAnyVehicle(ped, false) then
        notify(Config.Messages.inVehicle)
        return
    end

    local modelHash = requestModel(Config.Model)
    if not modelHash then
        notify(Config.Messages.modelFailed)
        return
    end

    local spawnCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, -5.0)
    local object = CreateObject(modelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, true)

    if not object or not DoesEntityExist(object) then
        SetModelAsNoLongerNeeded(modelHash)
        notify(Config.Messages.modelFailed)
        return
    end

    local netId = ObjToNet(object)

    SetNetworkIdExistsOnAllMachines(netId, true)
    NetworkSetNetworkIdDynamic(netId, true)
    SetNetworkIdCanMigrate(netId, false)
    SetEntityCollision(object, Config.Collision, Config.Collision)
    SetEntityCanBeDamaged(object, false)
    SetEntityAsMissionEntity(object, true, true)

    local attach = Config.Attach
    AttachEntityToEntity(
        object,
        ped,
        GetPedBoneIndex(ped, attach.bone),
        attach.offset.x,
        attach.offset.y,
        attach.offset.z,
        attach.rotation.x,
        attach.rotation.y,
        attach.rotation.z,
        true,
        true,
        true,
        true,
        0,
        true
    )

    shieldObject = object
    shieldNetId = netId
    shieldEquipped = true

    SetModelAsNoLongerNeeded(modelHash)
    notify(Config.Messages.equipped)
end

local function toggleShield()
    if shouldUseOriginalPPoliceJob() then
        TriggerEvent('p_policejob/client/objects/togglePoliceShield')
        return
    end

    if shieldEquipped then
        deleteShield()
        notify(Config.Messages.removed)
        return
    end

    equipShield()
end

RegisterNetEvent('kongcheng_shield:client:toggle', toggleShield)
RegisterNetEvent('kongcheng_shield:client:equip', function()
    if not shieldEquipped then
        equipShield()
    end
end)
RegisterNetEvent('kongcheng_shield:client:remove', function()
    if shieldEquipped then
        deleteShield()
        notify(Config.Messages.removed)
    end
end)

RegisterNetEvent('p_policejob/client/objects/togglePoliceShield', function()
    if shouldUseOriginalPPoliceJob() then return end

    toggleShield()
end)

if Config.Command and Config.Command ~= '' then
    RegisterCommand(Config.Command, function()
        toggleShield()
    end, false)
end

if Config.DebugCommand and Config.DebugCommand ~= '' then
    RegisterCommand(Config.DebugCommand, function(_, args)
        if #args ~= 7 then
            print(('[kongcheng_shield] attach: bone=%s offset=vector3(%.3f, %.3f, %.3f) rotation=vector3(%.3f, %.3f, %.3f)'):format(
                Config.Attach.bone,
                Config.Attach.offset.x,
                Config.Attach.offset.y,
                Config.Attach.offset.z,
                Config.Attach.rotation.x,
                Config.Attach.rotation.y,
                Config.Attach.rotation.z
            ))
            print('[kongcheng_shield] usage: /shieldpos bone x y z rx ry rz')
            return
        end

        local bone = tonumber(args[1])
        local x = tonumber(args[2])
        local y = tonumber(args[3])
        local z = tonumber(args[4])
        local rx = tonumber(args[5])
        local ry = tonumber(args[6])
        local rz = tonumber(args[7])

        if not bone or not x or not y or not z or not rx or not ry or not rz then
            print('[kongcheng_shield] invalid numbers')
            return
        end

        Config.Attach = {
            bone = bone,
            offset = vector3(x, y, z),
            rotation = vector3(rx, ry, rz)
        }

        local entity = currentShieldEntity()
        if entity then
            AttachEntityToEntity(
                entity,
                PlayerPedId(),
                GetPedBoneIndex(PlayerPedId(), bone),
                x,
                y,
                z,
                rx,
                ry,
                rz,
                true,
                true,
                true,
                true,
                0,
                true
            )
        end

        print(('[kongcheng_shield] updated: bone=%s offset=vector3(%.3f, %.3f, %.3f) rotation=vector3(%.3f, %.3f, %.3f)'):format(
            bone, x, y, z, rx, ry, rz
        ))
    end, false)
end

CreateThread(function()
    while true do
        if not shieldEquipped then
            Wait(1000)
        else
            Wait(0)

            local ped = PlayerPedId()

            if Config.PreventVehicleEntry then
                SetPlayerMayNotEnterAnyVehicle(PlayerId())
            end

            if Config.RemoveOnDeath and IsEntityDead(ped) then
                deleteShield()
            elseif Config.RemoveInVehicle and IsPedInAnyVehicle(ped, false) then
                deleteShield()
            elseif not currentShieldEntity() then
                shieldObject = nil
                shieldNetId = nil
                shieldEquipped = false
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        deleteShield()
    end
end)

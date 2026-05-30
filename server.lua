local function toggleShield(playerId)
    TriggerClientEvent('kongcheng_shield:client:toggle', playerId)
end

local function registerQb()
    if GetResourceState('qb-core') ~= 'started' then return false end

    local ok, core = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)

    if not ok or not core then return false end

    core.Functions.CreateUseableItem(Config.ItemName, function(source)
        toggleShield(source)
    end)

    return true
end

local function registerQbx()
    if GetResourceState('qbx_core') ~= 'started' then return false end

    local ok = pcall(function()
        exports.qbx_core:CreateUseableItem(Config.ItemName, function(source)
            toggleShield(source)
        end)
    end)

    return ok
end

local function registerEsx()
    if GetResourceState('es_extended') ~= 'started' then return false end

    local ok, esx = pcall(function()
        return exports.es_extended:getSharedObject()
    end)

    if not ok or not esx then return false end

    esx.RegisterUsableItem(Config.ItemName, function(source)
        toggleShield(source)
    end)

    return true
end

CreateThread(function()
    if not Config.RegisterUsableItem or Config.Framework == 'none' then return end
    if Config.UseOriginalPPoliceJob and GetResourceState('p_policejob') == 'started' then return end

    Wait(1500)

    local framework = Config.Framework
    if framework == 'qb' then
        registerQb()
    elseif framework == 'qbx' then
        registerQbx()
    elseif framework == 'esx' then
        registerEsx()
    elseif framework == 'auto' then
        if registerQb() then return end
        if registerQbx() then return end
        registerEsx()
    end
end)

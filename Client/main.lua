local initialized = false
local playerId = PlayerId()
local serverId = GetPlayerServerId(playerId)

local framework = 'none'
if Config.Framework == 'qb' then
    if GetResourceState('qb-core') == 'started' then
        framework = 'qb'
        QBCore = exports['qb-core']:GetCoreObject()
        DebugLog('QBCore framework detected')
    end
elseif Config.Framework == 'esx' then
    if GetResourceState('es_extended') == 'started' then 
        framework = 'esx'
        ESX = exports['es_extended']:getSharedObject()
        DebugLog('ESX framework detected')
    end
elseif Config.Framework == 'qbox' then
    if GetResourceState('qbx-core') == 'started' then
        framework = 'qbox'
        QBCore = exports['qbx-core']:GetCoreObject()
        DebugLog('QBox framework detected')
    end
elseif Config.Framework == 'vrp' then
    if GetResourceState('vrp') == 'started' then
        framework = 'vrp'
        DebugLog('vRP framework detected')
    end
end

Citizen.CreateThread(function()
    DebugLog('Admin Panel initializing...')
    Wait(1000) 
    
    if Config.Authentication.openKey then
        RegisterKeyMapping(Config.Authentication.openCommand or 'admin', 'Open Admin Panel', 'keyboard', Config.Authentication.openKey)
        DebugLog('Registered key binding: ' .. Config.Authentication.openKey)
    end
    
    initialized = true
    DebugLog('Admin Panel initialized successfully')
    
    AdminNotify('Admin Panel loaded', 'success')
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    DebugLog('Resource started: ' .. resourceName)
    
    Citizen.SetTimeout(3000, function()
        TriggerServerEvent('admin:server:checkPermission', 'helper', function(hasPermission)
            if hasPermission then
                AdminNotify('Admin Panel is available. Type /' .. (Config.Authentication.openCommand or 'admin') .. ' to open', 'info')
            end
        end)
    end)
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    SetNuiFocus(false, false)
    DebugLog('Resource stopped: ' .. resourceName)
end) 
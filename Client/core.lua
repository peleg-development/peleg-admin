Admin = {}
Utils = {}
UI = {}
Teleport = {}
Players = {}
Vehicles = {}
DebugMode = {}

Admin.Panel = {
    isOpen = false,
    isActive = false,
    spectatingPlayer = nil,
    options = {
        ESP = false,
        PlayerNames = false,
        GodMode = false,
        NoClip = false,
        Invisibility = false,
        Bones = false,
        RepairVehicle = false,
        Teleport = false
    }
}

Admin.NoClip = {
    active = false,
    entity = nil,
    speed = 1.0,
    camera = nil
}

Admin.Commands = {
    open = Config.Authentication.openCommand or 'admin',
    noclip = 'noclip',
    legacy = 'ssm'
}

Utils.Framework = {
    name = Config.Framework,
    object = nil,
    isLoaded = false
}

DebugMode.enabled = Config.Debug or false
DebugMode.Log = function(message)
    if not DebugMode.enabled then return end
    print("[ADMIN DEBUG] " .. tostring(message))
end

Admin.Init = function()
    DebugMode.Log('Initializing admin system...')
    
    if Config.Framework == 'qb' and GetResourceState('qb-core') == 'started' then
        Utils.Framework.object = exports['qb-core']:GetCoreObject()
        Utils.Framework.isLoaded = true
        DebugMode.Log('QBCore framework loaded')
    elseif Config.Framework == 'esx' and GetResourceState('es_extended') == 'started' then
        Utils.Framework.object = exports['es_extended']:getSharedObject()
        Utils.Framework.isLoaded = true
        DebugMode.Log('ESX framework loaded')
    elseif Config.Framework == 'qbox' and GetResourceState('qbx-core') == 'started' then
        Utils.Framework.object = exports['qbx-core']:GetCoreObject()
        Utils.Framework.isLoaded = true
        DebugMode.Log('QBox framework loaded')
    elseif Config.Framework == 'vrp' and GetResourceState('vrp') == 'started' then
        Utils.Framework.name = 'vrp'
        Utils.Framework.isLoaded = true
        DebugMode.Log('vRP framework detected')
    else
        Utils.Framework.isLoaded = false
        DebugMode.Log('No compatible framework detected, running in standalone mode')
    end
    
    RegisterCommand(Admin.Commands.open, function()
        Admin.TogglePanel()
    end, false)
    
    RegisterCommand(Admin.Commands.legacy, function()
        Admin.TogglePanel()
    end, false)
    
    UI.ShowNotification('✓ Admin Panel loaded', 'success')
    DebugMode.Log('Admin system initialized')
    
    return true
end 
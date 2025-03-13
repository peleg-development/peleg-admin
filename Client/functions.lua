
function AdminNotify(message, type)
    type = type or 'info'

    SendNUIMessage({ 
        action = 'notification', 
        message = message,
        type = type
    })
    
    if Config.Framework == 'qb' or Config.Framework == 'qbox' then
        if QBCore then
            QBCore.Functions.Notify(message, type)
        else
            exports['qb-core']:Notify(message, type)
        end
    elseif Config.Framework == 'esx' then
        TriggerEvent('esx:showNotification', message)
    elseif Config.Framework == 'vrp' then
        TriggerEvent('chat:addMessage', {args = {'^3ADMIN', message}})
    end
end

function SendNotification(message, type)
    AdminNotify(message, type)
end

function GetCoords()
    return GetEntityCoords(PlayerPedId())
end

function GetHeading()
    return GetEntityHeading(PlayerPedId())
end

function TeleportTo(x, y, z, h)
    local ped = PlayerPedId()
    SetEntityCoords(ped, x, y, z, false, false, false, false)
    
    if h then
        SetEntityHeading(ped, h)
    end
end

function DebugLog(message)
    if Config.Debug then
        print("[ADMIN DEBUG] " .. tostring(message))
    end
end 
UI.ShowNotification = function(message, type)
    type = type or 'info'
    
    SendNUIMessage({ 
        action = 'notification', 
        message = message,
        type = type
    })
    
    if Utils.Framework.isLoaded then
        if Utils.Framework.name == 'qb' or Utils.Framework.name == 'qbox' then
            if Utils.Framework.object then
                Utils.Framework.object.Functions.Notify(message, type)
            else
                exports['qb-core']:Notify(message, type)
            end
        elseif Utils.Framework.name == 'esx' then
            TriggerEvent('esx:showNotification', message)
        elseif Utils.Framework.name == 'vrp' then
            TriggerEvent('chat:addMessage', {args = {'^3ADMIN', message}})
        end
    end
end

Players.GetCoords = function(playerId)
    if playerId then
        return GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerId)))
    end
    return GetEntityCoords(PlayerPedId())
end

Players.GetHeading = function()
    return GetEntityHeading(PlayerPedId())
end

Teleport.ToCoords = function(x, y, z, h)
    local ped = PlayerPedId()
    SetEntityCoords(ped, x, y, z, false, false, false, false)
    
    if h then
        SetEntityHeading(ped, h)
    end
end

Teleport.ToEntity = function(entity)
    local coords = GetEntityCoords(entity)
    Teleport.ToCoords(coords.x, coords.y, coords.z)
end

Teleport.ToPlayer = function(targetId)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))
    if DoesEntityExist(targetPed) then
        Teleport.ToEntity(targetPed)
        UI.ShowNotification("Teleported to player", "success")
        return true
    end
    return false
end

Teleport.ToWaypoint = function()
    local waypointBlip = GetFirstBlipInfoId(8)
    if DoesBlipExist(waypointBlip) then
        local waypointCoords = GetBlipInfoIdCoord(waypointBlip)
        for height = 1, 1000 do
            SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords.x, waypointCoords.y, height + 0.0)
            local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords.x, waypointCoords.y, height + 0.0)
            if foundGround then
                SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords.x, waypointCoords.y, zPos + 0.0)
                UI.ShowNotification("Teleported to waypoint", "success")
                return true
            end
            Citizen.Wait(5)
        end
        UI.ShowNotification("Could not find ground at waypoint", "error")
        return false
    else
        UI.ShowNotification("No waypoint set", "error")
        return false
    end
end

Vehicles.Repair = function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle and DoesEntityExist(vehicle) then
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineOn(vehicle, true, true, false)
        UI.ShowNotification("Vehicle repaired", "success")
        return true
    else
        UI.ShowNotification("You are not in a vehicle", "error")
        return false
    end
end

Players.ToggleGodMode = function(enable)
    local playerPed = PlayerPedId()
    SetEntityInvincible(playerPed, enable)
    UI.ShowNotification("God Mode: " .. (enable and "ON" or "OFF"), enable and "success" or "info")
end

Players.ToggleInvisibility = function(enable)
    local playerPed = PlayerPedId()
    SetEntityVisible(playerPed, not enable, false)
    UI.ShowNotification("Invisibility: " .. (enable and "ON" or "OFF"), enable and "success" or "info")
end

UI.DrawText3D = function(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end 
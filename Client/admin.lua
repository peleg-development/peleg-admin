Admin.TogglePanel = function()
    DebugMode.Log("Admin panel toggle. Current state: " .. tostring(Admin.Panel.isOpen))
    
    if Admin.Panel.isOpen then
        Admin.ClosePanel()
    else
        TriggerServerEvent('admin:server:checkPermission', 'helper')
    end
end

Admin.OpenPanel = function()
    DebugMode.Log("Opening admin panel")
    Admin.Panel.isOpen = true
    Admin.Panel.isActive = true
    
    SendNUIMessage({
        action = 'open'
    })
    SetNuiFocus(true, true)
    
    Admin.RefreshPlayerList()
end

Admin.ClosePanel = function()
    Admin.Panel.isOpen = false
    Admin.Panel.isActive = false
    
    SendNUIMessage({
        action = 'close'
    })
    SetNuiFocus(false, false)
    DebugMode.Log("Admin panel closed")
end

Admin.RefreshPlayerList = function()
    TriggerServerEvent('admin:server:getPlayers')
    Citizen.SetTimeout(100, function()
        TriggerServerEvent('getPlayers')
    end)
    DebugMode.Log("Refreshing player list")
end

Admin.ToggleNoClip = function()
    if Admin.NoClip.active then
        Admin.DisableNoClip()
    else
        Admin.EnableNoClip()
    end
end

Admin.EnableNoClip = function()
    Admin.NoClip.active = true
    Admin.NoClip.entity = GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 and GetVehiclePedIsIn(PlayerPedId(), false) or PlayerPedId()
    
    SetEntityVisible(Admin.NoClip.entity, false, 0)
    SetEntityCollision(Admin.NoClip.entity, false, false)
    FreezeEntityPosition(Admin.NoClip.entity, true)
    SetPlayerInvincible(PlayerId(), true)
    
    UI.ShowNotification('NoClip enabled', 'info')
    
    Citizen.CreateThread(function()
        while Admin.NoClip.active do
            Wait(0)
            local moveSpeed = Admin.NoClip.speed
            
            if IsControlPressed(0, 21) then
                moveSpeed = moveSpeed * 3.0
            end
            if IsControlPressed(0, 36) then
                moveSpeed = moveSpeed * 0.5
            end
            
            local forward, right, up = 0, 0, 0
            
            if IsControlPressed(0, 32) then forward = forward + 1 end
            if IsControlPressed(0, 33) then forward = forward - 1 end
            if IsControlPressed(0, 34) then right = right - 1 end
            if IsControlPressed(0, 35) then right = right + 1 end
            if IsControlPressed(0, 51) then up = up + 1 end
            if IsControlPressed(0, 52) then up = up - 1 end
            
            local camRot = GetGameplayCamRot(2)
            local camPos = GetGameplayCamCoord()
            
            local newPos = camPos + (GetGameplayCamDirection() * forward * moveSpeed)
            newPos = newPos + (GetEntityRight(Admin.NoClip.entity) * right * moveSpeed)
            newPos = newPos + (vector3(0, 0, 1) * up * moveSpeed)
            
            SetEntityCoords(Admin.NoClip.entity, newPos.x, newPos.y, newPos.z, true, true, true, false)
            SetEntityHeading(Admin.NoClip.entity, camRot.z)
        end
    end)
end

Admin.DisableNoClip = function()
    Admin.NoClip.active = false
    
    local ped = PlayerPedId()
    SetEntityVisible(ped, true, 0)
    SetEntityCollision(ped, true, true)
    FreezeEntityPosition(ped, false)
    SetPlayerInvincible(PlayerId(), false)
    
    UI.ShowNotification('NoClip disabled', 'info')
end

Admin.Spectate = function(playerId)
    Admin.Panel.spectatingPlayer = playerId
    local targetPed = GetPlayerPed(GetPlayerFromServerId(playerId))
    
    if DoesEntityExist(targetPed) then
        local playerPed = PlayerPedId()
        local targetCoords = GetEntityCoords(targetPed)

        RequestCollisionAtCoord(targetCoords.x, targetCoords.y, targetCoords.z)
        NetworkSetInSpectatorMode(true, targetPed)
        Admin.isSpectating = true
            
        UI.ShowNotification("Spectating player " .. playerId .. ". Press BACKSPACE to exit.")
        
        Citizen.CreateThread(function()
            while Admin.isSpectating and Admin.Panel.spectatingPlayer == playerId do
                Citizen.Wait(0)
                if IsControlJustReleased(0, 177) then -- 177 = Backspace
                    NetworkSetInSpectatorMode(false, playerPed)
                    Admin.isSpectating = false
                    Admin.Panel.spectatingPlayer = nil
                    UI.ShowNotification("Exited spectating mode.")
                    break
                end
            end
        end)
        
        return true
    end
    
    return false
end

Admin.ToggleOption = function(option, enabled)
    Admin.Panel.options[option] = enabled
    DebugMode.Log("Toggle option: " .. option .. " = " .. tostring(enabled))
    
    if option == "ESP" then
        Visuals.ToggleESP(enabled)
    elseif option == "PlayerNames" then
        Visuals.TogglePlayerNames(enabled)
    elseif option == "GodMode" then
        Players.ToggleGodMode(enabled)
    elseif option == "NoClip" then
        Admin.ToggleNoClip()
    elseif option == "Invisibility" then
        Players.ToggleInvisibility(enabled)
    elseif option == "Bones" then
        Visuals.ToggleBones(enabled)
    elseif option == "Repair Vehicle" and enabled then
        Vehicles.Repair()
    elseif option == "Teleport" and enabled then
        Teleport.ToWaypoint()
    end
end

Admin.SendNotification = function(message, type)
    UI.ShowNotification(message, type)
end 
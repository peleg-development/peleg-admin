local QBCore = exports['qb-core']:GetCoreObject()

local adminPanelOpen = false
local adminPanelActive = false
local spectatingPlayer = nil

local playerOptions = {
    ESP = false,
    PlayerNames = false,
    GodMode = false,
    NoClip = false,
    Invisibility = false,
    Bones = false,
    RepairVehicle = false,
    Teleport = false
}

local isSpectating = false
local isNoClip = false
local isCuffed = false
local isJailed = false

RegisterCommand(Config.Authentication.openCommand or 'admin', function()
    DebugLog("Admin command triggered. Current state: " .. tostring(adminPanelOpen))
    
    if adminPanelOpen then
        CloseAdminPanel()
    else
        TriggerServerEvent('admin:server:checkPermission', 'helper')
    end
end, false)

-- Command Replacement for secureserve
RegisterCommand('ssm', function()
    ExecuteCommand(Config.Authentication.openCommand or 'admin')
end, false)

function CloseAdminPanel()
    adminPanelOpen = false
    SendNUIMessage({
        action = 'close'
    })
    SetNuiFocus(false, false)
    DebugLog("Admin panel closed")
end

function OpenAdminPanel()
    DebugLog("Opening admin panel")
    adminPanelOpen = true
    adminPanelActive = true
    
    SendNUIMessage({
        action = 'open'
    })
    SetNuiFocus(true, true)
    
    RefreshPlayerList()
end

function RefreshPlayerList()
    TriggerServerEvent('admin:server:getPlayers')
    Citizen.SetTimeout(100, function()
        TriggerServerEvent('getPlayers')
    end)
    DebugLog("Refreshing player list")
end

-- Admin open menu event handler
RegisterNetEvent('admin:client:openMenu')
AddEventHandler('admin:client:openMenu', function()
    OpenAdminPanel()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    
    SetNuiFocus(false, false)
    adminPanelOpen = false
end)

RegisterNUICallback('getPlayers', function(data, cb)
    RefreshPlayerList()
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    CloseAdminPanel()
    cb('ok')
end)

RegisterNUICallback('closeMenu', function(data, cb)
    CloseAdminPanel()
    cb('ok')
end)

local noClipEntity = nil
local noClipSpeed = 1.0
local noClipCam = nil

function ToggleNoClip()
    if isNoClip then
        isNoClip = false
        
        local ped = PlayerPedId()
        SetEntityVisible(ped, true, 0)
        SetEntityCollision(ped, true, true)
        FreezeEntityPosition(ped, false)
        SetPlayerInvincible(PlayerId(), false)
        
        AdminNotify('NoClip disabled', 'info')
    else
        isNoClip = true
        noClipEntity = GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 and GetVehiclePedIsIn(PlayerPedId(), false) or PlayerPedId()
        
        SetEntityVisible(noClipEntity, false, 0)
        SetEntityCollision(noClipEntity, false, false)
        FreezeEntityPosition(noClipEntity, true)
        SetPlayerInvincible(PlayerId(), true)
        
        AdminNotify('NoClip enabled', 'info')
        
        Citizen.CreateThread(function()
            while isNoClip do
                Wait(0)
                local moveSpeed = noClipSpeed
                
                if IsControlPressed(0, 21) then -- Left Shift
                    moveSpeed = moveSpeed * 3.0
                end
                if IsControlPressed(0, 36) then -- Left Ctrl
                    moveSpeed = moveSpeed * 0.5
                end
                
                local forward = 0
                local right = 0
                local up = 0
                
                -- Forward/Backward
                if IsControlPressed(0, 32) then -- W
                    forward = forward + 1
                end
                if IsControlPressed(0, 33) then -- S
                    forward = forward - 1
                end
                
                -- Left/Right
                if IsControlPressed(0, 34) then -- A
                    right = right - 1
                end
                if IsControlPressed(0, 35) then -- D
                    right = right + 1
                end
                
                -- Up/Down
                if IsControlPressed(0, 51) then -- E
                    up = up + 1
                end
                if IsControlPressed(0, 52) then -- Q
                    up = up - 1
                end
                
                local camRot = GetGameplayCamRot(2)
                local camPos = GetGameplayCamCoord()
                
                local newPos = camPos + (GetGameplayCamDirection() * forward * moveSpeed)
                newPos = newPos + (GetEntityRight(noClipEntity) * right * moveSpeed)
                newPos = newPos + (vector3(0, 0, 1) * up * moveSpeed)
                
                SetEntityCoords(noClipEntity, newPos.x, newPos.y, newPos.z, true, true, true, false)
                SetEntityHeading(noClipEntity, camRot.z)
            end
        end)
    end
end

RegisterNUICallback('toggleNoClip', function(data, cb)
    ToggleNoClip()
    cb({ status = isNoClip })
end)

RegisterNUICallback('toggleNoclip', function(data, cb)
    ToggleNoClip()
    cb({ status = isNoClip })
end)

RegisterCommand('noclip', function()
    TriggerServerEvent('admin:server:checkPermission', 'mod', function(hasPermission)
        if hasPermission then
            ToggleNoClip()
        else
            AdminNotify('You don\'t have permission to use NoClip', 'error')
        end
    end)
end, false)

RegisterNetEvent('admin:client:toggleNoClip', function()
    ToggleNoClip()
end)

RegisterNetEvent('admin:client:permissionResult', function(hasPermission, requiredLevel, callbackName)
    if hasPermission then
        if callbackName then
            DebugMode.Log("Permission granted for: " .. requiredLevel)
            if _G[callbackName] then
                _G[callbackName]()
            end
        else
            OpenAdminPanel()
        end
    else
        UI.ShowNotification('You don\'t have permission to access this feature', 'error')
    end
end)

RegisterNetEvent('admin:client:receivePlayers', function(players)
    if players and type(players) == 'table' then
        DebugMode.Log("Received players list with " .. #players .. " players")
        
    SendNUIMessage({
        action = 'setPlayers',
        players = players
    })
        
        SendNUIMessage({
            action = 'players',
            players = players
        })
    else
        DebugMode.Log("Error: Received invalid players data")
    end
end)

RegisterNetEvent('receivePlayers', function(playerList)
    if playerList and type(playerList) == 'table' then
        DebugMode.Log("Received legacy players list with " .. #playerList .. " players")
        
        SendNUIMessage({
            action = 'setPlayers',
            players = playerList
        })
        
        SendNUIMessage({
            action = 'players',
            players = playerList
        })
    else
        DebugMode.Log("Error: Received invalid legacy players data")
    end
end)

RegisterNUICallback('teleportToPlayer', function(data, cb)
    TriggerServerEvent('admin:server:gotoPlayer', data.playerId)
    cb('ok')
end)

RegisterNUICallback('bringPlayer', function(data, cb)
    TriggerServerEvent('admin:server:bringPlayer', data.playerId)
    cb('ok')
end)

RegisterNUICallback('spectatePlayer', function(data, cb)
    local playerId = data.playerId
    spectatingPlayer = playerId
    local targetPed = GetPlayerPed(GetPlayerFromServerId(playerId))
    
    if DoesEntityExist(targetPed) then
    local playerPed = PlayerPedId()
        local targetCoords = GetEntityCoords(targetPed)

        RequestCollisionAtCoord(targetCoords.x, targetCoords.y, targetCoords.z)
            NetworkSetInSpectatorMode(true, targetPed)
            isSpectating = true
            
        AdminNotify("Spectating player " .. playerId .. ". Press BACKSPACE to exit.")
        
        Citizen.CreateThread(function()
            while isSpectating and spectatingPlayer == playerId do
                Citizen.Wait(0)
                if IsControlJustReleased(0, 177) then -- 177 = Backspace
                    NetworkSetInSpectatorMode(false, playerPed)
                    isSpectating = false
                    spectatingPlayer = nil
                    AdminNotify("Exited spectating mode.")
                    break
                end
            end
        end)

        cb({ success = true })
    else
        cb({ success = false })
    end
end)

RegisterNUICallback('toggleOptiona', function(data, cb)
    Admin.ToggleOption(data.option, data.enabled)
    cb('ok')
end)

RegisterNUICallback('kickPlayer', function(data, cb)
    local playerId = data.playerId
    local reason = data.reason or "Kicked by admin"
    TriggerServerEvent('admin:server:kickPlayer', playerId, reason)
    cb('ok')
end)

RegisterNUICallback('banPlayer', function(data, cb)
    local playerId = data.playerId
    local reason = data.reason or "Banned by admin"
    local duration = data.duration or "0"
    TriggerServerEvent('admin:server:banPlayer', playerId, reason, duration)
    cb('ok')
end)

RegisterNUICallback('unbanPlayer', function(data, cb)
    local banId = data.banId
    TriggerServerEvent('unbanPlayer', banId)
    cb('ok')
end)

RegisterNUICallback("clearAllEntities", function(data, cb)
    TriggerServerEvent('anticheat:clearAllEntities')
    cb('ok')
end)

RegisterNUICallback('screenshotPlayer', function(data, cb)
    local playerId = data.playerId
    TriggerServerEvent('SecureServe:screenshotPlayer', playerId)
    
    if exports['screenshot-basic'] then
        exports['screenshot-basic']:requestScreenshotUpload(Config.Webhooks.screenshots or "", 'files[]', function(data)
            local resp = json.decode(data)
            if resp and resp.attachments and resp.attachments[1] and resp.attachments[1].proxy_url then
                local screenshotUrl = resp.attachments[1].proxy_url
    SendNUIMessage({
        action = 'displayScreenshot',
        imageUrl = screenshotUrl
    })
            else
                SendNUIMessage({
                    action = 'displayScreenshot',
                    imageUrl = "https://media.discordapp.net/attachments/1234504751173865595/1237372961263190106/screenshot.jpg?ex=663b68df&is=663a175f&hm=52ec8f2d1e6e012e7a8282674b7decbd32344d85ba57577b12a136d34469ee9a&=&format=webp&width=810&height=456"
                })
            end
        end)
    end
    
    cb('ok')
end)

RegisterNUICallback("getDashboardStats", function(data, cb)
    TriggerServerEvent("secureServe:requestStats")
    cb("ok")
end)

RegisterNetEvent("secureServe:returnStats")
AddEventHandler("secureServe:returnStats", function(stats)
    SendNUIMessage({
        action = "dashboardStats",
        totalPlayers = stats.totalPlayers,
        activeCheaters = stats.activeCheaters,
        serverUptime = stats.serverUptime,
        peakPlayers = stats.peakPlayers
    })
end)

RegisterNUICallback('executeServerOption', function(data, cb)
    if data.action == 'restart' then
        TriggerServerEvent('executeServerOption:restartServer')
    end
    cb('ok')
end)

RegisterNetEvent('admin:client:receiveNotification', function(message, type)
    UI.ShowNotification(message, type)
end)

RegisterNetEvent('anticheat:notify')
AddEventHandler('anticheat:notify', function(message)
    UI.ShowNotification(message)
end)

function DrawText3D(x, y, z, text)
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

function ToggleESP(enable)
    if enable then
        Citizen.CreateThread(function()
            while playerOptions.ESP do
                Citizen.Wait(0)
                local PlayerList = GetActivePlayers()
                for i = 1, #PlayerList do
                    local curplayerped = GetPlayerPed(PlayerList[i])
                    local bone = GetEntityBoneIndexByName(curplayerped, "SKEL_HEAD")
                    local x, y, z = table.unpack(GetPedBoneCoords(curplayerped, bone, 0.0, 0.0, 0.0))
                    local px, py, pz = table.unpack(GetGameplayCamCoord())

                    if GetDistanceBetweenCoords(x, y, z, px, py, pz, true) < 300 + 0.0 then
                        if (curplayerped ~= PlayerPedId() or true) and IsEntityOnScreen(curplayerped) then
                            z = z + 0.9
                            local Distance = GetDistanceBetweenCoords(x, y, z, px, py, pz, true) * 0.002 / 2
                            if Distance < 0.0042 then
                                Distance = 0.0042
                            end

                            local color = { r = 255, g = 255, b = 255 }
                            local retval, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
                            local width = 0.00045
                            local height = 0.0023

                            DrawRect(_x, _y, width / Distance, 0.0015, color.r, color.g, color.b, 200)
                            DrawRect(_x, _y + height / Distance, width / Distance, 0.0015, color.r, color.g, color.b, 200)
                            DrawRect(_x + width / 2 / Distance, _y + height / 2 / Distance, 0.001, height / Distance,
                                color.r, color.g, color.b, 200)
                            DrawRect(_x - width / 2 / Distance, _y + height / 2 / Distance, 0.001, height / Distance,
                                color.r, color.g, color.b, 200)
                            
                            local health = GetEntityHealth(curplayerped)
                            if health > 200 then
                                health = 200
                            end

                            DrawRect(_x - 0.00028 / Distance, _y + height / 2 / Distance, 0.0016 / Distance * 0.015,
                                height / Distance, 0, 0, 0, 200)
                            DrawRect(_x - 0.00028 / Distance,
                                _y + height / Distance - GetEntityHealth(curplayerped) / 175000 / Distance,
                                0.0016 / Distance * 0.015, GetEntityHealth(curplayerped) / 87500 / Distance, 0, 255, 0,
                                200)
                            DrawRect(_x - 0.00033 / Distance, _y + height / 2 / Distance, 0.0016 / Distance * 0.015,
                                height / Distance, 0, 0, 0, 200)

                            DrawRect(_x - 0.00033 / Distance,
                                _y + height / Distance - GetPedArmour(curplayerped) / 87500 / Distance,
                                0.0016 / Distance * 0.015, GetPedArmour(curplayerped) / 43750 / Distance, 0, 77, 166, 255)
                        end
                    end
                end
            end
        end)
    end
end

function TogglePlayerNames(enable)
    if enable then
        Citizen.CreateThread(function()
            while playerOptions.PlayerNames do
                Citizen.Wait(0)
                local PlayerList = GetActivePlayers()
                local x2, y2, z2 = table.unpack(GetEntityCoords(PlayerPedId()))
                for i = 1, #PlayerList do
                    local curplayerped = GetPlayerPed(PlayerList[i])
                    local x1, y1, z1 = table.unpack(GetEntityCoords(curplayerped))
                    local talking = "~s~[~y~TALKING~s~]"
                    local dist = math.floor(GetDistanceBetweenCoords(x2, y2, z2, x1, y1, z1, true) + 0.5)
                    if not NetworkIsPlayerTalking(PlayerList[i]) then talking = "" else talking = talking end
                    local bone = GetEntityBoneIndexByName(curplayerped, "SKEL_HEAD")
                    local x, y, z = table.unpack(GetPedBoneCoords(curplayerped, bone, 0.0, 0.0, 0.0))
                    if dist < 3000 then
                        DrawText3D(x, y, z + 0.9,
                            ("%s ~s~[~w~%s~s~] ~w~%s~s~"):format(talking, GetPlayerServerId(PlayerList[i]),
                                GetPlayerName(PlayerList[i])))
                        DrawText3D(x, y, z - 1, ("%sm"):format(dist))
                    end
                end
            end
        end)
    end
end

function ToggleGodMode(enable)
    local playerPed = PlayerPedId()
    SetEntityInvincible(playerPed, enable)
    AdminNotify("God Mode: " .. (enable and "ON" or "OFF"))
end

function ToggleInvisibility(enable)
    local playerPed = PlayerPedId()
    SetEntityVisible(playerPed, not enable, false)
    AdminNotify("Invisibility: " .. (enable and "ON" or "OFF"))
end

function GetPedBoneCoordsF(ped, boneId)
    local cam = GetFinalRenderedCamCoord()
    local ret, coords, shape = GetShapeTestResult(
        StartShapeTestRay(
            vector3(cam), vector3(GetPedBoneCoords(ped, 0x0)), -1
        )
    )
    if coords then
        a = Vdist(cam, shape) / Vdist(cam, GetPedBoneCoords(ped, 0x0))
    else
        a = 0.83
    end
    if a > 1 then
        a = 0.83
    end
    if ret then
        return (((GetPedBoneCoords(ped, boneId) - cam) * ((a) * 0.83)) + cam)
    end
end

function ToggleBones(enable)
    if enable then
        Citizen.CreateThread(function()
            while playerOptions.Bones do
                Citizen.Wait(0)
                for k, v in pairs(GetActivePlayers()) do
                    local ped = GetPlayerPed(v)
                    if GetDistanceBetweenCoords(GetEntityCoords(ped), GetEntityCoords(PlayerPedId()), true) < 300 + 0.0 and (ped ~= PlayerPedId() or true) then
                        DrawLine(GetPedBoneCoordsF(ped, 31086), GetPedBoneCoordsF(ped, 0x9995), 255, 255, 255, 255)
                        DrawLine(GetPedBoneCoordsF(ped, 0x9995), GetPedBoneCoordsF(ped, 0xE0FD), 255, 255, 255, 255)
                        DrawLine(GetPedBoneCoordsF(ped, 0x5C57), GetPedBoneCoordsF(ped, 0xE0FD), 255, 255, 255, 255)
                        DrawLine(GetPedBoneCoordsF(ped, 0x192A), GetPedBoneCoordsF(ped, 0xE0FD), 255, 255, 255, 255)
                        DrawLine(GetPedBoneCoordsF(ped, 0x3FCF), GetPedBoneCoordsF(ped, 0x192A), 255, 255, 255, 255)
                        DrawLine(GetPedBoneCoordsF(ped, 0xCC4D), GetPedBoneCoordsF(ped, 0x3FCF), 255, 255, 255, 255)
                        DrawLine(GetPedBoneCoordsF(ped, 0xB3FE), GetPedBoneCoordsF(ped, 0x5C57), 255, 255, 255, 255)
                        DrawLine(GetPedBoneCoordsF(ped, 0xB3FE), GetPedBoneCoordsF(ped, 0x3779), 255, 255, 255, 255)
                        DrawLine(GetPedBoneCoordsF(ped, 0x9995), GetPedBoneCoordsF(ped, 0xB1C5), 255, 255, 255, 255)
                        DrawLine(GetPedBoneCoordsF(ped, 0xB1C5), GetPedBoneCoordsF(ped, 0xEEEB), 255, 255, 255, 255)
                        DrawLine(GetPedBoneCoordsF(ped, 0xEEEB), GetPedBoneCoordsF(ped, 0x49D9), 255, 255, 255, 255)
                        DrawLine(GetPedBoneCoordsF(ped, 0x9995), GetPedBoneCoordsF(ped, 0x9D4D), 255, 255, 255, 255)
                        DrawLine(GetPedBoneCoordsF(ped, 0x9D4D), GetPedBoneCoordsF(ped, 0x6E5C), 255, 255, 255, 255)
                        DrawLine(GetPedBoneCoordsF(ped, 0x6E5C), GetPedBoneCoordsF(ped, 0xDEAD), 255, 255, 255, 255)
                    end
                end
            end
        end)
    end
end

function RepairVehicle()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle then
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineOn(vehicle, true, true, false)
        AdminNotify("Vehicle repaired")
    else
        AdminNotify("You are not in a vehicle")
    end
end

function TeleportToWaypoint()
    local waypointBlip = GetFirstBlipInfoId(8)
    if DoesBlipExist(waypointBlip) then
        local waypointCoords = GetBlipInfoIdCoord(waypointBlip)
        for height = 1, 1000 do
            SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords.x, waypointCoords.y, height + 0.0)
            local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords.x, waypointCoords.y, height + 0.0)
            if foundGround then
                SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords.x, waypointCoords.y, zPos + 0.0)
                AdminNotify("Teleported to waypoint")
                break
            end
            Citizen.Wait(5)
        end
    else
        AdminNotify("No waypoint set")
    end
end

RegisterNetEvent('admin:client:gotoPlayer', function(coords)
    if coords then
        Teleport.ToCoords(coords.x, coords.y, coords.z)
        UI.ShowNotification("Teleported to player", "success")
    end
end)

RegisterNetEvent('admin:client:bringPlayer', function(adminCoords)
    if adminCoords then
        Teleport.ToCoords(adminCoords.x, adminCoords.y, adminCoords.z)
        UI.ShowNotification("You were teleported to an admin", "info")
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    DebugMode.Log('Resource started: ' .. resourceName)
    
    Citizen.SetTimeout(3000, function()
        TriggerServerEvent('admin:server:checkPermission', 'helper', function(hasPermission)
            if hasPermission then
                UI.ShowNotification('Admin Panel is available. Type /' .. Admin.Commands.open .. ' to open', 'info')
            end
        end)
    end)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    SetNuiFocus(false, false)
    DebugMode.Log('Resource stopped: ' .. resourceName)
end)

Citizen.CreateThread(function()
    Wait(500)
    Admin.Init()
end)

local QBCore = nil
if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject() 
end


local PermissionLevels = Config.PermissionLevels

function HasPermission(source, requiredLevel)
    local minLevel = requiredLevel or Config.Authentication.minimumGrade
    local hasPermission = false
    
    if Config.Authentication.useAcePerms then
        hasPermission = IsPlayerAceAllowed(source, Config.Authentication.acePermission)
        
        print(string.format("[PERMISSION DEBUG] Player: %s, UseACE: yes, HasACE: %s", 
            GetPlayerName(source), hasPermission))
        
        return hasPermission
    end
    
    if Bridge and Bridge.HasPermission then
        hasPermission = Bridge.HasPermission(source, minLevel)
        
        print(string.format("[PERMISSION DEBUG] Player: %s, RequiredLevel: %s, Bridge: %s", 
            GetPlayerName(source), minLevel, hasPermission))
        
        if hasPermission ~= nil then
            return hasPermission
        end
    end
    
    if Config.Authentication.fallbackToAce then
        hasPermission = IsPlayerAceAllowed(source, Config.Authentication.acePermission)
        
        print(string.format("[PERMISSION DEBUG] Player: %s, FallbackToACE: yes, HasACE: %s", 
            GetPlayerName(source), hasPermission))
        
        return hasPermission
    end
    
    print(string.format("^1[ERROR] Permission check failed for player %s^7", GetPlayerName(source)))
    return false
end

function IsAdmin(source)
    return Bridge.HasPermission(source, 'admin')
end

RegisterNetEvent('admin:server:checkPermission', function(requiredLevel, callback)
    local src = source
    local hasPermission = HasPermission(src, requiredLevel or 'helper')
    
    if not callback then
        if hasPermission then
            TriggerClientEvent('admin:client:openMenu', src)
        else
            TriggerClientEvent('admin:client:receiveNotification', src, 'You don\'t have permission to access the admin panel', 'error')
            print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to open admin panel without permission^7")
        end
    else
        TriggerClientEvent('admin:client:permissionResult', src, hasPermission, requiredLevel, callback)
    end
end)

RegisterNetEvent('anticheat:toggleOption', function(option, enabled)
    local _source = source
    
    if not HasPermission(_source, 'mod') then
        print("^1[WARN] Player " .. GetPlayerName(_source) .. " tried to toggle option without permission^7")
        return
    end
    
    if enabled then
        TriggerClientEvent('anticheat:notify', _source, option .. " enabled")
    else
        TriggerClientEvent('anticheat:notify', _source, option .. " disabled")
    end
end)

RegisterNetEvent('anticheat:clearAllEntities', function()
    local _source = source
    
    if not HasPermission(_source, 'admin') then
        print("^1[WARN] Player " .. GetPlayerName(_source) .. " tried to clear entities without permission^7")
        return
    end
    
    for _, obj in pairs(GetAllObjects()) do
        DeleteEntity(obj)
    end
    for _, ped in pairs(GetAllPeds()) do
        if not IsPedAPlayer(ped) then
            DeleteEntity(ped)
        end
    end
    for _, veh in pairs(GetAllVehicles()) do
        DeleteEntity(veh)
    end
    
    TriggerClientEvent('anticheat:notify', _source, "All entities cleared")
end)

local function loadBans()
    return Bridge.LoadBans()
end

local function saveBans(bans)
    return true
end

RegisterNetEvent('unbanPlayer', function(banId)
    local src = source
    
    if not HasPermission(src, 'admin') then
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to unban without permission^7")
        return
    end
    
    local bans = loadBans()
    for i, ban in ipairs(bans) do
        if ban.id == banId then
            -- Remove the ban from database
            MySQL.Async.execute('DELETE FROM bans WHERE id = @id', {['@id'] = banId})
            TriggerClientEvent('anticheat:notify', src, 'Player unbanned successfully')
            break
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        loadBans()
        print("^2[INFO] Admin Panel loaded successfully^7")
        
        Citizen.CreateThread(function()
            Citizen.Wait(2000) 
            
            print("^3[DEBUG] Permission Levels Configuration:^7")
            for level, value in pairs(Config.PermissionLevels) do
                print("^3[DEBUG] Level: " .. level .. " = " .. value .. "^7")
            end
            
            local minGrade = Config.Authentication.minimumGrade
            if Config.PermissionLevels[minGrade] == nil then
                print("^1[ERROR] Minimum grade '" .. minGrade .. "' is not defined in Config.PermissionLevels^7")
                print("^1[ERROR] This will prevent the admin panel from working properly^7")
            else
                print("^2[INFO] Minimum grade '" .. minGrade .. "' is properly configured^7")
            end
            
            print("^2[INFO] Admin Panel permission system test completed^7")
        end)
    end
end)

function GetRealPlayers()
    local players = {}
    
    if QBCore then
        local qbPlayers = QBCore.Functions.GetQBPlayers()
        if qbPlayers and type(qbPlayers) == 'table' then
            for _, player in pairs(qbPlayers) do
                if player and player.PlayerData then
                    table.insert(players, {
                        source = player.PlayerData.source,
                        id = player.PlayerData.source,
                        name = player.PlayerData.name or GetPlayerName(player.PlayerData.source),
                        ping = GetPlayerPing(player.PlayerData.source),
                        job = player.PlayerData.job and player.PlayerData.job.name or 'unknown',
                        grade = player.PlayerData.job and player.PlayerData.job.grade.name or '0'
                    })
                end
            end
        end
    end
    
    if #players == 0 and Bridge and Bridge.GetAllPlayers and type(Bridge.GetAllPlayers) == 'function' then
        local bridgePlayers = Bridge.GetAllPlayers()
        if bridgePlayers and type(bridgePlayers) == 'table' and #bridgePlayers > 0 then
            for _, player in ipairs(bridgePlayers) do
                if player.source then
                    table.insert(players, {
                        source = player.source,
                        id = player.source,
                        name = player.name or GetPlayerName(player.source),
                        ping = GetPlayerPing(player.source)
                    })
                end
            end
        end
    end
    
    if #players == 0 then
        for _, playerId in ipairs(GetPlayers()) do
            local id = tonumber(playerId)
            if id then
                local playerInfo = {
                    source = id,
                    id = id,
                    name = GetPlayerName(id),
                    ping = GetPlayerPing(id)
                }
                
                if not playerInfo.name or playerInfo.name == "" then
                    playerInfo.name = "Player_" .. id
                end
                
                table.insert(players, playerInfo)
            end
        end
    end
    
    print("^2[INFO] Found " .. #players .. " players^7")
    if #players == 0 then
        print("^1[ERROR] Failed to find any players. This is likely a serious problem.^7")
    else
        local sample = math.min(3, #players)
        for i = 1, sample do
            print(string.format("^3[DEBUG] Player sample %d: ID=%s, Name=%s^7", 
                i, players[i].id, players[i].name))
        end
    end
    
    return players
end

RegisterNetEvent('admin:server:getPlayers', function()
    local src = source
    
    if not HasPermission(src, 'helper') then
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to get player list without permission^7")
        TriggerClientEvent('admin:client:receiveNotification', src, 'You don\'t have permission to view player list', 'error')
        return
    end
    
    local players = GetRealPlayers()
    TriggerClientEvent('admin:client:receivePlayers', src, players)
end)

RegisterNetEvent('getPlayers', function()
    local src = source
    
    if not HasPermission(src, 'helper') then
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to get player list (legacy) without permission^7")
        TriggerClientEvent('admin:client:receiveNotification', src, 'You don\'t have permission to view player list', 'error')
        return
    end
    
    local players = GetRealPlayers()
    TriggerClientEvent('receivePlayers', src, players)
end)

RegisterNetEvent('checkAdminPermission', function()
    local src = source
    local hasPermission = HasPermission(src, 'helper')
    
    if hasPermission then
        TriggerClientEvent('admin:client:openMenu', src)
    else
        TriggerClientEvent('admin:client:receiveNotification', src, 'No permission', 'error')
    end
end)

RegisterServerEvent('refreshPlayerList', function()
    local src = source
    
    if HasPermission(src, 'helper') then
        local players = GetRealPlayers()
        TriggerClientEvent('receivePlayers', src, players)
    end
end)

RegisterNetEvent('admin:server:kickPlayer', function(playerId, reason)
    local src = source
    
    if not HasPermission(src, 'admin') then 
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to kick player without permission^7")
        return
    end
    
    if not reason or reason == '' then
        reason = 'No reason provided'
    end
    
    print("^3[INFO] Admin " .. GetPlayerName(src) .. " kicked " .. GetPlayerName(playerId) .. " for: " .. reason .. "^7")
    
    TriggerClientEvent('admin:client:receiveNotification', src, 'Player kicked: ' .. GetPlayerName(playerId), 'success')
    
    DropPlayer(playerId, 'You were kicked: ' .. reason)
end)

RegisterNetEvent('admin:server:banPlayer', function(playerId, reason, duration)
    local src = source
    
    if not HasPermission(src, 'admin') then 
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to ban player without permission^7")
        return
    end
    
    if not reason or reason == '' then
        reason = 'No reason provided'
    end
    
    if not duration or duration == '' then
        duration = '0' -- Permanent ban
    end
    
    local targetName = GetPlayerName(playerId)
    local targetIdentifiers = GetPlayerIdentifiers(playerId)
    local banData = {
        name = targetName,
        reason = reason,
        admin = GetPlayerName(src),
        duration = duration,
        timestamp = os.time(),
        identifiers = targetIdentifiers
    }
    
    -- Bridge.AddBan(banData)
    
    print("^1[INFO] Admin " .. GetPlayerName(src) .. " banned " .. targetName .. 
          " for: " .. reason .. " (Duration: " .. duration .. ")^7")
    
    TriggerClientEvent('admin:client:receiveNotification', src, 'Player banned: ' .. targetName, 'success')
    
    DropPlayer(playerId, 'You were banned: ' .. reason .. '\nDuration: ' .. 
               (duration == '0' and 'Permanent' or duration .. ' days'))
end)

RegisterNetEvent('admin:server:giveMoney', function(playerId, amount, type)
    local src = source
    if not HasPermission(src, 'admin') then return end
    
    local success = Bridge.GivePlayerMoney(src, tonumber(playerId), type, amount)
    
    if success then
        TriggerClientEvent('anticheat:notify', src, 'Gave $' .. amount .. ' to player', 'success')
    else
        TriggerClientEvent('anticheat:notify', src, 'Failed to give money', 'error')
    end
end)

RegisterNetEvent('admin:server:setJob', function(playerId, job, grade)
    local src = source
    if not HasPermission(src, 'admin') then return end
    
    local success = Bridge.UpdatePlayerJob(src, tonumber(playerId), job, grade)
    
    if success then
        TriggerClientEvent('anticheat:notify', src, 'Job updated for player', 'success')
    else
        TriggerClientEvent('anticheat:notify', src, 'Failed to update job', 'error')
    end
end)

local statsPath = "stats.json"
local startTime = os.time()  
local statsCache = {}

function updateUptime(statsCache)
    local now = os.time()
    local elapsedSeconds = now - startTime
    local elapsedHours = math.floor(elapsedSeconds / 3600)
    statsCache.serverUptime = string.format("%d hours", elapsedHours)
    saveStats(statsCache)
end

function loadStats()
    local statsFile = LoadResourceFile(GetCurrentResourceName(), statsPath)
    if statsFile then
        return json.decode(statsFile)
    else
        print("[Admin Panel] Could not open " .. statsPath)
        return {}
    end
end

function saveStats(stats)
    local statsContent = json.encode(stats, { indent = true })
    SaveResourceFile(GetCurrentResourceName(), statsPath, statsContent, -1)
end

AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    statsCache = loadStats()
    statsCache.totalPlayers    = statsCache.totalPlayers    or 0
    statsCache.activeCheaters  = statsCache.activeCheaters  or 0
    statsCache.serverUptime    = statsCache.serverUptime    or "0 minutes"
    statsCache.peakPlayers     = statsCache.peakPlayers     or 0
    saveStats(statsCache)
    print("[Admin Panel] stats.json loaded. Current stats:")
    print(json.encode(statsCache, { indent = true }))
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(60 * 60 * 1000)
            updateUptime(statsCache)
        end
    end)
end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local playerCount = #GetPlayers() + 1  
    statsCache.totalPlayers = playerCount
    if playerCount > statsCache.peakPlayers then
        statsCache.peakPlayers = playerCount
    end
    saveStats(statsCache)
end)

AddEventHandler("playerDropped", function(reason)
    local playerCount = #GetPlayers()
    statsCache.totalPlayers = playerCount
    saveStats(statsCache)
end)

RegisterNetEvent("secureServe:requestStats", function()
    local src = source
    if not src then return end
    
    if not HasPermission(src, 'helper') then 
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to request stats without permission^7")
        return
    end
    
    statsCache = loadStats()
    statsCache.totalPlayers    = statsCache.totalPlayers    or 0
    statsCache.activeCheaters  = statsCache.activeCheaters  or 0
    statsCache.serverUptime    = statsCache.serverUptime    or "0 minutes"
    statsCache.peakPlayers     = statsCache.peakPlayers     or 0
    TriggerClientEvent("secureServe:returnStats", src, statsCache)
end)

RegisterNetEvent('executeServerOption:restartServer', function()
    local src = source
    
    if not HasPermission(src, 'admin') then
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to restart server without permission^7")
        return
    end
    
    TriggerClientEvent('chat:addMessage', -1, {
        args = { '^1SERVER', 'The server is restarting. Please reconnect shortly.' }
    })
    print('[SERVER] Restart initiated by an admin.')
    Citizen.Wait(5000)
    os.exit()
end)

RegisterNetEvent('SecureServe:screenshotPlayer', function(playerId)
    local src = source
    
    if not HasPermission(src, 'mod') then
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to take screenshot without permission^7")
        return
    end
    
    local webhookUrl = Config.Webhooks.screenshots
    if not webhookUrl or webhookUrl == '' then
        TriggerClientEvent('anticheat:notify', src, 'Screenshot webhook not configured', 'error')
        return
    end
    
    exports['screenshot-basic']:requestScreenshotUpload(webhookUrl, 'image', function(response)
        local responseData = json.decode(response)
        if responseData and responseData.attachments and responseData.attachments[1] then
            local screenshotUrl = responseData.attachments[1].url
            PerformHttpRequest(webhookUrl, function(err, text, headers) end, 'POST', json.encode({
                embeds = {{
                    title = "Screenshot Taken",
                    description = string.format("Screenshot taken for player ID: %s by admin %s", 
                                              playerId, GetPlayerName(src)),
                    image = { url = screenshotUrl },
                    color = 3066993,
                    footer = {
                        text = "Admin Panel • " .. os.date("%Y-%m-%d %H:%M:%S")
                    }
                }}
            }), { ['Content-Type'] = 'application/json' })
            TriggerClientEvent('SecureServe:screenshotPlayerResult', src, screenshotUrl)
        else
            TriggerClientEvent('SecureServe:screenshotPlayerResult', src, nil)
        end
    end)
end)

RegisterNetEvent('anticheat:cuffPlayer', function(targetId)
    local src = source
    
    if not HasPermission(src, 'mod') then
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to cuff without permission^7")
        return
    end
    
    if targetId then
        TriggerClientEvent('anticheat:applyCuffs', targetId)
        TriggerClientEvent('anticheat:notify', src, 'Player cuffed successfully', 'success')
        print(("[INFO] Player %s was cuffed by admin %s"):format(GetPlayerName(targetId), GetPlayerName(src)))
    end
end)

RegisterNetEvent('anticheat:updatePlayerJob', function(targetId, newJob)
    local src = source
    
    if not HasPermission(src, 'admin') then
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to update job without permission^7")
        return
    end
    
    local success = Bridge.UpdatePlayerJob(src, tonumber(targetId), newJob, 1)
    
    if success then
        TriggerClientEvent('anticheat:notify', src, 'Player job updated to ' .. newJob, 'success')
        
        if Config.Framework == 'qb' or Config.Framework == 'qbox' then
            TriggerClientEvent('QBCore:Notify', targetId, "Your job has been updated to " .. newJob, "success")
        elseif Config.Framework == 'esx' then
            TriggerClientEvent('esx:showNotification', targetId, "Your job has been updated to " .. newJob)
        elseif Config.Framework == 'vrp' then
            TriggerClientEvent('chat:addMessage', targetId, {args = {"^2ADMIN", "Your job has been updated to " .. newJob}})
        end
    else
        TriggerClientEvent('anticheat:notify', src, 'Failed to update player job', 'error')
    end
end)

RegisterNetEvent('anticheat:updatePlayerGang', function(targetId, newGang)
    local src = source
    
    if not HasPermission(src, 'admin') then
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to update gang without permission^7")
        return
    end
    
    local success = false
    
    if Config.Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(tonumber(targetId))
        if Player then
            Player.Functions.SetGang(newGang, 1)
            success = true
        end
    elseif Config.Framework == 'qbox' then
        local Player = exports['qbx-core']:GetCoreObject().Functions.GetPlayer(tonumber(targetId))
        if Player then
            Player.Functions.SetGang(newGang, 1)
            success = true
        end
    elseif Config.Framework == 'esx' then
        local success = exports['esx_gangs']:setPlayerGang(tonumber(targetId), newGang, 1)
    elseif Config.Framework == 'vrp' then
        local user_id = exports['vrp']:getUserId(tonumber(targetId))
        if user_id then
            exports['vrp']:removeUserGroup(user_id, "gang") 
            exports['vrp']:addUserGroup(user_id, newGang)  
            success = true
        end
    end
    
    if success then
        TriggerClientEvent('anticheat:notify', src, 'Player gang updated to ' .. newGang, 'success')
        
        if Config.Framework == 'qb' or Config.Framework == 'qbox' then
            TriggerClientEvent('QBCore:Notify', targetId, "Your gang has been updated to " .. newGang, "success")
        elseif Config.Framework == 'esx' then
            TriggerClientEvent('esx:showNotification', targetId, "Your gang has been updated to " .. newGang)
        elseif Config.Framework == 'vrp' then
            TriggerClientEvent('chat:addMessage', targetId, {args = {"^2ADMIN", "Your gang has been updated to " .. newGang}})
        end
    else
        TriggerClientEvent('anticheat:notify', src, 'Failed to update player gang', 'error')
    end
end)

RegisterNetEvent('anticheat:givePlayerMoney', function(targetId, amount)
    local src = source
    
    if not HasPermission(src, 'admin') then
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to give money without permission^7")
        return
    end
    
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        TriggerClientEvent('anticheat:notify', src, 'Invalid amount', 'error')
        return
    end
    
    local success = Bridge.GivePlayerMoney(src, tonumber(targetId), 'cash', amount)
    
    if success then
        TriggerClientEvent('anticheat:notify', src, 'Gave $' .. amount .. ' to player', 'success')
        
        if Config.Framework == 'qb' or Config.Framework == 'qbox' then
            TriggerClientEvent('QBCore:Notify', targetId, "You received $" .. amount, "success")
        elseif Config.Framework == 'esx' then
            TriggerClientEvent('esx:showNotification', targetId, "You received $" .. amount)
        elseif Config.Framework == 'vrp' then
            TriggerClientEvent('chat:addMessage', targetId, {args = {"^2ADMIN", "You received $" .. amount}})
        end
    else
        TriggerClientEvent('anticheat:notify', src, 'Failed to give money', 'error')
    end
end)

RegisterNetEvent('anticheat:removePlayerMoney', function(targetId, amount)
    local src = source
    
    if not HasPermission(src, 'admin') then
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to remove money without permission^7")
        return
    end
    
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        TriggerClientEvent('anticheat:notify', src, 'Invalid amount', 'error')
        return
    end
    
    local success = Bridge.RemovePlayerMoney(src, tonumber(targetId), 'cash', amount)
    
    if success then
        TriggerClientEvent('anticheat:notify', src, 'Removed $' .. amount .. ' from player', 'success')
        
        if Config.Framework == 'qb' or Config.Framework == 'qbox' then
            TriggerClientEvent('QBCore:Notify', targetId, "You lost $" .. amount, "error")
            TriggerClientEvent('inventory:client:ItemBox', targetId, QBCore.Shared.Items[item], "remove")
        elseif Config.Framework == 'esx' then
            TriggerClientEvent('esx:showNotification', targetId, "You lost $" .. amount)
        elseif Config.Framework == 'vrp' then
            TriggerClientEvent('chat:addMessage', targetId, {args = {"^1ADMIN", "You lost $" .. amount}})
        end
    else
        TriggerClientEvent('anticheat:notify', src, 'Failed to remove money', 'error')
    end
end)

RegisterNetEvent('anticheat:jailPlayer', function(targetId, time)
    local src = source
    
    if not HasPermission(src, 'mod') then
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to jail without permission^7")
        return
    end
    
    time = tonumber(time)
    if not time or time <= 0 then
        TriggerClientEvent('anticheat:notify', src, 'Invalid jail time', 'error')
        return
    end
    
    local jailCoords = Config.JailCoords or vector3(1641.0, 2574.0, 45.0)
    
    local success = false
    
    if Config.Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(tonumber(targetId))
        if Player then
            TriggerClientEvent('anticheat:applyJail', targetId, time, jailCoords)
            success = true
        end
    elseif Config.Framework == 'esx' then
        TriggerEvent('esx_jail:sendToJail', targetId, time)
        success = true
    elseif Config.Framework == 'qbox' then
        local Player = exports['qbx-core']:GetCoreObject().Functions.GetPlayer(tonumber(targetId))
        if Player then
            TriggerClientEvent('anticheat:applyJail', targetId, time, jailCoords)
            success = true
        end
    elseif Config.Framework == 'vrp' then
        local user_id = exports['vrp']:getUserId(tonumber(targetId))
        if user_id then
            exports['vrp']:jailPlayer(user_id, time)
            success = true
        end
    end
    
    if success then
        TriggerClientEvent('anticheat:notify', src, 'Player jailed for ' .. time .. ' minutes', 'success')
        
        if Config.Framework == 'qb' or Config.Framework == 'qbox' then
            TriggerClientEvent('QBCore:Notify', targetId, "You have been jailed for " .. time .. " minutes", "error")
        elseif Config.Framework == 'esx' then
            TriggerClientEvent('esx:showNotification', targetId, "You have been jailed for " .. time .. " minutes")
        elseif Config.Framework == 'vrp' then
            TriggerClientEvent('chat:addMessage', targetId, {args = {"^1ADMIN", "You have been jailed for " .. time .. " minutes"}})
        end
    else
        TriggerClientEvent('anticheat:notify', src, 'Failed to jail player', 'error')
    end
end)

RegisterNetEvent('admin:server:gotoPlayer', function(playerId)
    local src = source
    
    if not HasPermission(src, 'mod') then 
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to goto player without permission^7")
        return
    end
    
    local targetPed = GetPlayerPed(playerId)
    if not DoesEntityExist(targetPed) then
        TriggerClientEvent('admin:client:receiveNotification', src, 'Player does not exist', 'error')
        return
    end
    
    local coords = GetEntityCoords(targetPed)
    TriggerClientEvent('admin:client:gotoPlayer', src, coords)
    TriggerClientEvent('admin:client:receiveNotification', src, 'Teleported to player', 'success')
    
    print("^2[INFO] Admin " .. GetPlayerName(src) .. " teleported to " .. GetPlayerName(playerId) .. "^7")
end)

RegisterNetEvent('admin:server:bringPlayer', function(playerId)
    local src = source
    
    if not HasPermission(src, 'mod') then 
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to bring player without permission^7")
        return
    end
    
    local adminPed = GetPlayerPed(src)
    if not DoesEntityExist(adminPed) then
        TriggerClientEvent('admin:client:receiveNotification', src, 'Error getting your position', 'error')
        return
    end
    
    local coords = GetEntityCoords(adminPed)
    TriggerClientEvent('admin:client:bringPlayer', playerId, coords)
    TriggerClientEvent('admin:client:receiveNotification', src, 'Player teleported to you', 'success')
    
    TriggerClientEvent('admin:client:receiveNotification', playerId, 'You were teleported to an admin', 'info')
    
    print("^2[INFO] Admin " .. GetPlayerName(src) .. " brought " .. GetPlayerName(playerId) .. " to them^7")
end)

RegisterNetEvent('admin:server:toggleNoclip', function(targetId)
    local src = source
    
    if not HasPermission(src, 'mod') then 
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to toggle noclip without permission^7")
        return
    end
    
    local target = targetId or src
    
    TriggerClientEvent('admin:client:toggleNoclip', target)
    
    if target ~= src then
        TriggerClientEvent('anticheat:notify', src, 'Toggled noclip for player', 'success')
    end
    
    if Config.Webhooks.actions and Config.Webhooks.actions ~= '' then
        local message = {
            embeds = {
                {
                    title = "Admin Action",
                    description = string.format("**Admin:** %s\n**Action:** Toggle Noclip\n**Target:** %s", 
                        GetPlayerName(src), GetPlayerName(target)),
                    color = 3447003,
                    footer = {
                        text = "Admin Panel • " .. os.date("%Y-%m-%d %H:%M:%S")
                    }
                }
            }
        }
        
        PerformHttpRequest(Config.Webhooks.actions, function(err, text, headers) end, 'POST', 
            json.encode(message), { ['Content-Type'] = 'application/json' })
    end
end)

RegisterNetEvent('admin:server:getAdminList', function()
    local src = source
    
    if not HasPermission(src, 'admin') then 
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to get admin list without permission^7")
        return
    end
    
    local admins = Bridge.GetAdmins()
    TriggerClientEvent('admin:client:receiveAdminList', src, admins)
end)

RegisterNetEvent('admin:server:getPlayerInventory', function(targetId)
    local src = source
    
    if not HasPermission(src, 'admin') then 
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to get player inventory without permission^7")
        return
    end
    
    local inventory = Bridge.GetPlayerInventory(targetId)
    TriggerClientEvent('admin:client:receivePlayerInventory', src, inventory)
end)

RegisterNetEvent('admin:server:giveItem', function(targetId, item, amount)
    local src = source
    
    if not HasPermission(src, 'admin') then 
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to give item without permission^7")
        return
    end
    
    amount = tonumber(amount) or 1
    
    local success = false
    
    if Config.Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(tonumber(targetId))
        if Player then
            Player.Functions.AddItem(item, amount)
            success = true
        end
    elseif Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(tonumber(targetId))
        if xPlayer then
            xPlayer.addInventoryItem(item, amount)
            success = true
        end
    elseif Config.Framework == 'qbox' then
        local Player = exports['qbx-core']:GetCoreObject().Functions.GetPlayer(tonumber(targetId))
        if Player then
            Player.Functions.AddItem(item, amount)
            success = true
        end
    elseif Config.Framework == 'vrp' then
        local user_id = exports['vrp']:getUserId(tonumber(targetId))
        if user_id then
            exports['vrp']:giveInventoryItem(user_id, item, amount)
            success = true
        end
    end
    
    if success then
        TriggerClientEvent('anticheat:notify', src, 'Gave ' .. amount .. ' ' .. item .. ' to player', 'success')
        
        if Config.Framework == 'qb' or Config.Framework == 'qbox' then
            TriggerClientEvent('QBCore:Notify', targetId, "You received " .. amount .. " " .. item, "success")
            TriggerClientEvent('inventory:client:ItemBox', targetId, QBCore.Shared.Items[item], "add")
        elseif Config.Framework == 'esx' then
            TriggerClientEvent('esx:showNotification', targetId, "You received " .. amount .. " " .. item)
        elseif Config.Framework == 'vrp' then
            TriggerClientEvent('chat:addMessage', targetId, {args = {"^2ADMIN", "You received " .. amount .. " " .. item}})
        end
    else
        TriggerClientEvent('anticheat:notify', src, 'Failed to give item to player', 'error')
    end
end)

RegisterNetEvent('admin:server:removeItem', function(targetId, item, amount)
    local src = source
    
    if not HasPermission(src, 'admin') then 
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to remove item without permission^7")
        return
    end
    
    amount = tonumber(amount) or 1
    
    local success = false
    
    if Config.Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(tonumber(targetId))
        if Player then
            Player.Functions.RemoveItem(item, amount)
            success = true
        end
    elseif Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(tonumber(targetId))
        if xPlayer then
            xPlayer.removeInventoryItem(item, amount)
            success = true
        end
    elseif Config.Framework == 'qbox' then
        local Player = exports['qbx-core']:GetCoreObject().Functions.GetPlayer(tonumber(targetId))
        if Player then
            Player.Functions.RemoveItem(item, amount)
            success = true
        end
    elseif Config.Framework == 'vrp' then
        local user_id = exports['vrp']:getUserId(tonumber(targetId))
        if user_id then
            exports['vrp']:tryGetInventoryItem(user_id, item, amount)
            success = true
        end
    end
    
    if success then
        TriggerClientEvent('anticheat:notify', src, 'Removed ' .. amount .. ' ' .. item .. ' from player', 'success')
        
        if Config.Framework == 'qb' or Config.Framework == 'qbox' then
            TriggerClientEvent('QBCore:Notify', targetId, "You lost " .. amount .. " " .. item, "error")
            TriggerClientEvent('inventory:client:ItemBox', targetId, QBCore.Shared.Items[item], "remove")
        elseif Config.Framework == 'esx' then
            TriggerClientEvent('esx:showNotification', targetId, "You lost " .. amount .. " " .. item)
        elseif Config.Framework == 'vrp' then
            TriggerClientEvent('chat:addMessage', targetId, {args = {"^1ADMIN", "You lost " .. amount .. " " .. item}})
        end
    else
        TriggerClientEvent('anticheat:notify', src, 'Failed to remove item from player', 'error')
    end
end)

RegisterNetEvent('admin:server:sendNotification', function(target, message, type)
    local src = source
    
    if not HasPermission(src, 'helper') and target ~= src then
        print("^1[WARN] Player " .. GetPlayerName(src) .. " tried to send notification without permission^7")
        return
    end
    
    TriggerClientEvent('admin:client:receiveNotification', target, message, type)
end)

RegisterNetEvent('anticheat:notify', function(message, type)
    TriggerClientEvent('admin:client:receiveNotification', source, message, type)
end)

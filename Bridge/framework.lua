Bridge = {}

local QBCore, ESX, QBox, vRP = nil, nil, nil, nil
local Framework = Config.Framework



local function InitializeFramework()
    if Framework == 'qb' then
        QBCore = exports['qb-core']:GetCoreObject()
        print("^2[INFO] QBCore initialized^7")
        return true
    elseif Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
        print("^2[INFO] ESX initialized^7")
        return true
    elseif Framework == 'qbox' then
        QBox = exports['qbx-core']:GetCoreObject()
        print("^2[INFO] QBox initialized^7")
        return true
    elseif Framework == 'vrp' then
        vRP = exports['vrp']:getSharedObject()
        print("^2[INFO] vRP initialized^7")
        return true
    else
        print("^1[ERROR] Invalid framework specified in config: " .. Framework .. "^7")
        return false
    end
end

CreateThread(function()
    if not InitializeFramework() then
        print("^1[ERROR] Failed to initialize framework^7")
    end
end)



Bridge.HasPermission = function(source, requiredLevel)
    if Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            local group = nil
            
            if Player.PlayerData and Player.PlayerData.group then
                group = Player.PlayerData.group
            elseif Player.PlayerData and Player.PlayerData.metadata and Player.PlayerData.metadata.permissiongroup then
                group = Player.PlayerData.metadata.permissiongroup
            elseif Player.getPermission then
                group = Player.getPermission()
            elseif Player.getGroup then
                group = Player.getGroup()
            elseif Player.permission then
                group = Player.permission
            end
            
            if not group then
                if IsPlayerAceAllowed(source, "command.admin") then
                    group = "admin"
                elseif IsPlayerAceAllowed(source, "command.mod") then
                    group = "mod"
                else
                    print(string.format("^1[ERROR] Could not determine permission group for player %s^7", GetPlayerName(source)))
                    return false
                end
            end
            
            local permLevel = Config.PermissionLevels[group] 
            local reqLevel = Config.PermissionLevels[requiredLevel]
            
            if Config.Debug then
                print(string.format("[PERMISSION DEBUG] Player: %s, Group: %s, PermLevel: %s, RequiredLevel: %s, ReqValue: %s", 
                    GetPlayerName(source), group, permLevel, requiredLevel, reqLevel))
            end
            
            if permLevel == nil then
                print(string.format("^1[ERROR] Group '%s' not found in Config.PermissionLevels^7", group))
                return false
            end
            
            if reqLevel == nil then
                print(string.format("^1[ERROR] Required level '%s' not found in Config.PermissionLevels^7", requiredLevel))
                return false
            end
            
            return permLevel >= reqLevel
        end
    elseif Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            local group = xPlayer.getGroup()
            local permLevel = Config.PermissionLevels[group]
            local reqLevel = Config.PermissionLevels[requiredLevel]
            
            if Config.Debug then
                print(string.format("[PERMISSION DEBUG] Player: %s, Group: %s, PermLevel: %s, RequiredLevel: %s, ReqValue: %s", 
                    GetPlayerName(source), group, permLevel, requiredLevel, reqLevel))
            end
            
            if permLevel == nil then
                print(string.format("^1[ERROR] Group '%s' not found in Config.PermissionLevels^7", group))
                return false
            end
            
            if reqLevel == nil then
                print(string.format("^1[ERROR] Required level '%s' not found in Config.PermissionLevels^7", requiredLevel))
                return false
            end
            
            return permLevel >= reqLevel
        end
    elseif Framework == 'qbox' then
        local Player = QBox.Functions.GetPlayer(source)
        if Player then
            local group = nil
            
            if Player.PlayerData and Player.PlayerData.group then
                group = Player.PlayerData.group
            elseif Player.PlayerData and Player.PlayerData.metadata and Player.PlayerData.metadata.permissiongroup then
                group = Player.PlayerData.metadata.permissiongroup
            elseif Player.getPermission then
                group = Player.getPermission()
            elseif Player.getGroup then
                group = Player.getGroup()
            elseif Player.permission then
                group = Player.permission
            end
            
            if not group then
                if IsPlayerAceAllowed(source, "command.admin") then
                    group = "admin"
                elseif IsPlayerAceAllowed(source, "command.mod") then
                    group = "mod"
                else
                    print(string.format("^1[ERROR] Could not determine permission group for player %s^7", GetPlayerName(source)))
                    return false
                end
            end
            
            local permLevel = Config.PermissionLevels[group] 
            local reqLevel = Config.PermissionLevels[requiredLevel]
            
            if Config.Debug then
                print(string.format("[PERMISSION DEBUG] Player: %s, Group: %s, PermLevel: %s, RequiredLevel: %s, ReqValue: %s", 
                    GetPlayerName(source), group, permLevel, requiredLevel, reqLevel))
            end
            
            if permLevel == nil then
                print(string.format("^1[ERROR] Group '%s' not found in Config.PermissionLevels^7", group))
                return false
            end
            
            if reqLevel == nil then
                print(string.format("^1[ERROR] Required level '%s' not found in Config.PermissionLevels^7", requiredLevel))
                return false
            end
            
            return permLevel >= reqLevel
        end
    elseif Framework == 'vrp' then
        -- vRP permission check
        if source and vRP then
            local user_id = vRP.getUserId({source})
            if user_id then
                if Config.Debug then
                    print(string.format("[PERMISSION DEBUG] Player: %s, UserID: %s, RequiredLevel: %s", 
                        GetPlayerName(source), user_id, requiredLevel))
                end
                
                if requiredLevel == 'helper' and vRP.hasPermission({user_id, 'helper.permission'}) then
                    return true
                elseif requiredLevel == 'mod' and vRP.hasPermission({user_id, 'moderator.permission'}) then
                    return true
                elseif requiredLevel == 'admin' and vRP.hasPermission({user_id, 'admin.permission'}) then
                    return true
                elseif requiredLevel == 'god' and vRP.hasPermission({user_id, 'superadmin.permission'}) then
                    return true
                end
            end
        end
    end
    
    return false
end



Bridge.GetAllPlayers = function()
    local players = {}
    
    if Framework == 'qb' and QBCore then
        for k, v in pairs(QBCore.Functions.GetPlayers()) do
            local Player = QBCore.Functions.GetPlayer(v)
            if Player then
                local playerData = {
                    source = Player.PlayerData.source,
                    id = Player.PlayerData.source,
                    name = Player.PlayerData.charinfo and Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname or GetPlayerName(Player.PlayerData.source),
                    citizenid = Player.PlayerData.citizenid,
                    job = Player.PlayerData.job and Player.PlayerData.job.name or 'unknown',
                    grade = Player.PlayerData.job and Player.PlayerData.job.grade.name or '0',
                    ping = GetPlayerPing(Player.PlayerData.source)
                }
                table.insert(players, playerData)
            end
        end
    elseif Framework == 'esx' and ESX then
        for k, v in pairs(ESX.GetPlayers()) do
            local xPlayer = ESX.GetPlayerFromId(v)
            if xPlayer then
                local playerData = {
                    source = xPlayer.source,
                    id = xPlayer.source,
                    name = GetPlayerName(xPlayer.source),
                    identifier = xPlayer.identifier,
                    job = xPlayer.job and xPlayer.job.name or 'unknown',
                    grade = xPlayer.job and xPlayer.job.grade_name or '0',
                    ping = GetPlayerPing(xPlayer.source)
                }
                table.insert(players, playerData)
            end
        end
    elseif Framework == 'qbox' and QBox then
        for k, v in pairs(QBox.Functions.GetPlayers()) do
            local Player = QBox.Functions.GetPlayer(v)
            if Player then
                local playerData = {
                    source = Player.PlayerData.source,
                    id = Player.PlayerData.source,
                    name = Player.PlayerData.charinfo and Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname or GetPlayerName(Player.PlayerData.source),
                    citizenid = Player.PlayerData.citizenid,
                    job = Player.PlayerData.job and Player.PlayerData.job.name or 'unknown',
                    grade = Player.PlayerData.job and Player.PlayerData.job.grade.name or '0',
                    ping = GetPlayerPing(Player.PlayerData.source)
                }
                table.insert(players, playerData)
            end
        end
    elseif Framework == 'vrp' and vRP then
        local users = vRP.getUsers({})
        for k, v in pairs(users) do
            local source = vRP.getUserSource({k})
            if source then
                local playerData = {
                    source = source,
                    id = source,
                    name = GetPlayerName(source),
                    userid = k,
                    ping = GetPlayerPing(source)
                }
                table.insert(players, playerData)
            end
        end
    else
        for _, playerId in ipairs(GetPlayers()) do
            local id = tonumber(playerId)
            table.insert(players, {
                source = id,
                id = id,
                name = GetPlayerName(id),
                ping = GetPlayerPing(id)
            })
        end
    end
    
    return players
end


Bridge.GivePlayerMoney = function(adminSource, playerId, type, amount)
    if Framework == 'qb' and QBCore then
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            if type == 'cash' then
                Player.Functions.AddMoney('cash', amount)
            elseif type == 'bank' then
                Player.Functions.AddMoney('bank', amount)
            end
            return true
        end
    elseif Framework == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            if type == 'cash' then
                xPlayer.addMoney(amount)
            elseif type == 'bank' then
                xPlayer.addAccountMoney('bank', amount)
            end
            return true
        end
    elseif Framework == 'qbox' and QBox then
        local Player = QBox.Functions.GetPlayer(playerId)
        if Player then
            if type == 'cash' then
                Player.Functions.AddMoney('cash', amount)
            elseif type == 'bank' then
                Player.Functions.AddMoney('bank', amount)
            end
            return true
        end
    elseif Framework == 'vrp' and vRP then
        local user_id = vRP.getUserId({playerId})
        if user_id then
            if type == 'cash' then
                vRP.giveMoney({user_id, amount})
            elseif type == 'bank' then
                vRP.giveBankMoney({user_id, amount})
            end
            return true
        end
    end
    
    return false
end

Bridge.RemovePlayerMoney = function(adminSource, playerId, type, amount)
    if Framework == 'qb' and QBCore then
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            if type == 'cash' then
                Player.Functions.RemoveMoney('cash', amount)
            elseif type == 'bank' then
                Player.Functions.RemoveMoney('bank', amount)
            end
            return true
        end
    elseif Framework == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            if type == 'cash' then
                xPlayer.removeMoney(amount)
            elseif type == 'bank' then
                xPlayer.removeAccountMoney('bank', amount)
            end
            return true
        end
    elseif Framework == 'qbox' and QBox then
        local Player = QBox.Functions.GetPlayer(playerId)
        if Player then
            if type == 'cash' then
                Player.Functions.RemoveMoney('cash', amount)
            elseif type == 'bank' then
                Player.Functions.RemoveMoney('bank', amount)
            end
            return true
        end
    elseif Framework == 'vrp' and vRP then
        local user_id = vRP.getUserId({playerId})
        if user_id then
            if type == 'cash' then
                vRP.tryPayment({user_id, amount})
            elseif type == 'bank' then
                vRP.tryBankPayment({user_id, amount})
            end
            return true
        end
    end
    
    return false
end


Bridge.UpdatePlayerJob = function(adminSource, playerId, job, grade)
    if Framework == 'qb' and QBCore then
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            Player.Functions.SetJob(job, grade)
            return true
        end
    elseif Framework == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            xPlayer.setJob(job, grade)
            return true
        end
    elseif Framework == 'qbox' and QBox then
        local Player = QBox.Functions.GetPlayer(playerId)
        if Player then
            Player.Functions.SetJob(job, grade)
            return true
        end
    elseif Framework == 'vrp' and vRP then
        local user_id = vRP.getUserId({playerId})
        if user_id then
            vRP.addUserGroup({user_id, job})
            return true
        end
    end
    
    return false
end

Bridge.GetPlayerData = function(source)
    if Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            return {
                name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                job = Player.PlayerData.job.label,
                grade = Player.PlayerData.job.grade.name,
                cash = Player.PlayerData.money.cash,
                bank = Player.PlayerData.money.bank,
                citizenid = Player.PlayerData.citizenid,
                group = Player.PlayerData.group
            }
        end
    elseif Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return {
                name = xPlayer.getName(),
                job = xPlayer.getJob().label or xPlayer.getJob().name,
                grade = xPlayer.getJob().grade_label or tostring(xPlayer.getJob().grade),
                cash = xPlayer.getMoney(),
                bank = xPlayer.getAccount('bank').money,
                citizenid = xPlayer.identifier,
                group = xPlayer.getGroup()
            }
        end
    elseif Framework == 'qbox' then
        local Player = QBox.Functions.GetPlayer(source)
        if Player then
            return {
                name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                job = Player.PlayerData.job.label,
                grade = Player.PlayerData.job.grade.name,
                cash = Player.PlayerData.money.cash,
                bank = Player.PlayerData.money.bank,
                citizenid = Player.PlayerData.citizenid,
                group = Player.PlayerData.group
            }
        end
    elseif Framework == 'vrp' then
        local user_id = vRP.getUserId({source})
        if user_id then
            local identity = vRP.getUserIdentity({user_id})
            if identity then
                local money = vRP.getMoney({user_id})
                local bank = vRP.getBankMoney({user_id})
                local job = vRP.getUserGroupByType({user_id, "job"})
                local group = "user"
                
                if vRP.hasPermission({user_id, "superadmin.permission"}) then
                    group = "god"
                elseif vRP.hasPermission({user_id, "admin.permission"}) then
                    group = "admin"
                elseif vRP.hasPermission({user_id, "moderator.permission"}) then
                    group = "mod"
                elseif vRP.hasPermission({user_id, "helper.permission"}) then
                    group = "helper"
                end
                
                return {
                    name = identity.firstname .. ' ' .. identity.name,
                    job = job or "Unemployed",
                    grade = "N/A",
                    cash = money,
                    bank = bank,
                    citizenid = tostring(user_id),
                    group = group
                }
            end
        end
    end
    return nil
end

Bridge.BanPlayer = function(source, target, reason, duration)
    if not Bridge.HasPermission(source, 'admin') then return false end
    
    if Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(target)
        if Player then
            local banData = {
                name = GetPlayerName(target),
                license = Player.PlayerData.license,
                discord = Player.PlayerData.discord,
                reason = reason,
                expires = duration == 0 and 2147483647 or os.time() + (duration * 86400),
                bannedby = GetPlayerName(source)
            }
            
            MySQL.insert('INSERT INTO bans (name, license, discord, reason, expires, bannedby) VALUES (?, ?, ?, ?, ?, ?)', {
                banData.name,
                banData.license,
                banData.discord,
                banData.reason,
                banData.expires,
                banData.bannedby
            })
            
            DropPlayer(target, 'Banned: ' .. reason)
            return true
        end
    elseif Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(target)
        if xPlayer then
            MySQL.Async.execute('INSERT INTO bans (identifier, reason, expire, bannedby) VALUES (@identifier, @reason, @expire, @bannedby)', {
                ['@identifier'] = xPlayer.identifier,
                ['@reason'] = reason,
                ['@expire'] = duration == 0 and 2147483647 or os.time() + (duration * 86400),
                ['@bannedby'] = GetPlayerName(source)
            })
            
            DropPlayer(target, 'Banned: ' .. reason)
            return true
        end
    elseif Framework == 'qbox' then
        local Player = QBox.Functions.GetPlayer(target)
        if Player then
            local banData = {
                name = GetPlayerName(target),
                license = Player.PlayerData.license,
                discord = Player.PlayerData.discord,
                reason = reason,
                expires = duration == 0 and 2147483647 or os.time() + (duration * 86400),
                bannedby = GetPlayerName(source)
            }
            
            MySQL.insert('INSERT INTO bans (name, license, discord, reason, expires, bannedby) VALUES (?, ?, ?, ?, ?, ?)', {
                banData.name,
                banData.license,
                banData.discord,
                banData.reason,
                banData.expires,
                banData.bannedby
            })
            
            DropPlayer(target, 'Banned: ' .. reason)
            return true
        end
    elseif Framework == 'vrp' then
        local user_id = vRP.getUserId({target})
        if user_id then
            -- VRP ban format
            local banData = {
                userid = user_id,
                reason = reason,
                expiration = duration == 0 and 0 or os.time() + (duration * 86400), -- 0 is permanent in vRP
                admin = GetPlayerName(source),
            }
            
            vRP.setBanned({user_id, true, banData.expiration, banData.reason})
            DropPlayer(target, 'Banned: ' .. reason)
            return true
        end
    end
    return false
end

Bridge.KickPlayer = function(source, target, reason)
    if not Bridge.HasPermission(source, 'mod') then return false end
    
    DropPlayer(target, reason or "Kicked by admin")
    return true
end

Bridge.GetAllPlayers = function()
    local players = {}
    
    if Framework == 'qb' then
        for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
            local Player = QBCore.Functions.GetPlayer(tonumber(playerId))
            if Player then
                local PlayerData = Player.PlayerData
                players[#players + 1] = {
                    id = PlayerData.source,
                    name = PlayerData.charinfo.firstname .. ' ' .. PlayerData.charinfo.lastname,
                    steam = PlayerData.steam,
                    citizenid = PlayerData.citizenid,
                    job = PlayerData.job.label,
                    grade = PlayerData.job.grade.name,
                    cash = PlayerData.money.cash,
                    bank = PlayerData.money.bank,
                    group = PlayerData.group
                }
            end
        end
    elseif Framework == 'esx' then
        local xPlayers = ESX.GetPlayers()
        for _, playerId in ipairs(xPlayers) do
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer then
                players[#players + 1] = {
                    id = xPlayer.source,
                    name = xPlayer.getName(),
                    steam = xPlayer.identifier,
                    citizenid = xPlayer.identifier,
                    job = xPlayer.getJob().label or xPlayer.getJob().name,
                    grade = xPlayer.getJob().grade_label or tostring(xPlayer.getJob().grade),
                    cash = xPlayer.getMoney(),
                    bank = xPlayer.getAccount('bank').money,
                    group = xPlayer.getGroup()
                }
            end
        end
    elseif Framework == 'qbox' then
        for _, playerId in pairs(QBox.Functions.GetPlayers()) do
            local Player = QBox.Functions.GetPlayer(tonumber(playerId))
            if Player then
                local PlayerData = Player.PlayerData
                players[#players + 1] = {
                    id = PlayerData.source,
                    name = PlayerData.charinfo.firstname .. ' ' .. PlayerData.charinfo.lastname,
                    steam = PlayerData.steam,
                    citizenid = PlayerData.citizenid,
                    job = PlayerData.job.label,
                    grade = PlayerData.job.grade.name,
                    cash = PlayerData.money.cash,
                    bank = PlayerData.money.bank,
                    group = PlayerData.group
                }
            end
        end
    elseif Framework == 'vrp' then
        local users = vRP.getUsers({})
        for user_id, source in pairs(users) do
            local identity = vRP.getUserIdentity({user_id})
            if identity then
                local money = vRP.getMoney({user_id})
                local bank = vRP.getBankMoney({user_id})
                local job = vRP.getUserGroupByType({user_id, "job"})
                local group = "user"
                
                if vRP.hasPermission({user_id, "superadmin.permission"}) then
                    group = "god"
                elseif vRP.hasPermission({user_id, "admin.permission"}) then
                    group = "admin"
                elseif vRP.hasPermission({user_id, "moderator.permission"}) then
                    group = "mod"
                elseif vRP.hasPermission({user_id, "helper.permission"}) then
                    group = "helper"
                end
                
                players[#players + 1] = {
                    id = source,
                    name = identity.firstname .. ' ' .. identity.name,
                    steam = "vrp:" .. user_id,
                    citizenid = tostring(user_id),
                    job = job or "Unemployed",
                    grade = "N/A",
                    cash = money,
                    bank = bank,
                    group = group
                }
            end
        end
    end
    
    return players
end

Bridge.GetPlayerInventory = function(source)
    if Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            return Player.PlayerData.items
        end
    elseif Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.getInventory()
        end
    elseif Framework == 'qbox' then
        local Player = QBox.Functions.GetPlayer(source)
        if Player then
            return Player.PlayerData.items
        end
    elseif Framework == 'vrp' then
        local user_id = vRP.getUserId({source})
        if user_id then
            local inventory = vRP.getInventory({user_id})
            local formattedInventory = {}
            for k, v in pairs(inventory) do
                table.insert(formattedInventory, {
                    name = k,
                    count = v.amount,
                    label = v.name or k
                })
            end
            return formattedInventory
        end
    end
    return {}
end

Bridge.LoadBans = function()
    local bans = {}
    
    if Framework == 'qb' then
        local result = MySQL.query.await('SELECT * FROM bans')
        return result or {}
    elseif Framework == 'esx' then
        local result = MySQL.Async.fetchAll('SELECT * FROM bans', {})
        return result or {}
    elseif Framework == 'qbox' then
        local result = MySQL.query.await('SELECT * FROM bans')
        return result or {}
    elseif Framework == 'vrp' then
        local vRPbans = {}
        for user_id, ban_data in pairs(vRPbans) do
            table.insert(bans, {
                identifier = "vrp:" .. user_id,
                reason = ban_data.reason,
                expire = ban_data.expiration,
                bannedby = ban_data.admin
            })
        end
        return bans
    end
    
    return {}
end

Bridge.GetAllJobs = function()
    local jobs = {}
    
    if Framework == 'qb' then
        jobs = QBCore.Shared.Jobs
    elseif Framework == 'esx' then
        jobs = ESX.GetJobs()
    elseif Framework == 'qbox' then
        jobs = QBox.Shared.Jobs
    elseif Framework == 'vrp' then
        jobs = {}
        local jobGroups = vRP.getGroupsByType({"job"})
        for group, data in pairs(jobGroups) do
            jobs[group] = {
                label = data.title or group,
                grades = { [0] = { name = "default", label = "Default" } }
            }
        end
    end
    
    return jobs
end

Bridge.IsPlayerAdmin = function(source)
    return Bridge.HasPermission(source, Config.Authentication.minimumGrade)
end

Bridge.GetPermissionsForGroup = function(groupName)
    for _, group in ipairs(Config.PermissionGroups) do
        if group.name:lower() == groupName:lower() then
            return group.permissions
        end
    end
    return {}
end

Bridge.ClearAllEntities = function(source)
    if not Bridge.HasPermission(source, 'admin') then return false end
    
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
    
    return true
end

return Bridge 
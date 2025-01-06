local statsCache = {}

AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    statsCache = loadStats()
    
    statsCache.totalPlayers    = statsCache.totalPlayers    or 0
    statsCache.activeCheaters  = statsCache.activeCheaters  or 0
    statsCache.serverUptime    = statsCache.serverUptime    or "0 minutes"
    statsCache.peakPlayers     = statsCache.peakPlayers     or 0

    saveStats(statsCache)

    print("^2[SecureServe] stats.json loaded. Current stats: ^0")
    print(json.encode(statsCache, { indent = true }))

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(60 * 60 * 1000)  -- 60 minutes in ms
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
    statsCache = loadStats()
    
    statsCache.totalPlayers    = statsCache.totalPlayers    or 0
    statsCache.activeCheaters  = statsCache.activeCheaters  or 0
    statsCache.serverUptime    = statsCache.serverUptime    or "0 minutes"
    statsCache.peakPlayers     = statsCache.peakPlayers     or 0
    
    TriggerClientEvent("secureServe:returnStats", src, statsCache)
end)

RegisterNetEvent('executeServerOption:restartServer', function()
    TriggerClientEvent('chat:addMessage', -1, {
        args = { '^1SERVER', 'The server is restarting. Please reconnect shortly.' }
    })

    print('[SERVER] Restart initiated by an admin.')

    Citizen.Wait(5000)

    -- Restart the server (if your hosting supports auto-restart)
    os.exit() -- Replace with your hosting provider's restart command if necessary
end)

RegisterNetEvent('SecureServe:screenshotPlayer', function(playerId)
    local src = source
    local webhookUrl = Config.Main.Webhook

    exports['screenshot-basic']:requestScreenshotUpload(webhookUrl, 'image', function(response)
        local responseData = json.decode(response)

        if responseData and responseData.attachments and responseData.attachments[1] then
            local screenshotUrl = responseData.attachments[1].url

            PerformHttpRequest(webhookUrl, function(err, text, headers) end, 'POST', json.encode({
                embeds = {{
                    title = "Screenshot Taken",
                    description = string.format("Screenshot taken for player ID: %s", playerId),
                    image = { url = screenshotUrl },
                    color = 3066993
                }}
            }), { ['Content-Type'] = 'application/json' })

            TriggerClientEvent('SecureServe:screenshotPlayerResult', src, screenshotUrl)
        else
            TriggerClientEvent('SecureServe:screenshotPlayerResult', src, nil)
        end
    end)
end)

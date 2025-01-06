RegisterNetEvent("secureServe:returnStats", function(stats)
    SendNUIMessage({
        action = "dashboardStats",
        totalPlayers    = stats.totalPlayers,
        activeCheaters  = stats.activeCheaters,
        serverUptime    = stats.serverUptime,
        peakPlayers     = stats.peakPlayers
    })
end)
    

RegisterNetEvent('spectatePlayer', function(playerId)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(playerId))
    if DoesEntityExist(targetPed) then
        local playerPed = PlayerPedId()
        local targetCoords = GetEntityCoords(targetPed)
        RequestCollisionAtCoord(targetCoords.x, targetCoords.y, targetCoords.z)
        NetworkSetInSpectatorMode(true, targetPed)
    end
end)

RegisterNetEvent('receivePlayers', function(playerList)
    SendNUIMessage({
        action = 'players',
        players = playerList
    })
end)

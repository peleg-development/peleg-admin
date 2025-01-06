statsPath = "stats.json"
startTime = os.time()  

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
        print("^1[SecureServe] Could not open " .. statsPath .. ".^0")
        return {}
    end
end

function saveStats(stats)
    local statsContent = json.encode(stats, { indent = true })
    SaveResourceFile(GetCurrentResourceName(), statsPath, statsContent, -1)
end


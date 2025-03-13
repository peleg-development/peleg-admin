Visuals = {}

Visuals.ToggleESP = function(enable)
    if enable then
        Citizen.CreateThread(function()
            while Admin.Panel.options.ESP do
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
                            DrawRect(_x + width / 2 / Distance, _y + height / 2 / Distance, 0.001, height / Distance, color.r, color.g, color.b, 200)
                            DrawRect(_x - width / 2 / Distance, _y + height / 2 / Distance, 0.001, height / Distance, color.r, color.g, color.b, 200)
                            
                            local health = GetEntityHealth(curplayerped)
                            if health > 200 then health = 200 end

                            DrawRect(_x - 0.00028 / Distance, _y + height / 2 / Distance, 0.0016 / Distance * 0.015, height / Distance, 0, 0, 0, 200)
                            DrawRect(_x - 0.00028 / Distance, _y + height / Distance - GetEntityHealth(curplayerped) / 175000 / Distance, 0.0016 / Distance * 0.015, GetEntityHealth(curplayerped) / 87500 / Distance, 0, 255, 0, 200)
                            DrawRect(_x - 0.00033 / Distance, _y + height / 2 / Distance, 0.0016 / Distance * 0.015, height / Distance, 0, 0, 0, 200)

                            DrawRect(_x - 0.00033 / Distance, _y + height / Distance - GetPedArmour(curplayerped) / 87500 / Distance, 0.0016 / Distance * 0.015, GetPedArmour(curplayerped) / 43750 / Distance, 0, 77, 166, 255)
                        end
                    end
                end
            end
        end)
    end
end

Visuals.TogglePlayerNames = function(enable)
    if enable then
        Citizen.CreateThread(function()
            while Admin.Panel.options.PlayerNames do
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
                        UI.DrawText3D(x, y, z + 0.9, ("%s ~s~[~w~%s~s~] ~w~%s~s~"):format(talking, GetPlayerServerId(PlayerList[i]), GetPlayerName(PlayerList[i])))
                        UI.DrawText3D(x, y, z - 1, ("%sm"):format(dist))
                    end
                end
            end
        end)
    end
end

Visuals.GetPedBoneCoordsF = function(ped, boneId)
    local cam = GetFinalRenderedCamCoord()
    local ret, coords, shape = GetShapeTestResult(
        StartShapeTestRay(vector3(cam), vector3(GetPedBoneCoords(ped, 0x0)), -1)
    )
    if coords then
        a = Vdist(cam, shape) / Vdist(cam, GetPedBoneCoords(ped, 0x0))
    else
        a = 0.83
    end
    if a > 1 then a = 0.83 end
    if ret then
        return (((GetPedBoneCoords(ped, boneId) - cam) * ((a) * 0.83)) + cam)
    end
end

Visuals.ToggleBones = function(enable)
    if enable then
        Citizen.CreateThread(function()
            while Admin.Panel.options.Bones do
                Citizen.Wait(0)
                for k, v in pairs(GetActivePlayers()) do
                    local ped = GetPlayerPed(v)
                    if GetDistanceBetweenCoords(GetEntityCoords(ped), GetEntityCoords(PlayerPedId()), true) < 300 + 0.0 and (ped ~= PlayerPedId() or true) then
                        DrawLine(Visuals.GetPedBoneCoordsF(ped, 31086), Visuals.GetPedBoneCoordsF(ped, 0x9995), 255, 255, 255, 255)
                        DrawLine(Visuals.GetPedBoneCoordsF(ped, 0x9995), Visuals.GetPedBoneCoordsF(ped, 0xE0FD), 255, 255, 255, 255)
                        DrawLine(Visuals.GetPedBoneCoordsF(ped, 0x5C57), Visuals.GetPedBoneCoordsF(ped, 0xE0FD), 255, 255, 255, 255)
                        DrawLine(Visuals.GetPedBoneCoordsF(ped, 0x192A), Visuals.GetPedBoneCoordsF(ped, 0xE0FD), 255, 255, 255, 255)
                        DrawLine(Visuals.GetPedBoneCoordsF(ped, 0x3FCF), Visuals.GetPedBoneCoordsF(ped, 0x192A), 255, 255, 255, 255)
                        DrawLine(Visuals.GetPedBoneCoordsF(ped, 0xCC4D), Visuals.GetPedBoneCoordsF(ped, 0x3FCF), 255, 255, 255, 255)
                        DrawLine(Visuals.GetPedBoneCoordsF(ped, 0xB3FE), Visuals.GetPedBoneCoordsF(ped, 0x5C57), 255, 255, 255, 255)
                        DrawLine(Visuals.GetPedBoneCoordsF(ped, 0xB3FE), Visuals.GetPedBoneCoordsF(ped, 0x3779), 255, 255, 255, 255)
                        DrawLine(Visuals.GetPedBoneCoordsF(ped, 0x9995), Visuals.GetPedBoneCoordsF(ped, 0xB1C5), 255, 255, 255, 255)
                        DrawLine(Visuals.GetPedBoneCoordsF(ped, 0xB1C5), Visuals.GetPedBoneCoordsF(ped, 0xEEEB), 255, 255, 255, 255)
                        DrawLine(Visuals.GetPedBoneCoordsF(ped, 0xEEEB), Visuals.GetPedBoneCoordsF(ped, 0x49D9), 255, 255, 255, 255)
                        DrawLine(Visuals.GetPedBoneCoordsF(ped, 0x9995), Visuals.GetPedBoneCoordsF(ped, 0x9D4D), 255, 255, 255, 255)
                        DrawLine(Visuals.GetPedBoneCoordsF(ped, 0x9D4D), Visuals.GetPedBoneCoordsF(ped, 0x6E5C), 255, 255, 255, 255)
                        DrawLine(Visuals.GetPedBoneCoordsF(ped, 0x6E5C), Visuals.GetPedBoneCoordsF(ped, 0xDEAD), 255, 255, 255, 255)
                    end
                end
            end
        end)
    end
end 
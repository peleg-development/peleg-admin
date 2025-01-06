Config = {}

-- ================================
-- Framework Settings
-- ================================
Config.Framework = {
    type = "qbcore", -- Options: "qbcore", "esx"
}

-- ================================
-- Staff Roles and Permissions
-- ================================
Config.Roles = {
    -- Structure:
    -- ["DiscordRoleID"] = {
    --     name = "RoleName",
    --     permissions = { 
    --         permissionKey = true/false, 
    --         ... 
    --     },
    -- },
    
    ["123456789012345678"] = { -- Owner Role ID
        name = "Owner",
        permissions = {
            accessAdminMenu = true,
            banPlayers = true,
            unbanPlayers = true,
            kickPlayers = true,
            spectatePlayers = true,
            clearEntities = true,
            viewLogs = true,
            manageServer = true,
            teleportPlayers = true,
            giveWeapons = true,
            manageVehicles = true, -- New Permission
        },
    },
    ["234567890123456789"] = { -- Admin Role ID
        name = "Admin",
        permissions = {
            accessAdminMenu = true,
            banPlayers = true,
            unbanPlayers = true,
            kickPlayers = true,
            spectatePlayers = true,
            clearEntities = true,
            viewLogs = true,
            teleportPlayers = true,
            giveWeapons = true,
        },
    },
    ["345678901234567890"] = { -- Moderator Role ID
        name = "Moderator",
        permissions = {
            accessAdminMenu = true,
            kickPlayers = true,
            spectatePlayers = true,
            teleportPlayers = true,
        },
    },
    ["456789012345678901"] = { -- Helper Role ID
        name = "Helper",
        permissions = {
            accessAdminMenu = true,
            spectatePlayers = true,
        },
    },
}

-- ================================
-- Notification System
-- ================================
Config.Notification = {
    system = "ox_notify", -- Options: "ox_notify", "default", "custom"
    types = {
        success = { 
            type = "success", 
            duration = 5000,
            title = "Success",
        },
        error = { 
            type = "error", 
            duration = 5000,
            title = "Error",
        },
        info = { 
            type = "info", 
            duration = 5000,
            title = "Info",
        },
        warning = { 
            type = "warning", 
            duration = 5000,
            title = "Warning",
        },
    },
}

Config.Notify = function(msg, type)
    -- Centralized function for triggering notifications.
    -- msg: The message to display.
    -- type: The type of notification (success, error, info, warning).
    local notifyType = Config.Notification.types[type] or Config.Notification.types.info -- Default to 'info' if type is invalid.
    
    if Config.Notification.system == "ox_notify" then
        exports.ox_lib:notify({
            title = notifyType.title,
            description = msg,
            type = notifyType.type,
            duration = notifyType.duration,
        })
    elseif Config.Notification.system == "default" then
        TriggerEvent('chat:addMessage', {
            color = { tonumber("0x"..notifyType.color:sub(2,7),16) },
            multiline = true,
            args = { notifyType.title, msg }
        })
    else
        -- Custom notification system placeholder
        -- Implement your custom notification here
    end
end


-- ================================
-- Localization Support
-- ================================
Config.Localization = {
    defaultLanguage = "en",
    languages = {
        en = {
            adminPanel = "Admin Panel",
            banPlayer = "Ban Player",
            unbanPlayer = "Unban Player",
            kickPlayer = "Kick Player",
            spectatePlayer = "Spectate Player",
            clearEntities = "Clear Entities",
            teleport = "Teleport",
            giveWeapon = "Give Weapon",
            removeWeapon = "Remove Weapon",
        },
        es = {
            adminPanel = "Panel de Administración",
            banPlayer = "Prohibir Jugador",
            unbanPlayer = "Desprohibir Jugador",
            kickPlayer = "Expulsar Jugador",
            spectatePlayer = "Espectar Jugador",
            clearEntities = "Limpiar Entidades",
            teleport = "Teletransportar",
            giveWeapon = "Dar Arma",
            removeWeapon = "Quitar Arma",
        },
    },
    getTranslation = function(lang, key)
        lang = lang or Config.Localization.defaultLanguage
        return Config.Localization.languages[lang][key] or Config.Localization.languages[Config.Localization.defaultLanguage][key] or key
    end,
}

return Config

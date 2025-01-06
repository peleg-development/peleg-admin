Config = {}

-- ================================
-- Framework Settings
-- ================================
Config.Framework = {
    type = "qbcore", -- Options: "qbcore", "esx"
}

-- ================================
-- Logging Settings
-- ================================
Config.Logs = {
    enabled = true, -- Enable or disable logging of admin actions.
    discordWebhooks = { -- Support multiple webhooks for different log types.
        general = "YOUR_GENERAL_DISCORD_WEBHOOK_URL",
        bans = "YOUR_BANS_DISCORD_WEBHOOK_URL",
        kicks = "YOUR_KICKS_DISCORD_WEBHOOK_URL",
        spectates = "YOUR_SPECTATES_DISCORD_WEBHOOK_URL",
        adminActions = "YOUR_ADMIN_ACTIONS_DISCORD_WEBHOOK_URL",
    },
    logTypes = {
        bans = true,
        unbans = true,
        kicks = true,
        spectates = true,
        adminActions = true,
        teleport = true, -- New log type
        weapons = true, -- New log type
    },
    includeTimestamp = true,
    includePlayerDetails = true, -- Option to include player IDs, names, etc.
}

-- ================================
-- Ban System Configuration
-- ================================
Config.Bans = {
    enabled = true,
    durations = {
        { label = "15 Minutes", value = "15m" },
        { label = "1 Hour", value = "1h" },
        { label = "12 Hours", value = "12h" },
        { label = "1 Day", value = "1d" },
        { label = "3 Days", value = "3d" },
        { label = "1 Week", value = "7d" },
        { label = "2 Weeks", value = "14d" },
        { label = "1 Month", value = "30d" },
        { label = "Permanent", value = "perm" },
    },
    defaultDuration = "7d",
    requireReason = true, -- Require admin to provide a reason for the ban.
    maxActiveBans = 5, -- Limit the number of active bans per player to prevent abuse.
}

-- ================================
-- Admin Commands
-- ================================
Config.Commands = {
    openAdminMenu = {
        command = "adminmenu",
        description = "Opens the admin menu.",
        permissions = { "accessAdminMenu" },
    },
    ban = {
        command = "ban",
        description = "Ban a player.",
        permissions = { "banPlayers" },
        args = {
            { name = "playerID", type = "player" },
            { name = "duration", type = "string", options = Config.Bans.durations },
            { name = "reason", type = "string", required = true },
        },
    },
    unban = {
        command = "unban",
        description = "Unban a player.",
        permissions = { "unbanPlayers" },
        args = {
            { name = "playerID", type = "player" },
        },
    },
    kick = {
        command = "kick",
        description = "Kick a player from the server.",
        permissions = { "kickPlayers" },
        args = {
            { name = "playerID", type = "player" },
            { name = "reason", type = "string", required = false },
        },
    },
    spectate = {
        command = "spectate",
        description = "Spectate a player.",
        permissions = { "spectatePlayers" },
        args = {
            { name = "playerID", type = "player" },
        },
    },
    clearEntities = {
        command = "clearents",
        description = "Clear all entities from the map.",
        permissions = { "clearEntities" },
        args = {},
    },
    teleportHere = {
        command = "tphere",
        description = "Teleport a player to your location.",
        permissions = { "teleportPlayers" },
        args = {
            { name = "playerID", type = "player" },
        },
    },
    teleportTo = {
        command = "tpto",
        description = "Teleport to a player's location.",
        permissions = { "teleportPlayers" },
        args = {
            { name = "playerID", type = "player" },
        },
    },
    giveWeapon = {
        command = "giveweapon",
        description = "Give a weapon to a player.",
        permissions = { "giveWeapons" },
        args = {
            { name = "playerID", type = "player" },
            { name = "weaponName", type = "string", required = true },
            { name = "ammo", type = "number", required = false, default = 100 },
        },
    },
    removeWeapon = {
        command = "removeweapon",
        description = "Remove a weapon from a player.",
        permissions = { "giveWeapons" },
        args = {
            { name = "playerID", type = "player" },
            { name = "weaponName", type = "string", required = true },
        },
    },
}

-- ================================
-- Security Settings
-- ================================
Config.Security = {
    enableAntiCheat = true, -- Enable basic anti-cheat measures.
    allowedCommandPrefix = "/", -- Prefix for regular commands.
    restrictedCommands = { -- Commands restricted to admins only.
        "ban",
        "kick",
        "unban",
        "spectate",
        "clearents",
    },
}

return Config

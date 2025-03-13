Config = {}

--[[ BASIC SETTINGS ]]--
Config.Debug = false                    -- Enable debug mode for development (false in production)
Config.Framework = 'qb'                 -- Supported frameworks: 'qb', 'esx', 'qbox', 'vrp'

--[[ ADMIN PANEL SETTINGS ]]--
Config.Authentication = {
    useAcePerms = false,                -- Set to true to use ACE permissions instead of framework roles
    fallbackToAce = true,               -- Fallback to ACE if framework permission check fails
    minimumGrade = 'admin',             -- Minimum grade required: 'helper', 'mod', 'admin', or 'god'
    openCommand = 'admin',              -- Command to open admin panel
    openKey = nil,                      -- Key binding to open panel (nil = no key binding)
    acePermission = "command.admin",    -- ACE permission to check if using ACE
}

--[[ WEBHOOK SETTINGS ]]--
Config.Webhooks = {
    actions = '',                       -- Discord webhook for admin actions
    bans = '',                          -- Discord webhook for ban actions
    kicks = '',                         -- Discord webhook for kick actions
    screenshots = '',                   -- Discord webhook for screenshots
}

--[[ PERMISSION SETTINGS ]]--
-- Higher number = more access
Config.PermissionLevels = {
    -- Standard permission levels
    ['god'] = 100,
    ['superadmin'] = 100,
    ['admin'] = 80,
    ['moderator'] = 60,
    ['mod'] = 60,
    ['helper'] = 40,
    ['user'] = 0,
    
    -- Framework-specific permissions (don't remove these)
    -- QBCore
    ['owner'] = 100,
    ['developer'] = 100,
    ['dev'] = 100,
    ['management'] = 90,
    ['senior_admin'] = 85,
    ['staff'] = 50,
    
    -- ESX
    ['_dev'] = 100,
    ['admin'] = 80,
    ['mod'] = 60,
}

--[[ PERMISSION GROUPS ]]--
Config.PermissionGroups = {
    {
        name = "Superadmin",
        level = 100,
        permissions = {
            all = true,
            banPlayers = true,
            kickPlayers = true,
            teleport = true,
            noclip = true,
            godmode = true,
            vehicleSpawn = true,
            moneyManagement = true,
            jobManagement = true,
            manageAdmins = true,
            clearEntities = true,
            serverManagement = true,
        }
    },
    {
        name = "Admin",
        level = 80,
        permissions = {
            banPlayers = true,
            kickPlayers = true,
            teleport = true,
            noclip = true,
            godmode = true,
            vehicleSpawn = true,
            clearEntities = true,
        }
    },
    {
        name = "Moderator",
        level = 60,
        permissions = {
            kickPlayers = true,
            teleport = true,
            noclip = true,
        }
    },
    {
        name = "Helper",
        level = 40,
        permissions = {
            teleport = true,
        }
    }
}

--[[ FRAMEWORK-SPECIFIC SETTINGS ]]--
Config.Frameworks = {
    vrp = {
        permissions = {
            ['helper.permission'] = 'helper',
            ['moderator.permission'] = 'mod',
            ['admin.permission'] = 'admin',
            ['superadmin.permission'] = 'god'
        }
    }
}

--[[ JAIL SETTINGS ]]--
Config.JailCoords = vector3(1641.0, 2574.0, 45.0)  -- Default jail location

return Config 
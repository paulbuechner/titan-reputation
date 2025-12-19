local _, TitanPanelReputation = ...

--[[ TitanPanelReputation
NAME: TitanPanelReputation.ID
DESC:
The unique ID of the addon. This is used to identify the addon in the Titan Panel API.
Also this affects the naming convention of the `TitanPanelRightClickMenu_Prepare{TitanPanelReputation.ID}Menu`
(menu.lua) to hook into Titan API.
:DESC
]]
TitanPanelReputation.ID = "Reputation"

--[[ TitanPanelReputation
NAME: TitanPanelReputation.VERSION
DESC: The current version of the addon. This is used to display the version number in the Titan Panel.
]]
TitanPanelReputation.VERSION = TitanUtils_GetAddOnMetadata("TitanReputation", "Version")

--[[ TitanPanelReputation
NAME: TitanPanelReputation.TITLE
DESC: The title of the addon. This is used to display the title in the Titan Panel.
]]
TitanPanelReputation.TITLE = TitanUtils_GetAddOnMetadata("TitanReputation", "Title")

--[[ TitanPanelReputation
NAME: TitanPanelReputation.ICON
DESC:
The icon to use for the addon. This is used to display the icon in the Titan Panel,
aswell as in the addon list.
:DESC
]]
TitanPanelReputation.ICON = "Interface\\AddOns\\TitanReputation\\assets\\TitanReputation"

--[[ TitanPanelReputation
NAME: TitanPanelReputation.INIT_TIME
DESC:
The time passed since TitanPanelReputation was initialized
(set to uptime of pc in seconds, with millisecond precision).
:DESC
]]
TitanPanelReputation.INIT_TIME = 0

--[[ TitanPanelReputation
NAME: TitanPanelReputation.EVENT_TIME
DESC: The time passed since TitanPanelReputation was last updated (triggered by an event).
]]
TitanPanelReputation.EVENT_TIME = GetTime()

--[[ TitanPanelReputation
NAME: TitanPanelReputation.SESSION_TIME_START
DESC: The time since the session started, used to calculate session related reputation farm metrics (e.g. per hour)
]]
TitanPanelReputation.SESSION_TIME_START = GetTime()

--[[ TitanPanelReputation
NAME: TitanPanelReputation.TABLE
DESC:
The table of reputation values for each faction.
    table = {
        ["factionID"].name = "FactionName",
        ["factionID"].standingID = 5,     -- 1 = Hated, 2 = Hostile, 3 = Unfriendly, 4 = Neutral, 5 = Friendly, 6 = Honored, 7 = Revered, 8 = Exalted
        ["factionID"].earnedValue = 1000,
        ["factionID"].topValue = 6000,
        ...
    }
:DESC
]]
TitanPanelReputation.TABLE = {}

--[[ TitanPanelReputation
NAME: TitanPanelReputation.TABLE_INIT
DESC: Whether the `TitanPanelReputation.TABLE` has been initialized.
]]
TitanPanelReputation.TABLE_INIT = false

--[[ TitanPanelReputation
NAME: TitanPanelReputation.RTS
DESC:
The table of reputation values for each faction for the current session.
    table = {
        ["factionName"] = 1337,
        ...
    }
:DESC
]]
TitanPanelReputation.RTS = {}

--[[ TitanPanelReputation
NAME: TitanPanelReputation.G_FACTION_ID
DESC:
The guild faction ID, used to filter out the guild reputation.
TODO: Make this an option in the settings.
:DESC
]]
TitanPanelReputation.G_FACTION_ID = 1168

--[[ TitanPanelReputation
NAME: TitanPanelReputation.BUTTON_TEXT
DESC: The text to display on the Titan Panel button.
]]
TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation:GT("LID_NO_FACTION_LABEL")

--[[ TitanPanelReputation
NAME: TitanPanelReputation.TOOLTIP_TEXT
DESC: The text to display on the Titan Panel tooltip.
]]
TitanPanelReputation.TOOLTIP_TEXT = ""

--[[ TitanPanelReputation
NAME: TitanPanelReputation.HIGHCHANGED
DESC: Used to track the earned reputation amount for a given faction (e.g. "rep increased by 15")
]]
TitanPanelReputation.HIGHCHANGED = 0

--[[ TitanPanelReputation
NAME: TitanPanelReputation.CHANGED_FACTION
DESC: The name of the faction last changed (reputation earned for).
]]
TitanPanelReputation.CHANGED_FACTION = "none"

--[[ TitanPanelReputation
NAME: TitanPanelReputation.DebugMode
DESC: Flag that toggles extra developer tooling (e.g. ctrl+click faction testing).
]]
TitanPanelReputation.DebugMode = false

--[[ TitanPanelReputation
NAME: TitanPanelReputation.ICONS
DESC: The icons to use for achivement standings announcements.
]]
TitanPanelReputation.ICONS = { "03", "03", "07", "08", "06", "06", "06", "05" }

--[[ TitanPanelReputation
NAME: TitanPanelReputation.COLORS_DEFAULT
DESC: The color themes `default` color palette.
]]
TitanPanelReputation.COLORS_DEFAULT = {
    [1] = { r = 0.8, g = 0, b = 0 },            -- #33ffff
    [2] = { r = 0.8, g = 0.3, b = 0.22 },       -- #33b3c7
    [3] = { r = 0.75, g = 0.27, b = 0 },        -- #3290c7
    [4] = { r = 0.9, g = 0.7, b = 0 },          -- #143bc7
    [5] = { r = 0, g = 1.0, b = 0.5 },          -- #ff0080
    [6] = { r = 0, g = 0.5, b = 0.5 },          -- #ff8080
    [7] = { r = 0, g = 0.5, b = 1.0 },          -- #ff8000
    [8] = { r = 0.2, g = 0.7, b = 0.7 },        -- #cc4d4d
    [9] = { r = 1, g = 0.5, b = 0.1 },          -- #0080e6
    [10] = { r = 0.000, g = 0.749, b = 0.953 }, -- #e63cd2
}

--[[ TitanPanelReputation
NAME: TitanPanelReputation.COLORS_ARMORY
DESC: The color themes `armory` color palette.
]]
TitanPanelReputation.COLORS_ARMORY = {
    [1] = { r = 0.54, g = 0.11, b = 0.07 },     -- #75e3ed
    [2] = { r = 0.65, g = 0.30, b = 0.10 },     -- #59b3e6
    [3] = { r = 0.70, g = 0.48, b = 0.11 },     -- #4d85e3
    [4] = { r = 0.67, g = 0.55, b = 0.11 },     -- #5473e3
    [5] = { r = 0.49, g = 0.49, b = 0.00 },     -- #8282ff
    [6] = { r = 0.34, g = 0.47, b = 0.00 },     -- #a987ff
    [7] = { r = 0.14, g = 0.48, b = 0.00 },     -- #da85ff
    [8] = { r = 0.01, g = 0.49, b = 0.42 },     -- #fc8294
    [9] = { r = 1, g = 0.5, b = 0.1 },          -- #0080e6
    [10] = { r = 0.000, g = 0.749, b = 0.953 }, -- #e63cd2
}

--[[ TitanPanelReputation
NAME: TitanPanelReputation.BARCOLORS
DESC: The color theme currently in use.
]]
TitanPanelReputation.BARCOLORS = TitanPanelReputation.COLORS_DEFAULT

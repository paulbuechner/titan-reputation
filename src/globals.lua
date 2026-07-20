---@diagnostic disable: assign-type-mismatch

local _, TitanPanelReputation = ...

---
---The unique ID of the addon. This is used to identify the addon in the Titan Panel API.
---
---@type string
TitanPanelReputation.ID = "Reputation"

---
---The current version of the addon. This is used to display the version number in the Titan Panel.
---
---@type string
TitanPanelReputation.VERSION = TitanUtils_GetAddOnMetadata("TitanReputation", "Version")

---
---The title of the addon. This is used to display the title in the Titan Panel.
---
---@type string
TitanPanelReputation.TITLE = "|cffffffffTitan [|cffeda55fReputation Continued|r]|r"

---
---The icon to use for the addon. This is used to display the icon in the Titan Panel,
---as well as in the addon list.
---
---@type string
TitanPanelReputation.ICON = "Interface\\AddOns\\TitanReputation\\assets\\TitanReputation"

---
---The time passed since TitanPanelReputation was initialized
---(set to uptime of pc in seconds, with millisecond precision).
---
---@type number
TitanPanelReputation.INIT_TIME = 0

---Minimum required Titan Panel version (string). Update as needed.
---@type string
TitanPanelReputation.MIN_TITAN_VERSION = "9.1.1"

---
---The time passed since TitanPanelReputation was last updated (triggered by an event).
---
---@type number
TitanPanelReputation.EVENT_TIME = GetTime()

---
---The time since the session started, used to calculate session related reputation farm metrics (e.g. per hour)
---
---@type number
TitanPanelReputation.SESSION_TIME_START = GetTime()

---
---The table of reputation values for each faction.
---```lua
---    table = {
---        ["factionID"].name = "FactionName",
---        ["factionID"].standingID = 5,     -- 1 = Hated, 2 = Hostile, 3 = Unfriendly, 4 = Neutral, 5 = Friendly, 6 = Honored, 7 = Revered, 8 = Exalted
---        ["factionID"].earnedValue = 1000,
---        ["factionID"].topValue = 6000,
---        ...
---    }
---```
---@type table<number, { name: string, standingID: number, earnedValue: number, topValue: number }>
TitanPanelReputation.TABLE = {}

---
---The table of reputation values for each faction for the current session.
---```lua
---    table = {
---        ["factionName"] = 1337,
---        ...
---    }
---```
---
---@type table<string, number>
TitanPanelReputation.RTS = {}

---
---The text to display on the Titan Panel button.
---
---@type string
TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation:GT("LID_NO_FACTION_LABEL")

---
---The text to display on the Titan Panel tooltip.
---
---@type string
TitanPanelReputation.TOOLTIP_TEXT = ""

---
---Used to track the earned reputation amount for a given faction (e.g. "rep increased by 15")
---
---@type number
TitanPanelReputation.HIGHCHANGED = 0

---
---The name of the faction last changed (reputation earned for).
---
---@type string
TitanPanelReputation.CHANGED_FACTION = "none"

---
---Flag that toggles extra developer tooling (e.g. ctrl+click faction testing).
---
---@type boolean
TitanPanelReputation.DebugMode = false

---
---The icons to use for achievement standings announcements.
---
---@type string[]
TitanPanelReputation.ICONS = { "03", "03", "07", "08", "06", "06", "06", "05" }

---
---The color themes `default` color palette.
---
---@type table<number, { r: number, g: number, b: number }>
TitanPanelReputation.COLORS_DEFAULT = {
    [1] = { r = 0.8, g = 0, b = 0 },            -- #cc0000 Hated
    [2] = { r = 0.8, g = 0.3, b = 0.22 },       -- #cc4d38 Hostile
    [3] = { r = 0.75, g = 0.27, b = 0 },        -- #bf4500 Unfriendly
    [4] = { r = 0.9, g = 0.7, b = 0 },          -- #e6b300 Neutral
    [5] = { r = 0, g = 1.0, b = 0.5 },          -- #00ff80 Friendly
    [6] = { r = 0, g = 0.5, b = 0.5 },          -- #008080 Honored
    [7] = { r = 0, g = 0.5, b = 1.0 },          -- #0080ff Revered
    [8] = { r = 0.2, g = 0.7, b = 0.7 },        -- #33b3b3 Exalted
    [9] = { r = 1, g = 0.5, b = 0.1 },          -- #ff801a Paragon
    [10] = { r = 0.000, g = 0.749, b = 0.953 }, -- #00bff3 Renown
}

---
---The color themes `armory` color palette.
---
---@type table<number, { r: number, g: number, b: number }>
TitanPanelReputation.COLORS_ARMORY = {
    [1] = { r = 0.54, g = 0.11, b = 0.07 },     -- #8a1c12 Hated
    [2] = { r = 0.65, g = 0.30, b = 0.10 },     -- #a64d1a Hostile
    [3] = { r = 0.70, g = 0.48, b = 0.11 },     -- #b37a1c Unfriendly
    [4] = { r = 0.67, g = 0.55, b = 0.11 },     -- #ab8c1c Neutral
    [5] = { r = 0.49, g = 0.49, b = 0.00 },     -- #7d7d00 Friendly
    [6] = { r = 0.34, g = 0.47, b = 0.00 },     -- #577800 Honored
    [7] = { r = 0.14, g = 0.48, b = 0.00 },     -- #247a00 Revered
    [8] = { r = 0.01, g = 0.49, b = 0.42 },     -- #037d6b Exalted
    [9] = { r = 1, g = 0.5, b = 0.1 },          -- #ff801a Paragon
    [10] = { r = 0.000, g = 0.749, b = 0.953 }, -- #00bff3 Renown
}

---
---The color theme currently in use.
---
---@type table<number, { r: number, g: number, b: number }>
TitanPanelReputation.BARCOLORS = TitanPanelReputation.COLORS_DEFAULT

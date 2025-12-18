local ADDON_NAME, TitanPanelReputation = ...

--[[ TitanPanelReputation
NAME: config
DESC: The configuration settings for the TitanPanelReputation AddOn.
]]
local config = {
    -- General Options --------------------------------------------------------
    AutoChange = true,                    -- Auto Show Changed
    WatchedFaction = "none",              --
    -- Announcement Settings
    ShowAnnounce = true,                  -- Announce Standing Changes
    ShowAnnounceFrame = true,             --
    ShowAnnounceMik = true,               --
    --
    FactionHeaders = {},                  --
    -- Button Options ---------------------------------------------------------
    DisplayOnRightSide = false,           -- Align Plugin to Right-Side
    ShowIcon = true,                      -- Show Icon
    ShowFriendsOnBar = true,              -- Show Friendships
    ShowFactionName = true,               -- Show Faction Name
    ShowStanding = true,                  -- Show Standing
    ShortStanding = false,                -- Abbreviate Standing
    ShowValue = true,                     -- Show Reputation Value
    ShowPercent = true,                   -- Show Percent
    -- Session Summary Settings
    ShowSessionSummaryDuration = true,    -- Show Duration
    ShowSessionSummaryTTL = true,         -- Show Time to Level
    -- Tooltip Options --------------------------------------------------------
    ToolTipScale = 1.0,                   --
    MinimalTip = false,                   --
    -- Friendship Rank Settings
    ShowFriendships = true,               --
    HideMaxFriendships = false,           -- Hide Best Friend (max) friendships from tooltip
    -- Reputation Standing Settings
    ShowExalted = true,                   --
    ShowRevered = true,                   --
    ShowHonored = true,                   --
    ShowFriendly = true,                  --
    ShowNeutral = true,                   --
    ShowUnfriendly = true,                --
    ShowHostile = true,                   --
    ShowHated = true,                     --
    --
    ShowTipReputationValue = true,        -- Show Reputation Value
    ShowTipPercent = true,                -- Show Percent
    ShowTipStanding = true,               -- Show Standing
    ShortTipStanding = false,             -- Abbreviate Standing
    ShowTipExaltedTotal = true,           -- Show Exalted Total
    -- Session Summary Settings
    ShowTipSessionSummaryDuration = true, -- Show Duration
    ShowTipSessionSummaryTTL = true,      -- Show Time to Level
    -- Color Options ----------------------------------------------------------
    ColorValue = 1,                       -- 1 = Default, 2 = Armory, 3 = Basic
}

--[[ TitanPanelReputation
NAME: TitanPanelReputationButton_OnLoad
DESC: The `OnLoad` event handler for the TitanPanelReputation AddOn.
]]
---@param self table TODO: Add explicit type
function TitanPanelReputationButton_OnLoad(self)
    ---@type TitanPluginRegistryType
    self.registry = {
        id = TitanPanelReputation.ID,
        menuText = TitanPanelReputation.TITLE,
        version = TitanPanelReputation.VERSION,
        buttonTextFunction = function()
            TitanPanelReputation:Refresh(); return TitanPanelReputation.BUTTON_TEXT
        end,
        tooltipCustomFunction = function()
            if not TitanGetVar(TitanPanelReputation.ID, "MinimalTip") then
                local tleft = "|T" ..
                    TitanPanelReputation.ICON .. ":20|t " .. TitanPanelReputation.TITLE
                GameTooltip:AddDoubleLine(tleft, "",
                    HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b,
                    HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            end
            -- Add the tooltip text
            TitanPanelReputation:AddTooltipText(TitanPanelReputation:BuildTooltipText())
            -- Show the tooltip
            GameTooltip:Show()
        end,
        category = "Information",
        icon = TitanPanelReputation.ICON,
        iconWidth = 16,
        savedVariables = config
    }
    self:RegisterEvent("UPDATE_FACTION")
    self:RegisterEvent("ADDON_LOADED")

    TitanPanelRightClickMenu_Close()
end

--[[ TitanPanelReputation
NAME: TitanPanelReputationButton_OnClick
DESC: The `OnClick` event handler for the TitanPanelReputation AddOn.
]]
---@param self table
---@param button string The button event name
function TitanPanelReputationButton_OnClick(self, button)
    if (button == "LeftButton") then
        ToggleCharacter("ReputationFrame")
    end
    if (button == "RightButton") then
        TitanPanelRightClickMenu_PrepareReputationMenu()
    end
end

--[[ TitanPanelReputation
NAME: TitanPanelReputationButton_OnEvent
DESC: The `OnEvent` event handler for the TitanPanelReputation AddOn.
]]
---@param event string The event name
function TitanPanelReputationButton_OnEvent(event, ...)
    if event == "ADDON_LOADED" and ... == ADDON_NAME then
        -- Initialize the saved variables
        -- if not TitanRep_Data then TitanRep_Data = {} end  -- TODO: currently not in use

        -- Set addon in init time (uptime of pc in seconds, with millisecond precision)
        TitanPanelReputation.INIT_TIME = GetTime();

        -- Set color theme
        local colorValue = TitanGetVar(TitanPanelReputation.ID, "ColorValue")
        --
        if (colorValue == 1) then TitanPanelReputation.BARCOLORS = TitanPanelReputation.COLORS_DEFAULT end
        if (colorValue == 2) then TitanPanelReputation.BARCOLORS = TitanPanelReputation.COLORS_ARMORY end
        if (colorValue == 3) then TitanPanelReputation.BARCOLORS = nil end

        TitanDebug("<TitanPanelReputation> " .. TitanPanelReputation:GT("LID_INITIALIZED"))
    end

    -- Only process data on reputation updates (https://warcraft.wiki.gg/wiki/UPDATE_FACTION)
    if event ~= "UPDATE_FACTION" then return end

    --[[  -------------------------- MAIN ADDON LOOP START -------------------------- ]]

    if TitanPanelReputation.INIT_TIME > 0 then
        -- Set the current tracked faction
        if ((GetTime() - TitanPanelReputation.EVENT_TIME) > .15) then
            TitanPanelReputation.HIGHCHANGED = 0
            TitanPanelReputation.EVENT_TIME = GetTime()

            -- If AutoChange is enabled (i.e. not 'none') set the watched faction to the changed faction
            if TitanGetVar(TitanPanelReputation.ID, "AutoChange") and TitanPanelReputation.CHANGED_FACTION ~= "none" then
                TitanSetVar(TitanPanelReputation.ID, "WatchedFaction", TitanPanelReputation.CHANGED_FACTION)
            end
        end

        -- Retrieve the current tracked faction name and earned reputation to populate `TitanPanelReputation.RTS` table
        if TitanPanelReputation.TABLE_INIT then
            TitanPanelReputation:FactionDetailsProvider(TitanPanelReputation.GetChangedName)
        end
        -- Collect all reputation data to populate `TitanPanelReputation.TABLE` table
        TitanPanelReputation:FactionDetailsProvider(TitanPanelReputation.GatherValues)

        -- Set the TitanPanelReputation table init flag after `TitanPanelReputation.GatherValues` has been called
        TitanPanelReputation.TABLE_INIT = true

        -- Update the TitanPanelReputation button (Now reflects updated reputation values, both session and total)
        TitanPanelReputation:Refresh()
    end

    --[[  --------------------------- MAIN ADDON LOOP END --------------------------- ]]

    -- Call TitanPanel API to render updates
    TitanPanelButton_UpdateTooltip()
    TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
end

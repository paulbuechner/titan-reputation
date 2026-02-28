local ADDON_NAME, TitanPanelReputation = ...

local required = TitanPanelReputation.MIN_TITAN_VERSION
local titanVersion = TitanUtils_GetAddOnMetadata("Titan", "Version")

if titanVersion and TitanPanelReputation:IsVersionLower(titanVersion, required) then
    TitanPanelReputation.TITAN_TOO_OLD = true
    TitanDebug("<TitanPanelReputation>" .. " "
        .. TitanPanelReputation:GT("LID_TITAN_TOO_OLD_WARNING_TOOLTIP_START") .. " "
        .. TitanPanelReputation.MIN_TITAN_VERSION .. " "
        .. TitanPanelReputation:GT("LID_TITAN_TOO_OLD_WARNING_TOOLTIP_END")
    )
else
    TitanPanelReputation.TITAN_TOO_OLD = false
end

---
---The configuration settings for the TitanPanelReputation AddOn.
---
local config = {
    -- General Options --------------------------------------------------------
    AutoChange = true,                    -- Auto Show Changed
    WatchedFaction = "none",              --
    -- Announcement Settings
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

---
---The `OnLoad` event handler for the TitanPanelReputation AddOn.
---
---@param self table TODO: Add explicit type
function TitanPanelReputationButton_OnLoad(self)
    ---@type TitanPluginRegistryType
    self.registry = {
        id = TitanPanelReputation.ID,
        menuText = TitanPanelReputation.TITLE,
        version = TitanPanelReputation.VERSION,
        buttonTextFunction = function()
            if TitanPanelReputation.TITAN_TOO_OLD then
                return "Titan Panel v" .. TitanPanelReputation.MIN_TITAN_VERSION .. " "
                    .. TitanPanelReputation:GT("LID_TITAN_TOO_OLD_WARNING_BUTTON")
            end

            TitanPanelReputation:RefreshButtonText()
            return TitanPanelReputation.BUTTON_TEXT
        end,
        tooltipTextFunction = function()
            if TitanPanelReputation.TITAN_TOO_OLD then
                return TitanPanelReputation:GT("LID_TITAN_TOO_OLD_WARNING_TOOLTIP_START") .. " "
                    .. TitanPanelReputation.MIN_TITAN_VERSION .. " "
                    .. TitanPanelReputation:GT("LID_TITAN_TOO_OLD_WARNING_TOOLTIP_END")
            end

            return TitanPanelReputation:BuildTooltipText()
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

---
---The `OnClick` event handler for the TitanPanelReputation AddOn.
---
---@param self table
---@param button string The button event name
function TitanPanelReputationButton_OnClick(self, button)
    if (button == "LeftButton") then
        ToggleCharacter("ReputationFrame")
    end
end

---
---The `OnEvent` event handler for the TitanPanelReputation AddOn.
---
---@param event string The event name
---@param ... any The event arguments
function TitanPanelReputationButton_OnEvent(event, ...)
    if event == "ADDON_LOADED" and ... == ADDON_NAME then
        -- Initialize the saved variables
        if not TitanRep_Data or type(TitanRep_Data) ~= "table" then
            TitanRep_Data = {}
        end

        -- Set addon in init time (uptime of pc in seconds, with millisecond precision)
        TitanPanelReputation.INIT_TIME = GetTime();

        -- Set color theme
        local colorValue = TitanGetVar(TitanPanelReputation.ID, "ColorValue")
        if (colorValue == 1) then TitanPanelReputation.BARCOLORS = TitanPanelReputation.COLORS_DEFAULT end
        if (colorValue == 2) then TitanPanelReputation.BARCOLORS = TitanPanelReputation.COLORS_ARMORY end
        if (colorValue == 3) then TitanPanelReputation.BARCOLORS = nil end

        -- Set debug mode (restore from saved vars)
        TitanPanelReputation:SetDebugMode(TitanRep_Data.DebugMode, true)

        TitanDebug("<TitanPanelReputation> " .. TitanPanelReputation:GT("LID_INITIALIZED"))

        return
    end

    if event == "UPDATE_FACTION" then
        --[[  -------------------------- MAIN ADDON LOOP START -------------------------- ]]

        if TitanPanelReputation.TITAN_TOO_OLD then return end

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

            TitanPanelReputation:HandleUpdateFaction()
        end

        --[[  --------------------------- MAIN ADDON LOOP END --------------------------- ]]

        -- Call TitanPanel API to render updates
        TitanPanelButton_UpdateTooltip()
        TitanPanelButton_UpdateButton(TitanPanelReputation.ID)

        return
    end
end

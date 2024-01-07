-- globals
TITANREP_ID = "Reputation"
TITANREP_VERSION = TitanUtils_GetAddOnMetadata("TitanReputation", "Version") or "UnKnown Version"
TITANREP_TITLE = TitanUtils_GetAddOnMetadata("TitanReputation", "Title") or "UnKnown Title"
TITANREP_BUTTON_ICON = "Interface\\AddOns\\TitanReputation\\assets\\TitanReputation"
TITANREP_EventTime = GetTime()
TITANREP_InitTime = 0
TITANREP_RTS = {}
gFactionID = 1168

-- Color coding
local TITANREP_COLORS_DEFAULT = {
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

local TITANREP_COLORS_ARMORY = {
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

local MYBARCOLORS = TITANREP_COLORS_DEFAULT

local TITANREP_ICONS = { "03", "03", "07", "08", "06", "06", "06", "05" }

-- labels
local TITANREP_ALL_HIDDEN_LABEL = "Reputation: Off"
local TITANREP_NO_FACTION_LABEL = "Reputation: No Faction Selected"
local TITANREP_SHOW_FACTION_NAME_LABEL = "Show Faction Name"
local TITANREP_SHOW_STANDING = "Show Standing"
local TITANREP_SHOW_VALUE = "Show Reputation Value"
local TITANREP_SHOW_PERCENT = "Show Percent"
local TITANREP_AUTO_CHANGE = "Auto Show Changed"
local TITANREP_SHOW_FRIENDSHIPS = "Show Frienships"
local TITANREP_SHOW_BESTFRIEND = "Show Best Friend"
local TITANREP_SHOW_GOODFRIEND = "Show Good Friend"
local TITANREP_SHOW_FRIEND = "Show Friend"
local TITANREP_SHOW_BUDDY = "Show Buddy"
local TITANREP_SHOW_ACQUAINTANCE = "Show Acquaintance"
local TITANREP_SHOW_STRANGER = "Show Stranger"
local TITANREP_SHOW_EXALTED = "Show Exalted"
local TITANREP_SHOW_REVERED = "Show Revered"
local TITANREP_SHOW_HONORED = "Show Honored"
local TITANREP_SHOW_FRIENDLY = "Show Friendly"
local TITANREP_SHOW_NEUTRAL = "Show Neutral"
local TITANREP_SHOW_UNFRIENDLY = "Show Unfriendly"
local TITANREP_SHOW_HOSTILE = "Show Hostile"
local TITANREP_SHOW_HATED = "Show Hated"
local TITANREP_SHORT_STANDING = " - Abbreviate Standing"
local TITANREP_ARMORY_COLORS = "Armory Colors"
local TITANREP_DEFAULT_COLORS = "Default Colors"
local TITANREP_NO_COLORS = "Basic Colors"
local TITANREP_SHOW_STATS = "Show Exalted Total"

-- Session Summary
local TITANREP_SESSION_SUMMARY_SETTINGS = "Session Summary Settings"
local TITANREP_SHOW_SUMMARY_DURATION = "Show Duration"
local TITANREP_SHOW_SUMMARY_TTL = "Show Time to Level"

local TITANREP_TIP_SESSION_SUMMARY_SETTINGS = "Tooltip Session Summary Settings"
local TITANREP_TIP_SHOW_SUMMARY_DURATION = "Show Duration"
local TITANREP_TIP_SHOW_SUMMARY_TTL = "Show Time to Level"

local TITANREP_SHOW_ANNOUNCE = "Announce Standing Changes"
-- TODO: Implement achivement style announcements based on official WoW API
-- local TITANREP_SHOW_ANNOUNCE_FRAME = "Glamourize Standing Changes"
local TITANREP_SHOW_ANNOUNCE_MIK = " - Use MikSBT for Announcement"
local TITANREP_SHOW_MINIMAL = "Use MinimalTip Tooltip Display"
local TITANREP_SCALE_INCREASE = "+ Increase Tooltip Scale"
local TITANREP_SCALE_DECREASE = "- Decrease Tooltip Scale"
local TITANREP_DisplayOnRightSide = "Align Plugin to Right-Side"
local TITANREP_ShowFriendsOnBar = "Show Friendships"
local TITANREP_PARAGON = "Paragon"
local TITANREP_SESSION_SUMMARY = "Session Summary"
local TITANREP_SESSION_SUMMARY_DURATION = "Duration"
local TITANREP_SESSION_SUMMARY_TOTAL_EXALTED_FACTIONS = "Total Exalted Factions"
local TITANREP_SESSION_SUMMARY_FACTIONS = "Factions"
local TITANREP_SESSION_SUMMARY_FRIENDS = "Friends"
local TITANREP_SESSION_SUMMARY_TOTAL = "Total"

-- local
local TITANREP_BUTTON_TEXT = TITANREP_NO_FACTION_LABEL
local TITANREP_TOOLTIP_TEXT = ""
local TITANREP_HIGHCHANGED = 0
local TITANREP_TIME = GetTime()
local TITANREP_CHANGEDFACTION = "none"
local TITANREP_TABLE = {}
local TITANREP_TABLE_INIT = false

-- initializing
function TitanPanelReputationButton_OnLoad(self)
    self.registry = {
        id = TITANREP_ID,
        menuText = TITANREP_ID,
        version = TITANREP_VERSION,
        buttonTextFunction = "TitanPanelReputation_GetButtonText",
        tooltipCustomFunction = function(self)
            if not TitanGetVar(TITANREP_ID, "MinimalTip") then
                local tleft = "|T" .. TITANREP_BUTTON_ICON .. ":20|t " .. TITANREP_TITLE
                -- local tright = "v" .. TITANREP_VERSION .. "|T" .. TITANREP_BUTTON_ICON .. ":20|t"
                local tright = ""
                GameTooltip:AddDoubleLine(tleft, tright, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g,
                    HIGHLIGHT_FONT_COLOR.b,
                    HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            end

            TitanPanelReputationUtils_AddTooltipText(TitanPanelReputation_GetToolTipText())

            GameTooltip:Show()
        end,
        category = "Information",
        icon = TITANREP_BUTTON_ICON,
        iconWidth = 16,
        savedVariables = {
            -- General Options -------------------------------------------
            AutoChange = true, -- Auto Show Changed

            -- Announcement Settings
            ShowAnnounce = true, -- Announce Standing Changes
            ShowAnnounceFrame = true,
            ShowAnnounceMik = true,

            FactionHeaders = { "" },

            -- Button Options --------------------------------------------
            DisplayOnRightSide = false, -- Align Plugin to Right-Side
            ShowIcon = true,            -- Show Icon
            ShowFriendsOnBar = true,    -- Show Friendships
            ShowFactionName = true,     -- Show Faction Name
            ShowStanding = true,        -- Show Standing
            ShortStanding = false,      -- Abbreviate Standing
            ShowValue = true,           -- Show Reputation Value
            ShowPercent = true,         -- Show Percent

            -- Session Summary Settings
            ShowSessionSummaryDuration = true, -- Show Duration
            ShowSessionSummaryTTL = true,      -- Show Time to Level

            -- Tooltip Options -------------------------------------------
            ToolTipScale = 1.0,
            MinimalTip = false,

            -- Friendship Rank Settings
            ShowFriendships = true,
            ShowBESTFRIEND = true,
            ShowGOODFRIEND = true,
            ShowFRIEND = true,
            ShowBUDDY = true,
            ShowACQUAINTANCE = true,
            ShowSTRANGER = true,

            -- Reputation Standing Settings
            ShowExalted = true,
            ShowRevered = true,
            ShowHonored = true,
            ShowFriendly = true,
            ShowNeutral = true,
            ShowUnfriendly = true,
            ShowHostile = true,
            ShowHated = true,

            ShowTipReputationValue = true, -- Show Reputation Value
            ShowTipPercent = true,         -- Show Percent
            ShowTipStanding = true,        -- Show Standing
            ShortTipStanding = false,      -- Abbreviate Standing
            ShowTipExaltedTotal = true,    -- Show Exalted Total

            -- Session Summary Settings
            ShowTipSessionSummaryDuration = true, -- Show Duration
            ShowTipSessionSummaryTTL = true,      -- Show Time to Level

            -- Color Options --------------------------------------------
            ColorValue = true,

            -- Other ----------------------------------------------------
            TITANREP_WATCHED_FACTION = "none",
        }
    }
    self:RegisterEvent("UPDATE_FACTION")
    self:RegisterEvent("ADDON_LOADED")

    TitanPanelRightClickMenu_Close()
end

-- event handling
function TitanPanelReputationButton_OnClick(self, button)
    if (button == "LeftButton") then
        ToggleCharacter("ReputationFrame")
    end
    if (button == "RightButton") then
        TitanPanelRightClickMenu_PrepareReputationMenu()
    end
end

function TitanPanelReputationButton_OnEvent(event, ...)
    if event == "ADDON_LOADED" and ... == "TitanPanelReputation" then
        if not TitanRep_Data then
            TitanRep_Data = {}
        end

        TITANREP_InitTime = GetTime();
        TitanDebug("<TITANREP> InitTime Set: " .. TITANREP_InitTime);
    end


    local EventTime = GetTime()
    local EventTimeDiff = EventTime - TITANREP_EventTime
    TitanPanelReputation_GatherFactions(TitanPanelReputation_GetChangedName)
    if (EventTimeDiff > .15) then
        TITANREP_HIGHCHANGED = 0
        TITANREP_EventTime = GetTime()
        if (TitanGetVar(TITANREP_ID, "AutoChange")) then
            if (not (TITANREP_CHANGEDFACTION == "none")) then
                TitanSetVar(TITANREP_ID, "TITANREP_WATCHED_FACTION", TITANREP_CHANGEDFACTION)
            end
        end
    end
    TitanPanelReputation_GatherFactions(TitanPanelReputation_GatherValues)
    if not TITANREP_TABLE_INIT then
        TITANREP_TABLE_INIT = true
        TitanDebug("<TITANREP> INIT SET")
    end
    TitanPanelReputation_Refresh()
    TitanPanelButton_UpdateTooltip()
    TitanPanelButton_UpdateButton(TITANREP_ID)
end

-- for titan to get the displayed text
function TitanPanelReputation_GetButtonText(id)
    TitanPanelReputation_Refresh()
    return TITANREP_BUTTON_TEXT
end

-- Tooltip scaling hooked ownership check (Thanks to Pankkirosvo, this was educational.)
local TITANREP_OldScale
local TITANREP_isTooltipShowing = false
function TitanPanelReputation_TooltipHook()
    if GameTooltip:GetOwner() == TitanPanelReputationButton then
        if not TITANREP_isTooltipShowing then
            TITANREP_isTooltipShowing = true
            TITANREP_OldScale = GameTooltip:GetScale()
            local toolTipScale = TitanGetVar(TITANREP_ID, "ToolTipScale")
            if toolTipScale ~= nil then
                GameTooltip:SetScale(toolTipScale)
            end
        end
    elseif TITANREP_isTooltipShowing then
        TITANREP_isTooltipShowing = false
        if TITANREP_OldScale then
            GameTooltip:SetScale(TITANREP_OldScale)
            TITANREP_OldScale = nil
        end
    end
end

hooksecurefunc(GameTooltip, "Show", TitanPanelReputation_TooltipHook)

function TitanPanelReputationSetColor()
    if (TitanGetVar(TITANREP_ID, "ColorValue") == 1) then
        MYBARCOLORS = TITANREP_COLORS_DEFAULT
    end
    if (TitanGetVar(TITANREP_ID, "ColorValue") == 2) then
        MYBARCOLORS = TITANREP_COLORS_ARMORY
    end
    if (TitanGetVar(TITANREP_ID, "ColorValue") == 3) then
        MYBARCOLORS = nil
    end
end

-- This method sets the text of the button according to selected faction's data
function TitanPanelReputation_BuildButtonText(name, parentName, standingID, topValue, earnedValue, percent, isHeader,
                                              isCollapsed, isInactive, hasRep, isChild, isFriendship, factionID,
                                              hasBonusRepGain)
    local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold
    local adjustedId = standingID

    if isFriendship then
        if not TitanGetVar(TITANREP_ID, "ShowFriendsOnBar") then
            return
        end

        local reputationInfo = C_GossipInfo.GetFriendshipReputation(factionID)

        friendID = reputationInfo["friendshipFactionID"]
        friendRep = reputationInfo["standing"]
        friendMaxRep = reputationInfo["maxRep"]
        friendName = reputationInfo["name"]
        friendText = reputationInfo["text"]
        friendTexture = reputationInfo["texture"]
        friendTextLevel = reputationInfo["reaction"]
        friendThreshold = reputationInfo["reactionThreshold"]
        nextFriendThreshold = reputationInfo["nextThreshold"]
    end

    if hasBonusRepGain then
        adjustedId = 9
    end

    if topValue == 0 then adjustedId = 8 end

    local preface = ""

    local LABEL = getglobal("FACTION_STANDING_LABEL" .. standingID)
    if isFriendship then LABEL = friendTextLevel end

    if hasBonusRepGain and not (isFriendship and not nextFriendThreshold) and not (adjustedId >= 8 and topValue == 0) then
        LABEL = TITANREP_PARAGON
    end

    if factionID and C_Reputation.IsMajorFaction(factionID) then
        local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)

        if majorFactionData ~= nil then
            LABEL = tostring(majorFactionData.renownLevel)
        end
        adjustedId = 10
    end

    if (TitanGetVar(TITANREP_ID, "ShortStanding")) then LABEL = strsub(LABEL, 1, adjustedId == 10 and 2 or 1) end

    TitanPanelReputationSetColor()

    if ((not isHeader or (isHeader and hasRep)) and (TitanGetVar(TITANREP_ID, "TITANREP_WATCHED_FACTION") == name)) then
        TITANREP_BUTTON_TEXT = ""
        local COLOR = nil
        if (MYBARCOLORS) then
            COLOR = MYBARCOLORS[(adjustedId)]
        end

        if (TitanGetVar(TITANREP_ID, "ShowFactionName")) then
            if (COLOR) then
                TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT .. TitanUtils_GetColoredText(name, COLOR)
            else
                TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT .. name
            end
            if (TitanGetVar(TITANREP_ID, "ShowStanding") or
                    TitanGetVar(TITANREP_ID, "ShowStanding") or
                    TitanGetVar(TITANREP_ID, "ShowValue") or
                    TitanGetVar(TITANREP_ID, "ShowPercent")) then
                TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT .. " - "
            end
        end

        if (TitanGetVar(TITANREP_ID, "ShowStanding")) then
            if (COLOR) then
                TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT .. TitanUtils_GetColoredText(LABEL, COLOR) .. " "
            else
                TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT .. LABEL .. " "
            end
        end
        if (TitanGetVar(TITANREP_ID, "ShowValue") and not (isFriendship and not nextFriendThreshold) and not (adjustedId >= 8 and topValue == 0)) then
            if (COLOR) then
                TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT ..
                    "[" .. TitanUtils_GetColoredText(earnedValue .. "/" .. topValue, COLOR) .. "] "
            else
                TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT .. "[" .. earnedValue .. "/" .. topValue .. "] "
            end
        end

        if (TitanGetVar(TITANREP_ID, "ShowPercent") and not (isFriendship and not nextFriendThreshold) and not (adjustedId >= 8 and topValue == 0)) then
            if (COLOR) then
                TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT .. TitanUtils_GetColoredText(percent .. "%", COLOR)
            else
                TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT .. percent .. "%"
            end
        end

        if (TitanGetVar(TITANREP_ID, "ShowSessionSummaryDuration") or TitanGetVar(TITANREP_ID, "ShowSessionSummaryTTL")) then
            local timeonline = GetTime() - TITANREP_TIME

            RTS_HAS_ENTRIES = (next(TITANREP_RTS) ~= nil)

            if RTS_HAS_ENTRIES then
                if (TitanGetVar(TITANREP_ID, "ShowSessionSummaryDuration")) then
                    local humantime = TitanPanelReputationUtils_GetHumanReadableTime(timeonline)

                    if (COLOR) then
                        TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT .. " - " ..
                            TitanUtils_GetColoredText(TITANREP_SESSION_SUMMARY_DURATION .. ": ", COLOR) ..
                            TitanUtils_GetNormalText(humantime)
                    else
                        TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT .. " - " ..
                            TitanUtils_GetNormalText(TITANREP_SESSION_SUMMARY_DURATION .. ": " .. humantime)
                    end
                end

                local earnedAmount = TITANREP_RTS[name]

                if earnedAmount then
                    local RPH_STRING = ""
                    local RPH = floor(earnedAmount / (timeonline / 60 / 60))
                    local RPM = floor(earnedAmount / (timeonline / 60))

                    if (TitanGetVar(TITANREP_ID, "ShowSessionSummaryDuration")) then
                        if (RPH > 0) then
                            if (COLOR) then
                                RPH_STRING = TitanUtils_GetGreenText(RPH) .. TitanUtils_GetColoredText("/h ", COLOR) ..
                                    TitanUtils_GetGreenText(RPM) .. TitanUtils_GetColoredText("/min", COLOR)
                            else
                                RPH_STRING = TitanUtils_GetGreenText(RPH) ..
                                    "/h " .. TitanUtils_GetGreenText(RPM) .. "/min"
                            end
                        else
                            if (COLOR) then
                                RPH_STRING = TitanUtils_GetRedText(RPH) .. TitanUtils_GetColoredText("/h ", COLOR) ..
                                    TitanUtils_GetRedText(RPM) .. TitanUtils_GetColoredText("/min ", COLOR)
                            else
                                RPH_STRING = TitanUtils_GetRedText(RPH) .. "/h " .. TitanUtils_GetRedText(RPM) .. "/min"
                            end
                        end

                        if (COLOR) then
                            TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT ..
                                TitanUtils_GetColoredText(" @ ", COLOR) .. RPH_STRING
                        else
                            TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT .. " @ " .. RPH_STRING
                        end
                    end

                    -- Calculate time to next level
                    if (TitanGetVar(TITANREP_ID, "ShowSessionSummaryTTL")) then
                        local TTL_STRING = ""
                        local timeToNextLevel = TitanPanelReputationUtils_CalculateTimeToNextLevel(earnedValue, topValue,
                            RPH)
                        local hours = floor(timeToNextLevel)
                        local minutes = floor((timeToNextLevel * 60) % 60)

                        if (hours > 0) then
                            if (COLOR) then
                                TTL_STRING = TitanUtils_GetColoredText("TTL: ", COLOR) ..
                                    hours .. "hrs " .. minutes .. "mins"
                            else
                                TTL_STRING = "TTL: " .. hours .. "hrs " .. minutes .. "mins"
                            end
                        else
                            if (COLOR) then
                                TTL_STRING = TitanUtils_GetColoredText("TTL: ", COLOR) .. minutes .. "mins"
                            else
                                TTL_STRING = "TTL: " .. minutes .. " mins"
                            end
                        end

                        TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT .. " - " .. TTL_STRING
                    end
                end

                TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT
            end
        end

        if (not (TitanGetVar(TITANREP_ID, "ShowFactionName") or
                TitanGetVar(TITANREP_ID, "ShowStanding") or
                TitanGetVar(TITANREP_ID, "ShowValue") or
                TitanGetVar(TITANREP_ID, "ShowPercent") or
                TitanGetVar(TITANREP_ID, "ShowSummary"))) then
            TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT .. TITANREP_ALL_HIDDEN_LABEL
        end
    end
end

function TitanPanelReputation_GetToolTipText()
    RTS_HAS_ENTRIES = false
    TITANREP_TOOLTIP_TEXT = ""
    TOTAL_EXALTED = 0
    TOTAL_BESTFRIENDS = 0
    LAST_HEADER = { "HEADER", 1 }

    TitanPanelReputation_GatherFactions(TitanPanelReputation_BuildToolTipText)

    if (TitanGetVar(TITANREP_ID, "ShowTipSessionSummaryDuration") or TitanGetVar(TITANREP_ID, "ShowTipSessionSummaryTTL")) then
        local timeonline = GetTime() - TITANREP_TIME

        RTS_HAS_ENTRIES = (next(TITANREP_RTS) ~= nil)

        if RTS_HAS_ENTRIES then
            local humantime = TitanPanelReputationUtils_GetHumanReadableTime(timeonline)

            TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT ..
                "\n" ..
                TitanUtils_GetHighlightText(TITANREP_SESSION_SUMMARY .. ":") ..
                "\t" .. TitanUtils_GetNormalText(TITANREP_SESSION_SUMMARY_DURATION .. ": " .. humantime)

            for f, v in pairs(TITANREP_RTS) do
                local RPH_STRING = ""
                local RPH = floor(v / (timeonline / 60 / 60))
                local RPM = floor(v / (timeonline / 60))

                if (RPH > 0) then
                    RPH_STRING = TitanUtils_GetGoldText(f) .. ": " .. TitanUtils_GetGreenText(RPH) .. "/h " ..
                        TitanUtils_GetGreenText(RPM) .. "/min " ..
                        "\t Total: " .. TitanUtils_GetGreenText(v)
                else
                    RPH_STRING = TitanUtils_GetGoldText(f) .. " : " .. TitanUtils_GetRedText(RPH) .. "/h " ..
                        TitanUtils_GetRedText(RPM) .. "/min " ..
                        "\t Total: " .. TitanUtils_GetGreenText(v)
                end

                -- Calculate time to next level
                if (TitanGetVar(TITANREP_ID, "ShowTipSessionSummaryTTL")) then
                    -- Retrieve the earnedValue and topValue for the faction
                    local _, _, _, _, topValue, earnedValue, _, _, _, _, _, _, _, _, _, _ =
                        TitanPanelReputationUtils_GetFactionInfoByName(f)

                    local TTL_STRING = ""
                    local timeToNextLevel = TitanPanelReputationUtils_CalculateTimeToNextLevel(earnedValue, topValue,
                        RPH)
                    local hours = floor(timeToNextLevel)
                    local minutes = floor((timeToNextLevel * 60) % 60)

                    if (hours > 0) then
                        TTL_STRING = "TTL: " .. hours .. "hrs " .. minutes .. "mins"
                    else
                        TTL_STRING = "TTL: " .. minutes .. " mins"
                    end

                    RPH_STRING = RPH_STRING .. " - " .. TTL_STRING
                end

                TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT .. "\n  " .. RPH_STRING
            end

            TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT .. "\n"
        end
    end

    if (TitanGetVar(TITANREP_ID, "ShowTipExaltedTotal") == 1) then
        TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT ..
            "\n" .. TitanUtils_GetHighlightText(TITANREP_SESSION_SUMMARY_TOTAL_EXALTED_FACTIONS .. ":")
        TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT .. "\t" ..
            TitanUtils_GetGoldText(TITANREP_SESSION_SUMMARY_FACTIONS .. ": ") ..
            TitanUtils_GetGreenText(TOTAL_EXALTED) ..
            TitanUtils_GetGoldText(" " .. TITANREP_SESSION_SUMMARY_FRIENDS .. ": ") ..
            TitanUtils_GetGreenText(TOTAL_BESTFRIENDS) ..
            TitanUtils_GetGoldText(" " .. TITANREP_SESSION_SUMMARY_TOTAL .. ": ") ..
            TitanUtils_GetGreenText((TOTAL_EXALTED + TOTAL_BESTFRIENDS)) .. "\n"
    end

    return TITANREP_TOOLTIP_TEXT
end

function TitanPanelReputation_BuildToolTipText(name, parentName, standingID, topValue, earnedValue, percent, isHeader,
                                               isCollapsed, isInactive, hasRep, isChild, isFriendship, factionID,
                                               hasBonusRepGain)
    local showrep = 0
    local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold
    local adjustedId = standingID

    if isFriendship then
        local reputationInfo = C_GossipInfo.GetFriendshipReputation(factionID)

        friendID = reputationInfo["friendshipFactionID"]
        friendRep = reputationInfo["standing"]
        friendMaxRep = reputationInfo["maxRep"]
        friendName = reputationInfo["name"]
        friendText = reputationInfo["text"]
        friendTexture = reputationInfo["texture"]
        friendTextLevel = reputationInfo["reaction"]
        friendThreshold = reputationInfo["reactionThreshold"]
        nextFriendThreshold = reputationInfo["nextThreshold"]

        if not nextFriendThreshold then
            adjustedId = 8
            TOTAL_BESTFRIENDS = TOTAL_BESTFRIENDS + 1
        end
    elseif standingID == 8 then
        TOTAL_EXALTED = TOTAL_EXALTED + 1
    end

    if hasBonusRepGain then
        adjustedId = 9
    end

    local factionHeaders = TitanGetVar(TITANREP_ID, "FactionHeaders")
    if factionHeaders and tContains(factionHeaders, parentName) then
        return
    end

    TitanPanelReputationSetColor()

    local preface = TitanUtils_GetHighlightText(" - ")
    local postface = ""

    if (isInactive) then
        showrep = 0
    else
        showrep = 1
    end

    if (isHeader) then
        LAST_HEADER = { name, 0 }

        if (isHeader and hasRep) then
            showrep = 1
        else
            showrep = 0
        end
    end

    if (showrep == 1) then
        showrep = 0

        if isFriendship then
            if TitanGetVar(TITANREP_ID, "ShowFriendships") then
                showrep = 1
            end
        else
            if (standingID == 8 and TitanGetVar(TITANREP_ID, "ShowExalted")) then showrep = 1 end
            if (standingID == 8 and hasBonusRepGain) then showrep = 1 end
            if (standingID == 7 and TitanGetVar(TITANREP_ID, "ShowRevered")) then showrep = 1 end
            if (standingID == 6 and TitanGetVar(TITANREP_ID, "ShowHonored")) then showrep = 1 end
            if (standingID == 5 and TitanGetVar(TITANREP_ID, "ShowFriendly")) then showrep = 1 end
            if (standingID == 4 and TitanGetVar(TITANREP_ID, "ShowNeutral")) then showrep = 1 end
            if (standingID == 3 and TitanGetVar(TITANREP_ID, "ShowUnfriendly")) then showrep = 1 end
            if (standingID == 2 and TitanGetVar(TITANREP_ID, "ShowHostile")) then showrep = 1 end
            if (standingID == 1 and TitanGetVar(TITANREP_ID, "ShowHated")) then showrep = 1 end
        end


        if (showrep == 1) then
            local LABEL = getglobal("FACTION_STANDING_LABEL" .. standingID)
            if isFriendship then LABEL = friendTextLevel end

            if hasBonusRepGain and not (isFriendship and not nextFriendThreshold) and not (adjustedId >= 8 and topValue == 0) then
                LABEL = TITANREP_PARAGON
            end

            if factionID and C_Reputation.IsMajorFaction(factionID) then
                local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)

                if majorFactionData ~= nil then
                    LABEL = tostring(majorFactionData.renownLevel)
                end
                adjustedId = 10
            end

            if TitanGetVar(TITANREP_ID, "ShortTipStanding") then
                LABEL = LABEL and
                    strsub(LABEL, 1, adjustedId == 10 and 2 or 1) or ""
            end

            if (LAST_HEADER[2] == 0) then
                --if(LAST_HEADER[1] == TITANREP_GUILDLOCAL) then
                if (factionID == gFactionID) then
                    TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT .. "\n" .. TitanUtils_GetHighlightText(LAST_HEADER[1])
                else
                    TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT ..
                        "\n" .. TitanUtils_GetHighlightText(LAST_HEADER[1]) .. "\n"
                end
                LAST_HEADER[2] = 1
            end

            if (MYBARCOLORS) then
                TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT .. preface
                if ((standingID == 8 and not hasBonusRepGain) or topValue == 1000 or topValue == 0) then
                    TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT ..
                        TitanUtils_GetColoredText(name, MYBARCOLORS[8]) .. postface .. "\t"
                    TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT .. TitanUtils_GetColoredText(LABEL, MYBARCOLORS[8])
                else
                    TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT ..
                        TitanUtils_GetColoredText(name, MYBARCOLORS[(adjustedId)]) .. postface .. "\t"
                    if (TitanGetVar(TITANREP_ID, "ShowTipReputationValue")) then
                        TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT ..
                            TitanUtils_GetColoredText("[" .. earnedValue .. "/" .. topValue .. "]",
                                MYBARCOLORS[(adjustedId)]) .. " "
                    end
                    if (TitanGetVar(TITANREP_ID, "ShowTipPercent")) then
                        TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT ..
                            TitanUtils_GetColoredText(percent .. "%", MYBARCOLORS[(adjustedId)]) .. " "
                    end
                    if (TitanGetVar(TITANREP_ID, "ShowTipStanding")) then
                        TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT ..
                            TitanUtils_GetColoredText(LABEL, MYBARCOLORS[(adjustedId)])
                    end
                end
            else
                TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT .. preface
                if (standingID == 8) then
                    TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT .. name .. postface .. "\t"
                    TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT .. LABEL
                else
                    TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT .. name .. postface .. "\t"
                    if (TitanGetVar(TITANREP_ID, "ShowTipReputationValue")) then
                        TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT .. "[" .. earnedValue .. "/" .. topValue .. "] "
                    end
                    if (TitanGetVar(TITANREP_ID, "ShowTipPercent")) then
                        TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT .. percent .. "% "
                    end
                    if (TitanGetVar(TITANREP_ID, "ShowTipStanding")) then
                        if LABEL then
                            TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT ..
                                strsub(LABEL, 1, adjustedId == 10 and 2 or 1)
                        else
                            TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT .. ""
                        end
                    end
                end
            end
            TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT .. "\n"
        end
    end
end

function TitanPanelRightClickMenu_AddTitle2(title, level)
    if (title) then
        local info = {}
        info.text = title
        info.notClickable = 1
        info.isTitle = 1
        info.notCheckable = true
        TitanPanelRightClickMenu_AddButton(info, level)
    end
end

function TitanPanelRightClickMenu_AddToggleVar2(text, id, var, toggleTable, level, noclose)
    if not level then level = 2 end
    local info = {}
    info.text = text
    info.value = { id, var, toggleTable }
    if noclose then
        info.func = function()
            TitanPanelRightClickMenu_ToggleVar({ id, var, toggleTable })
        end
    else
        info.func = function()
            TitanPanelRightClickMenu_ToggleVar({ id, var, toggleTable })
            TitanPanelRightClickMenu_Close()
        end
    end
    info.checked = TitanGetVar(id, var)
    info.keepShownOnClick = 1
    TitanPanelRightClickMenu_AddButton(info, level)
end

function TitanPanelRightClickMenu_AddToggleIcon2(id)
    TitanPanelRightClickMenu_AddToggleVar2("Show Icon", id, "ShowIcon")
end

function TitanPanelRightClickMenu_AddSpacer2(level)
    local info = {}
    info.disabled = 1
    info.notCheckable = true
    TitanPanelRightClickMenu_AddButton(info, level)
end

-- this method builds the right-click menus
function TitanPanelRightClickMenu_PrepareReputationMenu()
    local info = {}
    info.hasArrow = nil
    info.notCheckable = nil
    info.text = nil
    info.value = nil
    info.func = nil
    info.disabled = nil
    info.checked = nil

    -- level 2 menus
    if (TitanPanelRightClickMenu_GetDropdownLevel() == 3) then
        if TitanPanelRightClickMenu_GetDropdMenuValue() == "Friendship Rank Settings" then
            TitanPanelRightClickMenu_AddTitle2(TitanPanelRightClickMenu_GetDropdMenuValue(),
                TitanPanelRightClickMenu_GetDropdownLevel())
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_FRIENDSHIPS, TITANREP_ID, "ShowFriendships", "", 3, true)
            TitanPanelRightClickMenu_AddSpacer2(3)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_BESTFRIEND, TITANREP_ID, "ShowBESTFRIEND", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_GOODFRIEND, TITANREP_ID, "ShowGOODFRIEND", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_FRIEND, TITANREP_ID, "ShowFRIEND", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_BUDDY, TITANREP_ID, "ShowBUDDY", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_ACQUAINTANCE, TITANREP_ID, "ShowACQUAINTANCE", "", 3,
                true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_STRANGER, TITANREP_ID, "ShowSTRANGER", "", 3, true)
        end

        if TitanPanelRightClickMenu_GetDropdMenuValue() == "Reputation Standing Settings" then
            TitanPanelRightClickMenu_AddTitle2(TitanPanelRightClickMenu_GetDropdMenuValue(),
                TitanPanelRightClickMenu_GetDropdownLevel())
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_EXALTED, TITANREP_ID, "ShowExalted", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_REVERED, TITANREP_ID, "ShowRevered", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_HONORED, TITANREP_ID, "ShowHonored", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_FRIENDLY, TITANREP_ID, "ShowFriendly", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_NEUTRAL, TITANREP_ID, "ShowNeutral", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_UNFRIENDLY, TITANREP_ID, "ShowUnfriendly", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_HOSTILE, TITANREP_ID, "ShowHostile", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_HATED, TITANREP_ID, "ShowHated", "", 3, true)
        end

        if TitanPanelRightClickMenu_GetDropdMenuValue() == "Tooltip Scale" then
            TitanPanelRightClickMenu_AddTitle2("CAUTION: This effects ALL tooltips",
                TitanPanelRightClickMenu_GetDropdownLevel())
            info.text = TITANREP_SCALE_INCREASE
            info.notCheckable = true
            if TitanGetVar(TITANREP_ID, "ToolTipScale") >= 1.2 then
                info.disabled = true
                info.func = nil
            else
                info.disabled = nil
                info.func = function()
                    TitanSetVar(TITANREP_ID, "ToolTipScale", TitanGetVar(TITANREP_ID, "ToolTipScale") + .1)
                    TitanPanelButton_UpdateButton(TITANREP_ID)
                    TitanPanelRightClickMenu_Close()
                end
            end
            TitanPanelRightClickMenu_AddButton(info, 3)
            info.text = TITANREP_SCALE_DECREASE
            if TitanGetVar(TITANREP_ID, "ToolTipScale") <= .4 then
                info.disabled = true
                info.func = nil
            else
                info.disabled = nil
                info.func = function()
                    TitanSetVar(TITANREP_ID, "ToolTipScale", TitanGetVar(TITANREP_ID, "ToolTipScale") - .1)
                    TitanPanelButton_UpdateButton(TITANREP_ID)
                    TitanPanelRightClickMenu_Close()
                end
            end
            TitanPanelRightClickMenu_AddButton(info, 3)
        end

        -- Button Options
        if TitanPanelRightClickMenu_GetDropdMenuValue() == TITANREP_SESSION_SUMMARY_SETTINGS then
            TitanPanelRightClickMenu_AddTitle2(TITANREP_SESSION_SUMMARY_SETTINGS,
                TitanPanelRightClickMenu_GetDropdownLevel())
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_SUMMARY_DURATION,
                TITANREP_ID, "ShowSessionSummaryDuration", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_SUMMARY_TTL,
                TITANREP_ID, "ShowSessionSummaryTTL", "", 3, true)
        end

        -- Tooltip Options
        if TitanPanelRightClickMenu_GetDropdMenuValue() == TITANREP_TIP_SESSION_SUMMARY_SETTINGS then
            TitanPanelRightClickMenu_AddTitle2(TITANREP_SESSION_SUMMARY_SETTINGS,
                TitanPanelRightClickMenu_GetDropdownLevel())
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_TIP_SHOW_SUMMARY_DURATION,
                TITANREP_ID, "ShowTipSessionSummaryDuration", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_TIP_SHOW_SUMMARY_TTL,
                TITANREP_ID, "ShowTipSessionSummaryTTL", "", 3, true)
        end

        return
    end

    if (TitanPanelRightClickMenu_GetDropdownLevel() == 2) then
        TitanPanelRightClickMenu_AddTitle2(TitanPanelRightClickMenu_GetDropdMenuValue(),
            TitanPanelRightClickMenu_GetDropdownLevel())
        TitanPanelReputation_GatherFactions(TitanPanelReputation_BuildFactionSubMenu)

        if TitanPanelRightClickMenu_GetDropdMenuValue() == "Button Options" then
            info.text = TITANREP_DisplayOnRightSide
            if TitanGetVar(TITANREP_ID, "DisplayOnRightSide") then
                info.checked = 1
            else
                info.checked = nil
            end
            info.func = function()
                if TitanGetVar(TITANREP_ID, "DisplayOnRightSide") then
                    TitanSetVar(TITANREP_ID, "DisplayOnRightSide", nil)
                else
                    TitanSetVar(TITANREP_ID, "DisplayOnRightSide", 1)
                end
                TitanPanelRightClickMenu_Close()
                TitanPanel_InitPanelButtons()
            end
            TitanPanelRightClickMenu_AddButton(info, 2)

            TitanPanelRightClickMenu_AddToggleIcon2(TITANREP_ID, TitanPanelRightClickMenu_GetDropdownLevel())
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_ShowFriendsOnBar, TITANREP_ID, "ShowFriendsOnBar", "", 2,
                true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_FACTION_NAME_LABEL, TITANREP_ID, "ShowFactionName", "",
                2,
                true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_STANDING, TITANREP_ID, "ShowStanding", "", 2, true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHORT_STANDING, TITANREP_ID, "ShortStanding", "", 2, true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_VALUE, TITANREP_ID, "ShowValue", "", 2, true)
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_PERCENT, TITANREP_ID, "ShowPercent", "", 2, true)

            info.disabled = nil
            info.func = nil
            info.hasArrow = true
            info.notCheckable = true
            info.text = TITANREP_SESSION_SUMMARY_SETTINGS
            info.value = TITANREP_SESSION_SUMMARY_SETTINGS
            TitanPanelRightClickMenu_AddButton(info, 2)
        end

        if TitanPanelRightClickMenu_GetDropdMenuValue() == "Tooltip Options" then
            info.disabled = nil
            info.func = nil
            info.hasArrow = true
            info.notCheckable = true
            info.text = "Tooltip Scale (" .. (TitanGetVar(TITANREP_ID, "ToolTipScale") * 100) .. "%)"
            info.value = "Tooltip Scale"
            TitanPanelRightClickMenu_AddButton(info, 2)

            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_MINIMAL, TITANREP_ID, "MinimalTip")

            TitanPanelRightClickMenu_AddSpacer2(2)

            info.text = "Friendship Rank Settings"
            info.value = "Friendship Rank Settings"
            TitanPanelRightClickMenu_AddButton(info, 2)

            info.text = "Reputation Standing Settings"
            info.value = "Reputation Standing Settings"
            TitanPanelRightClickMenu_AddButton(info, 2)

            TitanPanelRightClickMenu_AddSpacer2(2)

            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_VALUE, TITANREP_ID, "ShowTipReputationValue")
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_PERCENT, TITANREP_ID, "ShowTipPercent")
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_STANDING, TITANREP_ID, "ShowTipStanding")
            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHORT_STANDING, TITANREP_ID, "ShortTipStanding")

            TitanPanelRightClickMenu_AddSpacer2(2)

            TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_STATS, TITANREP_ID, "ShowTipExaltedTotal")

            info.text = TITANREP_SESSION_SUMMARY_SETTINGS
            info.value = TITANREP_TIP_SESSION_SUMMARY_SETTINGS
            TitanPanelRightClickMenu_AddButton(info, 2)
        end

        if TitanPanelRightClickMenu_GetDropdMenuValue() == "Color Options" then
            info.disabled = nil
            info.hasArrow = nil
            info.notCheckable = nil
            info.value = nil

            info.text = TITANREP_DEFAULT_COLORS
            info.checked = function() if TitanGetVar(TITANREP_ID, "ColorValue") == 1 then return true else return nil end end
            info.func = function()
                TitanSetVar(TITANREP_ID, "ColorValue", 1)
                TitanPanelButton_UpdateButton(TITANREP_ID)
                TitanPanelRightClickMenu_Close()
            end
            TitanPanelRightClickMenu_AddButton(info, 2)

            info.text = TITANREP_ARMORY_COLORS
            info.checked = function() if TitanGetVar(TITANREP_ID, "ColorValue") == 2 then return true else return nil end end
            info.func = function()
                TitanSetVar(TITANREP_ID, "ColorValue", 2)
                TitanPanelButton_UpdateButton(TITANREP_ID)
                TitanPanelRightClickMenu_Close()
            end
            TitanPanelRightClickMenu_AddButton(info, 2)

            info.text = TITANREP_NO_COLORS
            info.checked = function() if TitanGetVar(TITANREP_ID, "ColorValue") == 3 then return true else return nil end end
            info.func = function()
                TitanSetVar(TITANREP_ID, "ColorValue", 3)
                TitanPanelButton_UpdateButton(TITANREP_ID)
                TitanPanelRightClickMenu_Close()
            end
            TitanPanelRightClickMenu_AddButton(info, 2)
        end
        return
    end

    -- level 1 menu
    TitanPanelRightClickMenu_AddTitle2(TitanPlugins[TITANREP_ID].menuText .. " v" .. TITANREP_VERSION)
    TitanPanelRightClickMenu_AddToggleVar(TITANREP_AUTO_CHANGE, TITANREP_ID, "AutoChange")
    TitanPanelRightClickMenu_AddToggleVar(TITANREP_SHOW_ANNOUNCE, TITANREP_ID, "ShowAnnounce")

    if (C_AddOns.IsAddOnLoaded("MikScrollingBattleText")) then
        TitanPanelRightClickMenu_AddToggleVar(TITANREP_SHOW_ANNOUNCE_MIK, TITANREP_ID, "ShowAnnounceMik")
    end

    -- TODO: Implement achivement style announcements based on official WoW API
    -- if (C_AddOns.IsAddOnLoaded("Glamour")) then
    --     TitanPanelRightClickMenu_AddToggleVar(TITANREP_SHOW_ANNOUNCE_FRAME, TITANREP_ID, "ShowAnnounceFrame")
    -- end

    TitanPanelRightClickMenu_AddSpacer2()
    TitanPanelReputation_GatherFactions(TitanPanelReputation_BuildRightClickMenu)
    TitanPanelRightClickMenu_AddSpacer2()

    info.checked = nil
    info.hasArrow = true
    info.notCheckable = true
    info.text = "Button Options"
    info.value = "Button Options"
    TitanPanelRightClickMenu_AddButton(info, 1)

    info.text = "Tooltip Options"
    info.value = "Tooltip Options"
    TitanPanelRightClickMenu_AddButton(info, 1)

    info.text = "Color Options"
    info.value = "Color Options"
    TitanPanelRightClickMenu_AddButton(info, 1)

    TitanPanelRightClickMenu_AddSpacer2()

    info.hasArrow = false
    info.text = "Reset Session Data"
    info.value = nil
    info.func = function()
        wipe(TITANREP_RTS)
        TITANREP_TIME = GetTime()

        TitanPanelPluginHandle_OnUpdate(TITANREP_ID, 1) -- force update button

        TitanDebug("TitanPanelReputation Session Data Reset!")
        TitanPanelRightClickMenu_Close()
    end
    TitanPanelRightClickMenu_AddButton(info, 1)

    info.text = "Close Menu"
    info.value = "Close Menu"
    TitanPanelRightClickMenu_AddButton(info, 1)
end

function TitanPanelReputationHeaderFactionToggle(name)
    local value = ""
    local found = false
    local array = TitanGetVar(TITANREP_ID, "FactionHeaders")
    for index, value in ipairs(array) do
        if (value == name) then
            found = index
        end
    end
    if (found) then
        tremove(array, found)
    else
        tinsert(array, name)
    end
    TitanSetVar(TITANREP_ID, "FactionHeaders", array)
    return
end

-- this method adds a line to the right-click menu (to build up faction headers)
function TitanPanelReputation_BuildRightClickMenu(name, parentName, standingID, topValue, earnedValue, percent, isHeader,
                                                  isCollapsed, isInactive, hasRep, isChild, isFrienship, factionId,
                                                  hasBonusRepGain)
    if (not isInactive) then
        if (isHeader and not isCollapsed) then
            local command = {}
            command.text = name
            command.value = name
            command.hasArrow = 1
            command.keepShownOnClick = 1
            command.checked = function()
                if (tContains(TitanGetVar(TITANREP_ID, "FactionHeaders"), name)) then
                    return nil
                else
                    return true
                end
            end
            command.func = function()
                TitanPanelReputationHeaderFactionToggle(name)
                TitanPanelButton_UpdateButton(TITANREP_ID)
            end
            TitanPanelRightClickMenu_AddButton(command)
        end
    end
end

-- this method adds a line to the level2 right-click menu (to build up factions for parent header)
function TitanPanelReputation_BuildFactionSubMenu(name, parentName, standingID, topValue, earnedValue, percent, isHeader,
                                                  isCollapsed, isInactive, hasRep, isChild, isFriendship, factionID,
                                                  hasBonusRepGain)
    local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold
    local adjustedId = standingID
    if isFriendship then
        local reputationInfo = C_GossipInfo.GetFriendshipReputation(factionID)

        friendID = reputationInfo["friendshipFactionID"]
        friendRep = reputationInfo["standing"]
        friendMaxRep = reputationInfo["maxRep"]
        friendName = reputationInfo["name"]
        friendText = reputationInfo["text"]
        friendTexture = reputationInfo["texture"]
        friendTextLevel = reputationInfo["reaction"]
        friendThreshold = reputationInfo["reactionThreshold"]
        nextFriendThreshold = reputationInfo["nextThreshold"]

        if not nextFriendThreshold then adjustedId = 8 end
    end

    if hasBonusRepGain then
        adjustedId = 9
    end

    local LABEL = getglobal("FACTION_STANDING_LABEL" .. standingID)
    if isFriendship then LABEL = friendTextLevel end

    if hasBonusRepGain and not (isFriendship and not nextFriendThreshold) and not (adjustedId >= 8 and topValue == 0) then
        LABEL = TITANREP_PARAGON
    end

    if factionID and C_Reputation.IsMajorFaction(factionID) then
        local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)

        if majorFactionData ~= nil then
            LABEL = tostring(majorFactionData.renownLevel)
        end
        adjustedId = 10
    end

    if TitanGetVar(TITANREP_ID, "ShortTipStanding") then LABEL = strsub(LABEL, 1, adjustedId == 10 and 2 or 1) end

    if (parentName == TitanPanelRightClickMenu_GetDropdMenuValue() and (not isHeader or (isHeader and hasRep))) then
        local command = {}
        if (MYBARCOLORS) then
            command.text = TitanUtils_GetColoredText(name .. " - " .. LABEL, MYBARCOLORS[(adjustedId)])
        else
            command.text = name .. " - " .. LABEL
        end
        command.value = name
        command.func = TitanPanelReputation_SetFaction
        command.notCheckable = true
        TitanPanelRightClickMenu_AddButton(command, TitanPanelRightClickMenu_GetDropdownLevel())
    end
end

-- this method sets the selected faction shown at titan panel
function TitanPanelReputation_SetFaction(this)
    TitanSetVar(TITANREP_ID, "TITANREP_WATCHED_FACTION", this.value)
    TitanPanelReputation_Refresh()
    TitanPanelButton_UpdateButton(TITANREP_ID)
end

-- This method refreshes the reputation data
function TitanPanelReputation_Refresh()
    if not (TitanGetVar(TITANREP_ID, "TITANREP_WATCHED_FACTION") == "none") then
        TitanPanelReputation_GatherFactions(TitanPanelReputation_BuildButtonText)
    else
        TITANREP_BUTTON_TEXT = TITANREP_NO_FACTION_LABEL
    end
end

-- saves all reputation value, so we can monitor what is changed
function TitanPanelReputation_GatherValues(name, parentName, standingID, topValue, earnedValue, percent, isHeader,
                                           isCollapsed, isInactive, hasRep, isChild, isFriendship, factionID,
                                           hasBonusRepGain)
    if TITANREP_TABLE_INIT then
        if hasBonusRepGain then
            if TitanRep_Data["BonusRep"] and TitanRep_Data["BonusRep"][factionID] then TitanRep_Data["BonusRep"][factionID] = nil end
        end

        if ((not isHeader and name) or (isHeader and hasRep)) then
            if not TITANREP_TABLE[factionID] and GetTime() - TITANREP_InitTime > 30 then
                local adjustedId = standingID
                local msg = ""
                local dsc = "You have obtained "
                local tag = " "
                local LABEL = getglobal("FACTION_STANDING_LABEL" .. standingID)
                local factionType = "Faction"

                if isFriendship then
                    if not TitanGetVar(TITANREP_ID, "ShowFriendsOnBar") then return end
                    local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold

                    local reputationInfo = C_GossipInfo.GetFriendshipReputation(factionID)

                    friendID = reputationInfo["friendshipFactionID"]
                    friendRep = reputationInfo["standing"]
                    friendMaxRep = reputationInfo["maxRep"]
                    friendName = reputationInfo["name"]
                    friendText = reputationInfo["text"]
                    friendTexture = reputationInfo["texture"]
                    friendTextLevel = reputationInfo["reaction"]
                    friendThreshold = reputationInfo["reactionThreshold"]
                    nextFriendThreshold = reputationInfo["nextThreshold"]

                    if not nextFriendThreshold then adjustedId = 8 end

                    LABEL = friendTextLevel
                    factionType = "Friendship"
                end

                if hasBonusRepGain and not (isFriendship and not nextFriendThreshold) and
                    not (adjustedId >= 8 and topValue == 0) then
                    adjustedId = 9
                    LABEL = TITANREP_PARAGON
                end

                if factionID and C_Reputation.IsMajorFaction(factionID) then
                    local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)

                    if majorFactionData ~= nil then
                        LABEL = tostring(majorFactionData.renownLevel)
                    end
                    adjustedId = 10
                end

                if (MYBARCOLORS) then
                    msg = TitanUtils_GetColoredText(name .. " - " .. LABEL, MYBARCOLORS[(adjustedId)])
                    dsc = dsc .. TitanUtils_GetColoredText(LABEL, MYBARCOLORS[(adjustedId)])
                else
                    msg = TitanUtils_GetGoldText(name .. " - " .. LABEL)
                    dsc = dsc .. TitanUtils_GetGoldText(LABEL)
                end

                dsc = dsc .. " standing with " .. name .. "."
                msg = tag .. msg .. tag

                if (TitanGetVar(TITANREP_ID, "ShowAnnounce")) then
                    if (C_AddOns.IsAddOnLoaded("MikScrollingBattleText") and TitanGetVar(TITANREP_ID, "ShowAnnounceMik")) then
                        MikSBT.DisplayMessage(
                            "|T" .. TITANREP_BUTTON_ICON .. ":32|t" .. msg .. "|T" .. TITANREP_BUTTON_ICON ..
                            ":32|t", "Notification", 1)
                    else
                        UIErrorsFrame:AddMessage("|T" .. TITANREP_BUTTON_ICON .. ":32|t" .. msg ..
                            "|T" .. TITANREP_BUTTON_ICON .. ":32|t", 2.0, 2.0, 0.0, 1.0, 53, 30)
                    end
                end

                -- TODO: Implement achivement style announcements based on official WoW API
                -- if (TitanGetVar(TITANREP_ID, "ShowAnnounceFrame")) then
                --     if (C_AddOns.IsAddOnLoaded("Glamour")) then
                --         local MyData = {}
                --         MyData.Text = name .. " - " .. LABEL
                --         MyData.Icon = "Interface\\ICONS\\Achievement_Reputation_" .. TITANREP_ICONS[(adjustedId)]
                --         local color = {}
                --         color.r = TITANREP_COLORS_ARMORY[(adjustedId)].r
                --         color.g = TITANREP_COLORS_ARMORY[(adjustedId)].g
                --         color.b = TITANREP_COLORS_ARMORY[(adjustedId)].b
                --         MyData.bTitle = "New " .. factionType .. " Discovered"
                --         MyData.Title = "You have discovered"
                --         MyData.FrameStyle = "GuildAchievement"
                --         MyData.BannerColor = color
                --         local LastAlertFrame = GlamourShowAlert(400, MyData, color, color)
                --     end
                -- end
            end
        end
    end

    if ((not isHeader and name) or (isHeader and hasRep)) then
        TITANREP_TABLE[factionID] = {}
        TITANREP_TABLE[factionID].standingID = standingID
        TITANREP_TABLE[factionID].earnedValue = earnedValue
        TITANREP_TABLE[factionID].topValue = topValue
    end
end

-- gets the faction name where reputation changed
function TitanPanelReputation_GetChangedName(name, parentName, standingID, topValue, earnedValue, percent, isHeader,
                                             isCollapsed, isInactive, hasRep, isChild, isFriendship, factionID,
                                             hasBonusRepGain)
    local earnedAmount = 0
    local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold
    local adjustedId = standingID
    local factionType = "Faction Standing"

    if isFriendship then
        local reputationInfo = C_GossipInfo.GetFriendshipReputation(factionID)

        friendID = reputationInfo["friendshipFactionID"]
        friendRep = reputationInfo["standing"]
        friendMaxRep = reputationInfo["maxRep"]
        friendName = reputationInfo["name"]
        friendText = reputationInfo["text"]
        friendTexture = reputationInfo["texture"]
        friendTextLevel = reputationInfo["reaction"]
        friendThreshold = reputationInfo["reactionThreshold"]
        nextFriendThreshold = reputationInfo["nextThreshold"]

        if not nextFriendThreshold then adjustedId = 8 end
        if not TitanGetVar(TITANREP_ID, "ShowFriendsOnBar") then return end
        factionType = "Friendship Ranking"
    end

    if hasBonusRepGain then
        adjustedId = 9
    end

    local LABEL = getglobal("FACTION_STANDING_LABEL" .. standingID)

    if isFriendship then LABEL = friendTextLevel end

    if hasBonusRepGain and not (isFriendship and not nextFriendThreshold) and not (adjustedId >= 8 and topValue == 0) then
        LABEL = TITANREP_PARAGON
    end

    if factionID and C_Reputation.IsMajorFaction(factionID) then
        local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)

        if majorFactionData ~= nil then
            LABEL = tostring(majorFactionData.renownLevel)
        end
        adjustedId = 10
    end

    if (not (factionID == gFactionID) and TITANREP_TABLE[factionID]) then
        if (GetTime() - TITANREP_InitTime > 30 and (TITANREP_TABLE[factionID].standingID < standingID) or (TITANREP_TABLE[factionID].earnedValue ~= earnedValue)) then
            local msg = ""
            local dsc = "You have obtained "
            local tag = " "
            if (TITANREP_TABLE[factionID].standingID < standingID) then
                if (MYBARCOLORS) then
                    msg = TitanUtils_GetColoredText(name .. " - " .. LABEL, MYBARCOLORS[(adjustedId)])
                    dsc = dsc .. TitanUtils_GetColoredText(LABEL, MYBARCOLORS[(adjustedId)])
                else
                    msg = TitanUtils_GetGoldText(name .. " - " .. LABEL)
                    dsc = dsc .. TitanUtils_GetGoldText(LABEL)
                end

                dsc = dsc .. " standing with " .. name .. "."
                msg = tag .. msg .. tag

                if (TitanGetVar(TITANREP_ID, "ShowAnnounce")) then
                    if (C_AddOns.IsAddOnLoaded("MikScrollingBattleText") and TitanGetVar(TITANREP_ID, "ShowAnnounceMik")) then
                        MikSBT.DisplayMessage(
                            "|T" .. TITANREP_BUTTON_ICON .. ":32|t" .. msg .. "|T" .. TITANREP_BUTTON_ICON ..
                            ":32|t", "Notification", 1)
                    else
                        UIErrorsFrame:AddMessage("|T" .. TITANREP_BUTTON_ICON .. ":32|t" .. msg ..
                            "|T" .. TITANREP_BUTTON_ICON .. ":32|t", 2.0, 2.0, 0.0, 1.0, 53, 30)
                    end
                end

                -- TODO: Implement achivement style announcements based on official WoW API
                -- if (TitanGetVar(TITANREP_ID, "ShowAnnounceFrame")) then
                --     if (C_AddOns.IsAddOnLoaded("Glamour")) then
                --         local MyData = {}
                --         MyData.Text = name .. " - " .. LABEL
                --         MyData.Icon = "Interface\\ICONS\\Achievement_Reputation_" .. TITANREP_ICONS[(adjustedId)]
                --         local color = {}
                --         color.r = TITANREP_COLORS_ARMORY[(adjustedId)].r
                --         color.g = TITANREP_COLORS_ARMORY[(adjustedId)].g
                --         color.b = TITANREP_COLORS_ARMORY[(adjustedId)].b
                --         MyData.bTitle = factionType .. " Upgrade"
                --         MyData.Title = ""
                --         MyData.FrameStyle = "GuildAchievement"
                --         MyData.BannerColor = color
                --         local LastAlertFrame = GlamourShowAlert(400, MyData, color, color)
                --     end
                -- end

                earnedAmount = TITANREP_TABLE[factionID].topValue - TITANREP_TABLE[factionID].earnedValue
                earnedAmount = earnedValue + earnedAmount
            elseif (TITANREP_TABLE[factionID].standingID > standingID) then
                if (MYBARCOLORS) then
                    msg = TitanUtils_GetColoredText(name .. " - " .. LABEL, MYBARCOLORS[(adjustedId)])
                    dsc = dsc .. TitanUtils_GetColoredText(LABEL, MYBARCOLORS[(adjustedId)])
                else
                    msg = TitanUtils_GetGoldText(name .. " - " .. LABEL)
                    dsc = dsc .. TitanUtils_GetGoldText(LABEL)
                end

                dsc = dsc .. " standing with " .. name .. "."
                msg = tag .. msg .. tag

                if (TitanGetVar(TITANREP_ID, "ShowAnnounce")) then
                    if (C_AddOns.IsAddOnLoaded("MikScrollingBattleText") and TitanGetVar(TITANREP_ID, "ShowAnnounceMik")) then
                        MikSBT.DisplayMessage(
                            "|T" .. TITANREP_BUTTON_ICON .. ":32|t" .. msg .. "|T" .. TITANREP_BUTTON_ICON ..
                            ":32|t", "Notification", 1)
                    else
                        UIErrorsFrame:AddMessage("|T" .. TITANREP_BUTTON_ICON .. ":32|t" .. msg ..
                            "|T" .. TITANREP_BUTTON_ICON .. ":32|t", 2.0, 2.0, 0.0, 1.0, 53, 30)
                    end
                end

                -- TODO: Implement achivement style announcements based on official WoW API
                -- if (TitanGetVar(TITANREP_ID, "ShowAnnounceFrame")) then
                --     if (C_AddOns.IsAddOnLoaded("Glamour")) then
                --         local MyData = {}
                --         MyData.Text = name .. " - " .. LABEL
                --         MyData.Icon = "Interface\\ICONS\\Achievement_Reputation_" .. TITANREP_ICONS[(adjustedId)]
                --         local color = {}
                --         color.r = TITANREP_COLORS_ARMORY[(adjustedId)].r
                --         color.g = TITANREP_COLORS_ARMORY[(adjustedId)].g
                --         color.b = TITANREP_COLORS_ARMORY[(adjustedId)].b
                --         MyData.bTitle = factionType .. " Downgrade"
                --         MyData.Title = ""
                --         MyData.FrameStyle = "GuildAchievement"
                --         MyData.BannerColor = color
                --         local LastAlertFrame = GlamourShowAlert(400, MyData, color, color)
                --     end
                -- end

                earnedAmount = earnedValue - topValue
                earnedAmount = earnedAmount - TITANREP_TABLE[factionID].earnedValue
            elseif (TITANREP_TABLE[factionID].standingID == standingID) then
                if (TITANREP_TABLE[factionID].earnedValue < earnedValue) then
                    earnedAmount = earnedValue - TITANREP_TABLE[factionID].earnedValue
                else
                    earnedAmount = earnedValue - TITANREP_TABLE[factionID].earnedValue
                end
            end
            if TITANREP_RTS[name] then
                TITANREP_RTS[name] = TITANREP_RTS[name] + earnedAmount
            else
                TITANREP_RTS[name] = earnedAmount
            end
            if earnedAmount > 0 then
                if TITANREP_HIGHCHANGED < earnedAmount then
                    TITANREP_HIGHCHANGED = earnedAmount
                    TITANREP_CHANGEDFACTION = name
                end
            elseif earnedAmount < 0 then
                if TITANREP_HIGHCHANGED > earnedAmount and TITANREP_HIGHCHANGED < 0 then
                    TITANREP_HIGHCHANGED = earnedAmount
                    TITANREP_CHANGEDFACTION = name
                end
            else
                TITANREP_CHANGEDFACTION = name
            end
        end
    end
end

-- This method looks up all factions, and calls 'method' with faction parameters
function TitanPanelReputation_GatherFactions(method)
    local count = GetNumFactions()
    if not count then return end

    local done = false
    local index = 1
    local parentName = ""

    while (not done) do
        local name, description, standingID, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus =
            GetFactionInfo(index)

        if factionID then
            local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold

            local reputationInfo = C_GossipInfo.GetFriendshipReputation(factionID)

            friendID = reputationInfo["friendshipFactionID"]
            friendRep = reputationInfo["standing"]
            friendMaxRep = reputationInfo["maxRep"]
            friendName = reputationInfo["name"]
            friendText = reputationInfo["text"]
            friendTexture = reputationInfo["texture"]
            friendTextLevel = reputationInfo["reaction"]
            friendThreshold = reputationInfo["reactionThreshold"]
            nextFriendThreshold = reputationInfo["nextThreshold"]

            local value

            -- Normalize values
            topValue = topValue - bottomValue
            earnedValue = earnedValue - bottomValue
            bottomValue = 0

            -- BonusRep Compatibility :: Issue #27 :: Code Provided by: SLOKnightfall
            if (C_Reputation.IsFactionParagon(factionID)) then
                earnedValue, topValue, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)

                local level = math.floor(earnedValue / topValue) - (hasRewardPending and 1 or 0)
                local realValue = level > 0 and tonumber(string.sub(earnedValue, string.len(level) + 1)) or earnedValue
                earnedValue = realValue
                hasBonusRepGain = true
            elseif (C_Reputation.IsMajorFaction(factionID)) then
                local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)

                if majorFactionData then
                    topValue = majorFactionData.renownLevelThreshold
                    earnedValue = C_MajorFactions.HasMaximumRenown(factionID) and majorFactionData.renownLevelThreshold or
                        majorFactionData.renownReputationEarned or 0
                end
            elseif (reputationInfo and friendID > 0) then
                if (nextFriendThreshold) then
                    bottomValue, topValue, earnedValue = 0, nextFriendThreshold - friendThreshold,
                        friendRep - friendThreshold
                else
                    bottomValue, topValue, earnedValue = 0, friendRep - friendThreshold, friendRep - friendThreshold
                end
            end

            local finalValue = 0
            if topValue > 0 then
                finalValue = (earnedValue / topValue)
            end

            local percent = format("%.2f", finalValue * 100)
            if (percent:len() < 5) then percent = "0" .. percent; end

            if (isHeader) and name then parentName = name; end

            method(name, parentName, standingID, topValue, earnedValue, percent, isHeader, isCollapsed,
                IsFactionInactive(index), hasRep, isChild, (friendID > 0) and true or false, factionID, hasBonusRepGain)
        end


        index = index + 1

        if (index > count) then done = true; end
    end
end

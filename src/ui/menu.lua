local _, TitanPanelReputation = ...

local WoW5 = select(4, GetBuildInfo()) >= 50000

local reservedMenuLabels
local function IsReservedMenuValue(value)
    if not value then return false end
    if not reservedMenuLabels then
        reservedMenuLabels = {
            [TitanPanelReputation:GT("LID_BUTTON_OPTIONS")] = true,
            [TitanPanelReputation:GT("LID_TOOLTIP_OPTIONS")] = true,
            [TitanPanelReputation:GT("LID_COLOR_OPTIONS")] = true,
            [TitanPanelReputation:GT("LID_FRIENDSHIP_RANK_SETTINGS")] = true,
            [TitanPanelReputation:GT("LID_REPUTATION_STANDING_SETTINGS")] = true,
            [TitanPanelReputation:GT("LID_TOOLTIP_SCALE")] = true,
            [TitanPanelReputation:GT("LID_SESSION_SUMMARY_SETTINGS")] = true,
            [TitanPanelReputation:GT("LID_TIP_SESSION_SUMMARY_SETTINGS")] = true,
        }
    end
    return reservedMenuLabels[value] or false
end

--[[ TitanPanelReputation
NAME: BuildRightClickMenu
DESC: Builds the faction headers part of the right-click menu.
]]
---@param factionDetails FactionDetails
local function BuildFactionHeaderMenu(factionDetails)
    -- Destructure props from FactionDetails
    local name, isHeader, isCollapsed, isInactive, headerLevel =
        factionDetails.name,
        factionDetails.isHeader,
        factionDetails.isCollapsed,
        factionDetails.isInactive,
        factionDetails.headerLevel

    if (not isInactive) and isHeader and (headerLevel or 0) == 0 then
        if not isCollapsed then
            local command = {}
            command.text = name
            command.value = name
            command.hasArrow = 1
            command.keepShownOnClick = 1
            command.checked = not TitanPanelReputation:IsFactionEffectivelyHidden(factionDetails)
            command.func = function()
                TitanPanelReputation:ToggleFactionVisibility(factionDetails)
                TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
            end
            TitanPanelRightClickMenu_AddButton(command)
        end
    end
end

--[[ TitanPanelReputation
NAME: BuildFactionHeaderSubMenu
DESC: Builds the faction headers sub menu part of the right-click menu.
]]
---@param factionDetails FactionDetails
local function BuildFactionHeaderSubMenu(factionDetails)
    -- Destructure props from FactionDetails
    local name, parentName, standingID, topValue, isHeader, hasRep, friendShipReputationInfo, factionID, headerLevel =
        factionDetails.name,
        factionDetails.parentName,
        factionDetails.standingID,
        factionDetails.topValue,
        factionDetails.isHeader,
        factionDetails.hasRep,
        factionDetails.friendShipReputationInfo,
        factionDetails.factionID,
        factionDetails.headerLevel

    -- Get adjusted ID and label depending on the faction type
    local adjustedIDAndLabel = TitanPanelReputation:GetAdjustedIDAndLabel(
        factionID, standingID, friendShipReputationInfo, topValue)
    -- Destructure props from AdjustedIDAndLabel
    local adjustedID, LABEL = adjustedIDAndLabel.adjustedID, adjustedIDAndLabel.label

    if TitanGetVar(TitanPanelReputation.ID, "ShortTipStanding") then LABEL = strsub(LABEL, 1, adjustedID == 10 and 2 or 1) end

    local dropdownValue = TitanPanelRightClickMenu_GetDropdMenuValue()
    if parentName ~= dropdownValue then
        return
    end

    if isHeader then
        local command = {}
        command.text = name
        command.value = name
        command.hasArrow = 1
        command.keepShownOnClick = 1
        command.checked = not TitanPanelReputation:IsFactionEffectivelyHidden(factionDetails)
        command.func = function()
            TitanPanelReputation:ToggleFactionVisibility(factionDetails)
            TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
        end
        TitanPanelRightClickMenu_AddButton(command, TitanPanelRightClickMenu_GetDropdownLevel())
        return
    end

    local canSelectFaction = (not isHeader) or (isHeader and hasRep)
    if not canSelectFaction then
        return
    end

    local command = {}
    if (TitanPanelReputation.BARCOLORS) then
        command.text = TitanUtils_GetColoredText(name .. " - " .. LABEL, TitanPanelReputation.BARCOLORS[(adjustedID)])
    else
        command.text = name .. " - " .. LABEL
    end
    command.value = name
    command.keepShownOnClick = 1
    command.checked = not TitanPanelReputation:IsFactionEffectivelyHidden(factionDetails)
    command.func = function()
        if IsShiftKeyDown() then
            TitanSetVar(TitanPanelReputation.ID, "WatchedFaction", name)
            TitanPanelReputation:Refresh()
        else
            TitanPanelReputation:ToggleFactionVisibility(factionDetails)
        end
        TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
    end
    TitanPanelRightClickMenu_AddButton(command, TitanPanelRightClickMenu_GetDropdownLevel())
end

--[[ TitanPanelReputation
NAME: TitanPanelRightClickMenu_PrepareReputationMenu
DESC: Builds the faction headers sub menu part of the right-click menu.
NOTE:
This method is called by the TitanPanel API to build the right-click menu. Therefore the naming convention
of this method is important and should read `TitanPanelRightClickMenu_Prepare${TitanPanelReputation.ID}Menu`
:NOTE
]]
function TitanPanelRightClickMenu_PrepareReputationMenu()
    local dropdownLevel = TitanPanelRightClickMenu_GetDropdownLevel()
    local dropdownValue = TitanPanelRightClickMenu_GetDropdMenuValue()

    -- Initialize button defaults
    local info = {}
    info.hasArrow = nil
    info.notCheckable = nil
    info.text = nil
    info.value = nil
    info.func = nil
    info.disabled = nil
    info.checked = nil

    if (dropdownLevel >= 2) and not IsReservedMenuValue(dropdownValue) then
        TitanPanelRightClickMenu_AddTitle2(dropdownValue, dropdownLevel)
        TitanPanelReputation:FactionDetailsProvider(BuildFactionHeaderSubMenu)
        return
    end

    -- Level 3 menus
    if (dropdownLevel == 3) then
        if (WoW5) then -- Friendship Rank Settings (Submenu)
            if dropdownValue == TitanPanelReputation:GT("LID_FRIENDSHIP_RANK_SETTINGS") then
                TitanPanelRightClickMenu_AddTitle2(TitanPanelRightClickMenu_GetDropdMenuValue(), 3)
                -- Toggle Options
                TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_FRIENDSHIPS"),
                    TitanPanelReputation.ID, "ShowFriendships", "", 3, true)
                TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_HIDE_MAX_FRIENDSHIPS"),
                    TitanPanelReputation.ID, "HideMaxFriendships", "", 3, true)
                --
                -- NOTE: Given the many inconsistencies in friendship reputation data, requiring
                -- NOTE: different total amounts of available standings as well as different
                -- NOTE: maxRep values, and amount needed for each level we opt for a simple "SHOW Friendships"
                -- NOTE: toggle, otherwise we would end up in configuration hell.
                -- TitanPanelRightClickMenu_AddSpacer2(3)
                -- --
                -- TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_BESTFRIEND"),
                --     TitanPanelReputation.ID, "ShowBESTFRIEND", "", 3, true)
                -- TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_GOODFRIEND"),
                --     TitanPanelReputation.ID, "ShowGOODFRIEND", "", 3, true)
                -- TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_FRIEND"),
                --     TitanPanelReputation.ID, "ShowFRIEND", "", 3, true)
                -- TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_BUDDY"),
                --     TitanPanelReputation.ID, "ShowBUDDY", "", 3, true)
                -- TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_ACQUAINTANCE"),
                --     TitanPanelReputation.ID, "ShowACQUAINTANCE", "", 3, true)
                -- TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_STRANGER"),
                --     TitanPanelReputation.ID, "ShowSTRANGER", "", 3, true)
            end
        end

        -- Reputation Standing Settings (Submenu)
        if dropdownValue == TitanPanelReputation:GT("LID_REPUTATION_STANDING_SETTINGS") then
            TitanPanelRightClickMenu_AddTitle2(TitanPanelRightClickMenu_GetDropdMenuValue(), 3)
            -- Toggle Options
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_EXALTED"),
                TitanPanelReputation.ID, "ShowExalted", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_REVERED"),
                TitanPanelReputation.ID, "ShowRevered", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_HONORED"),
                TitanPanelReputation.ID, "ShowHonored", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_FRIENDLY"),
                TitanPanelReputation.ID, "ShowFriendly", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_NEUTRAL"),
                TitanPanelReputation.ID, "ShowNeutral", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_UNFRIENDLY"),
                TitanPanelReputation.ID, "ShowUnfriendly", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_HOSTILE"),
                TitanPanelReputation.ID, "ShowHostile", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_HATED"),
                TitanPanelReputation.ID, "ShowHated", "", 3, true)
        end

        -- Tooltip Scale (Submenu)
        if dropdownValue == TitanPanelReputation:GT("LID_TOOLTIP_SCALE") then
            TitanPanelRightClickMenu_AddTitle2(TitanPanelReputation:GT("LID_TOOLTIP_SCALE"), 3)
            -- Toggle Options (Increase Scale)
            info.text = TitanPanelReputation:GT("LID_SCALE_INCREASE")
            info.notCheckable = true
            if TitanGetVar(TitanPanelReputation.ID, "ToolTipScale") >= 1.2 then
                info.disabled = true
                info.func = nil
            else
                info.disabled = nil
                info.func = function()
                    TitanSetVar(TitanPanelReputation.ID, "ToolTipScale",
                        TitanGetVar(TitanPanelReputation.ID, "ToolTipScale") + .1)
                    TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
                    TitanPanelRightClickMenu_Close()
                end
            end
            TitanPanelRightClickMenu_AddButton(info, 3)
            -- Toggle Options (Decrease Scale)
            info.text = TitanPanelReputation:GT("LID_SCALE_DECREASE")
            if TitanGetVar(TitanPanelReputation.ID, "ToolTipScale") <= .4 then
                info.disabled = true
                info.func = nil
            else
                info.disabled = nil
                info.func = function()
                    TitanSetVar(TitanPanelReputation.ID, "ToolTipScale",
                        TitanGetVar(TitanPanelReputation.ID, "ToolTipScale") - .1)
                    TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
                    TitanPanelRightClickMenu_Close()
                end
            end
            TitanPanelRightClickMenu_AddButton(info, 3)
        end

        -- Button Options (Submenu) Button Options // Session Summary Settings //
        if dropdownValue == TitanPanelReputation:GT("LID_SESSION_SUMMARY_SETTINGS") then
            TitanPanelRightClickMenu_AddTitle2(TitanPanelRightClickMenu_GetDropdMenuValue(), 3)
            -- Toggle Options
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_SUMMARY_DURATION"),
                TitanPanelReputation.ID, "ShowSessionSummaryDuration", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_SUMMARY_TTL"),
                TitanPanelReputation.ID, "ShowSessionSummaryTTL", "", 3, true)
        end

        -- Tooltip Options (Submenu) Tooltip Options // Session Summary Settings //
        if dropdownValue == TitanPanelReputation:GT("LID_TIP_SESSION_SUMMARY_SETTINGS") then
            -- NOTE: Using same title as the button options, but different value
            TitanPanelRightClickMenu_AddTitle2(TitanPanelReputation:GT("LID_SESSION_SUMMARY_SETTINGS"),
                3)
            -- Toggle Options
            TitanPanelRightClickMenu_AddToggleVar2(
                TitanPanelReputation:GT("LID_TIP_SHOW_SUMMARY_DURATION"),
                TitanPanelReputation.ID, "ShowTipSessionSummaryDuration", "", 3, true)
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_TIP_SHOW_SUMMARY_TTL"),
                TitanPanelReputation.ID, "ShowTipSessionSummaryTTL", "", 3, true)
        end

        return -- Return when we are done with the level 3 menus
    end

    -- Level 2 menus
    if (dropdownLevel == 2) then
        TitanPanelRightClickMenu_AddTitle2(dropdownValue, 2)

        -- Button Options (Submenu) Button Options //
        if TitanPanelRightClickMenu_GetDropdMenuValue() == TitanPanelReputation:GT("LID_BUTTON_OPTIONS") then
            -- Display on Right Side
            info.text = TitanPanelReputation:GT("LID_DISPLAY_ON_RIGHT_SIDE")
            if TitanGetVar(TitanPanelReputation.ID, "DisplayOnRightSide") then
                info.checked = 1
            else
                info.checked = nil
            end
            info.func = function()
                if TitanGetVar(TitanPanelReputation.ID, "DisplayOnRightSide") then
                    TitanSetVar(TitanPanelReputation.ID, "DisplayOnRightSide", nil)
                else
                    TitanSetVar(TitanPanelReputation.ID, "DisplayOnRightSide", 1)
                end
                TitanPanelRightClickMenu_Close()
                TitanPanel_InitPanelButtons()
            end
            TitanPanelRightClickMenu_AddButton(info, 2)
            --
            TitanPanelRightClickMenu_AddSpacer2(2)
            --
            -- Toggle Options
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_ICON"),
                TitanPanelReputation.ID, "ShowIcon", "", 2, true)
            if (WoW5) then
                TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_FRIENDS_ON_BAR"),
                    TitanPanelReputation.ID, "ShowFriendsOnBar", "", 2, true)
            end
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_FACTION_NAME_LABEL"),
                TitanPanelReputation.ID, "ShowFactionName", "", 2, true)
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_STANDING"),
                TitanPanelReputation.ID, "ShowStanding", "", 2, true)
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHORT_STANDING"),
                TitanPanelReputation.ID, "ShortStanding", "", 2, true)
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_VALUE"),
                TitanPanelReputation.ID, "ShowValue", "", 2, true)
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_PERCENT"),
                TitanPanelReputation.ID, "ShowPercent", "", 2, true)
            --
            TitanPanelRightClickMenu_AddSpacer2(2)
            --
            TitanPanelRightClickMenu_AddButton2(TitanPanelReputation:GT("LID_SESSION_SUMMARY_SETTINGS"),
                2)
        end

        -- Tooltip Options (Submenu) Tooltip Options //
        if TitanPanelRightClickMenu_GetDropdMenuValue() == TitanPanelReputation:GT("LID_TOOLTIP_OPTIONS") then
            -- Tooltip Scale
            local scale = TitanGetVar(TitanPanelReputation.ID, "ToolTipScale") * 100
            TitanPanelRightClickMenu_AddButton2(
                TitanPanelReputation:GT("LID_TOOLTIP_SCALE") .. " (" .. (scale) .. "%)", 2,
                TitanPanelReputation:GT("LID_TOOLTIP_SCALE"))
            -- Use minimal tooltip scale toggle
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_MINIMAL"),
                TitanPanelReputation.ID, "MinimalTip", "", 2, true)
            --
            TitanPanelRightClickMenu_AddSpacer2(2)
            --
            if (WoW5) then
                TitanPanelRightClickMenu_AddButton2(TitanPanelReputation:GT("LID_FRIENDSHIP_RANK_SETTINGS"), 2)
            end
            TitanPanelRightClickMenu_AddButton2(TitanPanelReputation:GT("LID_REPUTATION_STANDING_SETTINGS"), 2)
            --
            TitanPanelRightClickMenu_AddSpacer2(2)
            --
            -- Toggle Options
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_VALUE"),
                TitanPanelReputation.ID, "ShowTipReputationValue", "", 2, true)
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_PERCENT"),
                TitanPanelReputation.ID, "ShowTipPercent", "", 2, true)
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_STANDING"),
                TitanPanelReputation.ID, "ShowTipStanding", "", 2, true)
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHORT_STANDING"),
                TitanPanelReputation.ID, "ShortTipStanding", "", 2, true)
            --
            TitanPanelRightClickMenu_AddSpacer2(2)
            --
            TitanPanelRightClickMenu_AddToggleVar2(TitanPanelReputation:GT("LID_SHOW_STATS"),
                TitanPanelReputation.ID, "ShowTipExaltedTotal", "", 2, true)
            --
            TitanPanelRightClickMenu_AddSpacer2(2)
            --
            TitanPanelRightClickMenu_AddButton2(TitanPanelReputation:GT("LID_SESSION_SUMMARY_SETTINGS"),
                2)
        end

        -- Color Options (Submenu) Color Options //
        if TitanPanelRightClickMenu_GetDropdMenuValue() == TitanPanelReputation:GT("LID_COLOR_OPTIONS") then
            -- Initialize the color options
            info.disabled = nil
            info.hasArrow = nil
            info.notCheckable = nil
            info.value = nil
            info.keepShownOnClick = true

            -- Default Colors
            info.text = TitanPanelReputation:GT("LID_DEFAULT_COLORS")
            info.checked = TitanGetVar(TitanPanelReputation.ID, "ColorValue") == 1

            ---@diagnostic disable: duplicate-set-field

            info.func = function()
                TitanSetVar(TitanPanelReputation.ID, "ColorValue", 1); TitanPanelReputation.BARCOLORS =
                    TitanPanelReputation.COLORS_DEFAULT
                TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
                TitanPanelRightClickMenu_Close()
            end
            TitanPanelRightClickMenu_AddButton(info, 2)
            -- Armory Colors
            info.text = TitanPanelReputation:GT("LID_ARMORY_COLORS")
            info.checked = TitanGetVar(TitanPanelReputation.ID, "ColorValue") == 2
            info.func = function()
                TitanSetVar(TitanPanelReputation.ID, "ColorValue", 2); TitanPanelReputation.BARCOLORS =
                    TitanPanelReputation.COLORS_ARMORY
                TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
                TitanPanelRightClickMenu_Close()
            end
            TitanPanelRightClickMenu_AddButton(info, 2)
            -- No Colors (Basic)
            info.text = TitanPanelReputation:GT("LID_NO_COLORS")
            info.checked = TitanGetVar(TitanPanelReputation.ID, "ColorValue") == 3
            info.func = function()
                TitanSetVar(TitanPanelReputation.ID, "ColorValue", 3); TitanPanelReputation.BARCOLORS = nil
                TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
                TitanPanelRightClickMenu_Close()
            end

            ---@diagnostic enable: duplicate-set-field

            TitanPanelRightClickMenu_AddButton(info, 2)
        end

        return -- Return when we are done with the level 2 menus
    end

    -- Level 1 menu
    TitanPanelRightClickMenu_AddTitle2(TitanPlugins[TitanPanelReputation.ID].menuText)
    -- Toggle Options
    TitanPanelRightClickMenu_AddToggleVar(TitanPanelReputation:GT("LID_AUTO_CHANGE"),
        TitanPanelReputation.ID, "AutoChange")
    TitanPanelRightClickMenu_AddToggleVar(TitanPanelReputation:GT("LID_SHOW_ANNOUNCE"),
        TitanPanelReputation.ID, "ShowAnnounce")

    if (C_AddOns.IsAddOnLoaded("MikScrollingBattleText")) then
        TitanPanelRightClickMenu_AddToggleVar(TitanPanelReputation:GT("LID_SHOW_ANNOUNCE_MIK"),
            TitanPanelReputation.ID, "ShowAnnounceMik")
    end

    -- TODO: Implement achivement style announcements based on official WoW API
    -- if (C_AddOns.IsAddOnLoaded("Glamour")) then
    --     TitanPanelRightClickMenu_AddToggleVar(TitanPanelReputation:GT("LID_SHOW_ANNOUNCE_FRAME"), TitanPanelReputation.ID, "ShowAnnounceFrame")
    -- end
    --
    TitanPanelRightClickMenu_AddSpacer2()
    --
    -- ${FACTION_PARENT_HEADER}
    -- e.g. "The Burning Crusade .. Legion .. etc."
    TitanPanelReputation:FactionDetailsProvider(BuildFactionHeaderMenu)
    --
    TitanPanelRightClickMenu_AddSpacer2()
    --
    TitanPanelRightClickMenu_AddButton2(TitanPanelReputation:GT("LID_BUTTON_OPTIONS"), 1)
    TitanPanelRightClickMenu_AddButton2(TitanPanelReputation:GT("LID_TOOLTIP_OPTIONS"), 1)
    TitanPanelRightClickMenu_AddButton2(TitanPanelReputation:GT("LID_COLOR_OPTIONS"), 1)
    --
    TitanPanelRightClickMenu_AddSpacer2()
    -- Session Reset Button
    info.func = function()
        wipe(TitanPanelReputation.RTS)
        TitanPanelReputation.SESSION_TIME_START = GetTime()
        TitanPanelButton_UpdateButton(TitanPanelReputation.RTS)
        TitanPanelRightClickMenu_Close()
    end
    info.notCheckable = true
    info.text = TitanPanelReputation:GT("LID_SESSION_SUMMARY_RESET")
    info.value = nil
    TitanPanelRightClickMenu_AddButton(info, 1)
    -- Close Menu Button
    TitanPanelRightClickMenu_AddButton({ text = TitanPanelReputation:GT("LID_CLOSE_MENU"), notCheckable = true }, 1)
end

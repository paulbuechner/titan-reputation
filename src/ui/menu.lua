local _, TitanPanelReputation = ...

local WoW3 = select(4, GetBuildInfo()) >= 30000
local WoW5 = select(4, GetBuildInfo()) >= 50000

local dropdownSeedFrame
local dropdownSeeded

local function EnsureDropDownSeeded()
    if dropdownSeeded then
        return
    end
    if type(UIDropDownMenu_Initialize) ~= "function" or type(CreateFrame) ~= "function" then
        return
    end

    dropdownSeedFrame = dropdownSeedFrame or CreateFrame("Frame", "TitanPanelReputationDropDownSeeder", UIParent, "UIDropDownMenuTemplate")
    dropdownSeedFrame:Hide()

    UIDropDownMenu_Initialize(dropdownSeedFrame, function() end, "DROPDOWN_MENU_LEVEL")

    dropdownSeeded = true
end

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

---
---Builds the faction headers part of the right-click menu.
---
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
        local headerKey = TitanPanelReputation:GetNodeKey(factionDetails)
        if not isCollapsed then
            TitanPanelRightClickMenu_AddToggleVar2({
                label = name,
                value = name,
                hasArrow = 1,
                level = 1,
                checked = function()
                    return TitanPanelReputation:IsBranchVisibleByKey(headerKey)
                end,
                func = function()
                    TitanPanelReputation:ToggleFactionVisibility(factionDetails)
                    TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
                    TitanPanelRightClickMenu_RefreshOpenDropdown(1, true)
                    if UIDROPDOWNMENU_MENU_VALUE == name then
                        TitanPanelRightClickMenu_RefreshOpenDropdown(2, true)
                    end
                end,
            })
        end
    end
end

---
---Builds the faction headers sub menu part of the right-click menu.
---
---@param factionDetails FactionDetails
local function BuildFactionHeaderSubMenu(factionDetails)
    -- Destructure props from FactionDetails
    local name, parentName, standingID, topValue, isHeader, hasRep, friendShipReputationInfo, factionID, paragonProgressStarted =
        factionDetails.name,
        factionDetails.parentName,
        factionDetails.standingID,
        factionDetails.topValue,
        factionDetails.isHeader,
        factionDetails.hasRep,
        factionDetails.friendShipReputationInfo,
        factionDetails.factionID,
        factionDetails.paragonProgressStarted

    local dropdownValue = TitanPanelRightClickMenu_GetDropdMenuValue()
    local currentLevel = TitanPanelRightClickMenu_GetDropdownLevel()

    local function GetStandingLabel()
        local adjusted = TitanPanelReputation:GetAdjustedIDAndLabel(
            factionID, standingID, friendShipReputationInfo, topValue, paragonProgressStarted)
        if not adjusted then
            return nil, nil
        end
        local adjustedID, label = adjusted.adjustedID, adjusted.label
        if TitanGetVar(TitanPanelReputation.ID, "ShortTipStanding") then
            label = strsub(label, 1, adjustedID == 10 and 2 or 1)
        end
        return adjustedID, label
    end

    local function BuildDisplayText(displayName)
        local adjustedID, label = GetStandingLabel()
        if not adjustedID then
            return nil
        end

        if TitanPanelReputation.BARCOLORS then
            return TitanUtils_GetColoredText(displayName .. " - " .. label, TitanPanelReputation.BARCOLORS[(adjustedID)])
        end
        return displayName .. " - " .. label
    end

    local function WrapCommonClicks(details, allowDebugToast, allowWatchFaction, toggleFn)
        return function()
            -- Ctrl+Click: debug toast
            if allowDebugToast and IsControlKeyDown() and TitanPanelReputation:IsDebugEnabled() then
                TitanPanelReputation:TriggerDebugStandingToast(details)
                TitanPanelRightClickMenu_RefreshOpenDropdown(currentLevel, true)
                return
            end

            -- Shift+Click: watched faction
            if allowWatchFaction and IsShiftKeyDown() then
                TitanSetVar(TitanPanelReputation.ID, "WatchedFaction", details.name)
                TitanPanelReputation:RefreshButtonText()
                TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
                TitanPanelRightClickMenu_RefreshOpenDropdown(currentLevel, true)
                return
            end

            toggleFn()
            TitanPanelRightClickMenu_RefreshOpenDropdown(currentLevel, true)
        end
    end

    if isHeader then
        local headerKey = TitanPanelReputation:GetNodeKey(factionDetails)

        -- Header context:
        -- - In a parent's submenu (dropdownValue == parentName): show the header row (branch toggle), with arrow if it
        --   has reputation itself OR has children.
        -- - In its own submenu (dropdownValue == name): if it has reputation, show the header-self toggle row.
        if dropdownValue == parentName then
            local hasChildren = TitanPanelReputation:HasDescendantsByKey(headerKey)

            TitanPanelRightClickMenu_AddToggleVar2({
                label = name,
                value = name,
                hasArrow = (hasRep or hasChildren) and 1 or nil,
                level = currentLevel,
                checked = function()
                    return TitanPanelReputation:IsBranchVisibleByKey(headerKey)
                end,
                func = WrapCommonClicks(
                    factionDetails,
                    hasRep, -- debug toast only makes sense if the header has rep
                    hasRep, -- watched faction only makes sense if the header has rep
                    function()
                        TitanPanelReputation:ToggleFactionVisibility(factionDetails)
                        TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
                        if (hasRep or hasChildren) and UIDROPDOWNMENU_MENU_VALUE == name then
                            TitanPanelRightClickMenu_RefreshOpenDropdown(currentLevel + 1, true)
                        end
                    end
                ),
            })
            return
        end

        if dropdownValue == name then
            -- Header has no rep: omit the header-self toggle, but keep submenu alive for its children.
            if not hasRep then return end

            local displayText = BuildDisplayText(name); if not displayText then return end
            --
            TitanPanelRightClickMenu_AddToggleVar2({
                label = displayText,
                value = name,
                level = currentLevel,
                checked = function()
                    return not TitanPanelReputation:IsFactionEffectivelyHidden(factionDetails)
                end,
                func = WrapCommonClicks(
                    factionDetails,
                    true,
                    true,
                    function()
                        local shouldHide = not TitanPanelReputation:IsFactionEffectivelyHidden(factionDetails)
                        TitanPanelReputation:SetHeaderSelfHiddenState(headerKey, shouldHide)
                        TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
                    end
                ),
            })
            return
        end

        return -- Header doesn't match current dropdown context, skip it
    end

    -- For non-headers, check if they belong to the current dropdown
    if parentName ~= dropdownValue then return end

    local displayText = BuildDisplayText(name); if not displayText then return end
    --
    TitanPanelRightClickMenu_AddToggleVar2({
        label = displayText,
        value = name,
        level = currentLevel,
        checked = function()
            return not TitanPanelReputation:IsFactionEffectivelyHidden(factionDetails)
        end,
        func = WrapCommonClicks(
            factionDetails,
            true,
            true,
            function()
                TitanPanelReputation:ToggleFactionVisibility(factionDetails)
                TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
            end
        ),
    })
end

local function AddColorOption(level, label, colorValue, colors)
    local targetLevel = level or 2
    TitanPanelRightClickMenu_AddToggleVar2({
        level = targetLevel,
        label = label,
        keepShownOnClick = true,
        checked = function()
            return TitanGetVar(TitanPanelReputation.ID, "ColorValue") == colorValue
        end,
        func = function()
            TitanSetVar(TitanPanelReputation.ID, "ColorValue", colorValue)
            TitanPanelReputation.BARCOLORS = colors
            TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
            TitanPanelRightClickMenu_RefreshOpenDropdown(targetLevel)
        end,
    })
end

---
---Builds the faction headers sub menu part of the right-click menu.
---
---NOTE: This method is called by the TitanPanel API to build the right-click menu. Therefore the naming convention
---of this method is important and should read `TitanPanelRightClickMenu_Prepare${TitanPanelReputation.ID}Menu`
---
function TitanPanelRightClickMenu_PrepareReputationMenu()
    if TitanPanelReputation.TITAN_TOO_OLD then return end

    -- Ensure the Blizzard dropdown lists exist before Titan tries to add entries
    EnsureDropDownSeeded()

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
                TitanPanelRightClickMenu_AddToggleVar2({ level = 3, label = TitanPanelReputation:GT("LID_SHOW_FRIENDSHIPS"), savedVar = "ShowFriendships" })
                TitanPanelRightClickMenu_AddToggleVar2({ level = 3, label = TitanPanelReputation:GT("LID_HIDE_MAX_FRIENDSHIPS"), savedVar = "HideMaxFriendships" })
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
            TitanPanelRightClickMenu_AddToggleVar2({ level = 3, label = TitanPanelReputation:GT("LID_SHOW_EXALTED"), savedVar = "ShowExalted" })
            TitanPanelRightClickMenu_AddToggleVar2({ level = 3, label = TitanPanelReputation:GT("LID_SHOW_REVERED"), savedVar = "ShowRevered" })
            TitanPanelRightClickMenu_AddToggleVar2({ level = 3, label = TitanPanelReputation:GT("LID_SHOW_HONORED"), savedVar = "ShowHonored" })
            TitanPanelRightClickMenu_AddToggleVar2({ level = 3, label = TitanPanelReputation:GT("LID_SHOW_FRIENDLY"), savedVar = "ShowFriendly" })
            TitanPanelRightClickMenu_AddToggleVar2({ level = 3, label = TitanPanelReputation:GT("LID_SHOW_NEUTRAL"), savedVar = "ShowNeutral" })
            TitanPanelRightClickMenu_AddToggleVar2({ level = 3, label = TitanPanelReputation:GT("LID_SHOW_UNFRIENDLY"), savedVar = "ShowUnfriendly" })
            TitanPanelRightClickMenu_AddToggleVar2({ level = 3, label = TitanPanelReputation:GT("LID_SHOW_HOSTILE"), savedVar = "ShowHostile" })
            TitanPanelRightClickMenu_AddToggleVar2({ level = 3, label = TitanPanelReputation:GT("LID_SHOW_HATED"), savedVar = "ShowHated" })
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
            TitanPanelRightClickMenu_AddToggleVar2({ level = 3, label = TitanPanelReputation:GT("LID_SHOW_SUMMARY_DURATION"), savedVar = "ShowSessionSummaryDuration" })
            TitanPanelRightClickMenu_AddToggleVar2({ level = 3, label = TitanPanelReputation:GT("LID_SHOW_SUMMARY_TTL"), savedVar = "ShowSessionSummaryTTL" })
        end

        -- Tooltip Options (Submenu) Tooltip Options // Session Summary Settings //
        if dropdownValue == TitanPanelReputation:GT("LID_TIP_SESSION_SUMMARY_SETTINGS") then
            -- NOTE: Using same title as the button options, but different value
            TitanPanelRightClickMenu_AddTitle2(TitanPanelReputation:GT("LID_SESSION_SUMMARY_SETTINGS"),
                3)
            -- Toggle Options
            TitanPanelRightClickMenu_AddToggleVar2({ level = 3, label = TitanPanelReputation:GT("LID_TIP_SHOW_SUMMARY_DURATION"), savedVar = "ShowTipSessionSummaryDuration" })
            TitanPanelRightClickMenu_AddToggleVar2({ level = 3, label = TitanPanelReputation:GT("LID_TIP_SHOW_SUMMARY_TTL"), savedVar = "ShowTipSessionSummaryTTL" })
        end

        return -- Return when we are done with the level 3 menus
    end

    -- Level 2 menus
    if (dropdownLevel == 2) then
        TitanPanelRightClickMenu_AddTitle2(dropdownValue, 2)

        -- Button Options (Submenu) Button Options //
        if TitanPanelRightClickMenu_GetDropdMenuValue() == TitanPanelReputation:GT("LID_BUTTON_OPTIONS") then
            -- Display on Right Side
            TitanPanelRightClickMenu_AddToggleVar2({
                level = 2,
                label = TitanPanelReputation:GT("LID_DISPLAY_ON_RIGHT_SIDE"),
                keepShownOnClick = false,
                checked = TitanGetVar(TitanPanelReputation.ID, "DisplayOnRightSide"),
                func = function()
                    TitanSetVar(TitanPanelReputation.ID, "DisplayOnRightSide", not TitanGetVar(TitanPanelReputation.ID, "DisplayOnRightSide"))
                    TitanPanelRightClickMenu_Close()
                    TitanPanel_InitPanelButtons()
                end,
            })
            --
            TitanPanelRightClickMenu_AddSpacer2(2)
            --
            -- Toggle Options
            TitanPanelRightClickMenu_AddToggleVar2({ level = 2, label = TitanPanelReputation:GT("LID_SHOW_ICON"), savedVar = "ShowIcon" })
            if (WoW5) then
                TitanPanelRightClickMenu_AddToggleVar2({ level = 2, label = TitanPanelReputation:GT("LID_SHOW_FRIENDS_ON_BAR"), savedVar = "ShowFriendsOnBar" })
            end
            TitanPanelRightClickMenu_AddToggleVar2({ level = 2, label = TitanPanelReputation:GT("LID_SHOW_FACTION_NAME_LABEL"), savedVar = "ShowFactionName" })
            TitanPanelRightClickMenu_AddToggleVar2({ level = 2, label = TitanPanelReputation:GT("LID_SHOW_STANDING"), savedVar = "ShowStanding" })
            TitanPanelRightClickMenu_AddToggleVar2({ level = 2, label = TitanPanelReputation:GT("LID_SHORT_STANDING"), savedVar = "ShortStanding" })
            TitanPanelRightClickMenu_AddToggleVar2({ level = 2, label = TitanPanelReputation:GT("LID_SHOW_VALUE"), savedVar = "ShowValue" })
            TitanPanelRightClickMenu_AddToggleVar2({ level = 2, label = TitanPanelReputation:GT("LID_SHOW_PERCENT"), savedVar = "ShowPercent" })
            --
            TitanPanelRightClickMenu_AddSpacer2(2)
            --
            TitanPanelRightClickMenu_AddButton2(TitanPanelReputation:GT("LID_SESSION_SUMMARY_SETTINGS"), 2)
        end

        -- Tooltip Options (Submenu) Tooltip Options //
        if TitanPanelRightClickMenu_GetDropdMenuValue() == TitanPanelReputation:GT("LID_TOOLTIP_OPTIONS") then
            -- Tooltip Scale
            local scale = TitanGetVar(TitanPanelReputation.ID, "ToolTipScale") * 100
            TitanPanelRightClickMenu_AddButton2(
                TitanPanelReputation:GT("LID_TOOLTIP_SCALE") .. " (" .. (scale) .. "%)", 2,
                TitanPanelReputation:GT("LID_TOOLTIP_SCALE"))
            -- Use minimal tooltip scale toggle
            TitanPanelRightClickMenu_AddToggleVar2({ level = 2, label = TitanPanelReputation:GT("LID_SHOW_MINIMAL"), savedVar = "MinimalTip" })
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
            TitanPanelRightClickMenu_AddToggleVar2({ level = 2, label = TitanPanelReputation:GT("LID_SHOW_VALUE"), savedVar = "ShowTipReputationValue" })
            TitanPanelRightClickMenu_AddToggleVar2({ level = 2, label = TitanPanelReputation:GT("LID_SHOW_PERCENT"), savedVar = "ShowTipPercent" })
            TitanPanelRightClickMenu_AddToggleVar2({ level = 2, label = TitanPanelReputation:GT("LID_SHOW_STANDING"), savedVar = "ShowTipStanding" })
            TitanPanelRightClickMenu_AddToggleVar2({ level = 2, label = TitanPanelReputation:GT("LID_SHORT_STANDING"), savedVar = "ShortTipStanding" })
            --
            TitanPanelRightClickMenu_AddSpacer2(2)
            --
            TitanPanelRightClickMenu_AddToggleVar2({ level = 2, label = TitanPanelReputation:GT("LID_SHOW_STATS"), savedVar = "ShowTipExaltedTotal" })
            --
            TitanPanelRightClickMenu_AddSpacer2(2)
            --
            TitanPanelRightClickMenu_AddButton2(TitanPanelReputation:GT("LID_SESSION_SUMMARY_SETTINGS"), 2)
        end

        -- Color Options (Submenu) Color Options //
        if TitanPanelRightClickMenu_GetDropdMenuValue() == TitanPanelReputation:GT("LID_COLOR_OPTIONS") then
            -- Initialize the color options
            info.disabled = nil
            info.hasArrow = nil
            info.notCheckable = nil
            info.value = nil
            info.keepShownOnClick = true

            -- Default, Armory, Basic color sets stay visible while toggling
            AddColorOption(2, TitanPanelReputation:GT("LID_DEFAULT_COLORS"), 1, TitanPanelReputation.COLORS_DEFAULT)
            AddColorOption(2, TitanPanelReputation:GT("LID_ARMORY_COLORS"), 2, TitanPanelReputation.COLORS_ARMORY)
            AddColorOption(2, TitanPanelReputation:GT("LID_NO_COLORS"), 3, nil)
        end

        return -- Return when we are done with the level 2 menus
    end

    -- Level 1 menu
    TitanPanelRightClickMenu_AddTitle2(TitanPlugins[TitanPanelReputation.ID].menuText)
    -- Toggle Options
    TitanPanelRightClickMenu_AddToggleVar2({ label = TitanPanelReputation:GT("LID_AUTO_CHANGE"), savedVar = "AutoChange" })
    -- Achievement-style toasts require the Achievement system (WotLK+).
    if WoW3 then
        TitanPanelRightClickMenu_AddToggleVar2({ label = TitanPanelReputation:GT("LID_SHOW_ANNOUNCE_FRAME"), savedVar = "ShowAnnounceFrame" })
    end
    if (C_AddOns.IsAddOnLoaded("MikScrollingBattleText")) then
        TitanPanelRightClickMenu_AddToggleVar2({ label = TitanPanelReputation:GT("LID_SHOW_ANNOUNCE_MIK"), savedVar = "ShowAnnounceMik" })
    end
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

local _, TitanPanelReputation = ...

local WoW3 = select(4, GetBuildInfo()) >= 30000
local WoW5 = select(4, GetBuildInfo()) >= 50000

---
---Resolve the adjusted standing ID and label for a faction, honoring the `ShortTipStanding` setting.
---
---@param factionDetails FactionDetails
---@return number|nil adjustedID
---@return string|nil label
local function GetStandingLabel(factionDetails)
    local adjusted = TitanPanelReputation:GetAdjustedIDAndLabel(
        factionDetails.factionID,
        factionDetails.standingID,
        factionDetails.friendShipReputationInfo,
        factionDetails.topValue,
        factionDetails.paragonProgressStarted
    )
    if not adjusted then return nil, nil end

    local adjustedID, label = adjusted.adjustedID, adjusted.label
    if TitanGetVar(TitanPanelReputation.ID, "ShortTipStanding") then
        label = strsub(label, 1, adjustedID == 10 and 2 or 1)
    end
    return adjustedID, label
end

---
---Build the colored "Name - Standing" label for a faction menu entry.
---
---@param factionDetails FactionDetails
---@return string|nil
local function BuildDisplayText(factionDetails)
    local adjustedID, label = GetStandingLabel(factionDetails)
    if not adjustedID then return nil end

    local text = factionDetails.name .. " - " .. label
    if TitanPanelReputation.BARCOLORS then
        return TitanUtils_GetColoredText(text, TitanPanelReputation.BARCOLORS[adjustedID])
    end
    return text
end

---
---Handle modifier-click shortcuts on a faction entry; returns `true` if the click was consumed.
---
---@param factionDetails FactionDetails
---@param allowDebugToast boolean
---@param allowWatchFaction boolean
---@return boolean consumed
local function HandleFactionModifiers(factionDetails, allowDebugToast, allowWatchFaction)
    if allowDebugToast and IsControlKeyDown() and TitanPanelReputation:IsDebugEnabled() then
        TitanPanelReputation:TriggerDebugStandingToast(factionDetails)
        return true
    end
    if allowWatchFaction and IsShiftKeyDown() then
        TitanSetVar(TitanPanelReputation.ID, "WatchedFaction", factionDetails.name)
        TitanPanelReputation:RefreshButtonText()
        TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
        return true
    end
    return false
end

---
---Snapshot the current faction list so nested submenu builders reuse one scan.
---
---@return FactionDetails[]
local function CollectAllDetails()
    local list = {}
    TitanPanelReputation:FactionDetailsProvider(function(details)
        list[#list + 1] = details
    end)
    return list
end

-- NOTE on Blizzard_Menu refresh scope:
-- Returning `MenuResponse.Refresh` from a setSelected callback only
-- re-evaluates the clicked menu's level and its directly open submenu.
-- Grandchild submenus that were already expanded retain their stale
-- isSelected state until the user closes and re-hovers them. There is
-- no public Blizzard_Menu API to force a deep refresh across arbitrary
-- submenu depth, so cross-hierarchy cascades (e.g. toggling a top-level
-- faction header while a nested sub-header's submenu is visible) may
-- show stale checkboxes at depth >= 2 until re-hovered.

local AddFactionRow
local AddHeaderRow
local AttachChildrenByParentName

AddFactionRow = function(owner, details)
    local text = BuildDisplayText(details)
    if not text then return end

    Titan_Menu.AddSelectorGeneric(owner, text,
        function()
            return not TitanPanelReputation:IsFactionEffectivelyHidden(details)
        end,
        function()
            if HandleFactionModifiers(details, true, true) then return end
            TitanPanelReputation:ToggleFactionVisibility(details)
            TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
        end
    )
end

AddHeaderRow = function(owner, allDetails, details)
    local headerKey = TitanPanelReputation:GetNodeKey(details)
    local hasRep = details.hasRep
    local hasChildren = TitanPanelReputation:HasDescendantsByKey(headerKey)

    -- A header row behaves like a branch-visibility toggle. When it has rep
    -- and/or descendants, attaching children turns it into a submenu parent.
    local hdr = Titan_Menu.AddSelectorGeneric(owner, details.name,
        function()
            return TitanPanelReputation:IsBranchVisibleByKey(headerKey)
        end,
        function()
            if HandleFactionModifiers(details, hasRep, hasRep) then return end
            TitanPanelReputation:ToggleFactionVisibility(details)
            TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
        end
    )

    if not (hasRep or hasChildren) then return end

    if hasRep then
        local display = BuildDisplayText(details)
        if display then
            Titan_Menu.AddSelectorGeneric(hdr, display,
                function()
                    return not TitanPanelReputation:IsFactionEffectivelyHidden(details)
                end,
                function()
                    if HandleFactionModifiers(details, true, true) then return end
                    local shouldHide = not TitanPanelReputation:IsFactionEffectivelyHidden(details)
                    TitanPanelReputation:SetHeaderSelfHiddenState(headerKey, shouldHide)
                    TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
                end
            )
        end
    end

    AttachChildrenByParentName(hdr, allDetails, details.name)
end

AttachChildrenByParentName = function(owner, allDetails, parentName)
    for _, details in ipairs(allDetails) do
        if (not details.isInactive) and details.parentName == parentName then
            if details.isHeader then
                AddHeaderRow(owner, allDetails, details)
            else
                AddFactionRow(owner, details)
            end
        end
    end
end

---
---Build the Button Options submenu.
---
---@param parent table Menu widget object
local function BuildButtonOptions(parent)
    local id = TitanPanelReputation.ID

    Titan_Menu.AddSelector(parent, id, TitanPanelReputation:GT("LID_SHOW_ICON"), "ShowIcon")
    if WoW5 then
        Titan_Menu.AddSelector(parent, id, TitanPanelReputation:GT("LID_SHOW_FRIENDS_ON_BAR"), "ShowFriendsOnBar")
    end
    Titan_Menu.AddSelector(parent, id, TitanPanelReputation:GT("LID_SHOW_FACTION_NAME_LABEL"), "ShowFactionName")
    Titan_Menu.AddSelector(parent, id, TitanPanelReputation:GT("LID_SHOW_STANDING"), "ShowStanding")
    Titan_Menu.AddSelector(parent, id, TitanPanelReputation:GT("LID_SHORT_STANDING"), "ShortStanding")
    Titan_Menu.AddSelector(parent, id, TitanPanelReputation:GT("LID_SHOW_VALUE"), "ShowValue")
    Titan_Menu.AddSelector(parent, id, TitanPanelReputation:GT("LID_SHOW_PERCENT"), "ShowPercent")

    Titan_Menu.AddDivider(parent)

    local sess = Titan_Menu.AddButton(parent, TitanPanelReputation:GT("LID_SESSION_SUMMARY_SETTINGS"))
    Titan_Menu.AddSelector(sess, id, TitanPanelReputation:GT("LID_SHOW_SUMMARY_DURATION"), "ShowSessionSummaryDuration")
    Titan_Menu.AddSelector(sess, id, TitanPanelReputation:GT("LID_SHOW_SUMMARY_TTL"), "ShowSessionSummaryTTL")
end

---
---Build the Tooltip Options submenu.
---
---@param parent table Menu widget object
local function BuildTooltipOptions(parent)
    local id = TitanPanelReputation.ID

    local scale = TitanGetVar(id, "ToolTipScale") * 100
    local scale_parent = Titan_Menu.AddButton(parent,
        TitanPanelReputation:GT("LID_TOOLTIP_SCALE") .. " (" .. scale .. "%)")
    Titan_Menu.AddCommand(scale_parent, id, TitanPanelReputation:GT("LID_SCALE_INCREASE"),
        function()
            local curr = TitanGetVar(id, "ToolTipScale")
            if curr >= 1.2 then return end
            TitanSetVar(id, "ToolTipScale", curr + 0.1)
            TitanPanelButton_UpdateButton(id)
        end)
    Titan_Menu.AddCommand(scale_parent, id, TitanPanelReputation:GT("LID_SCALE_DECREASE"),
        function()
            local curr = TitanGetVar(id, "ToolTipScale")
            if curr <= 0.4 then return end
            TitanSetVar(id, "ToolTipScale", curr - 0.1)
            TitanPanelButton_UpdateButton(id)
        end)

    Titan_Menu.AddSelector(parent, id, TitanPanelReputation:GT("LID_SHOW_MINIMAL"), "MinimalTip")

    Titan_Menu.AddDivider(parent)

    if WoW5 then
        local friends = Titan_Menu.AddButton(parent, TitanPanelReputation:GT("LID_FRIENDSHIP_RANK_SETTINGS"))
        Titan_Menu.AddSelector(friends, id, TitanPanelReputation:GT("LID_SHOW_FRIENDSHIPS"), "ShowFriendships")
        Titan_Menu.AddSelector(friends, id, TitanPanelReputation:GT("LID_HIDE_MAX_FRIENDSHIPS"), "HideMaxFriendships")
    end

    local standing = Titan_Menu.AddButton(parent, TitanPanelReputation:GT("LID_REPUTATION_STANDING_SETTINGS"))
    Titan_Menu.AddSelector(standing, id, TitanPanelReputation:GT("LID_SHOW_EXALTED"), "ShowExalted")
    Titan_Menu.AddSelector(standing, id, TitanPanelReputation:GT("LID_SHOW_REVERED"), "ShowRevered")
    Titan_Menu.AddSelector(standing, id, TitanPanelReputation:GT("LID_SHOW_HONORED"), "ShowHonored")
    Titan_Menu.AddSelector(standing, id, TitanPanelReputation:GT("LID_SHOW_FRIENDLY"), "ShowFriendly")
    Titan_Menu.AddSelector(standing, id, TitanPanelReputation:GT("LID_SHOW_NEUTRAL"), "ShowNeutral")
    Titan_Menu.AddSelector(standing, id, TitanPanelReputation:GT("LID_SHOW_UNFRIENDLY"), "ShowUnfriendly")
    Titan_Menu.AddSelector(standing, id, TitanPanelReputation:GT("LID_SHOW_HOSTILE"), "ShowHostile")
    Titan_Menu.AddSelector(standing, id, TitanPanelReputation:GT("LID_SHOW_HATED"), "ShowHated")

    Titan_Menu.AddDivider(parent)

    Titan_Menu.AddSelector(parent, id, TitanPanelReputation:GT("LID_SHOW_VALUE"), "ShowTipReputationValue")
    Titan_Menu.AddSelector(parent, id, TitanPanelReputation:GT("LID_SHOW_PERCENT"), "ShowTipPercent")
    Titan_Menu.AddSelector(parent, id, TitanPanelReputation:GT("LID_SHOW_STANDING"), "ShowTipStanding")
    Titan_Menu.AddSelector(parent, id, TitanPanelReputation:GT("LID_SHORT_STANDING"), "ShortTipStanding")

    Titan_Menu.AddDivider(parent)

    Titan_Menu.AddSelector(parent, id, TitanPanelReputation:GT("LID_SHOW_STATS"), "ShowTipExaltedTotal")

    Titan_Menu.AddDivider(parent)

    local sess = Titan_Menu.AddButton(parent, TitanPanelReputation:GT("LID_SESSION_SUMMARY_SETTINGS"))
    Titan_Menu.AddSelector(sess, id, TitanPanelReputation:GT("LID_TIP_SHOW_SUMMARY_DURATION"),
        "ShowTipSessionSummaryDuration")
    Titan_Menu.AddSelector(sess, id, TitanPanelReputation:GT("LID_TIP_SHOW_SUMMARY_TTL"),
        "ShowTipSessionSummaryTTL")
end

---
---Build the Color Options submenu.
---
---@param parent table Menu widget object
local function BuildColorOptions(parent)
    local id = TitanPanelReputation.ID

    local list = {
        { TitanPanelReputation:GT("LID_DEFAULT_COLORS"), 1 },
        { TitanPanelReputation:GT("LID_ARMORY_COLORS"),  2 },
        { TitanPanelReputation:GT("LID_NO_COLORS"),      3 },
    }

    Titan_Menu.AddSelectorList(parent, id, nil, "ColorValue", list, function()
        local colorValue = TitanGetVar(id, "ColorValue")
        if colorValue == 1 then
            TitanPanelReputation.BARCOLORS = TitanPanelReputation.COLORS_DEFAULT
        elseif colorValue == 2 then
            TitanPanelReputation.BARCOLORS = TitanPanelReputation.COLORS_ARMORY
        else
            TitanPanelReputation.BARCOLORS = nil
        end
    end)
end

---
---`menuContextFunction` entrypoint - builds the right-click context menu for the
---TitanReputation plugin using the modern `Titan_Menu` / `Blizzard_Menu` API.
---
---@param _owner table Plugin frame (unused; Titan passes it for Blizzard_Menu compatibility)
---@param rootDescription table Root menu context
function TitanPanelReputation:BuildContextMenu(_owner, rootDescription)
    if TitanPanelReputation.TITAN_TOO_OLD then return end

    local id = TitanPanelReputation.ID
    local root = rootDescription

    Titan_Menu.AddSelector(root, id, TitanPanelReputation:GT("LID_AUTO_CHANGE"), "AutoChange")
    if WoW3 then
        Titan_Menu.AddSelector(root, id, TitanPanelReputation:GT("LID_SHOW_ANNOUNCE_FRAME"), "ShowAnnounceFrame")
    end
    if C_AddOns.IsAddOnLoaded("MikScrollingBattleText") then
        Titan_Menu.AddSelector(root, id, TitanPanelReputation:GT("LID_SHOW_ANNOUNCE_MIK"), "ShowAnnounceMik")
    end

    Titan_Menu.AddDivider(root)

    -- Top-level faction headers with descendant submenus
    local allDetails = CollectAllDetails()
    for _, details in ipairs(allDetails) do
        if (not details.isInactive)
            and details.isHeader
            and (not details.isCollapsed)
            and (details.headerLevel or 0) == 0 then
            AddHeaderRow(root, allDetails, details)
        end
    end

    Titan_Menu.AddDivider(root)

    local opts_button = Titan_Menu.AddButton(root, TitanPanelReputation:GT("LID_BUTTON_OPTIONS"))
    BuildButtonOptions(opts_button)

    local opts_tooltip = Titan_Menu.AddButton(root, TitanPanelReputation:GT("LID_TOOLTIP_OPTIONS"))
    BuildTooltipOptions(opts_tooltip)

    local opts_color = Titan_Menu.AddButton(root, TitanPanelReputation:GT("LID_COLOR_OPTIONS"))
    BuildColorOptions(opts_color)

    Titan_Menu.AddDivider(root)

    Titan_Menu.AddCommand(root, id, TitanPanelReputation:GT("LID_SESSION_SUMMARY_RESET"),
        function()
            wipe(TitanPanelReputation.RTS)
            TitanPanelReputation.SESSION_TIME_START = GetTime()
            TitanPanelButton_UpdateButton(id)
        end)
end

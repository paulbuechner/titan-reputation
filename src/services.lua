local _, TitanPanelReputation = ...

local function BuildKeyLookup(savedList)
    local lookup = {}
    if type(savedList) == "table" then
        for _, nodeKey in ipairs(savedList) do
            if type(nodeKey) == "string" and nodeKey ~= "" then
                lookup[nodeKey] = true
            end
        end
    end
    return lookup
end

local function WriteLookupToSavedVar(lookup, varName)
    local serialized = {}
    for name in pairs(lookup) do
        serialized[#serialized + 1] = name
    end
    table.sort(serialized)
    TitanSetVar(TitanPanelReputation.ID, varName, serialized)
end

local function JoinHeaderPath(headerPath, uptoIndex)
    if not headerPath or uptoIndex <= 0 then
        return ""
    end
    local out = headerPath[1] or ""
    for i = 2, uptoIndex do
        out = out .. "/" .. (headerPath[i] or "")
    end
    return out
end

---
---Builds the key that identifies a faction or header in the visibility saved variables: its
---header path joined with "/", ending in its own name (e.g. "Dragonflight/Sabellian").
---
---@param factionDetails FactionDetails
---@return string
local function BuildNodeKey(factionDetails)
    local hp = factionDetails.headerPath or {}
    if factionDetails.isHeader then
        if #hp == 0 then
            return factionDetails.name or ""
        end
        return JoinHeaderPath(hp, #hp)
    end
    local base = ""
    if #hp > 0 then
        base = JoinHeaderPath(hp, #hp)
    end
    if base ~= "" then
        return base .. "/" .. (factionDetails.name or "")
    end
    return factionDetails.name or ""
end

---
---Builds the node keys of all headers above a faction or header, outermost first.
---
---@param factionDetails FactionDetails
---@return string[]
local function BuildAncestorKeys(factionDetails)
    local keys = {}
    local hp = factionDetails.headerPath
    if not hp then
        return keys
    end
    local maxIndex = #hp
    -- For headers, headerPath includes the header itself; ancestors are everything before the last element
    if factionDetails.isHeader and maxIndex > 0 then
        maxIndex = maxIndex - 1
    end
    for i = 1, maxIndex do
        keys[i] = JoinHeaderPath(hp, i)
    end
    return keys
end

local NO_KEYS = {}

function TitanPanelReputation:GetNodeKey(factionDetails)
    if not factionDetails then
        return ""
    end
    -- Cached entries carry it precomputed (see BuildFactionDetailsList)
    return factionDetails.nodeKey or BuildNodeKey(factionDetails)
end

local function GetAncestorKeys(factionDetails)
    if not factionDetails then
        return NO_KEYS
    end
    return factionDetails.ancestorKeys or BuildAncestorKeys(factionDetails)
end

function TitanPanelReputation:IsDescendantOfKey(rootKey, factionDetails)
    if not rootKey or rootKey == "" or not factionDetails then
        return false
    end
    if self:GetNodeKey(factionDetails) == rootKey then
        return true
    end
    for _, key in ipairs(GetAncestorKeys(factionDetails)) do
        if key == rootKey then
            return true
        end
    end
    return false
end

---
--- Returns true if any factionDetails exists whose nodeKey is under `headerKey` (prefix match).
---Used by the menu to decide whether to show an arrow/submenu for headers that have no reputation
---themselves but do have children.
---
---@param headerKey string
---@return boolean
---@nodiscard
function TitanPanelReputation:HasDescendantsByKey(headerKey)
    if not headerKey or headerKey == "" then
        return false
    end
    local prefix = headerKey .. "/"
    local found = false
    self:FactionDetailsProvider(function(details)
        if found then return end
        if not details then return end
        local k = self:GetNodeKey(details)
        if k and k ~= headerKey and string.sub(k, 1, #prefix) == prefix then
            found = true
        end
    end)
    return found
end

local function CollectBranchKeys(rootKey)
    local keys = {}
    if not rootKey or rootKey == "" then
        return keys
    end
    TitanPanelReputation:FactionDetailsProvider(function(details)
        if TitanPanelReputation:IsDescendantOfKey(rootKey, details) then
            local k = TitanPanelReputation:GetNodeKey(details)
            if k ~= "" then
                keys[#keys + 1] = k
            end
        end
    end)
    return keys
end

local function BuildStandingAlertPayload(params)
    if type(params) ~= "table" then
        return nil
    end

    local payloadText = params.text or params.name or ""
    if payloadText == "" then
        return nil
    end

    local icon = params.icon
    if not icon and params.factionID then
        local mapping = TitanPanelReputation:GetFactionMapping(params.factionID)
        if mapping and mapping.icon then
            icon = mapping.icon
        end
    end

    local payload = {
        text = payloadText,
        factionID = params.factionID,
        icon = icon or TitanPanelReputation.ICON,
    }

    payload.title = ACHIEVEMENT_UNLOCKED
    payload.standingText = params.label or ""

    return payload
end

local function DispatchReputationAnnouncement(message, alertPayload)
    -- Achievement-style toast (skipped on clients without achievements, see ShowStandingAchievement)
    if TitanGetVar(TitanPanelReputation.ID, "ShowAnnounceFrame") and alertPayload then
        TitanPanelReputation:ShowStandingAchievement(alertPayload)
    end

    if not message or message == "" then
        return
    end

    if C_AddOns.IsAddOnLoaded("MikScrollingBattleText") and TitanGetVar(TitanPanelReputation.ID, "ShowAnnounceMik") and MikSBT then
        local decorated = "|T" .. TitanPanelReputation.ICON .. ":32|t" .. message .. "|T" .. TitanPanelReputation.ICON .. ":32|t"
        MikSBT.DisplayMessage(decorated, MikSBT.DISPLAYTYPE_NOTIFICATION, true)
    end
end

---@param name string
---@param factionID number
---@param adjusted AdjustedIDAndLabel
local function ShowReputationAnnouncement(name, factionID, adjusted)
    local color = TitanPanelReputation:GetStandingColor(adjusted.adjustedID)
    local msg
    if color then
        msg = TitanUtils_GetColoredText(name .. " - " .. adjusted.label, color)
    else
        msg = TitanUtils_GetGoldText(name .. " - " .. adjusted.label)
    end
    msg = " " .. msg .. " "

    local alertPayload = BuildStandingAlertPayload({ name = name, label = adjusted.label, adjustedID = adjusted.adjustedID, factionID = factionID })

    DispatchReputationAnnouncement(msg, alertPayload)
end

function TitanPanelReputation:TriggerDebugStandingToast(factionDetails)
    if not factionDetails or not TitanPanelReputation:IsDebugEnabled() then
        return
    end

    if factionDetails.isHeader and not factionDetails.hasRep then
        return
    end

    local adjusted = TitanPanelReputation:GetAdjustedIDAndLabel(factionDetails, true)
    if not adjusted then
        return
    end

    local payload = BuildStandingAlertPayload({
        name = factionDetails.name,
        label = adjusted.label,
        adjustedID = adjusted.adjustedID,
        factionID = factionDetails.factionID,
    })
    if payload then
        TitanPanelReputation:ShowStandingAchievement(payload)
    end
end

---
---Resolves the bucket key used when regrouping the reputation tree. For root headers
---it returns their own name, for child nodes it walks up the cached headerPath so every
---entry produced by `FactionDetailsProvider` can be associated with the correct top-level
---header before reordering the results.
---
---@param factionDetails FactionDetails|nil
---@return string
---@nodiscard
local function DetermineRootHeaderKey(factionDetails)
    if not factionDetails then
        return ""
    end

    if factionDetails.headerLevel == 0 then
        return factionDetails.name or ""
    end

    if factionDetails.headerPath and #factionDetails.headerPath > 0 then
        return factionDetails.headerPath[1] or ""
    end

    if factionDetails.parentName and factionDetails.parentName ~= "" then
        return factionDetails.parentName
    end

    return ""
end

---
---Given the raw faction list produced by the Blizzard API, rebuilds it so each root
---header emits its direct factions first and then any nested header buckets. This keeps
---the UI grouped as Main Header → direct factions → sub-header groups → sub-factions regardless
---of the order Blizzard returns rows in.
---
---@param detailsList FactionDetails[]|nil
---@return FactionDetails[]
---@nodiscard
local function OrderFactionDetails(detailsList)
    if not detailsList or #detailsList == 0 then
        return detailsList or {}
    end

    local orderedRoots = {}
    local buckets = {}

    local function EnsureBucket(key)
        key = key or ""
        if not buckets[key] then
            buckets[key] = {
                header = nil,
                rootFactions = {},
                nestedHeaders = {},
                nestedOrder = {},
            }
            tinsert(orderedRoots, key)
        end
        return buckets[key]
    end

    for _, details in ipairs(detailsList) do
        local bucket = EnsureBucket(details.rootKey)
        local level = details.headerLevel

        if level == 0 and details.isHeader then
            bucket.header = details
        elseif details.isHeader then
            local nestedKey = details.name or ""
            if nestedKey == "" then
                nestedKey = "__nested__" .. tostring(#bucket.nestedOrder + 1)
            end
            if not bucket.nestedHeaders[nestedKey] then
                bucket.nestedHeaders[nestedKey] = { header = details, children = {} }
                tinsert(bucket.nestedOrder, nestedKey)
            else
                bucket.nestedHeaders[nestedKey].header = bucket.nestedHeaders[nestedKey].header or details
            end
        else
            if level <= 1 then
                tinsert(bucket.rootFactions, details)
            else
                local parentKey = details.parentName or ""
                if parentKey ~= "" then
                    if not bucket.nestedHeaders[parentKey] then
                        bucket.nestedHeaders[parentKey] = { header = nil, children = {} }
                        tinsert(bucket.nestedOrder, parentKey)
                    end
                    tinsert(bucket.nestedHeaders[parentKey].children, details)
                else
                    tinsert(bucket.rootFactions, details)
                end
            end
        end
    end

    local ordered = {}
    for _, key in ipairs(orderedRoots) do
        local bucket = buckets[key]
        if bucket.header then
            tinsert(ordered, bucket.header)
        end
        for _, faction in ipairs(bucket.rootFactions) do
            tinsert(ordered, faction)
        end
        for _, nestedKey in ipairs(bucket.nestedOrder) do
            local nestedBucket = bucket.nestedHeaders[nestedKey]
            if nestedBucket.header then
                tinsert(ordered, nestedBucket.header)
            end
            for _, child in ipairs(nestedBucket.children) do
                tinsert(ordered, child)
            end
        end
    end

    return ordered
end

function TitanPanelReputation:GetHiddenFactionLookup()
    if not self.hiddenFactionLookup then
        local saved = TitanGetVar(TitanPanelReputation.ID, "FactionHeaders") or {}
        self.hiddenFactionLookup = BuildKeyLookup(saved)
    end
    return self.hiddenFactionLookup
end

function TitanPanelReputation:GetShownFactionOverrideLookup()
    if not self.shownFactionOverrideLookup then
        local saved = TitanGetVar(TitanPanelReputation.ID, "FactionShowOverrides") or {}
        self.shownFactionOverrideLookup = BuildKeyLookup(saved)
    end
    return self.shownFactionOverrideLookup
end

function TitanPanelReputation:GetHeaderSelfOverrideLookup()
    if not self.headerSelfOverrideLookup then
        local saved = TitanGetVar(TitanPanelReputation.ID, "HeaderSelfOverrides") or {}
        if type(saved) ~= "table" then
            saved = {}
        end
        self.headerSelfOverrideLookup = saved
    end
    return self.headerSelfOverrideLookup
end

function TitanPanelReputation:IsFactionEffectivelyHidden(factionDetails)
    if not factionDetails then
        return false
    end
    local lookup = self:GetHiddenFactionLookup()
    local shownOverrides = self:GetShownFactionOverrideLookup()

    local nodeKey = self:GetNodeKey(factionDetails)
    if nodeKey ~= "" and shownOverrides[nodeKey] then
        return false
    end

    if nodeKey ~= "" and lookup[nodeKey] then
        return true
    end

    for _, key in ipairs(GetAncestorKeys(factionDetails)) do
        if key ~= "" and lookup[key] then
            return true
        end
    end

    return false
end

function TitanPanelReputation:HasHiddenAncestor(factionDetails)
    if not factionDetails then
        return false
    end
    local lookup = self:GetHiddenFactionLookup()
    for _, key in ipairs(GetAncestorKeys(factionDetails)) do
        if key ~= "" and lookup[key] then
            return true
        end
    end
    return false
end

function TitanPanelReputation:IsBranchVisible(rootKey)
    if not rootKey or rootKey == "" then
        return false
    end
    local visible = false
    self:FactionDetailsProvider(function(details)
        if visible then return end
        if TitanPanelReputation:IsDescendantOfKey(rootKey, details) then
            if not TitanPanelReputation:IsFactionEffectivelyHidden(details) then
                visible = true
            end
        end
    end)
    return visible
end

function TitanPanelReputation:ClearShownOverridesForBranch(rootName)
    if not rootName or rootName == "" then
        return
    end
    local overrides = self:GetShownFactionOverrideLookup()
    if not next(overrides) then
        return
    end
    for _, key in ipairs(CollectBranchKeys(rootName)) do
        overrides[key] = nil
    end
    WriteLookupToSavedVar(overrides, "FactionShowOverrides")
end

function TitanPanelReputation:SetFactionHiddenState(factionDetails, hidden)
    if not factionDetails then
        return
    end
    local nodeKey = self:GetNodeKey(factionDetails)
    if not nodeKey or nodeKey == "" then
        return
    end

    local lookup = self:GetHiddenFactionLookup()
    local overrides = self:GetShownFactionOverrideLookup()
    if hidden then
        lookup[nodeKey] = true
        overrides[nodeKey] = nil
        TitanPanelReputation:ClearShownOverridesForBranch(nodeKey)
    else
        lookup[nodeKey] = nil
        overrides[nodeKey] = nil
        if factionDetails.isHeader then
            local branchKeys = CollectBranchKeys(nodeKey)
            if #branchKeys > 0 then
                for _, branchKey in ipairs(branchKeys) do
                    lookup[branchKey] = nil
                    overrides[branchKey] = nil
                end
                if TitanPanelReputation:HasHiddenAncestor(factionDetails) then
                    for _, branchKey in ipairs(branchKeys) do
                        overrides[branchKey] = true
                    end
                end
            end
        elseif TitanPanelReputation:HasHiddenAncestor(factionDetails) then
            overrides[nodeKey] = true
        end
    end

    WriteLookupToSavedVar(lookup, "FactionHeaders")
    WriteLookupToSavedVar(overrides, "FactionShowOverrides")
    self.hiddenFactionLookup = lookup
    self.shownFactionOverrideLookup = overrides
end

function TitanPanelReputation:ToggleFactionVisibility(factionDetails)
    local shouldHide = not self:IsFactionEffectivelyHidden(factionDetails)
    self:SetFactionHiddenState(factionDetails, shouldHide)
end

---
---Hide/unhide a header node without changing its descendants' effective visibility state.
---Used by the "header - standing" toggle inside a header's own submenu.
---
---@param headerKey string
---@param hidden boolean
function TitanPanelReputation:SetHeaderSelfHiddenState(headerKey, hidden)
    if not headerKey or headerKey == "" then
        return
    end

    local lookup = self:GetHiddenFactionLookup()
    local overrides = self:GetShownFactionOverrideLookup()
    local selfOverrides = self:GetHeaderSelfOverrideLookup()

    -- Helper: determine if a nodeKey has any hidden ancestor (other than `excludeKey`, if given)
    -- purely from the key string, without relying on the current `FactionDetailsProvider` scan state.
    local function KeyHasHiddenAncestor(nodeKey, excludeKey)
        if not nodeKey or nodeKey == "" then
            return false
        end
        local prefix = nil
        for segment in string.gmatch(nodeKey, "([^/]+)") do
            if not prefix then
                prefix = segment
            else
                prefix = prefix .. "/" .. segment
            end
            -- Stop before checking the key itself; ancestors are prefixes only.
            if prefix == nodeKey then
                break
            end
            if prefix ~= excludeKey and lookup[prefix] then
                return true
            end
        end
        return false
    end

    -- Helper: find details by key (menu clicks are rare, linear scan is fine)
    local function FindDetailsByKey(targetKey)
        local found = nil
        self:FactionDetailsProvider(function(details)
            if found then return end
            if details and self:GetNodeKey(details) == targetKey then
                found = details
            end
        end)
        return found
    end

    if hidden then
        -- Preserve descendants: for any descendant that is currently visible, add a show-override
        -- so hiding this header doesn't flip their effective visibility.
        local recorded = {}
        self:FactionDetailsProvider(function(details)
            if not details or not details.name or details.name == "" then
                return
            end
            local detailsKey = self:GetNodeKey(details)
            if detailsKey == "" then
                return
            end
            if detailsKey == headerKey then
                return
            end
            if self:IsDescendantOfKey(headerKey, details) then
                local wasVisible = not self:IsFactionEffectivelyHidden(details)
                if wasVisible then
                    -- Don't force-show nodes that are explicitly hidden already
                    if not lookup[detailsKey] and not overrides[detailsKey] then
                        overrides[detailsKey] = true
                        recorded[#recorded + 1] = detailsKey
                    end
                end
            end
        end)

        lookup[headerKey] = true
        overrides[headerKey] = nil
        selfOverrides[headerKey] = recorded
    else
        -- If THIS header was explicitly hidden (not merely hidden by an ancestor),
        -- preserve descendants that were hidden due to this header being hidden.
        local wasExplicitlyHidden = lookup[headerKey] and true or false

        -- If descendants are currently hidden (often because this header was used to hide the whole branch),
        -- explicitly keep them hidden so "enable only this header" doesn't re-enable all children.
        self:FactionDetailsProvider(function(details)
            if not wasExplicitlyHidden then
                return
            end
            if not details or not details.name or details.name == "" then
                return
            end
            local detailsKey = self:GetNodeKey(details)
            if detailsKey == "" or detailsKey == headerKey then
                return
            end
            if self:IsDescendantOfKey(headerKey, details) then
                -- Only persist hidden state if the node is hidden *because of this header*,
                -- not because some other ancestor (e.g. the root header) is hidden.
                if self:IsFactionEffectivelyHidden(details) and not KeyHasHiddenAncestor(detailsKey, headerKey) then
                    lookup[detailsKey] = true
                    overrides[detailsKey] = nil
                end
            end
        end)

        lookup[headerKey] = nil
        overrides[headerKey] = nil

        -- If this header lives under a hidden ancestor, it will still be effectively hidden unless we
        -- add a show-override for the header itself (same behavior as branch toggles).
        local headerDetails = FindDetailsByKey(headerKey)
        if (headerDetails and self:HasHiddenAncestor(headerDetails)) or (not headerDetails and KeyHasHiddenAncestor(headerKey)) then
            overrides[headerKey] = true
        end

        local recorded = selfOverrides[headerKey] or {}
        for _, descendantKey in ipairs(recorded) do
            if overrides[descendantKey] then
                local keep = false
                if not lookup[descendantKey] then
                    local details = FindDetailsByKey(descendantKey)
                    if (details and self:HasHiddenAncestor(details)) or (not details and KeyHasHiddenAncestor(descendantKey)) then
                        keep = true
                    end
                end
                if not keep then
                    overrides[descendantKey] = nil
                end
            end
        end
        selfOverrides[headerKey] = nil
    end

    WriteLookupToSavedVar(lookup, "FactionHeaders")
    WriteLookupToSavedVar(overrides, "FactionShowOverrides")
    TitanSetVar(TitanPanelReputation.ID, "HeaderSelfOverrides", selfOverrides)

    self.hiddenFactionLookup = lookup
    self.shownFactionOverrideLookup = overrides
    self.headerSelfOverrideLookup = selfOverrides
end

---
---Check if a faction is a paragon faction
---
---@param factionID number The ID of the faction to check
---@return boolean True if the faction is a paragon faction with a positive paragon value, false otherwise
local function IsFactionParagon(factionID)
    if (C_Reputation.IsFactionParagon and C_Reputation.IsFactionParagon(factionID)) then
        local val = C_Reputation.GetFactionParagonInfo(factionID)
        if (val and val > 0) then
            return true
        end
    end
    return false
end

---
---Retrieves the current paragon reputation value and threshold for a given faction ID
---
---@param factionID number
---@return number|nil earnedValue The current paragon reputation value for the faction, or nil if not applicable
---@return number|nil topValue The paragon threshold for the faction, or nil if not applicable
---@return boolean paragonProgressStarted Whether the player has made any progress towards the next paragon reward for the faction
local function GetParagonInfo(factionID)
    local earnedValue, topValue = nil, nil

    local currentValue, threshold, _, hasRewardPending, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID)
    if currentValue then -- May be nil
        -- Set the top value to the paragon threshold
        topValue = threshold

        -- Calculate the offset level to account for the reputation offset caused by the paragon system
        -- ... The typical paragon threshold is 10000, so we can use that to calculate the offset level
        -- ... by dividing the current rep value by the thresholds and rounding down to the nearest whole
        -- ... number. E.g. 20000 / 10000 = 2, 30000 / 10000 = 3, etc. If there's a reward pending, we
        -- ... subtract 1 from the offset level.
        local offsetLevel = math.floor(currentValue / threshold)
        if hasRewardPending then
            offsetLevel = offsetLevel - 1
        end

        -- Now adjust the actual paragon reputation value by subtracting the offset level times the threshold
        -- from the current value. This will give us the actual reputation value for the paragon faction.
        -- ... E.g. 25000 - (2 * 10000) = 5000, 38000 - (3 * 10000) = 8000, etc.
        local adjustedValue = currentValue - (offsetLevel * threshold)
        earnedValue = adjustedValue
    end

    return earnedValue, topValue, not tooLowLevelForParagon
end

---
---Width of each classic reaction bracket (Hated .. Exalted). Stable game constants,
---used to count skipped brackets when a standing jumps more than one level at once.
---
local STANDING_BRACKET_WIDTH = {
    [1] = 36000, -- Hated
    [2] = 3000,  -- Hostile
    [3] = 3000,  -- Unfriendly
    [4] = 3000,  -- Neutral
    [5] = 6000,  -- Friendly
    [6] = 12000, -- Honored
    [7] = 21000, -- Revered
    [8] = 1000,  -- Exalted
}

---
---Retrieve the faction name where reputation changed to populate the `TitanPanelReputation.RTS` table.
---
---@param factionDetails FactionDetails
local function HandleFactionUpdate(factionDetails)
    -- Destructure props from FactionDetails
    local name, standingID, topValue, earnedValue, factionID =
        factionDetails.name,
        factionDetails.standingID,
        factionDetails.topValue,
        factionDetails.earnedValue,
        factionDetails.factionID

    -- Guard: Check if factionID is present in `TitanPanelReputation.TABLE`
    local previous = TitanPanelReputation.TABLE[factionID]
    if not previous then return end

    -- Guard: Check if standingID has not increased and earnedValue has not changed
    if previous.standingID == standingID and previous.earnedValue == earnedValue then
        return
    end

    -- Get adjusted ID and label depending on the faction type
    local adjusted = TitanPanelReputation:GetAdjustedIDAndLabel(factionDetails, true)
    if not adjusted then return end -- Return if adjusted is nil (is friendship && 'ShowFriendsOnBar' is disabled)

    -- Standing jumps of more than one level must also count the skipped brackets. Their
    -- widths only apply to the classic reaction ladder; renown/paragon/friendship report
    -- synthetic standings with different bracket sizes, so the sum is skipped for those.
    local isClassicLadder = adjusted.factionType == "Faction Standing" and adjusted.adjustedID <= 8

    -- Calculate the earned amount
    local earnedAmount = 0
    if (previous.standingID < standingID) then
        -- Standing increased: rest of the old bracket + skipped brackets + progress in the new one
        earnedAmount = (previous.topValue - previous.earnedValue) + earnedValue
        if isClassicLadder then
            for id = previous.standingID + 1, standingID - 1 do
                earnedAmount = earnedAmount + (STANDING_BRACKET_WIDTH[id] or 0)
            end
        end

        ShowReputationAnnouncement(name, factionID, adjusted)
    elseif (previous.standingID > standingID) then
        -- Standing decreased: progress lost in the old bracket + skipped brackets + distance below the new cap
        earnedAmount = (earnedValue - topValue) - previous.earnedValue
        if isClassicLadder then
            for id = standingID + 1, previous.standingID - 1 do
                earnedAmount = earnedAmount - (STANDING_BRACKET_WIDTH[id] or 0)
            end
        end

        ShowReputationAnnouncement(name, factionID, adjusted)
    elseif (previous.standingID == standingID) then
        -- Standing remained the same
        if (previous.earnedValue < earnedValue) or isClassicLadder then
            -- Progress within the bracket; negative when reputation was lost
            earnedAmount = earnedValue - previous.earnedValue
        else
            -- Renown, paragon and friendship progress restarts on a level-up (or once a paragon
            -- reward is collected) while the standing stays: rest of the old level + new progress
            earnedAmount = (previous.topValue - previous.earnedValue) + earnedValue
        end
    end

    -- Nothing earned (e.g. a paragon reward was collected): keep it out of the session summary
    if earnedAmount ~= 0 then
        TitanPanelReputation.RTS[name] = (TitanPanelReputation.RTS[name] or 0) + earnedAmount
    end

    -- Remember the faction with the biggest change of this burst for AutoChange (see main.lua).
    -- Gains win over losses: a loss only counts while no gain has been seen.
    local highChanged = TitanPanelReputation.HIGHCHANGED
    if (earnedAmount > 0 and earnedAmount > highChanged) or
        (earnedAmount < 0 and highChanged <= 0 and earnedAmount < highChanged) then
        TitanPanelReputation.HIGHCHANGED = earnedAmount
        TitanPanelReputation.CHANGED_FACTION = name
        TitanPanelReputation.CHANGED_FACTION_ID = factionID
    end
end

---
---This character's saved data (SavedVariablesPerCharacter).
---
---@return table
local function GetCharacterData()
    if type(TitanRep_CharData) ~= "table" then
        TitanRep_CharData = {}
    end
    return TitanRep_CharData
end

---
---Collects the values of one reputation row (as `BlizzAPI_GetFactionInfo` returns them) that the
---addon uses; nil for rows without a faction ID.
---
---@return table|nil row
---@nodiscard
local function ReadRow(name, _, standingID, bottomValue, topValue, earnedValue, _, _, isHeader,
                       isCollapsed, hasRep, _, isChild, factionID, hasBonusRepGain)
    if not factionID then
        return nil
    end
    return {
        name = name,
        standingID = standingID,
        bottomValue = bottomValue,
        topValue = topValue,
        earnedValue = earnedValue,
        isHeader = isHeader,
        isCollapsed = isCollapsed,
        hasRep = hasRep,
        isChild = isChild,
        factionID = factionID,
        hasBonusRepGain = hasBonusRepGain,
        isInactive = false,
    }
end

---
---Builds the details of one faction from its row (see `ReadRow`): normalizes the bar and applies
---paragon, renown and friendship progress. The hierarchy fields describe an entry at the top of
---the list; the list scan replaces them with the row's actual place.
---
---@param row table
---@return FactionDetails
---@nodiscard
local function CreateFactionDetails(row)
    local factionID = row.factionID

    -- Normalize values
    local topValue = row.topValue - row.bottomValue
    local earnedValue = row.earnedValue - row.bottomValue

    -- Used to determine if the player has started the paragon progress for the current faction
    local paragonProgressStarted = false

    -- Fetch friendship reputation info
    local friendShipReputationInfo = C_GossipInfo.GetFriendshipReputation(factionID)
    if not (friendShipReputationInfo and friendShipReputationInfo.friendshipFactionID > 0) then
        friendShipReputationInfo = nil
    end

    --[[ --------------------------------------------------------
            Handle Renown, Paragon and Friendship factions
        -----------------------------------------------------------]]
    -- Gated by API, not by build number: WoW Forever runs the retail API under a Classic version
    if (IsFactionParagon(factionID)) then -- Paragon
        -- Get faction paragon info
        local paragonEarnedValue, paragonTopValue, paragonProgress = GetParagonInfo(factionID)
        if paragonEarnedValue and paragonTopValue then
            earnedValue = paragonEarnedValue
            topValue = paragonTopValue
            paragonProgressStarted = paragonProgress
        end
    elseif (C_MajorFactions and C_Reputation.IsMajorFaction(factionID)) then -- Renown
        -- Get the renown faction data
        local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)

        if majorFactionData then
            -- Set the top value to the renown level threshold of the major faction
            topValue = majorFactionData.renownLevelThreshold

            -- If the faction has maximum renown, set the earned value to the renown level threshold of the major faction
            if C_MajorFactions.HasMaximumRenown(factionID) then
                earnedValue = majorFactionData.renownLevelThreshold
            else
                -- Otherwise, set the earned value to the renown reputation earned by the major faction
                earnedValue = majorFactionData.renownReputationEarned
            end
        end
    end

    if (friendShipReputationInfo) then -- Friendship (since MoP; the info is nil for every other faction)
        -- Set topValue to the difference between nextFriendThreshold and friendThreshold (reactionThreshold) if
        -- nextFriendThreshold exists, otherwise set it to the difference between friendRep (standing) and friendThreshold
        if friendShipReputationInfo.nextThreshold then
            topValue = friendShipReputationInfo.nextThreshold -
                friendShipReputationInfo.reactionThreshold
        else
            topValue = friendShipReputationInfo.standing - friendShipReputationInfo.reactionThreshold
        end
        earnedValue = friendShipReputationInfo.standing - friendShipReputationInfo.reactionThreshold
    end

    -- Calculate earnedValueRatio based on the earned value and top value. If top value is less than or equal to 0, set it to 0
    local earnedValueRatio = (topValue > 0) and (earnedValue / topValue) or 0

    -- Calculate the percentage and format it to 2 decimal places (e.g. 12.33334 -> 12.33)
    local percent = format("%.2f", earnedValueRatio * 100)

    -- NOTE: Uses default initialization because `GetFactionInfo` WOW API is not strictly typed,
    -- NOTE: but should always return valid values so defaults won't be used.
    local factionDetails = ---@type FactionDetails
    {
        name = row.name or "",
        parentName = "",
        standingID = row.standingID or -69,
        topValue = topValue,
        earnedValue = earnedValue,
        percent = percent,
        isHeader = row.isHeader or false,
        isCollapsed = row.isCollapsed or false,
        isInactive = row.isInactive or false,
        hasRep = row.hasRep or false,
        isChild = row.isChild or false,
        friendShipReputationInfo = friendShipReputationInfo,
        factionID = factionID,
        hasBonusRepGain = row.hasBonusRepGain or false,
        paragonProgressStarted = paragonProgressStarted or false,
        rowsUnknown = row.rowsUnknown or false,
        headerLevel = 0,
        headerPath = {}
    }
    return factionDetails
end

---
---The rows of each header as last seen expanded, per character: header factionID -> faction IDs of
---its direct rows in list order, or false for a header only seen collapsed so far. The client does
---not list the rows of a collapsed header, so the scan puts these back in (read by ID): the tooltip
---and menu do not depend on the collapse state.
---
---@return table<number, number[]|false>
local function GetKnownChildren()
    local data = GetCharacterData()
    data.KnownChildren = data.KnownChildren or {}
    return data.KnownChildren
end

---
---Reads the rows the client lists: all of them except the rows of collapsed headers.
---
---@return table[]
local function ReadListedRows()
    local rows = {}
    for index = 1, TitanPanelReputation:BlizzAPI_GetNumFactions() or 0 do
        local row = ReadRow(TitanPanelReputation:BlizzAPI_GetFactionInfo(index))
        if row then
            row.isInactive = TitanPanelReputation:BlizzAPI_IsFactionInactive(index)
            rows[#rows + 1] = row
        end
    end
    return rows
end

---
---Puts the remembered rows of collapsed headers back in after their header, and remembers the rows
---of the expanded ones (see `GetKnownChildren`). Inactive factions are not remembered: they are only
---listed under the "Inactive" header, which the tooltip and menu skip anyway. A collapsed header
---that was never seen expanded gets `rowsUnknown`: it has nothing to show until it is.
---
---@param listedRows table[]
---@return table[]
local function AddRowsOfCollapsedHeaders(listedRows)
    local knownChildren = GetKnownChildren()
    local listed = {}
    for _, row in ipairs(listedRows) do
        listed[row.factionID] = true
    end

    local rows, added, seenChildren = {}, {}, {}

    -- Read by ID, a row comes without its place in the list (the client reports it as a top-level
    -- row), so its nesting is taken from where it was remembered
    local function AddRemembered(headerID, isSubHeader)
        for _, factionID in ipairs(knownChildren[headerID] or {}) do
            if not listed[factionID] and not added[factionID] then
                local row = ReadRow(TitanPanelReputation:BlizzAPI_GetFactionInfoByID(factionID))
                if row then
                    row.isHeader = row.isHeader or knownChildren[factionID] ~= nil
                    row.isChild = isSubHeader or row.isHeader
                    added[factionID] = true
                    rows[#rows + 1] = row
                    if row.isHeader then
                        row.rowsUnknown = not knownChildren[factionID]
                        AddRemembered(factionID, true)
                    end
                end
            end
        end
    end

    local rootRow, nestedRow = nil, nil
    for _, row in ipairs(listedRows) do
        -- The header the row is listed under (same nesting rules as BuildFactionDetailsList)
        local parent = nil
        if row.isHeader and not row.isChild then
            rootRow, nestedRow = row, nil
        elseif row.isHeader then
            parent, nestedRow = rootRow, row
        else
            parent = (row.isChild and nestedRow) or rootRow
            if not row.isChild then
                nestedRow = nil
            end
        end
        local siblings = parent and seenChildren[parent.factionID]
        if siblings and not row.isInactive then
            siblings[#siblings + 1] = row.factionID
        end

        added[row.factionID] = true
        rows[#rows + 1] = row
        if row.isHeader then
            if row.isCollapsed then
                row.rowsUnknown = not knownChildren[row.factionID] and not row.isInactive
                if knownChildren[row.factionID] == nil then
                    knownChildren[row.factionID] = false -- a header whose rows were not seen yet
                end
                AddRemembered(row.factionID, row.isChild)
            else
                seenChildren[row.factionID] = {}
            end
        end
    end

    -- What the client lists under an expanded header is the current layout
    for headerID, children in pairs(seenChildren) do
        knownChildren[headerID] = children
    end
    return rows
end

---
---Rebuilds the ordered faction details list by scanning the Blizzard reputation API.
---
---@return FactionDetails[]
---@nodiscard
local function BuildFactionDetailsList()
    local rootHeader = ""
    local nestedHeader = ""
    local collectedDetails = {}

    for _, row in ipairs(AddRowsOfCollapsedHeaders(ReadListedRows())) do
        local name, isHeader, isChild = row.name, row.isHeader, row.isChild
        local factionDetails = CreateFactionDetails(row)

        local headerPath = {}
        if isHeader then
            if isChild then
                if rootHeader ~= "" then
                    tinsert(headerPath, rootHeader)
                end
                tinsert(headerPath, name)
            else
                tinsert(headerPath, name)
            end
        else
            local shouldAttachToNested = (nestedHeader ~= "" and isChild)
            if shouldAttachToNested then
                if rootHeader ~= "" then
                    tinsert(headerPath, rootHeader)
                end
                tinsert(headerPath, nestedHeader)
            else
                if rootHeader ~= "" then
                    tinsert(headerPath, rootHeader)
                end
            end
        end

        local headerLevel
        if isHeader then
            headerLevel = math.max(#headerPath - 1, 0)
        else
            headerLevel = #headerPath
        end

        local resolvedParentName = ""
        if isHeader then
            if #headerPath > 1 then
                resolvedParentName = headerPath[#headerPath - 1]
            end
        else
            if #headerPath > 0 then
                resolvedParentName = headerPath[#headerPath]
            end
        end

        factionDetails.parentName = resolvedParentName
        factionDetails.headerLevel = headerLevel
        factionDetails.headerPath = headerPath

        -- Apply optional faction mapping overrides before consumers use the data
        factionDetails = TitanPanelReputation:ApplyFactionMapping(factionDetails)

        -- The visibility checks look these up per entry and per menu row, so build them once
        factionDetails.nodeKey = BuildNodeKey(factionDetails)
        factionDetails.ancestorKeys = BuildAncestorKeys(factionDetails)
        factionDetails.rootKey = DetermineRootHeaderKey(factionDetails)

        if isHeader then
            if isChild then
                nestedHeader = name or ""
            else
                rootHeader = name or ""
                nestedHeader = ""
            end
        elseif not isChild then
            nestedHeader = ""
        end
        -- Collect the faction details for ordering after we finish scanning
        tinsert(collectedDetails, factionDetails)
    end

    return OrderFactionDetails(collectedDetails)
end

---
---Ordered faction list shared by every consumer (button, tooltip, menu). Scanning the
---Blizzard API is expensive, so the list is rebuilt lazily after `UPDATE_FACTION`
---invalidates it (see main.lua) instead of on every call.
---
---@type FactionDetails[]|nil
local factionDetailsCache = nil

function TitanPanelReputation:InvalidateFactionDetailsCache()
    factionDetailsCache = nil
end

---
---Looks up all factions details, and calls 'callback' with faction parameters.
---
---@param callback fun(factionDetails: FactionDetails) The callback to call with `FactionDetails` parameters
function TitanPanelReputation:FactionDetailsProvider(callback)
    if not factionDetailsCache then
        factionDetailsCache = BuildFactionDetailsList()
    end

    for _, details in ipairs(factionDetailsCache) do
        callback(details)
    end
end

---
---Builds the details of a faction by its ID, also while its header is collapsed (the list scan only
---sees expanded rows). Such entries have no place in the list and are not cached.
---
---@param factionID number
---@return FactionDetails|nil
---@nodiscard
function TitanPanelReputation:GetFactionDetailsByID(factionID)
    local row = ReadRow(self:BlizzAPI_GetFactionInfoByID(factionID))
    if not row then
        return nil
    end
    return self:ApplyFactionMapping(CreateFactionDetails(row))
end

---
---Shows the given faction on the button. Its ID keeps finding it while its header is collapsed.
---
---@param name string
---@param factionID number
function TitanPanelReputation:SetWatchedFaction(name, factionID)
    TitanSetVar(TitanPanelReputation.ID, "WatchedFaction", name)
    TitanSetVar(TitanPanelReputation.ID, "WatchedFactionID", factionID)
end

---
---The experience bar faction seen by the previous update; false before the first one.
---
---@type number|nil|false
local lastExperienceBarFactionID = false

---
---Shows the faction picked as "Show as Experience Bar" on the button whenever another one is
---picked there (and at login while the button shows none). In between, Shift-click in the menu
---still picks a faction; Auto Show Changed stays off as long as a faction is picked there.
---
---@return boolean following Whether a faction is shown as experience bar
function TitanPanelReputation:FollowExperienceBar()
    -- Plugin settings are only there once Titan has loaded its profile
    local watchedName = TitanGetVar(TitanPanelReputation.ID, "WatchedFaction")
    if watchedName == nil then
        return false
    end

    local factionID = self:BlizzAPI_GetExperienceBarFactionID()
    local picked = lastExperienceBarFactionID ~= false and factionID ~= lastExperienceBarFactionID
    lastExperienceBarFactionID = factionID
    if not factionID then
        return false
    end

    if picked or watchedName == "none" then
        local details = self:GetFactionDetailsByID(factionID)
        if details then
            self:SetWatchedFaction(details.name, factionID)
        end
    end
    return true
end

---
---Returns the faction shown on the button: found by its saved ID (by name for selections saved
---before the ID was), and looked up directly while its header is collapsed.
---
---@return FactionDetails|nil
---@nodiscard
function TitanPanelReputation:GetWatchedFactionDetails()
    local name = TitanGetVar(TitanPanelReputation.ID, "WatchedFaction")
    if not name or name == "none" then
        return nil
    end
    local factionID = TitanGetVar(TitanPanelReputation.ID, "WatchedFactionID")
    if not factionID or factionID == 0 then
        factionID = nil
    end

    local found = nil
    self:FactionDetailsProvider(function(details)
        if not found and (details.factionID == factionID or (not factionID and details.name == name)) then
            found = details
        end
    end)
    if found then
        if not factionID then
            TitanSetVar(TitanPanelReputation.ID, "WatchedFactionID", found.factionID)
        end
        return found
    end
    return factionID and self:GetFactionDetailsByID(factionID) or nil
end

---
---Refreshes the reputation data (rebuilds the button text).
---
function TitanPanelReputation:RefreshButtonText()
    local details = self:GetWatchedFactionDetails()
    if details then
        TitanPanelReputation.BuildButtonText(details)
    elseif TitanGetVar(TitanPanelReputation.ID, "WatchedFaction") == "none" then
        TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation:GT("LID_NO_FACTION_LABEL")
    end
end

---
---Node keys of the headers that were collapsed in the previous scan (see `IsRevealedByExpand`).
---
---@type table<string, boolean>
local collapsedHeaderKeys = {}

---
---Faction IDs this character has seen in the reputation list, saved per character: a faction that
---is missing from it is new, one that reappears from a collapsed header is not.
---
---@return table<number, boolean>
local function GetKnownFactions()
    local data = GetCharacterData()
    data.KnownFactions = data.KnownFactions or {}
    return data.KnownFactions
end

---
---Whether the entry only shows up because a header that was collapsed in the previous scan got
---expanded. Covers what the known factions cannot: headers kept collapsed since before this
---character's factions were first recorded.
---
---@param details FactionDetails
---@return boolean
local function IsRevealedByExpand(details)
    for _, key in ipairs(GetAncestorKeys(details)) do
        if collapsedHeaderKeys[key] then
            return true
        end
    end
    return false
end

---
---Whether the entry has reputation to track (factions and headers with their own reputation).
---
---@param details FactionDetails
---@return boolean
local function IsTrackable(details)
    return (not details.isHeader and details.name ~= nil) or (details.isHeader and details.hasRep)
end

---
---Records the entry's current values after reacting to their change since the last update.
---
---@param details FactionDetails
local function TrackFaction(details)
    -- 1. Handle the faction update
    HandleFactionUpdate(details)

    -- 2. Persist the faction update
    TitanPanelReputation.TABLE[details.factionID] = {
        name = details.name,
        standingID = details.standingID,
        earnedValue = details.earnedValue,
        topValue = details.topValue,
    }
end

---
---Public entrypoint used by the `UPDATE_FACTION` event handler in `main.lua`.
---
function TitanPanelReputation:HandleUpdateFaction()
    local newFactionsCount = 0
    local newFactions = {}
    local known = GetKnownFactions()
    local listed = {}
    local collapsedNow = {}
    local showAnnouncements = TitanGetVar(TitanPanelReputation.ID, "ShowAnnounceFrame") or TitanGetVar(TitanPanelReputation.ID, "ShowAnnounceMik")
    -- New factions are judged against the ones this character has seen before. The very first scan
    -- only records that baseline, and the client can still add factions shortly after login.
    local detectNewFactions = showAnnouncements and next(known) ~= nil
        and (GetTime() - TitanPanelReputation.INIT_TIME) > 30

    self:FactionDetailsProvider(function(details)
        if details.isHeader and details.isCollapsed then
            collapsedNow[self:GetNodeKey(details)] = true
        end

        if IsTrackable(details) then
            -- Detect newly discovered factions (for announcement later)
            if detectNewFactions and not known[details.factionID] and not IsRevealedByExpand(details)
                and details.earnedValue and details.earnedValue > 0 and details.standingID <= 4 then
                newFactionsCount = newFactionsCount + 1
                newFactions[details.factionID] = details
            end
            known[details.factionID] = true
            listed[details.factionID] = true

            TrackFaction(details)
        end
    end)
    collapsedHeaderKeys = collapsedNow

    -- Factions under collapsed headers are missing from the scan: look the known ones up by ID, so
    -- their reputation still counts for the session summary, announcements and Auto Show Changed
    for factionID in pairs(known) do
        if not listed[factionID] then
            local details = self:GetFactionDetailsByID(factionID)
            if details and IsTrackable(details) then
                TrackFaction(details)
            end
        end
    end

    -- 3. Announce newly discovered factions (iterate over collected newFactions)
    -- NOTE: Max 2 factions can be discovered at once, e.g. WotLK Horde Expedition
    local isNewFaction = (newFactionsCount == 1 or newFactionsCount == 2)
    if detectNewFactions and isNewFaction then
        for _, details in pairs(newFactions) do
            local adjusted = TitanPanelReputation:GetAdjustedIDAndLabel(details, true)

            if adjusted then
                ShowReputationAnnouncement(details.name, details.factionID, adjusted)
            end
        end
    end
    -- NOTE: No explicit RefreshButtonText here: main.lua follows up with
    -- TitanPanelButton_UpdateButton, which invokes buttonTextFunction and
    -- rebuilds the button text from the freshly cached faction list.
end

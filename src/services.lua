local _, TitanPanelReputation = ...

local WoW3 = select(4, GetBuildInfo()) >= 30000
local WoW5 = select(4, GetBuildInfo()) >= 50000
local WoW10 = select(4, GetBuildInfo()) >= 100000

local function BuildHiddenLookup(savedList)
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

local function WriteHiddenLookupToSavedVar(lookup)
    local serialized = {}
    for name in pairs(lookup) do
        serialized[#serialized + 1] = name
    end
    table.sort(serialized)
    TitanSetVar(TitanPanelReputation.ID, "FactionHeaders", serialized)
end

local function BuildOverrideLookup(savedList)
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

local function WriteOverrideLookupToSavedVar(lookup)
    local serialized = {}
    for name in pairs(lookup) do
        serialized[#serialized + 1] = name
    end
    table.sort(serialized)
    TitanSetVar(TitanPanelReputation.ID, "FactionShowOverrides", serialized)
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

function TitanPanelReputation:GetNodeKey(factionDetails)
    if not factionDetails then
        return ""
    end
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

local function GetAncestorKeyAndNamePairs(factionDetails)
    local pairsList = {}
    if not factionDetails or not factionDetails.headerPath then
        return pairsList
    end
    local hp = factionDetails.headerPath
    local maxIndex = #hp
    -- For headers, headerPath includes the header itself; ancestors are everything before the last element
    if factionDetails.isHeader and maxIndex > 0 then
        maxIndex = maxIndex - 1
    end
    for i = 1, maxIndex do
        pairsList[#pairsList + 1] = {
            key = JoinHeaderPath(hp, i),
            name = hp[i],
        }
    end
    return pairsList
end

function TitanPanelReputation:IsDescendantOfKey(rootKey, factionDetails)
    if not rootKey or rootKey == "" or not factionDetails then
        return false
    end
    local nodeKey = self:GetNodeKey(factionDetails)
    if nodeKey == rootKey then
        return true
    end
    for _, pair in ipairs(GetAncestorKeyAndNamePairs(factionDetails)) do
        if pair.key == rootKey then
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
    -- Achievement-style toasts require the Achievement system (WotLK+).
    if WoW3 and TitanGetVar(TitanPanelReputation.ID, "ShowAnnounceFrame") and alertPayload then
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
    local msg
    local dsc = "You have obtained "
    local tag = " "

    if (TitanPanelReputation.BARCOLORS) then
        msg = TitanUtils_GetColoredText(name .. " - " .. adjusted.label, TitanPanelReputation.BARCOLORS[(adjusted.adjustedID)])
        dsc = dsc .. TitanUtils_GetColoredText(adjusted.label, TitanPanelReputation.BARCOLORS[(adjusted.adjustedID)])
    else
        msg = TitanUtils_GetGoldText(name .. " - " .. adjusted.label)
        dsc = dsc .. TitanUtils_GetGoldText(adjusted.label)
    end

    dsc = dsc .. " standing with " .. name .. "."
    msg = tag .. msg .. tag

    local alertPayload = BuildStandingAlertPayload({ name = name, label = adjusted.label, adjustedID = adjusted.adjustedID, factionID = factionID })

    DispatchReputationAnnouncement(msg, alertPayload)
end

function TitanPanelReputation:TriggerDebugStandingToast(factionDetails)
    if not factionDetails or not TitanPanelReputation:IsDebugEnabled() then
        return
    end
    if not WoW3 then
        return
    end

    if factionDetails.isHeader and not factionDetails.hasRep then
        return
    end

    local adjusted = TitanPanelReputation:GetAdjustedIDAndLabel(
        factionDetails.factionID,
        factionDetails.standingID,
        factionDetails.friendShipReputationInfo,
        factionDetails.topValue,
        factionDetails.paragonProgressStarted,
        true
    )
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
        local bucket = EnsureBucket(DetermineRootHeaderKey(details))
        local level = details.headerLevel
        if level == nil then
            level = details.isHeader and 0 or (details.isChild and 2 or 1)
        end

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
        self.hiddenFactionLookup = BuildHiddenLookup(saved)
    end
    return self.hiddenFactionLookup
end

function TitanPanelReputation:GetShownFactionOverrideLookup()
    if not self.shownFactionOverrideLookup then
        local saved = TitanGetVar(TitanPanelReputation.ID, "FactionShowOverrides") or {}
        self.shownFactionOverrideLookup = BuildOverrideLookup(saved)
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

function TitanPanelReputation:IsNodeExplicitlyHiddenByKey(nodeKey)
    if not nodeKey or nodeKey == "" then
        return false
    end
    local lookup = self:GetHiddenFactionLookup()
    return lookup[nodeKey] or false
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

    for _, pair in ipairs(GetAncestorKeyAndNamePairs(factionDetails)) do
        if pair.key ~= "" and lookup[pair.key] then
            return true
        end
    end

    return false
end

function TitanPanelReputation:HasHiddenAncestor(factionDetails)
    if not factionDetails or not factionDetails.headerPath then
        return false
    end
    local lookup = self:GetHiddenFactionLookup()
    for _, pair in ipairs(GetAncestorKeyAndNamePairs(factionDetails)) do
        if pair.key ~= "" and lookup[pair.key] then
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

function TitanPanelReputation:IsBranchVisibleByKey(rootKey)
    if not rootKey or rootKey == "" then
        return false
    end
    return self:IsBranchVisible(rootKey)
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
    WriteOverrideLookupToSavedVar(overrides)
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

    WriteHiddenLookupToSavedVar(lookup)
    WriteOverrideLookupToSavedVar(overrides)
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

    -- Helper: determine if a nodeKey has any hidden ancestor purely from the key string,
    -- without relying on the current `FactionDetailsProvider` scan state.
    local function KeyHasHiddenAncestor(nodeKey)
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
            if lookup[prefix] then
                return true
            end
        end
        return false
    end

    -- Helper: determine if a nodeKey has any hidden ancestor OTHER than `excludeKey`.
    local function KeyHasOtherHiddenAncestor(nodeKey, excludeKey)
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
                if self:IsFactionEffectivelyHidden(details) and not KeyHasOtherHiddenAncestor(detailsKey, headerKey) then
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

    WriteHiddenLookupToSavedVar(lookup)
    WriteOverrideLookupToSavedVar(overrides)
    TitanSetVar(TitanPanelReputation.ID, "HeaderSelfOverrides", selfOverrides)

    self.hiddenFactionLookup = lookup
    self.shownFactionOverrideLookup = overrides
    self.headerSelfOverrideLookup = selfOverrides
end

---
---Retrieve the faction name where reputation changed to populate the `TitanPanelReputation.RTS` table.
---
---@param factionDetails FactionDetails
local function HandleFactionUpdate(factionDetails)
    -- Destructure props from FactionDetails
    local name, standingID, topValue, earnedValue, friendShipReputationInfo, factionID, paragonProgressStarted =
        factionDetails.name,
        factionDetails.standingID,
        factionDetails.topValue,
        factionDetails.earnedValue,
        factionDetails.friendShipReputationInfo,
        factionDetails.factionID,
        factionDetails.paragonProgressStarted

    -- Get adjusted ID and label depending on the faction type
    local adjusted = TitanPanelReputation:GetAdjustedIDAndLabel(factionID, standingID, friendShipReputationInfo, topValue, paragonProgressStarted, true)
    if not adjusted then return end -- Return if adjusted is nil (is friendship && 'ShowFriendsOnBar' is disabled)

    -- Guard: Check if factionID is present in `TitanPanelReputation.TABLE`
    if not TitanPanelReputation.TABLE[factionID] then
        -- If the faction has an earned amount and is not in the table yet, announce a newly discovered faction
        if earnedValue > 0 then
            ShowReputationAnnouncement(name, factionID, adjusted)
        end

        return
    end

    -- Guard: Check if standingID has not increased and earnedValue has not changed
    if TitanPanelReputation.TABLE[factionID].standingID == standingID and
        TitanPanelReputation.TABLE[factionID].earnedValue == earnedValue then
        return
    end

    -- Calculate the earned amount
    local earnedAmount = 0
    if (TitanPanelReputation.TABLE[factionID].standingID < standingID) then
        -- Standing increased
        earnedAmount = TitanPanelReputation.TABLE[factionID].topValue - TitanPanelReputation.TABLE[factionID].earnedValue
        earnedAmount = earnedValue + earnedAmount

        ShowReputationAnnouncement(name, factionID, adjusted)
    elseif (TitanPanelReputation.TABLE[factionID].standingID > standingID) then
        -- Standing decreased
        earnedAmount = earnedValue - topValue
        earnedAmount = earnedAmount - TitanPanelReputation.TABLE[factionID].earnedValue

        ShowReputationAnnouncement(name, factionID, adjusted)
    elseif (TitanPanelReputation.TABLE[factionID].standingID == standingID) then
        -- Standing remained the same
        if (TitanPanelReputation.TABLE[factionID].earnedValue < earnedValue) then
            -- Earned value increased
            earnedAmount = earnedValue - TitanPanelReputation.TABLE[factionID].earnedValue
        else
            -- Earned value remained the same
            earnedAmount = earnedValue
        end
    end

    if TitanPanelReputation.RTS[name] then
        TitanPanelReputation.RTS[name] = TitanPanelReputation.RTS[name] + earnedAmount
    else
        TitanPanelReputation.RTS[name] = earnedAmount
    end

    -- Check if the earned amount is a new high or low
    if (earnedAmount > 0 and earnedAmount > TitanPanelReputation.HIGHCHANGED) or
        (earnedAmount < 0 and earnedAmount < TitanPanelReputation.HIGHCHANGED) then
        -- If so, update the highest changed amount to the current earned amount
        TitanPanelReputation.HIGHCHANGED = earnedAmount
    end

    -- Update the current tracked faction when the reputation changes
    TitanPanelReputation.CHANGED_FACTION = name
end

---
---Looks up all factions details, and calls 'callback' with faction parameters.
---
---@param callback fun(factionDetails: FactionDetails) The callback to call with `FactionDetails` parameters
function TitanPanelReputation:FactionDetailsProvider(callback)
    local count = TitanPanelReputation:BlizzAPI_GetNumFactions()

    -- If there are no factions, return
    if not count then return end

    local done = false
    local index = 1
    local rootHeader = ""
    local nestedHeader = ""
    local collectedDetails = {}

    while (not done) do
        local name, description, standingID, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader,
        isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus =
            TitanPanelReputation:BlizzAPI_GetFactionInfo(index)
        if factionID then
            -- Normalize values
            topValue = topValue - bottomValue
            earnedValue = earnedValue - bottomValue
            bottomValue = 0

            -- Used to determine if the player has started the paragon progress for the current faction
            local paragonProgressStarted = false

            -- Fetch friendship reputation info
            local friendShipReputationInfo = nil
            if C_GossipInfo.GetFriendshipReputation(factionID) and C_GossipInfo.GetFriendshipReputation(factionID).friendshipFactionID > 0 then
                friendShipReputationInfo = C_GossipInfo.GetFriendshipReputation(factionID)
            end

            -- /run DevTools_Dump(C_GossipInfo.GetFriendshipReputation(2432))
            -- /run print(C_Reputation.IsFactionParagon(2432))
            -- /run print(C_Reputation.IsMajorFaction(2432))
            -- /run print(C_Reputation.GetFactionParagonInfo(2432))

            -- /run DevTools_Dump(C_GossipInfo.GetFriendshipReputation(2164))
            -- /run print(C_Reputation.IsFactionParagon(2164))
            -- /run print(C_Reputation.IsMajorFaction(2164))
            -- /run print(C_Reputation.GetFactionParagonInfo(2164))
            -- /run DevTools_Dump(C_Reputation.GetFactionDataByIndex(45))

            --[[ --------------------------------------------------------
                    Handle Paragon, Renown and Friendship factions
                -----------------------------------------------------------]]
            if (WoW10) then
                if (C_Reputation.IsFactionParagon(factionID)) then -- Paragon
                    -- Get faction paragon info
                    local currentValue, threshold, rewardQuestID, hasRewardPending, tooLowLevelForParagon, paragonStorageLevel = C_Reputation.GetFactionParagonInfo(factionID)
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

                        if currentValue ~= 0 then
                            -- If the current value is not 0, the player has started the paragon progress for the current faction
                            paragonProgressStarted = true
                        end
                    end
                elseif (C_Reputation.IsMajorFaction(factionID)) then -- Renown
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
            end

            if (WoW5) then -- Friendship Reputation is available with MoP
                if (friendShipReputationInfo) then
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
            end

            -- Calculate earnedValueRatio based on the earned value and top value. If top value is less than or equal to 0, set it to 0
            local earnedValueRatio = (topValue > 0) and (earnedValue / topValue) or 0

            -- Calculate the percentage and format it to 2 decimal places (e.g. 12.33334 -> 12.33)
            local percent = format("%.2f", earnedValueRatio * 100)

            local headerPath = {}
            if isHeader then
                if isChild then
                    if rootHeader ~= "" then
                        tinsert(headerPath, rootHeader)
                    end
                    tinsert(headerPath, name)
                else
                    wipe(headerPath)
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
                    if not isChild then
                        nestedHeader = ""
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

            -- NOTE: Uses default initialization because `GetFactionInfo` WOW API is not strictly typed,
            -- NOTE: but should always return valid values so defaults won't be used.
            local factionDetails = ---@type FactionDetails
            {
                name = name or "",
                parentName = resolvedParentName,
                standingID = standingID or -69,
                topValue = topValue,
                earnedValue = earnedValue,
                percent = percent,
                isHeader = isHeader or false,
                isCollapsed = isCollapsed or false,
                isInactive = TitanPanelReputation:BlizzAPI_IsFactionInactive(index),
                hasRep = hasRep or false,
                isChild = isChild or false,
                friendShipReputationInfo = friendShipReputationInfo,
                factionID = factionID,
                hasBonusRepGain = hasBonusRepGain or false,
                paragonProgressStarted = paragonProgressStarted or false,
                headerLevel = headerLevel,
                headerPath = headerPath
            }
            -- Apply optional faction mapping overrides before consumers use the data
            factionDetails = TitanPanelReputation:ApplyFactionMapping(factionDetails)

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

        index = index + 1

        if (index > count) then done = true; end -- If we're done, set done to true
    end

    local orderedDetails = OrderFactionDetails(collectedDetails)
    for _, details in ipairs(orderedDetails) do
        callback(details) -- Call the callback with the faction details
    end
end

---
---Refreshes the reputation data (rebuilds the button text).
---
function TitanPanelReputation:RefreshButtonText()
    if not (TitanGetVar(TitanPanelReputation.ID, "WatchedFaction") == "none") then
        self:FactionDetailsProvider(TitanPanelReputation.BuildButtonText)
    else
        TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation:GT("LID_NO_FACTION_LABEL")
    end
end

---
---Public entrypoint used by the `UPDATE_FACTION` event handler in `main.lua`.
---
function TitanPanelReputation:HandleUpdateFaction()
    self:FactionDetailsProvider(function(details)
        -- Check if the faction can be tracked
        if (not details.isHeader and details.name) or (details.isHeader and details.hasRep) then
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
    end)

    -- 3. Refresh the button
    self:RefreshButtonText()
end

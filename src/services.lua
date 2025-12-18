local _, TitanPanelReputation = ...

local WoW5 = select(4, GetBuildInfo()) >= 50000
local WoW10 = select(4, GetBuildInfo()) >= 100000

local function BuildHiddenLookup(savedList)
    local lookup = {}
    if type(savedList) == "table" then
        for _, name in ipairs(savedList) do
            if type(name) == "string" and name ~= "" then
                lookup[name] = true
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
        for _, name in ipairs(savedList) do
            if type(name) == "string" and name ~= "" then
                lookup[name] = true
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

local function IsAncestor(target, headerPath)
    if not headerPath then return false end
    for _, ancestor in ipairs(headerPath) do
        if ancestor == target then
            return true
        end
    end
    return false
end

local function CollectBranchNames(rootName)
    local names = {}
    if not rootName or rootName == "" then
        return names
    end
    TitanPanelReputation:FactionDetailsProvider(function(details)
        if details.name == rootName or IsAncestor(rootName, details.headerPath) then
            names[#names + 1] = details.name
        end
    end)
    return names
end

--[[ TitanPanelReputation
NAME: DetermineRootHeaderKey
DESC: Resolves the bucket key used when regrouping the reputation tree. For root headers
it returns their own name, for child nodes it walks up the cached headerPath so every
entry produced by `FactionDetailsProvider` can be associated with the correct top-level
header before reordering the results.
]]
---@param factionDetails FactionDetails|nil
---@return string
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

--[[ TitanPanelReputation
NAME: OrderFactionDetails
DESC: Given the raw faction list produced by the Blizzard API, rebuilds it so each root
header emits its direct factions first and then any nested header buckets. This keeps
the UI grouped as Main Header → direct factions → sub-header groups → sub-factions regardless
of the order Blizzard returns rows in.
]]
---@param detailsList FactionDetails[]|nil
---@return FactionDetails[]
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

function TitanPanelReputation:IsNodeExplicitlyHidden(name)
    if not name or name == "" then
        return false
    end
    local lookup = self:GetHiddenFactionLookup()
    return lookup[name] or false
end

function TitanPanelReputation:IsFactionEffectivelyHidden(factionDetails)
    if not factionDetails then
        return false
    end
    local lookup = self:GetHiddenFactionLookup()
    local shownOverrides = self:GetShownFactionOverrideLookup()

    if factionDetails.name and shownOverrides[factionDetails.name] then
        return false
    end

    if factionDetails.name and lookup[factionDetails.name] then
        return true
    end

    if factionDetails.headerPath then
        for _, ancestor in ipairs(factionDetails.headerPath) do
            if lookup[ancestor] then
                return true
            end
        end
    end

    return false
end

function TitanPanelReputation:HasHiddenAncestor(factionDetails)
    if not factionDetails or not factionDetails.headerPath then
        return false
    end
    local lookup = self:GetHiddenFactionLookup()
    for _, ancestor in ipairs(factionDetails.headerPath) do
        if lookup[ancestor] then
            return true
        end
    end
    return false
end

function TitanPanelReputation:IsBranchVisible(rootName)
    if not rootName or rootName == "" then
        return false
    end
    local visible = false
    self:FactionDetailsProvider(function(details)
        if visible then return end
        if details.name == rootName or IsAncestor(rootName, details.headerPath) then
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
    for _, name in ipairs(CollectBranchNames(rootName)) do
        overrides[name] = nil
    end
    WriteOverrideLookupToSavedVar(overrides)
end

function TitanPanelReputation:SetFactionHiddenState(factionDetails, hidden)
    if not factionDetails or not factionDetails.name then
        return
    end

    local lookup = self:GetHiddenFactionLookup()
    local overrides = self:GetShownFactionOverrideLookup()
    if hidden then
        if factionDetails.name ~= "" then
            lookup[factionDetails.name] = true
        end
        overrides[factionDetails.name] = nil
        TitanPanelReputation:ClearShownOverridesForBranch(factionDetails.name)
    else
        lookup[factionDetails.name] = nil
        overrides[factionDetails.name] = nil
        if factionDetails.isHeader then
            local branchNames = CollectBranchNames(factionDetails.name)
            if #branchNames > 0 then
                for _, branchName in ipairs(branchNames) do
                    lookup[branchName] = nil
                    overrides[branchName] = nil
                end
                if TitanPanelReputation:HasHiddenAncestor(factionDetails) then
                    for _, branchName in ipairs(branchNames) do
                        overrides[branchName] = true
                    end
                end
            end
        elseif TitanPanelReputation:HasHiddenAncestor(factionDetails) then
            overrides[factionDetails.name] = true
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

--[[ TitanPanelReputation
NAME: TitanPanelReputation.GetChangedName
DESC: Retrieve the faction name where reputation changed to populate the `TitanPanelReputation.RTS` table.
]]
---@param factionDetails FactionDetails
function TitanPanelReputation.GetChangedName(factionDetails)
    -- Destructure props from FactionDetails
    local name, standingID, topValue, earnedValue, friendShipReputationInfo, factionID =
        factionDetails.name,
        factionDetails.standingID,
        factionDetails.topValue,
        factionDetails.earnedValue,
        factionDetails.friendShipReputationInfo,
        factionDetails.factionID

    -- TODO: Make guild faction an option to track
    if factionID == TitanPanelReputation.G_FACTION_ID then return end

    -- Guard: Check if TABLE_INIT is not true or factionID is present in `TitanPanelReputation.TABLE`
    if not TitanPanelReputation.TABLE_INIT or not TitanPanelReputation.TABLE[factionID] then return end

    -- Guard: Check if standingID has not increased and earnedValue has not changed
    if TitanPanelReputation.TABLE[factionID].standingID == standingID and
        TitanPanelReputation.TABLE[factionID].earnedValue == earnedValue then
        return
    end

    -- Get adjusted ID and label depending on the faction type
    local adjustedIDAndLabel = TitanPanelReputation:GetAdjustedIDAndLabel(
        factionID, standingID, friendShipReputationInfo, topValue, true)
    -- Return if adjustedIDAndLabel is nil (is friendship && 'ShowFriendsOnBar' is disabled)
    if not adjustedIDAndLabel then return end
    -- Destructure props from AdjustedIDAndLabel
    local adjustedID, LABEL = adjustedIDAndLabel.adjustedID, adjustedIDAndLabel.label

    -- Init function local variables
    local msg -- ""
    local dsc = "You have obtained "
    local tag = " "
    local earnedAmount = 0

    if (TitanPanelReputation.TABLE[factionID].standingID < standingID) then
        if (TitanPanelReputation.BARCOLORS) then
            msg = TitanUtils_GetColoredText(name .. " - " .. LABEL, TitanPanelReputation.BARCOLORS[(adjustedID)])
            dsc = dsc .. TitanUtils_GetColoredText(LABEL, TitanPanelReputation.BARCOLORS[(adjustedID)])
        else
            msg = TitanUtils_GetGoldText(name .. " - " .. LABEL)
            dsc = dsc .. TitanUtils_GetGoldText(LABEL)
        end

        dsc = dsc .. " standing with " .. name .. "."
        msg = tag .. msg .. tag

        if (TitanGetVar(TitanPanelReputation.ID, "ShowAnnounce")) then
            if (C_AddOns.IsAddOnLoaded("MikScrollingBattleText") and TitanGetVar(TitanPanelReputation.ID, "ShowAnnounceMik")) then
                MikSBT.DisplayMessage("|T" ..
                    TitanPanelReputation.ICON .. ":32|t" .. msg .. "|T" ..
                    TitanPanelReputation.ICON .. ":32|t", MikSBT.DISPLAYTYPE_NOTIFICATION, true)
            else
                UIErrorsFrame:AddMessage("|T" ..
                    TitanPanelReputation.ICON .. ":32|t" .. msg .. "|T" ..
                    TitanPanelReputation.ICON .. ":32|t", 2.0, 2.0, 0.0, 1.0, 53, 30)
            end
        end

        -- TODO: Implement achivement style announcements based on official WoW API
        -- if (TitanGetVar(TitanPanelReputation.ID, "ShowAnnounceFrame")) then
        --     if (C_AddOns.IsAddOnLoaded("Glamour")) then
        --         local MyData = {}
        --         MyData.Text = name .. " - " .. LABEL
        --         MyData.Icon = "Interface\\ICONS\\Achievement_Reputation_" .. TitanPanelReputation_ICONS[(adjustedID)]
        --         local color = {}
        --         color.r = TitanPanelReputation.COLORS_ARMORY[(adjustedID)].r
        --         color.g = TitanPanelReputation.COLORS_ARMORY[(adjustedID)].g
        --         color.b = TitanPanelReputation.COLORS_ARMORY[(adjustedID)].b
        --         MyData.bTitle = factionType .. " Upgrade"
        --         MyData.Title = ""
        --         MyData.FrameStyle = "GuildAchievement"
        --         MyData.BannerColor = color
        --         local LastAlertFrame = GlamourShowAlert(400, MyData, color, color)
        --     end
        -- end

        earnedAmount = TitanPanelReputation.TABLE[factionID].topValue -
            TitanPanelReputation.TABLE[factionID].earnedValue
        -- TitanDebug(
        --     "<TitanPanelReputation> earnedAmount = TitanPanelReputation.TABLE[factionID].topValue - TitanPanelReputation.TABLE[factionID].earnedValue: " ..
        --     earnedAmount ..
        --     " = " .. TitanPanelReputation.TABLE[factionID].topValue .. " - " .. TitanPanelReputation.TABLE[factionID].earnedValue)
        earnedAmount = earnedValue + earnedAmount
        -- TitanDebug("<TitanPanelReputation> earnedAmount = earnedValue + earnedAmount: " .. earnedAmount .. " = " ..
        --     earnedValue .. " + " .. earnedAmount)
    elseif (TitanPanelReputation.TABLE[factionID].standingID > standingID) then
        if (TitanPanelReputation.BARCOLORS) then
            msg = TitanUtils_GetColoredText(name .. " - " .. LABEL, TitanPanelReputation.BARCOLORS[(adjustedID)])
            dsc = dsc .. TitanUtils_GetColoredText(LABEL, TitanPanelReputation.BARCOLORS[(adjustedID)])
        else
            msg = TitanUtils_GetGoldText(name .. " - " .. LABEL)
            dsc = dsc .. TitanUtils_GetGoldText(LABEL)
        end

        dsc = dsc .. " standing with " .. name .. "."
        msg = tag .. msg .. tag

        if (TitanGetVar(TitanPanelReputation.ID, "ShowAnnounce")) then
            if (C_AddOns.IsAddOnLoaded("MikScrollingBattleText") and TitanGetVar(TitanPanelReputation.ID, "ShowAnnounceMik")) then
                MikSBT.DisplayMessage("|T" ..
                    TitanPanelReputation.ICON .. ":32|t" .. msg .. "|T" ..
                    TitanPanelReputation.ICON .. ":32|t", MikSBT.DISPLAYTYPE_NOTIFICATION, true)
            else
                UIErrorsFrame:AddMessage("|T" ..
                    TitanPanelReputation.ICON .. ":32|t" .. msg .. "|T" ..
                    TitanPanelReputation.ICON .. ":32|t", 2.0, 2.0, 0.0, 1.0, 53, 30)
            end
        end

        -- TODO: Implement achievement style announcements based on official WoW API
        -- if (TitanGetVar(TitanPanelReputation.ID, "ShowAnnounceFrame")) then
        --     if (C_AddOns.IsAddOnLoaded("Glamour")) then
        --         local MyData = {}
        --         MyData.Text = name .. " - " .. LABEL
        --         MyData.Icon = "Interface\\ICONS\\Achievement_Reputation_" .. TitanPanelReputation_ICONS[(adjustedID)]
        --         local color = {}
        --         color.r = TitanPanelReputation.COLORS_ARMORY[(adjustedID)].r
        --         color.g = TitanPanelReputation.COLORS_ARMORY[(adjustedID)].g
        --         color.b = TitanPanelReputation.COLORS_ARMORY[(adjustedID)].b
        --         MyData.bTitle = factionType .. " Downgrade"
        --         MyData.Title = ""
        --         MyData.FrameStyle = "GuildAchievement"
        --         MyData.BannerColor = color
        --         local LastAlertFrame = GlamourShowAlert(400, MyData, color, color)
        --     end
        -- end

        earnedAmount = earnedValue - topValue
        -- TitanDebug("<TitanPanelReputation> earnedAmount = earnedValue - topValue: " ..
        --     earnedAmount .. " = " .. earnedValue .. " - " .. topValue)
        earnedAmount = earnedAmount - TitanPanelReputation.TABLE[factionID].earnedValue
        -- TitanDebug("<TitanPanelReputation> earnedAmount = earnedValue - TitanPanelReputation.TABLE[factionID].earnedValue: " ..
        --     earnedAmount .. " = " .. earnedValue .. " - " .. TitanPanelReputation.TABLE[factionID].earnedValue)
    elseif (TitanPanelReputation.TABLE[factionID].standingID == standingID) then
        -- TitanDebug("<TitanPanelReputation> elseif (TitanPanelReputation.TABLE[factionID].standingID == standingID) then")
        if (TitanPanelReputation.TABLE[factionID].earnedValue < earnedValue) then
            -- TitanDebug("<TitanPanelReputation> if (TitanPanelReputation.TABLE[factionID].earnedValue < earnedValue) then")
            earnedAmount = earnedValue - TitanPanelReputation.TABLE[factionID].earnedValue
            -- TitanDebug("<TitanPanelReputation> earnedAmount = earnedValue - TitanPanelReputation.TABLE[factionID].earnedValue: " ..
            --     earnedAmount .. " = " .. earnedValue .. " - " .. TitanPanelReputation.TABLE[factionID].earnedValue)
        else
            -- TitanDebug("<TitanPanelReputation> else")
            earnedAmount = earnedValue
        end
    end

    if TitanPanelReputation.RTS[name] then
        -- TitanDebug("<TitanPanelReputation> Reputation Changed: " ..
        --     name .. " by " .. TitanPanelReputation.RTS[name] + earnedAmount .. ", was: " .. TitanPanelReputation.RTS[name])

        TitanPanelReputation.RTS[name] = TitanPanelReputation.RTS[name] + earnedAmount
    else
        -- TitanDebug("<TitanPanelReputation> Reputation Changed: " .. name .. " by " .. earnedAmount .. ", was: None / 0")
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

--[[ TitanPanelReputation
NAME: TitanPanelReputation.GatherValues
DESC: Gathers all reputation values for each faction to populate the `TitanPanelReputation.TABLE` table.
]]
---@param factionDetails FactionDetails
function TitanPanelReputation.GatherValues(factionDetails)
    -- Destructure props from FactionDetails
    local name, standingID, topValue, earnedValue, isHeader, hasRep, friendShipReputationInfo, factionID =
        factionDetails.name,
        factionDetails.standingID,
        factionDetails.topValue,
        factionDetails.earnedValue,
        factionDetails.isHeader,
        factionDetails.hasRep,
        factionDetails.friendShipReputationInfo,
        factionDetails.factionID

    local isValidFaction = (not isHeader and name) or (isHeader and hasRep) -- Check if the faction can be tracked

    -- Announce newly discovered faction
    if TitanPanelReputation.TABLE_INIT and not TitanPanelReputation.TABLE[factionID] and isValidFaction then
        -- Get adjusted ID and label depending on the faction type
        local adjustedIDAndLabel = TitanPanelReputation:GetAdjustedIDAndLabel(
            factionID, standingID, friendShipReputationInfo, topValue, true)
        -- Return if adjustedIDAndLabel is nil (is friendship && 'ShowFriendsOnBar' is disabled)
        if not adjustedIDAndLabel then return end
        -- Destructure props from AdjustedIDAndLabel
        local adjustedID, LABEL = adjustedIDAndLabel.adjustedID, adjustedIDAndLabel.label

        -- Init function local variables
        local msg -- ""
        local dsc = "You have obtained "
        local tag = " "

        if (TitanPanelReputation.BARCOLORS) then
            msg = TitanUtils_GetColoredText(name .. " - " .. LABEL, TitanPanelReputation.BARCOLORS[(adjustedID)])
            dsc = dsc .. TitanUtils_GetColoredText(LABEL, TitanPanelReputation.BARCOLORS[(adjustedID)])
        else
            msg = TitanUtils_GetGoldText(name .. " - " .. LABEL)
            dsc = dsc .. TitanUtils_GetGoldText(LABEL)
        end

        dsc = dsc .. " standing with " .. name .. "."
        msg = tag .. msg .. tag

        if (TitanGetVar(TitanPanelReputation.ID, "ShowAnnounce")) then
            if (C_AddOns.IsAddOnLoaded("MikScrollingBattleText") and TitanGetVar(TitanPanelReputation.ID, "ShowAnnounceMik")) then
                MikSBT.DisplayMessage("|T" ..
                    TitanPanelReputation.ICON .. ":32|t" .. msg .. "|T" ..
                    TitanPanelReputation.ICON .. ":32|t", MikSBT.DISPLAYTYPE_NOTIFICATION, true)
            else
                UIErrorsFrame:AddMessage("|T" ..
                    TitanPanelReputation.ICON .. ":32|t" .. msg .. "|T" ..
                    TitanPanelReputation.ICON .. ":32|t", 2.0, 2.0, 0.0, 1.0, 53, 30)
            end
        end

        -- TODO: Implement achievement style announcements based on official WoW API
        -- if (TitanGetVar(TitanPanelReputation.ID, "ShowAnnounceFrame")) then
        --     if (C_AddOns.IsAddOnLoaded("Glamour")) then
        --         local MyData = {}
        --         MyData.Text = name .. " - " .. LABEL
        --         MyData.Icon = "Interface\\ICONS\\Achievement_Reputation_" .. TitanPanelReputation_ICONS[(adjustedID)]
        --         local color = {}
        --         color.r = TitanPanelReputation.COLORS_ARMORY[(adjustedID)].r
        --         color.g = TitanPanelReputation.COLORS_ARMORY[(adjustedID)].g
        --         color.b = TitanPanelReputation.COLORS_ARMORY[(adjustedID)].b
        --         MyData.bTitle = "New " .. factionType .. " Discovered"
        --         MyData.Title = "You have discovered"
        --         MyData.FrameStyle = "GuildAchievement"
        --         MyData.BannerColor = color
        --         local LastAlertFrame = GlamourShowAlert(400, MyData, color, color)
        --     end
        -- end
    end

    if isValidFaction then
        TitanPanelReputation.TABLE[factionID] = {}
        TitanPanelReputation.TABLE[factionID].name = name
        TitanPanelReputation.TABLE[factionID].standingID = standingID
        TitanPanelReputation.TABLE[factionID].earnedValue = earnedValue
        TitanPanelReputation.TABLE[factionID].topValue = topValue
    end
end

--[[ TitanPanelReputation
NAME: TitanPanelReputation:FactionDetailsProvider
DESC: Looks up all factions details, and calls 'method' with faction parameters.
]]
---@param method function The method to call with @class `FactionDetails` parameters
function TitanPanelReputation:FactionDetailsProvider(method)
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

        -- NOTE: If we ever want to filter out addon reputation grouping OR make the reputation selection more nested
        -- TODO: Alliance specific factions missing
        -- local skipFactionIDs = {
        --     -- Shadowlands
        --     [2445] = true, -- "Der Gluthof"
        --     -- MOP
        --     [1272] = true, -- "Die Ackerbauern"
        --     [1302] = true, -- "Die Angler"
        --     -- WOLTK
        --     [1052] = true, -- "Horde Expedition"
        --     -- TBC
        --     [936] = true,  -- "Shattrath"
        --     [169] = true,  -- "Steamwheel Cartell"
        --     [67] = true,   -- "Horde"
        --     [892] = true,  -- "Horde Forces"
        -- }
        -- if factionID and not skipFactionIDs[factionID] then


        if factionID then
            -- Normalize values
            topValue = topValue - bottomValue
            earnedValue = earnedValue - bottomValue
            bottomValue = 0

            -- Fetch friendship reputation info
            local friendShipReputationInfo = nil
            if C_GossipInfo.GetFriendshipReputation(factionID) and C_GossipInfo.GetFriendshipReputation(factionID).friendshipFactionID > 0 then
                friendShipReputationInfo = C_GossipInfo.GetFriendshipReputation(factionID)
            end

            --[[ --------------------------------------------------------
                    Handle Paragon, Renown and Friendship factions
                -----------------------------------------------------------]]
            if (WoW10) then
                if (C_Reputation.IsFactionParagon(factionID)) then -- Paragon
                    -- Get faction paragon info
                    local currentValue, threshold, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
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
            local currentParent = ""
            if isHeader then
                if isChild then
                    currentParent = rootHeader
                    if rootHeader ~= "" then
                        tinsert(headerPath, rootHeader)
                    end
                    tinsert(headerPath, name)
                else
                    currentParent = ""
                    wipe(headerPath)
                    tinsert(headerPath, name)
                end
            else
                local shouldAttachToNested = (nestedHeader ~= "" and isChild)
                if shouldAttachToNested then
                    currentParent = nestedHeader
                    if rootHeader ~= "" then
                        tinsert(headerPath, rootHeader)
                    end
                    tinsert(headerPath, nestedHeader)
                else
                    currentParent = rootHeader
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
        method(details)
    end
end

--[[ TitanPanelReputation
NAME: TitanPanelReputation:Refresh
DESC: Refreshes the reputation data (rebuilds the button text).
]]
function TitanPanelReputation:Refresh()
    if not (TitanGetVar(TitanPanelReputation.ID, "WatchedFaction") == "none") then
        TitanPanelReputation:FactionDetailsProvider(TitanPanelReputation.BuildButtonText)
    else
        TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation:GT("LID_NO_FACTION_LABEL")
    end
end

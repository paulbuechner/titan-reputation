local _, TitanPanelReputation = ...

--[[ TitanPanelReputation
NAME: TitanPanelReputation.GetChangedName
DESC: Retrieve the faction name where reputation changed to populate the `TitanPanelReputation.RTS` table.
]]
---@param factionDetails FactionDetails
function TitanPanelReputation.GetChangedName(factionDetails)
    -- Destructure props from FactionDetails
    local name, standingID, topValue, earnedValue, friendShipReputationInfo, factionID, hasBonusRepGain =
        factionDetails.name,
        factionDetails.standingID,
        factionDetails.topValue,
        factionDetails.earnedValue,
        factionDetails.friendShipReputationInfo,
        factionDetails.factionID,
        factionDetails.hasBonusRepGain

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
    local adjustedIDAndLabel = TitanPanelReputation:GetAdjustedIDAndLabel(factionID, standingID,
        friendShipReputationInfo, topValue, hasBonusRepGain, true)
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

            -- Fix for renown rep change showing negative RTS values
            if C_Reputation.IsMajorFaction(factionID) then
                -- TitanDebug("<TitanPanelReputation> if isMajorFactionHeader then")
                earnedAmount = earnedValue
                -- TitanDebug("<TitanPanelReputation> earnedAmount = earnedValue - TitanPanelReputation.TABLE[factionID].earnedValue: " ..
                --     earnedAmount .. " = " .. earnedValue .. " - " .. TitanPanelReputation.TABLE[factionID].earnedValue)
            else
                earnedAmount = earnedValue - TitanPanelReputation.TABLE[factionID].earnedValue
                -- TitanDebug("<TitanPanelReputation> earnedAmount = earnedValue - TitanPanelReputation.TABLE[factionID].earnedValue: " ..
                --     earnedAmount .. " = " .. earnedValue .. " - " .. TitanPanelReputation.TABLE[factionID].earnedValue)
            end
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
    local name, standingID, topValue, earnedValue, isHeader, hasRep, friendShipReputationInfo, factionID, hasBonusRepGain =
        factionDetails.name,
        factionDetails.standingID,
        factionDetails.topValue,
        factionDetails.earnedValue,
        factionDetails.isHeader,
        factionDetails.hasRep,
        factionDetails.friendShipReputationInfo,
        factionDetails.factionID,
        factionDetails.hasBonusRepGain

    local isValidFaction = (not isHeader and name) or (isHeader and hasRep) -- Check if the faction can be tracked

    -- Announce newly discovered faction
    if TitanPanelReputation.TABLE_INIT and not TitanPanelReputation.TABLE[factionID] and isValidFaction then
        -- Get adjusted ID and label depending on the faction type
        local adjustedIDAndLabel = TitanPanelReputation:GetAdjustedIDAndLabel(factionID, standingID,
            friendShipReputationInfo, topValue, hasBonusRepGain, true)
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
    local count = GetNumFactions()

    -- If there are no factions, return
    if not count then return end

    local done = false
    local index = 1
    local parentName = ""

    while (not done) do
        local name, description, standingID, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader,
        isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(index)

        if factionID then
            -- Normalize values
            topValue = topValue - bottomValue
            earnedValue = earnedValue - bottomValue
            bottomValue = 0

            -- Fetch friendship reputation info
            local friendShipReputationInfo = C_GossipInfo.GetFriendshipReputation(factionID).friendshipFactionID > 0 and
                C_GossipInfo.GetFriendshipReputation(factionID) or nil

            --[[ --------------------------------------------------------
                    Handle Paragon, Renown and Friendship factions
            -----------------------------------------------------------]]
            if (C_Reputation.IsFactionParagon(factionID)) then -- Paragon
                -- Get faction paragon info
                local currentValue, threshold, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)

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

                earnedValue, hasBonusRepGain = adjustedValue, true
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
            elseif (friendShipReputationInfo) then -- Friendship
                -- Set topValue to the difference between nextFriendThreshold and friendThreshold (reactionThreshold) if
                -- nextFriendThreshold exists, otherwise set it to the difference between friendRep (standing) and friendThreshold
                if friendShipReputationInfo.nextThreshold then
                    topValue = friendShipReputationInfo.nextThreshold - friendShipReputationInfo.reactionThreshold
                else
                    topValue = friendShipReputationInfo.standing - friendShipReputationInfo.reactionThreshold
                end
                earnedValue = friendShipReputationInfo.standing - friendShipReputationInfo.reactionThreshold
            end

            -- Calculate earnedValueRatio based on the earned value and top value. If top value is less than or equal to 0, set it to 0
            local earnedValueRatio = (topValue > 0) and (earnedValue / topValue) or 0

            -- Calculate the percentage and format it to 2 decimal places (e.g. 12.33334 -> 12.33)
            local percent = format("%.2f", earnedValueRatio * 100)

            -- If it's a header and name exists, set the parent name to name
            if (isHeader) and name then parentName = name; end

            -- NOTE: Uses default initialization because `GetFactionInfo` WOW API is not strictly typed,
            -- NOTE: but should always return valid values so defaults won't be used.
            local factionDetails = ---@type FactionDetails
            {
                name = name or "",
                parentName = parentName,
                standingID = standingID or -69,
                topValue = topValue,
                earnedValue = earnedValue,
                percent = percent,
                isHeader = isHeader or false,
                isCollapsed = isCollapsed or false,
                isInactive = IsFactionInactive(index),
                hasRep = hasRep or false,
                isChild = isChild or false,
                friendShipReputationInfo = friendShipReputationInfo,
                factionID = factionID,
                hasBonusRepGain = hasBonusRepGain or false
            }
            -- Call the method with the faction details
            method(factionDetails)
        end

        index = index + 1

        if (index > count) then done = true; end -- If we're done, set done to true
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

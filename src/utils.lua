local _, TitanPanelReputation = ...

--[[ ------------------------------ TitanPanelReputation.TABLE Filters ------------------------------ ]]

--[[ TitanPanelReputation
NAME: TTitanPanelReputation:FilterTableByName
DESC:
Filters the `TitanPanelReputation.TABLE` by the given faction name.
Returns the earnedValue and topValue for the given faction name.
:DESC
]]
---@param name string The name of the faction to filter by
---@return number|nil earnedValue, number|nil topValue
function TitanPanelReputation:FilterTableByName(name)
    for _, info in pairs(TitanPanelReputation.TABLE) do
        if info.name == name then
            return info.earnedValue, info.topValue
        end
    end
    return nil, nil
end

--[[ ------------------------------------------ Utilities ------------------------------------------- ]]

--[[ TitanPanelReputation
NAME: TitanPanelReputation:TTL
DESC: Calculates the time to next level based on the earnedValue, the topValue, and RPH (Rep/hr).
]]
---@param earnedValue number The earned value of the faction
---@param topValue number The top value of the faction
---@param RPH number The reputation per hour
---@return number, number, number (TTL, hours, minutes)
function TitanPanelReputation:TTL(earnedValue, topValue, RPH)
    local R2G = topValue - earnedValue
    local TTL = R2G / RPH
    return TTL, floor(TTL), floor((TTL * 60) % 60)
end

--[[ TitanPanelReputation
NAME: TitanPanelReputation:GetHumanReadableTime
DESC: Formats the given time into a human readable format (e.g. "< 1min"/"30mins"/"1hr 30min").
]]
---@param time number The time to format
---@return string humantime The formatted time string
function TitanPanelReputation:GetHumanReadableTime(time)
    local humantime
    if (time < 60) then
        humantime = "< 1" .. TitanPanelReputation:GT("LID_MINUTE_SHORT")
    else
        humantime = floor(time / 60)
        if (humantime < 60) then
            humantime = humantime .. TitanPanelReputation:GT("LID_MINUTES_SHORT")
        else
            local hours = floor(humantime / 60)
            local mins = floor((time - (hours * 60 * 60)) / 60)
            humantime = hours .. TitanPanelReputation:GT("LID_HOURS_SHORT") .. " "
                .. mins .. TitanPanelReputation:GT("LID_MINUTES_SHORT")
        end
    end
    return humantime
end

--[[ TitanPanelReputation
NAME: TitanPanelReputation:GetAdjustedIDAndLabel
DESC:
Adjusts the standingID and label based on the given parameters. This is used to handle friendship factions and
bonus rep gain factions without affecting the original standingID and label.
:DESC
]]
---@param factionID (number) The ID of the faction to get info for
---@param standingID (number) The current standingID for the given faction
---@param friendShipReputationInfo (FriendshipReputationInfo|nil) The friendship reputation info for the given faction
---@param topValue (number) The top value for the given faction
---@param hasBonusRepGain (boolean) Whether the given faction has bonus rep gain
---@param returnOnNotShowFriendInfo? (boolean) Whether to return if not showing friendship info (optional, default false)
---@return AdjustedIDAndLabel|nil
function TitanPanelReputation:GetAdjustedIDAndLabel(factionID, standingID, friendShipReputationInfo, topValue,
                                                    hasBonusRepGain, returnOnNotShowFriendInfo)
    returnOnNotShowFriendInfo = returnOnNotShowFriendInfo or false

    local adjustedID = standingID -- use local variable to avoid overwriting the global one

    local factionType = "Faction Standing"

    if friendShipReputationInfo then
        if returnOnNotShowFriendInfo and not TitanGetVar(TitanPanelReputation.ID, "ShowFriendsOnBar") then return end -- if not showing friendsip info, return

        -- If reached max friendship reputation standing, reflect it in the standingID (adjustedID)
        if not friendShipReputationInfo.nextThreshold then adjustedID = 8 end

        factionType = "Friendship Ranking"
    end

    if hasBonusRepGain then adjustedID = 9 end

    local LABEL = getglobal("FACTION_STANDING_LABEL" .. standingID)

    if friendShipReputationInfo then LABEL = friendShipReputationInfo.reaction end

    if hasBonusRepGain and not (friendShipReputationInfo and not friendShipReputationInfo.nextThreshold)
        and not (adjustedID >= 8 and topValue == 0) then
        LABEL = TitanPanelReputation:GT("LID_PARAGON")
    end

    if factionID and C_Reputation.IsMajorFaction(factionID) then
        local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)

        if majorFactionData ~= nil then
            LABEL = tostring(majorFactionData.renownLevel)
        end
        adjustedID = 10
    end

    local adjustedIDAndLabel = ---@type AdjustedIDAndLabel
    {
        adjustedID = adjustedID,
        label = LABEL,
        factionType = factionType
    }
    return adjustedIDAndLabel
end

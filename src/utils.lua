local _, TitanPanelReputation = ...

local WoW10 = select(4, GetBuildInfo()) >= 100000

---
---Filters the `TitanPanelReputation.TABLE` by the given faction name.
---Returns the `earnedValue` and `topValue` for the given faction name.
---
---@param name string The name of the faction to filter by
---@return number|nil earnedValue, number|nil topValue
---@nodiscard
function TitanPanelReputation:FilterTableByName(name)
    for _, info in pairs(TitanPanelReputation.TABLE) do
        if info.name == name then
            return info.earnedValue, info.topValue
        end
    end
    return nil, nil
end

---
---Calculates the time to next level based on the `earnedValue`, the `topValue`, and `RPH` (Rep/hr).
---
---@param earnedValue number The earned value of the faction
---@param topValue number The top value of the faction
---@param RPH number The reputation per hour
---@return number TTL, number hours, number minutes
---@nodiscard
function TitanPanelReputation:TTL(earnedValue, topValue, RPH)
    local R2G = topValue - earnedValue
    local TTL = R2G / RPH
    return TTL, floor(TTL), floor((TTL * 60) % 60)
end

---
---Formats the given time into a human readable format (e.g. "< 1min"/"30mins"/"1hr 30min").
---
---@param time number The time to format
---@return string humantime The formatted time string
---@nodiscard
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

---
---Adjusts the standingID and label based on the given parameters. This is used to handle friendship factions and
---bonus rep gain factions without affecting the original standingID and label.
---
---@param factionID number The ID of the faction to get info for
---@param standingID number The current standingID for the given faction
---@param friendShipReputationInfo FriendshipReputationInfo|nil The friendship reputation info for the given faction
---@param topValue number The top value for the given faction
---@param paragonProgressStarted boolean Whether the paragon progress for the given faction has been started
---@param returnOnNotShowFriendInfo? boolean Whether to return if not showing friendship info (optional, default false)
---@return AdjustedIDAndLabel|nil
---@nodiscard
function TitanPanelReputation:GetAdjustedIDAndLabel(factionID,
                                                    standingID,
                                                    friendShipReputationInfo,
                                                    topValue,
                                                    paragonProgressStarted,
                                                    returnOnNotShowFriendInfo)
    local adjustedID = standingID -- use local variable to avoid overwriting the global one
    local label = getglobal("FACTION_STANDING_LABEL" .. standingID)
    local factionType = "Faction Standing"

    if not WoW10 then
        local adjustedIDAndLabel = ---@type AdjustedIDAndLabel
        {
            adjustedID = adjustedID,
            label = label,
            factionType = factionType
        }
        return adjustedIDAndLabel
    end

    returnOnNotShowFriendInfo = returnOnNotShowFriendInfo or false

    if friendShipReputationInfo then
        if returnOnNotShowFriendInfo and not TitanGetVar(TitanPanelReputation.ID, "ShowFriendsOnBar") then return end -- if not showing friendsip info, return

        -- If reached max friendship reputation standing, reflect it in the standingID (adjustedID)
        if not friendShipReputationInfo.nextThreshold then adjustedID = 8 end

        factionType = "Friendship Ranking"
    end

    if friendShipReputationInfo then label = friendShipReputationInfo.reaction end

    -- Paragon - AdjustedID = 9
    if factionID and C_Reputation.IsFactionParagon(factionID) and paragonProgressStarted == true then
        if topValue == 0 or topValue == 1000 then
            -- If topValue is 0 or 1000, that individual faction is paragon but their paragon
            -- rep is tracked on another faction (e.g. "Azj Kahet" Sentinals)
            label = label .. " - " .. TitanPanelReputation:GT("LID_PARAGON")
        else
            label = TitanPanelReputation:GT("LID_PARAGON")
        end

        adjustedID = 9
    end

    -- Renown -> AdjustedID = 10
    if factionID and C_Reputation.IsMajorFaction(factionID) then
        local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)

        if majorFactionData ~= nil then
            label = tostring(majorFactionData.renownLevel)
        end
        adjustedID = 10
    end

    local adjustedIDAndLabel = ---@type AdjustedIDAndLabel
    {
        adjustedID = adjustedID,
        label = label,
        factionType = factionType
    }
    return adjustedIDAndLabel
end

---
---Trims the given string by removing leading and trailing whitespace.
---
---@param value string The string to trim
---@return string The trimmed string
---@nodiscard
function TitanPanelReputation:TrimString(value)
    if type(value) ~= "string" then
        return ""
    end
    return value:match("^%s*(.-)%s*$") or ""
end

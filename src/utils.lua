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
---Formats a count with its short unit, singular for a count of one (e.g. "1min", "5mins").
---
---@param count number
---@param oneKey string Locale key of the unit for a count of one
---@param manyKey string Locale key of the unit for any other count
---@return string
local function FormatCount(count, oneKey, manyKey)
    return count .. TitanPanelReputation:GT(count == 1 and oneKey or manyKey)
end

local function FormatHours(hours)
    return FormatCount(hours, "LID_ONE_HOUR_SHORT", "LID_HOURS_SHORT")
end

local function FormatMinutes(minutes)
    return FormatCount(minutes, "LID_MINUTE_SHORT", "LID_MINUTES_SHORT")
end

---
---Formats the given time into a human readable format (e.g. "< 1min"/"30mins"/"1hr 30mins").
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
            humantime = FormatMinutes(humantime)
        else
            local hours = floor(humantime / 60)
            local mins = floor((time - (hours * 60 * 60)) / 60)
            humantime = FormatHours(hours) .. " " .. FormatMinutes(mins)
        end
    end
    return humantime
end

---
---Adjusts the standingID and label of the given faction for friendship, paragon and renown
---factions without affecting the original standingID and label.
---
---@param factionDetails FactionDetails The faction to get the standing for
---@param returnOnNotShowFriendInfo? boolean Whether to return nil for friendships while 'ShowFriendsOnBar' is disabled (optional, default false)
---@return AdjustedIDAndLabel|nil
---@nodiscard
function TitanPanelReputation:GetAdjustedIDAndLabel(factionDetails, returnOnNotShowFriendInfo)
    local factionID, standingID, friendShipReputationInfo, topValue, paragonProgressStarted =
        factionDetails.factionID,
        factionDetails.standingID,
        factionDetails.friendShipReputationInfo,
        factionDetails.topValue,
        factionDetails.paragonProgressStarted

    local adjustedID = standingID -- use local variable to avoid overwriting the global one
    local label = _G["FACTION_STANDING_LABEL" .. standingID]
    local factionType = "Faction Standing"

    -- Friendships exist since MoP (Classic included); the info is nil for every other faction
    if friendShipReputationInfo then
        if returnOnNotShowFriendInfo and not TitanGetVar(TitanPanelReputation.ID, "ShowFriendsOnBar") then return end -- if not showing friendship info, return

        -- If reached max friendship reputation standing, reflect it in the standingID (adjustedID)
        if not friendShipReputationInfo.nextThreshold then adjustedID = 8 end

        label = friendShipReputationInfo.reaction
        factionType = "Friendship Ranking"
    end

    if WoW10 and factionID then
        -- Paragon - AdjustedID = 9
        if C_Reputation.IsFactionParagon(factionID) and paragonProgressStarted == true then
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
        if C_Reputation.IsMajorFaction(factionID) then
            local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)

            if majorFactionData ~= nil then
                label = tostring(majorFactionData.renownLevel)
            end
            adjustedID = 10
        end
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
---Returns the bar color for an adjusted standing ID in the color theme chosen in the menu,
---or nil for the "Basic" theme (no coloring).
---
---Resolved on every call: Titan only loads plugin settings at PLAYER_ENTERING_WORLD, so a
---theme picked at ADDON_LOADED would always be the default one.
---
---@param adjustedID number The adjusted standing ID (see `GetAdjustedIDAndLabel`)
---@return { r: number, g: number, b: number }|nil
---@nodiscard
function TitanPanelReputation:GetStandingColor(adjustedID)
    local colorValue = TitanGetVar(TitanPanelReputation.ID, "ColorValue")
    if colorValue == 3 then
        return nil
    end
    local palette = colorValue == 2 and TitanPanelReputation.COLORS_ARMORY or TitanPanelReputation.COLORS_DEFAULT
    return palette[adjustedID]
end

---
---Formats the time needed to reach `topValue` at the given rate (e.g. "2hrs 5mins").
---
---@param earnedValue number The earned value of the faction
---@param topValue number The top value of the faction
---@param RPH number The reputation per hour
---@return string|nil text Nil without a positive rate, when already at the top value, or below a minute
---@nodiscard
function TitanPanelReputation:GetTimeToLevelText(earnedValue, topValue, RPH)
    if RPH <= 0 or earnedValue >= topValue then
        return nil
    end

    local _, hrs, mins = self:TTL(earnedValue, topValue, RPH)
    if hrs > 0 then
        return FormatHours(hrs) .. " " .. FormatMinutes(mins)
    elseif mins > 0 then
        return FormatMinutes(mins)
    end
    return nil
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

---
---Parses a version string into its numeric components.
---
---@param version string The version string to parse
---@return number[] parts The parsed version components
---@nodiscard
function TitanPanelReputation:ParseVersion(version)
    if not version then return {} end
    -- Strip non-numeric/dot characters (e.g. @project-version@)
    version = tostring(version):gsub("[^0-9%.]", "")
    local parts = {}
    for num in string.gmatch(version, "(%d+)") do
        parts[#parts + 1] = tonumber(num)
    end
    return parts
end

---
---Compares two version strings to determine if the current version is lower than the required version.
---
---@param current string The current version string
---@param required string The required version string
---@return boolean True if the current version is lower, false otherwise
---@nodiscard
function TitanPanelReputation:IsVersionLower(current, required)
    local a = self:ParseVersion(current)
    local b = self:ParseVersion(required)
    local n = math.max(#a, #b)
    for i = 1, n do
        local ai = a[i] or 0
        local bi = b[i] or 0
        if ai < bi then return true end
        if ai > bi then return false end
    end
    return false
end

--[[ TitanPanelReputationUtils
NAME: TitanPanelReputationUtils_CalculateTimeToNextLevel
DESC: Calculates the time to next level based on the current rep, the rep needed to level, and the rep gain rate.
VAR: currentRep - The current reputation
VAR: nextLevelRep - The reputation needed to level
VAR: repGainRate - The rate at which reputation is gained (rep per hour)
OUT: timeToNextLevel - The time to next level in hours
--]]
function TitanPanelReputationUtils_CalculateTimeToNextLevel(currentRep, nextLevelRep, repGainRate)
    local repNeeded = nextLevelRep - currentRep
    local timeToNextLevel = repNeeded / repGainRate
    return timeToNextLevel
end

--[[ TitanPanelReputationUtils
NAME: TitanPanelReputationUtils_GetHumanReadableTime
DESC: Formats the given time into a human readable format
VAR: time - The time to format
OUT: humantime - The time the player has been online human readable format (1hr 30min)
--]]
function TitanPanelReputationUtils_GetHumanReadableTime(time)
    local humantime

    if (time < 60) then
        humantime = "< 1min"
    else
        humantime = floor(time / 60)
        if (humantime < 60) then
            humantime = humantime .. "min"
        else
            local hours = floor(humantime / 60)
            local mins = floor((time - (hours * 60 * 60)) / 60)
            humantime = hours .. "hr " .. mins .. "min"
        end
    end

    return humantime
end

--[[ TitanPanelReputationUtils
NAME: TitanPanelReputationUtils_AddTooltipText
DESC: Adds the given text to the tooltip
VAR: text - The text to add to the tooltip
OUT: None
--]]
function TitanPanelReputationUtils_AddTooltipText(text)
    if (text) then
        -- Append a "\n" to the end
        if (string.sub(text, -1, -1) ~= "\n") then
            --		text = text.."\n"
        end

        -- See if the string is intended for a double column
        for text1, text2 in string.gmatch(text, "([^\t\n]*)\t?([^\t\n]*)\n") do
            if (text2 ~= "") then
                -- Add as double wide
                GameTooltip:AddDoubleLine(text1, text2)
            elseif (text1 ~= "") then
                -- Add single column line
                GameTooltip:AddLine(text1)
            else
                if not TitanGetVar(TITANREP_ID, "MinimalTip") then
                    -- Assume a blank line
                    GameTooltip:AddLine("\n")
                end
            end
        end
    end
end

--[[ TitanPanelReputationUtils
NAME: TitanPanelReputationUtils_GetFactionInfoByName
DESC: Gets the faction info for the given faction name
VAR: factionName - The name of the faction to get info for
OUT: name, description, standingID, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar,
    isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus
--]]
function TitanPanelReputationUtils_GetFactionInfoByName(factionName)
    local factionIndex = 1
    while factionIndex <= GetNumFactions() do
        local name, description, standingID, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar,
        isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus =
            GetFactionInfo(factionIndex)

        if name == factionName then
            return name, description, standingID, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar,
                isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus
        end
        factionIndex = factionIndex + 1
    end
end

local _, TitanPanelReputation = ...

---
---Wraps `text` in the given bar color, or returns it unchanged when no color theme
---is active (ColorValue "Basic").
---
---@param text string
---@param color { r: number, g: number, b: number }|nil
---@return string
local function ColorText(text, color)
    if color then
        return TitanUtils_GetColoredText(text, color)
    end
    return text
end

---
---Builds the text to display on the TitanPanelReputation button.
---
---@param factionDetails FactionDetails
function TitanPanelReputation.BuildButtonText(factionDetails)
    -- Destructure props from FactionDetails
    local name, standingID, topValue, earnedValue, percent, friendShipReputationInfo, factionID, paragonProgressStarted =
        factionDetails.name,
        factionDetails.standingID,
        factionDetails.topValue,
        factionDetails.earnedValue,
        factionDetails.percent,
        factionDetails.friendShipReputationInfo,
        factionDetails.factionID,
        factionDetails.paragonProgressStarted

    -- Return if the faction is not currently being watched (displayed on the Titan Panel button)
    if TitanGetVar(TitanPanelReputation.ID, "WatchedFaction") ~= name then
        return
    end

    -- Get adjusted ID and label depending on the faction type
    local adjustedIDAndLabel = TitanPanelReputation:GetAdjustedIDAndLabel(
        factionID, standingID, friendShipReputationInfo, topValue, paragonProgressStarted, true)

    -- Return if adjustedIDAndLabel is nil (is friendship && 'ShowFriendsOnBar' is disabled)
    if not adjustedIDAndLabel then return end
    -- Destructure props from AdjustedIDAndLabel
    local adjustedID, LABEL = adjustedIDAndLabel.adjustedID, adjustedIDAndLabel.label

    if (TitanGetVar(TitanPanelReputation.ID, "ShortStanding")) then LABEL = string.utf8sub(LABEL, 1, adjustedID == 10 and 2 or 1) end

    local COLOR = TitanPanelReputation.BARCOLORS and TitanPanelReputation.BARCOLORS[adjustedID] or nil
    local text = ""

    if (TitanGetVar(TitanPanelReputation.ID, "ShowFactionName")) then
        text = text .. ColorText(name, COLOR)
        if (TitanGetVar(TitanPanelReputation.ID, "ShowStanding") or
                TitanGetVar(TitanPanelReputation.ID, "ShowValue") or
                TitanGetVar(TitanPanelReputation.ID, "ShowPercent")) then
            text = text .. " - "
        end
    end

    if (TitanGetVar(TitanPanelReputation.ID, "ShowStanding")) then
        text = text .. ColorText(LABEL, COLOR) .. " "
    end

    -- Value/percent are meaningless for maxed friendships and maxed standings without progress
    local hideProgress = (friendShipReputationInfo and not friendShipReputationInfo.nextThreshold)
        or (adjustedID >= 8 and topValue == 0)

    if (TitanGetVar(TitanPanelReputation.ID, "ShowValue") and not hideProgress) then
        text = text .. "[" .. ColorText(earnedValue .. "/" .. topValue, COLOR) .. "] "
    end

    if (TitanGetVar(TitanPanelReputation.ID, "ShowPercent") and not hideProgress) then
        text = text .. ColorText(percent .. "%", COLOR)
    end

    if (TitanGetVar(TitanPanelReputation.ID, "ShowSessionSummaryDuration") or TitanGetVar(TitanPanelReputation.ID, "ShowSessionSummaryTTL")) then
        if (next(TitanPanelReputation.RTS) ~= nil) then -- If there are any values in the RTS table
            local sessionTime = GetTime() - TitanPanelReputation.SESSION_TIME_START

            if (TitanGetVar(TitanPanelReputation.ID, "ShowSessionSummaryDuration")) then
                local humantime = TitanPanelReputation:GetHumanReadableTime(sessionTime)
                local durationLabel = TitanPanelReputation:GT("LID_SESSION_SUMMARY_DURATION") .. ": "

                -- Colored themes tint only the label; the value keeps the normal text color
                if (COLOR) then
                    text = text .. " - " .. TitanUtils_GetColoredText(durationLabel, COLOR) .. TitanUtils_GetNormalText(humantime)
                else
                    text = text .. " - " .. TitanUtils_GetNormalText(durationLabel .. humantime)
                end
            end

            local earnedAmount = TitanPanelReputation.RTS[name]

            if earnedAmount then
                local RPH = floor(earnedAmount / (sessionTime / 60 / 60))
                local RPM = floor(earnedAmount / (sessionTime / 60))

                if (TitanGetVar(TitanPanelReputation.ID, "ShowSessionSummaryDuration")) then
                    local rateText = RPH > 0 and TitanUtils_GetGreenText or TitanUtils_GetRedText
                    local RPH_STRING = rateText(RPH) ..
                        ColorText("/" .. TitanPanelReputation:GT("LID_HOUR_SHORT"), COLOR) ..
                        " " .. rateText(RPM) ..
                        ColorText("/" .. TitanPanelReputation:GT("LID_MINUTE_SHORT"), COLOR)

                    text = text .. ColorText(" @ ", COLOR) .. RPH_STRING
                end

                -- Append time to next level (TTL) info; needs a positive rate to be computable
                if (TitanGetVar(TitanPanelReputation.ID, "ShowSessionSummaryTTL") and RPH > 0) then
                    local _, hrs, mins = TitanPanelReputation:TTL(earnedValue, topValue, RPH)

                    local TTL_STRING = ""
                    if (hrs > 0) then
                        TTL_STRING = ColorText("TTL: ", COLOR) ..
                            hrs .. TitanPanelReputation:GT("LID_HOURS_SHORT") .. " " ..
                            mins .. TitanPanelReputation:GT("LID_MINUTES_SHORT")
                    elseif (mins > 0) then -- only render minutes if there are any
                        TTL_STRING = ColorText("TTL: ", COLOR) ..
                            mins .. TitanPanelReputation:GT("LID_MINUTES_SHORT")
                    end

                    if TTL_STRING ~= "" then
                        text = text .. " - " .. TTL_STRING
                    end
                end
            end
        end
    end

    if (not (TitanGetVar(TitanPanelReputation.ID, "ShowFactionName") or
            TitanGetVar(TitanPanelReputation.ID, "ShowStanding") or
            TitanGetVar(TitanPanelReputation.ID, "ShowValue") or
            TitanGetVar(TitanPanelReputation.ID, "ShowPercent") or
            TitanGetVar(TitanPanelReputation.ID, "ShowSessionSummaryDuration") or
            TitanGetVar(TitanPanelReputation.ID, "ShowSessionSummaryTTL"))) then
        text = text .. TitanPanelReputation:GT("LID_ALL_HIDDEN_LABEL")
    end

    TitanPanelReputation.BUTTON_TEXT = text
end

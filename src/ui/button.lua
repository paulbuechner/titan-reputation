local _, TitanPanelReputation = ...

--[[ TitanPanelReputation
NAME: TitanPanelReputation.BuildButtonText
DESC: Builds the text to display on the TitanPanelReputation button.
]]
---@param factionDetails FactionDetails
function TitanPanelReputation.BuildButtonText(factionDetails)
    -- Destructure props from FactionDetails
    local name, standingID, topValue, earnedValue, percent, isHeader, hasRep, friendShipReputationInfo, factionID, hasBonusRepGain =
        factionDetails.name,
        factionDetails.standingID,
        factionDetails.topValue,
        factionDetails.earnedValue,
        factionDetails.percent,
        factionDetails.isHeader,
        factionDetails.hasRep,
        factionDetails.friendShipReputationInfo,
        factionDetails.factionID,
        factionDetails.hasBonusRepGain

    -- Return if the faction is not currently being watched (displayed on the Titan Panel button)
    if ((isHeader or not (isHeader and hasRep)) and TitanGetVar(TitanPanelReputation.ID, "WatchedFaction") ~= name) then
        return
    end

    -- Get adjusted ID and label depending on the faction type
    local adjustedIDAndLabel = TitanPanelReputation:GetAdjustedIDAndLabel(factionID, standingID,
        friendShipReputationInfo, topValue, hasBonusRepGain, true)
    -- Return if adjustedIDAndLabel is nil (is friendship && 'ShowFriendsOnBar' is disabled)
    if not adjustedIDAndLabel then return end
    -- Destructure props from AdjustedIDAndLabel
    local adjustedID, LABEL = adjustedIDAndLabel.adjustedID, adjustedIDAndLabel.label

    if (TitanGetVar(TitanPanelReputation.ID, "ShortStanding")) then LABEL = strsub(LABEL, 1, adjustedID == 10 and 2 or 1) end

    TitanPanelReputation.BUTTON_TEXT = ""
    local COLOR = nil
    if (TitanPanelReputation.BARCOLORS) then
        COLOR = TitanPanelReputation.BARCOLORS[(adjustedID)]
    end

    if (TitanGetVar(TitanPanelReputation.ID, "ShowFactionName")) then
        if (COLOR) then
            TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation.BUTTON_TEXT ..
                TitanUtils_GetColoredText(name, COLOR)
        else
            TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation.BUTTON_TEXT .. name
        end
        if (TitanGetVar(TitanPanelReputation.ID, "ShowStanding") or
                TitanGetVar(TitanPanelReputation.ID, "ShowStanding") or
                TitanGetVar(TitanPanelReputation.ID, "ShowValue") or
                TitanGetVar(TitanPanelReputation.ID, "ShowPercent")) then
            TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation.BUTTON_TEXT .. " - "
        end
    end

    if (TitanGetVar(TitanPanelReputation.ID, "ShowStanding")) then
        if (COLOR) then
            TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation.BUTTON_TEXT ..
                TitanUtils_GetColoredText(LABEL, COLOR) .. " "
        else
            TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation.BUTTON_TEXT .. LABEL .. " "
        end
    end

    if (TitanGetVar(TitanPanelReputation.ID, "ShowValue")
            and not (friendShipReputationInfo and not friendShipReputationInfo.nextThreshold)
            and not (adjustedID >= 8 and topValue == 0)) then
        if (COLOR) then
            TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation.BUTTON_TEXT ..
                "[" .. TitanUtils_GetColoredText(earnedValue .. "/" .. topValue, COLOR) .. "] "
        else
            TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation.BUTTON_TEXT ..
                "[" .. earnedValue .. "/" .. topValue .. "] "
        end
    end

    if (TitanGetVar(TitanPanelReputation.ID, "ShowPercent")
            and not (friendShipReputationInfo and not friendShipReputationInfo.nextThreshold)
            and not (adjustedID >= 8 and topValue == 0)) then
        if (COLOR) then
            TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation.BUTTON_TEXT ..
                TitanUtils_GetColoredText(percent .. "%", COLOR)
        else
            TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation.BUTTON_TEXT .. percent .. "%"
        end
    end

    if (TitanGetVar(TitanPanelReputation.ID, "ShowSessionSummaryDuration") or TitanGetVar(TitanPanelReputation.ID, "ShowSessionSummaryTTL")) then
        if (next(TitanPanelReputation.RTS) ~= nil) then -- If there are any values in the RTS table
            local sessionTime = GetTime() - TitanPanelReputation.SESSION_TIME_START

            if (TitanGetVar(TitanPanelReputation.ID, "ShowSessionSummaryDuration")) then
                local humantime = TitanPanelReputation:GetHumanReadableTime(sessionTime)

                if (COLOR) then
                    TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation.BUTTON_TEXT .. " - " ..
                        TitanUtils_GetColoredText(
                            TitanPanelReputation:GT("LID_SESSION_SUMMARY_DURATION") .. ": ", COLOR) ..
                        TitanUtils_GetNormalText(humantime)
                else
                    TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation.BUTTON_TEXT .. " - " ..
                        TitanUtils_GetNormalText(
                            TitanPanelReputation:GT("LID_SESSION_SUMMARY_DURATION") ..
                            ": " .. humantime)
                end
            end

            local earnedAmount = TitanPanelReputation.RTS[name]

            if earnedAmount then
                local RPH_STRING = ""
                local RPH = floor(earnedAmount / (sessionTime / 60 / 60))
                local RPM = floor(earnedAmount / (sessionTime / 60))

                if (TitanGetVar(TitanPanelReputation.ID, "ShowSessionSummaryDuration")) then
                    if (RPH > 0) then
                        if (COLOR) then
                            RPH_STRING = TitanUtils_GetGreenText(RPH) ..
                                TitanUtils_GetColoredText(
                                    "/" .. TitanPanelReputation:GT("LID_HOUR_SHORT"),
                                    COLOR) ..
                                " " .. TitanUtils_GetGreenText(RPM) ..
                                TitanUtils_GetColoredText(
                                    "/" .. TitanPanelReputation:GT("LID_MINUTE_SHORT"),
                                    COLOR)
                        else
                            RPH_STRING = TitanUtils_GetGreenText(RPH) .. "/" ..
                                TitanPanelReputation:GT("LID_HOUR_SHORT") ..
                                " " .. TitanUtils_GetGreenText(RPM) .. "/" ..
                                TitanPanelReputation:GT("LID_MINUTE_SHORT")
                        end
                    else
                        if (COLOR) then
                            RPH_STRING = TitanUtils_GetRedText(RPH) ..
                                TitanUtils_GetColoredText(
                                    "/" .. TitanPanelReputation:GT("LID_HOUR_SHORT"),
                                    COLOR) ..
                                " " .. TitanUtils_GetRedText(RPM) ..
                                TitanUtils_GetColoredText(
                                    "/" .. TitanPanelReputation:GT("LID_MINUTE_SHORT"),
                                    COLOR)
                        else
                            RPH_STRING = TitanUtils_GetRedText(RPH) .. "/" ..
                                TitanPanelReputation:GT("LID_HOUR_SHORT") ..
                                " " .. TitanUtils_GetRedText(RPM) .. "/" ..
                                TitanPanelReputation:GT("LID_MINUTE_SHORT")
                        end
                    end

                    if (COLOR) then
                        TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation.BUTTON_TEXT ..
                            TitanUtils_GetColoredText(" @ ", COLOR) .. RPH_STRING
                    else
                        TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation.BUTTON_TEXT .. " @ " .. RPH_STRING
                    end
                end

                -- Append time to next level (TTL) info
                if (TitanGetVar(TitanPanelReputation.ID, "ShowSessionSummaryTTL")) then
                    local _, hrs, mins = TitanPanelReputation:TTL(earnedValue, topValue, RPH)

                    local TTL_STRING = ""
                    if (hrs > 0) then
                        if (COLOR) then
                            TTL_STRING = TitanUtils_GetColoredText("TTL: ", COLOR) ..
                                hrs .. TitanPanelReputation:GT("LID_HOURS_SHORT") .. " " ..
                                mins .. TitanPanelReputation:GT("LID_MINUTES_SHORT")
                        else
                            TTL_STRING = "TTL: " ..
                                hrs .. TitanPanelReputation:GT("LID_HOURS_SHORT") .. " " ..
                                mins .. TitanPanelReputation:GT("LID_MINUTES_SHORT")
                        end
                    elseif (mins > 0) then -- only render minutes if there are any
                        if (COLOR) then
                            TTL_STRING = TitanUtils_GetColoredText("TTL: ", COLOR) ..
                                mins .. TitanPanelReputation:GT("LID_MINUTES_SHORT")
                        else
                            TTL_STRING = "TTL: " ..
                                mins .. TitanPanelReputation:GT("LID_MINUTES_SHORT")
                        end
                    end

                    TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation.BUTTON_TEXT .. " - " .. TTL_STRING
                end
            end

            TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation.BUTTON_TEXT
        end
    end

    if (not (TitanGetVar(TitanPanelReputation.ID, "ShowFactionName") or
            TitanGetVar(TitanPanelReputation.ID, "ShowStanding") or
            TitanGetVar(TitanPanelReputation.ID, "ShowValue") or
            TitanGetVar(TitanPanelReputation.ID, "ShowPercent") or
            TitanGetVar(TitanPanelReputation.ID, "ShowSummary"))) then
        TitanPanelReputation.BUTTON_TEXT = TitanPanelReputation.BUTTON_TEXT ..
            TitanPanelReputation:GT("LID_ALL_HIDDEN_LABEL")
    end
end

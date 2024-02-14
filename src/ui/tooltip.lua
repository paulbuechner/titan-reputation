local _, TitanPanelReputation = ...

--[[ TitanPanelReputation
NAME: BuildFactionTooltipInfo
DESC:
Builds the tooltip faction details from the given `FactionDetails` and adds it to the
tooltip text (`TitanPanelReputation.TOOLTIP_TEXT`).
]]
---@param factionDetails FactionDetails
local function BuildFactionTooltipInfo(factionDetails)
    -- Destructure props from FactionDetails
    local name, parentName, standingID, topValue, earnedValue, percent, isHeader, isInactive, hasRep, friendShipReputationInfo, factionID, hasBonusRepGain =
        factionDetails.name,
        factionDetails.parentName,
        factionDetails.standingID,
        factionDetails.topValue,
        factionDetails.earnedValue,
        factionDetails.percent,
        factionDetails.isHeader,
        factionDetails.isInactive,
        factionDetails.hasRep,
        factionDetails.friendShipReputationInfo,
        factionDetails.factionID,
        factionDetails.hasBonusRepGain

    -- Get adjusted ID and label depending on the faction type
    local adjustedIDAndLabel = TitanPanelReputation:GetAdjustedIDAndLabel(factionID, standingID,
        friendShipReputationInfo, topValue, hasBonusRepGain)
    -- Destructure props from AdjustedIDAndLabel
    local adjustedID, LABEL = adjustedIDAndLabel.adjustedID, adjustedIDAndLabel.label

    -- Count total exalted and best friends
    if friendShipReputationInfo and not friendShipReputationInfo.nextThreshold then
        TitanPanelReputation.TOTAL_BESTFRIENDS = TitanPanelReputation.TOTAL_BESTFRIENDS + 1
    elseif standingID == 8 then
        TitanPanelReputation.TOTAL_EXALTED = TitanPanelReputation.TOTAL_EXALTED + 1
    end

    -- Check if the faction is a header and if it should be shown. If not, return
    local factionHeaders = TitanGetVar(TitanPanelReputation.ID, "FactionHeaders")
    if factionHeaders and tContains(factionHeaders, parentName) then
        return
    end

    -- Init function local variables
    local preface = TitanUtils_GetHighlightText(" - ")
    local postface = ""
    local showrep = isInactive and 0 or 1


    if (isHeader) then
        TitanPanelReputation.LAST_HEADER = { name, 0 }
        showrep = hasRep and 1 or 0 -- Show header if it has rep
    end

    if (showrep == 1) then
        showrep = 0

        if friendShipReputationInfo then
            if TitanGetVar(TitanPanelReputation.ID, "ShowFriendships") then
                showrep = 1
            end
        else
            if (standingID == 8 and TitanGetVar(TitanPanelReputation.ID, "ShowExalted")) then showrep = 1 end
            if (standingID == 8 and hasBonusRepGain) then showrep = 1 end
            if (standingID == 7 and TitanGetVar(TitanPanelReputation.ID, "ShowRevered")) then showrep = 1 end
            if (standingID == 6 and TitanGetVar(TitanPanelReputation.ID, "ShowHonored")) then showrep = 1 end
            if (standingID == 5 and TitanGetVar(TitanPanelReputation.ID, "ShowFriendly")) then showrep = 1 end
            if (standingID == 4 and TitanGetVar(TitanPanelReputation.ID, "ShowNeutral")) then showrep = 1 end
            if (standingID == 3 and TitanGetVar(TitanPanelReputation.ID, "ShowUnfriendly")) then showrep = 1 end
            if (standingID == 2 and TitanGetVar(TitanPanelReputation.ID, "ShowHostile")) then showrep = 1 end
            if (standingID == 1 and TitanGetVar(TitanPanelReputation.ID, "ShowHated")) then showrep = 1 end
        end


        if (showrep == 1) then
            if TitanGetVar(TitanPanelReputation.ID, "ShortTipStanding") then
                LABEL = LABEL and strsub(LABEL, 1, adjustedID == 10 and 2 or 1) or ""
            end

            if (TitanPanelReputation.LAST_HEADER[2] == 0) then
                --if(TitanPanelReputation.LAST_HEADER[1] == TitanPanelReputation_GUILDLOCAL) then
                if (factionID == TitanPanelReputation.G_FACTION_ID) then
                    TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT ..
                        "\n" .. TitanUtils_GetHighlightText(TitanPanelReputation.LAST_HEADER[1])
                else
                    TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT ..
                        "\n" .. TitanUtils_GetHighlightText(TitanPanelReputation.LAST_HEADER[1]) .. "\n"
                end
                TitanPanelReputation.LAST_HEADER[2] = 1
            end

            if (TitanPanelReputation.BARCOLORS) then
                TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT .. preface
                if ((standingID == 8 and not hasBonusRepGain) or topValue == 1000 or topValue == 0) then
                    TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT ..
                        TitanUtils_GetColoredText(name, TitanPanelReputation.BARCOLORS[8]) .. postface .. "\t"
                    TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT ..
                        TitanUtils_GetColoredText(LABEL, TitanPanelReputation.BARCOLORS[8])
                else
                    TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT ..
                        TitanUtils_GetColoredText(name, TitanPanelReputation.BARCOLORS[(adjustedID)]) .. postface .. "\t"
                    if (TitanGetVar(TitanPanelReputation.ID, "ShowTipReputationValue")) then
                        TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT ..
                            TitanUtils_GetColoredText("[" .. earnedValue .. "/" .. topValue .. "]",
                                TitanPanelReputation.BARCOLORS[(adjustedID)]) .. " "
                    end
                    if (TitanGetVar(TitanPanelReputation.ID, "ShowTipPercent")) then
                        TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT ..
                            TitanUtils_GetColoredText(percent .. "%", TitanPanelReputation.BARCOLORS[(adjustedID)]) ..
                            " "
                    end
                    if (TitanGetVar(TitanPanelReputation.ID, "ShowTipStanding")) then
                        TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT ..
                            TitanUtils_GetColoredText(LABEL, TitanPanelReputation.BARCOLORS[(adjustedID)])
                    end
                end
            else
                TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT .. preface
                if (standingID == 8) then
                    TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT .. name .. postface .. "\t"
                    TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT .. LABEL
                else
                    TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT .. name .. postface .. "\t"
                    if (TitanGetVar(TitanPanelReputation.ID, "ShowTipReputationValue")) then
                        TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT ..
                            "[" .. earnedValue .. "/" .. topValue .. "] "
                    end
                    if (TitanGetVar(TitanPanelReputation.ID, "ShowTipPercent")) then
                        TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT .. percent .. "% "
                    end
                    if (TitanGetVar(TitanPanelReputation.ID, "ShowTipStanding")) then
                        if LABEL then
                            TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT ..
                                strsub(LABEL, 1, adjustedID == 10 and 2 or 1)
                        else
                            TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT .. ""
                        end
                    end
                end
            end
            TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT .. "\n"
        end
    end
end

--[[ TitanPanelReputation
NAME: TitanPanelReputation.BuildTooltipText
DESC: Builds the tooltip text for the TitanPanelReputation AddOn.
]]
---@return string TitanPanelReputation.TOOLTIP_TEXT  The tooltip text
function TitanPanelReputation:BuildTooltipText()
    TitanPanelReputation.TOOLTIP_TEXT = ""
    TitanPanelReputation.TOTAL_EXALTED = 0
    TitanPanelReputation.TOTAL_BESTFRIENDS = 0
    TitanPanelReputation.LAST_HEADER = { "HEADER", 1 }

    -- Add the faction details to the tooltip text
    TitanPanelReputation:FactionDetailsProvider(BuildFactionTooltipInfo)

    -- Build the session summary
    if (TitanGetVar(TitanPanelReputation.ID, "ShowTipSessionSummaryDuration") or TitanGetVar(TitanPanelReputation.ID, "ShowTipSessionSummaryTTL")) then
        if (next(TitanPanelReputation.RTS) ~= nil) then -- If there are any values in the RTS table
            local sessionTime = GetTime() - TitanPanelReputation.SESSION_TIME_START

            local humantime = TitanPanelReputation:GetHumanReadableTime(sessionTime)

            TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT ..
                "\n" ..
                TitanUtils_GetHighlightText(TitanPanelReputation:GT("LID_SESSION_SUMMARY") .. ":") ..
                "\t" ..
                TitanUtils_GetNormalText(TitanPanelReputation:GT("LID_SESSION_SUMMARY_DURATION") ..
                    ": " .. humantime)

            for f, v in pairs(TitanPanelReputation.RTS) do
                local RPH_STRING = ""
                local RPH = floor(v / (sessionTime / 60 / 60))
                local RPM = floor(v / (sessionTime / 60))

                if (RPH > 0) then
                    RPH_STRING = TitanUtils_GetGoldText(f) .. ": " ..
                        TitanUtils_GetGreenText(RPH) ..
                        "/" .. TitanPanelReputation:GT("LID_HOUR_SHORT") .. " " ..
                        TitanUtils_GetGreenText(RPM) ..
                        "/" .. TitanPanelReputation:GT("LID_MINUTE_SHORT") .. " " ..
                        "\t" .. "Total: " .. TitanUtils_GetGreenText(v)
                else
                    RPH_STRING = TitanUtils_GetGoldText(f) .. ": " ..
                        TitanUtils_GetRedText(RPH) ..
                        "/" .. TitanPanelReputation:GT("LID_HOUR_SHORT") .. " " ..
                        TitanUtils_GetRedText(RPM) ..
                        "/" .. TitanPanelReputation:GT("LID_MINUTE_SHORT") .. " " ..
                        "\t" .. "Total: " .. TitanUtils_GetRedText(v)
                end

                -- Append time to next level (TTL) info
                if (TitanGetVar(TitanPanelReputation.ID, "ShowTipSessionSummaryTTL")) then
                    local earnedValue, topValue = TitanPanelReputation:FilterTableByName(f)
                    --
                    if earnedValue and topValue then
                        local _, hrs, mins = TitanPanelReputation:TTL(earnedValue, topValue, RPH)

                        local TTL_STRING = ""
                        if (hrs > 0) then
                            TTL_STRING = "TTL: " ..
                                hrs .. TitanPanelReputation:GT("LID_HOURS_SHORT") .. " " ..
                                mins .. TitanPanelReputation:GT("LID_MINUTES_SHORT")
                        else
                            TTL_STRING = "TTL: " .. mins .. TitanPanelReputation:GT("LID_MINUTES_SHORT")
                        end

                        RPH_STRING = RPH_STRING .. " - " .. TTL_STRING
                    end
                end

                TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT .. "\n  " .. RPH_STRING
            end

            TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT .. "\n"
        end
    end

    -- Build summary of total exalted and best friends
    if (TitanGetVar(TitanPanelReputation.ID, "ShowTipExaltedTotal")) then
        TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT ..
            "\n" ..
            TitanUtils_GetHighlightText(TitanPanelReputation:GT(
                "LID_SESSION_SUMMARY_TOTAL_EXALTED_FACTIONS") .. ":") ..
            "\t" ..
            TitanUtils_GetGoldText(TitanPanelReputation:GT("LID_SESSION_SUMMARY_FACTIONS") .. ": ") ..
            TitanUtils_GetGreenText(TitanPanelReputation.TOTAL_EXALTED) ..
            TitanUtils_GetGoldText(" " .. TitanPanelReputation:GT("LID_SESSION_SUMMARY_FRIENDS") .. ": ") ..
            TitanUtils_GetGreenText(TitanPanelReputation.TOTAL_BESTFRIENDS) ..
            TitanUtils_GetGoldText(" " .. TitanPanelReputation:GT("LID_SESSION_SUMMARY_TOTAL") .. ": ") ..
            TitanUtils_GetGreenText((TitanPanelReputation.TOTAL_EXALTED + TitanPanelReputation.TOTAL_BESTFRIENDS)) ..
            "\n"
    end

    return TitanPanelReputation.TOOLTIP_TEXT
end

--[[ TitanPanelReputation
NAME: TitanPanelReputation:AddTooltipText
DESC: Adds the given text to the tooltip
]]
---@param text string The text to add to the tooltip
function TitanPanelReputation:AddTooltipText(text)
    if (text) then
        -- See if the string is intended for a double column
        for text1, text2 in string.gmatch(text, "([^\t\n]*)\t?([^\t\n]*)\n") do
            if (text2 ~= "") then
                -- Add as double wide
                GameTooltip:AddDoubleLine(text1, text2)
            elseif (text1 ~= "") then
                -- Add single column line
                GameTooltip:AddLine(text1)
            else
                if not TitanGetVar(TitanPanelReputation.ID, "MinimalTip") then
                    -- Assume a blank line
                    GameTooltip:AddLine("\n")
                end
            end
        end
    end
end

local oldScale; local isTooltipShowing = false
--[[ TitanPanelReputation
NAME: TooltipHook
DESC: Tooltip scaling hooked ownership check
]]
local function TooltipHook()
    if GameTooltip:GetOwner() == TitanPanelReputationButton then
        if not isTooltipShowing then
            isTooltipShowing = true
            oldScale = GameTooltip:GetScale()
            local toolTipScale = TitanGetVar(TitanPanelReputation.ID, "ToolTipScale")
            if toolTipScale ~= nil then
                GameTooltip:SetScale(toolTipScale)
            end
        end
    elseif isTooltipShowing then
        isTooltipShowing = false
        if oldScale then
            GameTooltip:SetScale(oldScale)
            oldScale = nil
        end
    end
end

hooksecurefunc(GameTooltip, "Show", TooltipHook)

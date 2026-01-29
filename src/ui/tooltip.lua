local _, TitanPanelReputation = ...

---
---Ensures the header path is printed.
---
---@param headerPath string[] The header path
local function EnsureHeaderPathPrinted(headerPath)
    TitanPanelReputation.LAST_HEADER_PATH = TitanPanelReputation.LAST_HEADER_PATH or {}

    if not headerPath or #headerPath == 0 then
        wipe(TitanPanelReputation.LAST_HEADER_PATH)
        return
    end

    for level, headerName in ipairs(headerPath) do
        if TitanPanelReputation.LAST_HEADER_PATH[level] ~= headerName then
            local indent = string.rep("  ", level - 1)
            TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT ..
                "\n" .. indent .. TitanUtils_GetHighlightText(headerName) .. "\n"
            TitanPanelReputation.LAST_HEADER_PATH[level] = headerName
            for trim = level + 1, #TitanPanelReputation.LAST_HEADER_PATH do
                TitanPanelReputation.LAST_HEADER_PATH[trim] = nil
            end
        end
    end

    for trim = #headerPath + 1, #TitanPanelReputation.LAST_HEADER_PATH do
        TitanPanelReputation.LAST_HEADER_PATH[trim] = nil
    end
end


---
---Build the tooltip heading (icon + title + version) as a single string.
---
local function BuildTooltipHeading()
    return "|T" .. TitanPanelReputation.ICON .. ":20|t " .. TitanPanelReputation.TITLE .. " |cff00aa00" .. (TitanPanelReputation.VERSION or "") .. "|r\n"
end


---
---Builds the tooltip faction details from the given `FactionDetails` and adds it to the
---tooltip text (`TitanPanelReputation.TOOLTIP_TEXT`).
---
---@param factionDetails FactionDetails
local function BuildTooltipFactionInfo(factionDetails)
    -- Destructure props from FactionDetails
    local name, standingID, topValue, earnedValue, percent, isHeader, isInactive, hasRep, friendShipReputationInfo, factionID, paragonProgressStarted, headerLevel, headerPath =
        factionDetails.name,
        factionDetails.standingID,
        factionDetails.topValue,
        factionDetails.earnedValue,
        factionDetails.percent,
        factionDetails.isHeader,
        factionDetails.isInactive,
        factionDetails.hasRep,
        factionDetails.friendShipReputationInfo,
        factionDetails.factionID,
        factionDetails.paragonProgressStarted,
        factionDetails.headerLevel,
        factionDetails.headerPath

    -- Get adjusted ID and label depending on the faction type
    local adjustedIDAndLabel = TitanPanelReputation:GetAdjustedIDAndLabel(
        factionID, standingID, friendShipReputationInfo, topValue, paragonProgressStarted, false)
    -- Destructure props from AdjustedIDAndLabel
    local adjustedID, LABEL = adjustedIDAndLabel.adjustedID, adjustedIDAndLabel.label

    -- Count total exalted and best friends
    if friendShipReputationInfo and not friendShipReputationInfo.nextThreshold then
        TitanPanelReputation.TOTAL_BESTFRIENDS = TitanPanelReputation.TOTAL_BESTFRIENDS + 1
    elseif standingID == 8 then
        TitanPanelReputation.TOTAL_EXALTED = TitanPanelReputation.TOTAL_EXALTED + 1
    end

    -- Skip nodes hidden by the user's menu selections (handles ancestors automatically)
    if TitanPanelReputation:IsFactionEffectivelyHidden(factionDetails) then
        return
    end

    -- Init function local variables
    local preface = TitanUtils_GetHighlightText(" - ")
    local postface = ""
    local showrep = isInactive and 0 or 1
    local indentDepth = headerLevel or 0
    if not isHeader and indentDepth > 0 then
        indentDepth = indentDepth - 1
    end
    local indentPrefix = indentDepth > 0 and string.rep("  ", indentDepth) or ""


    if (isHeader) then
        showrep = hasRep and 1 or 0 -- Show header if it has rep
    end

    if (showrep == 1) then
        showrep = 0

        if friendShipReputationInfo then
            -- NOTE: Given the many inconsistencies in friendship reputation data, requiring
            -- NOTE: different total amounts of available standings as well as different
            -- NOTE: maxRep values, and amount needed for each level we opt for a simple "SHOW Friendships"
            -- NOTE: toggle, otherwise we would end up in configuration hell.
            if TitanGetVar(TitanPanelReputation.ID, "ShowFriendships") then
                -- Check if we should hide max friendships (Best Friend level)
                if TitanGetVar(TitanPanelReputation.ID, "HideMaxFriendships") and
                    friendShipReputationInfo.nextThreshold == nil then
                    -- This is a max level friendship (Best Friend), hide it
                    showrep = 0
                else
                    showrep = 1
                end
            end

            -- if TitanGetVar(TitanPanelReputation.ID, "ShowFriendships") == false then
            --     showrep = 0
            -- else
            --     -- DevTools_Dump(friendShipReputationInfo)

            --     -- Map friendship level based on standing value and maxRep
            --     local maxRep = friendShipReputationInfo.maxRep or 42000 -- Default fallback
            --     local standing = friendShipReputationInfo.standing or 0
            --     local levelThreshold = maxRep / 6                       -- 6 total levels: Stranger -> Best Friend

            --     -- Calculate the mapped friendship level (1 = Stranger, 6 = Best Friend)
            --     local mappedLevel = math.min(6, math.max(1, math.ceil(standing / levelThreshold)))

            --     -- Map levels to reaction names for settings check
            --     local levelToReaction = {
            --         [1] = "STRANGER",
            --         [2] = "ACQUAINTANCE",
            --         [3] = "BUDDY",
            --         [4] = "FRIEND",
            --         [5] = "GOODFRIEND",
            --         [6] = "BESTFRIEND"
            --     }

            --     local mappedReaction = levelToReaction[mappedLevel]
            --     if mappedReaction and TitanGetVar(TitanPanelReputation.ID, "Show" .. mappedReaction) then
            --         showrep = 1
            --     end
            -- end
        else
            if (standingID == 8 and TitanGetVar(TitanPanelReputation.ID, "ShowExalted")) then showrep = 1 end
            if (standingID == 7 and TitanGetVar(TitanPanelReputation.ID, "ShowRevered")) then showrep = 1 end
            if (standingID == 6 and TitanGetVar(TitanPanelReputation.ID, "ShowHonored")) then showrep = 1 end
            if (standingID == 5 and TitanGetVar(TitanPanelReputation.ID, "ShowFriendly")) then showrep = 1 end
            if (standingID == 4 and TitanGetVar(TitanPanelReputation.ID, "ShowNeutral")) then showrep = 1 end
            if (standingID == 3 and TitanGetVar(TitanPanelReputation.ID, "ShowUnfriendly")) then showrep = 1 end
            if (standingID == 2 and TitanGetVar(TitanPanelReputation.ID, "ShowHostile")) then showrep = 1 end
            if (standingID == 1 and TitanGetVar(TitanPanelReputation.ID, "ShowHated")) then showrep = 1 end
        end


        if (showrep == 1) then
            EnsureHeaderPathPrinted(headerPath)
            if TitanGetVar(TitanPanelReputation.ID, "ShortTipStanding") then
                LABEL = LABEL and strsub(LABEL, 1, adjustedID == 10 and 2 or 1) or ""
            end

            if (TitanPanelReputation.BARCOLORS) then
                TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT .. indentPrefix .. preface
                if (adjustedID == 8 or topValue == 1000 or topValue == 0) then
                    TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT ..
                        TitanUtils_GetColoredText(name, TitanPanelReputation.BARCOLORS[adjustedID]) .. postface .. "\t"
                    TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT ..
                        TitanUtils_GetColoredText(LABEL, TitanPanelReputation.BARCOLORS[adjustedID])
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
                TitanPanelReputation.TOOLTIP_TEXT = TitanPanelReputation.TOOLTIP_TEXT .. indentPrefix .. preface
                if (adjustedID == 8 or topValue == 1000 or topValue == 0) then
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

---
---Builds the tooltip text for the TitanPanelReputation AddOn.
---
---@return string TitanPanelReputation.TOOLTIP_TEXT  The tooltip text
function TitanPanelReputation:BuildTooltipText()
    TitanPanelReputation.TOOLTIP_TEXT = BuildTooltipHeading()
    TitanPanelReputation.TOTAL_EXALTED = 0
    TitanPanelReputation.TOTAL_BESTFRIENDS = 0
    TitanPanelReputation.LAST_HEADER_PATH = {}

    -- Add the faction details to the tooltip text
    TitanPanelReputation:FactionDetailsProvider(BuildTooltipFactionInfo)

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

local oldScale; local isTooltipShowing = false

---
---Tooltip scaling hooked ownership check
---
local function TooltipHook()
    if GameTooltip:GetOwner() == TitanPanelReputationButton then
        -- Cache initial tooltip scale
        if not isTooltipShowing then
            isTooltipShowing = true
            oldScale = GameTooltip:GetScale()
        end
        -- Set the scale
        local toolTipScale = TitanGetVar(TitanPanelReputation.ID, "ToolTipScale")
        if toolTipScale ~= nil then
            GameTooltip:SetScale(toolTipScale)
        end
    elseif isTooltipShowing then -- apply the initial scale for other tooltips
        isTooltipShowing = false
        if oldScale then
            GameTooltip:SetScale(oldScale)
            oldScale = nil
        end
    end
end
--
hooksecurefunc(GameTooltip, "Show", TooltipHook)

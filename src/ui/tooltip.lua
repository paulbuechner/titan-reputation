local _, TitanPanelReputation = ...

---
---Line buffer for building the tooltip text. Concatenating against one ever-growing
---string is O(n^2) in Lua, so segments are collected here and joined once per build.
---
local tooltipParts = {}

local function Append(text)
    tooltipParts[#tooltipParts + 1] = text
end

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
---Maps a standingID to the saved variable toggling its visibility in the tooltip.
---
local STANDING_SHOW_VARS = {
    [1] = "ShowHated",
    [2] = "ShowHostile",
    [3] = "ShowUnfriendly",
    [4] = "ShowNeutral",
    [5] = "ShowFriendly",
    [6] = "ShowHonored",
    [7] = "ShowRevered",
    [8] = "ShowExalted",
}

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
            local prefix = #tooltipParts == 0 and "" or "\n"

            Append(prefix .. indent .. TitanUtils_GetHighlightText(headerName) .. "\n")
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
    if not TitanGetVar(TitanPanelReputation.ID, "MinimalTip") then
        return "|T" .. TitanPanelReputation.ICON .. ":20|t " .. TitanPanelReputation.TITLE .. " |cff00aa00" .. (TitanPanelReputation.VERSION or "") .. "|r\n"
    else
        return ""
    end
end


---
---Builds the tooltip faction details from the given `FactionDetails` and appends it to
---the tooltip line buffer.
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
        elseif STANDING_SHOW_VARS[standingID] and TitanGetVar(TitanPanelReputation.ID, STANDING_SHOW_VARS[standingID]) then
            showrep = 1
        end

        if (showrep == 1) then
            EnsureHeaderPathPrinted(headerPath)
            if TitanGetVar(TitanPanelReputation.ID, "ShortTipStanding") then
                LABEL = LABEL and string.utf8sub(LABEL, 1, adjustedID == 10 and 2 or 1) or ""
            end

            local color = TitanPanelReputation.BARCOLORS and TitanPanelReputation.BARCOLORS[adjustedID] or nil
            local line = indentPrefix .. preface .. ColorText(name, color) .. "\t"
            if (adjustedID == 8 or topValue == 1000 or topValue == 0) then
                line = line .. ColorText(LABEL, color)
            else
                if (TitanGetVar(TitanPanelReputation.ID, "ShowTipReputationValue")) then
                    line = line .. ColorText("[" .. earnedValue .. "/" .. topValue .. "]", color) .. " "
                end
                if (TitanGetVar(TitanPanelReputation.ID, "ShowTipPercent")) then
                    line = line .. ColorText(percent .. "%", color) .. " "
                end
                if (TitanGetVar(TitanPanelReputation.ID, "ShowTipStanding")) then
                    line = line .. ColorText(LABEL, color)
                end
            end
            Append(line .. "\n")
        end
    end
end

---
---Builds the tooltip text for the TitanPanelReputation AddOn.
---
---@return string TitanPanelReputation.TOOLTIP_TEXT  The tooltip text
function TitanPanelReputation:BuildTooltipText()
    wipe(tooltipParts)
    TitanPanelReputation.TOTAL_EXALTED = 0
    TitanPanelReputation.TOTAL_BESTFRIENDS = 0
    TitanPanelReputation.LAST_HEADER_PATH = {}

    local heading = BuildTooltipHeading()
    if heading ~= "" then
        Append(heading)
    end

    -- Add the faction details to the tooltip text
    TitanPanelReputation:FactionDetailsProvider(BuildTooltipFactionInfo)

    -- Build the session summary
    if (TitanGetVar(TitanPanelReputation.ID, "ShowTipSessionSummaryDuration") or TitanGetVar(TitanPanelReputation.ID, "ShowTipSessionSummaryTTL")) then
        if (next(TitanPanelReputation.RTS) ~= nil) then -- If there are any values in the RTS table
            local sessionTime = GetTime() - TitanPanelReputation.SESSION_TIME_START
            local humantime = TitanPanelReputation:GetHumanReadableTime(sessionTime)

            Append("\n" ..
                TitanUtils_GetHighlightText(TitanPanelReputation:GT("LID_SESSION_SUMMARY") .. ":") ..
                "\t" ..
                TitanUtils_GetNormalText(TitanPanelReputation:GT("LID_SESSION_SUMMARY_DURATION") .. ": " .. humantime))

            for f, v in pairs(TitanPanelReputation.RTS) do
                local RPH = floor(v / (sessionTime / 60 / 60))
                local RPM = floor(v / (sessionTime / 60))
                local rateText = RPH > 0 and TitanUtils_GetGreenText or TitanUtils_GetRedText

                local RPH_STRING = TitanUtils_GetGoldText(f) .. ": " ..
                    rateText(RPH) ..
                    "/" .. TitanPanelReputation:GT("LID_HOUR_SHORT") .. " " ..
                    rateText(RPM) ..
                    "/" .. TitanPanelReputation:GT("LID_MINUTE_SHORT") .. " " ..
                    "\t" .. TitanPanelReputation:GT("LID_SESSION_SUMMARY_TOTAL") .. ": " .. rateText(v)

                -- Append time to next level (TTL) info; needs a positive rate to be computable
                if (TitanGetVar(TitanPanelReputation.ID, "ShowTipSessionSummaryTTL") and RPH > 0) then
                    local earnedValue, topValue = TitanPanelReputation:FilterTableByName(f)
                    --
                    if earnedValue and topValue then
                        local _, hrs, mins = TitanPanelReputation:TTL(earnedValue, topValue, RPH)

                        local TTL_STRING
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

                Append("\n  " .. RPH_STRING)
            end

            Append("\n")
        end
    end

    -- Build summary of total exalted and best friends
    if (TitanGetVar(TitanPanelReputation.ID, "ShowTipExaltedTotal")) then
        local prefix = #tooltipParts == 0 and "" or "\n"
        Append(prefix ..
            TitanUtils_GetHighlightText(TitanPanelReputation:GT("LID_SESSION_SUMMARY_TOTAL_EXALTED_FACTIONS") .. ":") .. "\t" ..
            TitanUtils_GetGoldText(TitanPanelReputation:GT("LID_SESSION_SUMMARY_FACTIONS") .. ": ") ..
            TitanUtils_GetGreenText(TitanPanelReputation.TOTAL_EXALTED) ..
            TitanUtils_GetGoldText(" " .. TitanPanelReputation:GT("LID_SESSION_SUMMARY_FRIENDS") .. ": ") ..
            TitanUtils_GetGreenText(TitanPanelReputation.TOTAL_BESTFRIENDS) ..
            TitanUtils_GetGoldText(" " .. TitanPanelReputation:GT("LID_SESSION_SUMMARY_TOTAL") .. ": ") ..
            TitanUtils_GetGreenText((TitanPanelReputation.TOTAL_EXALTED + TitanPanelReputation.TOTAL_BESTFRIENDS)) .. "\n")
    end

    TitanPanelReputation.TOOLTIP_TEXT = table.concat(tooltipParts)
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

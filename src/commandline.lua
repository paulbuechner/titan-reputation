local _, TitanPanelReputation = ...

local USAGE_TEXT = table.concat({
    "Usage:",
    "/titanrep debug 0||1",
    "/titanrep achievement-info||achinfo <achievementID||achievement title>",
}, " ")

function TitanPanelReputation:PrintMessage(message)
    local prefix = "|cffffd200Titan Reputation|r: "
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage(prefix .. (message or ""))
    else
        print("Titan Reputation: " .. (message or ""))
    end
end

function TitanPanelReputation:SetDebugMode(enabled, silent)
    local flag = not not enabled
    if type(TitanRep_Data) ~= "table" then
        TitanRep_Data = {}
    end
    if self.DebugMode == flag then
        TitanRep_Data.DebugMode = flag
        if not silent then
            self:PrintMessage("Debug mode already " .. (flag and "enabled" or "disabled"))
        end
        return
    end

    self.DebugMode = flag
    TitanRep_Data.DebugMode = flag

    if not silent then
        self:PrintMessage("Debug mode " .. (flag and "enabled" or "disabled"))
    end
end

function TitanPanelReputation:IsDebugEnabled()
    return self.DebugMode == true
end

local function NormalizeQuery(text)
    text = TitanPanelReputation:TrimString(text or "")
    -- strip surrounding quotes
    text = text:gsub('^"(.*)"$', "%1")
    text = text:gsub("^'(.*)'$", "%1")
    return TitanPanelReputation:TrimString(text)
end

local function PrintAchievementInfo(achievementID, name, icon)
    local iconText = icon ~= nil and tostring(icon) or "nil"
    TitanPanelReputation:PrintMessage(string.format('Achievement "%s" (ID %s) icon=%s', name or "?", tostring(achievementID or "?"), iconText))
end

local function FindAchievementByTitle(query)
    query = (query or ""):lower()
    if query == "" then
        return nil, nil, nil, "empty"
    end

    local matches = {}
    local categories = _G.GetCategoryList()
    for _, categoryID in ipairs(categories) do
        local num = _G.GetCategoryNumAchievements(categoryID, true) or 0
        for index = 1, num do
            local id, name, _, _, _, _, _, _, _, icon = _G.GetAchievementInfo(categoryID, index)
            if id and name then
                local lowerName = tostring(name):lower()
                if lowerName == query then
                    return id, name, icon, nil
                end
                if string.find(lowerName, query, 1, true) then
                    matches[#matches + 1] = { id = id, name = name, icon = icon }
                    if #matches >= 10 then
                        break
                    end
                end
            end
        end
        if #matches >= 10 then
            break
        end
    end

    if #matches == 1 then
        local m = matches[1]
        return m.id, m.name, m.icon, nil
    end
    if #matches > 1 then
        return nil, nil, nil, matches
    end
    return nil, nil, nil, "notfound"
end

function TitanPanelReputation:HandleAchievementInfoCommand(argument)
    local raw = NormalizeQuery(argument)
    if raw == "" then
        TitanPanelReputation:PrintMessage("Usage: /titanrep achievement-info <achievementID|achievement title>")
        return
    end

    local asNumber = tonumber(raw)
    if asNumber then
        local name, _, _, _, _, _, _, _, _, icon = _G.GetAchievementInfo(asNumber)
        if not name then
            TitanPanelReputation:PrintMessage("No achievement found for ID " .. tostring(asNumber))
            return
        end
        PrintAchievementInfo(asNumber, name, icon)
        return
    end

    local id, name, icon, err = FindAchievementByTitle(raw)
    if type(err) == "table" then
        TitanPanelReputation:PrintMessage('Multiple achievements match "' .. raw .. '". Try a more specific title or use an ID:')
        for _, m in ipairs(err) do
            TitanPanelReputation:PrintMessage(string.format('  - "%s" (ID %d) icon=%s', m.name, m.id, tostring(m.icon)))
        end
        return
    end
    if err == "api" then
        TitanPanelReputation:PrintMessage("Achievement search APIs are not available in this client.")
        return
    end
    if not id then
        TitanPanelReputation:PrintMessage('No achievement found matching "' .. raw .. '".')
        return
    end

    PrintAchievementInfo(id, name, icon)
end

local function PrintUsage()
    TitanPanelReputation:PrintMessage(USAGE_TEXT)
end

function TitanPanelReputation:HandleDebugCommand(argument)
    local trimmed = TitanPanelReputation:TrimString(argument):lower()
    if trimmed == "" then
        PrintUsage()
        return
    end

    if trimmed == "1" or trimmed == "true" or trimmed == "on" then
        self:SetDebugMode(true)
        return
    end

    if trimmed == "0" or trimmed == "false" or trimmed == "off" then
        self:SetDebugMode(false)
        return
    end

    PrintUsage()
end

function TitanPanelReputation:HandleSlashCommand(msg)
    local input = TitanPanelReputation:TrimString(msg)
    if input == "" then
        PrintUsage()
        return
    end

    local command, rest = input:match("^(%S+)%s*(.*)$")
    command = command and command:lower() or ""

    if command == "debug" then
        self:HandleDebugCommand(rest)
        return
    end

    if command == "achievement-info" or command == "achinfo" then
        self:HandleAchievementInfoCommand(rest)
        return
    end

    TitanPanelReputation:PrintMessage("Unknown command. " .. USAGE_TEXT)
end

SLASH_TITANREPUTATION1 = "/titanrep"
SlashCmdList["TITANREPUTATION"] = function(msg)
    TitanPanelReputation:HandleSlashCommand(msg)
end

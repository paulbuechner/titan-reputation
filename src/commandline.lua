local _, TitanPanelReputation = ...

local USAGE_TEXT = "Usage: /titanrep debug 0||1"

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

    TitanPanelReputation:PrintMessage("Unknown command. " .. USAGE_TEXT)
end

SLASH_TITANREPUTATION1 = "/titanrep"
SlashCmdList["TITANREPUTATION"] = function(msg)
    TitanPanelReputation:HandleSlashCommand(msg)
end

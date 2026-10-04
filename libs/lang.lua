local _, TitanPanelReputation = ...

---
---Prints a message to chat through Titan's plugin API. Stays quiet while Titan's
---"Silent Load" option is on, like Titan's own load messages.
---
---@param message string The message to print
function TitanPanelReputation:Log(message)
    if TitanAllGetVar("Silenced") then return end
    TitanPluginDebug("TitanPanelReputation", message)
end

local ltab = {}

function TitanPanelReputation:GetLangTab()
    return ltab
end

local missingTab = {}

function TitanPanelReputation:GT(str)
    local result = TitanPanelReputation:GetLangTab()[str]

    if result ~= nil then
        return result
    elseif not tContains(missingTab, str) then
        tinsert(missingTab, str)
        TitanPanelReputation:Log("Missing translation for: " .. str)

        return str
    end

    return str
end

function TitanPanelReputation:UpdateLanguage()
    TitanPanelReputation:LangenUS()

    if GetLocale() == "deDE" then
        TitanPanelReputation:LangdeDE()
    elseif GetLocale() == "enUS" then
        TitanPanelReputation:LangenUS()
    elseif GetLocale() == "esES" then
        TitanPanelReputation:Log(
            "Spanish locale not supported. You can help translating by visiting: " ..
            "https://github.com/paulbuechner/titan-reputation/blob/main/locale/esEs.lua")
        TitanPanelReputation:LangesES()
    elseif GetLocale() == "frFR" then
        TitanPanelReputation:Log(
            "France locale not supported. You can help translating by visiting: " ..
            "https://github.com/paulbuechner/titan-reputation/blob/main/locale/frFR.lua")
        TitanPanelReputation:LangfrFR()
    elseif GetLocale() == "itIT" then
        TitanPanelReputation:Log(
            "Italian locale not supported. You can help translating by visiting: " ..
            "https://github.com/paulbuechner/titan-reputation/blob/main/locale/itIT.lua")
        TitanPanelReputation:LangitIT()
    elseif GetLocale() == "ptBR" then
        TitanPanelReputation:Log(
            "Brazilian Portuguese locale not supported. You can help translating by visiting: " ..
            "https://github.com/paulbuechner/titan-reputation/blob/main/locale/ptBR.lua")
        TitanPanelReputation:LangptBR()
    elseif GetLocale() == "ruRU" then
        TitanPanelReputation:LangruRU()
    elseif GetLocale() == "zhCN" then
        TitanPanelReputation:Log(
            "Chinese locale not supported. You can help translating by visiting: " ..
            "https://github.com/paulbuechner/titan-reputation/blob/main/locale/zhCN.lua")
        TitanPanelReputation:LangzhCN()
    end
end

TitanPanelReputation:UpdateLanguage()

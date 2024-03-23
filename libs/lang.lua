local _, TitanPanelReputation = ...
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
        TitanDebug("<TitanPanelReputation> Missing translation for: " .. str)

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
        TitanDebug(
            "<TitanPanelReputation> Spanish locale not supported. You can help translating by visiting: " ..
            "https://github.com/paulbuechner/titan-reputation/blob/main/locale/esEs.lua")
        TitanPanelReputation:LangesES()
    elseif GetLocale() == "frFR" then
        TitanDebug(
            "<TitanPanelReputation> France locale not supported. You can help translating by visiting: " ..
            "https://github.com/paulbuechner/titan-reputation/blob/main/locale/frFR.lua")
        TitanPanelReputation:LangfrFR()
    elseif GetLocale() == "itIT" then
        TitanDebug(
            "<TitanPanelReputation> Italian locale not supported. You can help translating by visiting: " ..
            "https://github.com/paulbuechner/titan-reputation/blob/main/locale/itIT.lua")
        TitanPanelReputation:LangitIT()
    elseif GetLocale() == "ptBR" then
        TitanDebug(
            "<TitanPanelReputation> Brazilian Portuguese locale not supported. You can help translating by visiting: " ..
            "https://github.com/paulbuechner/titan-reputation/blob/main/locale/ptBR.lua")
        TitanPanelReputation:LangptBR()
    elseif GetLocale() == "ruRU" then
        TitanDebug(
            "<TitanPanelReputation> Russian locale not supported. You can help translating by visiting: " ..
            "https://github.com/paulbuechner/titan-reputation/blob/main/locale/ruRU.lua")
        TitanPanelReputation:LangruRU()
    elseif GetLocale() == "zhCN" then
        TitanDebug(
            "<TitanPanelReputation> Chinese locale not supported. You can help translating by visiting: " ..
            "https://github.com/paulbuechner/titan-reputation/blob/main/locale/zhCN.lua")
        TitanPanelReputation:LangzhCN()
    end
end

TitanPanelReputation:UpdateLanguage()

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
        TitanPanelReputation:LangesES()
    elseif GetLocale() == "frFR" then
        TitanPanelReputation:LangfrFR()
    elseif GetLocale() == "itIT" then
        TitanPanelReputation:LangitIT()
    elseif GetLocale() == "ptBR" then
        TitanPanelReputation:LangptBR()
    elseif GetLocale() == "ruRU" then
        TitanPanelReputation:LangruRU()
    elseif GetLocale() == "zhCN" then
        TitanPanelReputation:LangzhCN()
    end
end

TitanPanelReputation:UpdateLanguage()

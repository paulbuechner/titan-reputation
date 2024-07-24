local _, TitanPanelReputation = ...

local WoW10 = select(4, GetBuildInfo()) >= 100000
local WoW11 = select(4, GetBuildInfo()) >= 110000

--[[ TitanPanelReputation
NAME: TTitanPanelReputation:BlizzAPI_GetNumFactions
DESC:
Returns the number of lines in the faction display.
:DESC
]]
---[Documentation OLD](https://warcraft.wiki.gg/wiki/API_GetNumFactions)
---[Documentation NEW](https://warcraft.wiki.gg/wiki/API_GetNumFactions)
---@return number numFactions
function TitanPanelReputation:BlizzAPI_GetNumFactions()
    return WoW11 and C_Reputation.GetNumFactions() or GetNumFactions()
end

--[[ TitanPanelReputation
NAME: TTitanPanelReputation:BlizzAPI_IsFactionInactive
DESC:
Returns true if the specified faction is marked inactive.
:DESC
]]
---[Documentation OLD](https://warcraft.wiki.gg/wiki/API_IsFactionInactive)
---[Documentation NEW](https://warcraft.wiki.gg/wiki/API_C_Reputation.IsFactionActive)
---@return boolean isInactive
function TitanPanelReputation:BlizzAPI_IsFactionInactive(index)
    if WoW11 then
        return not C_Reputation.IsFactionActive(index)
    else
        return IsFactionInactive(index)
    end
end

--[[ TitanPanelReputation
NAME: TTitanPanelReputation:BlizzAPI_GetFactionInfo
DESC:
Returns info for a faction.
:DESC
]]
---[Documentation OLD](https://warcraft.wiki.gg/wiki/API_GetFactionInfo)
---[Documentation NEW](https://warcraft.wiki.gg/wiki/API_C_Reputation.GetFactionDataByIndex)
---@param factionIndex number Index from the currently displayed row in the player's reputation pane, including headers but excluding factions that are hidden because their parent header is collapsed.
---@return string|nil name, string|nil description, number|nil standingID, number|nil barMin, number|nil barMax, number|nil barValue, boolean|nil atWarWith, boolean|nil canToggleAtWar, boolean|nil isHeader, boolean|nil isCollapsed, boolean|nil hasRep, boolean|nil isWatched, boolean|nil isChild, number|nil factionID, boolean|nil hasBonusRepGain, boolean|nil canSetInactive, boolean|nil isAccountWide
function TitanPanelReputation:BlizzAPI_GetFactionInfo(factionIndex)
    if WoW11 then
        local factionData = C_Reputation.GetFactionDataByIndex(factionIndex)
        if factionData then
            return factionData.name, factionData.description, factionData.reaction, factionData.currentReactionThreshold,
                factionData.nextReactionThreshold, factionData.currentStanding, factionData.atWarWith,
                factionData.canToggleAtWar, factionData.isHeader, factionData.isCollapsed, factionData.isHeaderWithRep,
                factionData.isWatched, factionData.isChild, factionData.factionID, factionData.hasBonusRepGain,
                factionData.canSetInactive, factionData.isAccountWide
        end
    else
        return GetFactionInfo(factionIndex)
    end
end

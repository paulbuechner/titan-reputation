local _, TitanPanelReputation = ...

local WoW11 = select(4, GetBuildInfo()) >= 110000

---
---Returns the number of lines in the faction display.
---
---[Documentation OLD](https://warcraft.wiki.gg/wiki/API_GetNumFactions)
---[Documentation NEW](https://warcraft.wiki.gg/wiki/API_GetNumFactions)
---@return number numFactions
---@nodiscard
function TitanPanelReputation:BlizzAPI_GetNumFactions()
    return WoW11 and C_Reputation.GetNumFactions() or GetNumFactions()
end

---
---Returns true if the specified faction is marked inactive.
---
---[Documentation OLD](https://warcraft.wiki.gg/wiki/API_IsFactionInactive)
---[Documentation NEW](https://warcraft.wiki.gg/wiki/API_C_Reputation.IsFactionActive)
---@return boolean isInactive
---@nodiscard
function TitanPanelReputation:BlizzAPI_IsFactionInactive(index)
    if WoW11 then
        return not C_Reputation.IsFactionActive(index)
    else
        return IsFactionInactive(index)
    end
end

---
---Unpacks a retail `FactionData` table into the values the classic `GetFactionInfo` returns.
---
---@param factionData FactionData|nil
local function UnpackFactionData(factionData)
    if factionData then
        return
            factionData.name,
            factionData.description,
            factionData.reaction,
            factionData.currentReactionThreshold,
            factionData.nextReactionThreshold,
            factionData.currentStanding,
            factionData.atWarWith,
            factionData.canToggleAtWar,
            factionData.isHeader,
            factionData.isCollapsed,
            factionData.isHeaderWithRep,
            factionData.isWatched,
            factionData.isChild,
            factionData.factionID,
            factionData.hasBonusRepGain,
            factionData.canSetInactive,
            factionData.isAccountWide
    end
end

---
---Returns info for a faction.
---
---[Documentation OLD](https://warcraft.wiki.gg/wiki/API_GetFactionInfo)
---[Documentation NEW](https://warcraft.wiki.gg/wiki/API_C_Reputation.GetFactionDataByIndex)
---@param factionIndex number Index from the currently displayed row in the player's reputation pane, including headers but excluding factions that are hidden because their parent header is collapsed.
---@return string|nil name, string|nil description, number|nil standingID, number|nil barMin, number|nil barMax, number|nil barValue, boolean|nil atWarWith, boolean|nil canToggleAtWar, boolean|nil isHeader, boolean|nil isCollapsed, boolean|nil hasRep, boolean|nil isWatched, boolean|nil isChild, number|nil factionID, boolean|nil hasBonusRepGain, boolean|nil canSetInactive, boolean|nil isAccountWide
---@nodiscard
function TitanPanelReputation:BlizzAPI_GetFactionInfo(factionIndex)
    if WoW11 then
        return UnpackFactionData(C_Reputation.GetFactionDataByIndex(factionIndex))
    else
        return GetFactionInfo(factionIndex)
    end
end

---
---Returns info for a faction by its ID, also while its header is collapsed. Same values as
---`BlizzAPI_GetFactionInfo`.
---
---[Documentation OLD](https://warcraft.wiki.gg/wiki/API_GetFactionInfoByID)
---[Documentation NEW](https://warcraft.wiki.gg/wiki/API_C_Reputation.GetFactionDataByID)
---@param factionID number
---@nodiscard
function TitanPanelReputation:BlizzAPI_GetFactionInfoByID(factionID)
    if WoW11 then
        return UnpackFactionData(C_Reputation.GetFactionDataByID(factionID))
    else
        return GetFactionInfoByID(factionID)
    end
end

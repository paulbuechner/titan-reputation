local _, TitanPanelReputation = ...

--[[ TitanPanelReputation
NAME: TitanPanelReputation.FACTION_MAPPING
DESC:
User-editable overrides keyed by factionID. Each entry can optionally redefine the
display name (`name`), the header/group (`header`), and the hierarchy level (`level`).
Levels follow the Blizzard reputation UI semantics:
    0 = Header at the root level
    1 = Root-level faction (no indentation)
    2+ = Child faction (indented)
You can also force flags (isHeader, isChild, hasRep) if a faction behaves differently
from the default Blizzard data.
:DESC
]]
---@class TitanReputationFactionMapping
---@field name string|nil Display name override
---@field header string|nil Parent header label override
---@field level number|nil Hierarchy level (0 = header, 1 = root faction, 2+ = child)
---@field isHeader boolean|nil Force header flag
---@field isChild boolean|nil Force child flag
---@field hasRep boolean|nil Force reputation flag on headers
---@type table<number, TitanReputationFactionMapping>
TitanPanelReputation.FACTION_MAPPING = TitanPanelReputation.FACTION_MAPPING or {
    [2600] = { -- Die Durchtrennten Fäden
        level = 2,
    },
}

---Returns the override definition for a factionID, if one exists.
---@param factionID number|nil
---@return TitanReputationFactionMapping|nil
function TitanPanelReputation:GetFactionMapping(factionID)
    if not factionID then return nil end
    return self.FACTION_MAPPING and self.FACTION_MAPPING[factionID] or nil
end

local function DeriveLevelFlags(factionDetails, level)
    if not level then return end
    factionDetails.headerLevel = level
    if level <= 0 then
        factionDetails.isHeader = true
        factionDetails.isChild = false
    elseif level == 1 then
        factionDetails.isHeader = false
        factionDetails.isChild = false
    else
        factionDetails.isHeader = false
        factionDetails.isChild = true
    end
end

---Applies mapping overrides (if present) to the faction details payload.
---@param factionDetails FactionDetails
---@return FactionDetails
function TitanPanelReputation:ApplyFactionMapping(factionDetails)
    if not factionDetails or not factionDetails.factionID then return factionDetails end

    -- Always cache the Blizzard-provided hierarchy level for later use
    if not factionDetails.headerLevel then
        factionDetails.headerLevel = factionDetails.isHeader and 0 or (factionDetails.isChild and 2 or 1)
    end

    -- TitanDebug("Faction ID: " .. factionDetails.factionID .. " name: " .. factionDetails.name .. " headerLevel: " .. factionDetails.headerLevel)

    local override = self:GetFactionMapping(factionDetails.factionID)
    if not override then
        return factionDetails
    end

    if override.name then
        factionDetails.name = override.name
    end

    if override.header then
        factionDetails.parentName = override.header
    end

    if override.isHeader ~= nil then
        factionDetails.isHeader = override.isHeader
    end

    if override.isChild ~= nil then
        factionDetails.isChild = override.isChild
    end

    if override.hasRep ~= nil then
        factionDetails.hasRep = override.hasRep
    end

    if override.level ~= nil then
        DeriveLevelFlags(factionDetails, override.level)
    end

    return factionDetails
end

local _, TitanPanelReputation = ...

---
--- User-editable overrides keyed by factionID. Each entry can optionally redefine the
--- display name (`name`), the header/group (`header`), the hierarchy level (`level`),
--- and even provide a custom texture path (`icon`) for use in achievement toasts.
--- Levels follow the Blizzard reputation UI semantics:
---     0 = Header at the root level
---     1 = Root-level faction (no indentation)
---     2+ = Child faction (indented)
--- You can also force flags (isHeader, isChild, hasRep) if a faction behaves differently
--- from the default Blizzard data.
---
--- Buzz Words to lookup icon texture paths: Faction, Zone, Notoriety
---
---@type {[number]: TitanReputationFactionMapping}
TitanPanelReputation.FACTION_MAPPING = TitanPanelReputation.FACTION_MAPPING or {
    -- ****************************
    --        Dragonflight
    -- ****************************
    [2564] = { -- Niffen von Loamm
        icon = "Interface\\ICONS\\UI_MajorFaction_Niffen.tga",
    },
    -- ****************************
    --       The War Within
    -- ****************************
    [2570] = { -- Arathi von Heilsturz
        icon = "Interface\\ICONS\\UI_MajorFaction_Flame.tga",
    },
    [2658] = { -- Der Bund von K'aresh
        icon = "Interface\\ICONS\\UI_MajorFaction_ Karesh.tga",
    },
    [2594] = { -- Der Konvent der Tiefen
        icon = "Interface\\ICONS\\UI_MajorFaction_Candle.tga",
    },
    [2688] = { -- Die Strahlen der Flamme
        icon = "Interface\\ICONS\\UI_MajorFaction_ Nightfall.tga",
    },
    [2590] = { -- Rat von Dornogal
        icon = "Interface\\ICONS\\UI_MajorFaction_Storm.tga",
    },
    [2736] = { -- Vandalen der Manaschmiede
        icon = "Interface\\ICONS\\INV_112_Achievement_Raid_ManaforgeOmega.tga",
    },
    [2640] = { -- Brann Bronzebart
        -- icon = "Interface\\ICONS\\UI_Delves.tga",
        icon = "Interface\\ICONS\\INV_Helm_Armor_BuckledHat_B_01_Brown.tga",
    },
    [2600] = { -- Die Durchtrennten Fäden
        icon = "Interface\\ICONS\\UI_MajorFaction_Web.tga",
    },
    [2605] = { -- Der General
        icon = "Interface\\ICONS\\UI_Notoriety_TheGeneral.tga",
    },
    [2607] = { -- Der Wesir
        icon = "Interface\\ICONS\\UI_Notoriety_TheVizier.tga",
    },
    [2601] = { -- Die Weberin
        icon = "Interface\\ICONS\\UI_Notoriety_TheWeaver.tga",
    },
    [2653] = { -- Die Kartelle von Lorenhall
        icon = "Interface\\ICONS\\UI_MajorFaction_Rocket.tga",
    },
    [2685] = { -- Garbagio Treueclub
        icon = "Interface\\ICONS\\INV_Achievement_Zone_Undermine.tga",
    },
    [2673] = { -- Bilgewasserkartell
        icon = "Interface\\ICONS\\INV_Chicken2_Mechanical.tga",
    },
    [2677] = { -- Dampfdruckkartell
        icon = "Interface\\ICONS\\INV_Chicken2_Mechanical.tga",
    },
    [2675] = { -- Schwarzmeer AG
        icon = "Interface\\ICONS\\INV_Chicken2_Mechanical.tga",
    },
    [2671] = { -- Venture Company
        icon = "Interface\\ICONS\\INV_Chicken2_Mechanical.tga",
    },
    [2669] = { -- Düsternisverschmolzene Lösungen
        icon = "Interface\\ICONS\\INV_Misc_Bomb_06.tga",
    },
}

---
---Clones a path.
---
---@param path string[]
---@return string[]
local function ClonePath(path)
    local copy = {}
    for index = 1, #path do
        copy[index] = path[index]
    end
    return copy
end

---
---Returns the override definition for a factionID, if one exists.
---
---@param factionID number|nil
---@return TitanReputationFactionMapping|nil
function TitanPanelReputation:GetFactionMapping(factionID)
    if not factionID then return nil end
    return self.FACTION_MAPPING and self.FACTION_MAPPING[factionID] or nil
end

---
---Derives the level flags from the level.
---
---@param factionDetails FactionDetails
---@param level number
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

---
---Applies mapping overrides (if present) to the faction details payload.
---
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

    if override.icon then
        factionDetails.icon = override.icon
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

    if override.path then
        factionDetails.headerPath = ClonePath(override.path)
    end

    if override.level ~= nil then
        DeriveLevelFlags(factionDetails, override.level)
    end

    return factionDetails
end

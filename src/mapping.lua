local _, TitanPanelReputation = ...

---
---User-editable overrides keyed by factionID. Each entry can optionally redefine the
---display name (`name`), the header/group (`header`), the hierarchy level (`level`),
---and even provide a custom texture path (`icon`) for use in achievement toasts.
---Levels follow the Blizzard reputation UI semantics:
---  - 0 = Header at the root level
---  - 1 = Root-level faction (no indentation)
---  - 2+ = Child faction (indented)
---You can also force flags (isHeader, isChild, hasRep) if a faction behaves differently
---from the default Blizzard data.
---
---Buzz Words to lookup icon texture paths: Faction, Zone, Notoriety
---
---Developer helper: find an achievement's icon fileID.
---In-game usage:
---  - `/titanrep achievement-info 6`
---  - `/titanrep achievement-info "Loremaster"`
---
---Output prints:
---  - achievement ID
---  - icon (usually a fileID number in Retail)
---
---To translate a fileID to a path (for building `FACTION_MAPPING[*].icon`), use: `resources/ArtTextureID.lua`
---(search for the fileID; it contains fileID → path mappings)
---
---Then add/update a mapping entry to control the icon used in TitanReputation's achievement-style toasts:
---```lua
---  SetIcon("UI_MajorFaction_Flame", { FACTION_ID }) -- icon names are always under "Interface/Icons/"
---```
---
---@type {[number]: TitanReputationFactionMapping}
TitanPanelReputation.FACTION_MAPPING = TitanPanelReputation.FACTION_MAPPING

-- Support assigning multiple IDs to the same icon path to keep this file from getting bloated.
-- We only initialize these defaults if nothing was set yet, preserving the original behavior.
if TitanPanelReputation.FACTION_MAPPING == nil then
    TitanPanelReputation.FACTION_MAPPING = {}

    local MAP = TitanPanelReputation.FACTION_MAPPING

    local ICON_PREFIX = "Interface/Icons/"

    ---Assign the same icon to multiple faction IDs.
    ---Keep inline comments per ID as "faction hints".
    ---Icon names are assumed to be under `Interface/Icons/`.
    ---@param icon string
    ---@param factionIDs number[]
    local function SetIcon(icon, factionIDs)
        local iconPath = icon
        if string.sub(icon, 1, #ICON_PREFIX) ~= ICON_PREFIX then
            iconPath = ICON_PREFIX .. icon
        end
        for _, factionID in ipairs(factionIDs) do
            MAP[factionID] = MAP[factionID] or {}
            MAP[factionID].icon = iconPath
        end
    end

    -- ****************************
    --       The War Within
    -- ****************************
    SetIcon("UI_MajorFaction_Flame", { 2570 })                   -- Arathi von Heilsturz
    SetIcon("UI_MajorFaction_ Karesh", { 2658 })                 -- Der Bund von K'aresh
    SetIcon("UI_MajorFaction_Candle", { 2594 })                  -- Der Konvent der Tiefen
    SetIcon("UI_MajorFaction_ Nightfall", { 2688 })              -- Die Strahlen der Flamme
    SetIcon("UI_MajorFaction_Storm", { 2590 })                   -- Rat von Dornogal
    SetIcon("INV_112_Achievement_Raid_ManaforgeOmega", { 2736 }) -- Vandalen der Manaschmiede
    SetIcon("INV_Helm_Armor_BuckledHat_B_01_Brown", { 2640 })    -- Brann Bronzebart
    SetIcon("UI_MajorFaction_Web", { 2600 })                     -- Die Durchtrennten Fäden
    SetIcon("UI_Notoriety_TheGeneral", { 2605 })                 -- Der General
    SetIcon("UI_Notoriety_TheVizier", { 2607 })                  -- Der Wesir
    SetIcon("UI_Notoriety_TheWeaver", { 2601 })                  -- Die Weberin
    SetIcon("UI_MajorFaction_Rocket", { 2653 })                  -- Die Kartelle von Lorenhall
    SetIcon("INV_Achievement_Zone_Undermine", { 2685 })          -- Garbagio Treueclub
    SetIcon("INV_Misc_Bomb_06", { 2669 })                        -- Düsternisverschmolzene Lösungen
    SetIcon("INV_Chicken2_Mechanical", {
        2673,                                                    -- Bilgewasserkartell
        2677,                                                    -- Dampfdruckkartell
        2675,                                                    -- Schwarzmeer AG
        2671,                                                    -- Venture Company
    })

    -- ****************************
    --        Dragonflight
    -- ****************************
    SetIcon("UI_MajorFaction_Niffen", { 2564 })               -- Niffen von Loamm
    SetIcon("UI_MajorFaction_Denizens", { 2574 })             -- Traumwächter
    SetIcon("UI_MajorFaction_Tuskarr", { 2511 })              -- Tuskarr von Iskaara
    SetIcon("UI_MajorFaction_Centaur", { 2503 })              -- Zentauren der Maruuk
    SetIcon("UI_MajorFaction_Expedition", { 2507 })           -- Drachenschuppenexpedition
    SetIcon("INV_Helm_Armor_BuckledHat_B_01_Brown", { 2615 }) -- Archive von Azeroth
    SetIcon("UI_MajorFaction_Valdrakken", { 2510 })           -- Valdrakkenabkommen
    SetIcon("INV_Artifact_DragonScales", { 2517 })            -- Furorion
    SetIcon("INV_Misc_Statue_04", { 2544 })                   -- Handwerkerkonsortium - Zweig der Dracheninseln
    SetIcon("INV_Artifact_StolenPower", { 2550 })             -- Kobaltkonvent
    SetIcon("INV_10_Skinning_DragonScales_Black", { 2518 })   -- Sabellian
    SetIcon("INV_Shield_TimeWalker_B_01", { 2553 })           -- Soridormi
    SetIcon("INV_SnailrockMount_Pink", { 2568 })              -- Glimmeroggrenner
    SetIcon("INV_10_Misc_WinterpeltFurbolg_Totem", { 2526 })  -- Winterpelzfurbolgs

    -- ****************************
    --        Shadowlands
    -- ****************************
    SetIcon("INV_Inscription_80_Scroll", { 2472 })                           -- Der Archivarskodex
    SetIcon("INV_Tabard_Bastion_D_01", { 2407 })                             -- Die Aufgestiegenen
    SetIcon("Spell_AnimaRevendreth_Buff", { 2439 })                          -- Die Eingeschworenen
    SetIcon("Achievement_Reputation_EnlightenedBrokers", { 2478 })           -- Die Erleuchteten
    SetIcon("INV_Tabard_Maldraxxus_D_01", { 2410 })                          -- Die Unvergängliche Armee
    SetIcon("INV_Tabard_Ardenweald_D_01", { 2465 })                          -- Die Wilde Jagd
    SetIcon("Tradeskill_AbominationStitching_Abominations_Lesser", { 2462 }) -- Flickmeister
    SetIcon("INV_Tabard_Revendreth_D_01", { 2413 })                          -- Hof der Ernter
    SetIcon("Druid_Ability_Wildmushroom_b", { 2463 })                        -- Marasmius
    SetIcon("INV_Ardenweald", { 2464 })                                      -- Hof der Nacht
    SetIcon("INV_Helm_Cloth_OribosDungeon_C_01", { 2432 })                   -- Ve'nari
    SetIcon("INV_Tabard_DeathsAdvance_B_01", { 2470 })                       -- Vorstoß des Todes
    SetIcon("UI_Sigil_Venthyr", {
        2445,                                                                -- Der Gluthof
        2453,                                                                -- Rendel und Knüppelfratze
        2460,                                                                -- Steinkopf
        2449,                                                                -- Die Gräfin
        2455,                                                                -- Grufthüter Kassir
        2452,                                                                -- Polemarch Adrestes
        2447,                                                                -- Lady Mondbeere
        2457,                                                                -- Großmeister Vole
        2454,                                                                -- Choofa
        2446,                                                                -- Baronin Vashj
        2458,                                                                -- Kleia und Pelagos
        2461,                                                                -- Seuchenerfinder Marileth
        2448,                                                                -- Mikanikos
        2451,                                                                -- Jagdhauptmann Korayn
        2459,                                                                -- Sika
        2456,                                                                -- Dromanin Aliothe
        2450,                                                                -- Alexandros Mograine
    })

    -- ****************************
    --      Battle for Azeroth
    -- ****************************
    SetIcon("INV_FACTION_83_ULDUMACCORD", { 2417 })             -- Abkommen von Uldum
    SetIcon("INV_Faction_Championsofazeroth", { 2164 })         -- Champions von Azeroth
    SetIcon("INV_Tabard_HordeWarEffort", { 2157 })              -- Die Eidgebundenen
    SetIcon("INV_Faction_Unshackled", { 2373 })                 -- Die Entfesselten
    SetIcon("INV_FACTION_83_RAJANI", { 2415 })                  -- Rajani
    SetIcon("INV_Mechagon_JunkyardTinkeringCrafting", { 2391 }) -- Rostbolzenwiderstand
    SetIcon("INV_Faction_TalanjisExpedition", { 2156 })         -- Talanjis Expedition
    SetIcon("INV_Faction_TortollanSeekers", { 2163 })           -- Tortollanische Sucher
    SetIcon("INV_Faction_Voldunai", { 2158 })                   -- Voldunai
    SetIcon("INV_Faction_ZandalariEmpire", { 2103 })            -- Zandalariimperium
end

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

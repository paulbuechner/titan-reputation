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
---Wowhead Reputation Achievement Browser: https://www.wowhead.com/de/achievements/character-achievements/reputation#
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

    -- ****************************
    --            Legion
    -- ****************************
    SetIcon("Achievement_Admiral_of_the_Light", { 2165 })       -- Armee des Lichts
    SetIcon("Spell_Shadow_DemonicCircleTeleport", { 1975 })     -- Beschwörer Margoss
    SetIcon("Achievement_Reputation_WyrmrestTemple", { 2135 })  -- Chromie
    SetIcon("INV_Legion_Faction_ArgussianReach", { 2170 })      -- Der Argusvorstoß
    SetIcon("INV_Legion_Faction_HightmountainTribes", { 1828 }) -- Der Hochbergstamm
    SetIcon("INV_Legion_Faction_Legionfall", { 2045 })          -- Die Legionsrichter
    SetIcon("INV_Legion_Faction_NightFallen", { 1859 })         -- Die Nachtsüchtigen
    SetIcon("INV_Legion_Faction_DreamWeavers", { 1883 })        -- Die Traumweber
    SetIcon("INV_Legion_Faction_Warden", { 1894 })              -- Die Wächterinnen
    SetIcon("INV_Legion_Faction_CourtofFarnodis", { 1900 })     -- Farondis' Hofstaat
    SetIcon("Achievement_Profession_Fishing_OldManBarlowned", {
        2097,                                                   -- Ilyssia von den Wassern
        2098,                                                   -- Hüterin Raynae
        2099,                                                   -- Akule Flusshorn
        2100,                                                   -- Corbyn
        2101,                                                   -- Sha'leth
        2102                                                    -- Wichtlus
    })
    SetIcon("INV_Legion_Faction_Valarjar", { 1948 })            -- Valarjar

    -- ****************************
    --     Warlords of Draenor
    -- ****************************
    SetIcon("INV_Tabard_A_76ArakkoaOutcast", { 1515 }) -- Ausgestoßene Arakkoa
    SetIcon("Achievement_Zone_Tanaanjungle", { 1850 }) -- Die Säbelzahnpirscher
    SetIcon("INV_Tabard_A_01FrostwolfClan", { 1445 })  -- Frostwolforcs
    SetIcon("INV_Tabard_A_80LaughingSkull", { 1708 })  -- Orcs des Lachenden Schädels
    SetIcon("Achievement_Zone_Tanaanjungle", { 1849 }) -- Orden der Erwachten
    SetIcon("Achievement_Zone_Tanaanjungle", { 1848 }) -- Vol'jins Kopfjäger
    SetIcon("achievement_Goblinhead", { 1711 })        -- Werterhaltungsgesellschaft des Dampfdruckkartells
    SetIcon("INV_Tabard_A_81Exarchs", { 1731 })        -- Exarchenrat
    SetIcon("Achievement_Zone_Tanaanjungle", { 1847 }) -- Hand des Propheten
    SetIcon("INV_Tabard_A_ShatariDefense", { 1710 })   -- Sha'tarverteidigung
    SetIcon("INV_Feather_01", { 1735 })                -- Kasernenleibwächter
    -- SetIcon("...", { 1520 })                        -- Exilanten des Schattenmondklans (Can't raise standing with this faction)
    SetIcon("INV_Tabard_A_77VoljinsSpear", { 1681 })   -- Vol'jins Speer
    SetIcon("INV_Tabard_A_78WrynnVanguard", { 1682 })  -- Wrynns Vorhut
    -- SetIcon("achievement_Goblinhead", { 1732 })     -- Draenorexpedition des Dampfdruckkartells (Can't raise standing with this faction)

    -- ****************************
    --      Mists of Pandaria
    -- ****************************
    SetIcon("INV_Legendary_TheBlackPrince", { 1359 })           -- Der Schwarze Prinz
    SetIcon("Achievement_Faction_Celestials", { 1341 })         -- Die Himmlischen Erhabenen
    SetIcon("Achievement_Faction_Klaxxi", { 1337 })             -- Die Klaxxi
    SetIcon("Achievement_Faction_LoreWalkers", { 1345 })        -- Die Lehrensucher
    SetIcon("Achievement_Faction_GoldenLotus", { 1269 })        -- Goldener Lotus
    SetIcon("Achievement_General_HordeSlayer", { 1375 })        -- Herrschaftsoffensive
    SetIcon("ability_Monk_QuiPunch", { 1492 })                  -- Kaiser Shaohao
    SetIcon("Achievement_Faction_SerpentRiders", { 1271 })      -- Orden der Wolkenschlange
    SetIcon("Achievement_Faction_ShadoPan", { 1270 })           -- Shado-Pan
    SetIcon("Achievement_Faction_ShadoPan_Assault", { 1435 })   -- Shado-Pan-Vorstoß
    SetIcon("Achievement_KirinTor_Offensive", { 1387 })         -- Kirin Tor Offensive
    SetIcon("Achievement_Faction_SunreaverOnslaught", { 1388 }) -- Sonnenhäscheransturm
    SetIcon("Ability_Hunter_AspectOfTheMonkey", { 1228 })       -- Wald-Ho-zen
    SetIcon("INV_Misc_DeepJinyuCaster", { 1242 })               -- Jinyu der Perlflossen
    SetIcon("Achievement_Faction_Tillers", {
        1272,                                                   -- Die Ackerbauern
        1280,                                                   -- Tina Lehmkrall
        1275,                                                   -- Ella
        1281,                                                   -- Gina Lehmkrall
        1283,                                                   -- Bauer Fung
        1273,                                                   -- Jogu der Betrunkene
        1278,                                                   -- Sho
        1279,                                                   -- Haohan Lehmkrall
        1276,                                                   -- Der alte Hügelpranke
        1277,                                                   -- Chi-Chi
        1282                                                    -- Fischi Rohrroder
    })
    SetIcon("Achievement_Faction_Anglers", { 1302 })            -- Die Angler
    SetIcon("INV_Helmet_50", { 1358 })                          -- Nat Pagle

    -- ****************************
    --          Cataclysm
    -- ****************************
    SetIcon("INV_Misc_Tabard_EarthenRing", { 1135 })      -- Der Irdene Ring
    SetIcon("INV_Misc_Tabard_DragonMawClan", { 1172 })    -- Drachenmalklan
    SetIcon("INV_Neck_HyjalDaily_04", { 1204 })           -- Rächer des Hyjal
    SetIcon("INV_Misc_Tabard_Tolvir", { 1173 })           -- Ramkahen
    SetIcon("INV_Misc_Tabard_Therazane", { 1171 })        -- Therazane
    SetIcon("INV_Misc_Tabard_GuardiansofHyjal", { 1158 }) -- Wächter des Hyjal
    SetIcon("INV_Misc_Tabard_HellScream", { 1178 })       -- Höllschreis Hand
    SetIcon("INV_Misc_Tabard_WildHammerClan", { 1174 })   -- Wildhammerklan
    SetIcon("INV_Misc_Tabard_BaradinWardens", { 1177 })   -- Wächter von Baradin

    -- ****************************
    --    Wrath of the Lich King
    -- ****************************
    SetIcon("INV_Jewelry_Talisman_08", { 1106 })                      -- Argentumkreuzzug
    SetIcon("INV_Jewelry_Talisman_08", { 1156 })                      -- Das Äscherne Verdikt
    SetIcon("Achievement_Reputation_WyrmrestTemple", { 1091 })        -- Der Wyrmruhpakt
    SetIcon("Achievement_Reputation_Tuskarr", { 1073 })               -- Die Kalu'ak
    SetIcon("INV_Tabard_SonsofHodir_B_01", { 1119 })                  -- Die Söhne Hodirs
    SetIcon("Achievement_Reputation_KirinTor", { 1090 })              -- Kirin Tor
    SetIcon("Achievement_Reputation_KnightsoftheEbonBlade", { 1098 }) -- Ritter der Schwarzen Klinge
    SetIcon("Spell_Misc_HellifrePVPThrallmarFavor", { 1052 })         -- Expedition der Horde
    SetIcon("INV_Misc_Tabard_Forsaken", { 1067 })                     -- Die Hand der Rache
    SetIcon("INV_Elemental_Primal_Nether", { 1124 })                  -- Die Sonnenhäscher
    SetIcon("Spell_Misc_HellifrePVPThrallmarFavor", { 1064 })         -- Die Taunka
    SetIcon("Spell_Misc_HellifrePVPThrallmarFavor", { 1085 })         -- Kriegshymnenoffensive
    SetIcon("INV_Misc_Head_Murloc_01", { 1105 })                      -- Die Orakel
    SetIcon("Spell_Nature_MirrorImage", { 1104 })                     -- Stamm der Wildherzen
    SetIcon("INV_Elemental_Primal_Mana", { 1094 })                    -- Der Silberbund
    SetIcon("Spell_Misc_HellifrePVPHonorHoldFavor", { 1050 })         -- Expedition Valianz
    SetIcon("Spell_Misc_HellifrePVPHonorHoldFavor", { 1037 })         -- Vorhut der Allianz
    SetIcon("Spell_Misc_HellifrePVPHonorHoldFavor", { 1126 })         -- Die Frosterben
    SetIcon("Spell_Misc_HellifrePVPHonorHoldFavor", { 1068 })         -- Forscherliga

    -- ****************************
    --     The Burning Crusade
    -- ****************************
    SetIcon("INV_Enchant_ShardPrismaticLarge", { 933 })             -- Das Konsortium
    SetIcon("Spell_Holy_MindSooth", { 967 })                        -- Das Violette Auge
    SetIcon("INV_Misc_Foot_Centaur", { 941 })                       -- Die Mag'har
    SetIcon("Achievement_Reputation_AshtongueDeathsworn", { 1012 }) -- Die Todeshörigen
    SetIcon("INV_Enchant_DustIllusion", { 990 })                    -- Die Wächter der Sande
    SetIcon("Ability_Racial_Ultravision", { 942 })                  -- Expedition des Cenarius
    SetIcon("SPELL_HOLY_BORROWEDTIME", { 989 })                     -- Hüter der Zeit
    SetIcon("Ability_Mount_NetherdrakePurple", { 1015 })            -- Netherschwingen
    SetIcon("INV_Misc_Apexis_Crystal", { 1038 })                    -- Ogri'la
    SetIcon("INV_Mushroom_11", { 970 })                             -- Sporeggar
    SetIcon("Achievement_Zone_HellfirePeninsula_01", { 947 })       -- Thrallmar
    SetIcon("Achievement_Zone_IsleOfQuelDanas", { 922 })            -- Tristessa
    SetIcon("Spell_Arcane_PortalShattrath", { 932 })                -- Die Aldor
    SetIcon("Spell_Arcane_PortalShattrath", { 934 })                -- Die Seher
    SetIcon("Spell_Arcane_PortalShattrath", { 935 })                -- Die Sha'tar
    SetIcon("Ability_Hunter_Pet_NetherRay", { 1031 })               -- Himmelswache der Sha'tari
    SetIcon("INV_Shield_48", { 1077 })                              -- Offensive der Zerschmetterten Sonne
    SetIcon("Achievement_Zone_Terrokar", { 1011 })                  -- Unteres Viertel
    SetIcon("Achievement_Zone_HellfirePeninsula_01", { 946 })       -- Ehrenfeste
    SetIcon("Spell_Holy_MindSooth", { 967 })                        -- Das Violette Auge
    SetIcon("INV_Misc_Foot_Centaur", { 978 })                       -- Kurenai


    SetIcon("Inv_Misc_Tournaments_Symbol_BloodElf", { 911 }) -- Silbermond
    SetIcon("INV_Misc_Tabard_Gilneas", { 1134 })             -- Gilneas
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

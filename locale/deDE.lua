-- deDE German Deutsch
local _, TitanPanelReputation = ...
function TitanPanelReputation:LangdeDE()
    local tab = {
        -- General
        ["LID_INITIALIZED"] = "Initialisiert",
        ["LID_MINUTE_SHORT"] = "min",
        ["LID_MINUTES_SHORT"] = "mins",
        ["LID_HOUR_SHORT"] = "h",
        ["LID_HOURS_SHORT"] = "hrs",

        ["LID_TITAN_TOO_OLD_WARNING_BUTTON"] = "oder neuer erforderlich",
        ["LID_TITAN_TOO_OLD_WARNING_TOOLTIP_START"] = "Bitte aktualisiere Titan Panel auf Version",
        ["LID_TITAN_TOO_OLD_WARNING_TOOLTIP_END"] = "oder neuer, um alle Funktionen freizuschalten.",

        -- Labels
        ["LID_ALL_HIDDEN_LABEL"] = "Ruf: Aus",
        ["LID_NO_FACTION_LABEL"] = "Ruf: Keine Fraktion ausgewählt",
        ["LID_COLLAPSED_UNKNOWN"] = "(eingeklappt: zum Anzeigen aufklappen)",
        ["LID_SHOW_FACTION_NAME_LABEL"] = "Fraktionsname anzeigen",
        ["LID_SHOW_STANDING"] = "Rufstatus anzeigen",
        ["LID_SHOW_VALUE"] = "Rufwert anzeigen",
        ["LID_SHOW_PERCENT"] = "Prozent anzeigen",
        ["LID_AUTO_CHANGE"] = "Fraktion automatisch wechseln",
        ["LID_FRIENDSHIP_RANK_SETTINGS"] = "Freundschaftsrang-Einstellungen",
        ["LID_SHOW_FRIENDSHIPS"] = "Freundschaften anzeigen",
        ["LID_HIDE_MAX_FRIENDSHIPS"] = "Maximale Freundschaften ausblenden",
        ["LID_REPUTATION_STANDING_SETTINGS"] = "Rufstatus-Einstellungen",
        ["LID_SHOW_EXALTED"] = "Ehrfürchtig anzeigen",
        ["LID_SHOW_REVERED"] = "Respektvoll anzeigen",
        ["LID_SHOW_HONORED"] = "Wohlwollend anzeigen",
        ["LID_SHOW_FRIENDLY"] = "Freundlich anzeigen",
        ["LID_SHOW_NEUTRAL"] = "Neutral anzeigen",
        ["LID_SHOW_UNFRIENDLY"] = "Unfreundlich anzeigen",
        ["LID_SHOW_HOSTILE"] = "Feindlich anzeigen",
        ["LID_SHOW_HATED"] = "Hasserfüllt anzeigen",
        ["LID_SHORT_STANDING"] = " - Ruf abkürzen",
        ["LID_ARMORY_COLORS"] = "Arsenal",
        ["LID_DEFAULT_COLORS"] = "Standard",
        ["LID_NO_COLORS"] = "Basis",
        ["LID_SHOW_STATS"] = "Anzahl ehrfürchtiger Fraktionen anzeigen",
        ["LID_SHOW_ICON"] = "Symbol anzeigen",
        ["LID_BUTTON_OPTIONS"] = "Button-Optionen",
        ["LID_TOOLTIP_OPTIONS"] = "Tooltip-Optionen",
        ["LID_COLOR_OPTIONS"] = "Farbauswahl",

        -- Session Summary
        ["LID_SESSION_SUMMARY_SETTINGS"] = "Einstellungen für Sitzungszusammenfassung",
        ["LID_SHOW_SUMMARY_DURATION"] = "Dauer anzeigen",
        ["LID_SHOW_SUMMARY_TTL"] = "Zeit bis Rufaufstieg anzeigen",

        ["LID_TIP_SHOW_SUMMARY_DURATION"] = "Dauer anzeigen",
        ["LID_TIP_SHOW_SUMMARY_TTL"] = "Zeit bis Rufaufstieg anzeigen",

        ["LID_SHOW_ANNOUNCE_FRAME"] = "Erfolgsanzeige für Rufänderungen",
        ["LID_SHOW_ANNOUNCE_MIK"] = " - MikSBT für Ankündigung verwenden",
        ["LID_TOOLTIP_SCALE"] = "Tooltip-Skalierung",
        ["LID_SHOW_MINIMAL"] = "Minimale Tooltip-Anzeige verwenden",
        ["LID_SCALE_INCREASE"] = "+ Tooltip-Skalierung erhöhen",
        ["LID_SCALE_DECREASE"] = "- Tooltip-Skalierung verringern",
        ["LID_SHOW_FRIENDS_ON_BAR"] = "Freundschaften anzeigen",
        ["LID_PARAGON"] = "Paragon",
        ["LID_SESSION_SUMMARY"] = "Sitzungszusammenfassung",
        ["LID_SESSION_SUMMARY_DURATION"] = "Dauer",
        ["LID_SESSION_SUMMARY_TOTAL_EXALTED_FACTIONS"] = "Anzahl ehrfürchtiger Fraktionen",
        ["LID_SESSION_SUMMARY_FACTIONS"] = "Fraktionen",
        ["LID_SESSION_SUMMARY_FRIENDS"] = "Freunde",
        ["LID_SESSION_SUMMARY_TOTAL"] = "Gesamt",
        ["LID_SESSION_SUMMARY_RESET"] = "Sitzung zurücksetzen"
    }

    TitanPanelReputation:UpdateLanguageTab(tab)
end

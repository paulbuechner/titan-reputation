-- zhTW Simplified Chinese
local _, TitanPanelReputation = ...
function TitanPanelReputation:LangzhCN()
    local tab = {
        -- General
        ["LID_INITIALIZED"] = "Initialized",
        ["LID_MINUTE_SHORT"] = "min",
        ["LID_MINUTES_SHORT"] = "mins",
        ["LID_HOUR_SHORT"] = "h",
        ["LID_HOURS_SHORT"] = "hrs",

        ["LID_TITAN_TOO_OLD_WARNING_BUTTON"] = "or later required",
        ["LID_TITAN_TOO_OLD_WARNING_TOOLTIP_START"] = "Please upgrade Titan Panel to version",
        ["LID_TITAN_TOO_OLD_WARNING_TOOLTIP_END"] = "or later to unlock full functionality.",

        -- Labels
        ["LID_ALL_HIDDEN_LABEL"] = "Reputation: Off",
        ["LID_NO_FACTION_LABEL"] = "Reputation: No Faction Selected",
        ["LID_SHOW_FACTION_NAME_LABEL"] = "Show Faction Name",
        ["LID_SHOW_STANDING"] = "Show Standing",
        ["LID_SHOW_VALUE"] = "Show Reputation Value",
        ["LID_SHOW_PERCENT"] = "Show Percent",
        ["LID_AUTO_CHANGE"] = "Auto Show Changed",
        ["LID_FRIENDSHIP_RANK_SETTINGS"] = "Friendship Rank Settings",
        ["LID_SHOW_FRIENDSHIPS"] = "Show Friendships",
        ["LID_HIDE_MAX_FRIENDSHIPS"] = "Hide Max Friendships",
        ["LID_SHOW_BESTFRIEND"] = "Show Best Friend",
        ["LID_SHOW_GOODFRIEND"] = "Show Good Friend",
        ["LID_SHOW_FRIEND"] = "Show Friend",
        ["LID_SHOW_BUDDY"] = "Show Buddy",
        ["LID_SHOW_ACQUAINTANCE"] = "Show Acquaintance",
        ["LID_SHOW_STRANGER"] = "Show Stranger",
        ["LID_REPUTATION_STANDING_SETTINGS"] = "Reputation Standing Settings",
        ["LID_SHOW_EXALTED"] = "Show Exalted",
        ["LID_SHOW_REVERED"] = "Show Revered",
        ["LID_SHOW_HONORED"] = "Show Honored",
        ["LID_SHOW_FRIENDLY"] = "Show Friendly",
        ["LID_SHOW_NEUTRAL"] = "Show Neutral",
        ["LID_SHOW_UNFRIENDLY"] = "Show Unfriendly",
        ["LID_SHOW_HOSTILE"] = "Show Hostile",
        ["LID_SHOW_HATED"] = "Show Hated",
        ["LID_SHORT_STANDING"] = " - Abbreviate Standing",
        ["LID_ARMORY_COLORS"] = "Armory",
        ["LID_DEFAULT_COLORS"] = "Default",
        ["LID_NO_COLORS"] = "Basic",
        ["LID_SHOW_STATS"] = "Show Total Exalted Factions",
        ["LID_SHOW_ICON"] = "Show Icon",
        ["LID_BUTTON_OPTIONS"] = "Button Options",
        ["LID_TOOLTIP_OPTIONS"] = "Tooltip Options",
        ["LID_COLOR_OPTIONS"] = "Color Options",
        ["LID_CLOSE_MENU"] = "Close",


        -- Session Summary
        ["LID_SESSION_SUMMARY_SETTINGS"] = "Session Summary Settings",
        ["LID_SHOW_SUMMARY_DURATION"] = "Show Duration",
        ["LID_SHOW_SUMMARY_TTL"] = "Show Time to Level",

        ["LID_TIP_SESSION_SUMMARY_SETTINGS"] = "Tooltip Session Summary Settings",
        ["LID_TIP_SHOW_SUMMARY_DURATION"] = "Show Duration",
        ["LID_TIP_SHOW_SUMMARY_TTL"] = "Show Time to Level",

        ["LID_SHOW_ANNOUNCE"] = "Announce Standing Changes",
        ["LID_SHOW_ANNOUNCE_FRAME"] = "Standing Change Achievements",
        ["LID_SHOW_ANNOUNCE_MIK"] = " - Use MikSBT for Announcement",
        ["LID_TOOLTIP_SCALE"] = "Tooltip Scale",
        ["LID_TOOLTIP_WARNING"] = "CAUTION: This effects ALL tooltips",
        ["LID_SHOW_MINIMAL"] = "Use MinimalTip Tooltip Display",
        ["LID_SCALE_INCREASE"] = "+ Increase Tooltip Scale",
        ["LID_SCALE_DECREASE"] = "- Decrease Tooltip Scale",
        ["LID_DISPLAY_ON_RIGHT_SIDE"] = "Align Plugin to Right-Side",
        ["LID_SHOW_FRIENDS_ON_BAR"] = "Show Friendships",
        ["LID_PARAGON"] = "Paragon",
        ["LID_SESSION_SUMMARY"] = "Session Summary",
        ["LID_SESSION_SUMMARY_DURATION"] = "Duration",
        ["LID_SESSION_SUMMARY_TOTAL_EXALTED_FACTIONS"] = "Total Exalted Factions",
        ["LID_SESSION_SUMMARY_FACTIONS"] = "Factions",
        ["LID_SESSION_SUMMARY_FRIENDS"] = "Friends",
        ["LID_SESSION_SUMMARY_TOTAL"] = "Total",
        ["LID_SESSION_SUMMARY_RESET"] = "Reset Session Data"
    }

    TitanPanelReputation:UpdateLanguageTab(tab)
end

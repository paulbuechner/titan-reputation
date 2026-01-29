-- ruRU Russian ZamestoTV
local _, TitanPanelReputation = ...
function TitanPanelReputation:LangruRU()
    local tab = {
        -- General
        ["LID_INITIALIZED"] = "Инициализировано",
        ["LID_MINUTE_SHORT"] = "мин",
        ["LID_MINUTES_SHORT"] = "мин",
        ["LID_HOUR_SHORT"] = "ч",
        ["LID_HOURS_SHORT"] = "ч",

        ["LID_TITAN_TOO_OLD_WARNING_BUTTON"] = "or later required",
        ["LID_TITAN_TOO_OLD_WARNING_TOOLTIP_START"] = "Please upgrade Titan Panel to version",
        ["LID_TITAN_TOO_OLD_WARNING_TOOLTIP_END"] = "or later to unlock full functionality.",

        -- Labels
        ["LID_ALL_HIDDEN_LABEL"] = "Репутация: Выключено",
        ["LID_NO_FACTION_LABEL"] = "Репутация: Фракция не выбрана",
        ["LID_SHOW_FACTION_NAME_LABEL"] = "Показывать название фракции",
        ["LID_SHOW_STANDING"] = "Показывать статус",
        ["LID_SHOW_VALUE"] = "Показывать значение репутации",
        ["LID_SHOW_PERCENT"] = "Показывать процент",
        ["LID_AUTO_CHANGE"] = "Автоматическое отображение изменений",
        ["LID_FRIENDSHIP_RANK_SETTINGS"] = "Настройки рангов дружбы",
        ["LID_SHOW_FRIENDSHIPS"] = "Показывать дружеские отношения",
        ["LID_HIDE_MAX_FRIENDSHIPS"] = "Hide Max Friendships",
        ["LID_SHOW_BESTFRIEND"] = "Показывать лучший друг",
        ["LID_SHOW_GOODFRIEND"] = "Показывать хороший друг",
        ["LID_SHOW_FRIEND"] = "Показывать друг",
        ["LID_SHOW_BUDDY"] = "Показывать приятель",
        ["LID_SHOW_ACQUAINTANCE"] = "Показывать знакомый",
        ["LID_SHOW_STRANGER"] = "Показывать незнакомец",
        ["LID_REPUTATION_STANDING_SETTINGS"] = "Настройки статуса репутации",
        ["LID_SHOW_EXALTED"] = "Показывать превознесение",
        ["LID_SHOW_REVERED"] = "Показывать почтение",
        ["LID_SHOW_HONORED"] = "Показывать уважение",
        ["LID_SHOW_FRIENDLY"] = "Показывать дружелюбие",
        ["LID_SHOW_NEUTRAL"] = "Показывать нейтральность",
        ["LID_SHOW_UNFRIENDLY"] = "Показывать неприязнь",
        ["LID_SHOW_HOSTILE"] = "Показывать враждебность",
        ["LID_SHOW_HATED"] = "Показывать ненависть",
        ["LID_SHORT_STANDING"] = " - Сокращать статус",
        ["LID_ARMORY_COLORS"] = "Оружейная",
        ["LID_DEFAULT_COLORS"] = "По умолчанию",
        ["LID_NO_COLORS"] = "Базовый",
        ["LID_SHOW_STATS"] = "Показывать общее количество превознесённых фракций",
        ["LID_SHOW_ICON"] = "Показывать иконку",
        ["LID_BUTTON_OPTIONS"] = "Опции кнопки",
        ["LID_TOOLTIP_OPTIONS"] = "Опции подсказки",
        ["LID_COLOR_OPTIONS"] = "Опции цвета",
        ["LID_CLOSE_MENU"] = "Закрыть",

        -- Session Summary
        ["LID_SESSION_SUMMARY_SETTINGS"] = "Настройки сводки сессии",
        ["LID_SHOW_SUMMARY_DURATION"] = "Показывать длительность",
        ["LID_SHOW_SUMMARY_TTL"] = "Показывать время до уровня",

        ["LID_TIP_SESSION_SUMMARY_SETTINGS"] = "Настройки сводки сессии в подсказке",
        ["LID_TIP_SHOW_SUMMARY_DURATION"] = "Показывать длительность",
        ["LID_TIP_SHOW_SUMMARY_TTL"] = "Показывать время до уровня",

        ["LID_SHOW_ANNOUNCE"] = "Оповещать об изменении статуса",
        ["LID_SHOW_ANNOUNCE_FRAME"] = "Достижения изменения статуса",
        ["LID_SHOW_ANNOUNCE_MIK"] = " - Использовать MikSBT для оповещений",
        ["LID_TOOLTIP_SCALE"] = "Масштаб подсказки",
        ["LID_TOOLTIP_WARNING"] = "ВНИМАНИЕ: Это влияет на ВСЕ подсказки",
        ["LID_SHOW_MINIMAL"] = "Использовать минимальное отображение подсказки",
        ["LID_SCALE_INCREASE"] = "+ Увеличить масштаб подсказки",
        ["LID_SCALE_DECREASE"] = "- Уменьшить масштаб подсказки",
        ["LID_DISPLAY_ON_RIGHT_SIDE"] = "Выровнять плагин по правой стороне",
        ["LID_SHOW_FRIENDS_ON_BAR"] = "Показывать дружеские отношения",
        ["LID_PARAGON"] = "Парагон",
        ["LID_SESSION_SUMMARY"] = "Сводка сессии",
        ["LID_SESSION_SUMMARY_DURATION"] = "Длительность",
        ["LID_SESSION_SUMMARY_TOTAL_EXALTED_FACTIONS"] = "Общее количество превознесённых фракций",
        ["LID_SESSION_SUMMARY_FACTIONS"] = "Фракции",
        ["LID_SESSION_SUMMARY_FRIENDS"] = "Друзья",
        ["LID_SESSION_SUMMARY_TOTAL"] = "Итого",
        ["LID_SESSION_SUMMARY_RESET"] = "Сбросить данные сессии"
    }

    TitanPanelReputation:UpdateLanguageTab(tab)
end

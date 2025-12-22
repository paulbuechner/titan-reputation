---@meta _
---@diagnostic disable: duplicate-doc-field
---@diagnostic disable: duplicate-doc-alias

--[[ ------------------------------ CUSTOM TYPES ------------------------------ ]]

---@class FactionDetails
---@field name string: The name of the faction
---@field parentName string The name of the parent faction
---@field standingID number: The faction standing ID
---@field topValue number: The top value of the faction
---@field earnedValue number: The earned value of the faction
---@field percent string: The percentage of the current faction standing progress
---@field headerLevel number: The indentation level used when grouping factions
---@field headerPath string[]: Ordered list of header labels leading to this entry (empty table for root entries)
---@field isHeader boolean: Whether the faction is a header
---@field isCollapsed boolean: Whether the faction is collapsed
---@field isInactive boolean: Whether the faction is inactive
---@field hasRep boolean: Whether the faction has reputation
---@field isChild boolean: Whether the faction is a child
---@field friendShipReputationInfo FriendshipReputationInfo|nil: The friendship reputation info
---@field factionID number: The faction ID
---@field hasBonusRepGain boolean: Whether the faction has bonus reputation gain
---@field icon string|nil: The icon texture path for the faction

---@class AdjustedIDAndLabel
---@field adjustedID number: The adjusted standing ID
---@field label string|nil: The adjusted label
---@field factionType string: The faction type

---@class TitanReputationFactionMapping
---@field name string|nil Display name override
---@field header string|nil Parent header label override
---@field level number|nil Hierarchy level (0 = header, 1 = root faction, 2+ = child)
---@field icon string|nil Custom texture path for popups
---@field isHeader boolean|nil Force header flag
---@field isChild boolean|nil Force child flag
---@field hasRep boolean|nil Force reputation flag on headers
---@field path string[]|nil Explicit header lineage to display (e.g. `{"Dragonflight", "Dragonscale Expedition"}`)

--[[ ------------------------------ UI / Globals ------------------------------ ]]

---@class TextureKitConstants
---@field UseAtlasSize number

---@class AlertFrameSubSystem
---@field SetCanShowMoreConditionFunc fun(self: AlertFrameSubSystem, fn: fun(): boolean)
---@field AddAlert fun(self: AlertFrameSubSystem, ...)

---@class AlertFrame
---@field AddQueuedAlertFrameSubSystem fun(self: AlertFrame, alertFrameTemplate: string, setUpFunction: function, maxAlerts: number, maxQueue: number, coalesceFunction: function|nil): AlertFrameSubSystem

---@class _G
---@field TextureKitConstants TextureKitConstants
---@field AlertFrame AlertFrame
---@field AchievementFrame table|nil
---@field AchievementFrame_LoadUI fun()
---@field AchievementShield_SetPoints fun(points: number, pointString: string, normalFont: Font, smallFont: Font)

---@type AlertFrame
AlertFrame = _G.AlertFrame

---
---Sets the points and point string for the achievement shield.
---
---[Documentation](https://github.com/Gethe/wow-ui-source/blob/9851483e3df93d33143103db99bad8e9542c2b65/Interface/AddOns/Blizzard_AchievementUI/Mainline/Blizzard_AchievementUI.lua#L1655)
---@param points number: The points to set
---@param pointString string: The point string to set
---@param normalFont Font: The normal font to use
---@param smallFont Font: The small font to use
function AchievementShield_SetPoints(points, pointString, normalFont, smallFont) end

---
---Adds a queued alert frame sub system to the alert frame.
---
---[Documentation](https://github.com/Gethe/wow-ui-source/blob/9851483e3df93d33143103db99bad8e9542c2b65/Interface/AddOns/Blizzard_FrameXML/Mainline/AlertFrames.lua#L347)
---@param alertFrameTemplate string: The alert frame template to use
---@param setUpFunction function: The function to use to set up the alert frame
---@param maxAlerts number: The maximum number of alerts to show
---@param maxQueue number: The maximum number of alerts to queue
---@param coalesceFunction function|nil: The function to use to coalesce the alerts
---@return AlertFrameSubSystem: The alert frame sub system
function AlertFrame:AddQueuedAlertFrameSubSystem(alertFrameTemplate, setUpFunction, maxAlerts, maxQueue, coalesceFunction) end

--[[ ------------------------------ CUSTOM TYPES ------------------------------ ]]

---@class FactionDetails
---@field name string: The name of the faction
---@field parentName string The name of the parent faction
---@field standingID number: The faction standing ID
---@field topValue number: The top value of the faction
---@field earnedValue number: The earned value of the faction
---@field percent string: The percentage of the current faction standing progress
---@field headerLevel number: The indentation level used when grouping factions
---@field isHeader boolean: Whether the faction is a header
---@field isCollapsed boolean: Whether the faction is collapsed
---@field isInactive boolean: Whether the faction is inactive
---@field hasRep boolean: Whether the faction has reputation
---@field isChild boolean: Whether the faction is a child
---@field friendShipReputationInfo FriendshipReputationInfo|nil: The friendship reputation info
---@field factionID number: The faction ID
---@field hasBonusRepGain boolean: Whether the faction has bonus reputation gain


---@class AdjustedIDAndLabel
---@field adjustedID number: The adjusted standing ID
---@field label string|nil: The adjusted label
---@field factionType string: The faction type

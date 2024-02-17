-- THIS FILE IS NOT PUBLISHED

-- This file is here to define WoW and UI globals that are not declared in code
-- so that syntax analysers can react favourably to it.
-- For vscode users the WoW API Extension (https://marketplace.visualstudio.com/items?itemName=ketho.wow-api)
-- is recommended to support a wider range of WoW API functions.

-- the `<value> and <variable>` syntax is used to allow the syntax analyser to
-- determine the data-type of the variable


-------------------------------------------------------------------------------
-- MSBT API
-------------------------------------------------------------------------------

MikSBT = {}

local MSBTMedia = {}; MSBTAnimations = {}; MSBTProfiles = {} -- Not public (only for this file)


-- Public Functions.
MikSBT.RegisterFont                 = MSBTMedia.RegisterFont
MikSBT.RegisterAnimationStyle       = MSBTAnimations.RegisterAnimationStyle
MikSBT.RegisterStickyAnimationStyle = MSBTAnimations.RegisterStickyAnimationStyle
MikSBT.RegisterSound                = MSBTMedia.RegisterSound
MikSBT.IterateFonts                 = MSBTMedia.IterateFonts
MikSBT.IterateScrollAreas           = MSBTAnimations.IterateScrollAreas
MikSBT.IterateSounds                = MSBTMedia.IterateSounds
MikSBT.IsModDisabled                = MSBTProfiles.IsModDisabled

-- Public Constants.
---@alias MikSBT.DISPLAYTYPE_INCOMING string
MikSBT.DISPLAYTYPE_INCOMING         = "Incoming"
---@alias MikSBT.DISPLAYTYPE_OUTGOING string
MikSBT.DISPLAYTYPE_OUTGOING         = "Outgoing"
---@alias MikSBT.DISPLAYTYPE_NOTIFICATION string
MikSBT.DISPLAYTYPE_NOTIFICATION     = "Notification"
---@alias MikSBT.DISPLAYTYPE_STATIC string
MikSBT.DISPLAYTYPE_STATIC           = "Static"

---@alias MikSBT.DISPLAYTYPE
---| `MikSBT.DISPLAYTYPE_INCOMING`
---| `MikSBT.DISPLAYTYPE_OUTGOING`
---| `MikSBT.DISPLAYTYPE_NOTIFICATION`
---| `MikSBT.DISPLAYTYPE_STATIC`


--[[ MikSBT
NAME: MikSBT.DisplayMessage
DESC: Displays the passed message with the passed formatting options.
]]
---@param message string: The string to display.
---@param scrollArea? MikSBT.DISPLAYTYPE: Specifies the scroll area key or scroll area name in which to display the message. Defaults to `MikSBT.DISPLAYTYPE_NOTIFICATION`
---@param isSticky? boolean: Specifies whether or not the message should be displayed sticky style. This must be either true or false. Defaults to false.
---@param colorR? number: The red component of the color to display the message with. Value range is 0-255. Defaults to 255.
---@param colorG? number: The green component of the color to display the message with. Value range is 0-255. Defaults to 255.
---@param colorB? number: The blue component of the color to display the message with. Value range is 0-255. Defaults to 255.
---@param fontSize? number: The font size to use. Value range is 4-38.
---@param fontName? string: The name of the font to use. You can get a list of available font names with the `MikSBT.IterateFonts` function.
---@param outlineIndex? number: The index of the outline to use. The valid values are: 1 - No Outline, 2 - Thin, 3 - Thick, 4 - Monochrome, 5 - Monochrome + Thin, 6 - Monochrome + Thick
---@param texturePath? string: The path to a texture file to display. If the parameter is omitted or an invalid path is passed, no texture will be displayed.
MikSBT.DisplayMessage = function(message, scrollArea, isSticky, colorR, colorG, colorB, fontSize, fontName, outlineIndex,
                                 texturePath)
end

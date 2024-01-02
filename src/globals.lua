-- THIS FILE IS NOT PUBLISHED

-- This file is here to define WoW and UI globals that are not declared in code
-- so that syntax analysers can react favourably to it.
-- For vscode users the WoW API Extension (https://marketplace.visualstudio.com/items?itemName=ketho.wow-api)
-- is recommended to support a wider range of WoW API functions.

-- the `<value> and <variable>` syntax is used to allow the syntax analyser to
-- determine the data-type of the variable


-- main.lua --------------------------------------------------------------------------------

--[[ TitanPanelReputation
NAME: TitanPanelReputationButton
DESC: No code - this is a place holder for the XML template.
VAR: self - expected to be a Titan bar
OUT: None
--]]
TitanPanelReputationButton = function(self) end






-- TitanGlobal.lua ------------------------------------------------------------------------------------------

TitanPlugins = {}; -- Used by plugins






-- Titan.lua ------------------------------------------------------------------------------------------

TitanPanel_OkToReload = function() end

--[[ Titan
NAME: TitanPanel_ResetToDefault
DESC: Give the user a 'are you sure'. If the user accepts then reset current toon back to default Titan settings.
VAR:  None
OUT:  None
NOTE:
- Even if the user was using global profiles they will not when this is done.
:NOTE
--]]
TitanPanel_ResetToDefault = function() end

--[[ Titan
NAME: TitanPanel_SaveCustomProfile
DESC: The user wants to save a custom Titan profile. Show the user the dialog boxes to make it happen.
VAR:  None
OUT:  None
NOTE:
- The profile is written to the Titan saved variables. A reload of the UI is needed to ensure the profile is written to disk for the user to load later.
:NOTE
--]]
TitanPanel_SaveCustomProfile = function() end

--[[ Titan
NAME: TitanSetPanelFont
DESC: Set or change the font and font size of text on the Titan bar. This affects ALL plugins.
VAR: fontname - The text name of the font to use. Defaults to Titan default if none given.
VAR: fontsize - The size of the font to use. Defaults to Titan default if none given.
OUT: None
NOTE:
- Each registered plugin will have its font updated. Then all plugins will be refreshed to show the new font.
:NOTE
--]]
TitanSetPanelFont = function(fontname, fontsize) end

--[[ Titan
NAME: TitanPanel_PlayerEnteringWorld
DESC: Do all the setup needed when a user logs in / reload UI / enter or leave an instance.
VAR:  None
OUT:  None
NOTE:
- This is called after the 'player entering world' event is fired by Blizz.
- This is also used when a LDB plugin is created after Titan runs the 'player entering world' code.
:NOTE
--]]
TitanPanel_PlayerEnteringWorld = function(reload) end

--[[ Titan
NAME: TitanPanelBarButton_OnClick
DESC: Handle the button clicks on any Titan bar.
VAR: self - expected to be a Titan bar
VAR: button - which mouse button was clicked
OUT:  None
NOTE:
- This only reacts to the right or left mouse click without modifiers.
- Used in the set script for the Titan display and hider frames
:NOTE
--]]
TitanPanelBarButton_OnClick = function(self, button) end

TitanPanel_SetBarTexture = function(frame) end

--------------------------------------------------------------
--
-- auto hide event handlers
--[[ Titan
NAME: TitanPanelBarButton_OnLeave
DESC: On leaving the display check if we have to hide the Titan bar. A timer is used - when it expires the bar is hid.
VAR: self - expected to be a Titan bar
OUT: None
--]]
TitanPanelBarButton_OnLeave = function(self) end

--[[ Titan
NAME: TitanPanelBarButton_OnEnter
DESC: No code - this is a place holder for the XML template.
VAR: self - expected to be a Titan bar
OUT: None
--]]
TitanPanelBarButton_OnEnter = function(self) end

--[[ Titan
NAME: TitanPanelBarButtonHider_OnLeave
DESC: No code - this is a place holder for the XML template.
VAR: self - expected to be a Titan bar
OUT: None
--]]
TitanPanelBarButtonHider_OnLeave = function(self) end

--[[ Titan
NAME: TitanPanelBarButtonHider_OnEnter
DESC: On entering the hider check if we need to show the display bar.
VAR: self - expected to be a Titan hider bar
OUT: None
NOTE:
- No action is taken if the user is on combat.
:NOTE
--]]
TitanPanelBarButtonHider_OnEnter = function(self) end

--------------------------------------------------------------
--
-- Titan Frames for CLASSIC versions

--
--==========================
-- Routines to handle adjusting some UI frames
--
--[[ Titan
NAME: TitanPanelBarButton_ToggleAlign
DESC: Align the buttons per the user's new choice.
VAR: align - left or center
OUT: None
--]]
TitanPanelBarButton_ToggleAlign = function(align) end

--[[ Titan
NAME: TitanPanelBarButton_ToggleAutoHide
DESC: Toggle the auto hide of the given Titan bar per the user's new choice.
VAR: frame - expected to be a Titan bar
OUT:  None
--]]
TitanPanelBarButton_ToggleAutoHide = function(frame) end

--[[ Titan
NAME: TitanPanelBarButton_ToggleScreenAdjust
DESC: Toggle whether Titan adjusts 'top' frames around Titan bars per the user's new choice.
VAR:  None
NOTE:
- Another addon can tell Titan to NOT adjust some or all frames.
:NOTE
--]]
TitanPanelBarButton_ToggleScreenAdjust = function() end

--[[ Titan
NAME: TitanPanelBarButton_ToggleAuxScreenAdjust
DESC: Toggle whether Titan adjusts 'bottom' frames around Titan bars per the user's new choice.
VAR:  None
OUT:  None
NOTE:
- Another addon can tell Titan to NOT adjust some or all frames.
:NOTE
--]]
TitanPanelBarButton_ToggleAuxScreenAdjust = function() end

--[[ Titan
NAME: TitanPanelBarButton_ForceLDBLaunchersRight
DESC: Force all plugins created from LDB addons, visible or not, to be on the right side of the Titan bar. Any visible plugin will be forced to the right side on the same bar it is currently on.
VAR:  None
OUT:  None
--]]
TitanPanelBarButton_ForceLDBLaunchersRight = function() end

--[[ Titan
NAME: TitanPanelBarButton_DisplayBarsWanted
DESC: Show all the Titan bars the user has selected.
VAR:  None
OUT:  None
--]]
TitanPanelBarButton_DisplayBarsWanted = function(reason) end

--[[ Titan
NAME: TitanPanelBarButton_HideAllBars
DESC: This routine will hide all the Titan bars (and hiders) regardless of what the user has selected.
VAR:  None
OUT:  None
NOTE:
- For example when the pet battle is active. We cannot figure out how to move the pet battle frame so we are punting and hiding Titan...
- We only need to hide the bars (and hiders) - not adjust frames
:NOTE
--]]
TitanPanelBarButton_HideAllBars = function() end

--[[ Titan
NAME: TitanPanelBarButton_Show
DESC: Show / hide the given Titan bar based on the user selection.
VAR: frame - expected to be a Titan bar name (string)
OUT:  None
NOTE:
- Hide moves rather than just 'not shown'. Otherwise the buttons will stay visible defeating the purpose of hide.
:NOTE
--]]
TitanPanelBarButton_Show = function(frame) end

--[[ Titan
NAME: TitanPanelBarButton_Hide
DESC: Hide the given Titan bar based on the user selection.
VAR: frame - expected to be a Titan bar name (string)
OUT:  None
NOTE:
- Hide moves rather than just 'not shown'. Otherwise the buttons will stay visible defeating the purpose of hide.
- Also moves the hider bar if auto hide is not selected.
:NOTE
--]]
TitanPanelBarButton_Hide = function(frame) end

--[[ Titan
NAME: TitanPanel_InitPanelButtons
DESC: Show all user selected plugins on the Titan bar(s) then justify per the user selection.
VAR:  None
OUT:  None
--]]
TitanPanel_InitPanelButtons = function() end

--[[ Titan
NAME: TitanPanel_ReOrder
DESC: Reorder all the shown all user selected plugins on the Titan bar(s). Typically used after a button has been removed / hidden.
VAR: index - the index of the plugin removed so the list can be updated
OUT:  None
--]]
TitanPanel_ReOrder = function(index) end

--[[ Titan
NAME: TitanPanel_RemoveButton
DESC: Remove a plugin then show all the shown all user selected plugins on the Titan bar(s).
VAR:  id - the plugin name (string)
OUT:  None
NOTE:
- This cancels all timers of name "TitanPanel"..id as a safeguard to destroy any active plugin timers based on a fixed naming convention : TitanPanel..id, eg. "TitanPanelClock" this prevents "rogue" timers being left behind by lack of an OnHide check
:NOTE
--]]
TitanPanel_RemoveButton = function(id) end

--[[ Titan
NAME: TitanPanel_GetButtonNumber
DESC: Get the index of the given plugin from the Titan plugin displayed list.
VAR: id - the plugin name (string)
OUT: index of the plugin in the Titan plugin list or the end of the list. The routine returns +1 if not found so it is 'safe' to update / add to the Location
--]]
TitanPanel_GetButtonNumber = function(id) end

--[[ Titan
NAME: TitanPanel_RefreshPanelButtons
DESC: Update / refresh each plugin from the Titan plugin list. Used when a Titan option is changed that effects all plugins.
VAR:  None
OUT:  None
--]]
TitanPanel_RefreshPanelButtons = function() end

--[[ Titan
NAME: TitanPanelButton_Justify
DESC: Justify the plugins on each Titan bar. Used when the user changes the 'center' option on a Titan bar.
VAR:  None
OUT:  None
--]]
TitanPanelButton_Justify = function() end

--[[ Titan
NAME: TitanPanelRightClickMenu_PrepareBarMenu
DESC: This is the controller of the Titan (right click) menu.
VAR: self - expected to be the Titan bar that was right clicked
OUT: None
NOTE:
- Frame name used is <Titan bar name>RightClickMenu
:NOTE
--]]
TitanPanelRightClickMenu_PrepareBarMenu = function(self) end

--[[ Titan
NAME: TitanPanel_IsPluginShown
DESC: Determine if the given plugin is shown on a Titan bar. The Titan bar could be not shown or on auto hide and the plugin will still be 'shown'.
VAR: id - plugin name (string)
OUT: int - index of the plugin or nil
--]]
TitanPanel_IsPluginShown = function(id) end

--[[ Titan
NAME: TitanPanel_GetPluginSide
DESC: Determine if the given plugin is or would be on right or left of a Titan bar. This returns right or left regardless of whether the plugin is 'shown'.
VAR: id - plugin name (string)
OUT: string - "Right" or "Left"
--]]
TitanPanel_GetPluginSide = function(id) end

--[[
print("OnMoveStart"
.." "..tostring(self:GetName())..""
.." "..tostring(IsShiftKeyDown())..""
.." "..tostring(IsAltKeyDown())..""
.."\n"
.." x "..tostring(format("%0.1f", self:GetLeft()))..""
.." y "..tostring(format("%0.1f", self:GetTop()))..""
)
--]]

--[[ Titan
NAME: TitanPanel_InitPanelBarButton
DESC: Set the scale, texture (graphic), and transparancy of all the Titan bars based on the user selection.
VAR:  None
OUT:  None
--]]
TitanPanel_InitPanelBarButton = function() end

--
--==========================
-- Routines to handle creation of Titan bars
--
--[[ Titan
NAME: TitanPanelButton_CreateBar(frame_str)
DESC: Create a Titan bar that can show plugins.
VAR: frame_str - name of the frame
NOTE:
- This assumes ...
:NOTE
--]]
TitanPanelButton_CreateBar = function(frame_str) end






-- TitanUtils.lua ------------------------------------------------------------------------------------------

--[[ API
NAME: TitanUtils_GetMinimapAdjust
DESC: Return the current setting of the Titan MinimapAdjust option.
VAR: None
OUT: The value of the MinimapAdjust option
--]]
TitanUtils_GetMinimapAdjust = function() end -- Used by addons


--[[ API
NAME: TitanUtils_SetMinimapAdjust
DESC: Set the current setting of the Titan MinimapAdjust option.
VAR:  bool - true (off) or false (on)
OUT:  None
--]]
TitanUtils_SetMinimapAdjust = function(bool) -- Used by addons
    -- This routine allows an addon to turn on or off
    -- the Titan minimap adjust.
end

--[[ API
NAME: TitanUtils_AddonAdjust
DESC: Tell Titan to adjust (or not) a frame.
VAR: frame - is the name (string) of the frame
VAR: bool  - true if the addon will adjust the frame or false if Titan will adjust
OUT:  None
Note:
- Titan will NOT store the adjust value across a log out / exit.
- This is a generic way for an addon to tell Titan to not adjust a frame. The addon will take responsibility for adjusting that frame. This is useful for UI style addons so the user can run Titan and a modifed UI.
- The list of frames Titan adjusts is specified in TitanMovableData within TitanMovable.lua.
- If the frame name is not in TitanMovableData then Titan does not adjust that frame.
:NOTE
--]]
TitanUtils_AddonAdjust = function(frame, bool) end -- Used by addons


--[[ ==================================================
End Classic versions
--]]


--
-- The routines labeled API are useable by addon developers
--

--[[ API
NAME: TitanUtils_GetBarAnchors
DESC: Get the anchors of the bottom most top bar and the top most bottom bar.
   Intended for addons that modify the UI so they can adjust for Titan.
   The anchors adjust depending on what Titan bars the user displays.
:DESC
VAR:  None
OUT: frame - TitanPanelTopAnchor frame reference - Titan uses the space ABOVE this
OUT: frame - TitanPanelBottomAnchor frame reference - Titan uses the space BELOW this
NOTE:
-  The two anchors are implemented as 2 frames that are moved by Titan depending on which bars are shown.
:NOTE
--]]
TitanUtils_GetBarAnchors = function() end -- Used by addons

--------------------------------------------------------------
--
-- Plugin button search & manipulation routines
--
--[[ API
NAME: TitanUtils_GetButton
DESC: Create thebutton name from plugin id.
VAR: id - is the id of the plugin
OUT: string - The button / frame name
--]]
TitanUtils_ButtonName = function(id) end

--[[ API
NAME: TitanUtils_GetButton
DESC: Return the actual button frame and the plugin id.
VAR: id - is the id of the plugin
OUT: frame - The button table
OUT: string - The id of the plugin
--]]
TitanUtils_GetButton = function(id) end -- Used by plugins

--[[ API
NAME: TitanUtils_GetRealPosition
DESC: Return whether the plugin is on the top or bottom bar.
VAR: id - is the id of the plugin
OUT: bottom(2) or top(1)-default
NOTE:
- This returns top or bottom NOT which bar (1-4) the plugin is on.
:NOTE
--]]
TitanUtils_GetRealPosition = function(id) -- Used by plugins
    -- This will return top / bottom but it is a compromise.
    -- With the introduction of independent bars there is
    -- more than just top / bottom.
    -- This should work in the sense that the plugins using this
    -- would overlap the double bar.
end

--[[ API
NAME: TitanUtils_GetButtonID
DESC: Return the plugin id of the given name. This can be used to see if a plugin exists.
VAR: name - is the id of the plugin
OUT: string - plugin id or nil
--]]
TitanUtils_GetButtonID = function(name) end

--[[ API
NAME: TitanUtils_GetParentButtonID
DESC: Return the plugin id of the parent of the given name, if it exists.
VAR: name - is the id of the plugin
OUT: string - plugin id or nil
--]]
TitanUtils_GetParentButtonID = function(name) end

--[[ API
NAME: TitanUtils_GetButtonIDFromMenu
DESC: Return the plugin id of whatever the mouse is over. Used in the right click menu on load.
VAR: self - is the id of the frame
OUT: string - plugin id or nil
NOTE:
- The plugin id returned could be the Titan bar or a plugin or nil.
:NOTE
--]]
TitanUtils_GetButtonIDFromMenu = function(self) end

--[[ API
NAME: TitanUtils_GetPlugin
DESC: Return the plugin itself (table and all).
VAR: id - is the id of the plugin
OUT: table - plugin or nil
--]]
TitanUtils_GetPlugin = function(id) end

--[[ API
NAME: TitanUtils_GetWhichBar
DESC: Return the bar the plugin is shown on.
VAR: id - is the id of the plugin
OUT: string - internal bar name or nil
OUT: string - locale bar name or nil
--]]
TitanUtils_GetWhichBar = function(id) end

--[[ API
NAME: TitanUtils_PickBar
DESC: Return the first bar that is shown.
VAR:  None
OUT: string - bar name or nil
--]]
TitanUtils_PickBar = function()
    -- Pick the 'first' bar shown per the Titan defined order.
    -- This is used for defaulting where plugins are put
    -- if using the Titan options screen.
end

--[[ API
NAME: TitanUtils_ToRight
DESC: See if the plugin is to be on the right.
   These are the methods to place a plugin on the right:
   1) DisplayOnRightSide saved variable logic (preferred)
   2) Place a plugin in TITAN_PANEL_NONMOVABLE_PLUGINS (NOT preferred)
:DESC
VAR:  None
OUT: bool - true or nil. true if the plugin is to be placed on the right side of a bar.
NOTE:
- Using the Titan template TitanPanelIconTemplate used to enforce right side only but was removed during DragonFlight to give users more flexibility.
:NOTE
--]]
TitanUtils_ToRight = function(id) end

--------------------------------------------------------------
--
-- General util routines
--

--[[ API
NAME: TitanUtils_Ternary
DESC: Return b or c if true or false respectively
VAR: a - value to determine true or false
VAR: b - value to use if true
VAR: c - value to use if false or nil
OUT: value - b (true) or c (false)
--]]
TitanUtils_Ternary = function(a, b, c) end -- Used by plugins

--[[ API
NAME: TitanUtils_Toggle
DESC: Flip the value assuming it is true or false
VAR: value - value to start with
OUT: bool - true or false
--]]
TitanUtils_Toggle = function(value) end -- Used by plugins

--[[ API
NAME: TitanUtils_Min
DESC: Return the min of a or b
VAR: a - a value
VAR: b - a value
OUT:
- value of min (a, b)
--]]
TitanUtils_Min = function(a, b) end

--[[ API
NAME: TitanUtils_Max
DESC: Return the max of a or b
VAR: a - a value
VAR: b - a value
OUT: value - value of max (a, b)
--]]
TitanUtils_Max = function(a, b) end

--[[ API
NAME: TitanUtils_Round
DESC: Return the nearest integer
VAR: v - a value
OUT:
- value of nearest integer
--]]
TitanUtils_Round = function(v) end

--[[ API
NAME: TitanUtils_GetEstTimeText
DESC: Use the seconds (s) to return an estimated time.
VAR: s - a time value in seconds
OUT: string - string with localized, estimated elapsed time using spaces and leaving off the rest
--]]
TitanUtils_GetEstTimeText = function(s) end

--[[ API
NAME: TitanUtils_GetFullTimeText
DESC: break the seconds (s) into days, hours, minutes, and seconds
VAR: s - a time value in seconds
OUT: string - string with localized days, hours, minutes, and seconds using commas and including zeroes
--]]
TitanUtils_GetFullTimeText = function(s) end

--[[ API
NAME: TitanUtils_GetAbbrTimeText
DESC: break the seconds (s) into days, hours, minutes, and seconds
VAR: s - a time value in seconds
OUT: string - string with localized days, hours, minutes, and seconds using spaces and including zeroes
--]]
TitanUtils_GetAbbrTimeText = function(s) end -- Used by plugins

--[[ API
NAME: TitanUtils_GetControlFrame
DESC: return the control frame, if one was created.
VAR: id - id of the plugin
OUT: frame - nil or the control frame
NOTE
- This may not be used anymore.
:NOTE
--]]
TitanUtils_GetControlFrame = function(id) end

--[[ API
NAME: TitanUtils_TableContainsValue
DESC: Determine if the table contains the value.
VAR: table - table to search
VAR: value - value to find
OUT: int - nil or the index to value
--]]
TitanUtils_TableContainsValue = function(table, value) end

--[[ API
NAME: TitanUtils_TableContainsIndex
DESC: Determine if the table contains the index.
VAR: table - table to search
VAR: index - index to find
OUT: int - nil or the index
--]]
TitanUtils_TableContainsIndex = function(table, index) end

--[[ API
NAME: TitanUtils_GetCurrentIndex
DESC: Determine if the table contains the value.
VAR: table - table to search
VAR: value - value to find
OUT: int - nil or the index to value
--]]
TitanUtils_GetCurrentIndex = function(table, value) end

--[[ API
NAME: TitanUtils_PrintArray
DESC: Debug tool that will attempt to output the index and value of the array passed in.
VAR: array - array to output
OUT: table - Array output to the chat window
--]]
TitanUtils_PrintArray = function(array) end

--[[ API
NAME: TitanUtils_GetRedText
DESC: Make the given text red.
VAR: text - text to color
OUT: string - Red string with proper start and end font encoding
--]]
TitanUtils_GetRedText = function(text) end -- Used by plugins

--[[ API
NAME: TitanUtils_GetGoldText
DESC: Make the given text gold.
VAR: text - text to color
OUT: string - Gold string with proper start and end font encoding
--]]
TitanUtils_GetGoldText = function(text) end

--[[ API
NAME: TitanUtils_GetGreenText
DESC: Make the given text green.
VAR: text - text to color
OUT: string - Green string with proper start and end font encoding
--]]
TitanUtils_GetGreenText = function(text) end -- Used by plugins

--[[ API
NAME: TitanUtils_GetBlueText
DESC: Make the given text blue.
VAR: text - text to color
OUT: string - Blue string with proper start and end font encoding
--]]
TitanUtils_GetBlueText = function(text) end

--[[ API
NAME: TitanUtils_GetNormalText
DESC: Make the given text normal (gray-white).
VAR: text - text to color
OUT: string - Normal string with proper start and end font encoding
--]]
TitanUtils_GetNormalText = function(text) end -- Used by plugins

--[[ API
NAME: TitanUtils_GetHighlightText
DESC: Make the given text highlight (brighter white).
VAR: text - text to color
OUT: string - Highlight string with proper start and end font encoding
--]]
TitanUtils_GetHighlightText = function(text) end -- Used by plugins

--[[ API
NAME: TitanUtils_GetColoredText
DESC: Make the given text a custom color.
VAR: text - text to color
VAR: color - color is the color table with r, b, g values set.
OUT: string - Custom color string with proper start and end font encoding
--]]
TitanUtils_GetColoredText = function(text, color) end -- Used by plugins

--[[ API
NAME: TitanUtils_GetHexText
DESC: Make the given text a custom color.
VAR: text - text to color
VAR: hex - color as a 6 char hex code
OUT: string - Custom color string with proper start and end font encoding
--]]
TitanUtils_GetHexText = function(text, hex) end -- Used by plugins

--[[ API
NAME: TitanUtils_GetThresholdColor
DESC: Flexable routine that returns the threshold color for a given value using a table as input.
VAR: ThresholdTable - table holding the list of colors and values
VAR: value -
OUT: string - The color value from the treshhold table
--]]
TitanUtils_GetThresholdColor = function(ThresholdTable, value) end

--[[ API
NAME: TitanUtils_ToString
DESC: Routine that returns the text or an empty string.
VAR: text - text to check
OUT: string - string of text or ""
--]]
TitanUtils_ToString = function(text) end


--------------------------------------------------------------
--
-- Right click menu routines - Retail dropdown menu
--
--[[
Right click menu routines for plugins
The expected global function name in the plugin is:
"TitanPanelRightClickMenu_Prepare"..<registry.id>.."Menu"

This section abstracts the menu routines built into WoW.
Over time Titan used the menu routines written by Blizzard then a lib under Ace3. Currently back to the Blizzard routines.
Whenever there is a change to the menu routines, the abstractions allows us to update Utils rather than updating Titan using search & replace. It also helps insulate 3rd party Titan plugin authors from Blizz or lib changes.
--]]

--[[ API
NAME: TitanPanelRightClickMenu_GetDropdownFrameBase
DESC: Menu - Get the current dropdown w/o a level
OUT:  str - dropdown w/o a level
--]]
TitanPanelRightClickMenu_GetDropdownFrameBase = function() end

--[[ API
NAME: TitanPanelRightClickMenu_GetDropdownMenu
DESC: Menu - Get the current level in the menus.
VAR: None
OUT:  int - dropdown menu level
--]]
TitanPanelRightClickMenu_GetDropdownFrame = function() end

--[[ API
NAME: TitanPanelRightClickMenu_GetDropdownMenu
DESC: Menu - Get the current level in the menus.
VAR: None
OUT:  int - dropdown menu level
--]]
TitanPanelRightClickMenu_GetDropdownLevel = function() end

--[[ API
NAME: TitanPanelRightClickMenu_GetDropdMenuValue
DESC: Menu - Get the current value in the selected menu.
VAR: None
OUT:  int - dropdown menu value
--]]
TitanPanelRightClickMenu_GetDropdMenuValue = function() end

--[[ API
NAME: TitanPanelRightClickMenu_AddButton
DESC: Menu - add given info (button) at the given level in the form of a button.
VAR: info - text / button / command to show
VAR: level - level to put text
OUT:  None
--]]
TitanPanelRightClickMenu_AddButton = function(info, level) end

--[[ API
NAME: TitanPanelRightClickMenu_AddToggleRightSide
DESC: Menu - add a toggle Right Side (localized) command at the given level in the form of a button. Titan will properly control the "DisplayOnRightSide"
VAR: id - id of the plugin
VAR: level - level to put the line
OUT:  None
--]]
TitanPanelRightClickMenu_AddToggleRightSide = function(id, level) end

--[[ API
NAME: TitanPanelRightClickMenu_AddTitle
DESC: Menu - add a title at the given level in the form of a button.
VAR: title - text to show
VAR: level - level to put text
OUT:  None
--]]
TitanPanelRightClickMenu_AddTitle = function(title, level) end

--[[ API
NAME: TitanPanelRightClickMenu_AddCommand
DESC: Menu - add a command at the given level in the form of a button.
VAR: title - text to show
VAR: value - value of the command
VAR: functionName - routine to run when clicked
VAR: level - level to put command
OUT:  None
--]]
TitanPanelRightClickMenu_AddCommand = function(text, value, functionName, level) end

--[[ API
NAME: TitanPanelRightClickMenu_AddSeparator
DESC: Menu - add a line at the given level in the form of an inactive button.
VAR: level - level to put the line
OUT: None
--]]
TitanPanelRightClickMenu_AddSeparator = function(level) end

--[[ API
NAME: TitanPanelRightClickMenu_AddSpacer
DESC: Menu - add a blank line at the given level in the form of an inactive button.
VAR: level - level to put the line
OUT: None
--]]
TitanPanelRightClickMenu_AddSpacer = function(level) end

--[[ API
NAME: TitanPanelRightClickMenu_Hide
DESC: This will remove the plugin from the Titan bar.
VAR: value - id of the plugin
OUT: None
--]]
TitanPanelRightClickMenu_Hide = function(value) end

--[[ API
NAME: TitanPanelRightClickMenu_AddToggleVar
DESC: Menu - add a toggle variable command at the given level in the form of a button.
VAR: text - text to show
VAR: id - id of the plugin
VAR: var - the saved variable of the plugin to toggle
VAR: toggleTable - control table (called with other than nil??)
VAR: level - level to put the line
OUT:  None
--]]
TitanPanelRightClickMenu_AddToggleVar = function(text, id, var, toggleTable, level) end

--[[ API
NAME: TitanPanelRightClickMenu_AddToggleIcon
DESC: Menu - add a toggle Icon (localized) command at the given level in the form of a button. Titan will properly control the "ShowIcon"
VAR: id - id of the plugin
VAR: level - level to put the line
OUT:  None
--]]
TitanPanelRightClickMenu_AddToggleIcon = function(id, level) end

--[[ API
NAME: TitanPanelRightClickMenu_AddToggleLabelText
DESC: Menu - add a toggle Label (localized) command at the given level in the form of a button. Titan will properly control the "ShowLabelText"
VAR: id - id of the plugin
VAR: level - level to put the line
OUT:  None
--]]
TitanPanelRightClickMenu_AddToggleLabelText = function(id, level) end

--[[ API
NAME: TitanPanelRightClickMenu_AddToggleColoredText
DESC: Menu - add a toggle Colored Text (localized) command at the given level in the form of a button. Titan will properly control the "ShowColoredText"
VAR: id - id of the plugin
VAR: level - level to put the line
OUT:  None
--]]
TitanPanelRightClickMenu_AddToggleColoredText = function(id, level) end

--[[ API
NAME: TitanPanelRightClickMenu_AddHide
DESC: Menu - add a Hide (localized) command at the given level in the form of a button. When clicked this will remove the plugin from the Titan bar.
VAR: id - id of the plugin
VAR: level - level to put the line
OUT: None
--]]
TitanPanelRightClickMenu_AddHide = function(id, level) end

--[[ API
NAME: TitanPanelRightClickMenu_ToggleVar
DESC: This will toggle the Titan variable and the update the button.
VAR: value - table of (id of the plugin, saved var to be updated, control table)
OUT:  None
--]]
TitanPanelRightClickMenu_ToggleVar = function(value) end

--[[ API
NAME: TitanPanelRightClickMenu_AllVarNil
DESC: Check if all the variables in the table are nil/false.
VAR: id - id of the plugin
VAR: toggleTable - table of saved var to be checked
OUT: bool - true (1) or nil
--]]
TitanPanelRightClickMenu_AllVarNil = function(id, toggleTable) end

--[[ API
NAME: TitanPanelRightClickMenu_AddToggleColoredText
DESC: This will toggle the "ShowColoredText" Titan variable then update the button
VAR: id - id of the plugin
VAR: level - level to put the line
OUT:  None
--]]
TitanPanelRightClickMenu_ToggleColoredText = function(value) end

--[[ API
NAME: TitanPanelRightClickMenu_SetCustomBackdrop
DESC: This will set the backdrop of the given button. This is used for custom created controls such as Clock offset or Volume sliders to give a consistent look.
VAR: frame - the control frame of the plugin
OUT:  None
--]]
TitanPanelRightClickMenu_SetCustomBackdrop = function(frame) end

--[[ API
NAME: TitanPanelRightClickMenu_AddControlVars
DESC: Menu - add the set of options that are in the plugin registry control variables .
VAR: id - id of the plugin
OUT:  None
NOTE: Assume top level only
--]]
TitanPanelRightClickMenu_AddControlVars = function(id, level) end

--------------------------------------------------------------
--
-- Plugin manipulation routines
--

--[[ Titan
NAME: TitanUtils_AddButtonOnBar
DESC: Add the given plugin to the given bar. Then reinit the plugins to show it properly.
VAR: bar - The Titan bar to add the plugin
VAR: id - id of the plugin to add
OUT:  None.
--]]
TitanUtils_AddButtonOnBar = function(bar, id) end

--[[ Titan
NAME: TitanUtils_GetFirstButtonOnBar
DESC: Find the first button that is on the given bar and is on the given side.
VAR: bar - The Titan bar to search
VAR: side - right or left
OUT: int - index of the first button or nil if none found
NOTE:
-- buttons on Left are placed L to R; buttons on Right are placed R to L. Next and prev depend on which side we need to check.
-- buttons on Right are placed R to L
:NOTE
--]]
TitanUtils_GetFirstButtonOnBar = function(bar, side) end

--[[ Titan
NAME: TitanUtils_ShiftButtonOnBarLeft
DESC: Find the button that is on the bar and is on the side and left of the given button
VAR:
- name - id of the plugin
OUT:  None
--]]
TitanUtils_ShiftButtonOnBarLeft = function(name) end

--[[ Titan
NAME: TitanUtils_ShiftButtonOnBarRight
DESC: Find the button that is on the bar and is on the side and right of the given button
VAR:
- name - id of the plugin
OUT:  None
--]]
TitanUtils_ShiftButtonOnBarRight = function(name) end

--------------------------------------------------------------
--
-- Control Frame check & manipulation routines
--
--[[ Titan Plugins
NAME: TitanUtils_CheckFrameCounting
DESC: Check the frame - expected to be a control / menu frame. Close if timer has expired. Used in plugin OnUpdate
VAR:
- frame - control / menu frame
- elapsed - portion of second since last OnUpdate
OUT:  None
--]]
TitanUtils_CheckFrameCounting = function(frame, elapsed) end

--[[ Titan Plugins
NAME: TitanUtils_StartFrameCounting
DESC: Set the max time the control frame could be open once cursor has left frame. Used in plugin OnLeave
VAR:
- frame - control / menu frame
- frameShowTime - max time
OUT:  None
--]]
TitanUtils_StartFrameCounting = function(frame, frameShowTime) end

--[[ Titan Plugins
NAME: TitanUtils_StopFrameCounting
DESC: Remove timer flag once cursor has entered frame. Used in plugin OnEnter
VAR:
- frame - control / menu frame
OUT:  None
--]]
TitanUtils_StopFrameCounting = function(frame) end

--[[ Titan Plugins AND Titan
NAME: TitanUtils_CloseAllControlFrames
DESC: Remove all timer flags on plugin control frames. Used for plugin Shift+Left and within Titan
VAR:  None
OUT:  None
--]]
TitanUtils_CloseAllControlFrames = function() end

TitanUtils_IsAnyControlFrameVisible = function() end

--[[ Titan Plugins AND Titan
NAME: TitanUtils_GetOffscreen
DESC: Check where the control frame should be on screen; return x and y
VAR:  None
OUT: float - x where frame should be
OUT: float - y where frame should be
--]]
TitanUtils_GetOffscreen = function(frame) end

--------------------------------------------------------------
--
-- Plugin registration routines
--
--[[ Titan
NAME: TitanUtils_GetAddOnMetadata
DESC: Attempt to get meta data from the addon
VAR:
- name - string of addon name
- field - string of addon field to get
OUT:  None
NOTE:
- As of May 2023 (10.1) the routine moved and no longer dies silently so it is wrapped here...
--]]
TitanUtils_GetAddOnMetadata = function(name, field) end

--[[ Titan
NAME: TitanUtils_PluginToRegister
DESC: Place the plugin to be registered later by Titan
VAR:
- self - frame of the plugin (must be a Titan template)
- isChildButton - true if the frame is a child of a Titan frame
OUT:  None
NOTE:
- .registry is part of 'self' (the Titan plugin frame) which works great for Titan specific plugins.
  Titan plugins create the registry as part of the frame _OnLoad.
  But this does not work for LDB buttons. The frame is created THEN the registry is added to the frame.
- Any read of the registry must assume it may not exist. Also assume the registry could be updated after this routine.
- This is called when a Titan plugin frame is created. Normally these are held until the player 'enters world' then the plugin is registered.
  Sometimes plugin frames are created after this process. Right now only LDB plugins are handled. If someone where to start creating Titan frames after the registration process were complete then it would fail to be registered...
-!For LDB plugins the 'registry' is attached to the frame AFTER the frame is created...
- The fields put into "Attempted" are defaulted here in preperation of being registered.
--]]
TitanUtils_PluginToRegister = function(self, isChildButton) end

--[[ Titan
NAME: TitanUtils_PluginFail
DESC: Place the plugin to be registered later by Titan
VAR:
- plugin - frame of the plugin (must be a Titan template)
OUT:  None
NOTE:
- This is called when a plugin is unsupported. Cuurently this is used if a LDB data object is not supported. See SupportedDOTypes in LDBToTitan.lua for more detail.
  It is intended mainly for developers. It is a place to put relevant info for debug and so users can supply troubleshooting info.
  The key is set the status to 'fail' so there is no further attempt to register the plugin.
- The results will show in "Attempted" so the developer has a shot at figuring out what was wrong.
- plugin is expected to hold as much relevant info as possible...
--]]
TitanUtils_PluginFail = function(plugin) end

--[[ Titan
NAME: TitanUtils_RegisterPlugin
DESC: Attempt to register a plugin that has requested to be registered
VAR:
- plugin - frame of the plugin (must be a Titan template)
OUT:  None
NOTE:
- Lets be extremely paranoid here because registering plugins that do not play nice can cause real headaches...
--]]
TitanUtils_RegisterPlugin = function(plugin) end

--[[ Titan
NAME: TitanUtils_RegisterPluginList
DESC: Attempt to register the list of plugins that have requested to be registered
VAR:  None
OUT:  None
NOTE:
- Tell the user when this starts and ends only on the first time.
  This could be called if a plugin requests to be registered after the first loop through.
--]]
TitanUtils_RegisterPluginList = function() end

--[[ API
NAME: TitanUtils_IsPluginRegistered
DESC: See if the given plugin was registered successfully.
VAR:
- id - id of the plugin
OUT:  None
- true (successful) or false
--]]
TitanUtils_IsPluginRegistered = function(id) end

--------------------------------------------------------------
-- Right click menu routines for Titan Panel bars

--[[ Titan
NAME: TitanUtils_CloseRightClickMenu
DESC: Close the right click menu of any plugin if it was open. Only one can be open at a time.
VAR:  None
OUT:  None
--]]
TitanUtils_CloseRightClickMenu = function() end

--[[ Titan
NAME: TitanPanelRightClickMenu_Toggle
DESC: Call the routine to build the plugin menu then place it properly.
VAR:
- self - frame of the plugin (must be a Titan template)
- isChildButton - function to create the menu
OUT:  None
NOTE:
- This routine is for Titan plugins. There is a similar routine for the Titan bar.
--]]
TitanPanelRightClickMenu_Toggle = function(self) end

--[[ Titan
NAME: TitanPanelRightClickMenu_IsVisible
DESC: Determine if a right click menu is shown. There can only be one.
VAR:  None
OUT:
- true (IsVisible) or false
--]]
TitanPanelRightClickMenu_IsVisible = function() end

--[[ Titan
NAME: TitanPanelRightClickMenu_Close
DESC: Close the right click menu if shown. There can only be one.
VAR:  None
OUT:  None
--]]
TitanPanelRightClickMenu_Close = function() end

--------------------------------------------------------------
-- Titan utility routines

--[[ Titan
NAME: TitanUtils_ParseName
DESC: Parse the player name and return the parts.
VAR:
- name - the name to break up
OUT:
- string player name only
- string realm name only
--]]
TitanUtils_ParseName = function(name) end

--[[ Titan
NAME: TitanUtils_CreateName
DESC: Given the player name and server and return the Titan name.
VAR:
- player - 1st part
- realm - 2nd part. Could be realm or 'custom'
OUT:
- string - Titan name
--]]
TitanUtils_CreateName = function(player, realm) end

--[[ Titan
NAME: TitanUtils_GetPlayer
DESC: Create the player name (toon being played) and return the parts.
VAR:  None
OUT:
- string Titan player name or nil
- string player name only
- string realm name only
--]]
TitanUtils_GetPlayer = function() end

--[[ Titan
NAME: TitanUtils_GetGlobalProfile
DESC: Return the global profile setting and the global profile name, if any.
VAR:  None
OUT:
- bool Global profile value
- string Global profile name or default
- string player name only or blank
- string realm name only or blank
--]]
TitanUtils_GetGlobalProfile = function() end

--[[ Titan
NAME: TitanUtils_SetGlobalProfile
DESC: Return the global profile setting and the global profile name, if any.
VAR:
- bool Global profile value
- string Global profile name or default
OUT:  None
--]]
TitanUtils_SetGlobalProfile = function(glob, toon) end

--[[ Titan
NAME: TitanUtils_ScreenSize
DESC: Return the screen size after scaling
VAR:
- output - boolean if true dump a lot of UI size info to chat
OUT:
- number - scaled X / width
- number - scaled Y / height
--]]
TitanUtils_ScreenSize = function(output) end

--------------------------------------------------------------
-- Various debug routines
--[[
local function Debug_array(message)
local idx = TitanDebugArray.index
	TitanDebugArray.index = mod(TitanDebugArray.index + 1, TITAN_DEBUG_ARRAY_MAX)
	TitanDebugArray.lines[TitanDebugArray.index] = (date("%m/%d/%y %H:%M:%S".." : ")..message)
end
--]]
--[[ Titan
NAME: TitanPanel_GetVersion
DESC: Get the Titan version into a string.
VAR:  None
OUT:
- string containing the version
--]]
TitanPanel_GetVersion = function() end

--[[ Titan
NAME: TitanPrint
DESC: Output a message to the user in a consistent format.
VAR:
- message - string to output
- msg_type - "info" | "warning" | "error" | "plain"
OUT:
- string - message to chat window
--]]
TitanPrint = function(message, msg_type) end

--[[ Titan
NAME: TitanDebug
DESC: Output a debug message to the user in a consistent format.
VAR:
- debug_message - string to output
- debug_type - "normal" | "warning" | "error"
OUT:
- string - message to chat window
--]]
TitanDebug = function(debug_message, debug_type) end

TitanDumpPluginList = function() end

TitanDumpPlayerList = function() end

TitanDumpFrameName = function(self) end

TitanDumpTimers = function() end

TitanArgConvert = function(event, a1, a2, a3, a4, a4, a5, a6) end

TitanDumpTable = function(tb, level) end

--------------------------------------------------------------
--
-- Deprecated routines
-- These routines will be commented out for a couple releases then deleted.
--
--[===[
--[[ API
NAME: TitanUtils_GetMinimapAdjust
DESC: Return the current setting of the Titan MinimapAdjust option.
VAR: None
OUT: The value of the MinimapAdjust option
NOTE:
-  As of DragonFlight Titan Loc no longer adjusts or manipulates the minimap.
--]]
function TitanUtils_GetMinimapAdjust() -- Used by addons
--	return not TitanPanelGetVar("MinimapAdjust")
	return false
end

--[[ API
NAME: TitanUtils_SetMinimapAdjust
DESC: Set the current setting of the Titan MinimapAdjust option.
VAR:  bool - true (off) or false (on)
OUT:  None
NOTE:
-  As of DragonFlight Titan Loc no longer adjusts or manipulates the minimap.
--]]
function TitanUtils_SetMinimapAdjust(bool) -- Used by addons
	-- This routine allows an addon to turn on or off
	-- the Titan minimap adjust.
--	TitanPanelSetVar("MinimapAdjust", not bool)
end

--[[ API
NAME: TitanUtils_AddonAdjust
DESC: Tell Titan to adjust (or not) a frame.
VAR: frame - is the name (string) of the frame
VAR: bool  - true if the addon will adjust the frame or false if Titan will adjust
OUT:  None
Note:
-- As of DragonFlight, this is no longer needed. The Titan user can user place - or not - a couple frames not user placeable,

- Titan will NOT store the adjust value across a log out / exit.
- This is a generic way for an addon to tell Titan to not adjust a frame. The addon will take responsibility for adjusting that frame. This is useful for UI style addons so the user can run Titan and a modifed UI.
- The list of frames Titan adjusts is specified in TitanMovableData within TitanMovable.lua.
- If the frame name is not in TitanMovableData then Titan does not adjust that frame.
:NOTE
--]]
function TitanUtils_AddonAdjust(frame, bool) -- Used by addons
--	TitanMovable_AddonAdjust(frame, bool)
end

function TitanUtils_IsAnyControlFrameVisible() -- need?
	for index, value in TitanPlugins do
		local frame = _G["TitanPanel"..index.."ControlFrame"];
		if (frame:IsVisible()) then
			return true;
		end
	end
	return false;
end

--]===]






-- TitanTemplate.lua ------------------------------------------------------------------------------------------

--[[ File
NAME: TitanPanelTemplate.lua
DESC: Contains the routines to handle a frame created as a Titan plugin.
--]]
--[[ API
NAME: TitanPanelTemplate overview
DESC: See TitanPanelButtonTemplate.xml also.

A Titan plugin is a frame created using one of the button types in TitanPanelButtonTemplate.xml which inherits TitanPanelButtonTemplate.
The available plugin types are:
TitanPanelTextTemplate - A frame that only displays text ("$parentText")
TitanPanelIconTemplate - A frame that only displays an icon ("$parentIcon")
TitanPanelComboTemplate - A frame that displays an icon then text ("$parentIcon"  "$parentText")

Most plugins use the combo template.

TitanPanelButtonTemplate.xml contains other templates available to be used.
TitanOptionsSliderTemplate - A frame that contains the basics of a slider control. See TitanVolume for an example.
TitanPanelChildButtonTemplate - A frame that allows a plugin within a plugin. The older version of TitanGold was an example. This may not be used anymore.

Each template contains:
- a frame to handle a menu invoked by a right mouse click ("$parentRightClickMenu")
- default event handlers for
			<OnLoad>
				TitanPanelButton_OnLoad(self);
			</OnLoad>
			<OnShow>
				TitanPanelButton_OnShow(self);
			</OnShow>
			<OnClick>
				TitanPanelButton_OnClick(self, button);
			</OnClick>
			<OnEnter>
				TitanPanelButton_OnEnter(self);
			</OnEnter>
			<OnLeave>
				TitanPanelButton_OnLeave(self);
			</OnLeave>
If these events are overridden then the default routine needs to be included!
:DESC
--]]

--[[ Titan
NAME: TitanPanel_SetScale
DESC: Set the scale of each plugin and each Titan bar.
VAR:  None
OUT:  None
--]]
TitanPanel_SetScale = function() end

--[[ Titan
NAME: TitanPanelButton_IsIcon
DESC: Is the given Titan plugin of type icon?
VAR: id - string name of the plugin
OUT: boolean
--]]
TitanPanelButton_IsIcon = function(id) end

--[[ API
NAME: TitanOptionSlider_TooltipText
DESC: Set the color of the tooltip text to normal (white) with the value in green.
VAR: text - the label for value
VAR: value - the value
OUT: string - encoded color string of text and value
--]]
TitanOptionSlider_TooltipText = function(text, value) end

--[[ API
NAME: TitanPanelButton_OnLoad
DESC: Handle the OnLoad event of the requested Titan plugin. Ensure the plugin is set to be registered.
VAR: isChildButton - boolean
NOTE:
- This is called from the Titan plugin frame in the OnLoad event - usually as the frame is created.
- This starts the plugin registration process. See TitanUtils for more details on plugin registration.
- The plugin registration is a two step process because not all addons create Titan plugins in the frame create. The Titan feature of converting LDB addons to Titan plugins is an example.
:NOTE
--]]
TitanPanelButton_OnLoad = function(self, isChildButton) end -- Used by plugins

--[[ API
NAME: TitanPanelPluginHandle_OnUpdate
DESC: A method to refresh the display of a Titan plugin.
VAR: table - the frame of the plugin
VAR: oldarg - nil or command
NOTE:
- This is used by some plugins. It is not used within Titan.
- The expected usage is either:
1) Table contains {<plugin id>, <update command>}
2) table = <plugin id> and oldarg = <update command>
- oldarg - nil or command
1 = refresh button
2 = refresh tooltip
3 = refresh button and tooltip
:NOTE
--]]
TitanPanelPluginHandle_OnUpdate = function(table, oldarg) end -- Used by plugins

--[[ API
NAME: TitanPanelDetectPluginMethod
DESC: Poorly named routine that sets the OnDragStart & OnDragStop scripts of a Titan plugin.
VAR: id - the string name of the plugin
VAR: isChildButton - boolean
--]]
TitanPanelDetectPluginMethod = function(id, isChildButton) end

--[[ API
NAME: TitanPanelButton_OnShow
DESC: Handle the OnShow event of the requested Titan plugin.
VAR:self - frame reference of the plugin
--]]
TitanPanelButton_OnShow = function(self) end -- Used by plugins

--[[ API
NAME: TitanPanelButton_OnClick
DESC: Handle the OnClick mouse event of the requested Titan plugin.
VAR: self - frame reference of the plugin
VAR: button - mouse button that was clicked
VAR: isChildButton - boolean ! NO LONGER USED !
NOTE:
- Only the left and right mouse buttons are handled by Titan.
:NOTE
--]]
TitanPanelButton_OnClick = function(self, button, isChildButton) end -- Used by plugins

--[[ API
NAME: TitanPanelButton_OnEnter
DESC: Handle the OnEnter cursor event of the requested Titan plugin.
VAR: self - frame reference of the plugin
VAR: isChildButton - boolean
NOTE:
- The cursor has moved over the plugin so show the plugin tooltip.
- Save same hassle by doing nothing if the tooltip is already shown or if the cursor is moving.
- If the "is moving" is set the user is dragging this plugin around so do nothing here.
:NOTE
--]]
TitanPanelButton_OnEnter = function(self, isChildButton) end -- Used by plugins

--[[ API
NAME: TitanPanelButton_OnLeave
DESC: Handle the OnLeave cursor event of the requested Titan plugin.
VAR: self - frame reference of the plugin
VAR: isChildButton - boolean
NOTE:
- The cursor has moved off the plugin so hide the plugin tooltip.
:NOTE
--]]
TitanPanelButton_OnLeave = function(self, isChildButton) end

--[[ API
NAME: TitanPanelButton_UpdateButton
DESC: Update the display of the given Titan plugin.
VAR: id - string name of the plugin
VAR: setButtonWidth - new width
--]]
TitanPanelButton_UpdateButton = function(id, setButtonWidth) end -- Used by plugins

--[[ API
NAME: TitanPanelButton_UpdateTooltip
DESC: Update the tooltip of the given Titan plugin.
VAR: self - frame reference of the plugin
--]]
TitanPanelButton_UpdateTooltip = function(self) end -- Used by plugins

--[[ API
NAME: TitanPanelButton_SetButtonIcon
DESC: Set the icon of the given Titan plugin.
VAR: id - string name of the plugin
VAR: iconCoords - if given, this is the placing of the icon within the plugin
VAR: iconR - if given, this is the Red (RBG) setting of the icon
VAR: iconG - if given, this is the Green (RBG) setting of the icon
VAR: iconB - if given, this is the Blue (RBG) setting of the icon
--]]
TitanPanelButton_SetButtonIcon = function(id, iconCoords, iconR, iconG, iconB) end

--[[ Titan
NAME: TitanPanelButton_GetType
DESC: Get the type of the given Titan plugin.
VAR: id - string name of the plugin
OUT: type - The type of the plugin (text, icon, combo (default))
NOTE:
- This assumes that the developer is playing nice and is using the Titan templates as is...
:NOTE
--]]
TitanPanelButton_GetType = function(id) end

--[[ Titan
NAME: TitanPanelButton_ApplyBarPos
DESC: Apply saved Bar position to the Bar frame.
VAR: frame_str - string name of the Bar frame
OUT: None
NOTE:
- Bit of a sledge hammer; used when loading a profile over the current so the Bars are properly placed.
:NOTE
--]]
TitanPanelButton_ApplyBarPos = function(frame_str) end

--[[ Titan
NAME: TitanOptionsSliderTemplate_OnLoad
DESC: Loads the Backdrop for TitanOptionsSliderTemplate with new 9.0 API
VAR: self - The frame
--]]
TitanOptionsSliderTemplate_OnLoad = function(self) end






-- TitanVariables.lua ----------------------------------------------------------------------------------------

--[[ File
NAME: TitanVariables.lua
DESC: This file contains the routines to initialize, get, and set the basic data structures used by Titan.
It also sets the global variables and constants used by Titan.

TitanBarData ^^: Titan static bar reference and placement info
TitanAll is used for settings used for Titan itself such as use global profile, tootip modifier, etc.
TitanSettings, TitanSkins, ServerTimeOffsets, ServerHourFormat are the structures saved to disk (listed in toc).
TitanSettings : is the table that holds the Titan variables by character and the plugins used by that character.
TitanSkins : holds the list of Titan and custom skins available to the user.
   It is assumed that the skins are in the proper folder on the hard drive. Blizzard does not allow addons to access the disk.
ServerTimeOffsets and ServerHourFormat: are the tables that hold the user selected hour offset and display format per realm (server).


TitanSettings has major sections with associated shortcuts in the code
TitanPlayerSettings =		TitanSettings.Players[toon]
TitanPluginSettings =		TitanSettings.Players[toon].Plugins		: Successful registered plugins with all flags
TitanPanelSettings =		TitanSettings.Players[toon].Panel		: **
TitanPanelRegister =		TitanSettings.Players[toon].Register	: .registry of all plugins (Titan and LDB) to be registered with Titan
TitanBarDataVars ^^=		TitanSettings.Players[toon].BarVars		: Titan user selected placement info
TitanAdjustSettings =			TitanSettings.Players[toon].Adjust		: List of frames Titan can adjust, vertically only

** :
- Has Plugin placement data under Location and Buttons
- Bar settings Show / Hide, transparency, skins, etc
- Per character Titan settings plugin spacing, global skin, etc

^^ :
- The index is the string name of the Titan Bar to coordinate staic and user selected bar data
:DESC
--]]

--[[ Titan
NAME: TitanVariables_SyncSinglePluginSettings
DESC: Routine to sync one plugin - current loaded (lua file) to its plugin saved vars (last save to disk).
VAR:  id : plugin name
OUT:  None
--]]
TitanVariables_SyncSinglePluginSettings = function(id) end

--[[ Titan
NAME: TitanVariables_SyncPluginSettings
DESC: Routine to sync plugin datas - current loaded (lua file) to any plugin saved vars (last save to disk).
VAR:  None
OUT:  None
--]]
TitanVariables_SyncPluginSettings = function() end

--[[ Titan
NAME: TitanVariables_InitTitanSettings
DESC: Ensure TitanSettings (one of the saved vars in the toc) exists and set the Titan version.
VAR:  None
OUT:  None
NOTE:
- Called when Titan is loaded (ADDON_LOADED event)
:NOTE
--]]
TitanVariables_InitTitanSettings = function() end

--[[ Titan
NAME: TitanVariables_SetBarPos
DESC: Update local and saved vars to new bar position per user
VAR:  self - frame to save position
OUT:  None
NOTE:
- Called when Titan is loaded (ADDON_LOADED event)
- Called when user moves or changes width of bar
- :GetPoint(1) results in incorrect values based on point used
:NOTE
--]]
TitanVariables_SetBarPos = function(self, reset, x_off, y_off, w_off) end

--[[ Titan
NAME: TitanVariables_GetBarPos
DESC: Retrieve saved vars of bar position
VAR:  frame_str - frame name to retrieve positions from
OUT:  X, Y, Width
--]]
TitanVariables_GetBarPos = function(frame_str) end

--[[ Titan
NAME: TitanVariables_GetFrameName
DESC: Build the frame name from the bar name
VAR:  bar_str - frame name to retrieve positions from
OUT:  frame string
--]]
TitanVariables_GetFrameName = function(bar_str) end

--[[ API
NAME: TitanGetVar
DESC: Get the value of the requested plugin variable.
VAR: id - the plugin name (string)
VAR: var - the name (string) of the variable
OUT:  None
NOTE:
- 'var' is from the plugin <button>.registry.savedVariables table as created in the plugin lua.
:NOTE
--]]
TitanGetVar = function(id, var) end

--[[ API
NAME: TitanVarExists
DESC: Determine if requested plugin variable exists.
VAR: id - the plugin name (string)
VAR: var - the name (string) of the variable
OUT:  None
NOTE:
- 'var' is from the plugin <button>.registry.savedVariables table as created in the plugin lua.
- This checks existence NOT false!
:NOTE
--]]
TitanVarExists = function(id, var) end

--[[ API
NAME: TitanSetVar
DESC: Get the value of the requested plugin variable to the given value.
VAR: id - the plugin name (string)
VAR: var - the name (string) of the variable
VAR: value - new value of var
OUT:  None
NOTE:
- 'var' is from the plugin <button>.registry.savedVariables table as created in the plugin lua.
:NOTE
--]]
TitanSetVar = function(id, var, value) end

--[[ API
NAME: TitanToggleVar
DESC: Toggle the value of the requested plugin variable. This assumes var value represents a boolean
VAR: id - the plugin name (string)
VAR: var - the name (string) of the variable
OUT:  None
NOTE:
- Boolean in this case could be true / false or non zero / zero or nil.
:NOTE
--]]
TitanToggleVar = function(id, var) end

--[[ API
NAME: TitanPanelGetVar
DESC: Get the value of the requested Titan variable.
VAR: var - the name (string) of the variable
OUT: value of the requested Titan variable
NOTE:
- 'var' is from the TitanPanelSettings[var].
:NOTE
--]]
TitanPanelGetVar = function(var) end

--[[ API
NAME: TitanPanelSetVar
DESC: Set the value of the requested Titan variable.
VAR: var - the name (string) of the variable
VAR: value - new value of var
OUT:  None
NOTE:
- 'var' is from the TitanPanelSettings[var].
:NOTE
--]]
TitanPanelSetVar = function(var, value) end

--[[ API
NAME: TitanPanelToggleVar
DESC: Toggle the value of the requested Titan variable. This assumes var value represents a boolean
VAR:  var - the name (string) of the variable
OUT:  None
NOTE:
- Boolean in this case could be true / false or non zero / zero or nil.
:NOTE
--]]
TitanPanelToggleVar = function(var) end

--[[ API
NAME: TitanAllGetVar
DESC: Get the value of the requested Titan global variable.
VAR: var - the name (string) of the variable
OUT: None
NOTE:
- 'var' is from the TitanAll[var].
:NOTE
--]]
TitanAllGetVar = function(var) end

--[[ API
NAME: TitanAllSetVar
DESC: Set the value of the requested Titan global variable.
VAR: var - the name (string) of the variable
VAR: value - new value of var
OUT:  None
NOTE:
- 'var' is from the TitanPanelSettings[var].
:NOTE
--]]
TitanAllSetVar = function(var, value) end

--[[ API
NAME: TitanAllToggleVar
DESC: Toggle the value of the requested Titan global variable. This assumes var value represents a boolean
VAR: var - the name (string) of the variable
OUT: None
NOTE:
- Boolean in this case could be true / false or non zero / zero or nil.
:NOTE
--]]
TitanAllToggleVar = function(var) end

--[[ API
NAME: TitanVariables_GetPanelStrata
DESC: Return the strata and the next highest strata of the given value
VAR: value - the name (string) of the strata to look up
OUT: string - Next highest strata
OUT: string - passed in strata
--]]
TitanVariables_GetPanelStrata = function(value) end

--[[ API
NAME: TitanVariables_SetPanelStrata
DESC: Set the Titan bars to the given strata and the plugins to the next highest strata.
VAR: value - strata name (string)
OUT: None
--]]
TitanVariables_SetPanelStrata = function(value) end

--[[ Titan
NAME: TitanVariables_UseSettings
DESC: Set the Titan variables and plugin variables to the passed in profile.
VAR: profile - profile to use for this toon : <name>@<server>
OUT: None
NOTE:
- Called from the Titan right click menu
- profile is compared as 'lower' so the case of profile does not matter
:NOTE
--]]
TitanVariables_UseSettings = function(profile, action) end

-- decrecated routines
--[[

function TitanGetVarTable(id, var, position)
	if (id and var and TitanPluginSettings and TitanPluginSettings[id]) then
		-- compatibility check
		if TitanPluginSettings[id][var][position] == "Titan Nil" then TitanPluginSettings[id][var][position] = false end
		return TitanUtils_Ternary(TitanPluginSettings[id][var][position] == false, nil, TitanPluginSettings[id][var][position]);
	end
end

function TitanSetVarTable(id, var, position, value)
	if (id and var and TitanPluginSettings and TitanPluginSettings[id]) then
		TitanPluginSettings[id][var][position] = TitanUtils_Ternary(value, value, false);
	end
end

--]]

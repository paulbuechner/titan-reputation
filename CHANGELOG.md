Release 9.0.1.2
	- No changes over the Beta, but make it official release
Release 9.0.1.1 beta
	- Remove bonus reputation bits since they no longer exist
Release 9.0.1.0
	- toc update for Shadowlands pre-release
Release 3.9.3
	- toc update for BFA 8.0

Release 3.9.2
	- Fixed issue with Paragon standingID & LABEL. Paragon reputations should now be legendary orange. 
	- Touched up ButtonText Labeling :: Trim values/percentage from capped factions and friends
	- Began Conversion of text to strings for future localization
	- Fixed issues with Session Summon displaying incorrectly.

Release 3.9.1
	- Added Support for Paragon Reputation
		-	Assigned Legendary Orange as Reputation color
		-	Updated Tooltip To handle Paragons
		-	Updated Button Label to handle Paragons
		-	Updated Right-Click Menu to handle Paragons.
	- Updated Right-Click Menu to colorize faction names.
	- First Pass of bug fixes for handling friendships.

Release 3.9.0
	- Converted calls to UIDropDownMenu_NOTAINT to !UIDropDownMenu
	- Implemented temporary patch for RightClick bug in Titan Panel
	- Migrated ChangeLog from TitanReputation.toc to changelog.txt

Release 3.8.8d
    - Updated for Legion V 7.1
    - Fixed broken right click menu (thanks tominator1983 ticket #26)
	 
Release 3.8.7b
    - Removed Glamour as a required dependency on curseforge. 
    - Added Glamour as an optional dependency.
	 
Release 3.8.7
	- Initial LegeonRelease
	- BugFix: added logic to TitanPanelReputation_GatherFactions function to return early when GetNumFactions() is nil. 
	    - This should resolve ticket id: 19 - Perform Arithmetic ??
	 
Release 3.8.6
	- Fixed: "Session Summary" data not displaying in tooltip.
	- Tweak: "Session Summary" each faction is now indented in the tooltip.
	- Tweak: "Session Summary" each faction is now shows perHour and perMinute stats.
	- Tweak: "Session Summary" header and session duration will only show if there is a faction reputation gain in the current session.
	- Tweak: "Show Exalted Total" is now always the last line of the tooltip when enabled.
	 
Release 3.8.5
	- Added 30 Second delay to Alerts, this prevents the New Faction Discovered announcement spam when logging in or switching chars.
	 
Release 3.8.4
	- Fixed Tooltip scaling routine to check for GameToolTip owner for proper addon compatibility: Thanks to Pankkirosvo
	- Fix for stuck saved variables that wasn't working in 3.8.3: Thanks to Pankkirosvo

Release 3.8.3
	- Fix for stuck saved variables in reference to Shadowpan-Assault Grand Commedation.

Release 3.8.2
	- Fixed incorrect notice for Shadowpan-Assault Grand Commedation.

Release 3.8.1
	- Converted "Guild" check to use factionIDs. Eliminates common problems with non-english clients continuously reverting to guild rep being displayed.
	- Added Tooltip scaling functionality in the Tooltip Options section, default is 80% which is 20% smaller than previous versions. This effects all GameTooltip calls everywhere.
	- Optimized right click menu code to generate less garbage in memory from throw away tables.
	- Added Titan Panel Right-Side plugin support to Button Options menu
	- Added "Minimal" display option to Tooltip Options which removes the TitanRep banner and extra spacing in the tooltip display.
	- Cleaned out unnecessary end of line semicolon markers, unnecessary blank space and old commented out code
	- Fixed missing CloseDropDownMenus() calls within custom functions associated with the Right Click menu
	- Fixed issues with Glamour announcements displaying the incorrect standing for Friendships
	- Adjusted Friendship coloring behavior
	- Added Tooltip options for showing/disabling friendships by rank or all friendships within the tooltip.
	- Added "Show Friendships" Button Option, disabling this will disable displaying friendship reputations on the button. (For you friend haters out there)
	- Changed all internal code to use factionID instead of factionName. should resolve some erroneous checks on non-english clients.
	- Updated announcement code to detect when a new Faction/Friendship is found and fire an announcement
	- Fixed a display issue with the Faction Upgrade/Downgrade Glamour announcement window and updated it to differentiate between friendships and factions
	- Added support for Grand Commendation detection and warning messages when once is available that you already have

Release 3.8.0
	- Updated internal routines to fully support blizzard backend changes with friendship reputations.
	- Linked ToolTip config option "Abbreviate Standings" with the right click reputation menu.

Release 3.7.7
	- Factions Headers which are also Reputations should now work for all old and future expansions. (i.e. Horde Expedition, Alliance Vanguard, The Tillers, etc...)
	- Introduced basic localization checking in an effort to make the addon function on all locales even if it's not translated for those locales. 



local _, TitanPanelReputation = ...

function TitanPanelRightClickMenu_RefreshOpenDropdown(level, shouldRefresh)
    if shouldRefresh == false or not UIDROPDOWNMENU_OPEN_MENU then
        return
    end
    local refreshLevel = level or UIDROPDOWNMENU_MENU_LEVEL or 1
    if type(UIDropDownMenu_RefreshAll) == "function" then
        UIDropDownMenu_RefreshAll(UIDROPDOWNMENU_OPEN_MENU, nil, refreshLevel)
    elseif type(UIDropDownMenu_Refresh) == "function" then
        UIDropDownMenu_Refresh(UIDROPDOWNMENU_OPEN_MENU, nil, refreshLevel)
    end
end

function TitanPanelRightClickMenu_AddTitle2(title, level)
    if (title) then
        local info = {}
        info.text = title
        info.notClickable = true
        info.isTitle = true
        info.notCheckable = true
        TitanPanelRightClickMenu_AddButton(info, level)
    end
end

function TitanPanelRightClickMenu_AddButton2(text, level, value)
    if (text) then
        local info = {}
        info.disabled = nil
        info.func = nil
        info.hasArrow = true
        info.notCheckable = true
        info.text = text
        info.value = value or text
        info.keepShownOnClick = true
        TitanPanelRightClickMenu_AddButton(info, level)
    end
end

function TitanPanelRightClickMenu_AddToggleVar2(options)
    if type(options) ~= "table" then
        return
    end

    local level = options.level or 1
    local refreshLevel = options.refreshLevel or level
    local command = {}
    command.text = options.label
    if options.value then
        command.value = options.value
    elseif options.savedVar then
        command.value = { TitanPanelReputation.ID, options.savedVar, options.toggleTable }
    end
    command.hasArrow = options.hasArrow
    command.notCheckable = options.notCheckable
    command.disabled = options.disabled
    if options.keepShownOnClick ~= nil then
        command.keepShownOnClick = options.keepShownOnClick and 1 or nil
    else
        command.keepShownOnClick = 1
    end

    if options.checked then
        command.checked = options.checked
    elseif options.savedVar then
        command.checked = function()
            return TitanGetVar(TitanPanelReputation.ID, options.savedVar)
        end
    end

    if options.func then
        command.func = options.func
    elseif options.savedVar then
        command.func = function()
            TitanPanelRightClickMenu_ToggleVar({ TitanPanelReputation.ID, options.savedVar, options.toggleTable })
            TitanPanelButton_UpdateButton(TitanPanelReputation.ID)
            TitanPanelRightClickMenu_RefreshOpenDropdown(refreshLevel)
        end
    end

    TitanPanelRightClickMenu_AddButton(command, level)
end

function TitanPanelRightClickMenu_AddSpacer2(level)
    local info = {}
    info.disabled = true
    info.notCheckable = true
    TitanPanelRightClickMenu_AddButton(info, level)
end

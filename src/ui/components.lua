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

function TitanPanelRightClickMenu_AddToggleVar2(text, id, var, toggleTable, level, noclose)
    if not level then level = 2 end
    local info = {}
    info.text = text
    info.value = { id, var, toggleTable }
    if noclose then
        info.func = function()
            TitanPanelRightClickMenu_ToggleVar({ id, var, toggleTable })
        end
    else
        info.func = function()
            TitanPanelRightClickMenu_ToggleVar({ id, var, toggleTable })
            TitanPanelRightClickMenu_Close()
        end
    end
    info.checked = TitanGetVar(id, var)
    TitanPanelRightClickMenu_AddButton(info, level)
end

function TitanPanelRightClickMenu_AddSpacer2(level)
    local info = {}
    info.disabled = true
    info.notCheckable = true
    TitanPanelRightClickMenu_AddButton(info, level)
end

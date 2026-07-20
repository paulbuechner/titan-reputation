local _, TitanPanelReputation = ...

-- Skins the reputation toast to match the flat look AddOnSkins/ElvUI give Blizzard's
-- own achievement alerts. Both addons only restyle Blizzard's named alert subsystems,
-- so our private subsystem (achievement-popup.lua) has to opt in itself.
--
-- Provider priority: AddOnSkins (own 'TitanReputation' toggle in its options) wins when
-- installed; otherwise an ElvUI fallback follows ElvUI's BlizzardSkins > Alert Frames
-- setting. Either provider only stores TitanPanelReputation.SkinAchievementAlert - the
-- actual skinning runs at the end of SetupFrame on every show, because pooled frames get
-- the Blizzard art re-applied each time (only backdrops/hooks are created once).

local function ForceAlpha(self, alpha, forced)
    if alpha ~= 1 and forced ~= true then
        self:SetAlpha(1, true)
    end
end

--[[ ------------------------------ AddOnSkins ------------------------------ ]]

local function TryAddOnSkins()
    local Engine = _G.AddOnSkins
    if not Engine then return false end

    local AS, _, S = unpack(Engine)

    -- Mirrors SkinAchievementAlert from AddOnSkins/Skins/Mainline/Alerts.lua.
    local function SkinStandingAlert(frame)
        frame:SetAlpha(1)

        if not frame.hooked then
            hooksecurefunc(frame, "SetAlpha", ForceAlpha)
            frame.hooked = true
        end

        if not frame.backdrop then
            S:CreateBackdrop(frame)
            S:Point(frame.backdrop, "TOPLEFT", frame.Background, "TOPLEFT", -2, -6)
            S:Point(frame.backdrop, "BOTTOMRIGHT", frame.Background, "BOTTOMRIGHT", -2, 6)
        end

        -- Background
        frame.Background:SetTexture()
        S:Kill(frame.glow)
        S:Kill(frame.shine)
        S:Kill(frame.GuildBanner)
        S:Kill(frame.GuildBorder)

        -- Text
        S:FontTemplate(frame.Unlocked, nil, 12)
        frame.Unlocked:SetTextColor(1, 1, 1)
        S:FontTemplate(frame.Name, nil, 12)

        -- Icon
        S:HandleIcon(frame.Icon.Texture, true, true)
        S:Kill(frame.Icon.Overlay)

        frame.Icon.Texture:ClearAllPoints()
        S:Point(frame.Icon.Texture, "LEFT", frame, 7, 0)
    end

    -- AddOnSkins runs this at PLAYER_ENTERING_WORLD, gated by our options toggle.
    AS:RegisterSkin("TitanReputation", function()
        TitanPanelReputation.SkinAchievementAlert = SkinStandingAlert
    end)

    -- AddOnSkins builds its profile defaults at its own ADDON_LOADED, before load
    -- order lets us register, so seed our toggle to enabled on first use.
    if AS.db and AS.db.TitanReputation == nil then
        AS.db.TitanReputation = true
    end

    return true
end

--[[ -------------------------------- ElvUI --------------------------------- ]]

local function TryElvUI()
    if not _G.ElvUI then return false end

    -- E.private is populated during ElvUI's PLAYER_LOGIN initialization, so the
    -- settings check has to wait for PLAYER_ENTERING_WORLD.
    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    watcher:SetScript("OnEvent", function(self)
        self:UnregisterAllEvents()

        local E = unpack(_G.ElvUI)
        local skins = E and E.private and E.private.skins
        if not (skins and skins.blizzard and skins.blizzard.enable and skins.blizzard.alertframes) then
            return -- ElvUI leaves its own achievement toasts unskinned too
        end

        -- Mirrors SkinAchievementAlert from ElvUI/Game/Mainline/Skins/Alerts.lua using
        -- ElvUI's frame API extensions (available on all frames once ElvUI is loaded).
        TitanPanelReputation.SkinAchievementAlert = function(frame)
            frame:SetAlpha(1)

            if not frame.hooked then
                hooksecurefunc(frame, "SetAlpha", ForceAlpha)
                frame.hooked = true
            end

            if not frame.backdrop then
                frame:CreateBackdrop("Transparent")
                frame.backdrop:Point("TOPLEFT", frame.Background, "TOPLEFT", -2, -6)
                frame.backdrop:Point("BOTTOMRIGHT", frame.Background, "BOTTOMRIGHT", -2, 6)
            end

            -- Background
            frame.Background:SetTexture()
            frame.glow:Kill()
            frame.shine:Kill()
            frame.GuildBanner:Kill()
            frame.GuildBorder:Kill()

            -- Text
            frame.Unlocked:FontTemplate(nil, 12)
            frame.Unlocked:SetTextColor(1, 1, 1)
            frame.Name:FontTemplate(nil, 12)

            -- Icon
            local icon = frame.Icon
            if icon then
                icon.Overlay:Kill()

                local texture = icon.Texture
                if texture then
                    texture:SetTexCoords()
                    texture:ClearAllPoints()
                    texture:Point("LEFT", frame, 7, 0)

                    if not icon.backdrop then
                        icon:CreateBackdrop()
                        icon.backdrop:SetOutside(texture)
                    end
                end
            end
        end
    end)

    return true
end

if not TryAddOnSkins() then
    TryElvUI()
end

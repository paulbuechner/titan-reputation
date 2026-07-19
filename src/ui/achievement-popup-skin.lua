local _, TitanPanelReputation = ...

-- AddOnSkins integration: registers a 'TitanReputation' skin so the reputation
-- toast gets its own toggle in the AddOnSkins options (Skins > AddOns),
-- independent of the bundled 'Titan' bar skin.
-- AddOnSkins/ElvUI only restyle Blizzard's own alert subsystems, so our
-- private subsystem (achievement-popup.lua) has to opt in itself.
local Engine = _G.AddOnSkins
if not Engine then return end

local AS, _, S = unpack(Engine)

local function ForceAlpha(self, alpha, forced)
    if alpha ~= 1 and forced ~= true then
        self:SetAlpha(1, true)
    end
end

-- Mirrors SkinAchievementAlert from AddOnSkins/Skins/Mainline/Alerts.lua.
-- Runs after every SetupFrame call because pooled frames get the Blizzard art
-- re-applied on each show; only the backdrop and hooks are created once.
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
-- The actual skinning is deferred to SetupFrame so the alert subsystem (and
-- Blizzard_AchievementUI) stays lazily created.
AS:RegisterSkin("TitanReputation", function()
    TitanPanelReputation.SkinAchievementAlert = SkinStandingAlert
end)

-- AddOnSkins builds its profile defaults at its own ADDON_LOADED, before load
-- order lets us register, so seed our toggle to enabled on first use.
if AS.db and AS.db.TitanReputation == nil then
    AS.db.TitanReputation = true
end

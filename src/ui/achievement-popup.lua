local _, TitanPanelReputation = ...

local WoW3 = select(4, GetBuildInfo()) >= 30000
local WoW10 = select(4, GetBuildInfo()) >= 100000

local TextureKitConstants = _G.TextureKitConstants

local function EnsureAchievementUI()
    if not _G.AchievementFrame and _G.AchievementFrame_LoadUI then
        _G.AchievementFrame_LoadUI()
    end
end

local function GetAchievementAlertSystem()
    -- No achievements / no achievement toast system before WotLK.
    if not WoW3 then
        return nil
    end
    if not _G.AlertFrame or type(_G.AlertFrame.AddQueuedAlertFrameSubSystem) ~= "function" then
        return nil
    end

    if TitanPanelReputation.AchievementAlertSystem then
        return TitanPanelReputation.AchievementAlertSystem
    end

    -- Make sure the AchievementFrame is loaded to access AlertFrame methods
    EnsureAchievementUI()

    local function SetupFrame(frame, payload)
        local displayName = frame.Name
        local shieldPoints = frame.Shield.Points;
        local shieldIcon = frame.Shield.Icon;
        local unlocked = frame.Unlocked;

        local standing = payload.standingText
        if standing and standing ~= "" then
            displayName:SetText(string.format("%s: %s", payload.text or "", standing))
        else
            displayName:SetText(payload.text or "")
        end

        unlocked:SetText(payload.title or ACHIEVEMENT_UNLOCKED)

        AchievementShield_SetPoints(0, shieldPoints, GameFontNormal, GameFontNormalSmall);

        if WoW10 then
            -- Retail UI
            -- https://github.com/Gethe/wow-ui-source/blob/main/Interface/AddOns/Blizzard_FrameXML/Mainline/AlertFrameSystems.lua
            unlocked:SetPoint("TOP", 7, -23);

            shieldPoints:Show();
            shieldIcon:Show();
            frame:SetHeight(101);
            local background = frame.Background;
            background:SetAtlas("ui-achievement-alert-background", TextureKitConstants.UseAtlasSize);
            local iconBorder = frame.Icon.Overlay;
            iconBorder:SetAtlas("ui-achievement-iconframe", TextureKitConstants.UseAtlasSize);
            iconBorder:SetPoint("CENTER", -1, 1);
            frame.Icon:SetPoint("TOPLEFT", -4, -15);
            frame.Shield:SetPoint("TOPRIGHT", -8, -15);
            shieldPoints:SetPoint("CENTER", 2, -2);
            shieldPoints:SetVertexColor(1, 1, 1);
            unlocked:SetPoint("TOP", 7, -23);
            unlocked:SetText(ACHIEVEMENT_UNLOCKED);
            frame.GuildName:Hide();
            frame.GuildBorder:Hide();
            frame.GuildBanner:Hide();
            frame.glow:SetAtlas("ui-achievement-glow-glow", TextureKitConstants.UseAtlasSize);
            frame.shine:SetAtlas("ui-achievement-glow-shine", TextureKitConstants.UseAtlasSize);
            frame.shine:SetPoint("BOTTOMLEFT", 0, 8);

            shieldIcon:SetAtlas("UI-Achievement-Shield-NoPoints", TextureKitConstants.UseAtlasSize);
        else
            -- Classic UI
            -- https://github.com/Gethe/wow-ui-source/blob/classic/Interface/AddOns/Blizzard_FrameXML/Classic/AlertFrameSystems.lua
            frame.oldCheevo = nil
            shieldPoints:Show();
            shieldIcon:Show();
            frame:SetHeight(88);
            local background = frame.Background;
            background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Background");
            background:SetTexCoord(0, 0.605, 0, 0.703);
            background:SetPoint("TOPLEFT", 0, 0);
            background:SetPoint("BOTTOMRIGHT", 0, 0);
            local iconBorder = frame.Icon.Overlay;
            iconBorder:SetTexture("Interface\\AchievementFrame\\UI-Achievement-IconFrame");
            iconBorder:SetTexCoord(0, 0.5625, 0, 0.5625);
            iconBorder:SetPoint("CENTER", -1, 2);
            frame.Icon:SetPoint("TOPLEFT", -26, 16);
            displayName:SetPoint("BOTTOMLEFT", 72, 36);
            displayName:SetPoint("BOTTOMRIGHT", -60, 36);
            frame.Shield:SetPoint("TOPRIGHT", -10, -13);
            shieldPoints:SetPoint("CENTER", 7, 2);
            shieldPoints:SetVertexColor(1, 1, 1);
            shieldIcon:SetTexCoord(0, 0.5, 0, 0.45);
            unlocked:SetPoint("TOP", 7, -23);
            frame.GuildName:Hide();
            frame.GuildBorder:Hide();
            frame.GuildBanner:Hide();
            frame.glow:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Glow");
            frame.glow:SetTexCoord(0, 0.78125, 0, 0.66796875);
            frame.shine:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Glow");
            frame.shine:SetTexCoord(0.78125, 0.912109375, 0, 0.28125);
            frame.shine:SetPoint("BOTTOMLEFT", 0, 8);

            shieldIcon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields-NoPoints]]);
        end

        frame.Icon.Texture:SetTexture(payload.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        frame:EnableMouse(true)
        frame.id = payload.factionID;
        return true;
    end

    TitanPanelReputation.AchievementAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("AchievementAlertFrameTemplate", SetupFrame, 2, 6)
    if WoW10 then
        TitanPanelReputation.AchievementAlertSystem:SetCanShowMoreConditionFunc(function() return not C_PetBattles.IsInBattle() end)
    else
        TitanPanelReputation.AchievementAlertSystem:SetCanShowMoreConditionFunc(function() return true end);
    end

    return TitanPanelReputation.AchievementAlertSystem
end

function TitanPanelReputation:ShowStandingAchievement(payload)
    local system = GetAchievementAlertSystem()
    if not system then return end
    if not payload then return end
    system:AddAlert(payload)
    PlaySound(12891)
end

local _, TitanPanelReputation = ...

local TextureKitConstants = _G.TextureKitConstants

if not _G.AchievementFrame then _G.AchievementFrame_LoadUI() end

local AlertFrame = _G.AlertFrame
local AchievementShield_SetPoints = _G.AchievementShield_SetPoints

local function GetAchievementAlertSystem()
    if TitanPanelReputation.AchievementAlertSystem then
        return TitanPanelReputation.AchievementAlertSystem
    end

    local function SetupFrame(frame, payload)
        if not payload or type(payload) ~= "table" then
            return
        end

        local displayName = frame.Name
        local shieldPoints = frame.Shield.Points
        local shieldIcon = frame.Shield.Icon
        local unlocked = frame.Unlocked
        local oldCheevo = frame.OldAchievement

        local standing = payload.standingText
        if standing and standing ~= "" then
            displayName:SetText(string.format("%s: %s", payload.text or "", standing))
        else
            displayName:SetText(payload.text or "")
        end

        unlocked:SetText(payload.title or ACHIEVEMENT_UNLOCKED)
        frame.Icon.Texture:SetTexture(payload.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        frame:EnableMouse(false)

        AchievementShield_SetPoints(0, shieldPoints, GameFontNormal, GameFontNormalSmall)

        if frame.guildDisplay or frame.oldCheevo then
            frame.oldCheevo = nil
            shieldPoints:Show()
            shieldIcon:Show()
            oldCheevo:Hide()
            frame.guildDisplay = nil
            frame:SetHeight(104)
            local background = frame.Background
            background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Background")
            background:SetTexCoord(0, 0.605, 0, 0.703)
            background:SetPoint("TOPLEFT", 0, 0)
            background:SetPoint("BOTTOMRIGHT", 0, 0)
            local iconBorder = frame.Icon.Overlay
            iconBorder:SetAtlas("ui-achievement-guild-iconframe", TextureKitConstants.UseAtlasSize)
            iconBorder:SetPoint("CENTER", -1, 2)
            frame.Icon:SetPoint("TOPLEFT", -26, 16)
            displayName:SetPoint("BOTTOMLEFT", 72, 36)
            displayName:SetPoint("BOTTOMRIGHT", -60, 36)
            frame.Shield:SetPoint("TOPRIGHT", -10, -13)
            shieldPoints:SetPoint("CENTER", 7, 2)
            shieldPoints:SetVertexColor(1, 1, 1)
            shieldIcon:SetTexCoord(0, 0.5, 0, 0.45)
            unlocked:SetPoint("TOP", 7, -23)
            frame.GuildName:Hide()
            frame.GuildBorder:Hide()
            frame.GuildBanner:Hide()
            frame.glow:SetAtlas("ui-achievement-guild-glow", TextureKitConstants.UseAtlasSize)
            frame.shine:SetAtlas("ui-achievement-guild-shine", TextureKitConstants.UseAtlasSize)
            frame.shine:SetPoint("BOTTOMLEFT", 0, 8)
        end

        shieldIcon:SetAtlas("UI-Achievement-Shield-NoPoints", TextureKitConstants.UseAtlasSize)

        C_Timer.After(10, function()
            unlocked:SetText(ACHIEVEMENT_UNLOCKED)
            frame:EnableMouse(true)
        end)

        frame.id = payload.factionID

        return true
    end

    TitanPanelReputation.AchievementAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem(
        "AchievementAlertFrameTemplate",
        SetupFrame,
        2,
        6
    )

    TitanPanelReputation.AchievementAlertSystem:SetCanShowMoreConditionFunc(function()
        return not (C_PetBattles and C_PetBattles.IsInBattle and C_PetBattles.IsInBattle())
    end)

    return TitanPanelReputation.AchievementAlertSystem
end

function TitanPanelReputation:ShowStandingAchievement(payload)
    local system = GetAchievementAlertSystem()
    if not payload then return end
    system:AddAlert(payload)
    PlaySound(12891)
end

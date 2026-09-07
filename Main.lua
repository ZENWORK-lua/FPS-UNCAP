-- HYPER|HUB - Ultimate iOS Fluid UI v16 (Save Engine & Core Fixes)
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local env = (getgenv and getgenv()) or _G
local function getSafeGuiParent()
    local p = nil; if gethui then pcall(function() p = gethui() end) end
    if not p then pcall(function() p = game:GetService("CoreGui") end) end
    if not p or not pcall(function() local _ = p.Name end) then p = Players.LocalPlayer:WaitForChild("PlayerGui") end
    return p
end
local targetGui = getSafeGuiParent()

if env.SYROX_RUNNING and targetGui:FindFirstChild("FPSCapUI") then
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = "HYPERWORK", Text = "Script is already running, you can restart from settings.", Duration = 5}) end)
    return
end

if env.FPSCapUIConnections then for _, c in ipairs(env.FPSCapUIConnections) do if c and c.Connected then c:Disconnect() end end end
if targetGui:FindFirstChild("FPSCapUI") then targetGui.FPSCapUI:Destroy() end
env.FPSCapUIConnections = {}; local connections = env.FPSCapUIConnections
env.SYROX_RUNNING = true; env.SYROX_ORIGINAL_FFLAGS = {}


env.HYPER_SAVE = {Remember = false, Toggles = {}, Switches = {}}
if isfile and readfile and isfile("HYPER_HUB.json") then
    pcall(function() env.HYPER_SAVE = HttpService:JSONDecode(readfile("HYPER_HUB.json")) end)
end
if not env.HYPER_SAVE.Toggles then env.HYPER_SAVE.Toggles = {} end
if not env.HYPER_SAVE.Switches then env.HYPER_SAVE.Switches = {} end
env.saveHubData = function()
    if env.HYPER_SAVE.Remember and writefile then
        pcall(function() writefile("HYPER_HUB.json", HttpService:JSONEncode(env.HYPER_SAVE)) end)
    end
end

local origSettings = {
    GlobalShadows = Lighting.GlobalShadows, QualityLevel = settings().Rendering.QualityLevel,
    WaterWaveSize = workspace.Terrain.WaterWaveSize, WaterWaveSpeed = workspace.Terrain.WaterWaveSpeed, WaterReflectance = workspace.Terrain.WaterReflectance
}
local MIN_FPS, MAX_FPS = 5, 500; local currentTargetFps = setfpscap and 120 or 60

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FPSCapUI"; screenGui.ResetOnSpawn = false; screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local afkScreen = Instance.new("Frame")
afkScreen.Size = UDim2.new(1, 0, 1, 0); afkScreen.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
afkScreen.ZIndex = 999; afkScreen.Visible = false; afkScreen.Parent = screenGui
local afkText = Instance.new("TextLabel")
afkText.Size = UDim2.new(1, 0, 1, 0); afkText.BackgroundTransparency = 1; afkText.Font = Enum.Font.GothamBold
afkText.Text = "AFK Optimization activated.\nClick anywhere to stop"; afkText.TextColor3 = Color3.fromRGB(20, 20, 20); afkText.TextSize = 24; afkText.Parent = afkScreen

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"; mainFrame.Size = UDim2.new(0, 0, 0, 0); mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5); mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BackgroundTransparency = 0.25; mainFrame.BorderSizePixel = 0; mainFrame.Active = true; mainFrame.ClipsDescendants = false; mainFrame.Parent = screenGui

local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 52)), ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))})
bgGradient.Rotation = 45; bgGradient.Parent = mainFrame
local uiCorner = Instance.new("UICorner"); uiCorner.CornerRadius = UDim.new(1, 0); uiCorner.Parent = mainFrame

local introText = Instance.new("TextLabel")
introText.Size = UDim2.new(1, 0, 1, 0); introText.BackgroundTransparency = 1; introText.Font = Enum.Font.GothamBold
introText.Text = "HYPER|HUB"; introText.TextColor3 = Color3.fromRGB(255, 255, 255); introText.TextSize = 17; introText.TextTransparency = 1; introText.Parent = mainFrame
local outerAura = Instance.new("Frame"); outerAura.Size = UDim2.new(1, 6, 1, 6); outerAura.Position = UDim2.new(0.5, 0, 0.5, 0); outerAura.AnchorPoint = Vector2.new(0.5, 0.5); outerAura.BackgroundTransparency = 1; outerAura.Parent = mainFrame
Instance.new("UICorner", outerAura).CornerRadius = UDim.new(0, 19)
local auraStroke = Instance.new("UIStroke"); auraStroke.Color = Color3.fromRGB(0, 162, 255); auraStroke.Thickness = 1.2; auraStroke.Transparency = 1; auraStroke.Parent = outerAura

-- FİXLENMİŞ İZOLE HITBOX (Sadece Ortayı Kaplar)
local headerPillTouch = Instance.new("TextButton")
headerPillTouch.Size = UDim2.new(0, 150, 0, 32); headerPillTouch.Position = UDim2.new(0.5, 0, 0, 0); headerPillTouch.AnchorPoint = Vector2.new(0.5, 0)
headerPillTouch.BackgroundTransparency = 1; headerPillTouch.Text = ""; headerPillTouch.ZIndex = 50; headerPillTouch.Parent = mainFrame
local headerPill = Instance.new("Frame")
headerPill.Size = UDim2.new(0, 50, 0, 5); headerPill.Position = UDim2.new(0.5, 0, 0, 12); headerPill.AnchorPoint = Vector2.new(0.5, 0.5)
headerPill.BackgroundColor3 = Color3.fromRGB(255, 255, 255); headerPill.BackgroundTransparency = 1; headerPill.ZIndex = 1; headerPill.Parent = mainFrame
Instance.new("UICorner", headerPill).CornerRadius = UDim.new(1, 0)
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, 0, 1, 0); contentContainer.BackgroundTransparency = 1; contentContainer.ClipsDescendants = true; contentContainer.Visible = false; contentContainer.Parent = mainFrame

local infoOverlay = Instance.new("Frame")
infoOverlay.Size = UDim2.new(1, 0, 1, 0); infoOverlay.BackgroundColor3 = Color3.fromRGB(15, 15, 20); infoOverlay.BackgroundTransparency = 0.1
infoOverlay.ZIndex = 60; infoOverlay.Visible = false; infoOverlay.Parent = mainFrame
Instance.new("UICorner", infoOverlay).CornerRadius = UDim.new(0, 16)
local infoBody = Instance.new("TextLabel")
infoBody.Size = UDim2.new(1, -20, 1, -50); infoBody.Position = UDim2.new(0, 10, 0, 10); infoBody.BackgroundTransparency = 1
infoBody.Font = Enum.Font.SourceSansBold; infoBody.TextWrapped = true; infoBody.TextColor3 = Color3.fromRGB(240, 240, 250); infoBody.TextSize = 13
infoBody.Text = "Information:\n\nTo close the script:\nFirst minimize the menu, then double-tap the circle icon."; infoBody.Parent = infoOverlay
local btnCloseInfo = Instance.new("TextButton")
btnCloseInfo.Size = UDim2.new(0, 160, 0, 28); btnCloseInfo.Position = UDim2.new(0.5, -80, 1, -38); btnCloseInfo.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
btnCloseInfo.BackgroundTransparency = 0.3; btnCloseInfo.Font = Enum.Font.SourceSansBold; btnCloseInfo.Text = "Close this information"; btnCloseInfo.TextColor3 = Color3.fromRGB(255, 255, 255); btnCloseInfo.TextSize = 12; btnCloseInfo.Parent = infoOverlay
Instance.new("UICorner", btnCloseInfo).CornerRadius = UDim.new(0, 8)

local mainPage = Instance.new("Frame"); mainPage.Size = UDim2.new(1, 0, 1, 0); mainPage.BackgroundTransparency = 1; mainPage.Parent = contentContainer
local themePage = Instance.new("Frame"); themePage.Size = UDim2.new(1, 0, 1, 0); themePage.BackgroundTransparency = 1; themePage.Visible = false; themePage.Parent = contentContainer
local settingsPage = Instance.new("Frame"); settingsPage.Size = UDim2.new(1, 0, 1, 0); settingsPage.BackgroundTransparency = 1; settingsPage.Visible = false; settingsPage.Parent = contentContainer
local confirmPage = Instance.new("Frame"); confirmPage.Size = UDim2.new(1, 0, 1, 0); confirmPage.BackgroundTransparency = 1; confirmPage.Visible = false; confirmPage.Parent = contentContainer
local fadeCurtain = Instance.new("Frame"); fadeCurtain.Size = UDim2.new(1, 0, 1, 0); fadeCurtain.BackgroundColor3 = Color3.fromRGB(10, 10, 15); fadeCurtain.BackgroundTransparency = 1; fadeCurtain.ZIndex = 10; fadeCurtain.Parent = contentContainer
Instance.new("UICorner", fadeCurtain).CornerRadius = UDim.new(0, 16)

local btnTheme = Instance.new("ImageButton"); btnTheme.Size = UDim2.new(0, 20, 0, 20); btnTheme.Position = UDim2.new(1, -60, 0, 18); btnTheme.BackgroundTransparency = 1; btnTheme.Image = "rbxassetid://3926305904"; btnTheme.ImageRectOffset = Vector2.new(764, 244); btnTheme.ImageRectSize = Vector2.new(36, 36); btnTheme.ImageColor3 = Color3.fromRGB(255, 255, 255); btnTheme.ImageTransparency = 0.3; btnTheme.ZIndex = 11; btnTheme.Parent = contentContainer
local btnSettings = Instance.new("ImageButton"); btnSettings.Size = UDim2.new(0, 20, 0, 20); btnSettings.Position = UDim2.new(1, -34, 0, 18); btnSettings.BackgroundTransparency = 1; btnSettings.Image = "rbxassetid://3926307971"; btnSettings.ImageRectOffset = Vector2.new(324, 124); btnSettings.ImageRectSize = Vector2.new(36, 36); btnSettings.ImageColor3 = Color3.fromRGB(255, 255, 255); btnSettings.ImageTransparency = 0.3; btnSettings.ZIndex = 11; btnSettings.Parent = contentContainer

local titleLabel = Instance.new("TextLabel"); titleLabel.Size = UDim2.new(1, -24, 0, 22); titleLabel.Position = UDim2.new(0, 12, 0, 20); titleLabel.BackgroundTransparency = 1; titleLabel.Font = Enum.Font.SourceSansBold; titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240); titleLabel.TextSize = 15; titleLabel.TextXAlignment = Enum.TextXAlignment.Left; titleLabel.Text = string.format("Target FPS: %d FPS", currentTargetFps); titleLabel.Parent = mainPage
local effectBarBg = Instance.new("Frame"); effectBarBg.Size = UDim2.new(1, -24, 0, 5); effectBarBg.Position = UDim2.new(0, 12, 0, 66); effectBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50); effectBarBg.BackgroundTransparency = 0.3; effectBarBg.BorderSizePixel = 0; effectBarBg.Parent = mainPage; Instance.new("UICorner", effectBarBg).CornerRadius = UDim.new(1, 0)
local sliderTrack = Instance.new("Frame"); sliderTrack.Size = UDim2.new(1, -24, 0, 6); sliderTrack.Position = UDim2.new(0, 12, 0, 85); sliderTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 55); sliderTrack.BorderSizePixel = 0; sliderTrack.Parent = mainPage; Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(1, 0)
local initialRatio = math.clamp((currentTargetFps - MIN_FPS) / (MAX_FPS - MIN_FPS), 0, 1)
local effectBarGlow = Instance.new("Frame"); effectBarGlow.Size = UDim2.new(initialRatio, 0, 1, 0); effectBarGlow.BackgroundColor3 = Color3.fromRGB(0, 162, 255); effectBarGlow.Parent = effectBarBg; Instance.new("UICorner", effectBarGlow).CornerRadius = UDim.new(1, 0)
local sliderFill = Instance.new("Frame"); sliderFill.Size = UDim2.new(initialRatio, 0, 1, 0); sliderFill.BackgroundColor3 = Color3.fromRGB(0, 162, 255); sliderFill.Parent = sliderTrack; Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
local sliderKnob = Instance.new("Frame"); sliderKnob.Size = UDim2.new(0, 18, 0, 18); sliderKnob.Position = UDim2.new(initialRatio, -9, 0.5, -9); sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); sliderKnob.Parent = sliderTrack; Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
local fpsDisplay = Instance.new("TextLabel"); fpsDisplay.Size = UDim2.new(1, -24, 0, 18); fpsDisplay.Position = UDim2.new(0, 12, 0, 42); fpsDisplay.BackgroundTransparency = 1; fpsDisplay.Font = Enum.Font.SourceSansSemibold; fpsDisplay.TextColor3 = Color3.fromRGB(160, 160, 175); fpsDisplay.TextSize = 13; fpsDisplay.TextXAlignment = Enum.TextXAlignment.Left; fpsDisplay.Text = "Current FPS: 0"; fpsDisplay.Parent = mainPage

-- FİXLENMİŞ SONSUZ KAYDIRMA
local stabTitle = Instance.new("TextLabel"); stabTitle.Size = UDim2.new(1, -24, 0, 16); stabTitle.Position = UDim2.new(0, 12, 0, 110); stabTitle.BackgroundTransparency = 1; stabTitle.Font = Enum.Font.SourceSansBold; stabTitle.Text = "FEATURES (SWIPE RIGHT ->)"; stabTitle.TextColor3 = Color3.fromRGB(0, 200, 255); stabTitle.TextSize = 11; stabTitle.TextXAlignment = Enum.TextXAlignment.Left; stabTitle.Parent = mainPage
local scrollFrame = Instance.new("ScrollingFrame"); scrollFrame.Size = UDim2.new(1, -24, 0, 65); scrollFrame.Position = UDim2.new(0, 12, 0, 130); scrollFrame.BackgroundTransparency = 1; scrollFrame.BorderSizePixel = 0; scrollFrame.ScrollBarThickness = 0; scrollFrame.ScrollingDirection = Enum.ScrollingDirection.X
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.X; scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0); scrollFrame.Parent = mainPage -- YENİ (OTOMATİK LİMİT)
local gridLayout = Instance.new("UIGridLayout"); gridLayout.CellSize = UDim2.new(0, 115, 0, 28); gridLayout.CellPadding = UDim2.new(0, 8, 0, 8); gridLayout.FillDirection = Enum.FillDirection.Vertical; gridLayout.Parent = scrollFrame

local segmentBg = Instance.new("Frame")
segmentBg.Size = UDim2.new(0, 160, 0, 26); segmentBg.Position = UDim2.new(0, 12, 0, 14)
segmentBg.BackgroundColor3 = Color3.fromRGB(25, 25, 30); segmentBg.Parent = settingsPage
Instance.new("UICorner", segmentBg).CornerRadius = UDim.new(1, 0)
local segmentSlider = Instance.new("Frame")
segmentSlider.Size = UDim2.new(0, 95, 1, -4); segmentSlider.Position = UDim2.new(0, 2, 0, 2)
segmentSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70); segmentSlider.Parent = segmentBg
Instance.new("UICorner", segmentSlider).CornerRadius = UDim.new(1, 0)

local btnSysTab = Instance.new("TextButton")
btnSysTab.Size = UDim2.new(0, 95, 1, 0); btnSysTab.Position = UDim2.new(0, 0, 0, 0)
btnSysTab.BackgroundTransparency = 1; btnSysTab.Font = Enum.Font.SourceSansBold; btnSysTab.Text = "SYSTEM"
btnSysTab.TextColor3 = Color3.fromRGB(255, 255, 255); btnSysTab.TextSize = 11; btnSysTab.Parent = segmentBg
local btnFeatTab = Instance.new("TextButton")
btnFeatTab.Size = UDim2.new(0, 65, 1, 0); btnFeatTab.Position = UDim2.new(0, 95, 0, 0)
btnFeatTab.BackgroundTransparency = 1; btnFeatTab.Font = Enum.Font.SourceSansBold; btnFeatTab.Text = "MORE"
btnFeatTab.TextColor3 = Color3.fromRGB(150, 150, 160); btnFeatTab.TextSize = 11; btnFeatTab.Parent = segmentBg

local sysScroll = Instance.new("ScrollingFrame"); sysScroll.Size = UDim2.new(1, -24, 0, 140); sysScroll.Position = UDim2.new(0, 12, 0, 55); sysScroll.BackgroundTransparency = 1; sysScroll.BorderSizePixel = 0; sysScroll.ScrollBarThickness = 0; sysScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; sysScroll.CanvasSize = UDim2.new(0, 0, 0, 0); sysScroll.Parent = settingsPage
local featScroll = Instance.new("ScrollingFrame"); featScroll.Size = UDim2.new(1, -24, 0, 140); featScroll.Position = UDim2.new(0, 12, 0, 55); featScroll.BackgroundTransparency = 1; featScroll.BorderSizePixel = 0; featScroll.ScrollBarThickness = 0; featScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; featScroll.CanvasSize = UDim2.new(0, 0, 0, 0); featScroll.Visible = false; featScroll.Parent = settingsPage
Instance.new("UIListLayout", sysScroll).Padding = UDim.new(0, 10); Instance.new("UIListLayout", featScroll).Padding = UDim.new(0, 10)
local globalAccentColor = Color3.fromRGB(0, 162, 255)
local activeModules = {}
local function createBtn(name, text, p)
    local btn = Instance.new("TextButton"); btn.Name = name; btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40); btn.BackgroundTransparency = 0.3; btn.Font = Enum.Font.SourceSansBold; btn.Text = text; btn.TextColor3 = Color3.fromRGB(200, 200, 210); btn.TextSize = 11; btn.Parent = p or scrollFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local str = Instance.new("UIStroke", btn); str.Color = Color3.fromRGB(255, 255, 255); str.Thickness = 1; str.Transparency = 0.8
    activeModules[name] = {Btn = btn, Stroke = str, IsActive = false}; return btn, str
end

local btnRejoin = createBtn("BtnRejoin", "REJOIN SERVER")
local btnGfxLvl = createBtn("BtnGfx", "GFX LVL: AUTO"); local btnLowGfx = createBtn("BtnLowGfx", "LOW GFX: OFF")
local btnShadows = createBtn("BtnShadows", "SHADOWS: ON"); local btnCastS = createBtn("BtnCastS", "CAST-SHDW: ON")
local btnTex = createBtn("BtnTex", "TEXTURES: HIGH"); local btnPart = createBtn("BtnPart", "PARTICLES: ON")
local btnHigh = createBtn("BtnHigh", "HIGHLIGHTS: ON"); local btnWater = createBtn("BtnWater", "WATER: HIGH")
local btnGlow = createBtn("BtnGlow", "POST-FX: ON"); local btnAudio = createBtn("BtnAudio", "3D AUDIO: ON")
local btnGui = createBtn("BtnGui", "HIDE GUIS: OFF"); local btn3d = createBtn("Btn3d", "NO RENDER: OFF")

local function createSwitch(text, parent)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1, -8, 0, 30); f.BackgroundTransparency = 1; f.Parent = parent
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -50, 1, 0); lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.SourceSansBold; lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(200, 200, 210); lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = f
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, 40, 0, 20); btn.Position = UDim2.new(1, -40, 0.5, -10); btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70); btn.Text = ""; btn.Parent = f
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0, 16, 0, 16); knob.Position = UDim2.new(0, 2, 0.5, -8); knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); knob.Parent = btn
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    return btn, knob, f
end

local btnRemember, knobRemember = createSwitch("Remember Changes", sysScroll)
local btnMaxFps, knobMaxFps = createSwitch("Remove 500 FPS Limit", sysScroll)
local btnAutoExec, knobAutoExec = createSwitch("Auto-Execute On Join", sysScroll)

-- DÜZELTİLMİŞ FASTFLAG EDİTÖR (Hizalama ve Tasarım)
local ffContainer = Instance.new("Frame"); ffContainer.Size = UDim2.new(1, -8, 0, 48); ffContainer.BackgroundTransparency = 1; ffContainer.Parent = sysScroll
local ffTitle = Instance.new("TextLabel"); ffTitle.Size = UDim2.new(1, 0, 0, 14); ffTitle.BackgroundTransparency = 1; ffTitle.Font = Enum.Font.SourceSansBold; ffTitle.Text = "FASTFLAG EDITOR"; ffTitle.TextColor3 = Color3.fromRGB(0, 162, 255); ffTitle.TextSize = 11; ffTitle.TextXAlignment = Enum.TextXAlignment.Left; ffTitle.Parent = ffContainer
local fflagBg = Instance.new("Frame"); fflagBg.Size = UDim2.new(1, 0, 0, 30); fflagBg.Position = UDim2.new(0, 0, 0, 18); fflagBg.BackgroundTransparency = 1; fflagBg.Parent = ffContainer
local fflagInput = Instance.new("TextBox"); fflagInput.Size = UDim2.new(1, -55, 1, 0); fflagInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50); fflagInput.TextColor3 = Color3.fromRGB(255, 255, 255); fflagInput.PlaceholderText = "Edit FastFlag..."; fflagInput.Font = Enum.Font.SourceSansBold; fflagInput.TextSize = 12; fflagInput.Parent = fflagBg; Instance.new("UICorner", fflagInput).CornerRadius = UDim.new(0, 6)
local btnApplyFf = Instance.new("TextButton"); btnApplyFf.Size = UDim2.new(0, 50, 1, 0); btnApplyFf.Position = UDim2.new(1, -50, 0, 0); btnApplyFf.BackgroundColor3 = Color3.fromRGB(0, 162, 255); btnApplyFf.Text = "APPLY"; btnApplyFf.Font = Enum.Font.SourceSansBold; btnApplyFf.TextColor3 = Color3.fromRGB(255, 255, 255); btnApplyFf.TextSize = 11; btnApplyFf.Parent = fflagBg; Instance.new("UICorner", btnApplyFf).CornerRadius = UDim.new(0, 6)
table.insert(activeModules, {Btn = btnApplyFf, Stroke = Instance.new("UIStroke"), IsActive = true}); table.insert(activeModules, {Btn = ffTitle, Stroke = Instance.new("UIStroke"), IsActive = true})

-- GERÇEK RESTART BUTONU
local btnRestartScript = Instance.new("TextButton"); btnRestartScript.Size = UDim2.new(1, -8, 0, 30); btnRestartScript.BackgroundColor3 = Color3.fromRGB(180, 50, 50); btnRestartScript.Font = Enum.Font.SourceSansBold; btnRestartScript.Text = "RESTART SCRIPT"; btnRestartScript.TextColor3 = Color3.fromRGB(255, 255, 255); btnRestartScript.TextSize = 12; btnRestartScript.Parent = sysScroll; Instance.new("UICorner", btnRestartScript).CornerRadius = UDim.new(0, 8)
table.insert(connections, btnRestartScript.MouseButton1Click:Connect(function() env.SYROX_RUNNING = false; if screenGui then screenGui:Destroy() end; pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="HYPERWORK", Text="Restarting script...", Duration=2}) end); task.delay(0.5, function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ZENWORK-lua/FPS-UNCAP/refs/heads/main/Main.lua"))() end) end))

local btnAfk, knobAfk = createSwitch("AFK optimization Mode", featScroll)
local btnDynRes, knobDynRes = createSwitch("Dynamic Res Scaler (BETA)", featScroll)
local btnDistCull, knobDistCull = createSwitch("Distance Quality Culling(working on it)", featScroll)
local btnAnimLimit, knobAnimLimit = createSwitch("Distance Anim Limiter(working on it)", featScroll)
local btnDeepRam, knobDeepRam = createSwitch("Deep RAM Flush", featScroll)

local themeTitle = Instance.new("TextLabel"); themeTitle.Size = UDim2.new(1, -24, 0, 22); themeTitle.Position = UDim2.new(0, 12, 0, 20); themeTitle.BackgroundTransparency = 1; themeTitle.Font = Enum.Font.SourceSansBold; themeTitle.TextColor3 = Color3.fromRGB(255, 255, 255); themeTitle.TextSize = 16; themeTitle.TextXAlignment = Enum.TextXAlignment.Center; themeTitle.Text = "PREMIUM THEMES"; themeTitle.Parent = themePage
local themeScroll = Instance.new("ScrollingFrame"); themeScroll.Size = UDim2.new(1, -24, 0, 150); themeScroll.Position = UDim2.new(0, 12, 0, 50); themeScroll.BackgroundTransparency = 1; themeScroll.BorderSizePixel = 0; themeScroll.ScrollBarThickness = 2; themeScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255); themeScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; themeScroll.CanvasSize = UDim2.new(0, 0, 0, 0); themeScroll.Parent = themePage
local themeGrid = Instance.new("UIGridLayout"); themeGrid.CellSize = UDim2.new(0, 110, 0, 32); themeGrid.CellPadding = UDim2.new(0, 8, 0, 8); themeGrid.Parent = themeScroll

local themes = {
    {Name = "Aero Glass", Accent = Color3.fromRGB(0, 162, 255), Bg1 = Color3.fromRGB(45, 45, 52), Bg2 = Color3.fromRGB(10, 10, 15)},
    {Name = "Crimson Frost", Accent = Color3.fromRGB(255, 40, 60), Bg1 = Color3.fromRGB(50, 20, 25), Bg2 = Color3.fromRGB(15, 5, 5)},
    {Name = "Cyber Gold", Accent = Color3.fromRGB(255, 200, 30), Bg1 = Color3.fromRGB(50, 45, 30), Bg2 = Color3.fromRGB(15, 12, 5)},
    {Name = "Neon Mint", Accent = Color3.fromRGB(0, 255, 150), Bg1 = Color3.fromRGB(20, 50, 40), Bg2 = Color3.fromRGB(5, 15, 10)},
    {Name = "Plasma Purple", Accent = Color3.fromRGB(180, 50, 255), Bg1 = Color3.fromRGB(35, 20, 45), Bg2 = Color3.fromRGB(10, 5, 15)},
    {Name = "Lava Orange", Accent = Color3.fromRGB(255, 100, 0), Bg1 = Color3.fromRGB(50, 25, 10), Bg2 = Color3.fromRGB(15, 5, 0)},
    {Name = "Ghost White", Accent = Color3.fromRGB(230, 230, 240), Bg1 = Color3.fromRGB(60, 60, 65), Bg2 = Color3.fromRGB(25, 25, 30)},
    {Name = "Toxic Slime", Accent = Color3.fromRGB(150, 255, 0), Bg1 = Color3.fromRGB(30, 40, 20), Bg2 = Color3.fromRGB(10, 15, 5)}
}
local confirmTitle = Instance.new("TextLabel"); confirmTitle.Size = UDim2.new(1, -24, 0, 45); confirmTitle.Position = UDim2.new(0, 12, 0, 40); confirmTitle.BackgroundTransparency = 1; confirmTitle.Font = Enum.Font.SourceSansBold; confirmTitle.TextWrapped = true; confirmTitle.TextColor3 = Color3.fromRGB(255, 255, 255); confirmTitle.TextSize = 15; confirmTitle.TextXAlignment = Enum.TextXAlignment.Center; confirmTitle.Text = "Do you want to close the script?"; confirmTitle.Parent = confirmPage
local btnConfirmYes = Instance.new("TextButton"); btnConfirmYes.Size = UDim2.new(0, 100, 0, 32); btnConfirmYes.Position = UDim2.new(0.5, -110, 0, 115); btnConfirmYes.BackgroundColor3 = Color3.fromRGB(46, 204, 113); btnConfirmYes.Font = Enum.Font.SourceSansBold; btnConfirmYes.Text = "Yes"; btnConfirmYes.TextColor3 = Color3.fromRGB(255, 255, 255); btnConfirmYes.TextSize = 14; btnConfirmYes.Parent = confirmPage; Instance.new("UICorner", btnConfirmYes).CornerRadius = UDim.new(0, 8)
local btnConfirmNope = Instance.new("TextButton"); btnConfirmNope.Size = UDim2.new(0, 100, 0, 32); btnConfirmNope.Position = UDim2.new(0.5, 10, 0, 115); btnConfirmNope.BackgroundColor3 = Color3.fromRGB(231, 76, 60); btnConfirmNope.Font = Enum.Font.SourceSansBold; btnConfirmNope.Text = "Nope"; btnConfirmNope.TextColor3 = Color3.fromRGB(255, 255, 255); btnConfirmNope.TextSize = 14; btnConfirmNope.Parent = confirmPage; Instance.new("UICorner", btnConfirmNope).CornerRadius = UDim.new(0, 8)

local function applyAppleTween(obj, props, dur) TweenService:Create(obj, TweenInfo.new(dur or 0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), props):Play() end

local currentPage = mainPage
local function openPage(target)
    if currentPage == target then target = mainPage end
    local fadeOut = TweenService:Create(fadeCurtain, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0}); fadeOut:Play()
    fadeOut.Completed:Connect(function() currentPage.Visible = false; target.Visible = true; currentPage = target; local fadeIn = TweenService:Create(fadeCurtain, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {BackgroundTransparency = 1}); fadeIn:Play() end)
end
table.insert(connections, btnTheme.MouseButton1Click:Connect(function() applyAppleTween(btnTheme, {ImageTransparency = 0}, 0.1); openPage(themePage); task.delay(0.2, function() applyAppleTween(btnTheme, {ImageTransparency = 0.3}, 0.3) end) end))
table.insert(connections, btnSettings.MouseButton1Click:Connect(function() applyAppleTween(btnSettings, {ImageTransparency = 0}, 0.1); openPage(settingsPage); task.delay(0.2, function() applyAppleTween(btnSettings, {ImageTransparency = 0.3}, 0.3) end) end))

table.insert(connections, btnSysTab.MouseButton1Click:Connect(function()
    btnSysTab.Text = "SYSTEM"; btnFeatTab.Text = "MORE"
    applyAppleTween(btnSysTab, {Size = UDim2.new(0, 95, 1, 0)}); applyAppleTween(btnFeatTab, {Size = UDim2.new(0, 65, 1, 0), Position = UDim2.new(0, 95, 0, 0)})
    applyAppleTween(segmentSlider, {Size = UDim2.new(0, 95, 1, -4), Position = UDim2.new(0, 2, 0, 2)}, 0.3)
    btnSysTab.TextColor3 = Color3.fromRGB(255,255,255); btnFeatTab.TextColor3 = Color3.fromRGB(150,150,160)
    featScroll.Visible = false; sysScroll.Visible = true
end))
table.insert(connections, btnFeatTab.MouseButton1Click:Connect(function()
    btnSysTab.Text = "SYS"; btnFeatTab.Text = "MORE FEATURES"
    applyAppleTween(btnSysTab, {Size = UDim2.new(0, 45, 1, 0)}); applyAppleTween(btnFeatTab, {Size = UDim2.new(0, 115, 1, 0), Position = UDim2.new(0, 45, 0, 0)})
    applyAppleTween(segmentSlider, {Size = UDim2.new(0, 115, 1, -4), Position = UDim2.new(0, 45, 0, 2)}, 0.3)
    btnFeatTab.TextColor3 = Color3.fromRGB(255,255,255); btnSysTab.TextColor3 = Color3.fromRGB(150,150,160)
    sysScroll.Visible = false; featScroll.Visible = true
end))

for _, td in ipairs(themes) do
    local tb = Instance.new("TextButton"); tb.Size = UDim2.new(0, 110, 0, 32); tb.BackgroundColor3 = Color3.fromRGB(30, 30, 40); tb.BackgroundTransparency = 0.4; tb.Font = Enum.Font.GothamMedium; tb.Text = td.Name; tb.TextColor3 = td.Accent; tb.TextSize = 13; tb.Parent = themeScroll; Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", tb); s.Color = td.Accent; s.Transparency = 0.5; s.Thickness = 1
    table.insert(connections, tb.MouseButton1Click:Connect(function()
        globalAccentColor = td.Accent; bgGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, td.Bg1), ColorSequenceKeypoint.new(1, td.Bg2)})
        applyAppleTween(auraStroke, {Color = td.Accent}); applyAppleTween(effectBarGlow, {BackgroundColor3 = td.Accent}); applyAppleTween(sliderFill, {BackgroundColor3 = td.Accent}); applyAppleTween(segmentSlider, {BackgroundColor3 = td.Accent})
        stabTitle.TextColor3 = td.Accent; ffTitle.TextColor3 = td.Accent; btnApplyFf.BackgroundColor3 = td.Accent; btnTheme.ImageColor3 = td.Accent; btnSettings.ImageColor3 = td.Accent
        for _, m in pairs(activeModules) do if m.IsActive then applyAppleTween(m.Btn, {TextColor3 = td.Accent}); applyAppleTween(m.Stroke, {Color = td.Accent}) end end
    end))
end

table.insert(connections, btnApplyFf.MouseButton1Click:Connect(function()
    local txt = fflagInput.Text; local split = string.split(txt, "=")
    if #split >= 2 then
        local flag = string.gsub(split[1], " ", ""); local valStr = string.gsub(split[2], " ", ""); local val
        if string.lower(valStr) == "true" then val = true elseif string.lower(valStr) == "false" then val = false elseif tonumber(valStr) then val = tonumber(valStr) else val = valStr end
        if getfflag and setfflag then
            local success, orig = pcall(function() return getfflag(flag) end)
            if success then
                if env.SYROX_ORIGINAL_FFLAGS[flag] == nil then env.SYROX_ORIGINAL_FFLAGS[flag] = orig end
                local setSuccess = pcall(function() setfflag(flag, val) end)
                if setSuccess then game:GetService("StarterGui"):SetCore("SendNotification", {Title="HYPER|HUB", Text="FastFlag Applied: "..flag, Duration=3}); fflagInput.Text = "" end
            else game:GetService("StarterGui"):SetCore("SendNotification", {Title="ERROR", Text="Invalid FastFlag!", Duration=3}) end
        else game:GetService("StarterGui"):SetCore("SendNotification", {Title="ERROR", Text="Executor lacks FFlag support!", Duration=3}) end
    else game:GetService("StarterGui"):SetCore("SendNotification", {Title="ERROR", Text="Format: FFlagName=Value", Duration=3}) end
end))
local function handleSwitch(btn, knob, state) applyAppleTween(btn, {BackgroundColor3 = state and globalAccentColor or Color3.fromRGB(60, 60, 70)}); applyAppleTween(knob, {Position = state and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}) end
local function toggleSt(name, state, tOn, tOff) local m = activeModules[name]; m.IsActive = state; m.Btn.Text = state and tOn or tOff; applyAppleTween(m.Btn, {TextColor3 = state and globalAccentColor or Color3.fromRGB(200, 200, 210)}, 0.3); applyAppleTween(m.Stroke, {Color = state and globalAccentColor or Color3.fromRGB(255, 255, 255), Transparency = state and 0.5 or 0.8}, 0.3) end


local function bindSwitch(btn, knob, swName, cb)
    local state = env.HYPER_SAVE.Switches[swName] or false; if state then handleSwitch(btn, knob, true); task.spawn(cb, true) end
    table.insert(connections, btn.MouseButton1Click:Connect(function() state = not state; handleSwitch(btn, knob, state); cb(state); env.HYPER_SAVE.Switches[swName] = state; env.saveHubData() end))
end
local function bindToggle(name, tOn, tOff, cb)
    local m = activeModules[name]; if env.HYPER_SAVE.Toggles[name] then m.IsActive = true; toggleSt(name, true, tOn, tOff); task.spawn(cb, true) end
    table.insert(connections, m.Btn.MouseButton1Click:Connect(function() m.IsActive = not m.IsActive; toggleSt(name, m.IsActive, tOn, tOff); cb(m.IsActive); env.HYPER_SAVE.Toggles[name] = m.IsActive; env.saveHubData() end))
end

local unlockFps, autoExec, isAfkEngine, isDynRes, isDistCull, isAnimLim = false, false, false, false, false, false
local isLow, isShdw, isCast, isTex, isPart, isHigh, isWater, isGlow, isAud, is3d = false, true, true, false, false, true, true, true, true, true

bindSwitch(btnRemember, knobRemember, "Remember", function(s) env.HYPER_SAVE.Remember = s; if not s and writefile then pcall(function() writefile("HYPER_HUB.json", HttpService:JSONEncode({Remember=false, Toggles={}, Switches={}})) end) else env.saveHubData() end end)
bindSwitch(btnMaxFps, knobMaxFps, "MaxFps", function(s) unlockFps = s; MAX_FPS = s and 10000 or 500 end)
bindSwitch(btnAutoExec, knobAutoExec, "AutoExec", function(s) autoExec = s; local qot = (syn and syn.queue_on_teleport) or queue_on_teleport; if qot then qot([[loadstring(game:HttpGet("https://raw.githubusercontent.com/ZENWORK-lua/FPS-UNCAP/refs/heads/main/Main.lua"))()]]) end end)
bindSwitch(btnAfk, knobAfk, "Afk", function(s) isAfkEngine = s; if s then pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="HYPERWORK", Text="AFK Optimization Activated!", Duration=3}) end) end end)
bindSwitch(btnDynRes, knobDynRes, "DynRes", function(s) isDynRes = s end); bindSwitch(btnDistCull, knobDistCull, "DistCull", function(s) isDistCull = s end); bindSwitch(btnAnimLimit, knobAnimLimit, "AnimLim", function(s) isAnimLim = s end)
bindSwitch(btnDeepRam, knobDeepRam, "DeepRam", function(s) if s then task.wait(0.2); pcall(function() collectgarbage("collect") end); handleSwitch(btnDeepRam, knobDeepRam, false); env.HYPER_SAVE.Switches["DeepRam"] = false end end)

local function asyncProcessDescendants(cb) task.spawn(function() for i, v in ipairs(workspace:GetDescendants()) do pcall(cb, v); if i % 150 == 0 then RunService.Heartbeat:Wait() end end end) end
bindToggle("BtnLowGfx", "LOW GFX: ON", "LOW GFX: OFF", function(s) isLow = s; asyncProcessDescendants(function(v) if v:IsA("BasePart") then v.Material = s and Enum.Material.SmoothPlastic or Enum.Material.Plastic end end) end)
bindToggle("BtnShadows", "SHADOWS: ON", "SHADOWS: OFF", function(s) isShdw = s; pcall(function() Lighting.GlobalShadows = s end) end)
bindToggle("BtnCastS", "CAST-SHDW: ON", "CAST-SHDW: OFF", function(s) isCast = s; asyncProcessDescendants(function(v) if v:IsA("BasePart") then v.CastShadow = s end end) end)
bindToggle("BtnTex", "TEXTURES: LOW", "TEXTURES: HIGH", function(s) isTex = s; asyncProcessDescendants(function(v) if v:IsA("Texture") or v:IsA("Decal") then v.Transparency = s and 1 or 0 end end) end)
bindToggle("BtnPart", "PARTICLES: OFF", "PARTICLES: ON", function(s) isPart = s; asyncProcessDescendants(function(v) if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") then v.Enabled = not s end end) end)
bindToggle("BtnHigh", "HIGHLIGHTS: ON", "HIGHLIGHTS: OFF", function(s) isHigh = s; asyncProcessDescendants(function(v) if v:IsA("Highlight") then v.Enabled = s end end) end)
bindToggle("BtnWater", "WATER: HIGH", "WATER: LOW", function(s) isWater = s; pcall(function() local t = workspace.Terrain; t.WaterWaveSize = s and 0.15 or 0; t.WaterWaveSpeed = s and 10 or 0; t.WaterReflectance = s and 1 or 0 end) end)
bindToggle("BtnGlow", "POST-FX: ON", "POST-FX: OFF", function(s) isGlow = s; asyncProcessDescendants(function(v) if v:IsA("PostEffect") then v.Enabled = s end end) end)
bindToggle("BtnAudio", "3D AUDIO: ON", "3D AUDIO: OFF", function(s) isAud = s; pcall(function() game:GetService("SoundService").AmbientReverb = s and Enum.ReverbType.NoReverb or Enum.ReverbType.NoReverb end) end)
bindToggle("Btn3d", "NO RENDER: ON", "NO RENDER: OFF", function(s) is3d = s; pcall(function() RunService:Set3dRenderingEnabled(not s) end) end)
table.insert(connections, btnRejoin.MouseButton1Click:Connect(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer) end))

local currentState, isDraggingMoved, isIntroPlaying = 0, false, true
local draggingPill = false; local pillDragStart, startPos = nil, nil
local confirmStep = 0; local tapCount = 0


local function minimizeMenu() 
    currentState = 1; contentContainer.Visible = false
    applyAppleTween(mainFrame, {Size = UDim2.new(0, 44, 0, 44)})
    applyAppleTween(uiCorner, {CornerRadius = UDim.new(1, 0)})
    applyAppleTween(outerAura, {Size = UDim2.new(1, 4, 1, 4)})
    applyAppleTween(headerPillTouch, {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5)}) 
    applyAppleTween(headerPill, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0.5, 0, 0.5, 0)}) 
end
local function maximizeMenu() 
    currentState = 0
    applyAppleTween(mainFrame, {Size = UDim2.new(0, 270, 0, 210)})
    applyAppleTween(uiCorner, {CornerRadius = UDim.new(0, 16)})
    applyAppleTween(outerAura, {Size = UDim2.new(1, 6, 1, 6)})
    applyAppleTween(headerPillTouch, {Size = UDim2.new(0, 150, 0, 32), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0)}) 
    applyAppleTween(headerPill, {Size = UDim2.new(0, 50, 0, 5), Position = UDim2.new(0.5, 0, 0, 12)}) 
    task.delay(0.1, function() if currentState == 0 then contentContainer.Visible = true end end) 
end

local function startCloseSequence() confirmStep = 1; confirmTitle.Text = "Do you want to close the script?"; openPage(confirmPage) end
table.insert(connections, btnConfirmNope.MouseButton1Click:Connect(function()
    if confirmStep == 1 then openPage(mainPage); confirmStep = 0
    elseif confirmStep == 2 then
        pcall(function() Lighting.GlobalShadows = origSettings.GlobalShadows; settings().Rendering.QualityLevel = origSettings.QualityLevel; local t = workspace.Terrain; t.WaterWaveSize = origSettings.WaterWaveSize; t.WaterWaveSpeed = origSettings.WaterWaveSpeed; t.WaterReflectance = origSettings.WaterReflectance; RunService:Set3dRenderingEnabled(true) end)
        if setfflag then for k, v in pairs(env.SYROX_ORIGINAL_FFLAGS) do pcall(function() setfflag(k, v) end) end end
        env.SYROX_RUNNING = false; if screenGui then screenGui:Destroy() end
    end
end))
table.insert(connections, btnConfirmYes.MouseButton1Click:Connect(function()
    if confirmStep == 1 then confirmStep = 2; TweenService:Create(fadeCurtain, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play(); task.delay(0.2, function() confirmTitle.Text = "Do you want the changes to persist?"; TweenService:Create(fadeCurtain, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() end)
    elseif confirmStep == 2 then env.SYROX_RUNNING = false; if screenGui then screenGui:Destroy() end end
end))

table.insert(connections, headerPillTouch.InputBegan:Connect(function(input) if isIntroPlaying then return end; if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingPill = true; isDraggingMoved = false; pillDragStart = input.Position; startPos = mainFrame.Position end end))
table.insert(connections, UserInputService.InputChanged:Connect(function(input) if draggingPill and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - pillDragStart; if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then isDraggingMoved = true end; mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end))
table.insert(connections, headerPillTouch.InputEnded:Connect(function(input)
    if draggingPill and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        draggingPill = false; if isDraggingMoved then return end
        tapCount = tapCount + 1
        if tapCount == 1 then task.delay(0.25, function() if tapCount == 1 then if currentState == 0 then minimizeMenu() elseif currentState == 1 then maximizeMenu() end end; tapCount = 0 end)
        elseif tapCount == 2 then tapCount = 0; if currentState == 1 then startCloseSequence() end end
    end
end))

local function updateSlider(x) local tPos = sliderTrack.AbsolutePosition.X; local tSz = sliderTrack.AbsoluteSize.X; local ratio = math.clamp((x - tPos) / tSz, 0, 1); local fps = math.floor(MIN_FPS + (ratio * (MAX_FPS - MIN_FPS))); sliderFill.Size = UDim2.new(ratio, 0, 1, 0); sliderKnob.Position = UDim2.new(ratio, -9, 0.5, -9); titleLabel.Text = string.format("Target FPS: %d FPS", fps); return fps end
table.insert(connections, UserInputService.InputBegan:Connect(function(input) if isIntroPlaying or not mainPage.Visible then return end; if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then local pos, tPos, tSz = input.Position, sliderTrack.AbsolutePosition, sliderTrack.AbsoluteSize; if pos.X >= tPos.X-15 and pos.X <= tPos.X+tSz.X+15 and pos.Y >= tPos.Y-20 and pos.Y <= tPos.Y+tSz.Y+20 then draggingSlider = true; updateSlider(pos.X) end end end))
table.insert(connections, UserInputService.InputChanged:Connect(function(input) if draggingSlider then updateSlider(input.Position.X) end end))
table.insert(connections, UserInputService.InputEnded:Connect(function(input) if draggingSlider then draggingSlider = false; local f = updateSlider(input.Position.X); if setfpscap then pcall(setfpscap, f) elseif set_fps_cap then pcall(set_fps_cap, f) end; applyAppleTween(effectBarGlow, {Size = UDim2.new(math.clamp((f-MIN_FPS)/(MAX_FPS-MIN_FPS),0,1),0,1,0), BackgroundColor3 = Color3.fromRGB(0,255,180)}); task.delay(0.3, function() TweenService:Create(effectBarGlow, TweenInfo.new(0.4), {BackgroundColor3 = globalAccentColor}):Play() end) end end))

local lastInputTime = os.clock()
table.insert(connections, UserInputService.InputBegan:Connect(function() lastInputTime = os.clock(); if afkScreen.Visible then afkScreen.Visible = false; RunService:Set3dRenderingEnabled(not is3d) end end))

local lastTime, fCount, currentRealFps = os.clock(), 0, 60
local dynResScanFrames, maxPanelFps, dynResCalibrated, lowFpsSeconds = 0, 60, false, 0
table.insert(connections, RunService.RenderStepped:Connect(function()
    fCount = fCount + 1; local curr = os.clock()
    if curr - lastTime >= 1 then
        currentRealFps = math.floor(fCount / (curr - lastTime)); fpsDisplay.Text = string.format("Current FPS: %d", currentRealFps); fCount = 0; lastTime = curr
        if isAfkEngine and (curr - lastInputTime > 60) and not afkScreen.Visible then afkScreen.Visible = true; RunService:Set3dRenderingEnabled(false) end
        if isDynRes then
            if not dynResCalibrated then dynResScanFrames = dynResScanFrames + 1; if currentRealFps > maxPanelFps then maxPanelFps = currentRealFps end; if dynResScanFrames >= 4 then dynResCalibrated = true end
            else local target = (maxPanelFps > 70) and 80 or 40; if currentRealFps < target then lowFpsSeconds = lowFpsSeconds + 1 else lowFpsSeconds = 0; pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end) end
            if lowFpsSeconds >= 5 then pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level05 end) end end
        end
    end
end))

task.spawn(function()
    while env.SYROX_RUNNING do task.wait(2); local lp = Players.LocalPlayer; local char = lp.Character; if char and char:FindFirstChild("HumanoidRootPart") then local pos = char.HumanoidRootPart.Position; for _, v in ipairs(workspace:GetDescendants()) do if v:IsA("BasePart") and isDistCull then local dist = (v.Position - pos).Magnitude; if dist > 200 then v.Material = Enum.Material.SmoothPlastic; v.CastShadow = false else v.Material = Enum.Material.Plastic; v.CastShadow = true end end; if v:IsA("Humanoid") and v.Parent ~= char and isAnimLim then if v.Parent:FindFirstChild("HumanoidRootPart") then local dist = (v.Parent.HumanoidRootPart.Position - pos).Magnitude; if dist > 120 then v.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None else v.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end end end end end end
end)

table.insert(connections, btnCloseInfo.MouseButton1Click:Connect(function() TweenService:Create(infoOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play(); TweenService:Create(infoBody, TweenInfo.new(0.3), {TextTransparency = 1}):Play(); TweenService:Create(btnCloseInfo, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play(); task.delay(0.3, function() infoOverlay.Visible = false; contentContainer.Visible = true; isIntroPlaying = false end) end))

screenGui.Parent = targetGui
task.spawn(function()
    applyAppleTween(mainFrame, {Size = UDim2.new(0, 130, 0, 130)}, 0.6); task.wait(0.5); TweenService:Create(introText, TweenInfo.new(0.6), {TextTransparency = 0}):Play(); task.wait(1.5); TweenService:Create(introText, TweenInfo.new(0.4), {TextTransparency = 1}):Play(); task.wait(0.3)
    applyAppleTween(mainFrame, {Size = UDim2.new(0, 80, 0, 80)}, 0.4); task.wait(0.3); applyAppleTween(mainFrame, {Size = UDim2.new(0, 90, 0, 16)}, 0.5); applyAppleTween(uiCorner, {CornerRadius = UDim.new(0, 8)}, 0.5); task.wait(0.4)
    TweenService:Create(auraStroke, TweenInfo.new(0.3), {Transparency = 0.65}):Play(); TweenService:Create(headerPill, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play(); introText:Destroy(); task.wait(0.2)
    applyAppleTween(mainFrame, {Size = UDim2.new(0, 270, 0, 210)}, 0.5); applyAppleTween(uiCorner, {CornerRadius = UDim.new(0, 16)}, 0.5); applyAppleTween(headerPill, {Size = UDim2.new(0, 50, 0, 5), Position = UDim2.new(0.5, 0, 0, 12)}, 0.5); task.wait(0.3)
    infoOverlay.Visible = true
end)

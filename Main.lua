-- SYROX|TECH - Ultimate Mac-OS Fluid Hub v10
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local env = (getgenv and getgenv()) or _G
local function getSafeGuiParent()
    local p = nil; if gethui then pcall(function() p = gethui() end) end
    if not p then pcall(function() p = game:GetService("CoreGui") end) end
    if not p or not pcall(function() local _ = p.Name end) then p = Players.LocalPlayer:WaitForChild("PlayerGui") end
    return p
end
local targetGui = getSafeGuiParent()

-- ALREADY RUNNING CHECK
if env.SYROX_RUNNING and targetGui:FindFirstChild("FPSCapUI") then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "HYPERWORK",
            Text = "Script is already running. You can restart it from Settings.",
            Duration = 5
        })
    end)
    return
end

if env.FPSCapUIConnections then for _, c in ipairs(env.FPSCapUIConnections) do if c and c.Connected then c:Disconnect() end end end
if targetGui:FindFirstChild("FPSCapUI") then targetGui.FPSCapUI:Destroy() end
env.FPSCapUIConnections = {}
local connections = env.FPSCapUIConnections
env.SYROX_RUNNING = true

-- KEEP DEFAULT SETTINGS FOR BORING PEOPLE🫩
local origSettings = {
    GlobalShadows = Lighting.GlobalShadows,
    QualityLevel = settings().Rendering.QualityLevel,
    WaterWaveSize = workspace.Terrain.WaterWaveSize,
    WaterWaveSpeed = workspace.Terrain.WaterWaveSpeed,
    WaterReflectance = workspace.Terrain.WaterReflectance
}

local MIN_FPS = 5
local MAX_FPS = 500
local currentTargetFps = setfpscap and 120 or 60

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FPSCapUI"; screenGui.ResetOnSpawn = false; screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BackgroundTransparency = 0.25; mainFrame.BorderSizePixel = 0
mainFrame.Active = true; mainFrame.ClipsDescendants = false; mainFrame.Parent = screenGui

local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 52)), ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))})
bgGradient.Rotation = 45; bgGradient.Parent = mainFrame
local uiCorner = Instance.new("UICorner"); uiCorner.CornerRadius = UDim.new(1, 0); uiCorner.Parent = mainFrame

local introText = Instance.new("TextLabel")
introText.Size = UDim2.new(1, 0, 1, 0); introText.BackgroundTransparency = 1; introText.Font = Enum.Font.GothamBold
introText.Text = "HYPER|HUB"; introText.TextColor3 = Color3.fromRGB(255, 255, 255); introText.TextSize = 17
introText.TextTransparency = 1; introText.Parent = mainFrame

local outerAura = Instance.new("Frame")
outerAura.Size = UDim2.new(1, 6, 1, 6); outerAura.Position = UDim2.new(0.5, 0, 0.5, 0)
outerAura.AnchorPoint = Vector2.new(0.5, 0.5); outerAura.BackgroundTransparency = 1; outerAura.Parent = mainFrame
Instance.new("UICorner", outerAura).CornerRadius = UDim.new(0, 19)
local auraStroke = Instance.new("UIStroke")
auraStroke.Color = Color3.fromRGB(0, 162, 255); auraStroke.Thickness = 1.2; auraStroke.Transparency = 1; auraStroke.Parent = outerAura

-- GENİŞLETİLMİŞ HAP VE HITBOX (BÜYÜTÜLMÜŞ DOKUNMA ALANI)
local headerPillTouch = Instance.new("Frame")
headerPillTouch.Name = "HeaderPillTouch"
headerPillTouch.Size = UDim2.new(1, 0, 0, 26) -- Geniş Dokunma Kalkanı
headerPillTouch.Position = UDim2.new(0, 0, 0, 0)
headerPillTouch.BackgroundTransparency = 1
headerPillTouch.Parent = mainFrame

local headerPill = Instance.new("TextButton")
headerPill.Size = UDim2.new(1, -12, 0, 5); headerPill.Position = UDim2.new(0.5, 0, 0.5, 0)
headerPill.AnchorPoint = Vector2.new(0.5, 0.5)
headerPill.BackgroundColor3 = Color3.fromRGB(255, 255, 255); headerPill.BackgroundTransparency = 1
headerPill.Text = ""; headerPill.AutoButtonColor = false; headerPill.Parent = headerPillTouch
Instance.new("UICorner", headerPill).CornerRadius = UDim.new(1, 0)

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, 0, 1, 0); contentContainer.BackgroundTransparency = 1
contentContainer.ClipsDescendants = true; contentContainer.Visible = false; contentContainer.Parent = mainFrame

local mainPage = Instance.new("Frame")
mainPage.Size = UDim2.new(1, 0, 1, 0); mainPage.BackgroundTransparency = 1; mainPage.Parent = contentContainer
local themePage = Instance.new("Frame")
themePage.Size = UDim2.new(1, 0, 1, 0); themePage.BackgroundTransparency = 1; themePage.Visible = false; themePage.Parent = contentContainer
local settingsPage = Instance.new("Frame")
settingsPage.Size = UDim2.new(1, 0, 1, 0); settingsPage.BackgroundTransparency = 1; settingsPage.Visible = false; settingsPage.Parent = contentContainer
local confirmPage = Instance.new("Frame")
confirmPage.Size = UDim2.new(1, 0, 1, 0); confirmPage.BackgroundTransparency = 1; confirmPage.Visible = false; confirmPage.Parent = contentContainer

local fadeCurtain = Instance.new("Frame")
fadeCurtain.Size = UDim2.new(1, 0, 1, 0); fadeCurtain.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
fadeCurtain.BackgroundTransparency = 1; fadeCurtain.ZIndex = 10; fadeCurtain.Parent = contentContainer
Instance.new("UICorner", fadeCurtain).CornerRadius = UDim.new(0, 16)

local windowControls = Instance.new("Frame")
windowControls.Size = UDim2.new(0, 50, 0, 20); windowControls.Position = UDim2.new(0, 12, 0, 14)
windowControls.BackgroundTransparency = 1; windowControls.Visible = false; windowControls.Parent = mainPage
local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 12, 0, 12); btnClose.Position = UDim2.new(0, 0, 0, 0)
btnClose.BackgroundColor3 = Color3.fromRGB(255, 80, 80); btnClose.Text = ""; btnClose.Parent = windowControls
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(1, 0)
local btnMin = Instance.new("TextButton")
btnMin.Size = UDim2.new(0, 12, 0, 12); btnMin.Position = UDim2.new(0, 20, 0, 0)
btnMin.BackgroundColor3 = Color3.fromRGB(255, 190, 50); btnMin.Text = ""; btnMin.Parent = windowControls
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(1, 0)

local btnTheme = Instance.new("ImageButton")
btnTheme.Size = UDim2.new(0, 20, 0, 20); btnTheme.Position = UDim2.new(1, -60, 0, 18)
btnTheme.BackgroundTransparency = 1; btnTheme.Image = "rbxassetid://3926305904"
btnTheme.ImageRectOffset = Vector2.new(764, 244); btnTheme.ImageRectSize = Vector2.new(36, 36)
btnTheme.ImageColor3 = Color3.fromRGB(255, 255, 255); btnTheme.ImageTransparency = 0.3; btnTheme.ZIndex = 11; btnTheme.Parent = contentContainer

local btnSettings = Instance.new("ImageButton")
btnSettings.Size = UDim2.new(0, 20, 0, 20); btnSettings.Position = UDim2.new(1, -34, 0, 18)
btnSettings.BackgroundTransparency = 1; btnSettings.Image = "rbxassetid://3926307971"
btnSettings.ImageRectOffset = Vector2.new(324, 124); btnSettings.ImageRectSize = Vector2.new(36, 36)
btnSettings.ImageColor3 = Color3.fromRGB(255, 255, 255); btnSettings.ImageTransparency = 0.3; btnSettings.ZIndex = 11; btnSettings.Parent = contentContainer
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -24, 0, 22); titleLabel.Position = UDim2.new(0, 12, 0, 20)
titleLabel.BackgroundTransparency = 1; titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240); titleLabel.TextSize = 15; titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Text = string.format("Target Limit: %d FPS", currentTargetFps); titleLabel.Parent = mainPage

local effectBarBg = Instance.new("Frame")
effectBarBg.Size = UDim2.new(1, -24, 0, 5); effectBarBg.Position = UDim2.new(0, 12, 0, 66)
effectBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50); effectBarBg.BackgroundTransparency = 0.3
effectBarBg.BorderSizePixel = 0; effectBarBg.Parent = mainPage
Instance.new("UICorner", effectBarBg).CornerRadius = UDim.new(1, 0)

local sliderTrack = Instance.new("Frame")
sliderTrack.Size = UDim2.new(1, -24, 0, 6); sliderTrack.Position = UDim2.new(0, 12, 0, 85)
sliderTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 55); sliderTrack.BorderSizePixel = 0; sliderTrack.Parent = mainPage
Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(1, 0)

local initialRatio = math.clamp((currentTargetFps - MIN_FPS) / (MAX_FPS - MIN_FPS), 0, 1)
local effectBarGlow = Instance.new("Frame")
effectBarGlow.Size = UDim2.new(initialRatio, 0, 1, 0); effectBarGlow.BackgroundColor3 = Color3.fromRGB(0, 162, 255); effectBarGlow.Parent = effectBarBg
Instance.new("UICorner", effectBarGlow).CornerRadius = UDim.new(1, 0)
local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(initialRatio, 0, 1, 0); sliderFill.BackgroundColor3 = Color3.fromRGB(0, 162, 255); sliderFill.Parent = sliderTrack
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 18, 0, 18); sliderKnob.Position = UDim2.new(initialRatio, -9, 0.5, -9)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); sliderKnob.Parent = sliderTrack
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

local fpsDisplay = Instance.new("TextLabel")
fpsDisplay.Size = UDim2.new(1, -24, 0, 18); fpsDisplay.Position = UDim2.new(0, 12, 0, 42)
fpsDisplay.BackgroundTransparency = 1; fpsDisplay.Font = Enum.Font.SourceSansSemibold
fpsDisplay.TextColor3 = Color3.fromRGB(160, 160, 175); fpsDisplay.TextSize = 13; fpsDisplay.TextXAlignment = Enum.TextXAlignment.Left
fpsDisplay.Text = "Current FPS: 0"; fpsDisplay.Parent = mainPage

-- YENİLENEN BAŞLIK: FEATURES
local stabTitle = Instance.new("TextLabel")
stabTitle.Size = UDim2.new(1, -24, 0, 16); stabTitle.Position = UDim2.new(0, 12, 0, 110)
stabTitle.BackgroundTransparency = 1; stabTitle.Font = Enum.Font.SourceSansBold
stabTitle.Text = "FEATURES (SWIPE RIGHT ->)"; stabTitle.TextColor3 = Color3.fromRGB(0, 200, 255); stabTitle.TextSize = 11
stabTitle.TextXAlignment = Enum.TextXAlignment.Left; stabTitle.Parent = mainPage

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -24, 0, 65); scrollFrame.Position = UDim2.new(0, 12, 0, 130)
scrollFrame.BackgroundTransparency = 1; scrollFrame.BorderSizePixel = 0; scrollFrame.ScrollBarThickness = 0
scrollFrame.ScrollingDirection = Enum.ScrollingDirection.X; scrollFrame.CanvasSize = UDim2.new(0, 1100, 0, 0); scrollFrame.Parent = mainPage
local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 115, 0, 28); gridLayout.CellPadding = UDim2.new(0, 8, 0, 8); gridLayout.FillDirection = Enum.FillDirection.Vertical; gridLayout.Parent = scrollFrame

local activeModules = {}
local function createBtn(name, text)
    local btn = Instance.new("TextButton")
    btn.Name = name; btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40); btn.BackgroundTransparency = 0.3
    btn.Font = Enum.Font.SourceSansBold; btn.Text = text; btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.TextSize = 11; btn.Parent = scrollFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local str = Instance.new("UIStroke", btn); str.Color = Color3.fromRGB(255, 255, 255); str.Thickness = 1; str.Transparency = 0.8
    activeModules[name] = {Btn = btn, Stroke = str, IsActive = false}
    return btn, str
end

local btnRejoin = createBtn("BtnRejoin", "REJOIN SERVER")
local btnGfxLvl = createBtn("BtnGfx", "GFX LVL: AUTO"); local btnLowGfx = createBtn("BtnLowGfx", "LOW GFX: OFF")
local btnShadows = createBtn("BtnShadows", "SHADOWS: ON"); local btnCastS = createBtn("BtnCastS", "CAST-SHDW: ON")
local btnTex = createBtn("BtnTex", "TEXTURES: HIGH"); local btnPart = createBtn("BtnPart", "PARTICLES: ON")
local btnHigh = createBtn("BtnHigh", "HIGHLIGHTS: ON"); local btnWater = createBtn("BtnWater", "WATER: HIGH")
local btnGlow = createBtn("BtnGlow", "POST-FX: ON"); local btnAudio = createBtn("BtnAudio", "3D AUDIO: ON")
local btnGui = createBtn("BtnGui", "HIDE GUIS: OFF"); local btn3d = createBtn("Btn3d", "3D RENDER: ON")
local btnGc = createBtn("BtnGc", "AUTO GC: ON"); local btnCpu = createBtn("BtnCpu", "CPU T-MAX: ON")
local btnNet = createBtn("BtnNet", "NET BOOST: OFF"); local btnPhys = createBtn("BtnPhys", "PHYSICS: HIGH")

local function createPageHeader(txt, p)
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -24, 0, 22); tl.Position = UDim2.new(0, 12, 0, 20)
    tl.BackgroundTransparency = 1; tl.Font = Enum.Font.SourceSansBold; tl.TextColor3 = Color3.fromRGB(255, 255, 255)
    tl.TextSize = 16; tl.TextXAlignment = Enum.TextXAlignment.Center; tl.Text = txt; tl.Parent = p
    local scr = Instance.new("ScrollingFrame")
    scr.Size = UDim2.new(1, -24, 0, 150); scr.Position = UDim2.new(0, 12, 0, 50)
    scr.BackgroundTransparency = 1; scr.BorderSizePixel = 0; scr.ScrollBarThickness = 2
    scr.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255); scr.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scr.CanvasSize = UDim2.new(0, 0, 0, 0); scr.Parent = p
    return scr
end

local themeScroll = createPageHeader("THEMES", themePage)
local themeGrid = Instance.new("UIGridLayout"); themeGrid.CellSize = UDim2.new(1, -8, 0, 32); themeGrid.CellPadding = UDim2.new(0, 0, 0, 8); themeGrid.Parent = themeScroll
local globalAccentColor = Color3.fromRGB(0, 162, 255)
local themes = {
    {Name = "Aero Glass (Default)", Accent = Color3.fromRGB(0, 162, 255), Bg1 = Color3.fromRGB(45, 45, 52), Bg2 = Color3.fromRGB(10, 10, 15), TFont = Enum.Font.GothamMedium},
    {Name = "Crimson Frost", Accent = Color3.fromRGB(255, 40, 60), Bg1 = Color3.fromRGB(50, 20, 25), Bg2 = Color3.fromRGB(15, 5, 5), TFont = Enum.Font.Oswald},
    {Name = "Cyber Gold", Accent = Color3.fromRGB(255, 200, 30), Bg1 = Color3.fromRGB(50, 45, 30), Bg2 = Color3.fromRGB(15, 12, 5), TFont = Enum.Font.Michroma},
    {Name = "Arctic Silver", Accent = Color3.fromRGB(150, 220, 255), Bg1 = Color3.fromRGB(55, 60, 65), Bg2 = Color3.fromRGB(20, 25, 30), TFont = Enum.Font.TitilliumWeb}
}

local setScroll = createPageHeader("SYSTEM SETTINGS", settingsPage)
local setGrid = Instance.new("UIListLayout"); setGrid.Padding = UDim.new(0, 10); setGrid.Parent = setScroll

local function createSwitch(text, parent)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1, -8, 0, 30); f.BackgroundTransparency = 1; f.Parent = parent
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -50, 1, 0); lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSansBold; lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(200, 200, 210); lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = f
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, 40, 0, 20); btn.Position = UDim2.new(1, -40, 0.5, -10)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70); btn.Text = ""; btn.Parent = f
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0, 16, 0, 16); knob.Position = UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); knob.Parent = btn
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    return btn, knob, f
end

local btnWinCtrl, knobWinCtrl = createSwitch("Change Close Method", setScroll)
local infoWin = Instance.new("TextLabel")
infoWin.Size = UDim2.new(1, -8, 0, 32); infoWin.BackgroundTransparency = 1; infoWin.TextWrapped = true
infoWin.Font = Enum.Font.SourceSans; infoWin.TextColor3 = Color3.fromRGB(150, 150, 160); infoWin.TextSize = 11; infoWin.TextXAlignment = Enum.TextXAlignment.Left
infoWin.Text = "Info: Current close method is double-tapping the white pill, then double-tapping it again when minimized."; infoWin.Parent = setScroll
local btnMaxFps, knobMaxFps = createSwitch("Remove 500 FPS Limit", setScroll)
local btnAutoExec, knobAutoExec = createSwitch("Auto-Execute On Teleport", setScroll)

local btnRestartScript = Instance.new("TextButton")
btnRestartScript.Size = UDim2.new(1, -8, 0, 30); btnRestartScript.BackgroundColor3 = Color3.fromRGB(180, 50, 50); btnRestartScript.Font = Enum.Font.SourceSansBold
btnRestartScript.Text = "RESTART SCRIPT"; btnRestartScript.TextColor3 = Color3.fromRGB(255, 255, 255); btnRestartScript.TextSize = 12; btnRestartScript.Parent = setScroll
Instance.new("UICorner", btnRestartScript).CornerRadius = UDim.new(0, 8)
-- ONAY SAYFASI ARAYÜZÜ
local confirmTitle = Instance.new("TextLabel")
confirmTitle.Size = UDim2.new(1, -24, 0, 45); confirmTitle.Position = UDim2.new(0, 12, 0, 40)
confirmTitle.BackgroundTransparency = 1; confirmTitle.Font = Enum.Font.SourceSansBold; confirmTitle.TextWrapped = true
confirmTitle.TextColor3 = Color3.fromRGB(255, 255, 255); confirmTitle.TextSize = 15; confirmTitle.TextXAlignment = Enum.TextXAlignment.Center
confirmTitle.Text = "Do you want to close the script?"; confirmTitle.Parent = confirmPage

local btnConfirmYes = Instance.new("TextButton")
btnConfirmYes.Size = UDim2.new(0, 100, 0, 32); btnConfirmYes.Position = UDim2.new(0.5, -110, 0, 115)
btnConfirmYes.BackgroundColor3 = Color3.fromRGB(46, 204, 113); btnConfirmYes.Font = Enum.Font.SourceSansBold
btnConfirmYes.Text = "Yes"; btnConfirmYes.TextColor3 = Color3.fromRGB(255, 255, 255); btnConfirmYes.TextSize = 14; btnConfirmYes.Parent = confirmPage
Instance.new("UICorner", btnConfirmYes).CornerRadius = UDim.new(0, 8)

local btnConfirmNope = Instance.new("TextButton")
btnConfirmNope.Size = UDim2.new(0, 100, 0, 32); btnConfirmNope.Position = UDim2.new(0.5, 10, 0, 115)
btnConfirmNope.BackgroundColor3 = Color3.fromRGB(231, 76, 60); btnConfirmNope.Font = Enum.Font.SourceSansBold
btnConfirmNope.Text = "Nope"; btnConfirmNope.TextColor3 = Color3.fromRGB(255, 255, 255); btnConfirmNope.TextSize = 14; btnConfirmNope.Parent = confirmPage
Instance.new("UICorner", btnConfirmNope).CornerRadius = UDim.new(0, 8)

applyAppleTween = function(obj, props, dur)
    TweenService:Create(obj, TweenInfo.new(dur or 0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), props):Play()
end

local currentPage = mainPage
local function openPage(target)
    if currentPage == target then target = mainPage end
    local fadeOut = TweenService:Create(fadeCurtain, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0}); fadeOut:Play()
    fadeOut.Completed:Connect(function()
        currentPage.Visible = false; target.Visible = true; currentPage = target
        local fadeIn = TweenService:Create(fadeCurtain, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {BackgroundTransparency = 1}); fadeIn:Play()
    end)
end
table.insert(connections, btnTheme.MouseButton1Click:Connect(function() applyAppleTween(btnTheme, {ImageTransparency = 0}, 0.1); openPage(themePage); task.delay(0.2, function() applyAppleTween(btnTheme, {ImageTransparency = 0.3}, 0.3) end) end))
table.insert(connections, btnSettings.MouseButton1Click:Connect(function() applyAppleTween(btnSettings, {ImageTransparency = 0}, 0.1); openPage(settingsPage); task.delay(0.2, function() applyAppleTween(btnSettings, {ImageTransparency = 0.3}, 0.3) end) end))

for _, td in ipairs(themes) do
    local tb = Instance.new("TextButton")
    tb.Size = UDim2.new(1, 0, 1, 0); tb.BackgroundColor3 = Color3.fromRGB(30, 30, 40); tb.BackgroundTransparency = 0.4
    tb.Font = td.TFont; tb.Text = td.Name; tb.TextColor3 = td.Accent; tb.TextSize = 13; tb.Parent = themeScroll
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", tb); s.Color = td.Accent; s.Transparency = 0.5; s.Thickness = 1
    table.insert(connections, tb.MouseButton1Click:Connect(function()
        globalAccentColor = td.Accent; bgGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, td.Bg1), ColorSequenceKeypoint.new(1, td.Bg2)})
        applyAppleTween(auraStroke, {Color = td.Accent}); applyAppleTween(effectBarGlow, {BackgroundColor3 = td.Accent}); applyAppleTween(sliderFill, {BackgroundColor3 = td.Accent})
        stabTitle.TextColor3 = td.Accent; btnTheme.ImageColor3 = td.Accent; btnSettings.ImageColor3 = td.Accent
        if btnWinCtrl.BackgroundColor3 ~= Color3.fromRGB(60, 60, 70) then applyAppleTween(btnWinCtrl, {BackgroundColor3 = td.Accent}) end
        if btnMaxFps.BackgroundColor3 ~= Color3.fromRGB(60, 60, 70) then applyAppleTween(btnMaxFps, {BackgroundColor3 = td.Accent}) end
        if btnAutoExec.BackgroundColor3 ~= Color3.fromRGB(60, 60, 70) then applyAppleTween(btnAutoExec, {BackgroundColor3 = td.Accent}) end
        for _, m in pairs(activeModules) do if m.IsActive then applyAppleTween(m.Btn, {TextColor3 = td.Accent}); applyAppleTween(m.Stroke, {Color = td.Accent}) end end
    end))
end

useWinCtrl, unlockFps, autoExec = false, false, false
table.insert(connections, btnWinCtrl.MouseButton1Click:Connect(function()
    useWinCtrl = not useWinCtrl
    applyAppleTween(btnWinCtrl, {BackgroundColor3 = useWinCtrl and globalAccentColor or Color3.fromRGB(60, 60, 70)})
    applyAppleTween(knobWinCtrl, {Position = useWinCtrl and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
    windowControls.Visible = useWinCtrl; titleLabel.Visible = not useWinCtrl
    infoWin.Text = useWinCtrl and "Info: Double-tap is disabled. Use the Red and Yellow buttons to close or minimize." or "Info: Current close method is double-tapping the white pill, then double-tapping it again when minimized."
end))

table.insert(connections, btnMaxFps.MouseButton1Click:Connect(function()
    unlockFps = not unlockFps; MAX_FPS = unlockFps and 10000 or 500
    applyAppleTween(btnMaxFps, {BackgroundColor3 = unlockFps and globalAccentColor or Color3.fromRGB(60, 60, 70)})
    applyAppleTween(knobMaxFps, {Position = unlockFps and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
    local tPos = sliderTrack.AbsolutePosition.X; local tSz = sliderTrack.AbsoluteSize.X; local cur = sliderKnob.AbsolutePosition.X
    local rt = math.clamp((cur - tPos)/tSz, 0, 1); local nf = math.floor(MIN_FPS + (rt * (MAX_FPS - MIN_FPS)))
    titleLabel.Text = string.format("Target Limit: %d FPS", nf); if setfpscap then pcall(setfpscap, nf) elseif set_fps_cap then pcall(set_fps_cap, nf) end
end))

table.insert(connections, btnAutoExec.MouseButton1Click:Connect(function()
    autoExec = not autoExec
    applyAppleTween(btnAutoExec, {BackgroundColor3 = autoExec and globalAccentColor or Color3.fromRGB(60, 60, 70)})
    applyAppleTween(knobAutoExec, {Position = autoExec and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
    local qot = (syn and syn.queue_on_teleport) or queue_on_teleport
    if qot then qot([[loadstring(game:HttpGet("https://raw.githubusercontent.com/SyroxTech/FPS/main/script.lua"))()]]) end
end))

-- RESTART SCRIPT HANDLER
table.insert(connections, btnRestartScript.MouseButton1Click:Connect(function()
    env.SYROX_RUNNING = false
    if screenGui then screenGui:Destroy() end
    task.wait(0.1)
    -- Yeniden başlatma simülasyonu
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="HYPERWORK", Text="Restarting script...", Duration=2}) end)
end))

-- REJOIN SERVER HANDLER
table.insert(connections, btnRejoin.MouseButton1Click:Connect(function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
end))

local function toggleSt(name, state, tOn, tOff)
    local mod = activeModules[name]
    mod.IsActive = state
    mod.Btn.Text = state and tOn or tOff
    applyAppleTween(mod.Btn, {TextColor3 = state and globalAccentColor or Color3.fromRGB(200, 200, 210)}, 0.3)
    applyAppleTween(mod.Stroke, {Color = state and globalAccentColor or Color3.fromRGB(255, 255, 255), Transparency = state and 0.5 or 0.8}, 0.3)
end

local isLow, isShdw, isCast, isTex, isPart = false, true, true, false, false
local isHigh, isWater, isGlow, isAud, isGui = true, true, true, true, false
local is3d, isCpu, isNet, isPhys = true, true, true, false, false
isGc = true

toggleSt("BtnShadows", isShdw, "SHADOWS: ON", "SHADOWS: OFF")
toggleSt("BtnCastS", isCast, "CAST-SHDW: ON", "CAST-SHDW: OFF")
toggleSt("BtnHigh", isHigh, "HIGHLIGHTS: ON", "HIGHLIGHTS: OFF")
toggleSt("BtnWater", isWater, "WATER: HIGH", "WATER: LOW")
toggleSt("BtnGlow", isGlow, "POST-FX: ON", "POST-FX: OFF")
toggleSt("BtnAudio", isAud, "3D AUDIO: ON", "3D AUDIO: OFF")
toggleSt("Btn3d", is3d, "NO RENDER: OFF", "NO RENDER: ON")
toggleSt("BtnGc", isGc, "AUTO GC: ON", "AUTO GC: OFF")
toggleSt("BtnCpu", isCpu, "CPU T-MAX: ON", "CPU T-MAX: OFF")

local function asyncProcessDescendants(actionFunc)
    task.spawn(function()
        local descendants = workspace:GetDescendants()
        for i, v in ipairs(descendants) do pcall(actionFunc, v); if i % 150 == 0 then RunService.Heartbeat:Wait() end end
    end)
end

table.insert(connections, btnLowGfx.MouseButton1Click:Connect(function() isLow = not isLow; toggleSt("BtnLowGfx", isLow, "LOW GFX: ON", "LOW GFX: OFF"); asyncProcessDescendants(function(v) if v:IsA("BasePart") then v.Material = isLow and Enum.Material.SmoothPlastic or Enum.Material.Plastic end end) end))
table.insert(connections, btnShadows.MouseButton1Click:Connect(function() isShdw = not isShdw; toggleSt("BtnShadows", isShdw, "SHADOWS: ON", "SHADOWS: OFF"); pcall(function() Lighting.GlobalShadows = isShdw end) end))
table.insert(connections, btnCastS.MouseButton1Click:Connect(function() isCast = not isCast; toggleSt("BtnCastS", isCast, "CAST-SHDW: ON", "CAST-SHDW: OFF"); asyncProcessDescendants(function(v) if v:IsA("BasePart") then v.CastShadow = isCast end end) end))
table.insert(connections, btnTex.MouseButton1Click:Connect(function() isTex = not isTex; toggleSt("BtnTex", isTex, "TEXTURES: LOW", "TEXTURES: HIGH"); asyncProcessDescendants(function(v) if v:IsA("Texture") or v:IsA("Decal") then v.Transparency = isTex and 1 or 0 end end) end))
table.insert(connections, btnPart.MouseButton1Click:Connect(function() isPart = not isPart; toggleSt("BtnPart", isPart, "PARTICLES: OFF", "PARTICLES: ON"); asyncProcessDescendants(function(v) if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") then v.Enabled = not isPart end end) end))
table.insert(connections, btnHigh.MouseButton1Click:Connect(function() isHigh = not isHigh; toggleSt("BtnHigh", isHigh, "HIGHLIGHTS: ON", "HIGHLIGHTS: OFF"); asyncProcessDescendants(function(v) if v:IsA("Highlight") then v.Enabled = isHigh end end) end))
table.insert(connections, btnWater.MouseButton1Click:Connect(function() isWater = not isWater; toggleSt("BtnWater", isWater, "WATER: HIGH", "WATER: LOW"); pcall(function() local t = workspace.Terrain; t.WaterWaveSize = isWater and 0.15 or 0; t.WaterWaveSpeed = isWater and 10 or 0; t.WaterReflectance = isWater and 1 or 0 end) end))
table.insert(connections, btnGlow.MouseButton1Click:Connect(function() isGlow = not isGlow; toggleSt("BtnGlow", isGlow, "POST-FX: ON", "POST-FX: OFF"); asyncProcessDescendants(function(v) if v:IsA("PostEffect") then v.Enabled = isGlow end end) end))
table.insert(connections, btnAudio.MouseButton1Click:Connect(function() isAud = not isAud; toggleSt("BtnAudio", isAud, "3D AUDIO: ON", "3D AUDIO: MUTED"); pcall(function() game:GetService("SoundService").AmbientReverb = isAud and Enum.ReverbType.NoReverb or Enum.ReverbType.NoReverb end) end))
table.insert(connections, btnGui.MouseButton1Click:Connect(function() isGui = not isGui; toggleSt("BtnGui", isGui, "HIDE GUIS: ON", "HIDE GUIS: OFF"); pcall(function() for _, g in ipairs(Players.LocalPlayer.PlayerGui:GetChildren()) do if g.Name ~= "FPSCapUI" and g:IsA("ScreenGui") then g.Enabled = not isGui end end end) end))
table.insert(connections, btn3d.MouseButton1Click:Connect(function() is3d = not is3d; toggleSt("Btn3d", is3d, "NO RENDER: OFF", "NO RENDER: ON"); pcall(function() RunService:Set3dRenderingEnabled(is3d) end) end))
table.insert(connections, btnGc.MouseButton1Click:Connect(function() isGc = not isGc; toggleSt("BtnGc", isGc, "AUTO GC: ON", "AUTO GC: OFF") end))
table.insert(connections, btnCpu.MouseButton1Click:Connect(function() isCpu = not isCpu; toggleSt("BtnCpu", isCpu, "CPU T-MAX: ON", "CPU T-MAX: OFF"); if setthreadidentity then pcall(setthreadidentity, isCpu and 7 or 2) end end))
table.insert(connections, btnNet.MouseButton1Click:Connect(function() isNet = not isNet; toggleSt("BtnNet", isNet, "NET BOOST: ON", "NET BOOST: OFF"); pcall(function() settings().Network.IncomingReplicationLag = isNet and 0 or 0 end) end))
table.insert(connections, btnPhys.MouseButton1Click:Connect(function() isPhys = not isPhys; toggleSt("BtnPhys", isPhys, "PHYSICS: LOW", "PHYSICS: HIGH"); pcall(function() settings().Physics.PhysicsEnvironmentalThrottle = isPhys and Enum.EnviromentalPhysicsThrottle.SkipEveryOtherFrame or Enum.EnviromentalPhysicsThrottle.Disabled end) end))

local gfxLvlState = 0
local gfxMap = {{Enum.QualityLevel.Automatic, "AUTO"}, {Enum.QualityLevel.Level01, "1"}, {Enum.QualityLevel.Level10, "10"}, {Enum.QualityLevel.Level21, "21"}}
table.insert(connections, btnGfxLvl.MouseButton1Click:Connect(function()
    gfxLvlState = (gfxLvlState % 4) + 1; pcall(function() settings().Rendering.QualityLevel = gfxMap[gfxLvlState][1] end)
    btnGfxLvl.Text = "GFX LVL: " .. gfxMap[gfxLvlState][2]; strGfxLvl.Color = Color3.fromRGB(255, 150, 0); strGfxLvl.Transparency = 0.5
    task.delay(0.2, function() strGfxLvl.Color = Color3.fromRGB(255,255,255); strGfxLvl.Transparency = 0.8 end)
end))
local currentState, tapCount, isDraggingMoved, isIntroPlaying = 0, 0, false, true
local draggingPill, draggingSlider = false, false
local pillDragStart, startPos = nil, nil
local confirmStep = 0

local function minimizeMenu()
    currentState = 1; contentContainer.Visible = false; local cur = mainFrame.Position
    applyAppleTween(mainFrame, {Size = UDim2.new(0, 90, 0, 16), Position = UDim2.new(cur.X.Scale, cur.X.Offset, cur.Y.Scale, cur.Y.Offset - 97)})
    applyAppleTween(uiCorner, {CornerRadius = UDim.new(0, 8)}); applyAppleTween(outerAura, {Size = UDim2.new(1, 4, 1, 4)})
    applyAppleTween(headerPill, {Size = UDim2.new(1, -12, 0, 5), Position = UDim2.new(0.5, 0, 0.5, 0)})
end

local function maximizeMenu()
    currentState = 0; local cur = mainFrame.Position
    applyAppleTween(mainFrame, {Size = UDim2.new(0, 270, 0, 210), Position = UDim2.new(cur.X.Scale, cur.X.Offset, cur.Y.Scale, cur.Y.Offset + 97)})
    applyAppleTween(uiCorner, {CornerRadius = UDim.new(0, 16)}); applyAppleTween(outerAura, {Size = UDim2.new(1, 6, 1, 6)})
    applyAppleTween(headerPill, {Size = UDim2.new(0, 50, 0, 6), Position = UDim2.new(0.5, 0, 0, 11)})
    task.delay(0.1, function() if currentState == 0 then contentContainer.Visible = true end end)
end

-- COEMS🥶 CLOSING MECHANISM BTW
local function startCloseSequence()
    confirmStep = 1
    confirmTitle.Text = "Do you want to close the script?"
    openPage(confirmPage)
end

table.insert(connections, btnConfirmNope.MouseButton1Click:Connect(function()
    if confirmStep == 1 then
        openPage(mainPage)
        confirmStep = 0
    elseif confirmStep == 2 then
        -- REVERTING TO ORIGINAL GAME STATE
        pcall(function()
            Lighting.GlobalShadows = origSettings.GlobalShadows
            settings().Rendering.QualityLevel = origSettings.QualityLevel
            local t = workspace.Terrain
            t.WaterWaveSize = origSettings.WaterWaveSize
            t.WaterWaveSpeed = origSettings.WaterWaveSpeed
            t.WaterReflectance = origSettings.WaterReflectance
            RunService:Set3dRenderingEnabled(true)
        end)
        asyncProcessDescendants(function(v)
            if v:IsA("BasePart") then v.Material = Enum.Material.Plastic; v.CastShadow = true end
            if v:IsA("Texture") or v:IsA("Decal") then v.Transparency = 0 end
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") then v.Enabled = true end
            if v:IsA("Highlight") then v.Enabled = true end
            if v:IsA("PostEffect") then v.Enabled = true end
        end)
        env.SYROX_RUNNING = false
        if screenGui then screenGui:Destroy() end
    end
end))

table.insert(connections, btnConfirmYes.MouseButton1Click:Connect(function()
    if confirmStep == 1 then
        confirmStep = 2
        local fadeOut = TweenService:Create(fadeCurtain, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0}); fadeOut:Play()
        fadeOut.Completed:Connect(function()
            confirmTitle.Text = "Do you want the changes to persist?"
            local fadeIn = TweenService:Create(fadeCurtain, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {BackgroundTransparency = 1}); fadeIn:Play()
        end)
    elseif confirmStep == 2 then
        -- KEEP OPTIMIZATIONS ACTIVE (Değişiklikleri koruyarak kapat)
        env.SYROX_RUNNING = false
        if screenGui then screenGui:Destroy() end
    end
end))

table.insert(connections, btnClose.MouseButton1Click:Connect(function() startCloseSequence() end))
table.insert(connections, btnMin.MouseButton1Click:Connect(function() if currentState == 0 then minimizeMenu() end end))

table.insert(connections, headerPillTouch.InputBegan:Connect(function(input)
    if isIntroPlaying then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingPill = true; isDraggingMoved = false; pillDragStart = input.Position; startPos = mainFrame.Position
    end
end))
table.insert(connections, UserInputService.InputChanged:Connect(function(input)
    if isIntroPlaying then return end
    if draggingPill and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - pillDragStart
        if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then isDraggingMoved = true end
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end))
table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if isIntroPlaying then return end
    if draggingPill and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        draggingPill = false; if isDraggingMoved then return end
        tapCount = tapCount + 1
        if tapCount == 1 then
            task.delay(0.22, function()
                if tapCount == 1 then
                    if currentState == 1 or currentState == 2 then maximizeMenu() end
                end; tapCount = 0
            end)
        elseif tapCount == 2 then
            tapCount = 0
            if currentState == 0 then
                if useWinCtrl then return end
                minimizeMenu()
            elseif currentState == 1 then
                if useWinCtrl then maximizeMenu() return end
                currentState = 2; contentContainer.Visible = false; local cur = mainFrame.Position
                applyAppleTween(mainFrame, {Size = UDim2.new(0, 36, 0, 36), Position = UDim2.new(cur.X.Scale, cur.X.Offset, cur.Y.Scale, cur.Y.Offset + 10)})
                applyAppleTween(uiCorner, {CornerRadius = UDim.new(1, 0)}); applyAppleTween(outerAura, {Size = UDim2.new(1, 4, 1, 4)})
            elseif currentState == 2 then startCloseSequence() end
        end
    end
end))

local function updateSlider(x)
    local tPos = sliderTrack.AbsolutePosition.X; local tSz = sliderTrack.AbsoluteSize.X
    local ratio = math.clamp((x - tPos) / tSz, 0, 1); local fps = math.floor(MIN_FPS + (ratio * (MAX_FPS - MIN_FPS)))
    sliderFill.Size = UDim2.new(ratio, 0, 1, 0); sliderKnob.Position = UDim2.new(ratio, -9, 0.5, -9)
    titleLabel.Text = string.format("Target FPS: %d FPS", fps); return fps
end
table.insert(connections, UserInputService.InputBegan:Connect(function(input)
    if isIntroPlaying then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local pos, tPos, tSz = input.Position, sliderTrack.AbsolutePosition, sliderTrack.AbsoluteSize
        if pos.X >= tPos.X-15 and pos.X <= tPos.X+tSz.X+15 and pos.Y >= tPos.Y-20 and pos.Y <= tPos.Y+tSz.Y+20 then draggingSlider = true; updateSlider(pos.X) end
    end
end))
table.insert(connections, UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input.Position.X) end
end))
table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        draggingSlider = false; local f = updateSlider(input.Position.X)
        if setfpscap then pcall(setfpscap, f) elseif set_fps_cap then pcall(set_fps_cap, f) end
        applyAppleTween(effectBarGlow, {Size = UDim2.new(math.clamp((f-MIN_FPS)/(MAX_FPS-MIN_FPS),0,1),0,1,0), BackgroundColor3 = Color3.fromRGB(0,255,180)})
        task.delay(0.3, function() TweenService:Create(effectBarGlow, TweenInfo.new(0.4), {BackgroundColor3 = globalAccentColor}):Play() end)
    end
end))

task.spawn(function() while true do task.wait(5); if isGc then pcall(function() collectgarbage("step", 150) end) end end end)

local lastTime, fCount = os.clock(), 0
table.insert(connections, RunService.RenderStepped:Connect(function()
    fCount = fCount + 1; local curr = os.clock()
    if curr - lastTime >= 0.5 then
        fpsDisplay.Text = string.format("Current FPS: %d", math.floor(fCount / (curr - lastTime)))
        fCount = 0; lastTime = curr
    end
end))

screenGui.Parent = targetGui

task.spawn(function()
    applyAppleTween(mainFrame, {Size = UDim2.new(0, 130, 0, 130)}, 0.6); task.wait(0.5)
    TweenService:Create(introText, TweenInfo.new(0.6), {TextTransparency = 0}):Play(); task.wait(1.5)
    TweenService:Create(introText, TweenInfo.new(0.4), {TextTransparency = 1}):Play(); task.wait(0.3)
    applyAppleTween(mainFrame, {Size = UDim2.new(0, 80, 0, 80)}, 0.4); task.wait(0.3)
    applyAppleTween(mainFrame, {Size = UDim2.new(0, 90, 0, 16)}, 0.5)
    applyAppleTween(uiCorner, {CornerRadius = UDim.new(0, 8)}, 0.5); task.wait(0.4)
    TweenService:Create(auraStroke, TweenInfo.new(0.3), {Transparency = 0.65}):Play()
    TweenService:Create(headerPill, TweenInfo.new(0.3), {BackgroundTransparency = 0.2}):Play()
    introText:Destroy(); task.wait(0.2)
    applyAppleTween(mainFrame, {Size = UDim2.new(0, 270, 0, 210)}, 0.5)
    applyAppleTween(uiCorner, {CornerRadius = UDim.new(0, 16)}, 0.5)
    applyAppleTween(headerPill, {Size = UDim2.new(0, 50, 0, 6), Position = UDim2.new(0.5, 0, 0, 11)}, 0.5); task.wait(0.3)
    contentContainer.Visible = true; isIntroPlaying = false
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="HYPERWORK", Text="Ready to boost your experience", Duration=3}) end)
end)

-- [[ HYPER|HUB - 3D MASCOT INTRO (REWORKED & FIXED RE-EXECUTE FLOW) ]]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Chat = game:GetService("Chat")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

_G.HyperExecuteCount = _G.HyperExecuteCount or 0
_G.HyperInCooldown = _G.HyperInCooldown or false
_G.HyperPause = _G.HyperPause or false

-- SPAM / RE-EXECUTE VE CEZA KONTROLÜ
if _G.HyperPetActive then
    if _G.HyperInCooldown then return end
    
    _G.HyperExecuteCount = _G.HyperExecuteCount + 1
    _G.HyperInCooldown = true
    _G.HyperPause = true

    task.spawn(function()
        if _G.HyperExecuteCount == 1 then
            if _G.HyperPetHead then Chat:Chat(_G.HyperPetHead, "i tought i already executed the script...", Enum.ChatColor.White) end
            if _G.TriggerBounceFunc then _G.TriggerBounceFunc() end
            task.wait(1.5)
        elseif _G.HyperExecuteCount == 2 then
            if _G.HyperPetHead then Chat:Chat(_G.HyperPetHead, "Do you even hear what i say?", Enum.ChatColor.Red) end
            if _G.SetRedHornsFunc then _G.SetRedHornsFunc() end
            if _G.TriggerBounceFunc then _G.TriggerBounceFunc() end
            task.wait(1.5)
        elseif _G.HyperExecuteCount >= 3 then
            if _G.SetRedHornsFunc then _G.SetRedHornsFunc() end
            if _G.SetBloodEyesFunc then _G.SetBloodEyesFunc() end
            
            if _G.HyperPetHead then Chat:Chat(_G.HyperPetHead, "you dont learn don't you...?!", Enum.ChatColor.Red) end
            if _G.TriggerBounceFunc then _G.TriggerBounceFunc() end
            task.wait(1.5)

            pcall(function()
                Lighting.Ambient = Color3.fromRGB(200, 0, 0)
                Lighting.OutdoorAmbient = Color3.fromRGB(255, 0, 0)
                Lighting.FogColor = Color3.fromRGB(15, 0, 0)
                Lighting.FogEnd = 60
                Lighting.FogStart = 0
                
                local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
                sky.SkyboxBk = "rbxassetid://2634494"
                sky.SkyboxDn = "rbxassetid://2634494"
                sky.SkyboxFt = "rbxassetid://2634494"
                sky.SkyboxLf = "rbxassetid://2634494"
                sky.SkyboxRt = "rbxassetid://2634494"
                sky.SkyboxUp = "rbxassetid://2634494"
            end)

            local staticSound = Instance.new("Sound")
            staticSound.SoundId = "rbxassetid://9114223178"
            staticSound.Volume = 4
            staticSound.Looped = true
            staticSound.Parent = SoundService
            staticSound:Play()

            local pGui = localPlayer:WaitForChild("PlayerGui")
            local punishGui = Instance.new("ScreenGui")
            punishGui.Name = "HyperPunishGui"
            punishGui.ResetOnSpawn = false
            punishGui.Parent = pGui

            local redOverlay = Instance.new("Frame")
            redOverlay.Size = UDim2.new(1, 0, 1, 0)
            redOverlay.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            redOverlay.BackgroundTransparency = 0.55
            redOverlay.Parent = punishGui

            local words = {"RUN", "HIDE", "ITS COMING", "PUNISHMENT", "IT'S TOO LATE"}
            local isPunishing = true

            task.spawn(function()
                while isPunishing do
                    local oof = Instance.new("Sound")
                    oof.SoundId = "rbxassetid://5143383166"
                    oof.Volume = 10
                    oof.Parent = SoundService
                    oof:Play()
                    game:GetService("Debris"):AddItem(oof, 1.5)
                    task.wait(0.09)
                end
            end)

            task.spawn(function()
                while isPunishing do
                    local txtLbl = Instance.new("TextLabel")
                    txtLbl.Size = UDim2.new(0, 250, 0, 60)
                    txtLbl.Position = UDim2.new(math.random(5, 75)/100, 0, math.random(5, 75)/100, 0)
                    txtLbl.BackgroundTransparency = 1
                    txtLbl.Font = Enum.Font.GothamBlack
                    txtLbl.Text = words[math.random(1, #words)]
                    txtLbl.TextColor3 = Color3.fromRGB(255, 0, 0)
                    txtLbl.TextSize = math.random(32, 55)
                    txtLbl.Parent = punishGui

                    local stroke = Instance.new("UIStroke", txtLbl)
                    stroke.Color = Color3.fromRGB(0, 0, 0)
                    stroke.Thickness = 3

                    task.spawn(function()
                        for i = 1, 10 do
                            txtLbl.Position = txtLbl.Position + UDim2.new(0, math.random(-10, 10), 0, math.random(-10, 10))
                            task.wait(0.03)
                        end
                        txtLbl:Destroy()
                    end)
                    task.wait(0.08)
                end
            end)

            -- 4.5. SANİYEDE YÜKSEK SESLİ JUMPSCARE SESİ
            task.delay(4.5, function()
                local jumpscareSound = Instance.new("Sound")
                jumpscareSound.SoundId = "rbxassetid://9069609267"
                jumpscareSound.Volume = 10
                jumpscareSound.Parent = SoundService
                jumpscareSound:Play()
            end)

            -- 6 SANİYE SONRA KICK
            task.wait(6)
            isPunishing = false
            localPlayer:Kick("YOU ARE PUNISHED")
        end
        
        _G.HyperInCooldown = false
        _G.HyperPause = false
    end)
    return
end

_G.HyperPetActive = true

-- MASKOT OLUŞTURMA
local petModel = Instance.new("Model")
petModel.Name = "HyperPet"
_G.HyperPetModel = petModel

local head = Instance.new("Part")
head.Name = "Head"
head.Shape = Enum.PartType.Ball
head.Size = Vector3.new(2.4, 2.4, 2.4)
head.Color = Color3.fromRGB(30, 30, 38)
head.Material = Enum.Material.Sand
head.CanCollide = false
head.Anchored = true
head.Parent = petModel
petModel.PrimaryPart = head

_G.HyperPetHead = head

local function createHornPart(size, color, mat)
    local p = Instance.new("WedgePart")
    p.Size = size
    p.Color = color
    p.Material = mat
    p.CanCollide = false
    p.Anchored = true
    p.Parent = petModel
    return p
end

local hBaseL = createHornPart(Vector3.new(0.3, 0.9, 0.6), Color3.fromRGB(0, 162, 255), Enum.Material.Glass)
local hTipL = createHornPart(Vector3.new(0.2, 0.7, 0.4), Color3.fromRGB(0, 215, 255), Enum.Material.Neon)
local hBaseR = createHornPart(Vector3.new(0.3, 0.9, 0.6), Color3.fromRGB(0, 162, 255), Enum.Material.Glass)
local hTipR = createHornPart(Vector3.new(0.2, 0.7, 0.4), Color3.fromRGB(0, 215, 255), Enum.Material.Neon)

_G.SetRedHornsFunc = function()
    hBaseL.Color = Color3.fromRGB(255, 0, 0)
    hTipL.Color = Color3.fromRGB(255, 50, 50)
    hBaseR.Color = Color3.fromRGB(255, 0, 0)
    hTipR.Color = Color3.fromRGB(255, 50, 50)
end

local eyeGUI = Instance.new("SurfaceGui")
eyeGUI.Face = Enum.NormalId.Front
eyeGUI.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
eyeGUI.PixelsPerStud = 50
eyeGUI.Parent = head

local eyeFrame = Instance.new("Frame")
eyeFrame.Size = UDim2.new(1, 0, 1, 0)
eyeFrame.BackgroundTransparency = 1
eyeFrame.Parent = eyeGUI

local eyeL, eyeR
local function createBigHappyEye(isLeft)
    local eye = Instance.new("Frame")
    eye.Size = UDim2.new(0, 34, 0, 20)
    eye.Position = isLeft and UDim2.new(0.18, 0, 0.35, 0) or UDim2.new(0.62, 0, 0.35, 0)
    eye.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    eye.BorderSizePixel = 0
    eye.Parent = eyeFrame
    Instance.new("UICorner", eye).CornerRadius = UDim.new(0.8, 0)
    return eye
end

eyeL = createBigHappyEye(true)
eyeR = createBigHappyEye(false)

_G.SetBloodEyesFunc = function()
    if eyeL and eyeR then
        eyeL.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        eyeR.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end

local function updatePetCFrame(cf)
    head.CFrame = cf
    hBaseL.CFrame = cf * CFrame.new(-0.75, 0.95, 0.25) * CFrame.Angles(math.rad(-40), math.rad(-5), math.rad(-12))
    hTipL.CFrame = hBaseL.CFrame * CFrame.new(0, 0.6, 0.2) * CFrame.Angles(math.rad(-25), 0, 0)
    hBaseR.CFrame = cf * CFrame.new(0.75, 0.95, 0.25) * CFrame.Angles(math.rad(-40), math.rad(5), math.rad(12))
    hTipR.CFrame = hBaseR.CFrame * CFrame.new(0, 0.6, 0.2) * CFrame.Angles(math.rad(-25), 0, 0)
end

petModel.Parent = workspace

-- TAKİP SİSTEMİ VE YERDEN ÇIKMA ANİMASYONU
local isFollowing = true
local targetPos = hrp.Position + (hrp.CFrame.LookVector * 4.5) + Vector3.new(0, 1.2, 0)
local currentPetPos = targetPos - Vector3.new(0, 6, 0)
local bounceOffsetY = 0
local isSpawning = true

task.spawn(function()
    head.Size = Vector3.new(0.2, 0.2, 0.2)
    local targetHeadSize = Vector3.new(2.4, 2.4, 2.4)
    local stretchHeadSize = Vector3.new(1.8, 3.2, 1.8)

    local spawnPosValue = Instance.new("Vector3Value")
    spawnPosValue.Value = currentPetPos
    
    spawnPosValue.Changed:Connect(function(val)
        currentPetPos = val
    end)

    local posTween = TweenService:Create(spawnPosValue, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Value = targetPos})
    local sizeTween = TweenService:Create(head, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = stretchHeadSize})
    
    posTween:Play()
    sizeTween:Play()
    
    task.wait(0.5)
    local normalizeSizeTween = TweenService:Create(head, TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = targetHeadSize})
    normalizeSizeTween:Play()
    
    posTween.Completed:Wait()
    spawnPosValue:Destroy()
    isSpawning = false
end)

local followConn
followConn = RunService.RenderStepped:Connect(function()
    if not isFollowing or not hrp or not hrp.Parent then return end
    if not isSpawning then
        local tPos = hrp.Position + (hrp.CFrame.LookVector * 4.5) + Vector3.new(0, 1.2, 0)
        currentPetPos = currentPetPos:Lerp(tPos, 0.1)
    end
    local lookCF = CFrame.new(currentPetPos + Vector3.new(0, bounceOffsetY, 0), hrp.Position)
    updatePetCFrame(lookCF)
end)

local function triggerSmoothBounce()
    task.spawn(function()
        task.wait(0.2)
        local startTime = os.clock()
        while os.clock() - startTime < 1.5 do
            local elapsed = os.clock() - startTime
            bounceOffsetY = math.abs(math.sin(elapsed * 7)) * 0.65
            task.wait(0.015)
        end
        local tweenVal = Instance.new("NumberValue")
        tweenVal.Value = bounceOffsetY
        tweenVal.Changed:Connect(function(val) bounceOffsetY = val end)
        local tw = TweenService:Create(tweenVal, TweenInfo.new(0.3), {Value = 0})
        tw:Play()
        tw.Completed:Wait()
        tweenVal:Destroy()
    end)
end

_G.TriggerBounceFunc = triggerSmoothBounce

local function waitUnpaused(duration)
    local timer = 0
    while timer < duration do
        if not _G.HyperPause then
            timer = timer + 0.1
        end
        task.wait(0.1)
    end
end

-- İLK ÇALIŞTIRMA SİNEMATİK AKIŞI
task.spawn(function()
    waitUnpaused(0.9)

    while _G.HyperPause do task.wait(0.1) end
    pcall(function() Chat:Chat(head, "hi, thank you for trying Hyper|FPS", Enum.ChatColor.White) end)
    triggerSmoothBounce()
    waitUnpaused(2.2)

    while _G.HyperPause do task.wait(0.1) end
    pcall(function() Chat:Chat(head, "i will need you to click anywhere on your screen now", Enum.ChatColor.White) end)
    triggerSmoothBounce()
    waitUnpaused(1.2)

    while _G.HyperPause do task.wait(0.1) end

    -- DOKUNMA EKRANI
    local pGui = localPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HyperDynamicGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = pGui

    local overlay = Instance.new("TextButton")
    overlay.Size = UDim2.new(2, 0, 2, 0)
    overlay.Position = UDim2.new(-0.5, 0, -0.5, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.Text = ""
    overlay.Parent = screenGui

    local clickText = Instance.new("TextLabel")
    clickText.Size = UDim2.new(0.6, 0, 0, 50)
    clickText.Position = UDim2.new(0.2, 0, 0.65, 0)
    clickText.BackgroundTransparency = 1
    clickText.Font = Enum.Font.GothamBold
    clickText.Text = "click anywhere on your screen"
    clickText.TextColor3 = Color3.fromRGB(255, 255, 255)
    clickText.TextSize = 18
    clickText.TextTransparency = 1
    clickText.Parent = overlay

    TweenService:Create(overlay, TweenInfo.new(0.6), {BackgroundTransparency = 0.5}):Play()
    TweenService:Create(clickText, TweenInfo.new(0.6), {TextTransparency = 0}):Play()

    local canClick = true
    local pressStartTime = 0
    local startPressPos = Vector2.new()

    overlay.InputBegan:Connect(function(input)
        if not canClick then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            pressStartTime = os.clock()
            startPressPos = Vector2.new(input.Position.X, input.Position.Y)
        end
    end)

    overlay.Activated:Connect(function(inputObject)
        if not canClick then return end
        
        local pressDuration = os.clock() - pressStartTime
        local currentClickPos = inputObject and inputObject.Position or UserInputService:GetMouseLocation()
        local dragDistance = (Vector2.new(currentClickPos.X, currentClickPos.Y) - startPressPos).Magnitude

        if pressStartTime > 0 and (pressDuration > 0.4 or dragDistance > 30) then
            pressStartTime = 0
            return
        end

        canClick = false
        overlay:Destroy()

        _G.HyperMainStart = true

        pcall(function() Chat:Chat(head, "enjoy using the script!", Enum.ChatColor.White) end)
        triggerSmoothBounce()
        
        task.wait(1.5)
        isFollowing = false
        if followConn then followConn:Disconnect() end
        
        for _, p in ipairs(petModel:GetDescendants()) do
            if p:IsA("BasePart") then
                TweenService:Create(p, TweenInfo.new(0.5), {Transparency = 1}):Play()
            end
        end
        task.wait(0.5)
        petModel:Destroy()
        
        _G.HyperPetActive = nil
        _G.HyperPetHead = nil
        _G.HyperPetModel = nil
        _G.TriggerBounceFunc = nil
        _G.SetRedHornsFunc = nil
        _G.SetBloodEyesFunc = nil
        _G.HyperExecuteCount = nil
        _G.HyperInCooldown = nil
        _G.HyperPause = nil
    end)
end)

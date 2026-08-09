local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local afkConn
local activeNotif = nil

local function createParticle(parent, color)
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0, 6, 0, 6)
    p.AnchorPoint = Vector2.new(0.5, 0.5)
    p.Position = UDim2.new(0.5, 0, 0.5, 0)
    p.BackgroundColor3 = color
    p.BorderSizePixel = 0
    p.ZIndex = 5
    p.Parent = parent

    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(1, 0)
    pc.Parent = p

    local angle = math.random(0, 360)
    local dist = math.random(60, 140)
    local dx = math.cos(math.rad(angle)) * dist
    local dy = math.sin(math.rad(angle)) * dist

    local tween = TweenService:Create(p, TweenInfo.new(
        math.random(55, 90) / 100,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    ), {
        Position = UDim2.new(0.5, dx, 0.5, dy),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 1, 0, 1),
    })

    tween:Play()
    tween.Completed:Connect(function()
        p:Destroy()
    end)
end

local function buildCheckmark(parent, color)
    local short = Instance.new("Frame")
    short.Name = "IconMark"
    short.Size = UDim2.new(0, 9, 0, 3)
    short.AnchorPoint = Vector2.new(0.5, 0.5)
    short.Position = UDim2.new(0.5, -6, 0.5, 2)
    short.Rotation = 45
    short.BackgroundColor3 = color
    short.BorderSizePixel = 0
    short.ZIndex = 6
    short.Parent = parent

    Instance.new("UICorner", short).CornerRadius = UDim.new(1, 0)

    local long = Instance.new("Frame")
    long.Name = "IconMark"
    long.Size = UDim2.new(0, 18, 0, 3)
    long.AnchorPoint = Vector2.new(0.5, 0.5)
    long.Position = UDim2.new(0.5, 4, 0.5, -3)
    long.Rotation = -45
    long.BackgroundColor3 = color
    long.BorderSizePixel = 0
    long.ZIndex = 6
    long.Parent = parent

    Instance.new("UICorner", long).CornerRadius = UDim.new(1, 0)
end

local function buildXMark(parent, color)
    for _, rot in ipairs({45, -45}) do
        local bar = Instance.new("Frame")
        bar.Name = "IconMark"
        bar.Size = UDim2.new(0, 20, 0, 3)
        bar.AnchorPoint = Vector2.new(0.5, 0.5)
        bar.Position = UDim2.new(0.5, 0, 0.5, 0)
        bar.Rotation = rot
        bar.BackgroundColor3 = color
        bar.BorderSizePixel = 0
        bar.ZIndex = 6
        bar.Parent = parent

        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    end
end

local function createNotification()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AntiAfkNotif"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.AnchorPoint = Vector2.new(0.5, 0)
    glow.Position = UDim2.new(0.5, 0, 0, -140)
    glow.Size = UDim2.new(0, 460, 0, 180)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxasset://textures/ui/Shadow.png"
    glow.ImageColor3 = Color3.fromRGB(120, 200, 255)
    glow.ImageTransparency = 0.35
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(10, 10, 118, 118)
    glow.ZIndex = 1
    glow.Parent = screenGui

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.AnchorPoint = Vector2.new(0.5, 0)
    container.Position = UDim2.new(0.5, 0, 0, -140)
    container.Size = UDim2.new(0, 340, 0, 84)
    container.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    container.BorderSizePixel = 0
    container.ZIndex = 3
    container.Parent = screenGui

    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 18)

    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 18)),
    })
    fillGradient.Rotation = 100
    fillGradient.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2.5
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.15
    stroke.Parent = container

    local strokeGradient = Instance.new("UIGradient")
    strokeGradient.Parent = stroke

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 18)
    pad.PaddingRight = UDim.new(0, 18)
    pad.Parent = container

    local iconHolder = Instance.new("Frame")
    iconHolder.Name = "IconHolder"
    iconHolder.Size = UDim2.new(0, 48, 0, 48)
    iconHolder.Position = UDim2.new(0, 0, 0.5, 0)
    iconHolder.AnchorPoint = Vector2.new(0, 0.5)
    iconHolder.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    iconHolder.ZIndex = 4
    iconHolder.Parent = container

    Instance.new("UICorner", iconHolder).CornerRadius = UDim.new(1, 0)

    local iconStroke = Instance.new("UIStroke")
    iconStroke.Thickness = 2
    iconStroke.Parent = iconHolder

    local textHolder = Instance.new("Frame")
    textHolder.Position = UDim2.new(0, 64, 0, 0)
    textHolder.Size = UDim2.new(1, -64, 1, 0)
    textHolder.BackgroundTransparency = 1
    textHolder.ZIndex = 4
    textHolder.Parent = container

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Position = UDim2.new(0, 0, 0, 14)
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 19
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "ANTI-AFK"
    title.ZIndex = 5
    title.Parent = textHolder

    local titleGradient = Instance.new("UIGradient")
    titleGradient.Parent = title

    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Position = UDim2.new(0, 0, 0, 40)
    subtitle.Size = UDim2.new(1, 0, 0, 18)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 13
    subtitle.TextColor3 = Color3.fromRGB(190, 190, 200)
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Text = "Status updated"
    subtitle.ZIndex = 5
    subtitle.Parent = textHolder

    local barBg = Instance.new("Frame")
    barBg.Position = UDim2.new(0, 18, 1, -8)
    barBg.Size = UDim2.new(1, -36, 0, 3)
    barBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    barBg.BackgroundTransparency = 0.9
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 4
    barBg.Parent = container

    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(1, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    barFill.BorderSizePixel = 0
    barFill.ZIndex = 4
    barFill.Parent = barBg

    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

    return screenGui, container, glow, subtitle, title, stroke, strokeGradient,
        titleGradient, iconHolder, iconStroke, barFill
end

local function showAntiAfkNotification(state)
    if activeNotif then
        activeNotif:Destroy()
        activeNotif = nil
    end

    local screenGui, container, glow, subtitle, title, stroke, strokeGradient,
        titleGradient, iconHolder, iconStroke, barFill = createNotification()

    activeNotif = screenGui

    local mainColor, secondColor

    if state then
        mainColor = Color3.fromRGB(90, 255, 170)
        secondColor = Color3.fromRGB(70, 190, 255)
        subtitle.Text = "You're safe — idle kicks disabled"
        buildCheckmark(iconHolder, mainColor)
    else
        mainColor = Color3.fromRGB(255, 110, 110)
        secondColor = Color3.fromRGB(255, 170, 90)
        subtitle.Text = "Disabled — idle kicks are back on"
        buildXMark(iconHolder, mainColor)
    end

    glow.ImageColor3 = mainColor
    iconStroke.Color = mainColor

    titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, mainColor),
    })

    strokeGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, mainColor),
        ColorSequenceKeypoint.new(0.5, secondColor),
        ColorSequenceKeypoint.new(1, mainColor),
    })

    barFill.BackgroundColor3 = mainColor

    local running = true

    task.spawn(function()
        local t = 0

        while running and strokeGradient.Parent do
            t = t + RunService.Heartbeat:Wait()
            strokeGradient.Rotation = (strokeGradient.Rotation + 4) % 360
            iconStroke.Transparency = 0.35 + math.abs(math.sin(t * 2)) * 0.5
        end
    end)

    container.Size = UDim2.new(0, 300, 0, 70)
    container.BackgroundTransparency = 1

    for _, d in ipairs(container:GetDescendants()) do
        if d:IsA("TextLabel") then
            d.TextTransparency = 1
        elseif d:IsA("Frame") and d.Name == "IconMark" then
            d.BackgroundTransparency = 1
        elseif d:IsA("Frame") and d.Name ~= "BorderGlow" then
            d.BackgroundTransparency = 1
        end
    end

    glow.ImageTransparency = 1

    TweenService:Create(container, TweenInfo.new(
        0.6,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    ), {
        Position = UDim2.new(0.5, 0, 0, 28),
        Size = UDim2.new(0, 340, 0, 84),
        BackgroundTransparency = 0,
    }):Play()

    TweenService:Create(glow, TweenInfo.new(
        0.7,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    ), {
        Position = UDim2.new(0.5, 0, 0, 28 - 48),
        ImageTransparency = 0.35,
    }):Play()

    task.delay(0.15, function()
        for _, d in ipairs(container:GetDescendants()) do
            if d:IsA("TextLabel") then
                TweenService:Create(d, TweenInfo.new(0.4), {
                    TextTransparency = 0
                }):Play()
            elseif d:IsA("Frame") and d.Name == "IconMark" then
                TweenService:Create(d, TweenInfo.new(0.4), {
                    BackgroundTransparency = 0
                }):Play()
            end
        end
    end)

    task.delay(0.55, function()
        for i = 1, 14 do
            createParticle(container, i % 2 == 0 and mainColor or secondColor)
        end
    end)

    local displayTime = 5

    TweenService:Create(barFill, TweenInfo.new(
        displayTime,
        Enum.EasingStyle.Linear
    ), {
        Size = UDim2.new(0, 0, 1, 0),
    }):Play()

    task.delay(displayTime, function()
        running = false

        if container and container.Parent then
            local dropOut = TweenService:Create(container, TweenInfo.new(
                0.45,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.In
            ), {
                Position = UDim2.new(0.5, 0, 0, -140),
                BackgroundTransparency = 1,
            })

            TweenService:Create(glow, TweenInfo.new(
                0.45,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.In
            ), {
                Position = UDim2.new(0.5, 0, 0, -180),
                ImageTransparency = 1,
            }):Play()

            for _, d in ipairs(container:GetDescendants()) do
                if d:IsA("TextLabel") then
                    TweenService:Create(d, TweenInfo.new(0.3), {
                        TextTransparency = 1
                    }):Play()
                elseif d:IsA("Frame") and d.Name == "IconMark" then
                    TweenService:Create(d, TweenInfo.new(0.3), {
                        BackgroundTransparency = 1
                    }):Play()
                end
            end

            dropOut:Play()

            dropOut.Completed:Connect(function()
                screenGui:Destroy()

                if activeNotif == screenGui then
                    activeNotif = nil
                end
            end)
        end
    end)
end

local function setAntiAfk(state)
    if afkConn then
        afkConn:Disconnect()
        afkConn = nil
    end

    if not state then
        showAntiAfkNotification(false)
        return
    end

    afkConn = player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    showAntiAfkNotification(true)
end

setAntiAfk(true)
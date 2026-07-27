if game.PlaceId ~= 93829858358973 then
    return
end

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

pcall(function()
    CoreGui:FindFirstChild("ModernLoopGUI"):Destroy()
end)

local running = false
local guiVisible = true

local function tween(object, properties, duration)
    TweenService:Create(
        object,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties
    ):Play()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernLoopGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.Size = UDim2.fromOffset(320, 180)
Main.Position = UDim2.new(0.5, -160, 0.5, -90)
Main.BackgroundColor3 = Color3.fromRGB(20, 21, 27)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(55, 58, 72)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.2
MainStroke.Parent = Main

local TopBar = Instance.new("Frame")
TopBar.Parent = Main
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 26, 34)
TopBar.BorderSizePixel = 0

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 14)
TopCorner.Parent = TopBar

local TopFix = Instance.new("Frame")
TopFix.Parent = TopBar
TopFix.Position = UDim2.new(0, 0, 1, -14)
TopFix.Size = UDim2.new(1, 0, 0, 14)
TopFix.BackgroundColor3 = TopBar.BackgroundColor3
TopFix.BorderSizePixel = 0

local Accent = Instance.new("Frame")
Accent.Parent = TopBar
Accent.Size = UDim2.fromOffset(4, 22)
Accent.Position = UDim2.fromOffset(15, 13)
Accent.BackgroundColor3 = Color3.fromRGB(108, 92, 231)
Accent.BorderSizePixel = 0

local AccentCorner = Instance.new("UICorner")
AccentCorner.CornerRadius = UDim.new(1, 0)
AccentCorner.Parent = Accent

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Position = UDim2.fromOffset(29, 7)
Title.Size = UDim2.new(1, -75, 0, 22)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "AUTOFARM"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

local Subtitle = Instance.new("TextLabel")
Subtitle.Parent = TopBar
Subtitle.Position = UDim2.fromOffset(29, 26)
Subtitle.Size = UDim2.new(1, -75, 0, 15)
Subtitle.BackgroundTransparency = 1
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "Press Insert to Hide | @zur on rscripts.net"
Subtitle.TextColor3 = Color3.fromRGB(135, 138, 155)
Subtitle.TextSize = 10
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

local StatusContainer = Instance.new("Frame")
StatusContainer.Parent = Main
StatusContainer.Position = UDim2.fromOffset(16, 64)
StatusContainer.Size = UDim2.new(1, -32, 0, 42)
StatusContainer.BackgroundColor3 = Color3.fromRGB(27, 28, 36)
StatusContainer.BorderSizePixel = 0

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 9)
StatusCorner.Parent = StatusContainer

local StatusStroke = Instance.new("UIStroke")
StatusStroke.Color = Color3.fromRGB(48, 50, 62)
StatusStroke.Transparency = 0.45
StatusStroke.Parent = StatusContainer

local StatusDot = Instance.new("Frame")
StatusDot.Parent = StatusContainer
StatusDot.Position = UDim2.fromOffset(14, 15)
StatusDot.Size = UDim2.fromOffset(12, 12)
StatusDot.BackgroundColor3 = Color3.fromRGB(235, 80, 80)
StatusDot.BorderSizePixel = 0

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot

local StatusText = Instance.new("TextLabel")
StatusText.Parent = StatusContainer
StatusText.Position = UDim2.fromOffset(36, 0)
StatusText.Size = UDim2.new(1, -46, 1, 0)
StatusText.BackgroundTransparency = 1
StatusText.Font = Enum.Font.GothamMedium
StatusText.Text = "Loop is currently disabled"
StatusText.TextColor3 = Color3.fromRGB(185, 187, 200)
StatusText.TextSize = 12
StatusText.TextXAlignment = Enum.TextXAlignment.Left

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Main
ToggleButton.Position = UDim2.fromOffset(16, 119)
ToggleButton.Size = UDim2.new(1, -32, 0, 44)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 41, 52)
ToggleButton.BorderSizePixel = 0
ToggleButton.AutoButtonColor = false
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "ENABLE LOOP"
ToggleButton.TextColor3 = Color3.fromRGB(225, 225, 235)
ToggleButton.TextSize = 13

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = ToggleButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Color = Color3.fromRGB(68, 70, 87)
ButtonStroke.Transparency = 0.35
ButtonStroke.Parent = ToggleButton

local Scale = Instance.new("UIScale")
Scale.Scale = 1
Scale.Parent = Main

local function updateState()
    if running then
        ToggleButton.Text = "DISABLE LOOP"
        StatusText.Text = "Loop is currently running"

        tween(ToggleButton, {
            BackgroundColor3 = Color3.fromRGB(108, 92, 231)
        })

        tween(StatusDot, {
            BackgroundColor3 = Color3.fromRGB(81, 207, 122)
        })

        tween(ButtonStroke, {
            Color = Color3.fromRGB(135, 122, 255)
        })
    else
        ToggleButton.Text = "ENABLE LOOP"
        StatusText.Text = "Loop is currently disabled"

        tween(ToggleButton, {
            BackgroundColor3 = Color3.fromRGB(40, 41, 52)
        })

        tween(StatusDot, {
            BackgroundColor3 = Color3.fromRGB(235, 80, 80)
        })

        tween(ButtonStroke, {
            Color = Color3.fromRGB(68, 70, 87)
        })
    end
end

ToggleButton.MouseEnter:Connect(function()
    if not running then
        tween(ToggleButton, {
            BackgroundColor3 = Color3.fromRGB(48, 49, 61)
        }, 0.15)
    end
end)

ToggleButton.MouseLeave:Connect(function()
    if not running then
        tween(ToggleButton, {
            BackgroundColor3 = Color3.fromRGB(40, 41, 52)
        }, 0.15)
    end
end)

ToggleButton.MouseButton1Down:Connect(function()
    tween(ToggleButton, {
        Size = UDim2.new(1, -38, 0, 40),
        Position = UDim2.fromOffset(19, 121)
    }, 0.08)
end)

ToggleButton.MouseButton1Up:Connect(function()
    tween(ToggleButton, {
        Size = UDim2.new(1, -32, 0, 44),
        Position = UDim2.fromOffset(16, 119)
    }, 0.1)
end)

ToggleButton.MouseButton1Click:Connect(function()
    running = not running
    updateState()

    if running then
        task.spawn(function()
            local Players = game:GetService("Players")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")

            local LocalPlayer = Players.LocalPlayer
            local Remotes = ReplicatedStorage:WaitForChild("Remotes")
            local Train = Remotes:WaitForChild("Train")
            local Rebirth = Remotes:WaitForChild("Rebirth")

            local targetPosition = Vector3.new(-5058.53, 69.14, 270.92)

            while running do
                local character = LocalPlayer.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")

                if root then
                    root.CFrame = CFrame.new(targetPosition)
                end

                Train:FireServer()

                task.spawn(function()
                    pcall(function()
                        Rebirth:InvokeServer()
                    end)
                end)

                task.wait(0.1)
            end
        end)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.Insert then
        guiVisible = not guiVisible

        if guiVisible then
            Main.Visible = true
            Scale.Scale = 0.85
            Main.BackgroundTransparency = 1

            tween(Scale, {
                Scale = 1
            }, 0.25)

            tween(Main, {
                BackgroundTransparency = 0
            }, 0.2)
        else
            tween(Scale, {
                Scale = 0.85
            }, 0.2)

            tween(Main, {
                BackgroundTransparency = 1
            }, 0.15)

            task.delay(0.2, function()
                if not guiVisible then
                    Main.Visible = false
                end
            end)
        end
    end
end)

updateState()
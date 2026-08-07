--[[
PixelGG -> UI Library
Game: https://www.roblox.com/games/445664957/PARKOUR-Legacy
--]]

local LIBRARY_URL =
    "https://raw.githubusercontent.com/PixelGG/DXForge/main/DXForge.lua"

if not _G.DXForgeBagESP then
    _G.DXForgeBagESP = {
        Initialized = false,

        Enabled = true,
        Boxes = true,
        Names = true,
        DistanceText = true,

        MaxDistance = 500,
        ScanInterval = 3,

        Bags = {},
        LastScan = 0
    }
end

local State = _G.DXForgeBagESP

local function Clamp(Value, Minimum, Maximum)
    if Value < Minimum then
        return Minimum
    end

    if Value > Maximum then
        return Maximum
    end

    return Value
end

local function GetDistance(Position1, Position2)
    if not Position1 or not Position2 then
        return math.huge
    end

    local X = Position1.x - Position2.x
    local Y = Position1.y - Position2.y
    local Z = Position1.z - Position2.z

    return math.sqrt(
        X * X +
        Y * Y +
        Z * Z
    )
end

local function IsOnScreen(Position, Screen)
    if not Position then
        return false
    end

    return Position.x > 0
        and Position.y > 0
        and Position.x < Screen.width
        and Position.y < Screen.height
end

if not State.Initialized then
    local LibrarySource = dx9.Get(LIBRARY_URL)

    if not LibrarySource then
        dx9.ShowConsole(true)
        print("Failed to download DXForge.")
        return
    end

    local LibraryFunction, LoadError =
        loadstring(LibrarySource)

    if not LibraryFunction then
        dx9.ShowConsole(true)
        print("Failed to load DXForge: " .. tostring(LoadError))
        return
    end

    local Success, DXForge =
        pcall(LibraryFunction)

    if not Success or not DXForge then
        dx9.ShowConsole(true)
        print("Failed to initialize DXForge.")
        return
    end

    State.DXForge = DXForge

    local Window = DXForge:CreateWindow({
        Title = "Bag ESP",
        Size = {540, 430},
        ToggleKey = "[INSERT]",
        Theme = "Default",
        Resizable = true
    })

    local VisualsTab = Window:AddTab("Visuals")

    local ESPBox =
        VisualsTab:AddGroupbox("Bag ESP", "left")

    local SettingsBox =
        VisualsTab:AddGroupbox("Settings", "right")

    ESPBox:AddToggle({
        Text = "Enable Bag ESP",
        Default = State.Enabled,
        Tooltip = "Enables or disables the entire bag ESP.",

        Callback = function(Value)
            State.Enabled = Value
        end
    })

    ESPBox:AddToggle({
        Text = "Draw Boxes",
        Default = State.Boxes,

        Callback = function(Value)
            State.Boxes = Value
        end
    })

    ESPBox:AddToggle({
        Text = "Show Names",
        Default = State.Names,

        Callback = function(Value)
            State.Names = Value
        end
    })

    ESPBox:AddToggle({
        Text = "Show Distance",
        Default = State.DistanceText,

        Callback = function(Value)
            State.DistanceText = Value
        end
    })

    SettingsBox:AddSlider({
        Text = "Maximum Distance",
        Min = 50,
        Max = 2000,
        Default = State.MaxDistance,
        Step = 25,
        Tooltip = "Maximum distance at which bags are displayed.",

        Callback = function(Value)
            State.MaxDistance = Value
        end
    })

    SettingsBox:AddSlider({
        Text = "Scan Interval",
        Min = 1,
        Max = 10,
        Default = State.ScanInterval,
        Step = 1,
        Tooltip = "Higher values reduce scanning and improve performance.",

        Callback = function(Value)
            State.ScanInterval = Value
        end
    })

    SettingsBox:AddButton({
        Text = "Refresh Bags",

        Callback = function()
            State.LastScan = 0
        end
    })

    DXForge:Notify({
        Text = "Bag ESP loaded successfully.",
        Type = "Success",
        Duration = 4
    })

    State.Window = Window
    State.Initialized = true
end

local DXForge = State.DXForge
local DataModel = dx9.GetDatamodel()

if not DataModel then
    DXForge:Render()
    return
end

local Workspace =
    dx9.FindFirstChild(DataModel, "Workspace")

if not Workspace then
    DXForge:Render()
    return
end

local function AddBagFromObject(Object, Results, Added)
    if not Object then
        return
    end

    local Main =
        dx9.FindFirstChild(Object, "Main")

    if not Main then
        return
    end

    local Hitbox =
        dx9.FindFirstChild(Main, "hitbox")

    if not Hitbox then
        Hitbox =
            dx9.FindFirstChild(Main, "Hitbox")
    end

    if Hitbox and not Added[Hitbox] then
        Added[Hitbox] = true
        Results[#Results + 1] = Hitbox
    end
end

local function ScanContainer(
    Container,
    Results,
    Added,
    CurrentDepth,
    MaximumDepth
)
    if not Container then
        return
    end

    local Children =
        dx9.GetChildren(Container)

    if not Children then
        return
    end

    for _, Child in next, Children do
        AddBagFromObject(
            Child,
            Results,
            Added
        )

        if CurrentDepth < MaximumDepth then
            ScanContainer(
                Child,
                Results,
                Added,
                CurrentDepth + 1,
                MaximumDepth
            )
        end
    end
end

local function RefreshBagCache()
    local Results = {}
    local Added = {}

    ScanContainer(
        Workspace,
        Results,
        Added,
        0,
        2
    )

    State.Bags = Results
    State.LastScan = os.clock()
end

local function UpdateBagCache()
    local CurrentTime = os.clock()

    if State.LastScan == 0
    or CurrentTime - State.LastScan >= State.ScanInterval then
        RefreshBagCache()
    end
end

local function DrawBag(
    Hitbox,
    LocalPosition,
    ScreenSize
)
    local BagPosition =
        dx9.GetPosition(Hitbox)

    if not BagPosition then
        return
    end

    local Distance =
        GetDistance(
            LocalPosition,
            BagPosition
        )

    if Distance > State.MaxDistance then
        return
    end

    local ScreenPosition =
        dx9.WorldToScreen({
            BagPosition.x,
            BagPosition.y,
            BagPosition.z
        })

    if not IsOnScreen(ScreenPosition, ScreenSize) then
        return
    end

    local X = ScreenPosition.x
    local Y = ScreenPosition.y

    local Scale =
        Clamp(
            1 - Distance / 1500,
            0.35,
            1
        )

    local BoxWidth = 75 * Scale
    local BoxHeight = 55 * Scale

    local Left = X - BoxWidth / 2
    local Right = X + BoxWidth / 2
    local Top = Y - BoxHeight / 2
    local Bottom = Y + BoxHeight / 2

    local ESPColor = {155, 75, 255}

    if State.Boxes then
        dx9.DrawBox(
            {Left, Top},
            {Right, Bottom},
            ESPColor
        )
    end

    local TextY = Top - 16

    if State.DistanceText then
        local DistanceString =
            "[" .. math.floor(Distance) .. " studs]"

        local DistanceWidth =
            dx9.CalcTextWidth(DistanceString)

        dx9.DrawString(
            {
                X - DistanceWidth / 2,
                TextY
            },
            {220, 220, 220},
            DistanceString
        )

        TextY = TextY - 16
    end

    if State.Names then
        local NameString = "Bag"
        local NameWidth =
            dx9.CalcTextWidth(NameString)

        dx9.DrawString(
            {
                X - NameWidth / 2,
                TextY
            },
            {255, 255, 255},
            NameString
        )
    end
end

if State.Enabled then
    UpdateBagCache()

    local LocalPlayer =
        dx9.get_localplayer()

    local ScreenSize =
        dx9.size()

    if LocalPlayer
    and LocalPlayer.Position
    and ScreenSize then
        for _, Hitbox in next, State.Bags do
            DrawBag(
                Hitbox,
                LocalPlayer.Position,
                ScreenSize
            )
        end
    end
end

DXForge:Render()
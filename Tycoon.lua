local GUI_NAME = "TycoonFarmGui"

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local guiParent = gethui and gethui() or CoreGui

local oldGui = guiParent:FindFirstChild(GUI_NAME)

if oldGui then
    oldGui:Destroy()
end

task.wait(0.1)

local function getCharacterRoot()
    local character = player.Character or player.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart")
end

local positions = {}
local sellPosition = nil

local ONE_TIME_TELEPORT_DELAY = 0.2
local ONE_TIME_PROMPT_DELAY = 0.1
local LOOP_TELEPORT_DELAY = 0.6
local LOOP_PROMPT_DELAY = 0.4

local loopEnabled = false
local collectRunning = false
local loopThreadRunning = false

-- UI

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.Parent = guiParent
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.78, 0, 0.48, 0)
Main.Size = UDim2.fromOffset(270, 340)
Main.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 7)
MainCorner.Parent = Main

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = Main
Header.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
Header.BorderSizePixel = 0
Header.Size = UDim2.new(1, 0, 0, 34)

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 7)
HeaderCorner.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Parent = Header
HeaderFix.BackgroundColor3 = Header.BackgroundColor3
HeaderFix.BorderSizePixel = 0
HeaderFix.Position = UDim2.new(0, 0, 1, -7)
HeaderFix.Size = UDim2.new(1, 0, 0, 7)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(10, 0)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "TYCOON FARM | @ic3-gov"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Parent = Main
TabBar.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
TabBar.BorderSizePixel = 0
TabBar.Position = UDim2.fromOffset(0, 34)
TabBar.Size = UDim2.new(1, 0, 0, 36)

local FarmTabButton = Instance.new("TextButton")
FarmTabButton.Name = "FarmTabButton"
FarmTabButton.Parent = TabBar
FarmTabButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
FarmTabButton.BorderSizePixel = 0
FarmTabButton.Position = UDim2.fromOffset(6, 5)
FarmTabButton.Size = UDim2.new(0.5, -9, 0, 26)
FarmTabButton.Font = Enum.Font.GothamBold
FarmTabButton.Text = "Farm"
FarmTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmTabButton.TextSize = 13

local FarmTabCorner = Instance.new("UICorner")
FarmTabCorner.CornerRadius = UDim.new(0, 5)
FarmTabCorner.Parent = FarmTabButton

local PositionsTabButton = Instance.new("TextButton")
PositionsTabButton.Name = "PositionsTabButton"
PositionsTabButton.Parent = TabBar
PositionsTabButton.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
PositionsTabButton.BorderSizePixel = 0
PositionsTabButton.Position = UDim2.new(0.5, 3, 0, 5)
PositionsTabButton.Size = UDim2.new(0.5, -9, 0, 26)
PositionsTabButton.Font = Enum.Font.GothamBold
PositionsTabButton.Text = "Positions"
PositionsTabButton.TextColor3 = Color3.fromRGB(190, 190, 190)
PositionsTabButton.TextSize = 13

local PositionsTabCorner = Instance.new("UICorner")
PositionsTabCorner.CornerRadius = UDim.new(0, 5)
PositionsTabCorner.Parent = PositionsTabButton

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Parent = Main
Content.BackgroundTransparency = 1
Content.Position = UDim2.fromOffset(0, 70)
Content.Size = UDim2.new(1, 0, 1, -70)

local FarmPage = Instance.new("Frame")
FarmPage.Name = "FarmPage"
FarmPage.Parent = Content
FarmPage.BackgroundTransparency = 1
FarmPage.Size = UDim2.fromScale(1, 1)
FarmPage.Visible = true

local PositionsPage = Instance.new("Frame")
PositionsPage.Name = "PositionsPage"
PositionsPage.Parent = Content
PositionsPage.BackgroundTransparency = 1
PositionsPage.Size = UDim2.fromScale(1, 1)
PositionsPage.Visible = false

local function createButton(parent, name, text, position, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = parent
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Position = position
    button.Size = UDim2.new(1, -24, 0, 43)
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.AutoButtonColor = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    return button
end

local function createScrollButton(parent, name, text, layoutOrder, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = parent
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, 0, 0, 43)
    button.LayoutOrder = layoutOrder
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.AutoButtonColor = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    return button
end

local Collect = createButton(
    FarmPage,
    "Collect",
    "Collect All",
    UDim2.fromOffset(12, 18),
    Color3.fromRGB(48, 48, 48)
)

local LoopCollect = createButton(
    FarmPage,
    "LoopCollect",
    "Auto Collect: OFF",
    UDim2.fromOffset(12, 72),
    Color3.fromRGB(170, 0, 0)
)

local FarmInfo = Instance.new("TextLabel")
FarmInfo.Name = "FarmInfo"
FarmInfo.Parent = FarmPage
FarmInfo.BackgroundTransparency = 1
FarmInfo.Position = UDim2.fromOffset(12, 130)
FarmInfo.Size = UDim2.new(1, -24, 0, 70)
FarmInfo.Font = Enum.Font.Gotham
FarmInfo.Text = "Save collection positions and a sell position before starting the farm."
FarmInfo.TextColor3 = Color3.fromRGB(175, 175, 175)
FarmInfo.TextSize = 12
FarmInfo.TextWrapped = true
FarmInfo.TextXAlignment = Enum.TextXAlignment.Left
FarmInfo.TextYAlignment = Enum.TextYAlignment.Top

local PositionsScroll = Instance.new("ScrollingFrame")
PositionsScroll.Name = "PositionsScroll"
PositionsScroll.Parent = PositionsPage
PositionsScroll.BackgroundTransparency = 1
PositionsScroll.BorderSizePixel = 0
PositionsScroll.Position = UDim2.fromOffset(0, 0)
PositionsScroll.Size = UDim2.new(1, 0, 1, 0)
PositionsScroll.CanvasSize = UDim2.fromOffset(0, 0)
PositionsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
PositionsScroll.ScrollBarThickness = 5
PositionsScroll.ScrollBarImageColor3 = Color3.fromRGB(115, 115, 115)
PositionsScroll.ScrollingDirection = Enum.ScrollingDirection.Y

local ScrollPadding = Instance.new("UIPadding")
ScrollPadding.Parent = PositionsScroll
ScrollPadding.PaddingTop = UDim.new(0, 10)
ScrollPadding.PaddingBottom = UDim.new(0, 12)
ScrollPadding.PaddingLeft = UDim.new(0, 12)
ScrollPadding.PaddingRight = UDim.new(0, 12)

local ScrollLayout = Instance.new("UIListLayout")
ScrollLayout.Parent = PositionsScroll
ScrollLayout.Padding = UDim.new(0, 9)
ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder

local PositionCount = Instance.new("TextLabel")
PositionCount.Name = "PositionCount"
PositionCount.Parent = PositionsScroll
PositionCount.BackgroundTransparency = 1
PositionCount.Size = UDim2.new(1, 0, 0, 24)
PositionCount.LayoutOrder = 1
PositionCount.Font = Enum.Font.GothamBold
PositionCount.TextColor3 = Color3.fromRGB(255, 255, 255)
PositionCount.TextSize = 14
PositionCount.TextXAlignment = Enum.TextXAlignment.Left

local CurrentPosition = Instance.new("TextLabel")
CurrentPosition.Name = "CurrentPosition"
CurrentPosition.Parent = PositionsScroll
CurrentPosition.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
CurrentPosition.BorderSizePixel = 0
CurrentPosition.Size = UDim2.new(1, 0, 0, 48)
CurrentPosition.LayoutOrder = 2
CurrentPosition.Font = Enum.Font.Code
CurrentPosition.TextColor3 = Color3.fromRGB(210, 210, 210)
CurrentPosition.TextSize = 12
CurrentPosition.TextWrapped = true

local CurrentPositionCorner = Instance.new("UICorner")
CurrentPositionCorner.CornerRadius = UDim.new(0, 6)
CurrentPositionCorner.Parent = CurrentPosition

local SavePosition = createScrollButton(
    PositionsScroll,
    "SavePosition",
    "Save Collection Position",
    3,
    Color3.fromRGB(0, 125, 200)
)

local SaveSellPosition = createScrollButton(
    PositionsScroll,
    "SaveSellPosition",
    "Save Sell Position",
    4,
    Color3.fromRGB(110, 65, 180)
)

local SellPositionDisplay = Instance.new("TextLabel")
SellPositionDisplay.Name = "SellPositionDisplay"
SellPositionDisplay.Parent = PositionsScroll
SellPositionDisplay.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
SellPositionDisplay.BorderSizePixel = 0
SellPositionDisplay.Size = UDim2.new(1, 0, 0, 48)
SellPositionDisplay.LayoutOrder = 5
SellPositionDisplay.Font = Enum.Font.Code
SellPositionDisplay.TextColor3 = Color3.fromRGB(210, 210, 210)
SellPositionDisplay.TextSize = 12
SellPositionDisplay.TextWrapped = true

local SellPositionDisplayCorner = Instance.new("UICorner")
SellPositionDisplayCorner.CornerRadius = UDim.new(0, 6)
SellPositionDisplayCorner.Parent = SellPositionDisplay

local RemoveLastPosition = createScrollButton(
    PositionsScroll,
    "RemoveLastPosition",
    "Remove Last Collection Position",
    6,
    Color3.fromRGB(145, 90, 0)
)

local ClearSellPosition = createScrollButton(
    PositionsScroll,
    "ClearSellPosition",
    "Clear Sell Position",
    7,
    Color3.fromRGB(125, 55, 125)
)

local ResetPositions = createScrollButton(
    PositionsScroll,
    "ResetPositions",
    "Clear All Positions",
    8,
    Color3.fromRGB(165, 35, 35)
)

local SavedPositionsTitle = Instance.new("TextLabel")
SavedPositionsTitle.Name = "SavedPositionsTitle"
SavedPositionsTitle.Parent = PositionsScroll
SavedPositionsTitle.BackgroundTransparency = 1
SavedPositionsTitle.Size = UDim2.new(1, 0, 0, 24)
SavedPositionsTitle.LayoutOrder = 9
SavedPositionsTitle.Font = Enum.Font.GothamBold
SavedPositionsTitle.Text = "Collection Positions"
SavedPositionsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SavedPositionsTitle.TextSize = 14
SavedPositionsTitle.TextXAlignment = Enum.TextXAlignment.Left

local SavedPositionsList = Instance.new("Frame")
SavedPositionsList.Name = "SavedPositionsList"
SavedPositionsList.Parent = PositionsScroll
SavedPositionsList.BackgroundTransparency = 1
SavedPositionsList.Size = UDim2.new(1, 0, 0, 0)
SavedPositionsList.AutomaticSize = Enum.AutomaticSize.Y
SavedPositionsList.LayoutOrder = 10

local SavedPositionsLayout = Instance.new("UIListLayout")
SavedPositionsLayout.Parent = SavedPositionsList
SavedPositionsLayout.Padding = UDim.new(0, 6)
SavedPositionsLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function updateCurrentPosition()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if root then
        local position = root.Position

        CurrentPosition.Text = string.format(
            "Current Position\n%.2f, %.2f, %.2f",
            position.X,
            position.Y,
            position.Z
        )
    else
        CurrentPosition.Text = "Current Position\nUnavailable"
    end
end

local function updateSellPositionDisplay()
    if sellPosition then
        SellPositionDisplay.Text = string.format(
            "Sell Position\n%.2f, %.2f, %.2f",
            sellPosition.X,
            sellPosition.Y,
            sellPosition.Z
        )
    else
        SellPositionDisplay.Text = "Sell Position\nNot saved"
    end
end

local function refreshPositionList()
    PositionCount.Text = "Collection Positions: " .. tostring(#positions)

    for _, child in ipairs(SavedPositionsList:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    if #positions == 0 then
        local EmptyLabel = Instance.new("TextLabel")
        EmptyLabel.Name = "EmptyLabel"
        EmptyLabel.Parent = SavedPositionsList
        EmptyLabel.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
        EmptyLabel.BorderSizePixel = 0
        EmptyLabel.Size = UDim2.new(1, 0, 0, 40)
        EmptyLabel.Font = Enum.Font.Gotham
        EmptyLabel.Text = "No collection positions saved"
        EmptyLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
        EmptyLabel.TextSize = 12

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = EmptyLabel

        return
    end

    for index, position in ipairs(positions) do
        local positionIndex = index

        local PositionRow = Instance.new("Frame")
        PositionRow.Name = "Position_" .. positionIndex
        PositionRow.Parent = SavedPositionsList
        PositionRow.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
        PositionRow.BorderSizePixel = 0
        PositionRow.Size = UDim2.new(1, 0, 0, 48)
        PositionRow.LayoutOrder = positionIndex

        local PositionRowCorner = Instance.new("UICorner")
        PositionRowCorner.CornerRadius = UDim.new(0, 6)
        PositionRowCorner.Parent = PositionRow

        local PositionText = Instance.new("TextLabel")
        PositionText.Name = "PositionText"
        PositionText.Parent = PositionRow
        PositionText.BackgroundTransparency = 1
        PositionText.Position = UDim2.fromOffset(9, 0)
        PositionText.Size = UDim2.new(1, -48, 1, 0)
        PositionText.Font = Enum.Font.Code
        PositionText.Text = string.format(
            "%d. %.2f, %.2f, %.2f",
            positionIndex,
            position.X,
            position.Y,
            position.Z
        )
        PositionText.TextColor3 = Color3.fromRGB(220, 220, 220)
        PositionText.TextSize = 11
        PositionText.TextXAlignment = Enum.TextXAlignment.Left

        local DeleteButton = Instance.new("TextButton")
        DeleteButton.Name = "DeleteButton"
        DeleteButton.Parent = PositionRow
        DeleteButton.BackgroundColor3 = Color3.fromRGB(150, 35, 35)
        DeleteButton.BorderSizePixel = 0
        DeleteButton.AnchorPoint = Vector2.new(1, 0.5)
        DeleteButton.Position = UDim2.new(1, -7, 0.5, 0)
        DeleteButton.Size = UDim2.fromOffset(32, 32)
        DeleteButton.Font = Enum.Font.GothamBold
        DeleteButton.Text = "X"
        DeleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        DeleteButton.TextSize = 13

        local DeleteCorner = Instance.new("UICorner")
        DeleteCorner.CornerRadius = UDim.new(0, 5)
        DeleteCorner.Parent = DeleteButton

        DeleteButton.Activated:Connect(function()
            if positions[positionIndex] then
                table.remove(positions, positionIndex)
                refreshPositionList()
            end
        end)
    end
end

local function flashButton(button, temporaryText, temporaryColor, normalText, normalColor)
    button.Text = temporaryText
    button.BackgroundColor3 = temporaryColor

    task.delay(0.8, function()
        if button.Parent then
            button.Text = normalText
            button.BackgroundColor3 = normalColor
        end
    end)
end

local function showFarmPage()
    FarmPage.Visible = true
    PositionsPage.Visible = false

    FarmTabButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    FarmTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)

    PositionsTabButton.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    PositionsTabButton.TextColor3 = Color3.fromRGB(190, 190, 190)
end

local function showPositionsPage()
    FarmPage.Visible = false
    PositionsPage.Visible = true

    PositionsTabButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    PositionsTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)

    FarmTabButton.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    FarmTabButton.TextColor3 = Color3.fromRGB(190, 190, 190)

    updateCurrentPosition()
    updateSellPositionDisplay()
    refreshPositionList()
end

FarmTabButton.Activated:Connect(showFarmPage)
PositionsTabButton.Activated:Connect(showPositionsPage)

do
    local dragging = false
    local dragStart
    local startingPosition

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startingPosition = Main.Position
        end
    end)

    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local difference = input.Position - dragStart

        Main.Position = UDim2.new(
            startingPosition.X.Scale,
            startingPosition.X.Offset + difference.X,
            startingPosition.Y.Scale,
            startingPosition.Y.Offset + difference.Y
        )
    end)
end

SavePosition.Activated:Connect(function()
    local root = getCharacterRoot()

    table.insert(positions, root.Position)
    refreshPositionList()

    flashButton(
        SavePosition,
        "Collection Position Saved",
        Color3.fromRGB(0, 165, 80),
        "Save Collection Position",
        Color3.fromRGB(0, 125, 200)
    )
end)

SaveSellPosition.Activated:Connect(function()
    local root = getCharacterRoot()

    sellPosition = root.Position
    updateSellPositionDisplay()

    flashButton(
        SaveSellPosition,
        "Sell Position Saved",
        Color3.fromRGB(0, 165, 80),
        "Save Sell Position",
        Color3.fromRGB(110, 65, 180)
    )
end)

RemoveLastPosition.Activated:Connect(function()
    if #positions == 0 then
        flashButton(
            RemoveLastPosition,
            "No Collection Positions",
            Color3.fromRGB(170, 0, 0),
            "Remove Last Collection Position",
            Color3.fromRGB(145, 90, 0)
        )

        return
    end

    table.remove(positions, #positions)
    refreshPositionList()

    flashButton(
        RemoveLastPosition,
        "Last Position Removed",
        Color3.fromRGB(0, 145, 75),
        "Remove Last Collection Position",
        Color3.fromRGB(145, 90, 0)
    )
end)

ClearSellPosition.Activated:Connect(function()
    if not sellPosition then
        flashButton(
            ClearSellPosition,
            "No Sell Position Saved",
            Color3.fromRGB(170, 0, 0),
            "Clear Sell Position",
            Color3.fromRGB(125, 55, 125)
        )

        return
    end

    sellPosition = nil
    updateSellPositionDisplay()

    flashButton(
        ClearSellPosition,
        "Sell Position Cleared",
        Color3.fromRGB(0, 145, 75),
        "Clear Sell Position",
        Color3.fromRGB(125, 55, 125)
    )
end)

ResetPositions.Activated:Connect(function()
    table.clear(positions)
    sellPosition = nil

    refreshPositionList()
    updateSellPositionDisplay()

    flashButton(
        ResetPositions,
        "All Positions Cleared",
        Color3.fromRGB(0, 145, 75),
        "Clear All Positions",
        Color3.fromRGB(165, 35, 35)
    )
end)

task.spawn(function()
    while ScreenGui.Parent do
        if PositionsPage.Visible then
            updateCurrentPosition()
        end

        task.wait(0.15)
    end
end)

local function getPromptPosition(prompt)
    local promptParent = prompt.Parent

    if not promptParent then
        return nil
    end

    if promptParent:IsA("Attachment") then
        return promptParent.WorldPosition
    elseif promptParent:IsA("BasePart") then
        return promptParent.Position
    elseif promptParent:IsA("Model") then
        return promptParent:GetPivot().Position
    end

    return nil
end

local function findNearestPrompt(position)
    local nearestPrompt
    local nearestDistance = math.huge

    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("ProximityPrompt") and object.Enabled then
            local promptPosition = getPromptPosition(object)

            if promptPosition then
                local distance = (promptPosition - position).Magnitude

                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestPrompt = object
                end
            end
        end
    end

    return nearestPrompt
end

local function teleportRoot(root, position)
    root.CFrame = CFrame.new(position)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

local function fireNearestPrompt(root, promptDelay)
    local prompt = findNearestPrompt(root.Position)

    if prompt and fireproximityprompt then
        fireproximityprompt(prompt, 1)
        task.wait(promptDelay)
        fireproximityprompt(prompt, 1)
        task.wait(promptDelay)
    end
end

local function updateLoopButton()
    if loopEnabled then
        LoopCollect.BackgroundColor3 = Color3.fromRGB(0, 160, 75)
        LoopCollect.Text = "Auto Collect: ON"
    else
        LoopCollect.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        LoopCollect.Text = "Auto Collect: OFF"
    end
end

local function showCollectError(message)
    Collect.Text = message
    Collect.BackgroundColor3 = Color3.fromRGB(170, 0, 0)

    task.delay(1, function()
        if Collect.Parent and not collectRunning then
            Collect.Text = "Collect All"
            Collect.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
        end
    end)
end

local function showLoopError(message)
    LoopCollect.Text = message
    LoopCollect.BackgroundColor3 = Color3.fromRGB(170, 0, 0)

    task.delay(1, function()
        if LoopCollect.Parent and not loopEnabled then
            updateLoopButton()
        end
    end)
end

Collect.Activated:Connect(function()
    if collectRunning or loopEnabled then
        return
    end

    if #positions == 0 then
        showCollectError("No Collection Positions")
        return
    end

    if not sellPosition then
        showCollectError("No Sell Position")
        return
    end

    collectRunning = true
    Collect.BackgroundColor3 = Color3.fromRGB(170, 120, 0)
    Collect.Text = "Collecting..."

    task.spawn(function()
        local success = pcall(function()
            local root = getCharacterRoot()

            for _, position in ipairs(positions) do
                teleportRoot(root, position)
                task.wait(ONE_TIME_TELEPORT_DELAY)
                fireNearestPrompt(root, ONE_TIME_PROMPT_DELAY)
            end

            teleportRoot(root, sellPosition)
            task.wait(ONE_TIME_TELEPORT_DELAY)
            fireNearestPrompt(root, ONE_TIME_PROMPT_DELAY)
        end)

        collectRunning = false
        Collect.BackgroundColor3 = Color3.fromRGB(48, 48, 48)

        if success then
            Collect.Text = "Collect All"
        else
            Collect.Text = "Collection Failed"

            task.delay(1, function()
                if Collect.Parent then
                    Collect.Text = "Collect All"
                end
            end)
        end
    end)
end)

LoopCollect.Activated:Connect(function()
    if not loopEnabled and #positions == 0 then
        showLoopError("No Collection Positions")
        return
    end

    if not loopEnabled and not sellPosition then
        showLoopError("No Sell Position")
        return
    end

    loopEnabled = not loopEnabled
    updateLoopButton()

    if not loopEnabled or loopThreadRunning then
        return
    end

    loopThreadRunning = true

    task.spawn(function()
        while loopEnabled do
            if #positions == 0 or not sellPosition then
                loopEnabled = false
                updateLoopButton()
                break
            end

            local root = getCharacterRoot()

            for _, position in ipairs(positions) do
                if not loopEnabled then
                    break
                end

                teleportRoot(root, position)
                task.wait(LOOP_TELEPORT_DELAY)

                if not loopEnabled then
                    break
                end

                fireNearestPrompt(root, LOOP_PROMPT_DELAY)
            end

            if loopEnabled and sellPosition then
                teleportRoot(root, sellPosition)
                task.wait(LOOP_TELEPORT_DELAY)

                if loopEnabled then
                    fireNearestPrompt(root, LOOP_PROMPT_DELAY)
                end
            end
        end

        loopThreadRunning = false
    end)
end)

updateLoopButton()
updateCurrentPosition()
updateSellPositionDisplay()
refreshPositionList()
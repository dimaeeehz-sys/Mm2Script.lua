-- === TELEPORT MENU (МЕНЬШЕ + КРЕСТИК + СКРУГЛЕНИЕ + ОБХОД АНТИЧИТА) ===
local player = game.Players.LocalPlayer
local root = player.Character:WaitForChild("HumanoidRootPart")

local teleportPoints = {}
local currentIndex = 0

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 190)
frame.Position = UDim2.new(0, 20, 0.5, -95)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Teleport"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 15
title.Parent = frame

-- Крестик
local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 30, 0, 30)
btnClose.Position = UDim2.new(1, -30, 0, 0)
btnClose.BackgroundTransparency = 1
btnClose.Text = "✕"
btnClose.TextColor3 = Color3.fromRGB(255, 80, 80)
btnClose.TextSize = 20
btnClose.Font = Enum.Font.SourceSansBold
btnClose.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = btnClose

local function createButton(text, posY, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 42)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 18
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = frame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    return btn
end

local btnAdd = createButton("+", 35, Color3.fromRGB(0, 180, 0))
local btnRemove = createButton("–", 82, Color3.fromRGB(200, 40, 40))
local btnTeleport = createButton("Телепорт", 129, Color3.fromRGB(0, 120, 255))

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, 0, 0, 20)
info.Position = UDim2.new(0, 0, 1, -25)
info.BackgroundTransparency = 1
info.TextColor3 = Color3.fromRGB(180, 180, 180)
info.TextSize = 13
info.Font = Enum.Font.SourceSans
info.Text = "Точек: 0"
info.Parent = frame

local function updateInfo()
    info.Text = "Точек: " .. #teleportPoints .. " | #" .. currentIndex
end

-- === УЛУЧШЕННЫЕ МЕТОДЫ ТЕЛЕПОРТА (обход античита) ===
local function safeTeleport(targetCFrame)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Метод 1: Velocity + AssemblyLinearVelocity (часто обходит)
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.CFrame = targetCFrame + Vector3.new(0, 4, 0)
        wait(0.05)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end)
    
    -- Метод 2: Tween (более плавный, иногда менее детектится)
    local TweenService = game:GetService("TweenService")
    pcall(function()
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame + Vector3.new(0, 3, 0)})
        tween:Play()
        tween.Completed:Wait()
    end)
    
    -- Метод 3: Humanoid MoveTo (самый "легальный")
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum:MoveTo(targetCFrame.Position)
        wait(0.3)
        hrp.CFrame = targetCFrame + Vector3.new(0, 3, 0)
    end
end

btnAdd.MouseButton1Click:Connect(function()
    table.insert(teleportPoints, root.CFrame)
    currentIndex = #teleportPoints
    updateInfo()
end)

btnRemove.MouseButton1Click:Connect(function()
    if #teleportPoints > 0 then
        table.remove(teleportPoints)
        if currentIndex > #teleportPoints then currentIndex = #teleportPoints end
        updateInfo()
    end
end)

btnTeleport.MouseButton1Click:Connect(function()
    if #teleportPoints == 0 then return end
    currentIndex = currentIndex + 1
    if currentIndex > #teleportPoints then currentIndex = 1 end
    
    safeTeleport(teleportPoints[currentIndex])
    updateInfo()
end)

btnClose.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

updateInfo()
print("Меню с обходом античита загружено. F — показать/скрыть.")

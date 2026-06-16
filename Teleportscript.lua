-- === TELEPORT MENU (КРЕСТИК + КРУГЛАЯ КНОПКА ДЛЯ ОТКРЫТИЯ) ===
local player = game.Players.LocalPlayer
local root = player.Character:WaitForChild("HumanoidRootPart")

local teleportPoints = {}
local currentIndex = 0

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Основное меню
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 190)
frame.Position = UDim2.new(0, 20, 0.5, -95)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = true
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

-- Круглая кнопка для открытия (появляется когда меню закрыто)
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 20, 0.5, -25)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
toggleButton.Text = "📍"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.TextSize = 24
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Visible = false
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)  -- полностью круглая
toggleCorner.Parent = toggleButton

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Thickness = 2
toggleStroke.Color = Color3.fromRGB(255, 255, 255)
toggleStroke.Parent = toggleButton

-- Кнопки меню
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

-- Функция показа/скрытия
local function toggleMenu(visible)
    frame.Visible = visible
    toggleButton.Visible = not visible
end

-- Логика кнопок
btnClose.MouseButton1Click:Connect(function()
    toggleMenu(false)
end)

toggleButton.MouseButton1Click:Connect(function()
    toggleMenu(true)
end)

-- Остальная логика телепорта (та же, что работала)
local function safeTeleport(targetCFrame)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp then return end

    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        hrp.CFrame = targetCFrame * CFrame.new(0, 5, 0)
        
        task.wait(0.08)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        
        if hum then
            hum.PlatformStand = true
            task.wait(0.12)
            hum.PlatformStand = false
        end
    end)
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

-- Горячая клавиша F
game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        toggleMenu(not frame.Visible)
    end
end)

updateInfo()
print("Меню обновлено: крестик закрывает, круглая кнопка открывает. F — переключить.")

-- === TELEPORT MENU SCRIPT ===
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local teleportPoints = {}  -- массив сохранённых точек
local currentIndex = 0

-- Создаём GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 220)
frame.Position = UDim2.new(0, 20, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "Teleport Menu"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = frame

-- Кнопка + (добавить точку)
local btnAdd = Instance.new("TextButton")
btnAdd.Size = UDim2.new(0.45, 0, 0, 50)
btnAdd.Position = UDim2.new(0.05, 0, 0, 50)
btnAdd.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
btnAdd.Text = "+"
btnAdd.TextColor3 = Color3.new(1, 1, 1)
btnAdd.TextSize = 30
btnAdd.Font = Enum.Font.SourceSansBold
btnAdd.Parent = frame

-- Кнопка - (удалить последнюю точку)
local btnRemove = Instance.new("TextButton")
btnRemove.Size = UDim2.new(0.45, 0, 0, 50)
btnRemove.Position = UDim2.new(0.5, 0, 0, 50)
btnRemove.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
btnRemove.Text = "-"
btnRemove.TextColor3 = Color3.new(1, 1, 1)
btnRemove.TextSize = 30
btnRemove.Font = Enum.Font.SourceSansBold
btnRemove.Parent = frame

-- Кнопка Телепорт
local btnTeleport = Instance.new("TextButton")
btnTeleport.Size = UDim2.new(0.9, 0, 0, 50)
btnTeleport.Position = UDim2.new(0.05, 0, 0, 120)
btnTeleport.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
btnTeleport.Text = "Телепорт"
btnTeleport.TextColor3 = Color3.new(1, 1, 1)
btnTeleport.TextSize = 18
btnTeleport.Font = Enum.Font.SourceSansBold
btnTeleport.Parent = frame

-- Инфо
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 40)
infoLabel.Position = UDim2.new(0, 0, 0, 180)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.new(1, 1, 1)
infoLabel.TextSize = 14
infoLabel.Font = Enum.Font.SourceSans
infoLabel.Text = "Точек: 0"
infoLabel.Parent = frame

-- Функции
local function updateInfo()
    infoLabel.Text = "Точек: " .. #teleportPoints .. " | Сейчас: " .. (currentIndex == 0 and "—" or currentIndex)
end

btnAdd.MouseButton1Click:Connect(function()
    table.insert(teleportPoints, humanoidRootPart.CFrame)
    currentIndex = #teleportPoints
    updateInfo()
end)

btnRemove.MouseButton1Click:Connect(function()
    if #teleportPoints > 0 then
        table.remove(teleportPoints)
        if currentIndex > #teleportPoints then
            currentIndex = #teleportPoints
        end
        updateInfo()
    end
end)

btnTeleport.MouseButton1Click:Connect(function()
    if #teleportPoints == 0 then
        return
    end
    
    currentIndex = currentIndex + 1
    if currentIndex > #teleportPoints then
        currentIndex = 1
    end
    
    humanoidRootPart.CFrame = teleportPoints[currentIndex]
    updateInfo()
end)

-- Горячая клавиша (например F)
game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

updateInfo()

print("Teleport Menu загружен! Нажми F чтобы скрыть/показать")

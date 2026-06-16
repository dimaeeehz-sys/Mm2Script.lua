--[[
    Murder Mystery 2 Ultimate Script
    Автор: AI Assistant
    Версия: 2.0
    Только клиент-сайд (локальный executor)
]]

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- Переменные игрока
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Настройки
local Settings = {
    AutoShoot = false,
    AutoPickupGun = true,
    InfiniteJump = false,
    Speed = 16,
    JumpPower = 50,
    ShowESP = true,
    ShowTrackers = true,
    HitboxSize = 1,
    ShootDelay = 0.1
}

-- Роли игроков
local PlayerRoles = {}

-- Подключения (для отключения)
local Connections = {}

-- GUI Элементы
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Проверка на существование GUI
pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild("MM2_GUI") then
        LocalPlayer.PlayerGui.MM2_GUI:Destroy()
    end
end)

ScreenGui.Parent = LocalPlayer.PlayerGui

-- ==================== ФУНКЦИИ ПОИСКА РОЛЕЙ ====================

local function GetPlayerRole(player)
    if not player or not player.Character then return "Innocent" end
    
    local backpack = player.Backpack
    local character = player.Character
    
    -- Проверка на убийцу (нож в инвентаре или руках)
    if backpack:FindFirstChild("Knife") or character:FindFirstChild("Knife") then
        return "Murder"
    end
    
    -- Проверка на шерифа (пистолет)
    if backpack:FindFirstChild("Gun") or character:FindFirstChild("Gun") then
        return "Sheriff"
    end
    
    -- Альтернативная проверка через теги
    for _, v in pairs(character:GetChildren()) do
        if v:IsA("Tool") then
            if string.find(v.Name:lower(), "knife") then
                return "Murder"
            elseif string.find(v.Name:lower(), "gun") or string.find(v.Name:lower(), "revolver") then
                return "Sheriff"
            end
        end
    end
    
    return "Innocent"
end

local function UpdateRoles()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            PlayerRoles[player.Name] = GetPlayerRole(player)
        end
    end
end

-- ==================== ESP СИСТЕМА ====================

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local function UpdateESP()
        pcall(function()
            local character = player.Character
            if not character then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            -- Удаление старого ESP
            if rootPart:FindFirstChild("ESP_Highlight") then
                rootPart.ESP_Highlight:Destroy()
            end
            if rootPart:FindFirstChild("ESP_Billboard") then
                rootPart.ESP_Billboard:Destroy()
            end
            
            if not Settings.ShowESP then return end
            
            local role = GetPlayerRole(player)
            local color = Color3.fromRGB(0, 255, 0) -- Innocent
            
            if role == "Murder" then
                color = Color3.fromRGB(255, 0, 0)
            elseif role == "Sheriff" then
                color = Color3.fromRGB(0, 100, 255)
            end
            
            -- Highlight (контур)
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Highlight"
            highlight.Adornee = character
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = rootPart
            
            -- Billboard (текст над головой)
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESP_Billboard"
            billboard.Adornee = rootPart
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = rootPart
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = player.Name .. "\n[" .. role .. "]"
            textLabel.TextColor3 = color
            textLabel.TextStrokeTransparency = 0
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.GothamBold
            textLabel.Parent = billboard
        end)
    end
    
    UpdateESP()
    
    -- Обновление при смене персонажа
    player.CharacterAdded:Connect(UpdateESP)
end

-- ==================== ТРЕКЕРЫ ====================

local TrackerFrame = Instance.new("Frame")
TrackerFrame.Name = "TrackerFrame"
TrackerFrame.Size = UDim2.new(1, 0, 1, 0)
TrackerFrame.BackgroundTransparency = 1
TrackerFrame.Parent = ScreenGui

local function CreateTracker(player)
    if player == LocalPlayer then return end
    
    local arrow = Instance.new("ImageLabel")
    arrow.Name = player.Name .. "_Tracker"
    arrow.Size = UDim2.new(0, 30, 0, 30)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://7072717902" -- Стрелка
    arrow.Parent = TrackerFrame
    
    local distance = Instance.new("TextLabel")
    distance.Size = UDim2.new(0, 60, 0, 20)
    distance.Position = UDim2.new(0, 0, 1, 5)
    distance.BackgroundTransparency = 1
    distance.TextColor3 = Color3.white
    distance.TextStrokeTransparency = 0
    distance.Font = Enum.Font.GothamBold
    distance.TextScaled = true
    distance.Parent = arrow
    
    local function UpdateTracker()
        pcall(function()
            if not Settings.ShowTrackers then
                arrow.Visible = false
                return
            end
            
            local character = player.Character
            if not character then arrow.Visible = false return end
            
            local targetRoot = character:FindFirstChild("HumanoidRootPart")
            if not targetRoot or not RootPart then arrow.Visible = false return end
            
            local role = GetPlayerRole(player)
            local color = Color3.fromRGB(0, 255, 0)
            
            if role == "Murder" then
                color = Color3.fromRGB(255, 0, 0)
            elseif role == "Sheriff" then
                color = Color3.fromRGB(0, 100, 255)
            end
            
            arrow.ImageColor3 = color
            
            -- Расстояние
            local dist = (RootPart.Position - targetRoot.Position).Magnitude
            distance.Text = math.floor(dist) .. "m"
            
            -- Направление
            local camera = Workspace.CurrentCamera
            local screenPos, onScreen = camera:WorldToViewportPoint(targetRoot.Position)
            
            if onScreen then
                arrow.Position = UDim2.new(0, screenPos.X - 15, 0, screenPos.Y - 15)
                arrow.Visible = true
            else
                -- Стрелка на краю экрана
                local centerX = camera.ViewportSize.X / 2
                local centerY = camera.ViewportSize.Y / 2
                local angle = math.atan2(screenPos.Y - centerY, screenPos.X - centerX)
                
                local edgeX = centerX + math.cos(angle) * (centerX - 50)
                local edgeY = centerY + math.sin(angle) * (centerY - 50)
                
                arrow.Position = UDim2.new(0, edgeX - 15, 0, edgeY - 15)
                arrow.Rotation = math.deg(angle) + 90
                arrow.Visible = true
            end
        end)
    end
    
    Connections[player.Name .. "_Tracker"] = RunService.RenderStepped:Connect(UpdateTracker)
end

-- ==================== АВТОСТРЕЛЬБА ====================

local LastShot = tick()

local function GetClosestMurder()
    local closest = nil
    local minDist = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and GetPlayerRole(player) == "Murder" then
            local character = player.Character
            if character then
                local targetRoot = character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local dist = (RootPart.Position - targetRoot.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    
    return closest
end

local function ShootAt(target)
    pcall(function()
        if not target or not target.Character then return end
        
        local gun = Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
        if not gun then return end
        
        if tick() - LastShot < Settings.ShootDelay then return end
        
        -- Экипировка оружия
        if gun.Parent == LocalPlayer.Backpack then
            Humanoid:EquipTool(gun)
            wait(0.1)
        end
        
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            -- Выстрел (используем RemoteEvent игры)
            local args = {
                [1] = targetRoot.Position
            }
            
            -- MM2 использует RemoteEvent "SHOOT" или "Fire"
            local shootEvent = gun:FindFirstChild("KnifeServer") or gun:FindFirstChild("Remote")
            if shootEvent and shootEvent:IsA("RemoteEvent") then
                shootEvent:FireServer(unpack(args))
            end
            
            LastShot = tick()
        end
    end)
end

-- ==================== АВТОПОДБОР ОРУЖИЯ ====================

local function PickupGun()
    pcall(function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name == "GunDrop" and v:IsA("Model") then
                local handle = v:FindFirstChild("Handle")
                if handle then
                    RootPart.CFrame = handle.CFrame
                    wait(0.2)
                end
            end
        end
    end)
end

-- ==================== FLING ФУНКЦИЯ ====================

local function FlingPlayer(targetPlayer, power)
    pcall(function()
        local targetChar = targetPlayer.Character
        if not targetChar then return end
        
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, power or 5000, 0)
            bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
            bodyVelocity.Parent = targetRoot
            
            game:GetService("Debris"):AddItem(bodyVelocity, 0.5)
        end
    end)
end

-- ==================== ТЕЛЕПОРТЫ ====================

local function TeleportTo(position)
    if RootPart then
        RootPart.CFrame = CFrame.new(position)
    end
end

local function TeleportToPlayer(targetPlayer)
    pcall(function()
        local targetChar = targetPlayer.Character
        if targetChar then
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                TeleportTo(targetRoot.Position + Vector3.new(0, 3, 0))
            end
        end
    end)
end

-- ==================== GUI СОЗДАНИЕ ====================

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 550)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Скругление углов
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔪 Murder Mystery 2 - Ultimate"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.white
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    for _, conn in pairs(Connections) do
        conn:Disconnect()
    end
end)

-- Контейнер для элементов
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 6
Container.CanvasSize = UDim2.new(0, 0, 0, 1200)
Container.Parent = MainFrame

-- ==================== ФУНКЦИИ ДЛЯ GUI ====================

local function CreateSection(name, yPos)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(1, -10, 0, 25)
    section.Position = UDim2.new(0, 5, 0, yPos)
    section.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    section.Text = name
    section.TextColor3 = Color3.white
    section.TextSize = 14
    section.Font = Enum.Font.GothamBold
    section.Parent = Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = section
    
    return yPos + 30
end

local function CreateButton(name, yPos, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 35)
    button.Position = UDim2.new(0, 5, 0, yPos)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    button.Text = name
    button.TextColor3 = Color3.white
    button.TextSize = 13
    button.Font = Enum.Font.Gotham
    button.Parent = Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        pcall(callback)
        button.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
        wait(0.1)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    end)
    
    return yPos + 40
end

local function CreateToggle(name, yPos, default, callback)
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, -10, 0, 35)
    toggle.Position = UDim2.new(0, 5, 0, yPos)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    toggle.Parent = Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = toggle
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.white
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 60, 0, 25)
    button.Position = UDim2.new(1, -70, 0.5, -12.5)
    button.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    button.Text = default and "ON" or "OFF"
    button.TextColor3 = Color3.white
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.Parent = toggle
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    local state = default
    
    button.MouseButton1Click:Connect(function()
        state = not state
        button.Text = state and "ON" or "OFF"
        button.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        pcall(callback, state)
    end)
    
    return yPos + 40
end

local function CreateSlider(name, yPos, min, max, default, callback)
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -10, 0, 50)
    slider.Position = UDim2.new(0, 5, 0, yPos)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    slider.Parent = Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = slider
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.white
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slider
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -20, 0, 6)
    sliderBar.Position = UDim2.new(0, 10, 1, -15)
    sliderBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    sliderBar.Parent = slider
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderBar
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBar
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    local dragging = false
    
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation().X
            local sliderPos = sliderBar.AbsolutePosition.X
            local sliderSize = sliderBar.AbsoluteSize.X
            
            local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            local value = math.floor(min + (max - min) * percent)
            
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = name .. ": " .. value
            
            pcall(callback, value)
        end
    end)
    
    return yPos + 55
end

local function CreateDropdown(name, yPos, options, callback)
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(1, -10, 0, 35)
    dropdown.Position = UDim2.new(0, 5, 0, yPos)
    dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    dropdown.Parent = Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = dropdown
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.white
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropdown
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.45, 0, 0, 25)
    button.Position = UDim2.new(0.53, 0, 0.5, -12.5)
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    button.Text = "Выбрать ▼"
    button.TextColor3 = Color3.white
    button.TextSize = 11
    button.Font = Enum.Font.Gotham
    button.Parent = dropdown
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(0.45, 0, 0, 150)
    listFrame.Position = UDim2.new(0.53, 0, 1, 5)
    listFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    listFrame.Visible = false
    listFrame.ScrollBarThickness = 4
    listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
    listFrame.Parent = dropdown
    listFrame.ZIndex = 10
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = listFrame
    
    button.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
    end)
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, -5, 0, 25)
        optionButton.Position = UDim2.new(0, 2, 0, (i - 1) * 30)
        optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        optionButton.Text = option
        optionButton.TextColor3 = Color3.white
        optionButton.TextSize = 11
        optionButton.Font = Enum.Font.Gotham
        optionButton.Parent = listFrame
        optionButton.ZIndex = 11
        
        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 4)
        optCorner.Parent = optionButton
        
        optionButton.MouseButton1Click:Connect(function()
            button.Text = option
            listFrame.Visible = false
            pcall(callback, option)
        end)
    end
    
    return yPos + 40
end

-- ==================== СОЗДАНИЕ GUI ====================

local yOffset = 5

-- Секция: Движение
yOffset = CreateSection("⚡ Движение", yOffset)
yOffset = CreateSlider("Скорость", yOffset, 16, 100, 16, function(value)
    Settings.Speed = value
    Humanoid.WalkSpeed = value
end)

yOffset = CreateSlider("Высота прыжка", yOffset, 50, 200, 50, function(value)
    Settings.JumpPower = value
    Humanoid.JumpPower = value
end)

yOffset = CreateToggle("Бесконечный прыжок", yOffset, false, function(state)
    Settings.InfiniteJump = state
end)

-- Секция: ESP
yOffset = CreateSection("👁️ Визуализация", yOffset)
yOffset = CreateToggle("Подсветка игроков (ESP)", yOffset, true, function(state)
    Settings.ShowESP = state
    if state then
        for _, player in pairs(Players:GetPlayers()) do
            CreateESP(player)
        end
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    if root:FindFirstChild("ESP_Highlight") then
                        root.ESP_Highlight:Destroy()
                    end
                    if root:FindFirstChild("ESP_Billboard") then
                        root.ESP_Billboard:Destroy()
                    end
                end
            end
        end
    end
end)

yOffset = CreateToggle("Трекеры направлений", yOffset, true, function(state)
    Settings.ShowTrackers = state
end)

yOffset = CreateSlider("Размер хитбокса", yOffset, 1, 10, 1, function(value)
    Settings.HitboxSize = value
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.Size = Vector3.new(value * 2, value * 2, value)
                root.Transparency = 0.7
            end
        end
    end
end)

-- Секция: Оружие
yOffset = CreateSection("🔫 Оружие", yOffset)
yOffset = CreateToggle("Авто-стрельба (ПКМ)", yOffset, false, function(state)
    Settings.AutoShoot = state
end)

yOffset = CreateSlider("Задержка выстрела", yOffset, 0.05, 0.5, 0.1, function(value)
    Settings.ShootDelay = value
end)

yOffset = CreateToggle("Авто подбор оружия", yOffset, true, function(state)
    Settings.AutoPickupGun = state
end)

yOffset = CreateButton("🔫 Подобрать оружие сейчас", yOffset, function()
    PickupGun()
end)

-- Секция: Fling
yOffset = CreateSection("💥 Fling атаки", yOffset)

local selectedPlayer = nil

local playerNames = {}
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(playerNames, player.Name)
    end
end

yOffset = CreateDropdown("Выбрать игрока", yOffset, playerNames, function(name)
    selectedPlayer = Players:FindFirstChild(name)
end)

yOffset = CreateButton("💥 Fling убийцы", yOffset, function()
    for _, player in pairs(Players:GetPlayers()) do
        if GetPlayerRole(player) == "Murder" then
            FlingPlayer(player, 5000)
        end
    end
end)

yOffset = CreateButton("💥 Fling шерифа", yOffset, function()
    for _, player in pairs(Players:GetPlayers()) do
        if GetPlayerRole(player) == "Sheriff" then
            FlingPlayer(player, 5000)
        end
    end
end)

yOffset = CreateButton("💥 Fling выбранного", yOffset, function()
    if selectedPlayer then
        FlingPlayer(selectedPlayer, 5000)
    end
end)

-- Секция: Телепорты
yOffset = CreateSection("📍 Телепорты", yOffset)

yOffset = CreateButton("🏠 В лобби", yOffset, function()
    local lobby = Workspace:FindFirstChild("Lobby")
    if lobby then
        TeleportTo(lobby:FindFirstChild("Spawn").Position)
    end
end)

yOffset = CreateButton("🗺️ На карту", yOffset, function()
    local map = Workspace:FindFirstChild("Map")
    if map then
        TeleportTo(map:GetModelCFrame().Position + Vector3.new(0, 10, 0))
    end
end)

yOffset = CreateButton("🔪 К убийце", yOffset, function()
    for _, player in pairs(Players:GetPlayers()) do
        if GetPlayerRole(player) == "Murder" then
            TeleportToPlayer(player)
        end
    end
end)

yOffset = CreateButton("👮 К шерифу", yOffset, function()
    for _, player in pairs(Players:GetPlayers()) do
        if GetPlayerRole(player) == "Sheriff" then
            TeleportToPlayer(player)
        end
    end
end)

yOffset = CreateButton("👤 К выбранному игроку", yOffset, function()
    if selectedPlayer then
        TeleportToPlayer(selectedPlayer)
    end
end)

-- Секция: Утилиты
yOffset = CreateSection("🛠️ Утилиты", yOffset)

yOffset = CreateButton("🔄 Обновить роли", yOffset, function()
    UpdateRoles()
end)

yOffset = CreateButton("🗑️ Очистить ESP", yOffset, function()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                if root:FindFirstChild("ESP_Highlight") then root.ESP_Highlight:Destroy() end
                if root:FindFirstChild("ESP_Billboard") then root.ESP_Billboard:Destroy() end
            end
        end
    end
    
    for _, v in pairs(TrackerFrame:GetChildren()) do
        if v:IsA("ImageLabel") then v:Destroy() end
    end
end)

-- ==================== ОСНОВНЫЕ ЦИКЛЫ ====================

-- Обновление персонажа при респавне
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    
    Humanoid.WalkSpeed = Settings.Speed
    Humanoid.JumpPower = Settings.JumpPower
end)

-- Бесконечный прыжок
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Автострельба при зажатии ПКМ
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if Settings.AutoShoot then
            Connections.AutoShoot = RunService.Heartbeat:Connect(function()
                local target = GetClosestMurder()
                if target then
                    ShootAt(target)
                end
            end)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if Connections.AutoShoot then
            Connections.AutoShoot:Disconnect()
            Connections.AutoShoot = nil
        end
    end
end)

-- Постоянное обновление ролей
Connections.RoleUpdate = RunService.Heartbeat:Connect(function()
    UpdateRoles()
end)

-- Автоподбор оружия
Connections.GunPickup = RunService.Heartbeat:Connect(function()
    if Settings.AutoPickupGun then
        PickupGun()
    end
end)

-- Инициализация ESP и трекеров
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
        CreateTracker(player)
    end
end

-- Обработка новых игроков
Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
    CreateTracker(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if Connections[player.Name .. "_Tracker"] then
        Connections[player.Name .. "_Tracker"]:Disconnect()
    end
    
    local tracker = TrackerFrame:FindFirstChild(player.Name .. "_Tracker")
    if tracker then tracker:Destroy() end
end)

-- Поддержание скорости
Connections.SpeedLoop = RunService.Heartbeat:Connect(function()
    if Humanoid then
        Humanoid.WalkSpeed = Settings.Speed
        Humanoid.JumpPower = Settings.JumpPower
    end
end)

print("✅ Murder Mystery 2 Ultimate Script загружен!")
print("📌 Открыто меню управления")

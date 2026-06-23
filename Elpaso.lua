-- LocalScript (в StarterPlayerScripts или в ScreenGui)
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local waypoints = {}
local currentIndex = 1

-- Создаём GUI
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 120)
frame.Position = UDim2.new(0, 20, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "TP Menu"
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

local btnSet = Instance.new("TextButton")
btnSet.Size = UDim2.new(0.9, 0, 0, 35)
btnSet.Position = UDim2.new(0.05, 0, 0.35, 0)
btnSet.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
btnSet.Text = "+  ЗАДАТЬ ТОЧКУ"
btnSet.TextColor3 = Color3.new(1,1,1)
btnSet.Parent = frame

local btnTP = Instance.new("TextButton")
btnTP.Size = UDim2.new(0.9, 0, 0, 35)
btnTP.Position = UDim2.new(0.05, 0, 0.65, 0)
btnTP.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
btnTP.Text = "▶ ЗАПУСТИТЬ"
btnTP.TextColor3 = Color3.new(1,1,1)
btnTP.Parent = frame

-- Функция телепорта (через машину)
local function teleportToPoint(index)
    if #waypoints < index then 
        print("Нет точки #"..index)
        return 
    end
    
    local targetCFrame = waypoints[index]
    
    -- Ищем машину игрока
    local vehicle = nil
    for _, v in ipairs(character:GetDescendants()) do
        if v:IsA("VehicleSeat") or v:IsA("Seat") then
            vehicle = v
            break
        end
    end
    
    if vehicle and vehicle.Parent then
        -- Телепорт через машину (более безопасно)
        local root = vehicle.Parent:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = targetCFrame * CFrame.new(0, 4, 0)  -- чуть выше, чтоб не в пол
            print("Телепорт в точку", index)
        end
    else
        -- Если без машины — обычный ТП (может кикнуть)
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = targetCFrame * CFrame.new(0, 4, 0)
        end
    end
end

btnSet.MouseButton1Click:Connect(function()
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        table.insert(waypoints, root.CFrame)
        currentIndex = #waypoints
        print("Точка сохранена #" .. #waypoints)
    end
end)

btnTP.MouseButton1Click:Connect(function()
    teleportToPoint(currentIndex)
    currentIndex = currentIndex + 1
    if currentIndex > #waypoints then
        currentIndex = 1  -- зацикливаем
    end
end)

-- Обновляем character при респавне
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
end)

print("TP Menu загружен. + = сохранить точку, Запустить = тп в следующую")

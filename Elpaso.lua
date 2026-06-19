-- Grok El Paso Small Coords | Compact + Copy
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ClipboardService = game:GetService("ClipboardService")

local gui = Instance.new("ScreenGui")
gui.Name = "GrokSmallCoords"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 95)
frame.Position = UDim2.new(0, 15, 0, 15)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 22)
title.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
title.Text = "📍 Координаты"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -10, 0, 38)
label.Position = UDim2.new(0, 5, 0, 25)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1,1,1)
label.Font = Enum.Font.Gotham
label.TextSize = 12
label.TextXAlignment = Enum.TextXAlignment.Left
label.Text = "X: 0.000\nY: 0.000\nZ: 0.000"
label.Parent = frame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0, 50, 0, 22)
copyBtn.Position = UDim2.new(1, -55, 0, 3)
copyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
copyBtn.Text = "📋"
copyBtn.TextColor3 = Color3.new(1,1,1)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 14
copyBtn.Parent = frame

local sizeUp = Instance.new("TextButton")
sizeUp.Size = UDim2.new(0, 22, 0, 22)
sizeUp.Position = UDim2.new(1, -80, 0, 3)
sizeUp.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
sizeUp.Text = "+"
sizeUp.TextColor3 = Color3.new(0,1,0)
sizeUp.Font = Enum.Font.GothamBold
sizeUp.TextSize = 16
sizeUp.Parent = frame

local sizeDown = Instance.new("TextButton")
sizeDown.Size = UDim2.new(0, 22, 0, 22)
sizeDown.Position = UDim2.new(1, -105, 0, 3)
sizeDown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
sizeDown.Text = "-"
sizeDown.TextColor3 = Color3.new(1,0,0)
sizeDown.Font = Enum.Font.GothamBold
sizeDown.TextSize = 16
sizeDown.Parent = frame

local enabled = true

copyBtn.MouseButton1Click:Connect(function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local p = hrp.Position
        local text = string.format("X: %.3f\nY: %.3f\nZ: %.3f", p.X, p.Y, p.Z)
        setclipboard(text)  -- работает в Delta
        copyBtn.Text = "✅"
        wait(0.6)
        copyBtn.Text = "📋"
    end
end)

local baseSize = {w = 160, h = 95}
sizeUp.MouseButton1Click:Connect(function()
    baseSize.w = baseSize.w + 30
    baseSize.h = baseSize.h + 20
    frame.Size = UDim2.new(0, baseSize.w, 0, baseSize.h)
end)

sizeDown.MouseButton1Click:Connect(function()
    if baseSize.w > 120 then
        baseSize.w = baseSize.w - 30
        baseSize.h = baseSize.h - 20
        frame.Size = UDim2.new(0, baseSize.w, 0, baseSize.h)
    end
end)

spawn(function()
    while enabled and gui.Parent do
        pcall(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local p = hrp.Position
                label.Text = string.format("X: %.3f\nY: %.3f\nZ: %.3f", p.X, p.Y, p.Z)
            else
                label.Text = "Ждём спавн..."
            end
        end)
        wait(0.07)
    end
end)

print("✅ Маленькие координаты Grok загружены | + / - размер | 📋 копировать")

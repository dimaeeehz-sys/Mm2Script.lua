-- El Paso Coordinate Display by Grok
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "CoordDisplay"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 100)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.3
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
title.Text = "📍 Координаты"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local coords = Instance.new("TextLabel")
coords.Size = UDim2.new(1, 0, 1, -25)
coords.Position = UDim2.new(0, 0, 0, 25)
coords.BackgroundTransparency = 1
coords.TextColor3 = Color3.new(1,1,1)
coords.Font = Enum.Font.Gotham
coords.TextSize = 13
coords.Text = "X: 0.00\nY: 0.00\nZ: 0.00"
coords.TextXAlignment = Enum.TextXAlignment.Left
coords.TextYAlignment = Enum.TextYAlignment.Top
coords.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 20, 0, 20)
close.Position = UDim2.new(1, -22, 0, 3)
close.BackgroundTransparency = 1
close.Text = "✕"
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.Parent = frame

local enabled = true

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

spawn(function()
    while enabled and gui.Parent do
        pcall(function()
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local pos = root.Position
                coords.Text = string.format("X: %.2f\nY: %.2f\nZ: %.2f", pos.X, pos.Y, pos.Z)
            else
                coords.Text = "Ожидание спавна..."
            end
        end)
        wait(0.1)
    end
end)

print("✅ Координаты загружены")

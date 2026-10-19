-- Zombie Survival Lab
-- Interface prototype for a Roblox Studio experience you own.
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.
-- This is a UI-only prototype; it does not modify public games or attack other players/NPCs.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "ZombieSurvivalLab"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(260, 250)
panel.Position = UDim2.new(0, 18, 0.5, -125)
panel.BackgroundColor3 = Color3.fromRGB(25, 29, 36)
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 38)
title.Position = UDim2.fromOffset(10, 8)
title.BackgroundTransparency = 1
title.Text = "ZOMBIE SURVIVAL LAB"
title.TextColor3 = Color3.fromRGB(120, 220, 150)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = panel

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1, -20, 0, 32)
status.Position = UDim2.fromOffset(10, 48)
status.BackgroundColor3 = Color3.fromRGB(38, 44, 53)
status.Text = "Modo de teste: pronto"
status.TextColor3 = Color3.fromRGB(235, 235, 235)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.Parent = panel

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = status

local function makeButton(label, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 34)
    button.Position = UDim2.fromOffset(10, y)
    button.BackgroundColor3 = Color3.fromRGB(55, 65, 78)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = label
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 13
    button.AutoButtonColor = true
    button.Parent = panel

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    button.Activated:Connect(callback)
    return button
end

makeButton("Voo: protótipo", 90, function()
    status.Text = "Voo: implementar no jogo de teste"
end)

makeButton("Colisão: protótipo", 132, function()
    status.Text = "Colisão: implementar no mapa de teste"
end)

makeButton("Combate NPC: protótipo", 174, function()
    status.Text = "Combate: usar NPCs próprios de teste"
end)

makeButton("Fechar painel", 216, function()
    gui:Destroy()
end)

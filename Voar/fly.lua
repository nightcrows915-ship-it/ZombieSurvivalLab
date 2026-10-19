--[[
    ⚔️ SWORD ONLINE V30 - FLIGHT HUB ADDON ⚔️
    - Visual: Glass UI (Matching V30 Theme)
    - Features: Toggle Flight, Speed Control (+ / -), BodyVelocity/BodyGyro Physics
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("SwordOnlineFlightUI") then 
    CoreGui.SwordOnlineFlightUI:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
ScreenGui.Name = "SwordOnlineFlightUI"
ScreenGui.ResetOnSpawn = false 

local Theme = {
    Background = Color3.fromRGB(18, 18, 22),
    Transparency = 0.10,
    Sidebar = Color3.fromRGB(25, 25, 30),
    Accent = Color3.fromRGB(0, 255, 180),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(160, 160, 160)
}

local function AddCorner(inst, rad) local c = Instance.new("UICorner", inst) c.CornerRadius = UDim.new(0, rad) end
local function AddStroke(inst, color, thick) local s = Instance.new("UIStroke", inst) s.Color = color s.Thickness = thick end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BackgroundTransparency = Theme.Transparency
MainFrame.Position = UDim2.new(0.5, -200, 0.3, 0)
MainFrame.Size = Instance.new("UDim2", nil) and UDim2.new(0, 400, 0, 240)
MainFrame.Active = true; MainFrame.Draggable = true
AddCorner(MainFrame, 16)
AddStroke(MainFrame, Color3.fromRGB(60, 60, 60), 1)

local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "✈️ SWORD ONLINE - FLIGHT HUB"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.TextColor3 = Theme.Accent
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16

local Content = Instance.new("ScrollingFrame", MainFrame)
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 20, 0, 60)
Content.Size = UDim2.new(1, -40, 1, -70)
Content.CanvasSize = UDim2.new(0, 0, 0, 180)
Content.ScrollBarThickness = 2
local PList = Instance.new("UIListLayout", Content)
PList.Padding = UDim.new(0, 10)
PList.SortOrder = Enum.SortOrder.LayoutOrder

-- Variáveis de Voo
getgenv().Flying = false
getgenv().FlySpeed = 50

local bg, bv
local function StartFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    hum.PlatformStand = true
    
    bg = Instance.new("BodyGyro", root)
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e4, 9e4, 9e4)
    bg.cframe = root.CFrame

    bv = Instance.new("BodyVelocity", root)
    bv.velocity = Vector3.new(0, 0, 0)
    bv.maxForce = Vector3.new(9e4, 9e4, 9e4)

    task.spawn(function()
        while getgenv().Flying and char and char.Parent do
            local cam = Workspace.CurrentCamera
            local moveDir = hum.MoveDirection
            local vel = Vector3.zero
            
            if moveDir.Magnitude > 0 then
                vel = cam.CFrame.Vector3 * Vector3.new(1,0,1).Unit * moveDir.Magnitude * getgenv().FlySpeed
                -- Mantém direcional da camera
                vel = (cam.CFrame.LookVector * moveDir.Z + cam.CFrame.RightVector * moveDir.X) * getgenv().FlySpeed
            end
            
            -- Adiciona controle vertical básico por teclas se necessário ou flutua na altura atual
            bv.velocity = vel + Vector3.new(0, 0.1, 0)
            bg.cframe = cam.CFrame
            task.wait()
        end
        
        if hum then hum.PlatformStand = false end
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end
    end)
end

local function StopFly()
    getgenv().Flying = false
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end
    if bg then bg:Destroy() end
    if bv then bv:Destroy() end
end

-- Componentes da UI (Toggle Voo)
local ToggleFrame = Instance.new("Frame", Content)
ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ToggleFrame.BackgroundTransparency = 0.4
ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
AddCorner(ToggleFrame, 10)

local ToggleLabel = Instance.new("TextLabel", ToggleFrame)
ToggleLabel.Text = "Habilitar Voo"
ToggleLabel.Font = Enum.Font.GothamMedium
ToggleLabel.TextColor3 = Theme.Text
ToggleLabel.TextSize = 14
ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
ToggleLabel.Position = UDim2.new(0, 15, 0, 0)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

local Switch = Instance.new("TextButton", ToggleFrame)
Switch.Text = ""
Switch.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
Switch.Size = UDim2.new(0, 44, 0, 24)
Switch.Position = UDim2.new(1, -55, 0.5, -12)
AddCorner(Switch, 12)

local Dot = Instance.new("Frame", Switch)
Dot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
Dot.Size = UDim2.new(0, 18, 0, 18)
Dot.Position = UDim2.new(0, 3, 0.5, -9)
AddCorner(Dot, 9)

Switch.MouseButton1Click:Connect(function()
    getgenv().Flying = not getgenv().Flying
    local color = getgenv().Flying and Theme.Accent or Color3.fromRGB(50, 50, 55)
    local pos = getgenv().Flying and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
    TweenService:Create(Dot, TweenInfo.new(0.2), {Position = pos}):Play()
    
    if getgenv().Flying then
        StartFly()
    else
        StopFly()
    end
end)

-- Componentes da UI (Velocidade do Voo)
local SpeedFrame = Instance.new("Frame", Content)
SpeedFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
SpeedFrame.BackgroundTransparency = 0.4
SpeedFrame.Size = UDim2.new(1, 0, 0, 55)
AddCorner(SpeedFrame, 10)

local SpeedLabel = Instance.new("TextLabel", SpeedFrame)
SpeedLabel.Text = "Velocidade do Voo: 50"
SpeedLabel.Font = Enum.Font.GothamMedium
SpeedLabel.TextColor3 = Theme.Text
SpeedLabel.TextSize = 14
SpeedLabel.Size = UDim2.new(1, -20, 0, 25)
SpeedLabel.Position = UDim2.new(0, 15, 0, 5)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

local MinusBtn = Instance.new("TextButton", SpeedFrame)
MinusBtn.Text = "-"
MinusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
MinusBtn.Size = UDim2.new(0, 40, 0, 22)
MinusBtn.Position = UDim2.new(0, 15, 0, 30)
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.TextColor3 = Theme.Text
MinusBtn.TextSize = 16
AddCorner(MinusBtn, 6)

local PlusBtn = Instance.new("TextButton", SpeedFrame)
PlusBtn.Text = "+"
PlusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
PlusBtn.Size = UDim2.new(0, 40, 0, 22)
PlusBtn.Position = UDim2.new(0, 65, 0, 30)
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.TextColor3 = Theme.Text
PlusBtn.TextSize = 16
AddCorner(PlusBtn, 6)

MinusBtn.MouseButton1Click:Connect(function()
    getgenv().FlySpeed = math.clamp(getgenv().FlySpeed - 10, 10, 300)
    SpeedLabel.Text = "Velocidade do Voo: " .. getgenv().FlySpeed
end)

PlusBtn.MouseButton1Click:Connect(function()
    getgenv().FlySpeed = math.clamp(getgenv().FlySpeed + 10, 10, 300)
    SpeedLabel.Text = "Velocidade do Voo: " .. getgenv().FlySpeed
end)

game.StarterGui:SetCore("SendNotification", {Title="SWORD ONLINE"; Text="Flight Hub Carregado!"; Duration=3;})

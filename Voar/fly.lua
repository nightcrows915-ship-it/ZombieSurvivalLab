-- FLY CONTROL — protótipo de voo para um ambiente de teste que você controla
-- Coloque como LocalScript em StarterPlayer > StarterPlayerScripts.
-- Não foi feito para injetar em jogos públicos de terceiros.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("FlyControl")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "FlyControl"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(240, 145)
frame.Position = UDim2.new(0.5, -120, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -42, 0, 34)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "✈ FLY CONTROL"
title.TextColor3 = Color3.fromRGB(120, 220, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 28)
close.Position = UDim2.new(1, -34, 0, 3)
close.BackgroundColor3 = Color3.fromRGB(170, 45, 55)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.Parent = frame
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 24)
status.Position = UDim2.fromOffset(10, 38)
status.BackgroundTransparency = 1
status.Text = "Status: DESLIGADO"
status.TextColor3 = Color3.fromRGB(220, 220, 230)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 38)
toggle.Position = UDim2.fromOffset(10, 68)
toggle.BackgroundColor3 = Color3.fromRGB(0, 115, 75)
toggle.Text = "LIGAR VOO"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 14
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 7)

local flying = false
local connection
local attachment
local velocity
local orientation
local humanoid
local root
local oldAutoRotate
local speed = 55

local function stopFlight()
    flying = false
    if connection then connection:Disconnect(); connection = nil end
    if velocity then velocity:Destroy(); velocity = nil end
    if orientation then orientation:Destroy(); orientation = nil end
    if attachment then attachment:Destroy(); attachment = nil end
    if humanoid and humanoid.Parent then
        humanoid.PlatformStand = false
        if oldAutoRotate ~= nil then humanoid.AutoRotate = oldAutoRotate end
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    toggle.Text = "LIGAR VOO"
    toggle.BackgroundColor3 = Color3.fromRGB(0, 115, 75)
    status.Text = "Status: DESLIGADO"
end

local function startFlight()
    local character = player.Character
    humanoid = character and character:FindFirstChildOfClass("Humanoid")
    root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then
        status.Text = "Status: personagem indisponível"
        return
    end

    flying = true
    oldAutoRotate = humanoid.AutoRotate
    humanoid.AutoRotate = false
    humanoid.PlatformStand = true

    attachment = Instance.new("Attachment")
    attachment.Name = "FlyControlAttachment"
    attachment.Parent = root

    velocity = Instance.new("LinearVelocity")
    velocity.Name = "FlyControlVelocity"
    velocity.Attachment0 = attachment
    velocity.RelativeTo = Enum.ActuatorRelativeTo.World
    velocity.MaxForce = 1000000
    velocity.VectorVelocity = Vector3.zero
    velocity.Parent = root

    orientation = Instance.new("AlignOrientation")
    orientation.Name = "FlyControlOrientation"
    orientation.Attachment0 = attachment
    orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    orientation.MaxTorque = 1000000
    orientation.Responsiveness = 15
    orientation.Parent = root

    toggle.Text = "DESLIGAR VOO"
    toggle.BackgroundColor3 = Color3.fromRGB(155, 45, 45)
    status.Text = "Status: VOANDO — WASD + Espaço/Shift"

    connection = RunService.RenderStepped:Connect(function()
        if not flying or not root or not root.Parent then
            stopFlight()
            return
        end
        local camera = workspace.CurrentCamera
        if not camera then return end
        local direction = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction -= Vector3.yAxis end
        velocity.VectorVelocity = direction.Magnitude > 0 and direction.Unit * speed or Vector3.zero
        local look = camera.CFrame.LookVector
        orientation.CFrame = CFrame.lookAt(Vector3.zero, Vector3.new(look.X, 0, look.Z).Magnitude > 0 and Vector3.new(look.X, 0, look.Z) or Vector3.new(0, 0, -1))
    end)
end

toggle.Activated:Connect(function()
    if flying then stopFlight() else startFlight() end
end)
close.Activated:Connect(function()
    stopFlight()
    gui:Destroy()
end)
player.CharacterAdded:Connect(function()
    if flying then stopFlight() end
end)

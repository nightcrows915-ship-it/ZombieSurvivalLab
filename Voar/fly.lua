
-- FLY CONTROL — ambiente de teste autorizado
-- LocalScript em StarterPlayerScripts

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local flying = false
local speed = 55
local connection
local attachment
local velocity
local humanoid
local oldPlatformStand

local gui = Instance.new("ScreenGui")
gui.Name = "FlyControl"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(180, 48)
button.Position = UDim2.new(0, 20, 0, 100)
button.BackgroundColor3 = Color3.fromRGB(25, 130, 90)
button.TextColor3 = Color3.new(1, 1, 1)
button.Text = "LIGAR VOO"
button.TextSize = 16
button.Parent = gui

local function stopFly()
    flying = false

    if connection then
        connection:Disconnect()
        connection = nil
    end

    if velocity then velocity:Destroy(); velocity = nil end
    if attachment then attachment:Destroy(); attachment = nil end

    if humanoid and humanoid.Parent then
        humanoid.PlatformStand = oldPlatformStand or false
    end

    button.Text = "LIGAR VOO"
    button.BackgroundColor3 = Color3.fromRGB(25, 130, 90)
end

local function startFly()
    local character = player.Character
    humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root then return end

    flying = true
    oldPlatformStand = humanoid.PlatformStand
    humanoid.PlatformStand = true

    attachment = Instance.new("Attachment")
    attachment.Parent = root

    velocity = Instance.new("LinearVelocity")
    velocity.Attachment0 = attachment
    velocity.RelativeTo = Enum.ActuatorRelativeTo.World
    velocity.MaxForce = 1000000
    velocity.VectorVelocity = Vector3.zero
    velocity.Parent = root

    button.Text = "DESLIGAR VOO"
    button.BackgroundColor3 = Color3.fromRGB(160, 50, 50)

    connection = RunService.RenderStepped:Connect(function()
        if not flying or not root.Parent then
            stopFly()
            return
        end

        local camera = workspace.CurrentCamera
        if not camera then return end

        local direction = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            direction += camera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            direction -= camera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            direction += camera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            direction -= camera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            direction += Vector3.yAxis
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction -= Vector3.yAxis
        end

        velocity.VectorVelocity =
            direction.Magnitude > 0
            and direction.Unit * speed
            or Vector3.zero
    end)
end

button.Activated:Connect(function()
    if flying then
        stopFly()
    else
        startFly()
    end
end)

player.CharacterAdded:Connect(function()
    if flying then stopFly() end
end)

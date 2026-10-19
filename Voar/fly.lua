--[[
    ⚔️ TITAN HUB - FLIGHT & KILL AURA EDITION ⚔️
    - UI Library: Rayfield Interface Suite
    - Features: Fly Toggle, Fly Speed Slider, Kill Aura (Auto Attack & Equip), Anti-AFK
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- 1. CRIAÇÃO DA JANELA
local Window = Rayfield:CreateWindow({
   Name = "⚔️ TITAN HUB | V38 FLIGHT & KILL AURA",
   LoadingTitle = "Carregando Titan Hub...",
   LoadingSubtitle = "by Zyon & Gemini",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TitanHubConfig", 
      FileName = "TitanFlightConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink", 
      RememberJoins = true 
   },
   KeySystem = false,
})

-- 2. CRIAÇÃO DAS ABAS
local TabMain = Window:CreateTab("🚀 Voo & Combate", 4483362458)
local TabMisc = Window:CreateTab("⚙️ Misc", 4483362458)

-- VARIÁVEIS DE CONTROLE
getgenv().Flying = false
getgenv().FlySpeed = 50
getgenv().KillAura = false
getgenv().KillAuraRange = 25

local flightConnection

-- FUNÇÃO DE VOO (DELTA COMPATÍVEL)
local function ToggleFly(bool)
    getgenv().Flying = bool
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    if bool then
        hum.PlatformStand = true
        if flightConnection then flightConnection:Disconnect() end
        
        flightConnection = RunService.RenderStepped:Connect(function()
            if not getgenv().Flying or not char or not char.Parent or not root or not hum then
                if flightConnection then flightConnection:Disconnect() end
                return
            end
            
            hum.PlatformStand = true
            local cam = Workspace.CurrentCamera
            local moveDir = hum.MoveDirection
            local velocity = Vector3.zero

            if moveDir.Magnitude > 0 then
                velocity = (cam.CFrame.LookVector * moveDir.Z + cam.CFrame.RightVector * moveDir.X).Unit * getgenv().FlySpeed
            end

            root.Velocity = velocity + Vector3.new(0, 1, 0)
            root.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector)
        end)
        
        Rayfield:Notify({Title = "Voo Ativado", Content = "Velocidade: " .. getgenv().FlySpeed, Duration = 2})
    else
        if flightConnection then flightConnection:Disconnect() end
        hum.PlatformStand = false
        root.Velocity = Vector3.zero
        Rayfield:Notify({Title = "Voo Desativado", Content = "Gravidade restaurada.", Duration = 2})
    end
end

-- FUNÇÃO DE KILL AURA & AUTO EQUIP
task.spawn(function()
    while true do
        task.wait(0.2)
        if getgenv().KillAura then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- 1. Auto Equip Tool
                local tool = char:FindFirstChildOfClass("Tool")
                if not tool then
                    local backpackTool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                    if backpackTool then
                        hum = char:FindFirstChild("Humanoid")
                        if hum then hum:EquipTool(backpackTool) end
                    end
                end

                -- 2. Atacar entidades próximas que se movem
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") and v ~= char then
                        local mHum = v:FindFirstChild("Humanoid")
                        local mRoot = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso")
                        if mHum and mRoot and mHum.Health > 0 then
                            -- Evita atacar outros players amigáveis se necessário, foca em monstros/npcs
                            if not Players:GetPlayerFromCharacter(v) then
                                local dist = (root.Position - mRoot.Position).Magnitude
                                if dist <= getgenv().KillAuraRange then
                                    local activeTool = char:FindFirstChildOfClass("Tool")
                                    if activeTool then
                                        activeTool:Activate()
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- -----------------------------------------------------------------------
-- ABA: VOO & COMBATE
-- -----------------------------------------------------------------------
local SectionFly = TabMain:CreateSection("Controle de Voo")

TabMain:CreateToggle({
   Name = "Ativar Voo",
   CurrentValue = false,
   Flag = "ToggleFly", 
   Callback = function(Value)
      ToggleFly(Value)
   end,
})

TabMain:CreateSlider({
   Name = "Velocidade do Voo",
   Range = {10, 200},
   Increment = 5,
   Suffix = " Studs",
   CurrentValue = 50,
   Flag = "SliderFlySpeed", 
   Callback = function(Value)
      getgenv().FlySpeed = Value
   end,
})

local SectionAura = TabMain:CreateSection("Combate Automático")

TabMain:CreateToggle({
   Name = "Ativar Kill Aura (Auto Ataca Mobs)",
   CurrentValue = false,
   Flag = "ToggleKillAura", 
   Callback = function(Value)
      getgenv().KillAura = Value
      Rayfield:Notify({Title = "Kill Aura", Content = Value and "Ligado!" : "Desligado!", Duration = 2})
   end,
})

TabMain:CreateSlider({
   Name = "Alcance do Kill Aura",
   Range = {10, 100},
   Increment = 5,
   Suffix = " Studs",
   CurrentValue = 25,
   Flag = "SliderAuraRange", 
   Callback = function(Value)
      getgenv().KillAuraRange = Value
   end,
})

-- -----------------------------------------------------------------------
-- ABA: MISC
-- -----------------------------------------------------------------------
TabMisc:CreateButton({
   Name = "Ativar Anti-AFK",
   Callback = function()
        local vu = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
           vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
           task.wait(1)
           vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end)
        Rayfield:Notify({Title = "Sistema", Content = "Anti-AFK Ativado com sucesso!", Duration = 2})
   end,
})

TabMisc:CreateButton({
   Name = "Destruir Hub Completamente",
   Callback = function()
        if flightConnection then flightConnection:Disconnect() end
        getgenv().Flying = false
        getgenv().KillAura = false
        Rayfield:Destroy()
   end,
})

Rayfield:LoadConfiguration()

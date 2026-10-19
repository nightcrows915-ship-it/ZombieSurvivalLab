--[[
    ⚔️ TITAN HUB - REMOTE FLY INTEGRATION ⚔️
    - UI Library: Rayfield Interface Suite
    - Features: Voo via loadstring direto do seu link + Kill Aura + Anti-AFK
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- 1. CRIAÇÃO DA JANELA
local Window = Rayfield:CreateWindow({
   Name = "⚔️ TITAN HUB | V38 REMOTE FLY",
   LoadingTitle = "Carregando Titan Hub...",
   LoadingSubtitle = "by Zyon",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TitanHubConfig", 
      FileName = "TitanRemoteFlyConfig"
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
getgenv().KillAura = false
getgenv().KillAuraRange = 25

-- FUNÇÃO DE VOO VIA LOADSTRING DO SEU LINK
local flyEnv = nil
TabMain:CreateToggle({
   Name = "Ativar Voo (Link Externo)",
   CurrentValue = false,
   Flag = "ToggleFlyRemote", 
   Callback = function(Value)
      if Value then
          pcall(function()
              flyEnv = loadstring(game:HttpGet("https://raw.githubusercontent.com/nightcrows915-ship-it/ZombieSurvivalLab/refs/heads/main/Voar/fly.lua"))()
          end)
          Rayfield:Notify({Title = "Voo", Content = "Script de voo carregado via loadstring!", Duration = 2})
      else
          pcall(function()
              if flyEnv and type(flyEnv) == "table" and flyEnv.Stop then
                  flyEnv.Stop()
              elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                  LocalPlayer.Character.Humanoid.PlatformStand = false
              end
          end)
          Rayfield:Notify({Title = "Voo", Content = "Voo desativado.", Duration = 2})
      end
   end,
})

-- LOOP DO KILL AURA & AUTO EQUIP
task.spawn(function()
    while true do
        task.wait(0.2)
        if getgenv().KillAura then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- Auto Equip Tool
                local tool = char:FindFirstChildOfClass("Tool")
                if not tool then
                    local backpackTool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                    if backpackTool then
                        local hum = char:FindFirstChild("Humanoid")
                        if hum then hum:EquipTool(backpackTool) end
                    end
                end

                -- Atacar entidades próximas que se movem
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") and v ~= char then
                        local mHum = v:FindFirstChild("Humanoid")
                        local mRoot = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso")
                        if mHum and mRoot and mHum.Health > 0 then
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

-- SEÇÃO DE COMBATE
local SectionAura = TabMain:CreateSection("Combate Automático")

TabMain:CreateToggle({
   Name = "Ativar Kill Aura (Auto Ataca Mobs)",
   CurrentValue = false,
   Flag = "ToggleKillAura", 
   Callback = function(Value)
      getgenv().KillAura = Value
      Rayfield:Notify({Title = "Kill Aura", Content = Value and "Ligado!" or "Desligado!", Duration = 2})
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

-- ABA MISC
TabMisc:CreateButton({
   Name = "Ativar Anti-AFK",
   Callback = function()
        local vu = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
           vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
           task.wait(1)
           vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end)
        Rayfield:Notify({Title = "Sistema", Content = "Anti-AFK Ativado!", Duration = 2})
   end,
})

TabMisc:CreateButton({
   Name = "Destruir Hub Completamente",
   Callback = function()
        getgenv().KillAura = false
        Rayfield:Destroy()
   end,
})

Rayfield:LoadConfiguration()

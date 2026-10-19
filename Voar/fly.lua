--[[
    ⚔️ TITAN HUB - ULTIMATE ZOMBIE SURVIVAL EDITION ⚔️
    - UI Library: Rayfield Interface Suite
    - Integrado com seu Script de Voo via loadstring oficial
    - Kill Aura Avançado (Equip + Disparo automático via GunKit Remote)
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- 1. CRIAÇÃO DA JANELA
local Window = Rayfield:CreateWindow({
   Name = "⚔️ TITAN HUB | ZOMBIE SURVIVAL ULTIMATE",
   LoadingTitle = "Carregando Titan Hub...",
   LoadingSubtitle = "by Zyon",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TitanHubConfig", 
      FileName = "TitanSurvivalConfig"
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
getgenv().KillAuraRange = 50

-- CARREGAR O VOO DIRETAMENTE DO SEU LINK
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
          Rayfield:Notify({Title = "Voo Ativado", Content = "Script de voo carregado com sucesso!", Duration = 2})
      else
          pcall(function()
              if flyEnv and type(flyEnv) == "table" and flyEnv.Stop then
                  flyEnv.Stop()
              elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                  LocalPlayer.Character.Humanoid.PlatformStand = false
              end
          end)
          Rayfield:Notify({Title = "Voo Desativado", Content = "Modo de voo desligado.", Duration = 2})
      end
   end,
})

-- LOOP DE KILL AURA (Compatível com GunKit & Mobs do Jogo)
task.spawn(function()
    local gunTriggerRemote = ReplicatedStorage:FindFirstChild("GunTrigger", true)
    
    while true do
        task.wait(0.15)
        if getgenv().KillAura then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- 1. Garante que está com a arma equipada
                local tool = char:FindFirstChildOfClass("Tool")
                if not tool then
                    local backpackTool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                    if backpackTool then
                        local hum = char:FindFirstChild("Humanoid")
                        if hum then hum:EquipTool(backpackTool) end
                    end
                end

                -- 2. Varredura de alvos (Zumbis e Mobs no Workspace)
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") and v ~= char then
                        local mHum = v:FindFirstChild("Humanoid")
                        local mRoot = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso")
                        if mHum and mRoot and mHum.Health > 0 then
                            -- Ignora outros jogadores, foca em inimigos/mobs
                            if not Players:GetPlayerFromCharacter(v) then
                                local dist = (root.Position - mRoot.Position).Magnitude
                                if dist <= getgenv().KillAuraRange then
                                    -- Ativa a ferramenta na mão
                                    local activeTool = char:FindFirstChildOfClass("Tool")
                                    if activeTool then
                                        activeTool:Activate()
                                    end
                                    -- Dispara o remote do GunKit se disponível para dano instantâneo
                                    if gunTriggerRemote then
                                        pcall(function()
                                            gunTriggerRemote:FireServer(mRoot.Position)
                                        end)
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
local SectionAura = TabMain:CreateSection("Kill Aura Automático")

TabMain:CreateToggle({
   Name = "Ativar Kill Aura",
   CurrentValue = false,
   Flag = "ToggleKillAura", 
   Callback = function(Value)
      getgenv().KillAura = Value
      Rayfield:Notify({Title = "Kill Aura", Content = Value and "Ligado!" or "Desligado!", Duration = 2})
   end,
})

TabMain:CreateSlider({
   Name = "Alcance do Kill Aura",
   Range = {15, 150},
   Increment = 5,
   Suffix = " Studs",
   CurrentValue = 50,
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

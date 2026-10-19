-- [[ OMNI-SCANNER V4: BRAIN HUNTER ]] --
-- Foco: Encontrar a Lógica da IA (Modules) e os Comandos (Remotes)
-- Baseado na Engine V3 (Anti-Lag / Mobile Friendly)

local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- CONFIGURAÇÕES OTIMIZADAS
local Config = {
    IgnoreVisuals = true,  -- Ignora gráficos pra não travar
    ScanModules = true,    -- ESSENCIAL: Procura o cérebro do jogo
    ScanRemotes = true,    -- ESSENCIAL: Procura os ataques
}

-- UI SETUP (Dark Neon V4)
local ScreenName = "OmniBrainHunter"
if CoreGui:FindFirstChild(ScreenName) then CoreGui[ScreenName]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ScreenName
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50) -- Vermelho Agressivo
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
Title.Text = "🧠 BRAIN HUNTER V4 (AI SCANNER)"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0.12, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Pronto para caçar a IA..."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12

-- Lista
local ScrollList = Instance.new("ScrollingFrame", MainFrame)
ScrollList.Size = UDim2.new(0.98, 0, 0.65, 0)
ScrollList.Position = UDim2.new(0.01, 0, 0.2, 0)
ScrollList.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
ScrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollList.AutomaticCanvasSize = Enum.AutomaticSize.Y
local UIList = Instance.new("UIListLayout", ScrollList)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- Variáveis
local LogHistory = {}    
local SeenPaths = {}     
local Connections = {}
local IsScanning = false
local LogQueue = {}

-- [[ 1. O CÉREBRO (CLASSIFICADOR) ]] --
local function GetLogType(obj)
    local class = obj.ClassName
    local name = obj.Name:lower()
    
    -- DETECTOR DE IA (PRIORIDADE MÁXIMA)
    if name:find("ai") or name:find("brain") or name:find("controller") or name:find("combat") or name:find("state") or name:find("behavior") then
        if class == "ModuleScript" or class == "LocalScript" then
            return "🚨 [AI-LOGIC]", Color3.fromRGB(255, 0, 0) -- VERMELHO
        end
    end

    -- Comunicação (Ataques)
    if class == "RemoteEvent" then return "📡 [REMOTE]", Color3.fromRGB(255, 100, 255) end
    if class == "RemoteFunction" then return "📡 [FUNC]", Color3.fromRGB(200, 50, 200) end
    if class == "BindableEvent" then return "🔗 [BIND]", Color3.fromRGB(255, 170, 0) end
    
    -- Código Geral
    if class == "ModuleScript" then return "📜 [MODULE]", Color3.fromRGB(0, 170, 255) end
    
    -- Interação
    if class == "ProximityPrompt" then return "👋 [INTERACT]", Color3.fromRGB(0, 255, 255) end
    
    -- Entidades
    if class == "Model" and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then 
        return "💀 [MOB/NPC]", Color3.fromRGB(255, 255, 0) 
    end
    
    return nil, nil
end

local function IsIgnored(obj)
    if not Config.IgnoreVisuals then return false end
    local class = obj.ClassName
    -- Filtra tudo que não é código ou lógica
    if class == "Part" or class == "MeshPart" or class == "Weld" or class == "Attachment" or 
       class == "Sound" or class == "Animation" or class == "ParticleEmitter" or 
       class == "Trail" or class == "Beam" or class == "Decal" or class == "Texture" or class == "Animator" then
       return true
    end
    return false
end

-- [[ 2. PROCESSADOR ]] --
local function ProcessObject(obj)
    if not obj or not obj.Parent then return end
    if IsIgnored(obj) then return end
    
    local logType, color = GetLogType(obj)
    if not logType then return end 
    
    local fullPath = obj:GetFullName()
    
    -- ANTI-DUPLICAÇÃO
    if SeenPaths[fullPath] then return end
    SeenPaths[fullPath] = true 
    
    local timestamp = os.date("%X")
    local display = string.format("%s %s", logType, obj.Name)
    local fileEntry = string.format("[%s] TYPE: %s | PATH: %s", timestamp, logType, fullPath)
    
    table.insert(LogHistory, fileEntry)
    table.insert(LogQueue, {Text = display, Color = color})
end

-- [[ 3. SCANNER AUTOMÁTICO ]] --
local function MonitorService(service)
    local conn = service.DescendantAdded:Connect(function(descendant)
        if IsScanning then
            ProcessObject(descendant)
        end
    end)
    table.insert(Connections, conn)
end

-- [[ UI UPDATE ]] --
RunService.Heartbeat:Connect(function()
    if #LogQueue > 0 then
        local count = 0
        while #LogQueue > 0 and count < 5 do
            local data = table.remove(LogQueue, 1)
            count = count + 1
            
            local lbl = Instance.new("TextLabel", ScrollList)
            lbl.Size = UDim2.new(1, 0, 0, 18)
            lbl.BackgroundTransparency = 1
            lbl.Text = data.Text
            lbl.TextColor3 = data.Color
            lbl.Font = Enum.Font.Code
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
        end
        StatusLabel.Text = "Objetos Capturados: " .. #LogHistory
    end
end)

-- [[ FUNÇÕES ]] --
local function ToggleScan()
    IsScanning = not IsScanning
    if IsScanning then
        StatusLabel.Text = "🟢 CAÇANDO CÓDIGOS DE IA..."
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        if #Connections == 0 then
            -- Monitora onde os scripts se escondem
            MonitorService(ReplicatedStorage) -- Módulos compartilhados
            MonitorService(Workspace)         -- Mobs nascendo
            MonitorService(LocalPlayer.PlayerGui) -- Scripts de interface
            MonitorService(LocalPlayer.PlayerScripts) -- Scripts locais
        end
    else
        StatusLabel.Text = "🔴 PAUSADO"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end

local function FullSnapshot()
    StatusLabel.Text = "📸 VARRENDO TUDO (Isso pode levar uns segundos)..."
    task.wait(0.1)
    
    local targets = {ReplicatedStorage, Workspace, LocalPlayer.PlayerGui, LocalPlayer.PlayerScripts}
    
    for _, service in pairs(targets) do
        for _, v in pairs(service:GetDescendants()) do
            ProcessObject(v)
        end
        task.wait() -- Anti-Crash
    end
    StatusLabel.Text = "📸 Varredura Completa!"
end

local function SaveToFile()
    if #LogHistory == 0 then return end
    local fileName = "BRAIN_LOG_" .. os.date("%H%M%S") .. ".txt"
    local content = table.concat(LogHistory, "\n")
    
    local success, err = pcall(function() writefile(fileName, content) end)
    
    if success then
        StatusLabel.Text = "✅ SALVO: " .. fileName
        MainFrame.BorderColor3 = Color3.new(0,1,0)
        task.wait(0.5)
        MainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
    else
        StatusLabel.Text = "❌ ERRO AO SALVAR"
    end
end

local function ClearLogs()
    LogHistory = {}
    SeenPaths = {}
    for _, v in pairs(ScrollList:GetChildren()) do 
        if v:IsA("TextLabel") then v:Destroy() end 
    end
    StatusLabel.Text = "🗑️ LIMPADO"
end

-- [[ BOTÕES ]] --
local BtnContainer = Instance.new("Frame", MainFrame)
BtnContainer.Size = UDim2.new(1, -10, 0.15, 0)
BtnContainer.Position = UDim2.new(0, 5, 0.82, 0)
BtnContainer.BackgroundTransparency = 1

local function CreateBtn(text, order, color, func)
    local btn = Instance.new("TextButton", BtnContainer)
    btn.Size = UDim2.new(0.23, 0, 1, 0)
    btn.Position = UDim2.new((order-1)*0.25, 0, 0, 0)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(func)
end

CreateBtn("MONITORAR", 1, Color3.fromRGB(200, 50, 50), ToggleScan)
CreateBtn("SNAPSHOT", 2, Color3.fromRGB(200, 150, 0), FullSnapshot)
CreateBtn("SALVAR TXT", 3, Color3.fromRGB(0, 150, 200), SaveToFile)
CreateBtn("LIMPAR", 4, Color3.fromRGB(100, 100, 100), ClearLogs)

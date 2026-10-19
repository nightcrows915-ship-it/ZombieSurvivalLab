--[[
    🦍 MONKEY APOCALYPSE HUB - V5 (FORÇAR CLIQUE TELA + MIRA NA TELA) 🦍
    - Correção de Tiro: Simulação de input de tela na posição exata do alvo (ScreenPoint)
    - Hitbox: Varredura profunda em todas as pastas de inimigos do jogo
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Globais de Controle
getgenv().AutoShootFocused = false
getgenv().KillAura = false
getgenv().ExpandHitbox = false
getgenv().HitboxSize = 40
getgenv().FlyEnabled = false
getgenv().NoClipEnabled = false
getgenv().AutoChest = false
getgenv().PotatoMode = false
getgenv().SpeedHack = false

local CurrentTarget = nil
local Camera = Workspace.CurrentCamera

-- Função Draggable Lisa
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    gui.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
end

-- Simula o clique real do mouse na tela para disparar a arma do GunKit
local function SimularCliqueNaTela(vector2Pos)
    pcall(function()
        -- Ativa a ferramenta na mão
        local char = LocalPlayer.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end

        -- Simula o evento de clique do mouse na posição exata do inimigo na tela
        VirtualInputManager:SendMouseButtonEvent(vector2Pos.X, vector2Pos.Y, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(vector2Pos.X, vector2Pos.Y, 0, false, game, 1)
    end)
end

-- Interface Visual Glass UI
local function LoadGlassUI()
    if CoreGui:FindFirstChild("MonkeyApocalypseUI") then CoreGui.MonkeyApocalypseUI:Destroy() end
    local ScreenGui = Instance.new("ScreenGui"); pcall(function() ScreenGui.Parent = CoreGui end); if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end; ScreenGui.Name = "MonkeyApocalypseUI"; ScreenGui.ResetOnSpawn = false 

    local Theme = {Background=Color3.fromRGB(18,18,22), Transparency=0.10, Sidebar=Color3.fromRGB(25,25,30), Accent=Color3.fromRGB(255,165,0), Text=Color3.fromRGB(255,255,255), TextDim=Color3.fromRGB(160,160,160)}
    local function AddCorner(i,r) local c=Instance.new("UICorner",i) c.CornerRadius=UDim.new(0,r) c.Parent=i end
    local function AddStroke(i,c,t) local s=Instance.new("UIStroke",i) s.Color=c s.Thickness=t s.Parent=i end

    local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.BackgroundColor3=Theme.Background; MainFrame.BackgroundTransparency=Theme.Transparency; MainFrame.Position=UDim2.new(0.5,-225,0.3,0); MainFrame.Size=UDim2.new(0,450,0,380); MakeDraggable(MainFrame); AddCorner(MainFrame,16); AddStroke(MainFrame,Color3.fromRGB(60,60,60),1)
    local Sidebar = Instance.new("Frame", MainFrame); Sidebar.BackgroundColor3=Theme.Sidebar; Sidebar.BackgroundTransparency=0.5; Sidebar.Size=UDim2.new(0,130,1,0); AddCorner(Sidebar,16)
    local SideFix = Instance.new("Frame", Sidebar); SideFix.BackgroundColor3=Theme.Sidebar; SideFix.BackgroundTransparency=0.5; SideFix.BorderSizePixel=0; SideFix.Size=UDim2.new(0,20,1,0); SideFix.Position=UDim2.new(1,-10,0,0); SideFix.ZIndex=0
    local Title = Instance.new("TextLabel", Sidebar); Title.Text="MONKEY\nAPOCALYPSE"; Title.Size=UDim2.new(1,0,0,60); Title.BackgroundTransparency=1; Title.TextColor3=Theme.Accent; Title.Font=Enum.Font.GothamBlack; Title.TextSize=18; Title.LineHeight=0.9
    local TabContainer = Instance.new("Frame", Sidebar); TabContainer.BackgroundTransparency=1; TabContainer.Position=UDim2.new(0,10,0,80); TabContainer.Size=UDim2.new(1,-20,1,-100); local TabList=Instance.new("UIListLayout",TabContainer); TabList.Padding=UDim.new(0,10); TabList.SortOrder=Enum.SortOrder.LayoutOrder
    local MiniBtn = Instance.new("TextButton", Sidebar); MiniBtn.Text="Minimizar"; MiniBtn.BackgroundColor3=Color3.fromRGB(255,60,60); MiniBtn.BackgroundTransparency=0.8; MiniBtn.Size=UDim2.new(1,-20,0,30); MiniBtn.Position=UDim2.new(0,10,1,-40); MiniBtn.Font=Enum.Font.GothamBold; MiniBtn.TextColor3=Theme.Text; MiniBtn.TextSize=12; AddCorner(MiniBtn,8)
    local Content = Instance.new("Frame", MainFrame); Content.BackgroundTransparency=1; Content.Position=UDim2.new(0,140,0,10); Content.Size=UDim2.new(1,-150,1,-20)
    local OpenBtn = Instance.new("ImageButton", ScreenGui); OpenBtn.BackgroundColor3=Color3.new(1,1,1); OpenBtn.BackgroundTransparency=1; OpenBtn.Size=UDim2.new(0,70,0,70); OpenBtn.Position=UDim2.new(0,20,0.5,0); OpenBtn.Image=MY_LOGO; OpenBtn.Visible=false; OpenBtn.ScaleType=Enum.ScaleType.Fit; MakeDraggable(OpenBtn)
    MiniBtn.MouseButton1Click:Connect(function() MainFrame.Visible=false; OpenBtn.Visible=true end); OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible=true; OpenBtn.Visible=false end)

    local Tabs={}; local Pages={} 
    local function CreateTab(n) local b=Instance.new("TextButton",TabContainer); b.BackgroundColor3=Theme.Background; b.BackgroundTransparency=1; b.Size=UDim2.new(1,0,0,35); b.Text=n; b.Font=Enum.Font.GothamBold; b.TextColor3=Theme.TextDim; b.TextSize=14; b.TextXAlignment=Enum.TextXAlignment.Left; AddCorner(b,8); local p=Instance.new("UIPadding",b); p.PaddingLeft=UDim.new(0,10)
    local g=Instance.new("ScrollingFrame",Content); g.Size=UDim2.new(1,0,1,0); g.BackgroundTransparency=1; g.BorderSizePixel=0; g.ScrollBarThickness=2; g.Visible=false; local l=Instance.new("UIListLayout",g); l.Padding=UDim.new(0,8); l.SortOrder=Enum.SortOrder.LayoutOrder
    b.MouseButton1Click:Connect(function() for _,v in pairs(Tabs) do TweenService:Create(v,TweenInfo.new(0.2),{BackgroundTransparency=1,TextColor3=Theme.TextDim}):Play() end; for _,v in pairs(Pages) do v.Visible=false end; TweenService:Create(b,TweenInfo.new(0.2),{BackgroundTransparency=0.8,TextColor3=Theme.Accent}):Play(); g.Visible=true end)
    table.insert(Tabs,b); table.insert(Pages,g); return g end

    local function CreateToggle(p,t,c) local f=Instance.new("Frame",p); f.BackgroundColor3=Color3.fromRGB(30,30,35); f.BackgroundTransparency=0.4; f.Size=UDim2.new(1,-5,0,45); AddCorner(f,10)
    local l=Instance.new("TextLabel",f); l.Text=t; l.Font=Enum.Font.GothamMedium; l.TextColor3=Theme.Text; l.TextSize=14; l.Size=UDim2.new(0.7,0,1,0); l.Position=UDim2.new(0,15,0,0); l.BackgroundTransparency=1; l.TextXAlignment=Enum.TextXAlignment.Left
    local s=Instance.new("TextButton",f); s.Text=""; s.BackgroundColor3=Color3.fromRGB(50,50,55); s.Size=UDim2.new(0,44,0,24); s.Position=UDim2.new(1,-55,0.5,-12); AddCorner(s,12)
    local d=Instance.new("Frame",s); d.BackgroundColor3=Color3.fromRGB(200,200,200); d.Size=UDim2.new(0,18,0,18); d.Position=UDim2.new(0,3,0.5,-9); AddCorner(d,9)
    local st=false; s.MouseButton1Click:Connect(function() st=not st; TweenService:Create(s,TweenInfo.new(0.2),{BackgroundColor3=st and Theme.Accent or Color3.fromRGB(50,50,55)}):Play(); TweenService:Create(d,TweenInfo.new(0.2),{Position=st and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)}):Play(); c(st) end) end

    local function CreateButton(p,t,c) local b=Instance.new("TextButton",p); b.BackgroundColor3=Color3.fromRGB(40,40,45); b.BackgroundTransparency=0.4; b.Size=UDim2.new(1,-5,0,40); b.Text=t; b.TextColor3=Theme.Text; b.Font=Enum.Font.GothamBold; b.TextSize=14; AddCorner(b,8); b.MouseButton1Click:Connect(c) end
    local function CreateSection(p,t) local l=Instance.new("TextLabel",p); l.Text=t; l.Size=UDim2.new(1,0,0,25); l.BackgroundTransparency=1; l.TextColor3=Theme.TextDim; l.Font=Enum.Font.Gotham; l.TextSize=12 end

    -- ==============================================================================
    -- 2. LÓGICAS DE COMBATE (CLIQUE NA TELA + HITBOX CORRIGIDA)
    -- ==============================================================================

    -- [[ AUTO ATIRAR FOCADO (1 POR VEZ COM CLIQUE NA TELA) ]]
    task.spawn(function()
        while true do
            task.wait(0.1)
            if getgenv().AutoShootFocused then
                pcall(function()
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if not root then return end

                    -- Valida alvo atual
                    local targetValid = false
                    if CurrentTarget and CurrentTarget.Parent then
                        local hum = CurrentTarget:FindFirstChild("Humanoid")
                        if hum and hum.Health > 0 then targetValid = true end
                    end

                    -- Busca o mais próximo se não houver
                    if not targetValid then
                        CurrentTarget = nil
                        local minDist = 99999
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj ~= char then
                                if not Players:GetPlayerFromCharacter(obj) then
                                    local hum = obj.Humanoid
                                    if hum.Health > 0 then
                                        local dist = (root.Position - obj.HumanoidRootPart.Position).Magnitude
                                        if dist < minDist then
                                            minDist = dist
                                            CurrentTarget = obj
                                        end
                                    end
                                end
                            end
                        end
                    end

                    -- Se achou, olha e clica na tela na posição exata do bicho
                    if CurrentTarget then
                        local tRoot = CurrentTarget:FindFirstChild("HumanoidRootPart")
                        if tRoot then
                            root.CFrame = CFrame.new(root.Position, Vector3.new(tRoot.Position.X, root.Position.Y, tRoot.Position.Z))
                            
                            -- Converte a posição 3D do monstro para a tela 2D do jogo
                            local screenPos, onScreen = Camera:WorldToScreenPoint(tRoot.Position)
                            if onScreen then
                                SimularCliqueNaTela(Vector2.new(screenPos.X, screenPos.Y))
                            else
                                -- Se estiver fora da tela, clica no centro
                                SimularCliqueNaTela(Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2))
                            end
                        end
                    end
                end)
            else
                CurrentTarget = nil
            end
        end
    end)

    -- [[ KILL AURA ]]
    task.spawn(function()
        while true do
            task.wait(0.15)
            if getgenv().KillAura then
                pcall(function()
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if not root then return end

                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj ~= char then
                            if not Players:GetPlayerFromCharacter(obj) then
                                local hum = obj.Humanoid
                                if hum.Health > 0 then
                                    local tRoot = obj.HumanoidRootPart
                                    local dist = (root.Position - tRoot.Position).Magnitude
                                    if dist <= 35 then
                                        local screenPos, onScreen = Camera:WorldToScreenPoint(tRoot.Position)
                                        if onScreen then
                                            SimularCliqueNaTela(Vector2.new(screenPos.X, screenPos.Y))
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

    -- [[ HITBOX EXPANDIDA E VISÍVEL CORRIGIDA ]]
    task.spawn(function()
        while true do
            task.wait(0.5)
            if getgenv().ExpandHitbox then
                pcall(function()
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj ~= LocalPlayer.Character then
                            if not Players:GetPlayerFromCharacter(obj) then
                                local hrp = obj.HumanoidRootPart
                                hrp.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
                                hrp.Transparency = 0.3 -- Bem visível em vermelho vivo
                                hrp.Color = Color3.fromRGB(255, 0, 0)
                                hrp.Material = Enum.Material.Neon
                                hrp.CanCollide = false
                            end
                        end
                    end
                end)
            end
        end
    end)

    -- [[ FLY (VOAR) ]]
    task.spawn(function()
        local bg, bv
        RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if getgenv().FlyEnabled and root and Camera then
                if not root:FindFirstChild("FlyBodyGyro") then
                    bg = Instance.new("BodyGyro", root); bg.Name = "FlyBodyGyro"; bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    bv = Instance.new("BodyVelocity", root); bv.Name = "FlyBodyVelocity"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Velocity = Vector3.new(0,0,0)
                end
                bg.CFrame = Camera.CFrame
                local moveDir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
                bv.Velocity = moveDir * 50
            else
                if root then
                    if root:FindFirstChild("FlyBodyGyro") then root.FlyBodyGyro:Destroy() end
                    if root:FindFirstChild("FlyBodyVelocity") then root.FlyBodyVelocity:Destroy() end
                end
            end
        end)
    end)

    -- [[ NOCLIP ]]
    RunService.Stepped:Connect(function()
        if getgenv().NoClipEnabled then
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end)

    -- Auto-Coleta de Baús
    task.spawn(function()
        while true do
            task.wait(1)
            if getgenv().AutoChest then
                pcall(function()
                    for _, v in pairs(Workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and (v.Parent.Name:match("Chest") or v.Parent.Name:match("SplitChest")) then
                            fireproximityprompt(v)
                        end
                    end
                end)
            end
        end
    end)

    -- Modo Batata
    local function TogglePotato(bool)
        getgenv().PotatoMode = bool
        if bool then
            Lighting.GlobalShadows = false
            Lighting.Brightness = 0
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then v:Destroy() end
            end
            local map = Workspace:FindFirstChild("Map")
            if map then
                for _, v in pairs(map:GetDescendants()) do
                    if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.CastShadow = false
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
                end
            end
        end
    end

    -- Abas da Interface
    local PageCombat = CreateTab("Combate")
    local PageMov = CreateTab("Movimento")
    local PageVisual = CreateTab("Visual")
    local PageMisc = CreateTab("Utilidades")

    CreateSection(PageCombat, "SISTEMAS DE TIRO E ABATE")
    CreateToggle(PageCombat, "🎯 Auto Atirar (Clique Simulado)", function(state) getgenv().AutoShootFocused = state end)
    CreateToggle(PageCombat, "⚔️ Kill Aura (Ataca Próximos)", function(state) getgenv().KillAura = state end)
    CreateToggle(PageCombat, "💥 Hitbox Gigante Visível", function(state) getgenv().ExpandHitbox = state end)

    CreateSection(PageMov, "MOBILIDADE")
    CreateToggle(PageMov, "🕊️ Voar (Fly - WASD)", function(state) getgenv().FlyEnabled = state end)
    CreateToggle(PageMov, "🧱 Atravessar Paredes (NoClip)", function(state) getgenv().NoClipEnabled = state end)
    CreateToggle(PageMov, "⚡ SpeedHack (WalkSpeed 32)", function(state) getgenv().SpeedHack = state end)

    CreateSection(PageVisual, "OTIMIZAÇÃO")
    CreateToggle(PageVisual, "🥔 Modo Batata (FPS Max)", function(state) TogglePotato(state) end)

    CreateSection(PageMisc, "OUTROS")
    CreateToggle(PageMisc, "📦 Auto Coletar Baús", function(state) getgenv().AutoChest = state end)
    CreateButton(PageMisc, "🔄 Resetar Personagem", function()
        pcall(function() LocalPlayer.Character.Humanoid.Health = 0 end)
    end)
end

LoadGlassUI()

-- Loop para SpeedHack
task.spawn(function()
    while true do
        task.wait(0.5)
        if getgenv().SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 32
        end
    end
end)

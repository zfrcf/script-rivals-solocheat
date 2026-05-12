-- --- NETTOYAGE DES INSTANCES PRÉCÉDENTES ---
pcall(function()
    for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
        if gui.Name == "Rayfield" then
            gui:Destroy()
        end
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- --- CONFIGURATION GLOBALE SÉCURISÉE ---
getgenv().Config = {
    Platform = "PC",
    AimbotEnabled = true,
    AimbotStrength = 0.7,
    AimFOV = 200,
    SilentAimEnabled = false,
    TriggerbotEnabled = true,
    Ragebot = false,
    ESPEnabled = true,
    InventoryESP = true,
    KillSound = false,
    WalkSpeed = 16,
    InfiniteJump = true,
    TPEnabled = true,
    StretchEnabled = true,
    StretchFactor = 0.7,
    FlyEnabled = false,
    FlySpeed = 50,
    Noclip = false,
    DarkTexturesEnabled = false,
    WeaponSkin = "Aucun"
}

-- --- SYSTÈME DE SAUVEGARDE JSON (Anti-Crash) ---
local ConfigFile = "SoloCheat_Config.json"

local function SaveConfig()
    pcall(function()
        if writefile then
            local json = HttpService:JSONEncode(getgenv().Config)
            writefile(ConfigFile, json)
        end
    end)
end

local function LoadConfig()
    local success, err = pcall(function()
        if readfile then
            local content = readfile(ConfigFile)
            local data = HttpService:JSONDecode(content)
            if data then
                for key, value in pairs(data) do
                    if getgenv().Config[key] ~= nil then
                        getgenv().Config[key] = value
                    end
                end
            end
        end
    end)
    return success
end

-- Tentative de chargement de la configuration existante
LoadConfig()

-- --- MAPPING DES ICÔNES D'ARMES ---
local ItemIcons = {
    ["Sniper"] = "rbxassetid://18821942711",
    ["Knife"] = "rbxassetid://18821940330",
    ["Katana"] = "rbxassetid://18821932520",
    ["Shuriken"] = "rbxassetid://18821935000",
    ["Saber"] = "rbxassetid://18821932520"
}

-- --- MODULE : PLATFORM SPOOFER ---
local oldPlatform
oldPlatform = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and self == UIS and key == "GetPlatform" then
        if getgenv().Config.Platform == "Mobile" then return Enum.Platform.IOS
        elseif getgenv().Config.Platform == "Console" then return Enum.Platform.XBoxOne
        elseif getgenv().Config.Platform == "PlayStation" then return Enum.Platform.PS4
        end
    end
    return oldPlatform(self, key)
end)

-- --- CERCLE FOV (Sécurisé sans API Drawing obligatoire) ---
local FOVCircle
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    FOVCircle.Transparency = 0.7
    FOVCircle.Visible = false
end)

-- --- FONCTIONS DE BASE ---
local function ApplyWeaponSkin(tool)
    if not tool or getgenv().Config.WeaponSkin == "Aucun" then return end
    local mat = Enum.Material.Plastic
    local col = Color3.fromRGB(255, 255, 255)
    
    if getgenv().Config.WeaponSkin == "Néon Cyan" then mat = Enum.Material.Neon col = Color3.fromRGB(0, 255, 255)
    elseif getgenv().Config.WeaponSkin == "Or Pur" then mat = Enum.Material.Foil col = Color3.fromRGB(255, 215, 0)
    elseif getgenv().Config.WeaponSkin == "Rubis Néon" then mat = Enum.Material.Neon col = Color3.fromRGB(255, 0, 50)
    end

    for _, part in pairs(tool:GetDescendants()) do
        if part:IsA("BasePart") then part.Material = mat part.Color = col end
    end
end

local function ApplyDarkTextures(char)
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.SmoothPlastic
            part.Color = Color3.fromRGB(255, 255, 255) -- Texture optimisée
        end
    end
end

local function PlayKillSound()
    local s = Instance.new("Sound", SoundService)
    s.SoundId = "rbxassetid://160432331" -- Ding classique
    s.Volume = 5
    s:Play()
    Debris:AddItem(s, 2)
end

local function GetClosest()
    local target, shortest = nil, getgenv().Config.AimFOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if dist < shortest then shortest = dist target = head end
                end
            end
        end
    end
    return target
end

-- --- CHARGEMENT DE L'INTERFACE RAYFIELD ---
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Rivals Ultimate Hub",
   LoadingTitle = "Initialisation du système...",
   LoadingSubtitle = "WASD Fly & Stabilité V24",
   ConfigurationSaving = { Enabled = false } -- Désactivé au profit du JSON natif propre
})

-- --- ONGLETS ---
local TabCombat = Window:CreateTab("Combat", 4483362458)
local TabVisuals = Window:CreateTab("Visuels", 4483362458)
local TabMove = Window:CreateTab("Mouvement", 4483362458)
local TabConfig = Window:CreateTab("Système", 4483362458)

-- --- [ONGLET COMBAT] ---
TabCombat:CreateToggle({Name = "Aimbot (Clic Droit)", CurrentValue = getgenv().Config.AimbotEnabled, Callback = function(v) getgenv().Config.AimbotEnabled = v end})
TabCombat:CreateSlider({Name = "Vitesse Aimbot (Smooth)", Range = {0.1, 1}, Increment = 0.05, CurrentValue = getgenv().Config.AimbotStrength, Callback = function(v) getgenv().Config.AimbotStrength = v end})
TabCombat:CreateToggle({Name = "Triggerbot", CurrentValue = getgenv().Config.TriggerbotEnabled, Callback = function(v) getgenv().Config.TriggerbotEnabled = v end})
TabCombat:CreateToggle({Name = "Ragebot (TP sur cible)", CurrentValue = getgenv().Config.Ragebot, Callback = function(v) getgenv().Config.Ragebot = v end})
TabCombat:CreateToggle({Name = "Kill Sound (Ding)", CurrentValue = getgenv().Config.KillSound, Callback = function(v) getgenv().Config.KillSound = v end})
TabCombat:CreateSlider({Name = "Rayon FOV", Range = {50, 600}, Increment = 10, CurrentValue = getgenv().Config.AimFOV, Callback = function(v) getgenv().Config.AimFOV = v end})
TabCombat:CreateToggle({Name = "Afficher le cercle FOV", CurrentValue = false, Callback = function(v) if FOVCircle then FOVCircle.Visible = v end end})

-- --- [ONGLET VISUELS] ---
TabVisuals:CreateToggle({Name = "ESP Character (Squelette/Cadre)", CurrentValue = getgenv().Config.ESPEnabled, Callback = function(v) getgenv().Config.ESPEnabled = v end})
TabVisuals:CreateToggle({Name = "Stuff ESP (Icônes & Contour Bleu)", CurrentValue = getgenv().Config.InventoryESP, Callback = function(v) getgenv().Config.InventoryESP = v end})
TabVisuals:CreateToggle({Name = "Stretched Resolution", CurrentValue = getgenv().Config.StretchEnabled, Callback = function(v) getgenv().Config.StretchEnabled = v end})
TabVisuals:CreateSlider({Name = "Facteur Stretch", Range = {0.1, 1}, Increment = 0.05, CurrentValue = getgenv().Config.StretchFactor, Callback = function(v) getgenv().Config.StretchFactor = v end})

TabVisuals:CreateDropdown({
    Name = "Skin d'Arme Personnalisé",
    Options = {"Aucun", "Néon Cyan", "Or Pur", "Rubis Néon"},
    CurrentOption = {getgenv().Config.WeaponSkin},
    MultipleOptions = false,
    Callback = function(Option)
        getgenv().Config.WeaponSkin = Option[1]
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then ApplyWeaponSkin(tool) end
    end
})

-- --- [ONGLET MOUVEMENT (WASD FLY)] ---
TabMove:CreateToggle({Name = "Activer le Fly (WASD)", CurrentValue = getgenv().Config.FlyEnabled, Callback = function(v) getgenv().Config.FlyEnabled = v end})
TabMove:CreateSlider({Name = "Vitesse du Vol", Range = {10, 250}, Increment = 5, CurrentValue = getgenv().Config.FlySpeed, Callback = function(v) getgenv().Config.FlySpeed = v end})
TabMove:CreateSlider({Name = "Vitesse au sol (WalkSpeed)", Range = {16, 150}, Increment = 1, CurrentValue = getgenv().Config.WalkSpeed, Callback = function(v) getgenv().Config.WalkSpeed = v end})
TabMove:CreateToggle({Name = "Saut Infini (Espace)", CurrentValue = getgenv().Config.InfiniteJump, Callback = function(v) getgenv().Config.InfiniteJump = v end})
TabMove:CreateToggle({Name = "Noclip (Traverser les murs)", CurrentValue = getgenv().Config.Noclip, Callback = function(v) getgenv().Config.Noclip = v end})

-- --- [ONGLET SYSTÈME & SPOOFER] ---
TabConfig:CreateSection("Platform Spoofer")
TabConfig:CreateDropdown({
   Name = "Plateforme Simulée",
   Options = {"PC", "Mobile", "Console", "PlayStation"},
   CurrentOption = {getgenv().Config.Platform},
   MultipleOptions = false,
   Callback = function(Option)
      getgenv().Config.Platform = Option[1]
      Rayfield:Notify({Title = "Spoofer", Content = "Métadonnées changées en : " .. Option[1]})
   end,
})

TabConfig:CreateSection("Gestion de Configuration")
TabConfig:CreateButton({Name = "Sauvegarder JSON manuellement", Callback = function()
    SaveConfig()
    Rayfield:Notify({Title = "Système", Content = "Configuration enregistrée avec succès."})
end})

-- --- BOUCLE DE RENDU PRINCIPALE ---
RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Position = UIS:GetMouseLocation()
        FOVCircle.Radius = getgenv().Config.AimFOV
    end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    -- Gestion du Fly (WASD Strict)
    if getgenv().Config.FlyEnabled and hrp and hum then
        hum.PlatformStand = true -- Indispensable pour couper la gravité et les animations de sol
        local moveDir = Vector3.new(0, 0, 0)
        
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        hrp.Velocity = moveDir * getgenv().Config.FlySpeed
    elseif hum and hum.PlatformStand then
        hum.PlatformStand = false
    end

    -- Vitesse de marche et Stretch Resolution
    if hum and not getgenv().Config.FlyEnabled then hum.WalkSpeed = getgenv().Config.WalkSpeed end
    if getgenv().Config.StretchEnabled then
        Camera.CFrame = Camera.CFrame * CFrame.new(0,0,0, 1,0,0, 0, getgenv().Config.StretchFactor, 0, 0,0,1)
    end
    
    -- Noclip
    if getgenv().Config.Noclip then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    -- Gestion Visuelle des Adversaires (Stuff ESP & Highlight)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local pHead = p.Character:FindFirstChild("Head")
            local pHum = p.Character:FindFirstChildOfClass("Humanoid")
            
            -- Cadre/Squelette ESP Basique
            local hl = p.Character:FindFirstChild("RivalsESP")
            if getgenv().Config.ESPEnabled and pHum and pHum.Health > 0 then
                if not hl then
                    hl = Instance.new("Highlight", p.Character)
                    hl.Name = "RivalsESP"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
                hl.Enabled = true
            elseif hl then hl:Destroy() end

            -- Inventory ESP (Images + Cadre actif bleu)
            if pHead then
                local invGui = pHead:FindFirstChild("StuffESP")
                if getgenv().Config.InventoryESP and pHum and pHum.Health > 0 then
                    if not invGui then
                        invGui = Instance.new("BillboardGui", pHead)
                        invGui.Name = "StuffESP"
                        invGui.Size = UDim2.new(0, 200, 0, 40)
                        invGui.AlwaysOnTop = true
                        invGui.ExtentsOffset = Vector3.new(0, 3.5, 0)
                        local container = Instance.new("Frame", invGui)
                        container.Size = UDim2.new(1, 0, 1, 0)
                        container.BackgroundTransparency = 1
                        local layout = Instance.new("UIListLayout", container)
                        layout.FillDirection = Enum.FillDirection.Horizontal
                        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout.Padding = UDim.new(0, 4)
                    end
                    
                    local container = invGui:FindFirstChild("Frame")
                    if container then
                        container:ClearAllChildren()
                        local activeTool = p.Character:FindFirstChildOfClass("Tool")
                        
                        local function RenderItem(name, isActive)
                            local img = Instance.new("ImageLabel", container)
                            img.Size = UDim2.new(0, 30, 0, 30)
                            img.Image = ItemIcons[name] or "rbxassetid://0"
                            img.BackgroundColor3 = isActive and Color3.fromRGB(0, 130, 255) or Color3.fromRGB(25, 25, 25)
                            img.BackgroundTransparency = 0.2
                            
                            if isActive then
                                local stroke = Instance.new("UIStroke", img)
                                stroke.Color = Color3.fromRGB(0, 255, 255)
                                stroke.Thickness = 2
                            end
                        end

                        if activeTool then RenderItem(activeTool.Name, true) end
                        local backpack = p:FindFirstChild("Backpack")
                        if backpack then
                            for _, item in pairs(backpack:GetChildren()) do
                                if item:IsA("Tool") then RenderItem(item.Name, false) end
                            end
                        end
                    end
                elseif invGui then invGui:Destroy() end
            end
        end
    end

    -- Cible Aimbot
    if getgenv().Config.AimbotEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local targetHead = GetClosest()
        if targetHead then
            local pos = Camera:WorldToViewportPoint(targetHead.Position)
            local mouseLoc = UIS:GetMouseLocation()
            mousemoverel((pos.X - mouseLoc.X) * getgenv().Config.AimbotStrength, (pos.Y - mouseLoc.Y) * getgenv().Config.AimbotStrength)
        end
    end

    -- Triggerbot automatique au survol
    if getgenv().Config.TriggerbotEnabled and Mouse.Target then
        local hitPlayer = Players:GetPlayerFromCharacter(Mouse.Target.Parent)
        if hitPlayer and hitPlayer ~= LocalPlayer then mouse1click() end
    end
end)

-- --- BOUCLE SECONDAIRE : RAGEBOT ---
task.spawn(function()
    while task.wait(0.02) do
        if getgenv().Config.Ragebot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local target = GetClosest()
            if target then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 0, 2.5)
                mouse1click()
            end
        end
    end
end)

-- --- ÉVÉNEMENTS (Saut, Téléportation & Sons) ---
UIS.InputBegan:Connect(function(input, isProcessed)
    if isProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space and getgenv().Config.InfiniteJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    elseif input.KeyCode == Enum.KeyCode.E and getgenv().Config.TPEnabled then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0, 3, 0)) end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid").Died:Connect(function()
            if getgenv().Config.KillSound then PlayKillSound() end
        end)
        if getgenv().Config.DarkTexturesEnabled then ApplyDarkTextures(char) end
    end)
end)

-- Application des skins sur les armes existantes
local function HookToolSkin(tool)
    if tool and tool:IsA("Tool") then
        ApplyWeaponSkin(tool)
        tool.Equipped:Connect(function() ApplyWeaponSkin(tool) end)
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child) HookToolSkin(child) end)
end)

if LocalPlayer.Character then
    for _, tool in pairs(LocalPlayer.Character:GetChildren()) do HookToolSkin(tool) end
end
for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do HookToolSkin(tool) end
LocalPlayer.Backpack.ChildAdded:Connect(HookToolSkin)

-- Sauvegarde automatique espacée pour préserver les performances
task.spawn(function()
    while task.wait(45) do SaveConfig() end
end)

Rayfield:Notify({Title = "Succès", Content = "Hub V24 injecté sans erreurs. Fly configuré sur WASD."})

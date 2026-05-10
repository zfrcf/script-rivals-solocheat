-- --- NETTOYAGE DES INSTANCES PRÉCÉDENTES ---
for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
    if gui.Name == "Rayfield" then
        gui:Destroy()
    end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- --- CONFIGURATION GLOBALE ---
getgenv().Config = {
    Platform = "PC",
    AimbotEnabled = true,
    AimbotStrength = 0.7,
    AimFOV = 600,
    SilentAimEnabled = true,
    TriggerbotEnabled = true,
    Ragebot = false,
    ESPEnabled = true,
    KillSound = false,
    WalkSpeed = 16,
    InfiniteJump = true,
    TPEnabled = true,
    StretchEnabled = true,
    StretchFactor = 0.5,
    FlyEnabled = false,
    FlySpeed = 50,
    Noclip = false,
    DarkTexturesEnabled = false,
    WeaponSkin = "Aucun"
}

-- --- SYSTÈME DE SAUVEGARDE JSON ---
local ConfigFile = "SoloCheat_Config.json"

local function SaveConfig()
    if writefile then
        local json = HttpService:JSONEncode(getgenv().Config)
        writefile(ConfigFile, json)
    end
end

local function LoadConfig()
    if readfile and pcall(function() readfile(ConfigFile) end) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFile))
        end)
        if success and data then
            for key, value in pairs(data) do
                getgenv().Config[key] = value
            end
            return true
        end
    end
    return false
end

-- Charger la config sauvegardée avant de lancer le menu
LoadConfig()

-- --- MODULE : PLATFORM SPOOFER ---
local oldPlatform
oldPlatform = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and self == UIS and key == "GetPlatform" then
        if getgenv().Config.Platform == "Mobile" then
            return Enum.Platform.IOS
        elseif getgenv().Config.Platform == "Console" then
            return Enum.Platform.XBoxOne
        elseif getgenv().Config.Platform == "PlayStation" then
            return Enum.Platform.PS4
        end
    end
    return oldPlatform(self, key)
end)

-- --- INITIALISATION DE l'INTERFACE ---
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SoloCheat Ultimate",
   LoadingTitle = "SoloCheat",
   LoadingSubtitle = "Spoofer & JSON Edition - JOIN DISCORD !",
   ConfigurationSaving = { Enabled = true, FolderName = "SoloCheat", FileName = "Main" }
})

-- --- CERCLE FOV ---
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Transparency = 0.7
FOVCircle.Visible = false

-- --- FONCTIONS VISUELLES (Skins & Textures) ---
local function ApplyWeaponSkin(tool)
    if not tool or getgenv().Config.WeaponSkin == "Aucun" then return end
    
    local mat = Enum.Material.Plastic
    local col = Color3.fromRGB(255, 255, 255)
    
    if getgenv().Config.WeaponSkin == "Néon Cyan" then
        mat = Enum.Material.Neon
        col = Color3.fromRGB(0, 255, 255)
    elseif getgenv().Config.WeaponSkin == "Or Pur" then
        mat = Enum.Material.Foil
        col = Color3.fromRGB(255, 215, 0)
    elseif getgenv().Config.WeaponSkin == "Rubis Néon" then
        mat = Enum.Material.Neon
        col = Color3.fromRGB(255, 0, 50)
    end

    for _, part in pairs(tool:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = mat
            part.Color = col
        end
    end
end

local function ApplyDarkTextures(char)
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.Plastic
            part.Color = Color3.fromRGB(20, 20, 20)
        end
    end
end

local function PlayKillSound()
    local KillSounds = {
        "rbxassetid://160432331", -- Ding
        "rbxassetid://142700651", -- Another ding
        "rbxassetid://131961136", -- Gunshot
        "rbxassetid://146830992", -- Explosion
        "rbxassetid://138210320"  -- Bell
    }
    local s = Instance.new("Sound", SoundService)
    s.SoundId = KillSounds[math.random(1, #KillSounds)]
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
                    if dist < shortest then 
                        shortest = dist 
                        target = head 
                    end
                end
            end
        end
    end
    return target
end

-- --- ONGLETS ---
local TabCombat = Window:CreateTab("Combat & Rage", 4483362458)
local TabVisuals = Window:CreateTab("Visuels", 4483362458)
local TabMove = Window:CreateTab("Mouvement", 4483362458)
local TabConfig = Window:CreateTab("Config & Spoofer", 4483362458)

-- --- [TAB COMBAT] ---
TabCombat:CreateToggle({Name = "RAGEBOT (TP Cible)", CurrentValue = getgenv().Config.Ragebot, Callback = function(v) getgenv().Config.Ragebot = v end})
TabCombat:CreateToggle({Name = "Aimbot (Droit)", CurrentValue = getgenv().Config.AimbotEnabled, Callback = function(v) getgenv().Config.AimbotEnabled = v end})
TabCombat:CreateSlider({Name = "Puissance Aimbot", Range = {0.1, 1}, Increment = 0.05, CurrentValue = getgenv().Config.AimbotStrength, Callback = function(v) getgenv().Config.AimbotStrength = v end})
TabCombat:CreateToggle({Name = "Silent Aim", CurrentValue = getgenv().Config.SilentAimEnabled, Callback = function(v) getgenv().Config.SilentAimEnabled = v end})
TabCombat:CreateToggle({Name = "Triggerbot", CurrentValue = getgenv().Config.TriggerbotEnabled, Callback = function(v) getgenv().Config.TriggerbotEnabled = v end})
TabCombat:CreateToggle({Name = "Kill Sound (Ding)", CurrentValue = getgenv().Config.KillSound, Callback = function(v) getgenv().Config.KillSound = v end})
TabCombat:CreateSlider({Name = "Taille FOV", Range = {50, 600}, Increment = 10, CurrentValue = getgenv().Config.AimFOV, Callback = function(v) getgenv().Config.AimFOV = v end})
TabCombat:CreateToggle({Name = "Afficher FOV", CurrentValue = false, Callback = function(v) FOVCircle.Visible = v end})

-- --- [TAB VISUELS] ---
TabVisuals:CreateToggle({Name = "ESP Highlight (Stable)", CurrentValue = getgenv().Config.ESPEnabled, Callback = function(v) getgenv().Config.ESPEnabled = v end})
TabVisuals:CreateToggle({Name = "Stretch Resolution", CurrentValue = getgenv().Config.StretchEnabled, Callback = function(v) getgenv().Config.StretchEnabled = v end})
TabVisuals:CreateSlider({Name = "Intensité Stretch", Range = {0.1, 1}, Increment = 0.05, CurrentValue = getgenv().Config.StretchFactor, Callback = function(v) getgenv().Config.StretchFactor = v end})

TabVisuals:CreateDropdown({
    Name = "Skin d'Arme",
    Options = {"Aucun", "Néon Cyan", "Or Pur", "Rubis Néon"},
    CurrentOption = {getgenv().Config.WeaponSkin},
    MultipleOptions = false,
    Callback = function(Option)
        getgenv().Config.WeaponSkin = Option[1]
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then ApplyWeaponSkin(tool) end
    end
})

TabVisuals:CreateToggle({Name = "Dark Textures on Rivals", CurrentValue = getgenv().Config.DarkTexturesEnabled, Callback = function(v) 
    getgenv().Config.DarkTexturesEnabled = v
    if v then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                ApplyDarkTextures(p.Character)
            end
        end
    end
end})

-- --- [TAB MOUVEMENT] ---
TabMove:CreateSlider({Name = "Vitesse", Range = {16, 200}, Increment = 1, CurrentValue = getgenv().Config.WalkSpeed, Callback = function(v) getgenv().Config.WalkSpeed = v end})
TabMove:CreateToggle({Name = "Saut Infini", CurrentValue = getgenv().Config.InfiniteJump, Callback = function(v) getgenv().Config.InfiniteJump = v end})
TabMove:CreateToggle({Name = "Noclip", CurrentValue = getgenv().Config.Noclip, Callback = function(v) getgenv().Config.Noclip = v end})
TabMove:CreateToggle({Name = "Fly (Voler)", CurrentValue = getgenv().Config.FlyEnabled, Callback = function(v) getgenv().Config.FlyEnabled = v end})

-- --- [TAB CONFIG & SPOOFER] ---
TabConfig:CreateSection("Platform Spoofer")
TabConfig:CreateDropdown({
   Name = "Simuler Plateforme",
   Options = {"PC", "Mobile", "Console", "PlayStation"},
   CurrentOption = {getgenv().Config.Platform},
   MultipleOptions = false,
   Callback = function(Option)
      getgenv().Config.Platform = Option[1]
      Rayfield:Notify({Title = "Spoofer", Content = "Plateforme changée en : " .. Option[1]})
   end,
})

TabConfig:CreateSection("Système JSON")
TabConfig:CreateButton({Name = "Sauvegarder Config", Callback = function()
    SaveConfig()
    Rayfield:Notify({Title = "SoloCheat", Content = "Configuration sauvegardée sur le disque !"})
end})
TabConfig:CreateButton({Name = "Charger Config", Callback = function()
    if LoadConfig() then
        Rayfield:Notify({Title = "SoloCheat", Content = "Configuration chargée avec succès !"})
    else
        Rayfield:Notify({Title = "SoloCheat", Content = "Aucune configuration trouvée."})
    end
end})

-- --- BOUCLE PRINCIPALE ---
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Radius = getgenv().Config.AimFOV
    local char = LocalPlayer.Character
    if not char then return end

    -- Mouvement & Physique
    if char:FindFirstChildOfClass("Humanoid") then char:FindFirstChildOfClass("Humanoid").WalkSpeed = getgenv().Config.WalkSpeed end
    if getgenv().Config.StretchEnabled then Camera.CFrame = Camera.CFrame * CFrame.new(0,0,0, 1,0,0, 0, getgenv().Config.StretchFactor, 0, 0,0,1) end
    if getgenv().Config.Noclip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end

    -- Fly ZQSD / WASD
    if getgenv().Config.FlyEnabled and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local dir = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.Z) then dir = dir + Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.Q) then dir = dir - Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        hrp.Velocity = dir * getgenv().Config.FlySpeed
        hrp.Anchored = (dir == Vector3.new(0,0,0))
    elseif char:FindFirstChild("HumanoidRootPart") then 
        char.HumanoidRootPart.Anchored = false 
    end

    -- ESP Highlight
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = p.Character:FindFirstChild("SoloCheatESP")
            if getgenv().Config.ESPEnabled then
                if not hl then
                    hl = Instance.new("Highlight", p.Character)
                    hl.Name = "SoloCheatESP"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                end
                hl.Enabled = (p.Character:FindFirstChildOfClass("Humanoid").Health > 0)
            elseif hl then hl:Destroy() end
        end
    end

    -- Aimbot & Combat
    if getgenv().Config.AimbotEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetClosest()
        if t then
            local tPos = Camera:WorldToViewportPoint(t.Position)
            local mouseLoc = UIS:GetMouseLocation()
            mousemoverel((tPos.X - mouseLoc.X) * getgenv().Config.AimbotStrength, (tPos.Y - mouseLoc.Y) * getgenv().Config.AimbotStrength)
        end
    end

    if getgenv().Config.TriggerbotEnabled and Mouse.Target then
        local p = Players:GetPlayerFromCharacter(Mouse.Target.Parent)
        if p and p ~= LocalPlayer then mouse1click() end
    end
end)

-- Ragebot (Loop séparée pour la vitesse)
task.spawn(function()
    while task.wait(0.01) do
        if getgenv().Config.Ragebot and LocalPlayer.Character then
            local t = GetClosest()
            if t then
                LocalPlayer.Character.HumanoidRootPart.CFrame = t.CFrame * CFrame.new(0, 0, 3)
                mouse1click()
            end
        end
    end
end)

-- Saut & TP
UIS.InputBegan:Connect(function(i, p)
    if p then return end
    if i.KeyCode == Enum.KeyCode.Space and getgenv().Config.InfiniteJump then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(3)
    elseif i.KeyCode == Enum.KeyCode.E and getgenv().Config.TPEnabled then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0, 3, 0))
    end
end)

-- Événements et Gestion des Nouveaux Joueurs / Outils
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        c:WaitForChild("Humanoid").Died:Connect(function()
            if getgenv().Config.KillSound then PlayKillSound() end
        end)
        if getgenv().Config.DarkTexturesEnabled then
            ApplyDarkTextures(c)
        end
    end)
end)

local function HookTool(tool)
    if not tool or not tool:IsA("Tool") then return end
    ApplyWeaponSkin(tool)
    tool.Equipped:Connect(function()
        ApplyWeaponSkin(tool)
    end)
end

LocalPlayer.CharacterAdded:Connect(function(c)
    local tool = c:FindFirstChildOfClass("Tool")
    if tool then ApplyWeaponSkin(tool) end
    c.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then HookTool(child) end
    end)
end)

if LocalPlayer.Character then
    local currentTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if currentTool then ApplyWeaponSkin(currentTool) end
end

for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
    HookTool(tool)
end
LocalPlayer.Backpack.ChildAdded:Connect(HookTool)

-- --- AUTO-SAVE SYSTEM ---
task.spawn(function()
    while task.wait(30) do
        SaveConfig()
    end
end)

Rayfield:Notify({Title = "SoloCheat Ultimate", Content = "Spoofer actif. Menu injecté et corrigé avec succès."})

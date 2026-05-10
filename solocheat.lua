-- --- NETTOYAGE DES INSTANCES PRÉCÉDENTES ---
for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
    if gui.Name == "Rayfield" then
        gui:Destroy()
    end
end

-- --- SYSTÈME DE SAUVEGARDE JSON ---
local ConfigFile = "SoloCheat_Config.json"

local function SaveConfig()
    local json = game:GetService("HttpService"):JSONEncode(getgenv().Config)
    if writefile then
        writefile(ConfigFile, json)
    end
end

local function LoadConfig()
    if readfile and readfile(ConfigFile) then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(ConfigFile))
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

local success, err = pcall(function()

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SoloCheat",
   LoadingTitle = "SoloCheat",
   LoadingSubtitle = "JOIN DISCORD !",
   ConfigurationSaving = { Enabled = true }
})

-- --- CONFIGURATION GLOBALE ---
getgenv().Config = {
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
}

-- Charger la config sauvegardée
LoadConfig()

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- --- CERCLE FOV ---
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness, FOVCircle.Color, FOVCircle.Transparency, FOVCircle.Visible = 1, Color3.fromRGB(255, 0, 0), 0.7, false

-- --- ONGLETS ---
local TabCombat = Window:CreateTab("Combat & Rage", 4483362458)
local TabVisuals = Window:CreateTab("Visuels", 4483362458)
local TabMove = Window:CreateTab("Mouvement", 4483362458)

-- --- [TAB COMBAT] ---
TabCombat:CreateToggle({Name = "RAGEBOT (TP Cible)", CurrentValue = false, Callback = function(v) getgenv().Config.Ragebot = v end})
TabCombat:CreateToggle({Name = "Aimbot (Droit)", CurrentValue = false, Callback = function(v) getgenv().Config.AimbotEnabled = v end})
TabCombat:CreateSlider({Name = "Puissance Aimbot", Range = {0.1, 1}, Increment = 0.05, CurrentValue = 0.5, Callback = function(v) getgenv().Config.AimbotStrength = v end})
TabCombat:CreateToggle({Name = "Silent Aim", CurrentValue = false, Callback = function(v) getgenv().Config.SilentAimEnabled = v end})
TabCombat:CreateToggle({Name = "Triggerbot", CurrentValue = false, Callback = function(v) getgenv().Config.TriggerbotEnabled = v end})
TabCombat:CreateToggle({Name = "Kill Sound (Ding)", CurrentValue = false, Callback = function(v) getgenv().Config.KillSound = v end})
TabCombat:CreateSlider({Name = "Taille FOV", Range = {50, 600}, Increment = 10, CurrentValue = 150, Callback = function(v) getgenv().Config.AimFOV = v end})
TabCombat:CreateToggle({Name = "Afficher FOV", CurrentValue = false, Callback = function(v) FOVCircle.Visible = v end})

-- --- [TAB VISUELS] ---
TabVisuals:CreateToggle({Name = "ESP Highlight (Stable)", CurrentValue = false, Callback = function(v) getgenv().Config.ESPEnabled = v end})
TabVisuals:CreateToggle({Name = "Stretch Resolution", CurrentValue = false, Callback = function(v) getgenv().Config.StretchEnabled = v end})
    getgenv().Config.WeaponSkin = option
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then ApplyWeaponSkin(tool) end
end})
TabVisuals:CreateToggle({Name = "Dark Textures on Rivals", CurrentValue = false, Callback = function(v) 
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
TabMove:CreateSlider({Name = "Vitesse", Range = {16, 200}, Increment = 1, CurrentValue = 16, Callback = function(v) getgenv().Config.WalkSpeed = v end})
TabMove:CreateToggle({Name = "Saut Infini", CurrentValue = false, Callback = function(v) getgenv().Config.InfiniteJump = v end})
TabMove:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) getgenv().Config.Noclip = v end})
TabMove:CreateToggle({Name = "Fly (Voler)", CurrentValue = false, Flag = "FlyT", Callback = function(v) getgenv().Config.FlyEnabled = v end})

-- --- [TAB CONFIG] ---
local TabConfig = Window:CreateTab("Config", 4483362458)
TabConfig:CreateButton({Name = "Sauvegarder Config", Callback = function()
    SaveConfig()
    Rayfield:Notify({Title = "SoloCheat", Content = "Configuration sauvegardée!"})
end})
TabConfig:CreateButton({Name = "Charger Config", Callback = function()
    LoadConfig()
    Rayfield:Notify({Title = "SoloCheat", Content = "Configuration chargée!"})
end})

-- --- FONCTIONS ---
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
                    if dist < shortest then shortest, target = dist, head end
                end
            end
        end
    end
    return target
end

local function PlayKillSound()
    local KillSounds = {
        "rbxassetid://160432331", -- Ding
        "rbxassetid://142700651", -- Another ding
        "rbxassetid://131961136", -- Gunshot
        "rbxassetid://146830992", -- Explosion
        "rbxassetid://138210320"  -- Bell
    }
    local s = Instance.new("Sound", game:GetService("SoundService"))
    s.SoundId = KillSounds[math.random(1, #KillSounds)]
    s.Volume = 5
    s:Play()
    game:GetService("Debris"):AddItem(s, 2)
end

local function ApplyDarkTextures(char)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.Plastic
            part.Color = Color3.fromRGB(20, 20, 20)
        end
    end
end

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

    -- Fly
    if getgenv().Config.FlyEnabled and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local dir = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        hrp.Velocity = dir * getgenv().Config.FlySpeed
        hrp.Anchored = (dir == Vector3.new(0,0,0))
    elseif char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.Anchored = false end

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

-- Kill Sound Detection
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

-- Apply dark textures to existing players
for _, p in pairs(Players:GetPlayers()) do
    if p.Character and getgenv().Config.DarkTexturesEnabled then
        ApplyDarkTextures(p.Character)
    end
end

-- Weapon Skin Application
LocalPlayer.CharacterAdded:Connect(function(c)
    local tool = c:FindFirstChildOfClass("Tool")
    if tool then ApplyWeaponSkin(tool) end
    c.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then ApplyWeaponSkin(child) end
    end)
end)

local function HookTool(tool)
    if not tool or not tool:IsA("Tool") then return end
    ApplyWeaponSkin(tool)
    tool.Equipped:Connect(function()
        ApplyWeaponSkin(tool)
    end)
end

-- Apply to current tool
local currentTool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
if currentTool then ApplyWeaponSkin(currentTool) end
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

Rayfield:Notify({Title = "SoloCheat V12", Content = "Instances précédentes nettoyées. Menu prêt."})

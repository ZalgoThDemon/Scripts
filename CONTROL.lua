local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- 1. SISTEMA FULLBRIGHT DIRECTO
pcall(function()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    for _, e in ipairs(Lighting:GetChildren()) do
        if e:IsA("Atmosphere") or e:IsA("PostEffect") then
            e.Enabled = false
        end
    end
end)

-- 2. FUNCIÓN DE ESP CON ESTADO DE CELDAS
local function updateESP(model, isPlayer, isLockedInCell)
    if not model or not model:IsA("Model") then return end
    
    local color = isPlayer and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(255, 30, 30)
    local textColor = isPlayer and Color3.fromRGB(150, 220, 255) or Color3.fromRGB(255, 100, 100)

    local highlight = model:FindFirstChild("SafeESP_HL")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "SafeESP_HL"
        highlight.Adornee = model
        highlight.FillTransparency = 1
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = model
    end
    highlight.OutlineColor = color

    local head = model:FindFirstChild("Head") or model.PrimaryPart
    if head then
        local billboard = head:FindFirstChild("SafeESP_BB")
        if not billboard then
            billboard = Instance.new("BillboardGui")
            billboard.Name = "SafeESP_BB"
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 200, 0, 40)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = head

            local textLabel = Instance.new("TextLabel")
            textLabel.Name = "Text"
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextStrokeTransparency = 0
            textLabel.TextSize = 14
            textLabel.Font = Enum.Font.GothamBold
            textLabel.Parent = billboard
        end
        
        local textLabel = billboard:FindFirstChild("Text")
        if textLabel then
            local displayName = model.Name
            if displayName == "" or displayName == "Model" then
                displayName = isPlayer and "Jugador" or "Entidad Hostil"
            end

            if not isPlayer and isLockedInCell then
                textLabel.Text = displayName .. " (Encerrado)"
            else
                textLabel.Text = displayName
            end
            
            textLabel.TextColor3 = textColor
        end
    end
end

local function removeESP(model)
    if not model then return end
    local hl = model:FindFirstChild("SafeESP_HL")
    if hl then hl:Destroy() end
    local head = model:FindFirstChild("Head") or model.PrimaryPart
    if head then
        local bb = head:FindFirstChild("SafeESP_BB")
        if bb then bb:Destroy() end
    end
end

-- 3. REGISTRO CACHEADO DE ENTIDADES (Evita lag de búsqueda masiva)
local trackedEntities = {}

local function registerEntity(model)
    if not model:IsA("Model") then return end
    if Players:GetPlayerFromCharacter(model) then return end
    
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local rootPart = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
    
    if humanoid and rootPart and not trackedEntities[model] then
        trackedEntities[model] = {Humanoid = humanoid, RootPart = rootPart}
    end
end

-- Escanear mapa una única vez al iniciar
for _, obj in ipairs(Workspace:GetDescendants()) do
    registerEntity(obj)
end

-- Escuchar entidades nuevas que aparezcan
Workspace.DescendantAdded:Connect(function(obj)
    task.spawn(function()
        task.wait(0.2)
        registerEntity(obj)
    end)
end)

-- 4. BUCLE PRINCIPAL ULTRAOPTIMIZADO
RunService.Heartbeat:Connect(function()
    -- A. Actualizar jugadores
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            updateESP(player.Character, true, false)
        end
    end

    -- B. Iterar únicamente sobre la lista cacheada de entidades guardadas
    for model, data in pairs(trackedEntities) do
        if not model.Parent or not data.Humanoid or data.Humanoid.Health <= 0 then
            removeESP(model)
            trackedEntities[model] = nil
        else
            local pos = data.RootPart.Position
            
            local enCeldaX = (pos.X >= 241.0 and pos.X <= 280.0)
            
            local celda1 = (enCeldaX and pos.Z >= -123.0 and pos.Z <= -100.0)
            local celda2 = (enCeldaX and pos.Z >= -65.2  and pos.Z <= -42.2)
            local celda3 = (enCeldaX and pos.Z >= 72.9   and pos.Z <= 95.9)
            local celda4 = (enCeldaX and pos.Z >= 114.4  and pos.Z <= 137.4)
            
            local enCeldaZ = celda1 or celda2 or celda3 or celda4
            
            updateESP(model, false, (enCeldaX and enCeldaZ))
        end
    end
end)
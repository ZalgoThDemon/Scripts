local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Estados principales (empieza apagado)
local scriptEnabled = false

-- Interfaz gráfica principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ControlScriptMenu"
screenGui.ResetOnSpawn = false

pcall(function()
    screenGui.Parent = CoreGui
end)
if not screenGui.Parent then
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Ventana flotante del menú
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 160, 0, 90)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
mainFrame.BorderSizePixel = 1
mainFrame.Parent = screenGui

-- Título de la ventana
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -30, 0, 25)
titleLabel.Position = UDim2.new(0, 10, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Panel Control"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 12
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

-- Botón de cerrar (destruye el menú por completo sin dejar logos)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -25, 0, 7)
closeButton.BackgroundTransparency = 1
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(150, 150, 150)
closeButton.TextSize = 12
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

-- Botón interno para activar/desactivar el ESP (refleja el estado inicial apagado)
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -20, 0, 35)
toggleButton.Position = UDim2.new(0, 10, 0, 38)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.BorderColor3 = Color3.fromRGB(255, 50, 50)
toggleButton.BorderSizePixel = 2
toggleButton.Text = "ESP: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 50, 50)
toggleButton.TextSize = 13
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = mainFrame

-- Sistema para arrastrar la ventana desde cualquier parte del panel
local dragging, dragInput, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Funciones para limpiar por completo todos los ESPs (Jugadores, Entidades y Objetos)
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

local function removeItemESP(obj)
    if not obj then return end
    local hl = obj:FindFirstChild("ItemESP_HL")
    if hl then hl:Destroy() end
    local part = nil
    if obj:IsA("Model") then
        part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    elseif obj:IsA("BasePart") then
        part = obj
    end
    if part then
        local bb = part:FindFirstChild("ItemESP_BB")
        if bb then bb:Destroy() end
    end
end

local function clearAllVisuals()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            removeESP(player.Character)
        end
    end

    for model, _ in pairs(trackedEntities or {}) do
        if model then
            removeESP(model)
        end
    end

    for obj, _ in pairs(trackedItems or {}) do
        if obj then
            removeItemESP(obj)
        end
    end
end

-- Control de eventos de la interfaz
toggleButton.MouseButton1Click:Connect(function()
    scriptEnabled = not scriptEnabled
    if scriptEnabled then
        toggleButton.Text = "ESP: ON"
        toggleButton.TextColor3 = Color3.fromRGB(0, 255, 120)
        toggleButton.BorderColor3 = Color3.fromRGB(0, 255, 120)
    else
        toggleButton.Text = "ESP: OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 50, 50)
        toggleButton.BorderColor3 = Color3.fromRGB(255, 50, 50)
        clearAllVisuals()
    end
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

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

-- 2. FUNCIÓN DE ESP PARA JUGADORES Y ENTIDADES
local function updateESP(model, isPlayer, isLockedInCell, health, maxHealth)
    if not scriptEnabled then return end
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
            billboard.Size = UDim2.new(0, 120, 0, 20)
            billboard.StudsOffset = Vector3.new(0, 2.0, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = head

            local textLabel = Instance.new("TextLabel")
            textLabel.Name = "Text"
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextStrokeTransparency = 0
            textLabel.TextSize = 8
            textLabel.Font = Enum.Font.GothamBold
            textLabel.Parent = billboard
        end
        
        local textLabel = billboard:FindFirstChild("Text")
        if textLabel then
            local displayName = model.Name
            if displayName == "" or displayName == "Model" then
                displayName = isPlayer and "Jugador" or "Entidad Hostil"
            end

            if isPlayer then
                if health and maxHealth then
                    textLabel.Text = displayName .. " | " .. math.floor(health) .. "/" .. math.floor(maxHealth)
                else
                    textLabel.Text = displayName .. " | 100/100"
                end
            else
                if isLockedInCell then
                    textLabel.Text = displayName .. " (Encerrado)"
                else
                    textLabel.Text = displayName
                end
            end
            
            textLabel.TextColor3 = textColor
        end
    end
end

-- 3. FUNCIÓN DE ESP PARA OBJETOS
local function updateItemESP(obj, labelText, color)
    if not scriptEnabled then return end
    if not obj then return end
    
    local highlight = obj:FindFirstChild("ItemESP_HL")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "ItemESP_HL"
        highlight.Adornee = obj
        highlight.FillTransparency = 0.4
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = obj
    end
    highlight.FillColor = color
    highlight.OutlineColor = color

    local targetPart = nil
    if obj:IsA("Model") then
        targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    elseif obj:IsA("BasePart") then
        targetPart = obj
    end

    if targetPart then
        local billboard = targetPart:FindFirstChild("ItemESP_BB")
        if not billboard then
            billboard = Instance.new("BillboardGui")
            billboard.Name = "ItemESP_BB"
            billboard.Adornee = targetPart
            billboard.Size = UDim2.new(0, 120, 0, 20)
            billboard.StudsOffset = Vector3.new(0, 1.2, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = targetPart

            local textLabel = Instance.new("TextLabel")
            textLabel.Name = "Text"
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextStrokeTransparency = 0
            textLabel.TextSize = 8
            textLabel.Font = Enum.Font.GothamBold
            textLabel.Parent = billboard
        end
        
        local textLabel = billboard:FindFirstChild("Text")
        if textLabel then
            textLabel.Text = labelText
            textLabel.TextColor3 = color
        end
    end
end

-- 4. REGISTRO CACHEADO Y FILTRADO EXACTO
trackedEntities = {}
trackedItems = {}

local function registerEntity(model)
    if not model:IsA("Model") then return end
    if Players:GetPlayerFromCharacter(model) then return end
    
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local rootPart = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
    
    if humanoid and rootPart and not trackedEntities[model] then
        trackedEntities[model] = {Humanoid = humanoid, RootPart = rootPart}
    end
end

local function checkAndRegisterItem(obj)
    if obj:IsA("Model") or obj:IsA("BasePart") then
        local nameLower = obj.Name:lower()
        if nameLower:find("venda") or nameLower:find("bandage") or 
           nameLower:find("dinero") or nameLower:find("money") or nameLower:find("cash") or 
           nameLower:find("coin") or nameLower:find("billete") or nameLower:find("gold") or 
           nameLower:find("mission") or nameLower:find("mision") or nameLower:find("quest") or 
           nameLower:find("objetivo") or nameLower:find("task") or nameLower:find("drop") or 
           nameLower:find("loot") or nameLower:find("fuse") or nameLower:find("panel") or
           nameLower:find("activeitem") then
            trackedItems[obj] = true
        end
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do
    registerEntity(obj)
    checkAndRegisterItem(obj)
end

Workspace.DescendantAdded:Connect(function(obj)
    task.spawn(function()
        task.wait(0.2)
        registerEntity(obj)
        checkAndRegisterItem(obj)
    end)
end)

Workspace.DescendantRemoving:Connect(function(obj)
    if trackedItems[obj] then
        removeItemESP(obj)
        trackedItems[obj] = nil
    end
end)

-- 5. BUCLE PRINCIPAL CON DETECCIÓN REAL DE FALLOS
RunService.Heartbeat:Connect(function()
    if not scriptEnabled then return end

    Lighting.Brightness = 2
    Lighting.GlobalShadows = false

    -- A. Actualizar jugadores
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                updateESP(player.Character, true, false, humanoid.Health, humanoid.MaxHealth)
            else
                updateESP(player.Character, true, false, 100, 100)
            end
        end
    end

    -- B. Actualizar entidades hostiles
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

    -- C. Actualizar Objetos y Misiones
    for obj, _ in pairs(trackedItems) do
        if not obj.Parent then
            removeItemESP(obj)
            trackedItems[obj] = nil
        else
            local nameLower = obj.Name:lower()
            local shouldMark = false
            local color = Color3.fromRGB(255, 255, 0)
            local labelText = ""

            if nameLower:find("venda") or nameLower:find("bandage") then
                color = Color3.fromRGB(0, 255, 120)
                labelText = "[Venda]"
                shouldMark = true
            elseif nameLower:find("dinero") or nameLower:find("money") or nameLower:find("cash") or nameLower:find("coin") or nameLower:find("billete") or nameLower:find("gold") then
                color = Color3.fromRGB(0, 255, 0)
                labelText = "[Dinero]"
                shouldMark = true
            elseif nameLower:find("mission") or nameLower:find("mision") or nameLower:find("quest") or nameLower:find("objetivo") or nameLower:find("task") then
                color = Color3.fromRGB(255, 0, 255)
                labelText = "[Misión]"
                shouldMark = true
            elseif nameLower:find("activeitem") or nameLower:find("fuse") or nameLower:find("panel") then
                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true) or (obj:IsA("ProximityPrompt") and obj)
                local hasSpark = false
                for _, d in ipairs(obj:GetDescendants()) do
                    if (d:IsA("ParticleEmitter") or d:IsA("Fire") or d:IsA("Smoke")) and d.Enabled then
                        hasSpark = true
                        break
                    end
                end

                if (prompt and prompt.Enabled) or hasSpark then
                    color = Color3.fromRGB(255, 140, 0)
                    labelText = "[Arreglar]"
                    shouldMark = true
                else
                    shouldMark = false
                end
            end

            if shouldMark then
                updateItemESP(obj, labelText, color)
            else
                removeItemESP(obj)
            end
        end
    end
end)

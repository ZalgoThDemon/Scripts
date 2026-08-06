local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Estados principales (empieza apagado)
local scriptEnabled = false

-- Interfaz gráfica principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RTXControlMenu"
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
mainFrame.Position = UDim2.new(0, 50, 0, 150)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
mainFrame.BorderSizePixel = 1
mainFrame.Parent = screenGui

-- Título de la ventana
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -30, 0, 25)
titleLabel.Position = UDim2.new(0, 10, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Panel RTX"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 12
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

-- Botón de cerrar (destruye el menú y desactiva el efecto)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -25, 0, 7)
closeButton.BackgroundTransparency = 1
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(150, 150, 150)
closeButton.TextSize = 12
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

-- Botón interno para activar/desactivar el RTX
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -20, 0, 35)
toggleButton.Position = UDim2.new(0, 10, 0, 38)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.BorderColor3 = Color3.fromRGB(255, 50, 50)
toggleButton.BorderSizePixel = 2
toggleButton.Text = "RTX: OFF"
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

-- Guardar valores originales de iluminación para poder restaurarlos al apagar
local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    GeographicLatitude = Lighting.GeographicLatitude,
    ExposureCompensation = Lighting.ExposureCompensation,
    GlobalShadows = Lighting.GlobalShadows,
    ShadowSoftness = Lighting.ShadowSoftness,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Ambient = Lighting.Ambient,
    ColorShift_Top = Lighting.ColorShift_Top,
    ColorShift_Bottom = Lighting.ColorShift_Bottom
}

local function resetLighting()
    Lighting.Brightness = originalLighting.Brightness
    Lighting.ClockTime = originalLighting.ClockTime
    Lighting.GeographicLatitude = originalLighting.GeographicLatitude
    Lighting.ExposureCompensation = originalLighting.ExposureCompensation
    Lighting.GlobalShadows = originalLighting.GlobalShadows
    Lighting.ShadowSoftness = originalLighting.ShadowSoftness
    Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    Lighting.Ambient = originalLighting.Ambient
    Lighting.ColorShift_Top = originalLighting.ColorShift_Top
    Lighting.ColorShift_Bottom = originalLighting.ColorShift_Bottom

    local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    if cc then cc:Destroy() end
    local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
    if bloom then bloom:Destroy() end
end

-- Control de eventos de la interfaz
toggleButton.MouseButton1Click:Connect(function()
    scriptEnabled = not scriptEnabled
    if scriptEnabled then
        toggleButton.Text = "RTX: ON"
        toggleButton.TextColor3 = Color3.fromRGB(0, 255, 120)
        toggleButton.BorderColor3 = Color3.fromRGB(0, 255, 120)
    else
        toggleButton.Text = "RTX: OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 50, 50)
        toggleButton.BorderColor3 = Color3.fromRGB(255, 50, 50)
        resetLighting()
    end
end)

closeButton.MouseButton1Click:Connect(function()
    scriptEnabled = false
    resetLighting()
    screenGui:Destroy()
end)

-- Bucle principal de RTX
RunService.Heartbeat:Connect(function()
    if not scriptEnabled then return end

    -- 1. Iluminación base estilo Shaders RTX
    Lighting.Brightness = 1.8
    Lighting.ClockTime = 23.5
    Lighting.GeographicLatitude = 0
    Lighting.ExposureCompensation = -0.1
    Lighting.GlobalShadows = true
    Lighting.ShadowSoftness = 0.1

    Lighting.OutdoorAmbient = Color3.fromRGB(35, 30, 45)
    Lighting.Ambient = Color3.fromRGB(20, 18, 25)
    Lighting.ColorShift_Top = Color3.fromRGB(255, 220, 180)
    Lighting.ColorShift_Bottom = Color3.fromRGB(15, 15, 20)

    -- 2. Limpiar desenfoques molestos
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("DepthOfFieldEffect") or effect:IsA("BlurEffect") then
            effect:Destroy()
        end
    end

    -- 3. Configurar efectos de post-procesamiento nítidos
    local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    if not cc then
        cc = Instance.new("ColorCorrectionEffect")
        cc.Parent = Lighting
    end
    cc.Brightness = -0.05
    cc.Contrast = 0.35
    cc.Saturation = 0.15
    cc.TintColor = Color3.fromRGB(255, 240, 220)

    local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
    if not bloom then
        bloom = Instance.new("BloomEffect")
        bloom.Parent = Lighting
    end
    bloom.Intensity = 0.5
    bloom.Size = 16
    bloom.Threshold = 0.8
end)

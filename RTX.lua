local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Estados principales (empiezan apagados)
local rtxExteriorEnabled = false
local rtxInteriorEnabled = false

-- Interfaz gráfica principal unificada
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RTXDualControlMenu"
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
mainFrame.Size = UDim2.new(0, 160, 0, 130)
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
titleLabel.Text = "Panel RTX Dual"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 12
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

-- Botón de cerrar (destruye el menú y restaura la iluminación)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -25, 0, 7)
closeButton.BackgroundTransparency = 1
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(150, 150, 150)
closeButton.TextSize = 12
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

-- Botón para RTX Exterior (Shaders)
local rtxExtButton = Instance.new("TextButton")
rtxExtButton.Size = UDim2.new(1, -20, 0, 32)
rtxExtButton.Position = UDim2.new(0, 10, 0, 35)
rtxExtButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
rtxExtButton.BorderColor3 = Color3.fromRGB(255, 50, 50)
rtxExtButton.BorderSizePixel = 2
rtxExtButton.Text = "RTX Exterior: OFF"
rtxExtButton.TextColor3 = Color3.fromRGB(255, 50, 50)
rtxExtButton.TextSize = 11
rtxExtButton.Font = Enum.Font.GothamBold
rtxExtButton.Parent = mainFrame

-- Botón para RTX Interior
local rtxIntButton = Instance.new("TextButton")
rtxIntButton.Size = UDim2.new(1, -20, 0, 32)
rtxIntButton.Position = UDim2.new(0, 10, 0, 75)
rtxIntButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
rtxIntButton.BorderColor3 = Color3.fromRGB(255, 50, 50)
rtxIntButton.BorderSizePixel = 2
rtxIntButton.Text = "RTX Interior: OFF"
rtxIntButton.TextColor3 = Color3.fromRGB(255, 50, 50)
rtxIntButton.TextSize = 11
rtxIntButton.Font = Enum.Font.GothamBold
rtxIntButton.Parent = mainFrame

-- Sistema para arrastrar la ventana
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

-- Guardar iluminación original
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

-- Eventos de los botones
rtxExtButton.MouseButton1Click:Connect(function()
    rtxExteriorEnabled = not rtxExteriorEnabled
    if rtxExteriorEnabled then
        rtxInteriorEnabled = false -- Apaga el otro modo para que no compitan
        rtxIntButton.Text = "RTX Interior: OFF"
        rtxIntButton.TextColor3 = Color3.fromRGB(255, 50, 50)
        rtxIntButton.BorderColor3 = Color3.fromRGB(255, 50, 50)

        rtxExtButton.Text = "RTX Exterior: ON"
        rtxExtButton.TextColor3 = Color3.fromRGB(0, 255, 120)
        rtxExtButton.BorderColor3 = Color3.fromRGB(0, 255, 120)
    else
        rtxExtButton.Text = "RTX Exterior: OFF"
        rtxExtButton.TextColor3 = Color3.fromRGB(255, 50, 50)
        rtxExtButton.BorderColor3 = Color3.fromRGB(255, 50, 50)
        resetLighting()
    end
end)

rtxIntButton.MouseButton1Click:Connect(function()
    rtxInteriorEnabled = not rtxInteriorEnabled
    if rtxInteriorEnabled then
        rtxExteriorEnabled = false -- Apaga el otro modo para que no compitan
        rtxExtButton.Text = "RTX Exterior: OFF"
        rtxExtButton.TextColor3 = Color3.fromRGB(255, 50, 50)
        rtxExtButton.BorderColor3 = Color3.fromRGB(255, 50, 50)

        rtxIntButton.Text = "RTX Interior: ON"
        rtxIntButton.TextColor3 = Color3.fromRGB(0, 255, 120)
        rtxIntButton.BorderColor3 = Color3.fromRGB(0, 255, 120)
    else
        rtxIntButton.Text = "RTX Interior: OFF"
        rtxIntButton.TextColor3 = Color3.fromRGB(255, 50, 50)
        rtxIntButton.BorderColor3 = Color3.fromRGB(255, 50, 50)
        resetLighting()
    end
end)

closeButton.MouseButton1Click:Connect(function()
    rtxExteriorEnabled = false
    rtxInteriorEnabled = false
    resetLighting()
    screenGui:Destroy()
end)

-- Bucle principal
RunService.Heartbeat:Connect(function()
    if rtxExteriorEnabled then
        -- Configuración RTX Exterior (Shaders)
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

        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("DepthOfFieldEffect") or effect:IsA("BlurEffect") then
                effect:Destroy()
            end
        end

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

    elseif rtxInteriorEnabled then
        -- Configuración RTX Interior
        Lighting.Brightness = 1.3
        Lighting.ClockTime = 2.0
        Lighting.GeographicLatitude = 45
        Lighting.ExposureCompensation = 0.1
        Lighting.GlobalShadows = true
        Lighting.ShadowSoftness = 0.25

        Lighting.OutdoorAmbient = Color3.fromRGB(15, 15, 20)
        Lighting.Ambient = Color3.fromRGB(35, 28, 22)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 180, 120)
        Lighting.ColorShift_Bottom = Color3.fromRGB(40, 30, 25)

        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("DepthOfFieldEffect") or effect:IsA("BlurEffect") then
                effect:Destroy()
            end
        end

        local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
        if not cc then
            cc = Instance.new("ColorCorrectionEffect")
            cc.Parent = Lighting
        end
        cc.Brightness = -0.02
        cc.Contrast = 0.28
        cc.Saturation = 0.2
        cc.TintColor = Color3.fromRGB(255, 235, 210)

        local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
        if not bloom then
            bloom = Instance.new("BloomEffect")
            bloom.Parent = Lighting
        end
        bloom.Intensity = 0.6
        bloom.Size = 20
        bloom.Threshold = 0.75
    end
end)

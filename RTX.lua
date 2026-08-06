local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- 1. Configuración de propiedades visuales avanzadas (Estilo RTX / Global Illumination)
Lighting.Brightness = 2.5
Lighting.ClockTime = 14.5 -- Sol de tarde para generar buenas sombras y contrastes
Lighting.GeographicLatitude = 45
Lighting.ExposureCompensation = 0.2
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.2 -- Sombras con bordes difuminados más realistas

-- Colores ambientales para simular rebotes de luz indirecta
Lighting.OutdoorAmbient = Color3.fromRGB(120, 130, 150)
Lighting.Ambient = Color3.fromRGB(70, 75, 90)
Lighting.ColorShift_Top = Color3.fromRGB(255, 245, 230)
Lighting.ColorShift_Bottom = Color3.fromRGB(40, 45, 55)

-- 2. Limpiar y eliminar efectos molestos de desenfoque que traen otros scripts
for _, effect in ipairs(Lighting:GetChildren()) do
    if effect:IsA("DepthOfFieldEffect") or effect:IsA("BlurEffect") then
        effect:Destroy()
    end
end

-- 3. Añadir efectos de mejora visual nítida (sin blur)
local function applyPostProcessing()
    -- Atmosphere para darle profundidad volumétrica al aire sin borrar el fondo
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if not atmosphere then
        atmosphere = Instance.new("Atmosphere")
        atmosphere.Parent = Lighting
    end
    atmosphere.Density = 0.25
    atmosphere.Offset = 0.25
    atmosphere.Color = Color3.fromRGB(190, 205, 220)
    atmosphere.Decay = Color3.fromRGB(90, 100, 115)
    atmosphere.Glare = 0.1
    atmosphere.Haze = 1.5

    -- Bloom sutil para los brillos metálicos y luces (sin emborronar la cámara)
    local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
    if not bloom then
        bloom = Instance.new("BloomEffect")
        bloom.Parent = Lighting
    end
    bloom.Intensity = 0.4
    bloom.Size = 24
    bloom.Threshold = 0.9

    -- ColorCorrection para potenciar contrastes y saturación tipo RTX
    local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    if not cc then
        cc = Instance.new("ColorCorrectionEffect")
        cc.Parent = Lighting
    end
    cc.Brightness = 0.02
    cc.Contrast = 0.15
    cc.Saturation = 0.2
    cc.TintColor = Color3.fromRGB(255, 252, 245)
end

applyPostProcessing()

-- 4. Bucle de seguridad para evitar que el juego reincorpore efectos de desenfoque nativos
RunService.Heartbeat:Connect(function()
    Lighting.GlobalShadows = true
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("DepthOfFieldEffect") or effect:IsA("BlurEffect") then
            effect:Destroy()
        end
    end
end)
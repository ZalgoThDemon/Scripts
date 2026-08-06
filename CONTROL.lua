local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- 1. Iluminación base estilo Shaders RTX
Lighting.Brightness = 1.8
Lighting.ClockTime = 23.5 -- Hora nocturna para forzar la oscuridad ambiental y el contraste con las lámparas
Lighting.GeographicLatitude = 0
Lighting.ExposureCompensation = -0.1
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.1 -- Sombras más marcadas y definidas

-- Oscurecer el ambiente exterior para que resalten los puntos de luz cálidos
Lighting.OutdoorAmbient = Color3.fromRGB(35, 30, 45)
Lighting.Ambient = Color3.fromRGB(20, 18, 25)
Lighting.ColorShift_Top = Color3.fromRGB(255, 220, 180)
Lighting.ColorShift_Bottom = Color3.fromRGB(15, 15, 20)

-- 2. Limpiar cualquier desenfoque o blur basura
for _, effect in ipairs(Lighting:GetChildren()) do
    if effect:IsA("DepthOfFieldEffect") or effect:IsA("BlurEffect") then
        effect:Destroy()
    end
end

-- 3. Configurar efectos de post-procesamiento nítidos
local function applyShaders()
    -- ColorCorrection para lograr ese contraste oscuro y tonos cinematográficos
    local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    if not cc then
        cc = Instance.new("ColorCorrectionEffect")
        cc.Parent = Lighting
    end
    cc.Brightness = -0.05
    cc.Contrast = 0.35 -- Alto contraste para las zonas oscuras y de luz
    cc.Saturation = 0.15
    cc.TintColor = Color3.fromRGB(255, 240, 220)

    -- Bloom controlado para el brillo de las lámparas sin difuminar la pantalla
    local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
    if not bloom then
        bloom = Instance.new("BloomEffect")
        bloom.Parent = Lighting
    end
    bloom.Intensity = 0.5
    bloom.Size = 16
    bloom.Threshold = 0.8
end

applyShaders()

-- 4. Mantener la consistencia bloqueando efectos molestos
RunService.Heartbeat:Connect(function()
    Lighting.GlobalShadows = true
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("DepthOfFieldEffect") or effect:IsA("BlurEffect") then
            effect:Destroy()
        end
    end
end)

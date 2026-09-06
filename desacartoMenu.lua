-- LocalScript: Coloque em StarterPlayerScripts ou StarterGui
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

----------------------------------------------------------------
-- CONFIGURAÇÃO DO GITHUB
----------------------------------------------------------------
local GITHUB_KEYS_URL = "https://raw.githubusercontent.com/mszinnnyt-star/KeyUserScripts/refs/heads/main/Codification.txt"

local function fetchKeysFromGithub()
    local keysTable = {}
    local url = GITHUB_KEYS_URL .. "?nocache=" .. tostring(os.time())
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if success and response then
        for line in response:gmatch("[^\r\n]+") do
            local cleanKey = line:gsub("^%s*(.-)%s*$", "%1"):gsub("[%z\1-\31]", "")
            if #cleanKey > 0 then
                keysTable[cleanKey] = true
            end
        end
    else
        warn("Erro ao carregar as keys do GitHub: " .. tostring(response))
    end

    return keysTable
end

-- Salva o horário padrão
local ORIGINAL_TIME = Lighting.ClockTime
local CurrentTime = ORIGINAL_TIME

-- Configurações Gerais
local HighlightEnabled = false
local TextEnabled = false
local AimbotEnabled = false
local Aiming = false

-- Configurações de Aimbot/ESP
local FOV_RADIUS = 200
local MAX_ESP_DISTANCE = 5000
local SMOOTHNESS = 0.2
local TargetPart = "Chest"

-- Cores
local ENEMY_COLOR = Color3.fromRGB(255, 60, 60)
local TEAM_COLOR = Color3.fromRGB(60, 255, 60)

----------------------------------------------------------------
-- GUI Principal
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESPAimbotGui"
ScreenGui.ResetOnSpawn = false

local parentTarget = LocalPlayer:WaitForChild("PlayerGui")
pcall(function() ScreenGui.Parent = parentTarget end)

-- Círculo do FOV NATIVO
local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "FOVCircle"
FOVFrame.BackgroundTransparency = 1
FOVFrame.BorderSizePixel = 0
FOVFrame.Visible = false
FOVFrame.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Thickness = 1.5
FOVStroke.Parent = FOVFrame

-- Janela Principal do Cheat (Oculta até autenticar)
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 460)
Frame.Position = UDim2.new(0.05, 0, 0.15, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Visible = false
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

-- TopBar para arrastar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundTransparency = 1
TopBar.Active = true
TopBar.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "ESP & Aimbot Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = TopBar

local draggingFrame = false
local dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFrame = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingFrame = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingFrame and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

----------------------------------------------------------------
-- JANELA DO SISTEMA DE KEY (Online)
----------------------------------------------------------------
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 260, 0, 160)
KeyFrame.Position = UDim2.new(0.5, -130, 0.5, -80)
KeyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.Parent = ScreenGui

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 8)
KeyCorner.Parent = KeyFrame

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 35)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "Sistema de Key (Online)"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextSize = 16
KeyTitle.Font = Enum.Font.SourceSansBold
KeyTitle.Parent = KeyFrame

local KeyTextBox = Instance.new("TextBox")
KeyTextBox.Size = UDim2.new(0.85, 0, 0, 35)
KeyTextBox.Position = UDim2.new(0.075, 0, 0.28, 0)
KeyTextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
KeyTextBox.Text = ""
KeyTextBox.PlaceholderText = "Digite a sua Key aqui..."
KeyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
KeyTextBox.Font = Enum.Font.SourceSans
KeyTextBox.TextSize = 14
KeyTextBox.Parent = KeyFrame

local KeyTextCorner = Instance.new("UICorner")
KeyTextCorner.CornerRadius = UDim.new(0, 6)
KeyTextCorner.Parent = KeyTextBox

local KeySubmitBtn = Instance.new("TextButton")
KeySubmitBtn.Size = UDim2.new(0.85, 0, 0, 32)
KeySubmitBtn.Position = UDim2.new(0.075, 0, 0.58, 0)
KeySubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
KeySubmitBtn.Text = "Verificar Key"
KeySubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KeySubmitBtn.Font = Enum.Font.SourceSansBold
KeySubmitBtn.TextSize = 14
KeySubmitBtn.Parent = KeyFrame

local KeyBtnCorner = Instance.new("UICorner")
KeyBtnCorner.CornerRadius = UDim.new(0, 6)
KeyBtnCorner.Parent = KeySubmitBtn

local KeyStatus = Instance.new("TextLabel")
KeyStatus.Size = UDim2.new(1, 0, 0, 20)
KeyStatus.Position = UDim2.new(0, 0, 0.82, 0)
KeyStatus.BackgroundTransparency = 1
KeyStatus.Text = ""
KeyStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
KeyStatus.TextSize = 12
KeyStatus.Font = Enum.Font.SourceSans
KeyStatus.Parent = KeyFrame

KeySubmitBtn.MouseButton1Click:Connect(function()
    KeyStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
    KeyStatus.Text = "Consultando servidor..."

    task.spawn(function()
        local onlineKeys = fetchKeysFromGithub()
        local inputKey = KeyTextBox.Text:match("^%s*(.-)%s*$")

        if onlineKeys[inputKey] then
            KeyStatus.TextColor3 = Color3.fromRGB(80, 255, 80)
            KeyStatus.Text = "Key Aprovada! Abrindo..."
            task.wait(0.5)
            KeyFrame:Destroy()
            Frame.Visible = true
        else
            KeyStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
            KeyStatus.Text = "Key Invalida ou expirada!"
        end
    end)
end)

----------------------------------------------------------------
-- Criador de Botões do Menu
----------------------------------------------------------------
local function createButton(text, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.88, 0, 0, 26)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.Parent = Frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    return btn
end

local HighlightBtn = createButton("Highlight: OFF", UDim2.new(0.06, 0, 0.07, 0))
local TextBtn = createButton("Distancia/Nomes: OFF", UDim2.new(0.06, 0, 0.13, 0))
local AimbotBtn = createButton("Aimbot: OFF", UDim2.new(0.06, 0, 0.19, 0))
local TargetBtn = createButton("Alvo: Peito", UDim2.new(0.06, 0, 0.25, 0))
TargetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 180)

local ResetTimeBtn = createButton("Restaurar Hora Padrão", UDim2.new(0.06, 0, 0.31, 0))
ResetTimeBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 180)

----------------------------------------------------------------
-- Criador de Sliders
----------------------------------------------------------------
local function createSlider(labelText, posLabel, posBar, minVal, maxVal, defaultVal, suffix, onUpdate)
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(0.88, 0, 0, 16)
    SliderLabel.Position = posLabel
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = labelText .. ": " .. math.floor(defaultVal) .. suffix
    SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SliderLabel.TextSize = 12
    SliderLabel.Font = Enum.Font.SourceSans
    SliderLabel.Parent = Frame

    local SliderBack = Instance.new("Frame")
    SliderBack.Size = UDim2.new(0.88, 0, 0, 6)
    SliderBack.Position = posBar
    SliderBack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBack.BorderSizePixel = 0
    SliderBack.Parent = Frame

    local SliderBackCorner = Instance.new("UICorner")
    SliderBackCorner.CornerRadius = UDim.new(1, 0)
    SliderBackCorner.Parent = SliderBack

    local initialRatio = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(initialRatio, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBack

    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(1, 0)
    SliderFillCorner.Parent = SliderFill

    local isDragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        local val = minVal + (pos * (maxVal - minVal))
        SliderLabel.Text = labelText .. ": " .. math.floor(val) .. suffix
        onUpdate(val)
    end

    local function setValueExternal(val)
        local ratio = math.clamp((val - minVal) / (maxVal - minVal), 0, 1)
        SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
        SliderLabel.Text = labelText .. ": " .. math.floor(val) .. suffix
    end

    SliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            update(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    return setValueExternal
end

local updateTimeSlider = createSlider("Horário (Luz)", UDim2.new(0.06, 0, 0.38, 0), UDim2.new(0.06, 0, 0.42, 0), 0, 24, CurrentTime, "h", function(val)
    CurrentTime = val
    Lighting.ClockTime = val
end)

createSlider("Raio FOV", UDim2.new(0.06, 0, 0.48, 0), UDim2.new(0.06, 0, 0.52, 0), 30, 500, FOV_RADIUS, "", function(val)
    FOV_RADIUS = math.floor(val)
end)

createSlider("Distância ESP", UDim2.new(0.06, 0, 0.58, 0), UDim2.new(0.06, 0, 0.62, 0), 100, 5000, MAX_ESP_DISTANCE, "m", function(val)
    MAX_ESP_DISTANCE = math.floor(val)
end)

----------------------------------------------------------------
-- Lógica do Aimbot e ESP
----------------------------------------------------------------
ResetTimeBtn.MouseButton1Click:Connect(function()
    CurrentTime = ORIGINAL_TIME
    Lighting.ClockTime = ORIGINAL_TIME
    updateTimeSlider(ORIGINAL_TIME)
end)

local function isTeammate(player)
    if player == LocalPlayer then return false end
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team == player.Team
    end
    return false
end

local function getESPColor(player)
    return isTeammate(player) and TEAM_COLOR or ENEMY_COLOR
end

local function getTargetPart(character)
    if TargetPart == "Head" then
        return character:FindFirstChild("Head")
    else
        return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    end
end

local function getClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = FOV_RADIUS
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not isTeammate(player) then
            local char = player.Character
            if char and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                local part = getTargetPart(char)
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightShift then
        if not KeyFrame.Parent then
            Frame.Visible = not Frame.Visible
        end
        return
    end

    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aiming = false
    end
end)

local function applyESP(player)
    if player == LocalPlayer then return end

    local function setupCharacter(character)
        if not character then return end
        local head = character:WaitForChild("Head", 5)
        if not head then return end

        local color = getESPColor(player)

        local highlight = character:FindFirstChild("ESPHighlight") or Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.Adornee = character
        highlight.FillColor = color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.Enabled = false
        highlight.Parent = character

        local billboard = head:FindFirstChild("ESPText") or Instance.new("BillboardGui")
        billboard.Name = "ESPText"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 150, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Enabled = false
        billboard.Parent = head

        local label = billboard:FindFirstChild("NameLabel") or Instance.new("TextLabel")
        label.Name = "NameLabel"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.Name
        label.TextColor3 = color
        label.TextStrokeTransparency = 0
        label.TextSize = 14
        label.Font = Enum.Font.SourceSansBold
        label.Parent = billboard
    end

    if player.Character then setupCharacter(player.Character) end
    player.CharacterAdded:Connect(setupCharacter)
end

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    FOVFrame.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2)
    FOVFrame.Position = UDim2.new(0, mousePos.X - FOV_RADIUS, 0, mousePos.Y - FOV_RADIUS)
    FOVFrame.Visible = AimbotEnabled and Frame.Visible

    if Frame.Visible then
        Lighting.ClockTime = CurrentTime

        if AimbotEnabled and Aiming then
            local target = getClosestPlayerToCursor()
            if target and target.Character then
                local part = getTargetPart(target.Character)
                if part then
                    local targetCFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 - SMOOTHNESS)
                end
            end
        end

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myPos = LocalPlayer.Character.HumanoidRootPart.Position

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetHRT = player.Character:FindFirstChild("HumanoidRootPart")
                    local head = player.Character:FindFirstChild("Head")

                    if targetHRT and head then
                        local distanceMeters = math.floor((myPos - targetHRT.Position).Magnitude * 0.28)
                        local withinDistance = distanceMeters <= MAX_ESP_DISTANCE
                        local currentColor = getESPColor(player)

                        local highlight = player.Character:FindFirstChild("ESPHighlight")
                        if highlight then
                            highlight.Enabled = HighlightEnabled and withinDistance
                            highlight.FillColor = currentColor
                        end

                        local billboard = head:FindFirstChild("ESPText")
                        if billboard then
                            billboard.Enabled = TextEnabled and withinDistance
                            local label = billboard:FindFirstChild("NameLabel")
                            if label then
                                label.Text = string.format("%s\n[%d m]", player.Name, distanceMeters)
                                label.TextColor3 = currentColor
                            end
                        end
                    end
                end
            end
        end
    end
end)

HighlightBtn.MouseButton1Click:Connect(function()
    HighlightEnabled = not HighlightEnabled
    HighlightBtn.Text = "Highlight: " .. (HighlightEnabled and "ON" or "OFF")
    HighlightBtn.BackgroundColor3 = HighlightEnabled and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
end)

TextBtn.MouseButton1Click:Connect(function()
    TextEnabled = not TextEnabled
    TextBtn.Text = "Distancia/Nomes: " .. (TextEnabled and "ON" or "OFF")
    TextBtn.BackgroundColor3 = TextEnabled and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
end)

AimbotBtn.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimbotBtn.Text = "Aimbot: " .. (AimbotEnabled and "ON" or "OFF")
    AimbotBtn.BackgroundColor3 = AimbotEnabled and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
end)

TargetBtn.MouseButton1Click:Connect(function()
    if TargetPart == "Chest" then
        TargetPart = "Head"
        TargetBtn.Text = "Alvo: Cabeça"
    else
        TargetPart = "Chest"
        TargetBtn.Text = "Alvo: Peito"
    end
end)

for _, player in ipairs(Players:GetPlayers()) do applyESP(player) end
Players.PlayerAdded:Connect(applyESP)

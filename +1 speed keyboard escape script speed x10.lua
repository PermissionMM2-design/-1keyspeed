-- Локальные переменные
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

-- КЛЮЧ АКТИВАЦИИ (измените на свой)
local VALID_KEY = "HSD59307492849D3"

-- Состояние
local isKeyValid = false
local isBoostActive = false
local boostConnection = nil
local currentCharacter = nil
local currentHumanoid = nil

-- ============= ПРОВЕРКА СОХРАНЕННОГО КЛЮЧА =============

local function checkSavedKey()
    local keyFolder = workspace:FindFirstChild("key_boost")
    if keyFolder then
        local keyValue = keyFolder:FindFirstChild("Key")
        if keyValue and keyValue.Value == VALID_KEY then
            return true
        end
    end
    return false
end

local function saveKey()
    local keyFolder = workspace:FindFirstChild("key_boost")
    if not keyFolder then
        keyFolder = Instance.new("Folder")
        keyFolder.Name = "key_boost"
        keyFolder.Parent = workspace
    end
    
    local keyValue = keyFolder:FindFirstChild("Key")
    if not keyValue then
        keyValue = Instance.new("StringValue")
        keyValue.Name = "Key"
        keyValue.Parent = keyFolder
    end
    keyValue.Value = VALID_KEY
end

-- ============= СОЗДАНИЕ ЗАГРУЗОЧНОГО ЭКРАНА =============

local loadGui = Instance.new("ScreenGui")
loadGui.Name = "LoadGui"
loadGui.ResetOnSpawn = false
loadGui.Parent = player.PlayerGui
loadGui.Enabled = true

-- Затемненный фон
local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
background.BackgroundTransparency = 0.85
background.Parent = loadGui

-- Контейнер загрузки (первый экран)
local loadContainer = Instance.new("Frame")
loadContainer.Size = UDim2.new(0, 300, 0, 200)
loadContainer.Position = UDim2.new(0.5, -150, 0.5, -100)
loadContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
loadContainer.BackgroundTransparency = 0
loadContainer.BorderSizePixel = 0
loadContainer.Parent = background

-- Скругление контейнера
local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 16)
containerCorner.Parent = loadContainer

-- Логотип/Иконка загрузки
local loadIcon = Instance.new("TextLabel")
loadIcon.Size = UDim2.new(0, 60, 0, 60)
loadIcon.Position = UDim2.new(0.5, -30, 0, 20)
loadIcon.BackgroundTransparency = 1
loadIcon.Text = "⚡"
loadIcon.TextColor3 = Color3.fromRGB(200, 200, 200)
loadIcon.TextSize = 50
loadIcon.Font = Enum.Font.SourceSansBold
loadIcon.Parent = loadContainer

-- Заголовок загрузки
local loadTitle = Instance.new("TextLabel")
loadTitle.Size = UDim2.new(1, 0, 0, 30)
loadTitle.Position = UDim2.new(0, 0, 0, 90)
loadTitle.BackgroundTransparency = 1
loadTitle.Text = "LOADING..."
loadTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
loadTitle.TextSize = 18
loadTitle.Font = Enum.Font.SourceSansBold
loadTitle.TextScaled = false
loadTitle.Parent = loadContainer

-- Прогресс-бар
local progressBarBg = Instance.new("Frame")
progressBarBg.Size = UDim2.new(0.7, 0, 0, 4)
progressBarBg.Position = UDim2.new(0.15, 0, 0, 135)
progressBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
progressBarBg.BackgroundTransparency = 0
progressBarBg.BorderSizePixel = 0
progressBarBg.Parent = loadContainer

local progressBarCorner = Instance.new("UICorner")
progressBarCorner.CornerRadius = UDim.new(1, 0)
progressBarCorner.Parent = progressBarBg

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(100, 140, 200)
progressBar.BackgroundTransparency = 0
progressBar.BorderSizePixel = 0
progressBar.Parent = progressBarBg

local progressBarCorner2 = Instance.new("UICorner")
progressBarCorner2.CornerRadius = UDim.new(1, 0)
progressBarCorner2.Parent = progressBar

-- Текст процентов
local progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(1, 0, 0, 20)
progressText.Position = UDim2.new(0, 0, 0, 150)
progressText.BackgroundTransparency = 1
progressText.Text = "0%"
progressText.TextColor3 = Color3.fromRGB(150, 150, 150)
progressText.TextSize = 12
progressText.Font = Enum.Font.SourceSans
progressText.Parent = loadContainer

-- ============= GUI КЛЮЧА (компактный) =============

-- Контейнер ключа (появляется после загрузки)
local keyContainer = Instance.new("Frame")
keyContainer.Size = UDim2.new(0, 320, 0, 180)
keyContainer.Position = UDim2.new(0.5, -160, 0.5, -90)
keyContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
keyContainer.BackgroundTransparency = 0
keyContainer.BorderSizePixel = 0
keyContainer.Visible = false
keyContainer.Parent = background

-- Скругление контейнера ключа
local keyContainerCorner = Instance.new("UICorner")
keyContainerCorner.CornerRadius = UDim.new(0, 16)
keyContainerCorner.Parent = keyContainer

-- Заголовок ключа
local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, 0, 0, 35)
keyTitle.Position = UDim2.new(0, 0, 0, 15)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "🔑 ENTER KEY"
keyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
keyTitle.TextSize = 16
keyTitle.Font = Enum.Font.SourceSansBold
keyTitle.Parent = keyContainer

-- Поле ввода ключа (компактное)
local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0.85, 0, 0, 40)
keyBox.Position = UDim2.new(0.075, 0, 0, 60)
keyBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
keyBox.BackgroundTransparency = 0
keyBox.BorderSizePixel = 2
keyBox.BorderColor3 = Color3.fromRGB(60, 60, 65)
keyBox.Text = ""
keyBox.TextColor3 = Color3.fromRGB(200, 200, 200)
keyBox.TextSize = 16
keyBox.Font = Enum.Font.SourceSans
keyBox.PlaceholderText = "Enter key..."
keyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
keyBox.ClearTextOnFocus = false
keyBox.Parent = keyContainer

-- Скругление поля ввода
local keyBoxCorner = Instance.new("UICorner")
keyBoxCorner.CornerRadius = UDim.new(0, 8)
keyBoxCorner.Parent = keyBox

-- Кнопка активации (компактная)
local activateButton = Instance.new("ImageButton")
activateButton.Size = UDim2.new(0.85, 0, 0, 40)
activateButton.Position = UDim2.new(0.075, 0, 0, 110)
activateButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
activateButton.BackgroundTransparency = 0
activateButton.BorderSizePixel = 0
activateButton.Parent = keyContainer

-- Скругление кнопки
local activateCorner = Instance.new("UICorner")
activateCorner.CornerRadius = UDim.new(0, 8)
activateCorner.Parent = activateButton

-- Текст кнопки
local activateText = Instance.new("TextLabel")
activateText.Size = UDim2.new(1, 0, 1, 0)
activateText.BackgroundTransparency = 1
activateText.Text = "ACTIVATE"
activateText.TextColor3 = Color3.fromRGB(255, 255, 255)
activateText.TextSize = 16
activateText.Font = Enum.Font.SourceSansBold
activateText.Parent = activateButton

-- Статус сообщение
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 0, 25)
statusText.Position = UDim2.new(0, 0, 0, 155)
statusText.BackgroundTransparency = 1
statusText.Text = ""
statusText.TextColor3 = Color3.fromRGB(150, 150, 150)
statusText.TextSize = 13
statusText.Font = Enum.Font.SourceSans
statusText.Parent = keyContainer

-- ============= ГЛАВНЫЙ GUI С КНОПКОЙ БУСТА =============

local mainGui = Instance.new("ScreenGui")
mainGui.Name = "BoostGui"
mainGui.ResetOnSpawn = false
mainGui.Parent = player.PlayerGui
mainGui.Enabled = false

-- Кнопка буста
local boostFrame = Instance.new("ImageButton")
boostFrame.Size = UDim2.new(0, 70, 0, 70)
boostFrame.Position = UDim2.new(0.5, 140, 0.5, 50)
boostFrame.AnchorPoint = Vector2.new(0.5, 0.5)
boostFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
boostFrame.BackgroundTransparency = 0.1
boostFrame.BorderSizePixel = 2
boostFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
boostFrame.Parent = mainGui

local boostCorner = Instance.new("UICorner")
boostCorner.CornerRadius = UDim.new(0, 12)
boostCorner.Parent = boostFrame

-- Текст кнопки
local boostLabel = Instance.new("TextLabel")
boostLabel.Size = UDim2.new(1, 0, 1, 0)
boostLabel.BackgroundTransparency = 1
boostLabel.Text = "×10"
boostLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
boostLabel.TextSize = 28
boostLabel.Font = Enum.Font.SourceSansBold
boostLabel.TextStrokeTransparency = 0.3
boostLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
boostLabel.Parent = boostFrame

-- Тень текста
local boostShadow = Instance.new("TextLabel")
boostShadow.Size = UDim2.new(1, 0, 1, 0)
boostShadow.BackgroundTransparency = 1
boostShadow.Text = "×10"
boostShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
boostShadow.TextSize = 28
boostShadow.Font = Enum.Font.SourceSansBold
boostShadow.TextTransparency = 0.7
boostShadow.Position = UDim2.new(0, 1, 0, 1)
boostShadow.Parent = boostFrame

-- ============= ФУНКЦИИ АНИМАЦИИ =============

-- Анимация кнопки буста
local function animateBoostPress()
    local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenDown = tweenService:Create(boostFrame, tweenInfo, {
        Size = UDim2.new(0, 76, 0, 76),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderColor3 = Color3.fromRGB(80, 80, 80)
    })
    tweenDown:Play()
    tweenDown.Completed:Wait()
    
    local tweenUp = tweenService:Create(boostFrame, tweenInfo, {
        Size = UDim2.new(0, 70, 0, 70)
    })
    tweenUp:Play()
end

-- ============= ОСНОВНЫЕ ФУНКЦИИ =============

-- Обновление персонажа
local function updateCharacter(newChar)
    currentCharacter = newChar
    if newChar then
        currentHumanoid = newChar:FindFirstChild("Humanoid")
        if isBoostActive and currentHumanoid then
            currentHumanoid.WalkSpeed = 16 * 10
        end
    end
end

if player.Character then
    updateCharacter(player.Character)
end

player.CharacterAdded:Connect(function(newChar)
    updateCharacter(newChar)
end)

-- Переключение буста
local function toggleBoost()
    if not isKeyValid then return end
    
    animateBoostPress()
    
    if isBoostActive then
        isBoostActive = false
        boostFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        boostFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
        boostLabel.Text = "×10"
        boostLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        boostShadow.Text = "×10"
        
        if boostConnection then
            boostConnection:Disconnect()
            boostConnection = nil
        end
        if currentHumanoid then
            currentHumanoid.WalkSpeed = 16
        end
    else
        isBoostActive = true
        boostFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        boostFrame.BorderColor3 = Color3.fromRGB(100, 140, 200)
        boostLabel.Text = "ON"
        boostLabel.TextColor3 = Color3.fromRGB(120, 180, 255)
        boostShadow.Text = "ON"
        
        boostConnection = runService.Stepped:Connect(function()
            if currentCharacter and currentHumanoid then
                currentHumanoid.WalkSpeed = 16 * 10
            else
                local char = player.Character
                if char then
                    currentCharacter = char
                    currentHumanoid = char:FindFirstChild("Humanoid")
                end
            end
        end)
    end
end

boostFrame.MouseButton1Click:Connect(toggleBoost)

-- ============= СИСТЕМА КЛЮЧЕЙ =============

local function validateKey(inputKey)
    return inputKey == VALID_KEY
end

local function activateKey()
    local key = keyBox.Text
    if key == "" then
        statusText.Text = "⚠️ Enter the key!"
        statusText.TextColor3 = Color3.fromRGB(255, 200, 50)
        return
    end
    
    activateButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    activateText.Text = "CHECKING..."
    statusText.Text = "⏳ Checking key..."
    statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    
    task.wait(0.5)
    
    if validateKey(key) then
        isKeyValid = true
        saveKey() -- Сохраняем ключ в workspace
        statusText.Text = "✅ Key accepted!"
        statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        activateButton.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
        activateText.Text = "ACTIVATED"
        
        task.wait(0.3)
        
        -- Закрываем GUI ключа
        local closeTween = tweenService:Create(keyContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        })
        closeTween:Play()
        closeTween.Completed:Wait()
        
        keyContainer.Visible = false
        background.BackgroundTransparency = 1
        loadGui.Enabled = false
        mainGui.Enabled = true
        
        -- Автоматически включаем буст
        task.wait(0.2)
        toggleBoost()
    else
        statusText.Text = "❌ INVALID KEY!"
        statusText.TextColor3 = Color3.fromRGB(255, 80, 80)
        activateButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        activateText.Text = "ACTIVATE"
        
        -- Анимация ошибки
        local shake = tweenService:Create(keyContainer, TweenInfo.new(0.08, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
            Position = UDim2.new(0.5, -165, 0.5, -90)
        })
        shake:Play()
        task.wait(0.08)
        local shake2 = tweenService:Create(keyContainer, TweenInfo.new(0.08, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
            Position = UDim2.new(0.5, -155, 0.5, -90)
        })
        shake2:Play()
        task.wait(0.08)
        local shake3 = tweenService:Create(keyContainer, TweenInfo.new(0.08, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
            Position = UDim2.new(0.5, -160, 0.5, -90)
        })
        shake3:Play()
        
        keyBox.Text = ""
        keyBox:CaptureFocus()
    end
end

-- ============= ЗАГРУЗКА 5 СЕКУНД =============

local function startLoading()
    -- Проверяем сохраненный ключ
    if checkSavedKey() then
        isKeyValid = true
        -- Быстрая загрузка
        loadTitle.Text = "LOADED..."
        progressBar.Size = UDim2.new(1, 0, 1, 0)
        progressText.Text = "100%"
        progressBar.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        task.wait(0.5)
        
        loadContainer.Visible = false
        background.BackgroundTransparency = 1
        loadGui.Enabled = false
        mainGui.Enabled = true
        task.wait(0.2)
        toggleBoost()
        return
    end
    
    local duration = 5
    local steps = 50
    local stepTime = duration / steps
    
    for i = 0, steps do
        local progress = i / steps
        local percent = math.floor(progress * 100)
        
        progressBar.Size = UDim2.new(progress, 0, 1, 0)
        progressText.Text = percent .. "%"
        
        if percent < 30 then
            progressBar.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        elseif percent < 70 then
            progressBar.BackgroundColor3 = Color3.fromRGB(200, 180, 80)
        else
            progressBar.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        end
        
        if percent == 100 then
            loadTitle.Text = "LOADED..."
        end
        
        task.wait(stepTime)
    end
    
    -- Загрузка завершена - показываем GUI ключа
    loadContainer.Visible = false
    keyContainer.Visible = true
    keyContainer.BackgroundTransparency = 0
    
    local appearTween = tweenService:Create(keyContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 320, 0, 180)
    })
    appearTween:Play()
end

-- Запускаем загрузку
task.spawn(startLoading)

-- Обработка Enter
keyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        activateKey()
    end
end)

activateButton.MouseButton1Click:Connect(activateKey)

-- ============= ОЧИСТКА =============

player:GetPropertyChangedSignal("Character"):Connect(function()
    if not player.Character and boostConnection then
        boostConnection:Disconnect()
        boostConnection = nil
    end
end)
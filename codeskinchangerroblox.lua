local env = getfenv and getfenv(0) or _ENV or _G
local Instance = env.Instance
local game = env.game
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
-- ══════════════════════════════════════
--  CORE CLONE LOGIC
-- ══════════════════════════════════════

local function getDescriptionFromUserId(userId)
    local success, desc = pcall(function()
        return Players:GetCharacterAppearanceInfoAsync(userId)
    end)
    if not success then return nil, "Invalid user ID or no appearance found." end
    return desc, nil
end

local function getDescriptionFromUsername(username)
    local success, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    if not success then return nil, "Username not found." end
    return getDescriptionFromUserId(userId)
end

local function applyHumanoidDescription(description)
    local char = LocalPlayer.Character
    if not char then return false, "No character found." end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false, "No humanoid found." end

    local humDesc = Instance.new("HumanoidDescription")

    -- Body colors
    if description.bodyColors then
        humDesc.HeadColor = Color3.fromRGB(
            description.bodyColors.headColorId or 194,
            description.bodyColors.headColorId or 178,
            description.bodyColors.headColorId or 128
        )
    end

    -- Scales
    if description.scales then
        humDesc.HeightScale    = description.scales.height    or 1
        humDesc.WidthScale     = description.scales.width     or 1
        humDesc.HeadScale      = description.scales.head      or 1
        humDesc.BodyTypeScale  = description.scales.bodyType  or 0
        humDesc.ProportionScale = description.scales.proportion or 0
    end

    -- Assets
    local assetMap = {
        Hat         = "HatAccessory",
        HairAccessory = "HairAccessory",
        FaceAccessory = "FaceAccessory",
        NeckAccessory = "NeckAccessory",
        ShoulderAccessory = "ShoulderAccessory",
        FrontAccessory = "FrontAccessory",
        BackAccessory = "BackAccessory",
        WaistAccessory = "WaistAccessory",
        Face        = "Face",
        Head        = "Head",
        Torso       = "Torso",
        LeftArm     = "LeftArm",
        RightArm    = "RightArm",
        LeftLeg     = "LeftLeg",
        RightLeg    = "RightLeg",
        TShirt      = "GraphicTShirt",
        Shirt       = "Shirt",
        Pants       = "Pants",
    }

    local accTypes = {
        "Hat","HairAccessory","FaceAccessory","NeckAccessory",
        "ShoulderAccessory","FrontAccessory","BackAccessory","WaistAccessory"
    }
    local accIds = {}

    for _, asset in ipairs(description.assets or {}) do
        local t = asset.assetType and asset.assetType.name
        if t == "Face"    then humDesc.Face    = asset.id end
        if t == "Head"    then humDesc.Head    = asset.id end
        if t == "Torso"   then humDesc.Torso   = asset.id end
        if t == "LeftArm" then humDesc.LeftArm = asset.id end
        if t == "RightArm"then humDesc.RightArm= asset.id end
        if t == "LeftLeg" then humDesc.LeftLeg = asset.id end
        if t == "RightLeg"then humDesc.RightLeg= asset.id end
        if t == "TShirt"  then humDesc.GraphicTShirt = asset.id end
        if t == "Shirt"   then humDesc.Shirt   = asset.id end
        if t == "Pants"   then humDesc.Pants   = asset.id end

        for _, accType in ipairs(accTypes) do
            if t == accType then
                table.insert(accIds, asset.id)
            end
        end
    end

    humDesc.AccessoryBlob = table.concat(accIds, ",")

    local ok, err = pcall(function()
        hum:ApplyDescription(humDesc)
    end)

    if not ok then return false, "ApplyDescription failed: " .. tostring(err) end
    return true, "Avatar cloned successfully!"
end

local function cloneByInput(input)
    input = input:match("^%s*(.-)%s*$") -- trim whitespace
    local desc, err

    if tonumber(input) then
        desc, err = getDescriptionFromUserId(tonumber(input))
    else
        desc, err = getDescriptionFromUsername(input)
    end

    if not desc then return false, err end
    return applyHumanoidDescription(desc)
end

-- ══════════════════════════════════════
--  GUI
-- ══════════════════════════════════════

local screenGui = (syn and syn.protect_gui or function(o) return o end)(Instance.new("ScreenGui"))
screenGui.Name = "AvatarClonerGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = game:GetService("CoreGui")

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 200)
frame.Position = UDim2.new(0.5, -170, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Accent top bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 4)
topBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
topBar.BorderSizePixel = 0
topBar.Parent = frame

-- Corner rounding
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 16, 0, 8)
title.BackgroundTransparency = 1
title.Text = "🎭 Avatar Cloner"
title.TextColor3 = Color3.fromRGB(220, 235, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Subtitle
local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -32, 0, 20)
subtitle.Position = UDim2.new(0, 16, 0, 44)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Enter a username or user ID"
subtitle.TextColor3 = Color3.fromRGB(110, 130, 160)
subtitle.TextSize = 12
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = frame

-- Input box
local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -32, 0, 38)
inputBox.Position = UDim2.new(0, 16, 0, 70)
inputBox.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
inputBox.BorderSizePixel = 0
inputBox.PlaceholderText = "e.g. Builderman or 156"
inputBox.PlaceholderColor3 = Color3.fromRGB(70, 80, 100)
inputBox.Text = ""
inputBox.TextColor3 = Color3.fromRGB(210, 225, 255)
inputBox.TextSize = 14
inputBox.Font = Enum.Font.Gotham
inputBox.ClearTextOnFocus = false
inputBox.Parent = frame
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)
local inputPad = Instance.new("UIPadding", inputBox)
inputPad.PaddingLeft = UDim.new(0, 10)

-- Clone button
local cloneBtn = Instance.new("TextButton")
cloneBtn.Size = UDim2.new(1, -32, 0, 38)
cloneBtn.Position = UDim2.new(0, 16, 0, 118)
cloneBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
cloneBtn.Text = "Clone Avatar"
cloneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cloneBtn.TextSize = 14
cloneBtn.Font = Enum.Font.GothamBold
cloneBtn.BorderSizePixel = 0
cloneBtn.Parent = frame
Instance.new("UICorner", cloneBtn).CornerRadius = UDim.new(0, 6)

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -32, 0, 24)
statusLabel.Position = UDim2.new(0, 16, 0, 162)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(100, 200, 120)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = frame

-- Button hover effect
cloneBtn.MouseEnter:Connect(function()
    cloneBtn.BackgroundColor3 = Color3.fromRGB(0, 165, 255)
end)
cloneBtn.MouseLeave:Connect(function()
    cloneBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
end)

-- Clone action
local function doClone()
    local input = inputBox.Text
    if input == "" then
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "⚠ Please enter a username or ID."
        return
    end

    cloneBtn.Text = "Cloning..."
    cloneBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 170)
    statusLabel.Text = ""

    local ok, msg = cloneByInput(input)

    cloneBtn.Text = "Clone Avatar"
    cloneBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)

    if ok then
        statusLabel.TextColor3 = Color3.fromRGB(80, 220, 130)
        statusLabel.Text = "✔ " .. msg
    else
        statusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
        statusLabel.Text = "✘ " .. (msg or "Unknown error.")
    end
end

cloneBtn.MouseButton1Click:Connect(doClone)
inputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then doClone() end
end)

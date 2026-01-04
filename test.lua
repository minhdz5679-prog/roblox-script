local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Tạo GUI cho TELE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShortTeleportGUI"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 120, 0, 60)
MainFrame.Position = UDim2.new(0, 20, 0.5, -30)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 0, 0)  -- ĐỎ viền frame
Stroke.Thickness = 2
Stroke.Parent = MainFrame

local TeleButton = Instance.new("TextButton")
TeleButton.Name = "TeleButton"
TeleButton.Size = UDim2.new(1, -10, 1, -10)
TeleButton.Position = UDim2.new(0, 5, 0, 5)
TeleButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)  -- XANH DƯƠNG nền nút
TeleButton.Text = "TELE"
TeleButton.TextColor3 = Color3.new(1,1,1)
TeleButton.TextScaled = true
TeleButton.Font = Enum.Font.GothamBold
TeleButton.BorderSizePixel = 0
TeleButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = TeleButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Color = Color3.fromRGB(255, 0, 0)  -- ĐỎ viền nút
ButtonStroke.Thickness = 2
ButtonStroke.Parent = TeleButton

-- Draggable GUI
local dragging = false
local dragStart = nil
local startPos = nil

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Logic TELEPORT - 🔥 TĂNG LÊN 60 STUDS + SPEED 600 (XA HƠN & SIÊU NHANH!)
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local distance = 60   -- 🔥 TĂNG 60 STUDS (xa hơn!)
local speed = 600     -- 🔥 TĂNG SPEED 600 (nhanh gấp đôi trước!)
local teleConnection

local function setNoclip(state)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part ~= humanoidRootPart then
            part.CanCollide = not state
        end
    end
    humanoidRootPart.CanCollide = false
end

local function shortTeleport()
    if teleConnection then return end
    
    local startCFrame = humanoidRootPart.CFrame
    local direction = humanoidRootPart.CFrame.LookVector
    local targetCFrame = startCFrame + (direction * distance)
    
    setNoclip(true)
    
    local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    
    teleConnection = RunService.Heartbeat:Connect(function()
        setNoclip(true)
    end)
    
    tween:Play()
    tween.Completed:Connect(function()
        if teleConnection then
            teleConnection:Disconnect()
            teleConnection = nil
        end
        setNoclip(false)
        print("TELE: +" .. distance .. " studs phía trước (speed " .. speed .. ")! 🔵🔴⚡")
    end)
end

-- Sự kiện TELE: Nút + Phím T
TeleButton.MouseButton1Click:Connect(shortTeleport)
TeleButton.TouchTap:Connect(shortTeleport)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.T then
        shortTeleport()
    end
end)

-- Logic FLY ASCEND - 🔥 ASCEND 60 + WALKSPEED 60 KHI BAY (BAY NGANG SIÊU NHANH!)
local ascendSpeed = 60  -- 🔥 TĂNG 60 (bay lên nhanh hơn!)
local walkSpeedFly = 60 -- 🔥 TĂNG 60 (bay ngang 60 speed!)
local defaultWalkSpeed = 16
local bodyVelocity = nil
local isAscending = false

local function startAscend()
    if isAscending then return end
    isAscending = true
    
    humanoid.WalkSpeed = walkSpeedFly
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, ascendSpeed, 0)
    bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
    bodyVelocity.Parent = humanoidRootPart
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    print("Ascend: BẬT - Bay lên " .. ascendSpeed .. " + WalkSpeed " .. walkSpeedFly .. "! 🚀💨")
end

local function stopAscend()
    if not isAscending then return end
    isAscending = false
    
    humanoid.WalkSpeed = defaultWalkSpeed
    
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
    
    print("Ascend: TẮT - Reset WalkSpeed " .. defaultWalkSpeed .. ".")
end

-- Detect giữ/thả SPACE
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space then
        startAscend()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space then
        stopAscend()
    end
end)

-- Respawn handler
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    if teleConnection then
        teleConnection:Disconnect()
        teleConnection = nil
    end
    stopAscend()
    humanoid.WalkSpeed = defaultWalkSpeed
    wait(0.5)
end)

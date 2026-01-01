local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local distance = 8 -- Khoảng cách dịch chuyển (studs) - Có thể chỉnh nhỏ hơn nếu cần
local speed = 300 -- Tốc độ di chuyển (studs/giây) - Làm nhanh để mượt
local connection
local noclipConnection

local function setNoclip(state)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
end

local function shortTeleport()
    if connection then return end -- Tránh spam
    
    local startCFrame = humanoidRootPart.CFrame
    local direction = humanoidRootPart.CFrame.LookVector
    local targetCFrame = startCFrame + (direction * distance)
    
    -- Bật noclip tạm thời
    setNoclip(true)
    
    -- Tween mượt mà (tùy chọn, có thể bỏ để teleport tức thì)
    local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    
    connection = RunService.Heartbeat:Connect(function()
        -- Giữ noclip trong lúc di chuyển
        setNoclip(true)
    end)
    
    tween:Play()
    tween.Completed:Connect(function()
        connection:Disconnect()
        connection = nil
        setNoclip(false) -- Tắt noclip
    end)
    
    print("Short Teleport: VỀ PHÍA TRƯỚC " .. distance .. " studs!")
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        shortTeleport()
    end
end)

-- Tự động cập nhật khi respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    if connection then
        connection:Disconnect()
        connection = nil
    end
end)

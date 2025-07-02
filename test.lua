local gui = Instance.new("ScreenGui", game.CoreGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 280)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Name = "QuanCheaterVn"

local title = Instance.new("TextLabel", frame)
title.Text = "QuanCheaterVn"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local function makeToggle(name, y)
    local b = Instance.new("TextButton", frame)
    b.Text = name .. ": OFF"
    b.Size = UDim2.new(0, 200, 0, 30)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.BorderSizePixel = 0
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = name .. ": " .. (state and "ON" or "OFF")
    end)
    return function() return state end
end

local espToggle = makeToggle("ESP", 40)
local lineToggle = makeToggle("Line", 80)
local skeToggle = makeToggle("Skeleton", 120)
local nameToggle = makeToggle("Name", 160)
local aimToggle = makeToggle("Aimbot", 200)

local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ESPObjects = {}

function createESP(player)
    local box = Drawing.new("Square")
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 1
    box.Filled = false
    box.Visible = false

    local line = Drawing.new("Line")
    line.Color = Color3.fromRGB(255, 255, 0)
    line.Thickness = 1
    line.Visible = false

    local text = Drawing.new("Text")
    text.Size = 13
    text.Color = Color3.fromRGB(0, 255, 0)
    text.Center = true
    text.Outline = true
    text.Visible = false

    local function update()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then
            local pos, on = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
            if on then
                local head = Camera:WorldToViewportPoint(char.Head.Position)
                local sizeY = math.clamp(2000 / (char.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude, 30, 200)
                local sizeX = sizeY / 2
                box.Size = Vector2.new(sizeX, sizeY)
                box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                box.Visible = espToggle()
                line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                line.To = Vector2.new(pos.X, pos.Y)
                line.Visible = lineToggle()
                local dist = math.floor((Camera.CFrame.Position - char.HumanoidRootPart.Position).Magnitude)
                text.Position = Vector2.new(pos.X, pos.Y - sizeY / 2 - 15)
                text.Text = player.Name .. " [" .. dist .. "m]"
                text.Visible = nameToggle()
            else
                box.Visible = false
                line.Visible = false
                text.Visible = false
            end
        else
            box.Visible = false
            line.Visible = false
            text.Visible = false
        end
    end

    ESPObjects[player] = {update = update, box = box, line = line, text = text}
end

function drawSkeleton(player)
    local bones = {}
    local function drawLine()
        local l = Drawing.new("Line")
        l.Color = Color3.fromRGB(0, 255, 255)
        l.Thickness = 1
        l.Visible = false
        return l
    end
    for i = 1, 10 do
        bones[i] = drawLine()
    end
    local function update()
        local char = player.Character
        if not skeToggle() or not char or not char:FindFirstChild("Head") or not char:FindFirstChild("HumanoidRootPart") then
            for _, l in pairs(bones) do l.Visible = false end
            return
        end
        local joints = {
            char:FindFirstChild("Head"),
            char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
            char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso"),
            char:FindFirstChild("LeftUpperArm"),
            char:FindFirstChild("LeftLowerArm"),
            char:FindFirstChild("RightUpperArm"),
            char:FindFirstChild("RightLowerArm"),
            char:FindFirstChild("LeftUpperLeg"),
            char:FindFirstChild("LeftLowerLeg"),
            char:FindFirstChild("RightUpperLeg"),
            char:FindFirstChild("RightLowerLeg"),
        }
        local pos = {}
        for i, part in ipairs(joints) do
            if part then
                local screen, on = Camera:WorldToViewportPoint(part.Position)
                pos[i] = on and Vector2.new(screen.X, screen.Y) or nil
            end
        end
        local lines = {
            {1,2},{2,3},{2,4},{4,5},{2,6},{6,7},
            {3,8},{8,9},{3,10},{10,11}
        }
        for i, pair in ipairs(lines) do
            local a,b = pos[pair[1]], pos[pair[2]]
            if a and b then
                bones[i].From = a
                bones[i].To = b
                bones[i].Visible = true
            else
                bones[i].Visible = false
            end
        end
    end
    if not ESPObjects[player] then ESPObjects[player] = {} end
    ESPObjects[player].ske = update
end

local AimTarget = nil
function getClosest()
    local shortest = math.huge
    local target = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
            local pos, on = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if on then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                if dist < shortest and dist < 200 then
                    shortest = dist
                    target = p
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            if not ESPObjects[p] then
                createESP(p)
                drawSkeleton(p)
            end
            local obj = ESPObjects[p]
            if obj.update then obj.update() end
            if obj.ske then obj.ske() end
        end
    end

    if aimToggle() then
        AimTarget = getClosest()
        if AimTarget and AimTarget.Character and AimTarget.Character:FindFirstChild("Head") then
            local head = AimTarget.Character.Head.Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head)
        end
    end
end)
-- Creat By QuanCheaterVn

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Mouse = LP:GetMouse()

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanCheaterUI"
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 120, 0, 30)
toggleBtn.Position = UDim2.new(0, 20, 0, 60)
toggleBtn.Text = "Toggle Menu"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.TextSize = 14

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 440)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Visible = true
frame.Active = true
frame.Draggable = true

toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

local title = Instance.new("TextLabel", frame)
title.Text = "QuanCheaterVN"
title.Size = UDim2.new(1, 0, 0, 36)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1


local tabs = { "ESP", "Mem/S&F" }
local tabFrames = {}
for i, name in ipairs(tabs) do
    local tb = Instance.new("TextButton", frame)
    tb.Text = name
    tb.Size = UDim2.new(0, 140, 0, 30)
    tb.Position = UDim2.new(0, (i-1)*150+10, 0, 40)
    tb.Font = Enum.Font.Gotham
    tb.TextSize = 14
    tb.BackgroundColor3 = Color3.fromRGB(50,50,50)
    tb.TextColor3 = Color3.new(1,1,1)

    tabFrames[name] = Instance.new("Frame", frame)
    tabFrames[name].Size = UDim2.new(1, -20, 1, -80)
    tabFrames[name].Position = UDim2.new(0, 10, 0, 80)
    tabFrames[name].Visible = false

    tb.MouseButton1Click:Connect(function()
        for _, f in pairs(tabFrames) do f.Visible = false end
        tabFrames[name].Visible = true
    end)
end
tabFrames["ESP"].Visible = true

local function addToggle(parent, name, y)
    local s = false
    local b = Instance.new("TextButton", parent)
    b.Text = name .. ": OFF"
    b.Size = UDim2.new(0, 280, 0, 30)
    b.Position = UDim2.new(0, 10, 0, y)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.MouseButton1Click:Connect(function()
        s = not s
        b.Text = name .. ": " .. (s and "ON" or "OFF")
    end)
    return function() return s end
end


local espToggle = addToggle(tabFrames["ESP"], "ESP Master", 10)
local itemToggle = addToggle(tabFrames["ESP"], "Item ESP", 50)
local mobToggle = addToggle(tabFrames["ESP"], "Mob ESP", 90)
local itemPickToggle = addToggle(tabFrames["ESP"], "Item Pick ESP", 130)
local aimbotToggle = addToggle(tabFrames["ESP"], "Aimbot Lock", 170)
local fovToggle = addToggle(tabFrames["ESP"], "Draw FOV", 210)
local speedToggle = addToggle(tabFrames["Mem/S&F"], "Speed Hack", 10)
local flyToggle = addToggle(tabFrames["Mem/S&F"], "Fly", 50)

local ESPdata, Items, Mobs, ItemPick = {}, {}, {}, {}
local skeletonLines = { {1,2},{2,3},{3,4},{4,5},{2,6},{6,7},{3,8},{8,9},{3,10},{10,11} }

local function getJoints(c)
    local parts = {
        c:FindFirstChild("Head"), c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso"),
        c:FindFirstChild("LowerTorso") or c:FindFirstChild("Torso"),
        c:FindFirstChild("LeftUpperArm"), c:FindFirstChild("LeftLowerArm"),
        c:FindFirstChild("RightUpperArm"), c:FindFirstChild("RightLowerArm"),
        c:FindFirstChild("LeftUpperLeg"), c:FindFirstChild("LeftLowerLeg"),
        c:FindFirstChild("RightUpperLeg"), c:FindFirstChild("RightLowerLeg")
    }
    local pos = {}
    for i, pr in ipairs(parts) do
        if pr then
            local sp, on = Camera:WorldToViewportPoint(pr.Position)
            if on then pos[i] = Vector2.new(sp.X, sp.Y) end
        end
    end
    return pos
end

local function initESP(p)
    local box = Drawing.new("Square")
    box.Thickness = 1 box.Filled = false box.Color = Color3.fromRGB(255, 0, 0)
    local line = Drawing.new("Line") line.Thickness = 1 line.Color = Color3.fromRGB(255, 255, 0)
    local name = Drawing.new("Text") name.Size = 13 name.Color = Color3.fromRGB(0, 255, 0) name.Center = true name.Outline = true
    local hp = Drawing.new("Text") hp.Size = 13 hp.Color = Color3.fromRGB(255, 255, 255) hp.Center = true hp.Outline = true
    local skl = {} for i = 1, 10 do skl[i] = Drawing.new("Line") skl[i].Color = Color3.fromRGB(0, 255, 255) skl[i].Thickness = 1 end
    ESPdata[p] = { box = box, line = line, name = name, hp = hp, skeleton = skl }
end


local FovCircle = Drawing.new("Circle")
FovCircle.Color = Color3.fromRGB(0,255,0)
FovCircle.Thickness = 1
FovCircle.Radius = 100
FovCircle.Filled = false

local function getClosestTarget()
    local closest, minDist = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local sp, on = Camera:WorldToViewportPoint(hrp.Position)
            local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
            if on and dist < FovCircle.Radius and dist < minDist then
                closest = hrp
                minDist = dist
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Position = center
    FovCircle.Visible = fovToggle()

    if speedToggle() and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = 200
    end
    if flyToggle() and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.Velocity = Vector3.new(0, 50, 0)
    end
    
for _, t in pairs(Items) do t.Visible = false end
if itemToggle() then
    for _, o in pairs(workspace:GetDescendants()) do
        if o:IsA("Tool") or o:IsA("Part") then
            if not Items[o] then
                local ii = Drawing.new("Text")
                ii.Size = 13
                ii.Color = Color3.new(1, 1, 1)
                ii.Center = true
                ii.Outline = true
                Items[o] = ii
            end
            local sp, on = Camera:WorldToViewportPoint(o.Position)
            Items[o].Position = Vector2.new(sp.X, sp.Y)
            Items[o].Text = o.Name
            Items[o].Visible = on
        end
    end
end


for _, t in pairs(ItemPick) do t.Visible = false end
if itemPickToggle() then
    for _, o in pairs(workspace:GetDescendants()) do
        if (o:IsA("Part") or o:IsA("Model")) and (o:FindFirstChildWhichIsA("ProximityPrompt") or o:FindFirstChildWhichIsA("ClickDetector")) then
            if not ItemPick[o] then
                local txt = Drawing.new("Text")
                txt.Size = 13
                txt.Color = Color3.fromRGB(0, 255, 255)
                txt.Center = true
                txt.Outline = true
                ItemPick[o] = txt
            end
            local pos = o:IsA("Model") and o:FindFirstChild("PrimaryPart") or o
            if pos and pos.Position then
                local sp, on = Camera:WorldToViewportPoint(pos.Position)
                ItemPick[o].Position = Vector2.new(sp.X, sp.Y)
                ItemPick[o].Text = "[Pick] " .. o.Name
                ItemPick[o].Visible = on
            end
        end
    end
end



if aimbotToggle() then
    local target = nil
    local closest, minDist = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local sp, on = Camera:WorldToViewportPoint(hrp.Position)
                local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                if on and dist < FovCircle.Radius and dist < minDist then
                    closest = hrp
                    minDist = dist
                end
            end
        end
    end

    if closest then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
    end
end

    if espToggle() then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") then
                if not ESPdata[p] then initESP(p) end
                local ed = ESPdata[p]
                local c = p.Character
                local hrp = c:FindFirstChild("HumanoidRootPart")
                local hum = c:FindFirstChild("Humanoid")
                if hrp and hum then
                    local sp, on = Camera:WorldToViewportPoint(hrp.Position)
                    if on then
                        local sy = math.clamp(2000 / (hrp.Position - Camera.CFrame.Position).Magnitude, 30, 200)
                        local sx = sy / 2
                        ed.box.Position = Vector2.new(sp.X - sx / 2, sp.Y - sy / 2)
                        ed.box.Size = Vector2.new(sx, sy)
                        ed.box.Visible = true
                        ed.line.From = center
                        ed.line.To = Vector2.new(sp.X, sp.Y)
                        ed.line.Visible = true
                        ed.name.Position = Vector2.new(sp.X, sp.Y - sy / 2 - 15)
                        ed.name.Text = p.Name
                        ed.name.Visible = true
                        ed.hp.Position = Vector2.new(sp.X, sp.Y - sy / 2 - 30)
                        ed.hp.Text = "HP:" .. math.floor(hum.Health)
                        ed.hp.Visible = true
                        local joints = getJoints(c)
                        for i, pair in ipairs(skeletonLines) do
                            local a = joints[pair[1]]
                            local b = joints[pair[2]]
                            local sl = ed.skeleton[i]
                            if a and b then
                                sl.From = a sl.To = b sl.Visible = true
                            else sl.Visible = false end
                        end
                    end
                end
            end
        end
    end
end)


Players.PlayerRemoving:Connect(function(p)
    ESPdata[p] = nil
end)
for _, v in pairs(getconnections(LP.Idled)) do v:Disable() end
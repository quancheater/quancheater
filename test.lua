local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- Create main GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanCheaterUI"

-- Main toggle button
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 120, 0, 30)
toggleBtn.Position = UDim2.new(0, 20, 0, 60)
toggleBtn.Text = "Toggle Menu"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.BorderSizePixel = 0

-- Main frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 400)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.Active = true
frame.Draggable = true
frame.Visible = false

-- Title bar
local titleBar = Instance.new("Frame", frame)
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 120, 215)

local title = Instance.new("TextLabel", titleBar)
title.Text = "QuanCheaterVN"
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left

toggleBtn.MouseButton1Click:Connect(function() 
    frame.Visible = not frame.Visible
end)

-- Tab system
local tabs = {"ESP", "Player", "Mem/S&F"}
local tabFrames = {}

-- Tab buttons container
local tabButtons = Instance.new("Frame", frame)
tabButtons.Size = UDim2.new(1, -20, 0, 30)
tabButtons.Position = UDim2.new(0, 10, 0, 40)
tabButtons.BackgroundTransparency = 1

for i, name in ipairs(tabs) do
    local tb = Instance.new("TextButton", tabButtons)
    tb.Text = name
    tb.Size = UDim2.new(0.33, -5, 1, 0)
    tb.Position = UDim2.new((i-1)*0.33, 0, 0, 0)
    tb.Font = Enum.Font.GothamBold
    tb.TextSize = 14
    tb.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    tb.TextColor3 = Color3.new(1, 1, 1)
    tb.BorderSizePixel = 0
    
    tabFrames[name] = Instance.new("Frame", frame)
    tabFrames[name].Size = UDim2.new(1, -20, 1, -90)
    tabFrames[name].Position = UDim2.new(0, 10, 0, 80)
    tabFrames[name].Visible = false
    tabFrames[name].BackgroundTransparency = 1
    
    tb.MouseButton1Click:Connect(function()
        for _, f in pairs(tabFrames) do f.Visible = false end
        tabFrames[name].Visible = true
        -- Update button colors
        for _, btn in ipairs(tabButtons:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = btn == tb and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(50, 50, 70)
            end
        end
    end)
end

-- Set first tab as active
tabFrames[tabs[1]].Visible = true
tabButtons:GetChildren()[1].BackgroundColor3 = Color3.fromRGB(0, 120, 215)

-- Improved toggle function
local function addToggle(parent, name, y, default)
    local s = default or false
    local toggleFrame = Instance.new("Frame", parent)
    toggleFrame.Size = UDim2.new(1, -20, 0, 30)
    toggleFrame.Position = UDim2.new(0, 10, 0, y)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    
    local toggleLabel = Instance.new("TextLabel", toggleFrame)
    toggleLabel.Text = name
    toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    toggleLabel.Position = UDim2.new(0, 10, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextSize = 14
    toggleLabel.TextColor3 = Color3.new(1, 1, 1)
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleBtn = Instance.new("TextButton", toggleFrame)
    toggleBtn.Text = s and "ON" or "OFF"
    toggleBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
    toggleBtn.Position = UDim2.new(0.7, 5, 0.15, 0)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.BackgroundColor3 = s and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.BorderSizePixel = 0
    
    toggleBtn.MouseButton1Click:Connect(function()
        s = not s
        toggleBtn.Text = s and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = s and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
    end)
    
    return function() return s end
end

-- ESP Tab
local espMasterToggle = addToggle(tabFrames["ESP"], "ESP Master", 10, true)
local playerEspToggle = addToggle(tabFrames["ESP"], "Player ESP", 50, true)
local itemEspToggle = addToggle(tabFrames["ESP"], "Item ESP (Pickable)", 90, true)
local itemObjEspToggle = addToggle(tabFrames["ESP"], "Item ESP (Objects)", 130, false)
local mobEspToggle = addToggle(tabFrames["ESP"], "Mob ESP", 170, true)
local skeletonToggle = addToggle(tabFrames["ESP"], "Skeleton", 210, true)
local distanceToggle = addToggle(tabFrames["ESP"], "Show Distance", 250, true)
local healthToggle = addToggle(tabFrames["ESP"], "Show Health", 290, true)

-- Player Tab
local teleportList = Instance.new("Frame", tabFrames["Player"])
teleportList.Size = UDim2.new(1, 0, 1, -40)
teleportList.Position = UDim2.new(0, 0, 0, 0)
teleportList.BackgroundTransparency = 1

local teleportTitle = Instance.new("TextLabel", tabFrames["Player"])
teleportTitle.Text = "Teleport to Player:"
teleportTitle.Size = UDim2.new(1, 0, 0, 20)
teleportTitle.Position = UDim2.new(0, 0, 0, 0)
teleportTitle.BackgroundTransparency = 1
teleportTitle.Font = Enum.Font.GothamBold
teleportTitle.TextSize = 16
teleportTitle.TextColor3 = Color3.new(1, 1, 1)
teleportTitle.TextXAlignment = Enum.TextXAlignment.Left

local function updatePlayerList()
    for _, child in ipairs(teleportList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local yPos = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            local playerBtn = Instance.new("TextButton", teleportList)
            playerBtn.Text = player.Name
            playerBtn.Size = UDim2.new(1, -10, 0, 30)
            playerBtn.Position = UDim2.new(0, 5, 0, yPos)
            playerBtn.Font = Enum.Font.Gotham
            playerBtn.TextSize = 14
            playerBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            playerBtn.TextColor3 = Color3.new(1, 1, 1)
            playerBtn.BorderSizePixel = 0
            
            playerBtn.MouseButton1Click:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
                   LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    LP.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                end
            end)
            
            yPos = yPos + 35
        end
    end
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

-- Mem/S&F Tab - KEEPING ORIGINAL SPEED AND FLY FUNCTIONS
local speedToggle = addToggle(tabFrames["Mem/S&F"], "Speed Hack", 10)
local flyToggle = addToggle(tabFrames["Mem/S&F"], "Fly", 50)
local noclipToggle = addToggle(tabFrames["Mem/S&F"], "Noclip", 90)
local infJumpToggle = addToggle(tabFrames["Mem/S&F"], "Infinite Jump", 130)
local enemyCountLabel = Instance.new("TextLabel", tabFrames["Mem/S&F"])
enemyCountLabel.Text = "Enemies Nearby: 0"
enemyCountLabel.Size = UDim2.new(1, -20, 0, 30)
enemyCountLabel.Position = UDim2.new(0, 10, 0, 170)
enemyCountLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
enemyCountLabel.Font = Enum.Font.Gotham
enemyCountLabel.TextSize = 14
enemyCountLabel.TextColor3 = Color3.new(1, 1, 1)

-- ESP Data
local ESPdata, PickableItems, ObjectItems, Mobs = {}, {}, {}, {}
local enemyCount = 0

local function initESP(p)
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Color = Color3.fromRGB(0, 180, 255)
    box.Visible = false
    
    local line = Drawing.new("Line")
    line.Thickness = 1
    line.Color = Color3.fromRGB(255, 255, 0)
    line.Visible = false
    
    local name = Drawing.new("Text")
    name.Size = 13
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Center = true
    name.Outline = true
    name.Visible = false
    
    local hp = Drawing.new("Text")
    hp.Size = 13
    hp.Color = Color3.fromRGB(255, 50, 50)
    hp.Center = true
    hp.Outline = true
    hp.Visible = false
    
    local distance = Drawing.new("Text")
    distance.Size = 13
    distance.Color = Color3.fromRGB(200, 200, 200)
    distance.Center = true
    distance.Outline = true
    distance.Visible = false
    
    local skl = {}
    for i = 1, #skeletonLines do
        skl[i] = Drawing.new("Line")
        skl[i].Color = Color3.fromRGB(0, 255, 255)
        skl[i].Thickness = 1
        skl[i].Visible = false
    end
    
    ESPdata[p] = {
        box = box,
        line = line,
        name = name,
        hp = hp,
        distance = distance,
        skeleton = skl,
        lastUpdate = 0
    }
end

local skeletonLines = {
    {1, 2}, {2, 3}, {3, 4}, {4, 5},    -- Head to Right Arm
    {2, 6}, {6, 7},                     -- Torso to Left Arm
    {3, 8}, {8, 9},                     -- Torso to Right Leg
    {3, 10}, {10, 11}                   -- Torso to Left Leg
}

local function getJoints(c)
    local parts = {
        c:FindFirstChild("Head"),
        c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso"),
        c:FindFirstChild("HumanoidRootPart"),
        c:FindFirstChild("RightUpperArm"),
        c:FindFirstChild("RightLowerArm"),
        c:FindFirstChild("LeftUpperArm"),
        c:FindFirstChild("LeftLowerArm"),
        c:FindFirstChild("RightUpperLeg"),
        c:FindFirstChild("RightLowerLeg"),
        c:FindFirstChild("LeftUpperLeg"),
        c:FindFirstChild("LeftLowerLeg")
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

-- Infinite Jump
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if infJumpToggle() and input.KeyCode == Enum.KeyCode.Space and LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Main loop
RunService.RenderStepped:Connect(function(delta)
    -- ORIGINAL SPEED HACK (kept as you requested)
    if speedToggle() and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = 200
    end
    
    -- ORIGINAL FLY HACK (kept as you requested)
    if flyToggle() and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.Velocity = Vector3.new(0, 50, 0)
    end
    
    -- Noclip
    if noclipToggle() and LP.Character then
        for _, part in ipairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- ESP Master toggle
    if espMasterToggle() then
        -- Player ESP
        if playerEspToggle() then
            enemyCount = 0
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
                            enemyCount = enemyCount + 1
                            
                            local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
                            local sy = math.clamp(2000 / distance, 30, 200)
                            local sx = sy / 2
                            
                            ed.box.Position = Vector2.new(sp.X - sx/2, sp.Y - sy/2)
                            ed.box.Size = Vector2.new(sx, sy)
                            ed.box.Visible = true
                            
                            ed.line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                            ed.line.To = Vector2.new(sp.X, sp.Y)
                            ed.line.Visible = true
                            
                            ed.name.Position = Vector2.new(sp.X, sp.Y - sy/2 - 15)
                            ed.name.Text = p.Name
                            ed.name.Visible = true
                            
                            if healthToggle() then
                                ed.hp.Position = Vector2.new(sp.X, sp.Y - sy/2 - 30)
                                ed.hp.Text = "HP: "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
                                ed.hp.Visible = true
                            else
                                ed.hp.Visible = false
                            end
                            
                            if distanceToggle() then
                                ed.distance.Position = Vector2.new(sp.X, sp.Y + sy/2 + 5)
                                ed.distance.Text = math.floor(distance).."m"
                                ed.distance.Visible = true
                            else
                                ed.distance.Visible = false
                            end
                            
                            if skeletonToggle() then
                                local joints = getJoints(c)
                                for i, pair in ipairs(skeletonLines) do
                                    local a = joints[pair[1]]
                                    local b = joints[pair[2]]
                                    local sl = ed.skeleton[i]
                                    if a and b then
                                        sl.From = a
                                        sl.To = b
                                        sl.Visible = true
                                    else
                                        sl.Visible = false
                                    end
                                end
                            else
                                for _, sl in ipairs(ed.skeleton) do sl.Visible = false end
                            end
                        else
                            ed.box.Visible = false
                            ed.line.Visible = false
                            ed.name.Visible = false
                            ed.hp.Visible = false
                            ed.distance.Visible = false
                            for _, sl in ipairs(ed.skeleton) do sl.Visible = false end
                        end
                    end
                end
            end
            enemyCountLabel.Text = "Enemies Nearby: "..enemyCount
        else
            for _, ed in pairs(ESPdata) do
                ed.box.Visible = false
                ed.line.Visible = false
                ed.name.Visible = false
                ed.hp.Visible = false
                ed.distance.Visible = false
                for _, sl in ipairs(ed.skeleton) do sl.Visible = false end
            end
            enemyCountLabel.Text = "Enemies Nearby: 0"
        end
        
        -- Item ESP (Pickable)
        if itemEspToggle() then
            for _, o in pairs(workspace:GetDescendants()) do
                if o:IsA("Tool") or (o:IsA("BasePart") and o:FindFirstChildWhichIsA("ClickDetector")) then
                    if not PickableItems[o] then
                        local ii = Drawing.new("Text")
                        ii.Size = 13
                        ii.Color = Color3.fromRGB(0, 255, 0) -- Green for pickable items
                        ii.Center = true
                        ii.Outline = true
                        PickableItems[o] = ii
                    end
                    
                    local sp, on = Camera:WorldToViewportPoint(o.Position)
                    if on then
                        PickableItems[o].Position = Vector2.new(sp.X, sp.Y)
                        PickableItems[o].Text = o.Name
                        PickableItems[o].Visible = true
                    else
                        PickableItems[o].Visible = false
                    end
                end
            end
        else
            for _, item in pairs(PickableItems) do
                item.Visible = false
            end
        end
        
        -- Item ESP (Objects)
        if itemObjEspToggle() then
            for _, o in pairs(workspace:GetDescendants()) do
                if o:IsA("BasePart") and not o:FindFirstChildWhichIsA("ClickDetector") and not o:IsDescendantOf(LP.Character) then
                    if not ObjectItems[o] then
                        local ii = Drawing.new("Text")
                        ii.Size = 13
                        ii.Color = Color3.fromRGB(255, 165, 0) -- Orange for objects
                        ii.Center = true
                        ii.Outline = true
                        ObjectItems[o] = ii
                    end
                    
                    local sp, on = Camera:WorldToViewportPoint(o.Position)
                    if on then
                        ObjectItems[o].Position = Vector2.new(sp.X, sp.Y)
                        ObjectItems[o].Text = o.Name
                        ObjectItems[o].Visible = true
                    else
                        ObjectItems[o].Visible = false
                    end
                end
            end
        else
            for _, item in pairs(ObjectItems) do
                item.Visible = false
            end
        end
        
        -- Mob ESP
        if mobEspToggle() then
            for _, o in pairs(workspace:GetDescendants()) do
                if o:IsA("Model") and o:FindFirstChild("Humanoid") and o ~= LP.Character then
                    if not Mobs[o] then
                        local mm = Drawing.new("Text")
                        mm.Size = 13
                        mm.Color = Color3.fromRGB(255, 50, 50)
                        mm.Center = true
                        mm.Outline = true
                        Mobs[o] = mm
                    end
                    
                    local hrp = o:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local sp, on = Camera:WorldToViewportPoint(hrp.Position)
                        if on then
                            Mobs[o].Position = Vector2.new(sp.X, sp.Y)
                            Mobs[o].Text = o.Name
                            Mobs[o].Visible = true
                        else
                            Mobs[o].Visible = false
                        end
                    end
                end
            end
        else
            for _, mob in pairs(Mobs) do
                mob.Visible = false
            end
        end
    else
        -- Clear all ESP if master is off
        for _, ed in pairs(ESPdata) do
            ed.box.Visible = false
            ed.line.Visible = false
            ed.name.Visible = false
            ed.hp.Visible = false
            ed.distance.Visible = false
            for _, sl in ipairs(ed.skeleton) do sl.Visible = false end
        end
        
        for _, item in pairs(PickableItems) do
            item.Visible = false
        end
        
        for _, item in pairs(ObjectItems) do
            item.Visible = false
        end
        
        for _, mob in pairs(Mobs) do
            mob.Visible = false
        end
        
        enemyCountLabel.Text = "Enemies Nearby: 0"
    end
end)

-- Clean up when players leave
Players.PlayerRemoving:Connect(function(p)
    if ESPdata[p] then
        for _, drawing in pairs(ESPdata[p]) do
            drawing:Remove()
        end
        ESPdata[p] = nil
    end
end)

-- Clean up when items are removed
workspace.DescendantRemoving:Connect(function(desc)
    if PickableItems[desc] then
        PickableItems[desc]:Remove()
        PickableItems[desc] = nil
    end
    
    if ObjectItems[desc] then
        ObjectItems[desc]:Remove()
        ObjectItems[desc] = nil
    end
    
    if Mobs[desc] then
        Mobs[desc]:Remove()
        Mobs[desc] = nil
    end
end)

-- Anti-AFK
for _, v in pairs(getconnections(LP.Idled)) do 
    v:Disable()
end
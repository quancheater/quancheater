local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- GUI setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanCheaterUI"
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 120, 0, 30)
toggleBtn.Position = UDim2.new(0, 20, 0, 60)
toggleBtn.Text = "Toggle Menu"
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.TextSize = 14
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
toggleBtn.TextColor3 = Color3.new(1,1,1)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 480)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Active = true
frame.Draggable = true

toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- Title & tabs
local title = Instance.new("TextLabel", frame)
title.Text = "QuanCheaterVN"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.new(1,1,1)

local tabs = {"ESP", "Base & Spawn", "Mem/S&F"}
local tabFrames = {}
local activeTab = "ESP"

for i,name in ipairs(tabs) do
    local tb = Instance.new("TextButton", frame)
    tb.Text = name
    tb.Size = UDim2.new(0,90,0,30)
    tb.Position = UDim2.new(0,(i-1)*100+10,0,50)
    tb.Font = Enum.Font.Gotham
    tb.TextSize = 14
    tb.BackgroundColor3 = Color3.fromRGB(50,50,50)
    tb.TextColor3 = Color3.new(1,1,1)

    tabFrames[name] = Instance.new("Frame", frame)
    tabFrames[name].Size = UDim2.new(1,-20,1,-90)
    tabFrames[name].Position = UDim2.new(0,10,0,90)
    tabFrames[name].Visible = false

    tb.MouseButton1Click:Connect(function()
        for _,f in pairs(tabFrames) do f.Visible = false end
        tabFrames[name].Visible = true
        activeTab = name
    end)
end
tabFrames["ESP"].Visible = true

-- Create toggles
local function addToggle(parent, name, posY)
    local on = false
    local btn = Instance.new("TextButton", parent)
    btn.Text = name..": OFF"
    btn.Size = UDim2.new(0,260,0,30)
    btn.Position = UDim2.new(0,10,0,posY)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = name..": "..(on and "ON" or "OFF")
    end)
    return function() return on end
end

-- Tabs' toggles
local espMaster = addToggle(tabFrames["ESP"], "ESP Master", 10)
local itemESP   = addToggle(tabFrames["ESP"], "Item ESP", 50)
local mobESP    = addToggle(tabFrames["ESP"], "Mob ESP", 90)

local baseFrame = tabFrames["Base & Spawn"]
local spawnC = nil
local setSpawnBtn = Instance.new("TextButton", baseFrame)
setSpawnBtn.Text, setSpawnBtn.Size, setSpawnBtn.Position = "Set Spawn", UDim2.new(0,260,0,30), UDim2.new(0,10,0,10)
setSpawnBtn.Font, setSpawnBtn.TextSize, setSpawnBtn.BackgroundColor3 = Enum.Font.Gotham, 14, Color3.fromRGB(40,40,40)
setSpawnBtn.MouseButton1Click:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        spawnC = LP.Character.HumanoidRootPart.CFrame
    end
end)

local gotoSpawnBtn = Instance.new("TextButton", baseFrame)
gotoSpawnBtn.Text, gotoSpawnBtn.Size, gotoSpawnBtn.Position = "Teleport to Spawn", UDim2.new(0,260,0,30), UDim2.new(0,10,0,50)
gotoSpawnBtn.Font, gotoSpawnBtn.TextSize, gotoSpawnBtn.BackgroundColor3 = Enum.Font.Gotham, 14, Color3.fromRGB(40,40,40)
gotoSpawnBtn.MouseButton1Click:Connect(function()
    if spawnC and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = spawnC
    end
end)

local gotoBaseBtn = Instance.new("TextButton", baseFrame)
gotoBaseBtn.Text, gotoBaseBtn.Size, gotoBaseBtn.Position = "Teleport to Base", UDim2.new(0,260,0,30), UDim2.new(0,10,0,90)
gotoBaseBtn.Font, gotoBaseBtn.TextSize, gotoBaseBtn.BackgroundColor3 = Enum.Font.Gotham, 14, Color3.fromRGB(40,40,40)
gotoBaseBtn.MouseButton1Click:Connect(function()
    local b = workspace:FindFirstChild("Base")
    if b and b:IsA("BasePart") then
        LP.Character.HumanoidRootPart.CFrame = b.CFrame
    end
end)

local memFrame = tabFrames["Mem/S&F"]
local speedToggle = addToggle(memFrame, "Speed Hack", 10)
local flyToggle   = addToggle(memFrame, "Fly", 50)
local ghostToggle = addToggle(memFrame, "Ghost Mode", 90)

-- Drawing tables
local ESPdata, Items, Mobs = {}, {}, {}

-- ESP initialize
local function initPlayerESP(p)
    local box = Drawing.new("Square"); box.Thickness=1; box.Filled=false; box.Color=Color3.new(1,0,0)
    local line = Drawing.new("Line");   line.Thickness=1; line.Color=Color3.new(1,1,0)
    local name = Drawing.new("Text");   name.Size=13; name.Color=Color3.new(0,1,0); name.Center=true; name.Outline=true
    local hp   = Drawing.new("Text");   hp.Size=13; hp.Color=Color3.new(1,1,1); hp.Center=true; hp.Outline=true
    local sklLines = {}
    for i=1,5 do sklLines[i] = Drawing.new("Line"); sklLines[i].Color = Color3.new(0,1,1); sklLines[i].Thickness=1 end
    ESPdata[p] = {box=box,line=line,name=name,hp=hp,skeleton=sklLines}
end

-- Skeleton joint pairs
local sklPairs = {{1,2},{2,3},{2,4},{4,5}}

-- Get joint positions
local function getJointsPOS(char)
    local parts = {char:FindFirstChild("Head"), char:FindFirstChild("UpperTorso"), char:FindFirstChild("HumanoidRootPart"),
                   char:FindFirstChild("LeftUpperArm"), char:FindFirstChild("LeftLowerArm")}
    local pos = {}
    for i,part in ipairs(parts) do
        if part then
            local sp,ok = Camera:WorldToViewportPoint(part.Position)
            if ok then pos[i] = Vector2.new(sp.X,sp.Y) end
        end
    end
    return pos
end

-- Main update loop
RunService.RenderStepped:Connect(function()
    -- Speed / Ghost / Fly
    if speedToggle() and LP.Character then
        local hum = LP.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed=100 end
    end
    if ghostToggle() and LP.Character then
        for _,pt in pairs(LP.Character:GetDescendants()) do
            if pt:IsA("BasePart") then pt.CanCollide=false; pt.Transparency=1 end
        end
    end
    if flyToggle() and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.Velocity = Vector3.new(0,50,0)
    end

    -- ESP Player
    if espMaster() then
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") then
                if not ESPdata[p] then initPlayerESP(p) end
                local data = ESPdata[p]
                local char = p.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChild("Humanoid")
                if hrp and head and hum then
                    local sp,ok = Camera:WorldToViewportPoint(hrp.Position)
                    if ok then
                        local sizeY = math.clamp(2000/(hrp.Position - Camera.CFrame.Position).Magnitude, 30, 200)
                        local sizeX = sizeY/2
                        data.box.Position=Vector2.new(sp.X-sizeX/2,sp.Y-sizeY/2)
                        data.box.Size=Vector2.new(sizeX,sizeY)
                        data.box.Visible = true
                        data.line.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
                        data.line.To=Vector2.new(sp.X,sp.Y)
                        data.line.Visible = true
                        data.name.Position=Vector2.new(sp.X,sp.Y-sizeY/2-15)
                        data.name.Text=p.Name
                        data.name.Visible = true
                        data.hp.Position=Vector2.new(sp.X, sp.Y-sizeY/2-30)
                        data.hp.Text="HP:"..math.floor(hum.Health)
                        data.hp.Visible = true
                        -- Skeleton
                        local joints = getJointsPOS(char)
                        for i, pair in ipairs(sklPairs) do
                            local a,jb = joints[pair[1]], joints[pair[2]]
                            local sl = data.skeleton[i]
                            if a and jb then
                                sl.From = a; sl.To = jb; sl.Visible = true
                            else
                                sl.Visible = false
                            end
                        end
                    else
                        -- hide
                        data.box.Visible=false; data.line.Visible=false
                        data.name.Visible=false; data.hp.Visible=false
                        for _,sl in ipairs(data.skeleton) do sl.Visible=false end
                    end
                end
            end
        end
    else
        -- hide all
        for _,data in pairs(ESPdata) do
            data.box.Visible=false; data.line.Visible=false
            data.name.Visible=false; data.hp.Visible=false
            for _,sl in ipairs(data.skeleton) do sl.Visible=false end
        end
    end

    -- ESP Item
    for _,t in pairs(Items) do t.Visible=false end
    if itemESP() then
        for _,o in pairs(workspace:GetDescendants()) do
            if (o:IsA("Tool") or o:IsA("Part")) then
                if not Items[o] then
                    local it = Drawing.new("Text")
                    it.Size=13; it.Color=Color3.new(1,1,1); it.Center=true; it.Outline=true; Items[o]=it
                end
                local sp,ok=Camera:WorldToViewportPoint(o.Position)
                Items[o].Position=Vector2.new(sp.X,sp.Y)
                Items[o].Text=o.Name
                Items[o].Visible=ok
            end
        end
    end

    -- ESP Mob
    for _,t in pairs(Mobs) do t.Visible=false end
    if mobESP() then
        for _,o in pairs(workspace:GetDescendants()) do
            if o:IsA("Model") and o:FindFirstChild("Humanoid") and o ~= LP.Character then
                if not Mobs[o] then
                    local m = Drawing.new("Text")
                    m.Size=13; m.Color=Color3.fromRGB(1,0.4,0.4); m.Center=true; m.Outline=true; Mobs[o]=m
                end
                local hrp=o:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local sp,ok=Camera:WorldToViewportPoint(hrp.Position)
                    Mobs[o].Position=Vector2.new(sp.X,sp.Y)
                    Mobs[o].Text=o.Name
                    Mobs[o].Visible=ok
                end
            end
        end
    end
end)

-- clean ESP on player leave
Players.PlayerRemoving:Connect(function(pl)
    local data=ESPdata[pl]
    if data then
        data.box:Remove(); data.line:Remove()
        data.name:Remove(); data.hp:Remove()
        for _,sl in ipairs(data.skeleton) do sl:Remove() end
        ESPdata[pl]=nil
    end
end)

-- disable AFK
for _,v in pairs(getconnections(LP.Idled)) do v:Disable() end
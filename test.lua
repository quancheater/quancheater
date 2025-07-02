local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanCheaterUI"

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 550)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Visible = true
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel", frame)
title.Text = "QuanCheaterVN"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local toggles = {}

local function makeToggle(name, y)
    local b = Instance.new("TextButton", frame)
    b.Text = name .. ": OFF"
    b.Size = UDim2.new(0, 240, 0, 30)
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
    toggles[name] = function() return state end
    return state
end

-- All toggles
makeToggle("ESP", 40)
makeToggle("Line", 80)
makeToggle("Name", 120)
makeToggle("Skeleton", 160)
makeToggle("Aimbot", 200)
makeToggle("Item ESP", 240)
makeToggle("Mob ESP", 280)
makeToggle("Kill Aura", 320)
makeToggle("Fly", 360)
makeToggle("Hack Money", 400)
makeToggle("Auto Farm", 440)

-- Dump Game button
local dump = Instance.new("TextButton", frame)
dump.Text = "Dump Game"
dump.Size = UDim2.new(0, 240, 0, 30)
dump.Position = UDim2.new(0, 10, 0, 480)
dump.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
dump.TextColor3 = Color3.fromRGB(255, 255, 255)
dump.Font = Enum.Font.Gotham
dump.TextSize = 14

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local ESP, Items, NPCs = {}, {}, {}

dump.MouseButton1Click:Connect(function()
    local function deep(obj, t)
        local s = string.rep("  ", t) .. obj.Name .. " [" .. obj.ClassName .. "]\n"
        for _, c in ipairs(obj:GetChildren()) do
            s = s .. deep(c, t + 1)
        end
        return s
    end
    writefile("QuanDump.txt", deep(game, 0))
end)

function createBox(name, color)
    local d = Drawing.new("Text")
    d.Size = 13
    d.Color = color
    d.Center = true
    d.Outline = true
    d.Text = name
    d.Visible = false
    return d
end

function espPlayer(p)
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
    ESP[p] = {box = box, line = line, text = text}
end

function updateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            if not ESP[p] then espPlayer(p) end
            local e = ESP[p]
            local c = p.Character
            if c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChild("Head") then
                local pos, on = Camera:WorldToViewportPoint(c.HumanoidRootPart.Position)
                if on then
                    local sY = math.clamp(2000 / (c.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude, 30, 200)
                    local sX = sY / 2
                    e.box.Size = Vector2.new(sX, sY)
                    e.box.Position = Vector2.new(pos.X - sX / 2, pos.Y - sY / 2)
                    e.box.Visible = toggles["ESP"]()
                    e.line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    e.line.To = Vector2.new(pos.X, pos.Y)
                    e.line.Visible = toggles["Line"]()
                    e.text.Position = Vector2.new(pos.X, pos.Y - sY / 2 - 10)
                    e.text.Text = p.Name
                    e.text.Visible = toggles["Name"]()
                else
                    e.box.Visible = false
                    e.line.Visible = false
                    e.text.Visible = false
                end
            else
                e.box.Visible = false
                e.line.Visible = false
                e.text.Visible = false
            end
        end
    end
end

function updateItem()
    if not toggles["Item ESP"]() then for _,v in pairs(Items) do v.Visible = false end return end
    for _, o in pairs(workspace:GetDescendants()) do
        if o:IsA("Tool") or o:IsA("Part") then
            if not Items[o] then
                Items[o] = createBox(o.Name, Color3.fromRGB(255, 255, 255))
            end
            local screen, visible = Camera:WorldToViewportPoint(o.Position)
            if visible then
                Items[o].Position = Vector2.new(screen.X, screen.Y)
                Items[o].Text = o.Name
                Items[o].Visible = true
            else
                Items[o].Visible = false
            end
        end
    end
end

function updateMob()
    if not toggles["Mob ESP"]() then for _,v in pairs(NPCs) do v.Visible = false end return end
    for _, o in pairs(workspace:GetDescendants()) do
        if o:IsA("Model") and o:FindFirstChild("Humanoid") and o ~= LP.Character then
            if not NPCs[o] then
                NPCs[o] = createBox(o.Name, Color3.fromRGB(255, 100, 100))
            end
            local hrp = o:FindFirstChild("HumanoidRootPart")
            if hrp then
                local screen, visible = Camera:WorldToViewportPoint(hrp.Position)
                if visible then
                    NPCs[o].Position = Vector2.new(screen.X, screen.Y)
                    NPCs[o].Visible = true
                else
                    NPCs[o].Visible = false
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    updateESP()
    updateItem()
    updateMob()

    if toggles["Aimbot"]() then
        local t, d = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
                local pos, on = Camera:WorldToViewportPoint(p.Character.Head.Position)
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if on and dist < d and dist < 200 then
                    d = dist
                    t = p
                end
            end
        end
        if t then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position)
        end
    end

    if toggles["Kill Aura"]() then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") then
                p.Character.Humanoid.Health = 0
            end
        end
    end

    if toggles["Fly"]() and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.Velocity = Vector3.new(0, 50, 0)
    end

    if toggles["Hack Money"]() then
        for _,v in pairs(LP:GetChildren()) do
            if v:IsA("NumberValue") and (v.Name:lower():find("money") or v.Name:lower():find("cash")) then
                v.Value = 9999999
            end
        end
    end

    if toggles["Auto Farm"]() then
        for _, o in pairs(workspace:GetDescendants()) do
            if o:IsA("Model") and o:FindFirstChild("Humanoid") and o ~= LP.Character then
                local hrp = o:FindFirstChild("HumanoidRootPart")
                if hrp then
                    LP.Character:MoveTo(hrp.Position)
                    wait(0.3)
                end
            end
        end
    end
end)

for _, v in pairs(getconnections(LP.Idled)) do v:Disable() end
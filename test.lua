-- Created By QuanCheaterVN

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanCheaterUI"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 140, 0, 40)
toggleBtn.Position = UDim2.new(0, 20, 0, 60)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.Text = "Toggle Menu"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.AutoButtonColor = false
toggleBtn.BorderSizePixel = 0
toggleBtn.BackgroundTransparency = 0.1
toggleBtn.ClipsDescendants = true
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 460)
frame.Position = UDim2.new(0, 20, 0, 110)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Visible = true
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local shadow = Instance.new("ImageLabel", frame)
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
shadow.Size = UDim2.new(1, 60, 1, 60)
shadow.ZIndex = -1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.BackgroundTransparency = 1

local title = Instance.new("TextLabel", frame)
title.Text = "QuanCheaterVN"
title.Size = UDim2.new(1, 0, 0, 40)
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1

local tabs = { "ESP", "Mem/S&F" }
local tabFrames = {}

for i, name in ipairs(tabs) do
	local tb = Instance.new("TextButton", frame)
	tb.Text = name
	tb.Size = UDim2.new(0, 140, 0, 30)
	tb.Position = UDim2.new(0, (i - 1) * 150 + 10, 0, 45)
	tb.Font = Enum.Font.GothamBold
	tb.TextSize = 14
	tb.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	tb.TextColor3 = Color3.new(1, 1, 1)
	tb.AutoButtonColor = false
	tb.BorderSizePixel = 0
	Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)

	tabFrames[name] = Instance.new("Frame", frame)
	tabFrames[name].Size = UDim2.new(1, -20, 1, -90)
	tabFrames[name].Position = UDim2.new(0, 10, 0, 85)
	tabFrames[name].Visible = false
	tabFrames[name].BackgroundTransparency = 1

	tb.MouseButton1Click:Connect(function()
		for _, f in pairs(tabFrames) do f.Visible = false end
		tabFrames[name].Visible = true
	end)
end

tabFrames["ESP"].Visible = true

local function addToggle(parent, name, y)
	local state = false
	local btn = Instance.new("TextButton", parent)
	btn.Text = "OFF - " .. name
	btn.Size = UDim2.new(0, 280, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = (state and "ON - " or "OFF - ") .. name
	end)

	return function() return state end
end

local espToggle = addToggle(tabFrames["ESP"], "ESP Master", 10)
local mobToggle = addToggle(tabFrames["ESP"], "Mob ESP", 50)
local noRecoilToggle = addToggle(tabFrames["ESP"], "No Recoil", 90)
local itemPickToggle = addToggle(tabFrames["ESP"], "Item Pick ESP", 130)
local aimbotToggle = addToggle(tabFrames["ESP"], "Aimbot Lock", 170)
local speedToggle = addToggle(tabFrames["Mem/S&F"], "Speed Hack", 10)
local flyToggle = addToggle(tabFrames["Mem/S&F"], "Fly", 50)

toggleBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

local playerESPCount = 0
local mobESPCount = 0
local maxESPDistance = 450

if not counter then
    counter = Drawing.new("Text")
    counter.Size = 22
    counter.Center = true
    counter.Outline = true
    counter.Font = 2
    counter.Color = Color3.fromRGB(255, 255, 0)
    counter.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, 30)
end


local ESPdata, Items, ItemPick = {}, {}, {}
local skeletonLines = { {1,2},{2,3},{3,4},{4,5},{2,6},{6,7},{3,8},{8,9},{3,10},{10,11} }

local function getJoints(char)
	local parts = {
		char:FindFirstChild("Head"), char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
		char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso"),
		char:FindFirstChild("LeftUpperArm"), char:FindFirstChild("LeftLowerArm"),
		char:FindFirstChild("RightUpperArm"), char:FindFirstChild("RightLowerArm"),
		char:FindFirstChild("LeftUpperLeg"), char:FindFirstChild("LeftLowerLeg"),
		char:FindFirstChild("RightUpperLeg"), char:FindFirstChild("RightLowerLeg")
	}
	local pos = {}
	for i, part in ipairs(parts) do
		if part then
			local sp, on = Camera:WorldToViewportPoint(part.Position)
			if on then pos[i] = Vector2.new(sp.X, sp.Y) end
		end
	end
	return pos
end

local function initESP(p)
	local box = Drawing.new("Square") box.Thickness = 1 box.Filled = false box.Color = Color3.fromRGB(255, 0, 0)
	local line = Drawing.new("Line") line.Thickness = 1 line.Color = Color3.fromRGB(255, 255, 0)
	local name = Drawing.new("Text") name.Size = 13 name.Color = Color3.fromRGB(0, 255, 0) name.Center = true name.Outline = true
	local hp = Drawing.new("Text") hp.Size = 13 hp.Color = Color3.fromRGB(255, 255, 255) hp.Center = true hp.Outline = true
	local skl = {} for i = 1, 10 do skl[i] = Drawing.new("Line") skl[i].Color = Color3.fromRGB(0, 255, 255) skl[i].Thickness = 1 end
	ESPdata[p] = { box = box, line = line, name = name, hp = hp, skeleton = skl }
end

local FovCircle = Drawing.new("Circle")
FovCircle.Color = Color3.fromRGB(0, 255, 0)
FovCircle.Thickness = 1
FovCircle.Radius = 100
FovCircle.Filled = false


task.defer(function()
    -- FPS unlock
    pcall(function()
        if setfpscap then setfpscap(120)
        elseif set_fps_cap then set_fps_cap(120) end
    end)

    local lighting = game:GetService("Lighting")
    local terrain = workspace:FindFirstChildOfClass("Terrain")

    lighting.Brightness = 1
    lighting.GlobalShadows = false
    lighting.FogStart = 1e10
    lighting.FogEnd = 1e10
    lighting.ExposureCompensation = 0

    for _, v in ipairs(lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect")
        or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("BlurEffect") then
            pcall(function() v:Destroy() end)
        end
    end

    if terrain then
        terrain.WaterWaveSize = 0
        terrain.WaterTransparency = 1
        terrain.WaterReflectance = 0
        terrain.WaterColor = Color3.new(0, 0, 0)
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = false
        elseif obj:IsA("Clouds") or obj.Name:lower():find("weather") or obj.Name:lower():find("rain") or obj.Name:lower():find("storm") then
            pcall(function() obj:Destroy() end)
        elseif obj:IsA("Sound") and obj.Name:lower():match("rain") or obj.Name:lower():match("storm") or obj.Name:lower():match("wind") then
            pcall(function() obj:Destroy() end)
        end
    end

    -- Xoá script thời tiết nếu có
    for _, s in ipairs(workspace:GetDescendants()) do
        if s:IsA("Script") or s:IsA("LocalScript") then
            local name = s.Name:lower()
            if name:match("weather") or name:match("storm") or name:match("rain") or name:match("cloud") then
                pcall(function() s:Destroy() end)
            end
        end
    end

    -- Xoá recoil/camera shake
    pcall(function()
        for _, s in ipairs({
            LP:FindFirstChild("PlayerScripts") and LP.PlayerScripts:FindFirstChild("Recoil"),
            LP:FindFirstChild("PlayerScripts") and LP.PlayerScripts:FindFirstChild("CameraShake"),
            LP.Character and LP.Character:FindFirstChild("CameraShake"),
            LP.Character and LP.Character:FindFirstChild("Recoil")
        }) do
            if s then
                if s:IsA("ModuleScript") then
                    local m = require(s)
                    for k, v in pairs(m) do
                        if typeof(v) == "function" then m[k] = function() end end
                    end
                else
                    s:Destroy()
                end
            end
        end
    end)
end)

RunService.RenderStepped:Connect(function()
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	if speedToggle() and LP.Character and LP.Character:FindFirstChild("Humanoid") then
		LP.Character.Humanoid.WalkSpeed = 200
	end

	if flyToggle() and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
		LP.Character.HumanoidRootPart.Velocity = Vector3.new(0, 50, 0)
	end

	for obj, txt in pairs(ItemPick) do
		if not obj:IsDescendantOf(workspace) then
			txt:Remove()
			ItemPick[obj] = nil
		else
			txt.Visible = false
		end
	end
	
local function IsVisible(part)
    local origin = Camera.CFrame.Position
    local targetPosition = part.Position
    local direction = targetPosition - origin

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LP.Character}

    local result = workspace:Raycast(origin, direction, raycastParams)
    
    return not result or result.Instance:IsDescendantOf(part.Parent)
end


if noRecoilToggle() then
	local cam = workspace.CurrentCamera
	if cam and cam:FindFirstChild("RecoilScript") then
		for _, v in ipairs(cam.RecoilScript:GetChildren()) do
			if v:IsA("NumberValue") or v:IsA("Vector3Value") then
				v.Value = 0
			end
		end
	end

	for _, tool in ipairs(LP.Backpack:GetChildren()) do
		if tool:IsA("Tool") and tool:FindFirstChild("Recoil") then
			for _, obj in ipairs(tool:GetDescendants()) do
				if obj:IsA("NumberValue") or obj:IsA("Vector3Value") then
					obj.Value = 0
				end
			end
		end
	end

	local char = LP.Character
	if char then
		for _, obj in ipairs(char:GetDescendants()) do
			if obj:IsA("NumberValue") or obj:IsA("Vector3Value") then
				if obj.Name:lower():find("recoil") then
					obj.Value = 0
				end
			end
		end
	end
end



if aimbotToggle() then
    local target = nil
    local closestDist = math.huge
    local maxDist = 250
    local fov = 180
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    local function IsVisible(part, model)
        local origin = Camera.CFrame.Position
        local direction = (part.Position - origin)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Blacklist
        params.FilterDescendantsInstances = {LP.Character, Camera}
        local result = workspace:Raycast(origin, direction, params)
        return not result or result.Instance:IsDescendantOf(model)
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Team ~= LP.Team and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChild("Humanoid")
            if head and hum and hum.Health > 0 and IsVisible(head, p.Character) then
                local dist3D = (head.Position - Camera.CFrame.Position).Magnitude
                if dist3D <= maxDist then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    local dot = (head.Position - Camera.CFrame.Position).Unit:Dot(Camera.CFrame.LookVector)
                    if onScreen and dot > 0 and dist2D <= fov then
                        if dist3D < closestDist then
                            target = head
                            closestDist = dist3D
                        end
                    end
                end
            end
        end
    end

    RunService:UnbindFromRenderStep("ForceAimbotLock")
    if target and target.Parent then
        RunService:BindToRenderStep("ForceAimbotLock", Enum.RenderPriority.Camera.Value + 1, function()
            if not target or not target.Parent or target.Parent:FindFirstChild("Humanoid") and target.Parent.Humanoid.Health <= 0 then
                RunService:UnbindFromRenderStep("ForceAimbotLock")
                return
            end
            local camPos = Camera.CFrame.Position
            local headPos = target.Position + Vector3.new(0, 0.05, 0)
            Camera.CFrame = CFrame.lookAt(camPos, headPos)
        end)

        local recoil = workspace.CurrentCamera:FindFirstChild("RecoilScript")
        if recoil then
            for _, v in ipairs(recoil:GetChildren()) do
                if v:IsA("NumberValue") or v:IsA("Vector3Value") then
                    v.Value = 0
                end
            end
        end

        pcall(function()
            for _, s in ipairs({
                LP.PlayerScripts:FindFirstChild("GunRecoil"),
                LP.PlayerScripts:FindFirstChild("Recoil"),
                LP.PlayerScripts:FindFirstChild("CameraShake"),
                LP.Character and LP.Character:FindFirstChild("Recoil"),
                LP.Character and LP.Character:FindFirstChild("CameraShakeScript")
            }) do
                if s then
                    if s:IsA("ModuleScript") then
                        local m = require(s)
                        for k, v in pairs(m) do
                            if typeof(v) == "function" then m[k] = function() end end
                        end
                    else
                        s:Destroy()
                    end
                end
            end
        end)
    end
end

local function IsVisible(part)
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LP.Character}
    local result = workspace:Raycast(origin, direction, params)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

local lastUpdate = 0
local updateRate = 0.1

if espToggle() or mobToggle() then
    if tick() - lastUpdate < updateRate then return end
    lastUpdate = tick()

    playerESPCount = 0
    mobESPCount = 0

    -- Clear all visibility
    for ent, ed in pairs(ESPdata) do
        for _, v in pairs(ed) do
            if typeof(v) == "table" then
                for _, sub in pairs(v) do sub.Visible = false end
            else
                v.Visible = false
            end
        end
    end

    local function renderESP(ent, nameText, color)
        if not ent or not ent.Position then return end
        local sp, onScreen = Camera:WorldToViewportPoint(ent.Position)
        if not onScreen then return end
        local dist = (ent.Position - Camera.CFrame.Position).Magnitude
        if dist > maxESPDistance then return end

        if not ESPdata[ent] then
            ESPdata[ent] = {
                name = Drawing.new("Text"),
                dist = Drawing.new("Text")
            }
            ESPdata[ent].name.Size = 14
            ESPdata[ent].name.Color = color
            ESPdata[ent].name.Outline = true
            ESPdata[ent].name.Center = true

            ESPdata[ent].dist.Size = 13
            ESPdata[ent].dist.Color = Color3.fromRGB(255, 255, 255)
            ESPdata[ent].dist.Outline = true
            ESPdata[ent].dist.Center = true
        end

        local ed = ESPdata[ent]
        ed.name.Text = nameText
        ed.name.Position = Vector2.new(sp.X, sp.Y)
        ed.name.Visible = true

        ed.dist.Text = math.floor(dist) .. "m"
        ed.dist.Position = Vector2.new(sp.X, sp.Y + 15)
        ed.dist.Visible = true
    end

    -- Players
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 and hum.Health < math.huge then
                local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
                if distance <= maxESPDistance and not (p.Team and LP.Team and p.Team == LP.Team) then
                    playerESPCount += 1
                    renderESP(hrp, p.Name, Color3.fromRGB(0, 255, 0))
                end
            end
        end
    end

    -- Mobs
    for _, mob in pairs(workspace:GetDescendants()) do
        if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
            local hum = mob.Humanoid
            local hrp = mob.HumanoidRootPart
            if hum.Health > 0 and hum.Health < math.huge then
                local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
                if distance <= maxESPDistance then
                    mobESPCount += 1
                    renderESP(hrp, mob.Name, Color3.fromRGB(255, 0, 0))
                end
            end
        end
    end

    -- AmmoBox2
    for _, box in ipairs(workspace:GetChildren()) do
        if box.Name == "AmmoBox2" and box:IsA("MeshPart") then
            renderESP(box, "[AmmoBox]", Color3.fromRGB(255, 255, 0))
        end
    end

    -- Counter
    if not counter then
        counter = Drawing.new("Text")
        counter.Size = 17
        counter.Color = Color3.fromRGB(255, 255, 255)
        counter.Outline = true
        counter.Center = true
        counter.Position = Vector2.new(100, 50)
    end
    counter.Text = "ESP: " .. playerESPCount .. " | MOB: " .. mobESPCount
    counter.Visible = true

else
    -- Clean up ESP
    for ent, ed in pairs(ESPdata) do
        for _, v in pairs(ed) do
            pcall(function()
                if typeof(v) == "table" then
                    for _, sub in pairs(v) do sub:Remove() end
                else
                    v:Remove()
                end
            end)
        end
    end
    ESPdata = {}
    if counter then counter.Visible = false end
end

if itemPickToggle() then
    local LP = game:GetService("Players").LocalPlayer
    local Mouse = LP:GetMouse()
    local maxItemDistance = 200

    if not gui then
        gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
        gui.Name = "StoreUI"
        gui.ResetOnSpawn = false

        storeFrame = Instance.new("Frame", gui)
        storeFrame.Size = UDim2.new(0, 150, 0, 300)
        storeFrame.Position = UDim2.new(1, -160, 0.5, -150)
        storeFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        storeFrame.BorderSizePixel = 0

        local storeLabel = Instance.new("TextLabel", storeFrame)
        storeLabel.Size = UDim2.new(1, 0, 0, 30)
        storeLabel.Text = " TÚI ĐỒ"
        storeLabel.TextColor3 = Color3.new(1, 1, 1)
        storeLabel.BackgroundTransparency = 1
        storeLabel.Font = Enum.Font.GothamBold
        storeLabel.TextSize = 14

        StoreItems = {}
    end

    for obj, txt in pairs(ItemPick) do
        if not obj:IsDescendantOf(workspace) then
            txt:Remove()
            if txt._dragBtn then txt._dragBtn:Destroy() end
            ItemPick[obj] = nil
        else
            txt.Visible = false
        end
    end

    for _, o in pairs(workspace:GetDescendants()) do
        if (o:IsA("Part") or o:IsA("Model")) and (o:FindFirstChildWhichIsA("ProximityPrompt") or o:FindFirstChildWhichIsA("ClickDetector")) then
            local pos = o:IsA("Model") and (o.PrimaryPart and o.PrimaryPart.Position or o:GetPivot().Position) or o.Position
            local dist = (pos - Camera.CFrame.Position).Magnitude
            if dist > maxItemDistance then
                if ItemPick[o] then
                    ItemPick[o]:Remove()
                    if ItemPick[o]._dragBtn then ItemPick[o]._dragBtn:Destroy() end
                    ItemPick[o] = nil
                end
            else
                if not ItemPick[o] then
                    local txt = Drawing.new("Text")
                    txt.Size = 13
                    txt.Color = Color3.fromRGB(0, 255, 255)
                    txt.Center = true
                    txt.Outline = true
                    ItemPick[o] = txt

                    local dragBtn = Instance.new("TextButton", gui)
                    dragBtn.Size = UDim2.new(0, 100, 0, 25)
                    dragBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
                    dragBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
                    dragBtn.Text = "[Pick] " .. o.Name
                    dragBtn.Font = Enum.Font.SourceSansBold
                    dragBtn.TextSize = 14
                    dragBtn.Position = UDim2.new(0, -9999, 0, -9999)
                    dragBtn.Visible = false
                    ItemPick[o]._dragBtn = dragBtn

                    local dragging = false
                    local offset = Vector2.new()

                    txt.MouseButton1Down = function()
                        dragging = true
                        offset = Vector2.new(Mouse.X - dragBtn.AbsolutePosition.X, Mouse.Y - dragBtn.AbsolutePosition.Y)
                        dragBtn.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
                        dragBtn.Visible = true
                    end

                    game:GetService("UserInputService").InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
                            dragging = false
                            local ab = dragBtn.AbsolutePosition
                            local box = storeFrame.AbsolutePosition
                            local size = storeFrame.AbsoluteSize

                            if ab.X >= box.X and ab.X <= box.X + size.X and ab.Y >= box.Y and ab.Y <= box.Y + size.Y then
                                if not StoreItems[o] then
                                    StoreItems[o] = true
                                    local label = Instance.new("TextLabel", storeFrame)
                                    label.Size = UDim2.new(1, 0, 0, 20)
                                    label.Text = o.Name
                                    label.TextColor3 = Color3.new(1, 1, 1)
                                    label.BackgroundTransparency = 1
                                    label.Font = Enum.Font.Gotham
                                    label.TextSize = 13
                                end
                            end

                            dragBtn.Visible = false
                        end
                    end)

                    game:GetService("RunService").RenderStepped:Connect(function()
                        if dragging and dragBtn.Visible then
                            dragBtn.Position = UDim2.new(0, Mouse.X - offset.X, 0, Mouse.Y - offset.Y)
                        end
                    end)
                end

                local sp, on = Camera:WorldToViewportPoint(pos)
                ItemPick[o].Position = Vector2.new(sp.X, sp.Y)
                ItemPick[o].Text = "[Pick] " .. o.Name
                ItemPick[o].Visible = on
            end
        end
    end
end



end)

Players.PlayerRemoving:Connect(function(p)
    if ESPdata[p] then
        for _, d in pairs(ESPdata[p]) do
            if typeof(d) == "table" then
                for _, l in pairs(d) do l:Remove() end
            else
                d:Remove()
            end
        end
        ESPdata[p] = nil
    end
end)


for _, v in pairs(getconnections(LP.Idled)) do v:Disable() end
-- Created By QuanCheaterVN
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanCheaterUI"

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 130, 0, 32)
toggleBtn.Position = UDim2.new(0, 20, 0, 60)
toggleBtn.Text = "Toggle Menu"
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 170, 90)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.BorderSizePixel = 0

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 460)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
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
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 0, 0, 0)

local tabs = { "ESP", "Mem/S&F" }
local tabFrames = {}

for i, name in ipairs(tabs) do
	local tabBtn = Instance.new("TextButton", frame)
	tabBtn.Text = name
	tabBtn.Size = UDim2.new(0, 150, 0, 28)
	tabBtn.Position = UDim2.new(0, (i - 1) * 160 + 5, 0, 40)
	tabBtn.Font = Enum.Font.Gotham
	tabBtn.TextSize = 14
	tabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	tabBtn.TextColor3 = Color3.new(1, 1, 1)
	tabBtn.BorderSizePixel = 0

	local tabFrame = Instance.new("Frame", frame)
	tabFrame.Size = UDim2.new(1, -20, 1, -80)
	tabFrame.Position = UDim2.new(0, 10, 0, 80)
	tabFrame.Visible = false
	tabFrame.BackgroundTransparency = 1
	tabFrame.Name = name

	tabFrames[name] = tabFrame

	tabBtn.MouseButton1Click:Connect(function()
		for _, f in pairs(tabFrames) do f.Visible = false end
		tabFrame.Visible = true
	end)
end

tabFrames["ESP"].Visible = true

local function addToggle(parent, name, order)
	local state = false
	local y = (order - 1) * 35
	local btn = Instance.new("TextButton", parent)
	btn.Text = name .. ": OFF"
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.Position = UDim2.new(0, 0, 0, y)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BorderSizePixel = 0

	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = name .. ": " .. (state and "ON" or "OFF")
	end)

	btn.Parent = parent
	return function() return state end
end

local espToggle         = addToggle(tabFrames["ESP"], "ESP Master",       1)
local highDamageToggle  = addToggle(tabFrames["ESP"], "High Damage",      2)
local magicBulletToggle = addToggle(tabFrames["ESP"], "Magic Bullet",     3)
local noRecoilToggle    = addToggle(tabFrames["ESP"], "No Recoil",        4)
local mobToggle         = addToggle(tabFrames["ESP"], "Mob ESP",          5)
local itemPickToggle    = addToggle(tabFrames["ESP"], "Item Pick ESP",    6)
local aimbotToggle      = addToggle(tabFrames["ESP"], "Aimbot Lock",      7)

local speedToggle       = addToggle(tabFrames["Mem/S&F"], "Speed Hack",   1)
local flyToggle         = addToggle(tabFrames["Mem/S&F"], "Fly",          2)

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
	end
end

if itemPickToggle() then
	for _, o in pairs(workspace:GetDescendants()) do
		if (o:IsA("Part") or o:IsA("Model")) and (o:FindFirstChildWhichIsA("ProximityPrompt") or o:FindFirstChildWhichIsA("ClickDetector")) then
			local pos

			if o:IsA("Model") then
				if not o.PrimaryPart then
					local primary = o:FindFirstChild("HumanoidRootPart") or o:FindFirstChildWhichIsA("BasePart")
					if primary then
						pcall(function() o.PrimaryPart = primary end)
					end
				end
				if o.PrimaryPart then
					pos = o.PrimaryPart.Position
				else
					local success
					success, pos = pcall(function() return o:GetPivot().Position end)
					if not success then continue end
				end
			else
				pos = o.Position
			end

			local sp, onScreen = Camera:WorldToViewportPoint(pos)
			local dir = (pos - Camera.CFrame.Position).Unit
			local inFront = dir:Dot(Camera.CFrame.LookVector) > 0

			if not ItemPick[o] then
				local txt = Drawing.new("Text")
				txt.Size = 13
				txt.Color = Color3.fromRGB(0, 255, 255)
				txt.Center = true
				txt.Outline = true
				txt.Visible = false
				ItemPick[o] = txt
			end

			local draw = ItemPick[o]
			draw.Position = Vector2.new(sp.X, sp.Y)
			draw.Text = "[Pick] " .. o.Name
			draw.Visible = onScreen and inFront
		end
	end
else
	for _, txt in pairs(ItemPick) do
		txt.Visible = false
	end
end

if highDamageToggle() then
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
			local head = p.Character.Head
			for _, part in pairs(p.Character:GetChildren()) do
				if part:IsA("BasePart") and part.Name ~= "Head" then
					part.Size = Vector3.new(0.1, 0.1, 0.1)
					part.CanCollide = false
					part.Transparency = 1
					part.CFrame = head.CFrame
				end
			end
		end
	end
end
if magicBulletToggle() then
	for _, bullet in pairs(workspace:GetDescendants()) do
		if bullet:IsA("BasePart") and bullet.Name:lower():find("bullet") then
			for _, enemy in pairs(Players:GetPlayers()) do
				if enemy ~= LP and enemy.Character and enemy.Character:FindFirstChild("Head") then
					local head = enemy.Character.Head
					local direction = (head.Position - bullet.Position).Unit
					bullet.Velocity = direction * 3000
					bullet.CFrame = CFrame.lookAt(bullet.Position, head.Position)
					break -- Chỉ chọn 1 enemy gần nhất
				end
			end
		end
	end
end

  	if noRecoilToggle() then
		local cam = workspace.CurrentCamera
		if cam and cam:FindFirstChild("RecoilScript") then
			local recoilScript = cam:FindFirstChild("RecoilScript")
			for _, v in pairs(recoilScript:GetChildren()) do
				if v:IsA("NumberValue") or v:IsA("Vector3Value") then
					v.Value = 0
				end
			end
		end
		if cam then
			cam.CFrame = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + cam.CFrame.LookVector)
		end
	end

if aimbotToggle() then
    local target = nil
    local minDist = math.huge
    local minHealth = math.huge
    local maxAimDistance = 150
    local aimFovRadius = 180
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Team ~= LP.Team and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChild("Humanoid")

            if head and hum and hum.Health > 0 and hum.Health < math.huge then
                local distance3D = (head.Position - Camera.CFrame.Position).Magnitude
                if distance3D <= maxAimDistance then
                    local sp, on = Camera:WorldToViewportPoint(head.Position)
                    local dir = (head.Position - Camera.CFrame.Position).Unit
                    local dot = dir:Dot(Camera.CFrame.LookVector)
                    local dist2D = (Vector2.new(sp.X, sp.Y) - center).Magnitude

                    if on and dot > 0 and dist2D < aimFovRadius then
                        if dist2D < minDist or (math.abs(dist2D - minDist) < 1 and hum.Health < minHealth) then
                            target = head
                            minDist = dist2D
                            minHealth = hum.Health
                        end
                    end
                end
            end
        end
    end

    if target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
    end
end

if espToggle() or mobToggle() then
    playerESPCount = 0
    mobESPCount = 0

    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local topCenter = Vector2.new(screenCenter.X, 0)
    local alertMap = {}
    local alertRadius = 60

    for ent, ed in pairs(ESPdata) do
        ed.box.Visible = false
        ed.line.Visible = false
        ed.name.Visible = false
        ed.hp.Visible = false
        for _, sl in ipairs(ed.skeleton) do sl.Visible = false end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Team ~= LP.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            local hum = p.Character.Humanoid
            local hrp = p.Character.HumanoidRootPart
            local distance = (hrp.Position - Camera.CFrame.Position).Magnitude

            if distance <= maxESPDistance and hum.Health > 0 and hum.Health < math.huge then
                local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local dir = (hrp.Position - Camera.CFrame.Position).Unit
                local dot = dir:Dot(Camera.CFrame.LookVector)

                if espToggle() and onScreen and dot > 0 then
                    if not ESPdata[p] then initESP(p) end
                    local ed = ESPdata[p]
                    local sy = math.clamp(2000 / distance, 30, 200)
                    local sx = sy / 2

                    ed.box.Position = Vector2.new(sp.X - sx / 2, sp.Y - sy / 2)
                    ed.box.Size = Vector2.new(sx, sy)
                    ed.box.Visible = true

                    ed.line.From = topCenter
                    ed.line.To = Vector2.new(sp.X, sp.Y)
                    ed.line.Visible = true

                    ed.name.Position = Vector2.new(sp.X, sp.Y - sy / 2 - 15)
                    ed.name.Text = p.Name
                    ed.name.Visible = true

                    ed.hp.Position = Vector2.new(sp.X, sp.Y - sy / 2 - 30)
                    ed.hp.Text = "HP: " .. math.floor(hum.Health)
                    ed.hp.Visible = true

                    local joints = getJoints(p.Character)
                    for i, pair in ipairs(skeletonLines) do
                        local a, b = joints[pair[1]], joints[pair[2]]
                        local sl = ed.skeleton[i]
                        if a and b then
                            sl.From = a
                            sl.To = b
                            sl.Visible = true
                        else
                            sl.Visible = false
                        end
                    end
                    playerESPCount += 1
                else
                    local dir = (hrp.Position - Camera.CFrame.Position).Unit
                    local angle = math.atan2(dir.Z, dir.X)
                    local rounded = math.floor(angle * 10) / 10
                    alertMap[rounded] = true
                end
            end
        end
    end

    for _, mob in pairs(workspace:GetDescendants()) do
        if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
            local hum = mob.Humanoid
            local hrp = mob.HumanoidRootPart
            local distance = (hrp.Position - Camera.CFrame.Position).Magnitude

            if distance <= maxESPDistance and hum.Health > 0 and hum.Health < math.huge then
                local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local dir = (hrp.Position - Camera.CFrame.Position).Unit
                local dot = dir:Dot(Camera.CFrame.LookVector)

                if mobToggle() and onScreen and dot > 0 then
                    if not ESPdata[mob] then initESP(mob) end
                    local ed = ESPdata[mob]
                    local sy = math.clamp(2000 / distance, 30, 200)
                    local sx = sy / 2

                    ed.box.Position = Vector2.new(sp.X - sx / 2, sp.Y - sy / 2)
                    ed.box.Size = Vector2.new(sx, sy)
                    ed.box.Visible = true

                    ed.line.From = topCenter
                    ed.line.To = Vector2.new(sp.X, sp.Y)
                    ed.line.Visible = true

                    ed.name.Position = Vector2.new(sp.X, sp.Y - sy / 2 - 15)
                    ed.name.Text = mob.Name
                    ed.name.Visible = true

                    ed.hp.Position = Vector2.new(sp.X, sp.Y - sy / 2 - 30)
                    ed.hp.Text = "HP: " .. math.floor(hum.Health)
                    ed.hp.Visible = true

                    for _, sl in ipairs(ed.skeleton) do sl.Visible = false end
                    mobESPCount += 1
                else
                    local dir = (hrp.Position - Camera.CFrame.Position).Unit
                    local angle = math.atan2(dir.Z, dir.X)
                    local rounded = math.floor(angle * 10) / 10
                    alertMap[rounded] = true
                end
            end
        end
    end

    if not counter then
        counter = Instance.new("TextLabel")
        counter.Size = UDim2.new(0, 300, 0, 32)
        counter.AnchorPoint = Vector2.new(0.5, 0)
        counter.Position = UDim2.new(0.5, 0, 0, 22)
        counter.BackgroundTransparency = 1
        counter.TextColor3 = Color3.fromRGB(255, 255, 0)
        counter.TextStrokeColor3 = Color3.new(0, 0, 0)
        counter.TextStrokeTransparency = 0.3
        counter.Font = Enum.Font.GothamBold
        counter.TextSize = 22
        counter.Name = "ESPCount"
        counter.ZIndex = 9999
        counter.Parent = game.CoreGui
    end

    counter.Text = "ESP: " .. tostring(playerESPCount) .. " | MOB: " .. tostring(mobESPCount)
    counter.Visible = true

    for angle, _ in pairs(alertMap) do
        local dotPos = screenCenter + Vector2.new(math.cos(angle), math.sin(angle)) * alertRadius
        local dot = Drawing.new("Circle")
        dot.Position = dotPos
        dot.Radius = 6
        dot.Filled = true
        dot.Color = Color3.fromHSV(angle % 1, 1, 1)
        dot.Visible = true
        task.delay(0.3, function() dot:Remove() end)
    end
else
    if counter then counter.Visible = false end
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
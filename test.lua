-- Created By QuanCheaterVN

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanCheaterUI"

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 120, 0, 30)
toggleBtn.Position = UDim2.new(0, 20, 0, 60)
toggleBtn.Text = "Toggle Menu"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.TextSize = 14

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 440)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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

local playerESPCount = 0
local mobESPCount = 0
local counter = Drawing.new("Text")
counter.Size = 16
counter.Center = true
counter.Outline = true
counter.Color = Color3.fromRGB(255, 255, 0)
counter.Position = Vector2.new(Camera.ViewportSize.X / 2, 30)
counter.Visible = false


local tabs = { "ESP", "Mem/S&F" }
local tabFrames = {}
for i, name in ipairs(tabs) do
	local tb = Instance.new("TextButton", frame)
	tb.Text = name
	tb.Size = UDim2.new(0, 140, 0, 30)
	tb.Position = UDim2.new(0, (i - 1) * 150 + 10, 0, 40)
	tb.Font = Enum.Font.Gotham
	tb.TextSize = 14
	tb.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	tb.TextColor3 = Color3.new(1, 1, 1)

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
	local state = false
	local btn = Instance.new("TextButton", parent)
	btn.Text = name .. ": OFF"
	btn.Size = UDim2.new(0, 280, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.new(1, 1, 1)

	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = name .. ": " .. (state and "ON" or "OFF")
	end)

	return function() return state end
end


local espToggle = addToggle(tabFrames["ESP"], "ESP Master", 10)
local mobToggle = addToggle(tabFrames["ESP"], "Mob ESP", 90)
local noRecoilToggle = addToggle(tabFrames["ESP"], "noRecoilToggle", 90)
local aimbotToggle = addToggle(tabFrames["ESP"], "Aimbot Lock", 170)
local speedToggle = addToggle(tabFrames["Mem/S&F"], "Speed Hack", 10)
local flyToggle = addToggle(tabFrames["Mem/S&F"], "Fly", 50)
local itemPickToggle = addToggle(tabFrames["ESP"], "Item Pick ESP", 130)

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
    local target, minDist = nil, math.huge
    local maxAimDistance = 150 -- Khoảng cách cố định aim tối đa
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Team ~= LP.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local distance3D = (hrp.Position - Camera.CFrame.Position).Magnitude
            if distance3D <= maxAimDistance then -- chỉ xét mục tiêu trong 150 studs
                local sp, on = Camera:WorldToViewportPoint(hrp.Position)
                local dir = (hrp.Position - Camera.CFrame.Position).Unit
                local dot = dir:Dot(Camera.CFrame.LookVector)
                local dist2D = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                if on and dot > 0 and dist2D < minDist then
                    target = hrp
                    minDist = dist2D
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

		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
				local hum = p.Character.Humanoid
				local hrp = p.Character.HumanoidRootPart
				local sp, on = Camera:WorldToViewportPoint(hrp.Position)
				local dir = (hrp.Position - Camera.CFrame.Position).Unit
				local dot = dir:Dot(Camera.CFrame.LookVector)

				if espToggle() and hum.Health > 0 and on and dot > 0 then
					if not ESPdata[p] then initESP(p) end
					local ed = ESPdata[p]
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
					if ESPdata[p] then
						local ed = ESPdata[p]
						ed.box.Visible = false
						ed.line.Visible = false
						ed.name.Visible = false
						ed.hp.Visible = false
						for _, sl in ipairs(ed.skeleton) do sl.Visible = false end
					end
				end
			end
		end

		for _, mob in pairs(workspace:GetDescendants()) do
			if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
				local hum = mob.Humanoid
				local hrp = mob.HumanoidRootPart
				local sp, on = Camera:WorldToViewportPoint(hrp.Position)
				local dir = (hrp.Position - Camera.CFrame.Position).Unit
				local dot = dir:Dot(Camera.CFrame.LookVector)

				if mobToggle() and hum.Health > 0 and on and dot > 0 then
					if not ESPdata[mob] then initESP(mob) end
					local ed = ESPdata[mob]
					local sy = math.clamp(2000 / (hrp.Position - Camera.CFrame.Position).Magnitude, 30, 200)
					local sx = sy / 2
					ed.box.Position = Vector2.new(sp.X - sx / 2, sp.Y - sy / 2)
					ed.box.Size = Vector2.new(sx, sy)
					ed.box.Visible = true
					ed.line.From = center
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
					if ESPdata[mob] then
						local ed = ESPdata[mob]
						ed.box.Visible = false
						ed.line.Visible = false
						ed.name.Visible = false
						ed.hp.Visible = false
						for _, sl in ipairs(ed.skeleton) do sl.Visible = false end
					end
				end
			end
		end

		counter.Text = "ESP: " .. tostring(playerESPCount) .. " | MOB: " .. tostring(mobESPCount)
		counter.Visible = true
	else
		counter.Visible = false
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
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanItemESPMenu"

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 120, 0, 35)
toggleBtn.Position = UDim2.new(0, 20, 0, 60)
toggleBtn.Text = "Toggle Menu"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 350, 0, 500)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = false

toggleBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

local title = Instance.new("TextLabel", frame)
title.Text = "QuanCheaterVN Item Viewer"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local searchBox = Instance.new("TextBox", frame)
searchBox.PlaceholderText = "Tìm item..."
searchBox.Size = UDim2.new(1, -10, 0, 25)
searchBox.Position = UDim2.new(0, 5, 0, 30)
searchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
searchBox.BorderSizePixel = 0

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 1, -65)
scroll.Position = UDim2.new(0, 5, 0, 60)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
scroll.BorderSizePixel = 0

local currentHighlights = {}
local buttons = {}
local DrawingItems = {}

local function clearHighlights()
	for _, obj in pairs(currentHighlights) do
		if obj:IsA("BasePart") then
			obj.Material = Enum.Material.Plastic
			obj.Transparency = 0
		end
	end
	currentHighlights = {}

	for _, drawings in pairs(DrawingItems) do
		for _, d in pairs(drawings) do
			if d.Remove then d:Remove() end
		end
	end
	DrawingItems = {}
end

local function highlightItem(name, obj)
	clearHighlights()

	local part
	if obj:IsA("BasePart") then
		part = obj
	elseif obj:IsA("Model") then
		part = obj:FindFirstChildWhichIsA("BasePart")
	end

	if part then
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(0, 255, 0)
		part.Transparency = 0.2
		currentHighlights[name] = part

		-- 🟢 Teleport đến item
		local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if root then
			root.CFrame = CFrame.new(part.Position + Vector3.new(0, 5, 0))
		end
	end
end

local function collectItems()
	local map = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") or obj:IsA("Model") then
			if obj:FindFirstChildWhichIsA("ProximityPrompt") or obj:FindFirstChildWhichIsA("ClickDetector") then
				local key = obj.Name
				if not map[key] then map[key] = {} end
				table.insert(map[key], obj)
			end
		end
	end
	return map
end

local function updateSearch(keyword)
	for _, b in ipairs(buttons) do b:Destroy() end
	buttons = {}

	local y = 0
	local itemMap = collectItems()

	for itemName, objs in pairs(itemMap) do
		if keyword == "" or itemName:lower():find(keyword:lower()) then
			local row = Instance.new("Frame", scroll)
			row.Size = UDim2.new(1, 0, 0, 28)
			row.Position = UDim2.new(0, 0, 0, y)
			row.BackgroundTransparency = 1

			local btn = Instance.new("TextButton", row)
			btn.Size = UDim2.new(1, 0, 0, 28)
			btn.Position = UDim2.new(0, 0, 0, 0)
			btn.Text = itemName .. " [" .. tostring(#objs) .. "]"
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 13
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			btn.BorderSizePixel = 0

			btn.MouseButton1Click:Connect(function()
				highlightItem(itemName, objs[1])
			end)

			table.insert(buttons, row)
			y += 30
		end
	end

	scroll.CanvasSize = UDim2.new(0, 0, 0, y)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	updateSearch(searchBox.Text)
end)

updateSearch("")

-- 🎯 ESP Drawing Logic
RunService.RenderStepped:Connect(function()
	for _, drawings in pairs(DrawingItems) do
		for _, d in pairs(drawings) do
			if d.Remove then d:Remove() end
		end
	end
	DrawingItems = {}

	for itemName, obj in pairs(currentHighlights) do
		local espSet = {}
		if obj:IsA("BasePart") then
			local pos = obj.Position
			local sp, onScreen = Camera:WorldToViewportPoint(pos)

			-- Box
			local box = Drawing.new("Square")
			box.Size = Vector2.new(40, 40)
			box.Position = Vector2.new(sp.X - 20, sp.Y - 20)
			box.Color = Color3.fromRGB(0, 255, 0)
			box.Thickness = 2
			box.Visible = onScreen
			table.insert(espSet, box)

			-- Line
			local line = Drawing.new("Line")
			line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			line.To = Vector2.new(sp.X, sp.Y)
			line.Color = Color3.fromRGB(0, 255, 0)
			line.Thickness = 1.5
			line.Visible = onScreen
			table.insert(espSet, line)

			-- Name
			local txt = Drawing.new("Text")
			txt.Text = "[ITEM] " .. obj.Name
			txt.Size = 16
			txt.Center = true
			txt.Outline = true
			txt.Color = Color3.fromRGB(0, 255, 0)
			txt.Position = Vector2.new(sp.X, sp.Y - 30)
			txt.Visible = onScreen
			table.insert(espSet, txt)
		end
		DrawingItems[itemName] = espSet
	end
end)
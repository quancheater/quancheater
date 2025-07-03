local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanClassViewer"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 500, 0, 400)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "QuanCheaterVN Class Table"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Position = UDim2.new(0, 0, 0, 35)
scroll.Size = UDim2.new(1, 0, 1, -70)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 8
scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
scroll.BorderSizePixel = 0

local grid = Instance.new("UIGridLayout", scroll)
grid.CellSize = UDim2.new(0, 150, 0, 30)
grid.CellPadding = UDim2.new(0, 6, 0, 6)

local highlightMap, savedClasses = {}, {}

local function clearHighlights()
	for _, objs in pairs(highlightMap) do
		for _, obj in ipairs(objs) do
			if obj:IsA("BasePart") then
				obj.Material = Enum.Material.Plastic
				obj.Color = Color3.fromRGB(255, 255, 255)
				obj.Transparency = 0
			end
		end
	end
	highlightMap = {}
end

local function highlight(className, objects)
	highlightMap[className] = {}
	for _, obj in ipairs(objects) do
		if obj:IsA("BasePart") then
			obj.Material = Enum.Material.Neon
			obj.Color = Color3.fromRGB(0, 120, 255)
			obj.Transparency = 0.3
			table.insert(highlightMap[className], obj)
		elseif obj:IsA("Model") then
			for _, part in ipairs(obj:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Material = Enum.Material.Neon
					part.Color = Color3.fromRGB(0, 120, 255)
					part.Transparency = 0.3
					table.insert(highlightMap[className], part)
				end
			end
		end
	end
end

local function saveToFile(className)
	if not savedClasses[className] then
		appendfile("ClassesSet.txt", className .. "\n")
		savedClasses[className] = true
	end
end

local function collectClasses()
	local map = {}

	for _, obj in ipairs(game:GetDescendants()) do
		local cls = obj.ClassName
		if not map[cls] then map[cls] = {} end
		table.insert(map[cls], obj)
	end

	map["Player"] = {}
	map["NPC"] = {}

	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then table.insert(map["Player"], p.Character) end
	end
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
			table.insert(map["NPC"], obj)
		end
	end

	return map
end

local function loadClassTable()
	scroll:ClearAllChildren()
	local classes = collectClasses()
	for className, objects in pairs(classes) do
		local btn = Instance.new("TextButton", scroll)
		btn.Text = className .. " [" .. tostring(#objects) .. "]"
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 13
		btn.BorderSizePixel = 0

		btn.MouseButton1Click:Connect(function()
			clearHighlights()
			highlight(className, objects)
			saveToFile(className)
		end)
	end
end

local resetBtn = Instance.new("TextButton", frame)
resetBtn.Text = "Reset"
resetBtn.Size = UDim2.new(0, 100, 0, 30)
resetBtn.Position = UDim2.new(0, 10, 1, -35)
resetBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
resetBtn.TextColor3 = Color3.new(1, 1, 1)
resetBtn.Font = Enum.Font.Gotham
resetBtn.TextSize = 13
resetBtn.BorderSizePixel = 0
resetBtn.MouseButton1Click:Connect(clearHighlights)

local saveBtn = Instance.new("TextButton", frame)
saveBtn.Text = "Save Set"
saveBtn.Size = UDim2.new(0, 100, 0, 30)
saveBtn.Position = UDim2.new(0, 120, 1, -35)
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.Font = Enum.Font.Gotham
saveBtn.TextSize = 13
saveBtn.BorderSizePixel = 0
saveBtn.MouseButton1Click:Connect(function()
	for className, objs in pairs(highlightMap) do
		if #objs > 0 then
			saveToFile(className)
		end
	end
end)

loadClassTable()
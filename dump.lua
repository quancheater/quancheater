local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanClassMenu"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 330, 0, 480)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "QuanCheaterVN Class Viewer"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local searchBox = Instance.new("TextBox", frame)
searchBox.PlaceholderText = "Tìm class/hàm..."
searchBox.Size = UDim2.new(1, -10, 0, 25)
searchBox.Position = UDim2.new(0, 5, 0, 30)
searchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
searchBox.BorderSizePixel = 0

local btnPanel = Instance.new("Frame", frame)
btnPanel.Size = UDim2.new(1, -10, 0, 40)
btnPanel.Position = UDim2.new(0, 5, 0, 60)
btnPanel.BackgroundTransparency = 1

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, 0, 1, -110)
scroll.Position = UDim2.new(0, 0, 0, 100)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
scroll.BorderSizePixel = 0

btnPanel.Parent = frame

local buttons, lastClass = {}, nil

local function clearHighlights()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Material = Enum.Material.Plastic
			obj.Transparency = 0
		end
	end
end

local function highlightObjects(objects)
	clearHighlights()
	for _, obj in ipairs(objects) do
		if obj:IsA("BasePart") then
			obj.Material = Enum.Material.Neon
			obj.Color = Color3.fromRGB(0, 120, 255)
			obj.Transparency = 0.3
		elseif obj:IsA("Model") then
			for _, part in ipairs(obj:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Material = Enum.Material.Neon
					part.Color = Color3.fromRGB(0, 120, 255)
					part.Transparency = 0.3
				end
			end
		end
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

local function updateSearchResult(keyword)
	for _, btn in ipairs(buttons) do btn:Destroy() end
	buttons = {}

	local y = 0
	local classMap = collectClasses()

	for class, objects in pairs(classMap) do
		if keyword == "" or class:lower():find(keyword:lower()) then
			local btn = Instance.new("TextButton", scroll)
			btn.Size = UDim2.new(1, -10, 0, 26)
			btn.Position = UDim2.new(0, 5, 0, y)
			btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 13
			btn.Text = class .. " [" .. tostring(#objects) .. "]"
			btn.BorderSizePixel = 0

			btn.MouseButton1Click:Connect(function()
				lastClass = objects
				highlightObjects(objects)
			end)

			table.insert(buttons, btn)
			y += 28
		end
	end

	scroll.CanvasSize = UDim2.new(0, 0, 0, y)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	updateSearchResult(searchBox.Text)
end)

-- Button builder
local function createFuncBtn(name, color, callback)
	local b = Instance.new("TextButton", btnPanel)
	b.Text = name
	b.Size = UDim2.new(0, 75, 0, 30)
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.BorderSizePixel = 0
	b.MouseButton1Click:Connect(callback)
	return b
end

createFuncBtn("Reset", Color3.fromRGB(200, 0, 0), function()
	clearHighlights()
end).Position = UDim2.new(0, 0, 0, 5)

createFuncBtn("False", Color3.fromRGB(50, 50, 120), function()
	print("Return false")
end).Position = UDim2.new(0, 80, 0, 5)

createFuncBtn("Return 0", Color3.fromRGB(80, 80, 80), function()
	print("Return 0")
end).Position = UDim2.new(0, 160, 0, 5)

createFuncBtn("Int", Color3.fromRGB(60, 120, 80), function()
	print("INT mode applied")
end).Position = UDim2.new(0, 240, 0, 5)

-- First load
updateSearchResult("")
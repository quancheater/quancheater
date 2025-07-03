local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanClassMenu"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 350, 0, 500)
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
searchBox.PlaceholderText = "Tìm class..."
searchBox.Size = UDim2.new(1, -10, 0, 25)
searchBox.Position = UDim2.new(0, 5, 0, 30)
searchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
searchBox.BorderSizePixel = 0

local resetAll = Instance.new("TextButton", frame)
resetAll.Text = "Reset ALL"
resetAll.Size = UDim2.new(0, 100, 0, 28)
resetAll.Position = UDim2.new(0, 5, 0, 60)
resetAll.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
resetAll.TextColor3 = Color3.new(1, 1, 1)
resetAll.Font = Enum.Font.Gotham
resetAll.TextSize = 13
resetAll.BorderSizePixel = 0

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 1, -100)
scroll.Position = UDim2.new(0, 5, 0, 95)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
scroll.BorderSizePixel = 0

-- Highlight handling
local currentHighlights = {}

local function clearHighlights(className)
	for _, obj in pairs(currentHighlights[className] or {}) do
		if obj:IsA("BasePart") then
			obj.Material = Enum.Material.Plastic
			obj.Transparency = 0
		end
	end
	currentHighlights[className] = {}
end

local function highlightClass(className, objects)
	clearHighlights(className)
	currentHighlights[className] = {}
	for _, obj in ipairs(objects) do
		if obj:IsA("BasePart") then
			obj.Material = Enum.Material.Neon
			obj.Color = Color3.fromRGB(0, 120, 255)
			obj.Transparency = 0.2
			table.insert(currentHighlights[className], obj)
		elseif obj:IsA("Model") then
			for _, part in ipairs(obj:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Material = Enum.Material.Neon
					part.Color = Color3.fromRGB(0, 120, 255)
					part.Transparency = 0.2
					table.insert(currentHighlights[className], part)
				end
			end
		end
	end
end

local function resetAllHighlights()
	for class, _ in pairs(currentHighlights) do
		clearHighlights(class)
	end
end

resetAll.MouseButton1Click:Connect(resetAllHighlights)

-- Class collection
local function collectClasses()
	local map = {}
	for _, obj in ipairs(game:GetDescendants()) do
		local cls = obj.ClassName
		if not map[cls] then map[cls] = {} end
		table.insert(map[cls], obj)
	end
	-- Add NPC and Player manually
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

-- Update UI
local buttons = {}

local function updateSearch(keyword)
	for _, btn in pairs(buttons) do btn:Destroy() end
	buttons = {}

	local y = 0
	local classes = collectClasses()
	for class, objs in pairs(classes) do
		if keyword == "" or class:lower():find(keyword:lower()) then
			local row = Instance.new("Frame", scroll)
			row.Size = UDim2.new(1, 0, 0, 28)
			row.Position = UDim2.new(0, 0, 0, y)
			row.BackgroundTransparency = 1

			local btn = Instance.new("TextButton", row)
			btn.Size = UDim2.new(1, -110, 0, 28)
			btn.Position = UDim2.new(0, 0, 0, 0)
			btn.Text = class .. " [" .. tostring(#objs) .. "]"
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 13
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			btn.BorderSizePixel = 0

			local reset = Instance.new("TextButton", row)
			reset.Size = UDim2.new(0, 100, 0, 28)
			reset.Position = UDim2.new(1, -100, 0, 0)
			reset.Text = "Reset"
			reset.Font = Enum.Font.Gotham
			reset.TextSize = 13
			reset.TextColor3 = Color3.new(1, 1, 1)
			reset.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
			reset.BorderSizePixel = 0

			btn.MouseButton1Click:Connect(function()
				highlightClass(class, objs)
			end)

			reset.MouseButton1Click:Connect(function()
				clearHighlights(class)
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
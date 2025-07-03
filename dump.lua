local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanClassMenu"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 420)
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

local scrolling = Instance.new("ScrollingFrame", frame)
scrolling.Size = UDim2.new(1, 0, 1, -60)
scrolling.Position = UDim2.new(0, 0, 0, 60)
scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
scrolling.ScrollBarThickness = 6
scrolling.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
scrolling.BorderSizePixel = 0

local buttons = {}
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
			local btn = Instance.new("TextButton", scrolling)
			btn.Size = UDim2.new(1, -10, 0, 26)
			btn.Position = UDim2.new(0, 5, 0, y)
			btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 13
			btn.Text = class .. " [" .. tostring(#objects) .. "]"
			btn.BorderSizePixel = 0
			btn.Parent = scrolling

			btn.MouseButton1Click:Connect(function()
				highlightObjects(objects)
			end)

			table.insert(buttons, btn)
			y += 28
		end
	end

	scrolling.CanvasSize = UDim2.new(0, 0, 0, y)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	updateSearchResult(searchBox.Text)
end)

updateSearchResult("")
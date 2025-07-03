local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanClassMenu"

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

toggleBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

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

local saveSet = Instance.new("TextButton", frame)
saveSet.Text = "Lưu đã set"
saveSet.Size = UDim2.new(0, 100, 0, 28)
saveSet.Position = UDim2.new(0, 115, 0, 60)
saveSet.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
saveSet.TextColor3 = Color3.new(1, 1, 1)
saveSet.Font = Enum.Font.Gotham
saveSet.TextSize = 13
saveSet.BorderSizePixel = 0

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 1, -100)
scroll.Position = UDim2.new(0, 5, 0, 95)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
scroll.BorderSizePixel = 0

local currentHighlights, buttons = {}, {}

local function clearHighlights(className)
	for _, obj in pairs(currentHighlights[className] or {}) do
		if obj:IsA("BasePart") then
			obj.Material = Enum.Material.Plastic
			obj.Transparency = 0
		end
	end
	currentHighlights[className] = {}
end

local function resetAllHighlights()
	for k in pairs(currentHighlights) do
		clearHighlights(k)
	end
end

local function highlightClass(className, objects)
	clearHighlights(className)
	currentHighlights[className] = {}

	for _, obj in ipairs(objects) do
		if obj:IsA("BasePart") then
			obj.Material = Enum.Material.Neon
			obj.Color = Color3.fromRGB(0, 180, 255)
			obj.Transparency = 0.2
			table.insert(currentHighlights[className], obj)
		elseif obj:IsA("Model") then
			for _, part in ipairs(obj:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Material = Enum.Material.Neon
					part.Color = Color3.fromRGB(0, 180, 255)
					part.Transparency = 0.2
					table.insert(currentHighlights[className], part)
				end
			end
		end
	end
end

resetAll.MouseButton1Click:Connect(resetAllHighlights)

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

local function updateSearch(keyword)
	for _, b in ipairs(buttons) do b:Destroy() end
	buttons = {}

	local y = 0
	local classMap = collectClasses()

	for className, objects in pairs(classMap) do
		if keyword == "" or className:lower():find(keyword:lower()) then
			local row = Instance.new("Frame", scroll)
			row.Size = UDim2.new(1, 0, 0, 28)
			row.Position = UDim2.new(0, 0, 0, y)
			row.BackgroundTransparency = 1

			local classBtn = Instance.new("TextButton", row)
			classBtn.Size = UDim2.new(1, -110, 0, 28)
			classBtn.Position = UDim2.new(0, 0, 0, 0)
			classBtn.Text = className .. " [" .. tostring(#objects) .. "]"
			classBtn.Font = Enum.Font.Gotham
			classBtn.TextSize = 13
			classBtn.TextColor3 = Color3.new(1, 1, 1)
			classBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			classBtn.BorderSizePixel = 0

			local resetBtn = Instance.new("TextButton", row)
			resetBtn.Size = UDim2.new(0, 100, 0, 28)
			resetBtn.Position = UDim2.new(1, -100, 0, 0)
			resetBtn.Text = "Reset"
			resetBtn.Font = Enum.Font.Gotham
			resetBtn.TextSize = 13
			resetBtn.TextColor3 = Color3.new(1, 1, 1)
			resetBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
			resetBtn.BorderSizePixel = 0

			classBtn.MouseButton1Click:Connect(function()
				highlightClass(className, objects)
			end)

			resetBtn.MouseButton1Click:Connect(function()
				clearHighlights(className)
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

saveSet.MouseButton1Click:Connect(function()
	local lines = {}
	for className, objects in pairs(currentHighlights) do
		if #objects > 0 then
			table.insert(lines, className)
		end
	end
	writefile("QuanClassSet.txt", table.concat(lines, "\n"))
end)

updateSearch("")
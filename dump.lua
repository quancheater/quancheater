local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local currentHighlights = {}
local buttons = {}

-- 💡 Tạo đường dẫn tên đầy đủ
local function getFullPath(obj)
	local path = {}
	while obj and obj ~= game do
		table.insert(path, 1, obj.Name)
		obj = obj.Parent
	end
	return table.concat(path, ".")
end

-- 🌟 Tạo hiệu ứng glowing giả nếu object quá xa
local function createGlowProxy(item)
	local pos
	if item:IsA("Model") then
		local part = item:FindFirstChildWhichIsA("BasePart")
		pos = part and part.Position
	elseif item:IsA("BasePart") then
		pos = item.Position
	end
	if not pos then return end

	local glow = Instance.new("Part")
	glow.Anchored = true
	glow.CanCollide = false
	glow.Transparency = 0.2
	glow.Material = Enum.Material.Neon
	glow.Color = Color3.fromRGB(0, 255, 255)
	glow.Size = Vector3.new(1, 1, 1)
	glow.Position = pos
	glow.Parent = workspace
	task.delay(3, function() glow:Destroy() end)
end

-- ✅ Highlight thật (nếu nằm trong render)
local function highlightItem(obj)
	if currentHighlights[obj] then return end
	currentHighlights[obj] = {}

	local valid = false
	if obj:IsA("BasePart") then
		obj.Material = Enum.Material.Neon
		obj.Color = Color3.fromRGB(0, 255, 255)
		obj.Transparency = 0.2
		table.insert(currentHighlights[obj], obj)
		valid = true
	elseif obj:IsA("Model") then
		for _, part in ipairs(obj:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Material = Enum.Material.Neon
				part.Color = Color3.fromRGB(0, 255, 255)
				part.Transparency = 0.2
				table.insert(currentHighlights[obj], part)
				valid = true
			end
		end
	end

	-- Nếu không có part nào valid (ngoài render) thì tạo glow proxy
	if not valid then
		createGlowProxy(obj)
	end
end

-- ❌ Clear highlight 1 item
local function clearItem(obj)
	local list = currentHighlights[obj]
	if list then
		for _, part in ipairs(list) do
			if part:IsA("BasePart") then
				part.Material = Enum.Material.Plastic
				part.Transparency = 0
			end
		end
	end
	currentHighlights[obj] = nil
end

-- 🔄 Reset ALL
local function resetAll()
	for obj in pairs(currentHighlights) do
		clearItem(obj)
	end
end

-- 💾 Save
local function saveSet()
	local paths = {}
	for obj in pairs(currentHighlights) do
		table.insert(paths, getFullPath(obj))
	end
	writefile("QuanItemSet.txt", table.concat(paths, "\n"))
end

-- 🖼️ GUI setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanItemHighlighter"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 500)
frame.Position = UDim2.new(0, 50, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "QuanCheaterVN - Item Chams"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local searchBox = Instance.new("TextBox", frame)
searchBox.PlaceholderText = "Tìm item..."
searchBox.Size = UDim2.new(1, -10, 0, 25)
searchBox.Position = UDim2.new(0, 5, 0, 30)
searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
searchBox.BorderSizePixel = 0

local resetBtn = Instance.new("TextButton", frame)
resetBtn.Text = "Reset ALL"
resetBtn.Size = UDim2.new(0, 100, 0, 28)
resetBtn.Position = UDim2.new(0, 5, 0, 60)
resetBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
resetBtn.TextColor3 = Color3.new(1, 1, 1)
resetBtn.Font = Enum.Font.Gotham
resetBtn.TextSize = 13

local saveBtn = Instance.new("TextButton", frame)
saveBtn.Text = "Lưu đã set"
saveBtn.Size = UDim2.new(0, 100, 0, 28)
saveBtn.Position = UDim2.new(0, 115, 0, 60)
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.Font = Enum.Font.Gotham
saveBtn.TextSize = 13

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 1, -100)
scroll.Position = UDim2.new(0, 5, 0, 95)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scroll.BorderSizePixel = 0

-- 📋 Update danh sách
local function updateList(filter)
	for _, b in ipairs(buttons) do b:Destroy() end
	buttons = {}

	local y = 0
	for _, obj in ipairs(workspace:GetDescendants()) do
		local isValid = obj:IsA("BasePart") or (obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart"))
		if isValid then
			local path = getFullPath(obj)
			if filter == "" or path:lower():find(filter:lower()) then
				local btn = Instance.new("TextButton", scroll)
				btn.Size = UDim2.new(1, 0, 0, 28)
				btn.Position = UDim2.new(0, 0, 0, y)
				btn.Text = path
				btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				btn.TextColor3 = Color3.new(1, 1, 1)
				btn.Font = Enum.Font.Gotham
				btn.TextSize = 13
				btn.TextXAlignment = Enum.TextXAlignment.Left
				btn.BorderSizePixel = 0

				btn.MouseButton1Click:Connect(function()
					if currentHighlights[obj] then
						clearItem(obj)
						btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
					else
						highlightItem(obj)
						btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
					end
				end)

				table.insert(buttons, btn)
				y += 30
			end
		end
	end

	scroll.CanvasSize = UDim2.new(0, 0, 0, y)
end

-- 🎯 Kết nối nút và khởi động
resetBtn.MouseButton1Click:Connect(resetAll)
saveBtn.MouseButton1Click:Connect(saveSet)
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	updateList(searchBox.Text)
end)

updateList("")
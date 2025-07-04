--===[ ESP ITEM MENU - QuanCheaterVN ]===--
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local selectedItem = nil
local drawings = {}

-- Xoá ESP cũ
local function clearDrawings()
	for _, d in pairs(drawings) do
		if d and d.Remove then d:Remove() end
	end
	drawings = {}
end

-- Vẽ ESP tới item
local function drawESP(target)
	clearDrawings()
	if not target then return end

	local part = target:IsA("BasePart") and target or target:IsA("Model") and target:FindFirstChildWhichIsA("BasePart")
	if not part then return end

	local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
	if not onScreen then return end

	local box = Drawing.new("Square")
	box.Size = Vector2.new(40, 40)
	box.Position = Vector2.new(sp.X - 20, sp.Y - 20)
	box.Color = Color3.fromRGB(0, 255, 0)
	box.Thickness = 2
	box.Visible = true
	table.insert(drawings, box)

	local line = Drawing.new("Line")
	line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
	line.To = Vector2.new(sp.X, sp.Y)
	line.Color = Color3.fromRGB(0, 255, 0)
	line.Thickness = 2
	line.Visible = true
	table.insert(drawings, line)

	local txt = Drawing.new("Text")
	txt.Text = "[ITEM] " .. target.Name
	txt.Size = 15
	txt.Center = true
	txt.Outline = true
	txt.Color = Color3.fromRGB(0, 255, 0)
	txt.Position = Vector2.new(sp.X, sp.Y - 35)
	txt.Visible = true
	table.insert(drawings, txt)
end

-- Cập nhật ESP mỗi frame
game:GetService("RunService").RenderStepped:Connect(function()
	if selectedItem and selectedItem.Parent then
		drawESP(selectedItem)
	else
		clearDrawings()
	end
end)

--===[ GUI MENU ]===--
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ItemESPMenu"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 350, 0, 500)
frame.Position = UDim2.new(0, 30, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "Item ESP Menu"
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

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 1, -70)
scroll.Position = UDim2.new(0, 5, 0, 60)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scroll.BorderSizePixel = 0

local itemButtons = {}

-- Cập nhật danh sách item
local function updateList(filter)
	for _, b in pairs(itemButtons) do b:Destroy() end
	itemButtons = {}

	local y = 0
	for _, obj in ipairs(workspace:GetDescendants()) do
		local isValid = obj:IsA("BasePart") or (obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart"))
		if isValid and (filter == "" or obj.Name:lower():find(filter:lower())) then
			local btn = Instance.new("TextButton", scroll)
			btn.Size = UDim2.new(1, 0, 0, 28)
			btn.Position = UDim2.new(0, 0, 0, y)
			btn.Text = obj.Name
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 13
			btn.BorderSizePixel = 0

			btn.MouseButton1Click:Connect(function()
				selectedItem = obj
			end)

			table.insert(itemButtons, btn)
			y += 30
		end
	end

	scroll.CanvasSize = UDim2.new(0, 0, 0, y)
end

-- Search realtime
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	updateList(searchBox.Text)
end)

-- Khởi tạo lần đầu
updateList("")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "QuanClassViewer"

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 80, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "Toggle"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
toggleBtn.TextColor3 = Color3.new(1,1,1)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 400)
frame.Position = UDim2.new(0, 10, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = false

local searchBar = Instance.new("TextBox", frame)
searchBar.Size = UDim2.new(1, -20, 0, 30)
searchBar.Position = UDim2.new(0, 10, 0, 10)
searchBar.PlaceholderText = "Search class/function"
searchBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
searchBar.TextColor3 = Color3.new(1,1,1)

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -20, 1, -90)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local saveBtn = Instance.new("TextButton", frame)
saveBtn.Size = UDim2.new(0.3, 0, 0, 30)
saveBtn.Position = UDim2.new(0.05, 0, 1, -40)
saveBtn.Text = "Save"
saveBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
saveBtn.TextColor3 = Color3.new(1,1,1)

local resetBtn = Instance.new("TextButton", frame)
resetBtn.Size = UDim2.new(0.3, 0, 0, 30)
resetBtn.Position = UDim2.new(0.35, 0, 1, -40)
resetBtn.Text = "Reset"
resetBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
resetBtn.TextColor3 = Color3.new(1,1,1)

-- Toggle UI
toggleBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

local function highlightObject(obj)
	for _, d in ipairs(obj:GetDescendants()) do
		if d:IsA("BasePart") then
			d.Material = Enum.Material.ForceField
			d.Color = Color3.fromRGB(0, 200, 255)
		end
	end
end

local function resetObject(obj)
	for _, d in ipairs(obj:GetDescendants()) do
		if d:IsA("BasePart") then
			d.Material = Enum.Material.Plastic
			d.Color = Color3.fromRGB(255, 255, 255)
		end
	end
end

local selectedFuncs = {}
local allDumped = {}

local function makeRow(name, classObj)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundTransparency = 1

	local label = Instance.new("TextLabel", row)
	label.Size = UDim2.new(0.4, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left

	local function makeBtn(txt, color, callback)
		local b = Instance.new("TextButton", row)
		b.Size = UDim2.new(0, 50, 0, 25)
		b.Text = txt
		b.TextColor3 = Color3.new(1,1,1)
		b.BackgroundColor3 = color
		b.Font = Enum.Font.Gotham
		b.TextSize = 12
		b.AutoButtonColor = true
		b.MouseButton1Click:Connect(function()
			callback()
			highlightObject(classObj)
			selectedFuncs[name] = true
		end)
		return b
	end

	local btnFalse = makeBtn("False", Color3.fromRGB(70,70,200), function() end)
	btnFalse.Position = UDim2.new(0.45, 0, 0.1, 0)

	local btnReturn0 = makeBtn("Ret 0", Color3.fromRGB(120,120,120), function() end)
	btnReturn0.Position = UDim2.new(0.60, 0, 0.1, 0)

	local btnTrue = makeBtn("True", Color3.fromRGB(0,200,80), function() end)
	btnTrue.Position = UDim2.new(0.75, 0, 0.1, 0)

	return row
end

local function refreshList(filter)
	scroll:ClearAllChildren()
	local count = 0
	for _, obj in ipairs(game:GetDescendants()) do
		if obj.ClassName ~= "" and obj.Name ~= "" then
			local id = obj:GetFullName()
			if not allDumped[id] then
				allDumped[id] = true
			end
			if not filter or string.lower(id):find(filter) then
				local row = makeRow(id, obj)
				row.Parent = scroll
				row.Position = UDim2.new(0, 0, 0, count * 32)
				count += 1
			end
		end
	end
	scroll.CanvasSize = UDim2.new(0, 0, 0, count * 32)
end

searchBar:GetPropertyChangedSignal("Text"):Connect(function()
	local text = string.lower(searchBar.Text)
	refreshList(text)
end)

resetBtn.MouseButton1Click:Connect(function()
	for k in pairs(selectedFuncs) do selectedFuncs[k] = nil end
	for _, obj in ipairs(game:GetDescendants()) do resetObject(obj) end
end)

saveBtn.MouseButton1Click:Connect(function()
	local result = ""
	for k in pairs(selectedFuncs) do
		result = result .. k .. "\n"
	end
	writefile("QuanClassDump.txt", result)
end)

-- Initial load
refreshList()
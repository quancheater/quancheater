local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "QuanFunctionDebugger"
gui.ResetOnSpawn = false

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 120, 0, 30)
toggleBtn.Position = UDim2.new(0, 20, 0, 20)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 255)
toggleBtn.Text = "Toggle Menu"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 540, 0, 420)
frame.Position = UDim2.new(0, 20, 0, 60)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local searchBox = Instance.new("TextBox", frame)
searchBox.Size = UDim2.new(1, -10, 0, 30)
searchBox.Position = UDim2.new(0, 5, 0, 5)
searchBox.PlaceholderText = "Tìm tên hàm..."
searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.TextSize = 14

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 1, -80)
scroll.Position = UDim2.new(0, 5, 0, 40)
scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 6

local UIList = Instance.new("UIListLayout", scroll)
UIList.Padding = UDim.new(0, 4)

local saveBtn = Instance.new("TextButton", frame)
saveBtn.Text = "Lưu Hàm"
saveBtn.Size = UDim2.new(0, 100, 0, 28)
saveBtn.Position = UDim2.new(1, -110, 1, -35)
saveBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 13

local functionTable = {}
local edited = {}

-- fake function list demo
for i = 1, 50 do
	functionTable["Function_" .. i] = {
		Obj = workspace:FindFirstChildWhichIsA("Part", true),
		Reset = function()
			print("Reset:", i)
		end
	}
end

local function updateTable()
	for _, child in pairs(scroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for name, data in pairs(functionTable) do
		if searchBox.Text == "" or string.find(name:lower(), searchBox.Text:lower()) then
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 30)
			row.BackgroundTransparency = 1

			local label = Instance.new("TextLabel", row)
			label.Text = name
			label.Size = UDim2.new(0.75, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Color3.new(1, 1, 1)
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Font = Enum.Font.Gotham
			label.TextSize = 14

			local resetBtn = Instance.new("TextButton", row)
			resetBtn.Text = "Reset"
			resetBtn.Size = UDim2.new(0, 60, 0, 25)
			resetBtn.Position = UDim2.new(1, -70, 0.5, -12)
			resetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
			resetBtn.TextColor3 = Color3.new(1, 1, 1)
			resetBtn.Font = Enum.Font.GothamBold
			resetBtn.TextSize = 13

			resetBtn.MouseButton1Click:Connect(function()
				if data.Reset then data.Reset() end
				edited[name] = nil
				if data.Obj and data.Obj:IsA("BasePart") then
					data.Obj.Material = Enum.Material.Plastic
					data.Obj.Color = Color3.fromRGB(255, 255, 255)
				end
			end)

			row.MouseEnter:Connect(function()
				if data.Obj and data.Obj:IsA("BasePart") then
					data.Obj.Material = Enum.Material.ForceField
					data.Obj.Color = Color3.fromRGB(0, 170, 255)
					edited[name] = true
				end
			end)

			row.MouseLeave:Connect(function()
				if data.Obj and data.Obj:IsA("BasePart") then
					if not edited[name] then
						data.Obj.Material = Enum.Material.Plastic
						data.Obj.Color = Color3.fromRGB(255, 255, 255)
					end
				end
			end)

			row.Parent = scroll
		end
	end
end

searchBox:GetPropertyChangedSignal("Text"):Connect(updateTable)
updateTable()

saveBtn.MouseButton1Click:Connect(function()
	local content = ""
	for name in pairs(edited) do
		content = content .. name .. "\n"
	end
	writefile("FunctionEdited.txt", content)
end)

toggleBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)
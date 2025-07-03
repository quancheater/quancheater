local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- UI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanClassHighlighter"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 450, 0, 400)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🔍 Class Highlight Tool"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.BackgroundTransparency = 1

local searchBox = Instance.new("TextBox", frame)
searchBox.Size = UDim2.new(1, -20, 0, 25)
searchBox.Position = UDim2.new(0, 10, 0, 35)
searchBox.PlaceholderText = "Tìm class..."
searchBox.TextColor3 = Color3.new(1,1,1)
searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
searchBox.TextSize = 14
searchBox.Font = Enum.Font.Gotham

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -20, 1, -70)
scroll.Position = UDim2.new(0, 10, 0, 65)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
scroll.BorderSizePixel = 0

local UIListLayout = Instance.new("UIListLayout", scroll)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Track highlighted
local highlighted = {}

-- Glow logic
local function applyHighlight(obj)
	for _, p in pairs(obj:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Transparency = 0.3
			p.Material = Enum.Material.ForceField
			p.Color = Color3.fromRGB(0, 120, 255)
		end
	end
end

local function resetHighlight(obj)
	for _, p in pairs(obj:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Transparency = 0
			p.Material = Enum.Material.Plastic
		end
	end
end

-- Build buttons per class
local function buildButtons()
	scroll:ClearAllChildren()
	local listed = {}

	for _, obj in pairs(workspace:GetDescendants()) do
		local class = obj.ClassName
		if not listed[class] then
			if searchBox.Text == "" or string.find(class:lower(), searchBox.Text:lower()) then
				listed[class] = true

				local row = Instance.new("Frame")
				row.Size = UDim2.new(1, 0, 0, 30)
				row.BackgroundTransparency = 1
				row.Parent = scroll

				local nameLabel = Instance.new("TextLabel", row)
				nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
				nameLabel.Text = class
				nameLabel.TextColor3 = Color3.new(1,1,1)
				nameLabel.Font = Enum.Font.Gotham
				nameLabel.TextSize = 14
				nameLabel.BackgroundTransparency = 1
				nameLabel.TextXAlignment = Enum.TextXAlignment.Left

				local glowBtn = Instance.new("TextButton", row)
				glowBtn.Size = UDim2.new(0.2, 0, 1, 0)
				glowBtn.Position = UDim2.new(0.5, 5, 0, 0)
				glowBtn.Text = "Glow"
				glowBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
				glowBtn.TextColor3 = Color3.new(1, 1, 1)
				glowBtn.Font = Enum.Font.Gotham
				glowBtn.TextSize = 13

				local resetBtn = Instance.new("TextButton", row)
				resetBtn.Size = UDim2.new(0.2, 0, 1, 0)
				resetBtn.Position = UDim2.new(0.7, 10, 0, 0)
				resetBtn.Text = "Reset"
				resetBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
				resetBtn.TextColor3 = Color3.new(1, 1, 1)
				resetBtn.Font = Enum.Font.Gotham
				resetBtn.TextSize = 13

				glowBtn.MouseButton1Click:Connect(function()
					for _, item in pairs(workspace:GetDescendants()) do
						if item.ClassName == class then
							applyHighlight(item)
						end
					end
				end)

				resetBtn.MouseButton1Click:Connect(function()
					for _, item in pairs(workspace:GetDescendants()) do
						if item.ClassName == class then
							resetHighlight(item)
						end
					end
				end)
			end
		end
	end
	scroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(buildButtons)
buildButtons()
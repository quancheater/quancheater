local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local savedPaths = {}
local filePath = "SavedESPPaths.txt"

-- Tạo file nếu chưa tồn tại
if not isfile(filePath) then
    writefile(filePath, "")
else
    -- Đọc file cũ vào bảng để tránh trùng
    for line in readfile(filePath):gmatch("[^\r\n]+") do
        table.insert(savedPaths, line)
    end
end

local gui = Instance.new("ScreenGui")
gui.Name = "TouchESPMenu"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 100, 0, 30)
toggleBtn.Position = UDim2.new(1, -110, 0, 10)
toggleBtn.Text = "📋 Toggle"
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextScaled = true

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 240)
main.Position = UDim2.new(0, 50, 0, 50)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Visible = true
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
title.TextColor3 = Color3.fromRGB(255, 255, 0)
title.Text = "🔍 Nhấn vào vật thể để lấy đường dẫn + ESP"
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, 0, 1, -35)
scroll.Position = UDim2.new(0, 0, 0, 35)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0

local function saveToFile(path)
	if not table.find(savedPaths, path) then
		appendfile(filePath, path .. "\n")
	end
end

local function refreshList()
	scroll:ClearAllChildren()
	for i, path in ipairs(savedPaths) do
		local btn = Instance.new("TextButton", scroll)
		btn.Size = UDim2.new(1, -10, 0, 30)
		btn.Position = UDim2.new(0, 5, 0, (i - 1) * 35)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Text = path
		btn.Font = Enum.Font.Code
		btn.TextScaled = true
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.MouseButton1Click:Connect(function()
			setclipboard(path)
		end)
	end
	scroll.CanvasSize = UDim2.new(0, 0, 0, #savedPaths * 35)
end

local function highlightTarget(model)
	if model:FindFirstChild("ESP_Highlight") then return end
	local hl = Instance.new("Highlight")
	hl.Name = "ESP_Highlight"
	hl.FillColor = Color3.fromRGB(0, 255, 255)
	hl.FillTransparency = 0.2
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.OutlineTransparency = 0
	hl.Adornee = model
	hl.Parent = model
end

local function getFullPath(instance)
	local path = instance.Name
	local parent = instance.Parent
	while parent and parent ~= game do
		path = parent.Name .. "." .. path
		parent = parent.Parent
	end
	return "game." .. path
end

local blacklist = {
	"BasePart", "Humanoid", "MeshPart", "UnionOperation", "WedgePart", "Part", "TrussPart", "SpawnLocation"
}

local function isBlacklisted(name)
	for _, b in ipairs(blacklist) do
		if name:lower():find(b:lower()) then
			return true
		end
	end
	return false
end

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		local pos = input.Position
		local ray = camera:ScreenPointToRay(pos.X, pos.Y)
		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
		rayParams.FilterType = Enum.RaycastFilterType.Blacklist
		local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)

		if result and result.Instance then
			local model = result.Instance:FindFirstAncestorOfClass("Model") or result.Instance
			local path = getFullPath(model)

			if not table.find(savedPaths, path) then
				table.insert(savedPaths, path)
				saveToFile(path)
				refreshList()
			end

			highlightTarget(model)
		end
	end
end)

workspace.DescendantAdded:Connect(function(obj)
	if not obj:IsA("BasePart") then return end
	if obj:IsDescendantOf(LocalPlayer.Character) then return end
	if isBlacklisted(obj.Name) then return end

	local model = obj:FindFirstAncestorOfClass("Model") or obj
	if model and not model:FindFirstChild("ESP_Highlight") then
		local path = getFullPath(model)
		if not table.find(savedPaths, path) then
			table.insert(savedPaths, path)
			saveToFile(path)
			refreshList()
		end
		highlightTarget(model)
	end
end)

toggleBtn.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
end)
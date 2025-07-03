local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanESP"

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 120)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel", frame)
title.Text = "QuanCheaterVN - ESP"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local toggles, ESPObjects, itemLogged = {}, {}, {}

local function makeToggle(name, y)
    local btn = Instance.new("TextButton", frame)
    btn.Text = name .. ": OFF"
    btn.Size = UDim2.new(0, 240, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
    end)
    toggles[name] = function() return state end
end

makeToggle("Item ESP", 40)

local dump = Instance.new("TextButton", frame)
dump.Text = "Dump Game"
dump.Size = UDim2.new(0, 240, 0, 30)
dump.Position = UDim2.new(0, 10, 0, 80)
dump.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
dump.TextColor3 = Color3.fromRGB(255, 255, 255)
dump.Font = Enum.Font.Gotham
dump.TextSize = 14
dump.Parent = frame

dump.MouseButton1Click:Connect(function()
    local function deep(obj, depth)
        local indent = string.rep("  ", depth)
        local str = indent .. obj.Name .. " [" .. obj.ClassName .. "]\n"
        for _, child in ipairs(obj:GetChildren()) do
            str = str .. deep(child, depth + 1)
        end
        return str
    end
    writefile("QuanDump.txt", deep(game, 0))
end)

local function createESP(name, color)
    local d = Drawing.new("Text")
    d.Size = 14
    d.Color = color
    d.Center = true
    d.Outline = true
    d.Text = name
    d.Visible = false
    return d
end

local function updateItemESP()
    if not toggles["Item ESP"]() then
        for _, draw in pairs(ESPObjects) do if draw.Remove then draw:Remove() end end
        ESPObjects = {}
        return
    end

    for obj, draw in pairs(ESPObjects) do
        if not obj or not obj.Parent then
            if draw.Remove then draw:Remove() end
            ESPObjects[obj] = nil
        end
    end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Transparency < 1 and obj.Name ~= "" then
            if not ESPObjects[obj] then
                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt") or obj:FindFirstChildWhichIsA("ClickDetector")
                local text = createESP(obj.Name, prompt and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255))
                ESPObjects[obj] = text

                if not itemLogged[obj:GetFullName()] then
                    itemLogged[obj:GetFullName()] = true
                    appendfile("ItemsLoaded.txt", obj:GetFullName() .. "\n")
                end
            end

            local draw = ESPObjects[obj]
            local pos, visible = Camera:WorldToViewportPoint(obj.Position)
            if visible then
                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt") or obj:FindFirstChildWhichIsA("ClickDetector")
                draw.Color = prompt and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
                draw.Text = (prompt and "[Pick] " or "") .. obj.Name
                draw.Position = Vector2.new(pos.X, pos.Y)
                draw.Visible = true
            else
                draw.Visible = false
            end
        end
    end
end

RunService.RenderStepped:Connect(updateItemESP)
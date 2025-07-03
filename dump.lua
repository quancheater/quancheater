local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuanMinimalUI"

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 120)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel", frame)
title.Text = "QuanCheaterVN - ESP Dump"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local toggles, Items, touchedItems, itemLog = {}, {}, {}, {}

local function makeToggle(name, y)
    local b = Instance.new("TextButton", frame)
    b.Text = name .. ": OFF"
    b.Size = UDim2.new(0, 240, 0, 30)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.BorderSizePixel = 0
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = name .. ": " .. (state and "ON" or "OFF")
    end)
    toggles[name] = function() return state end
end

makeToggle("Item ESP", 40)
makeToggle("Touch ESP", 80)

local dump = Instance.new("TextButton", frame)
dump.Text = "Dump Game"
dump.Size = UDim2.new(0, 240, 0, 30)
dump.Position = UDim2.new(0, 10, 0, 110)
dump.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
dump.TextColor3 = Color3.fromRGB(255, 255, 255)
dump.Font = Enum.Font.Gotham
dump.TextSize = 14
dump.Parent = frame

dump.MouseButton1Click:Connect(function()
    local function deep(obj, t)
        local s = string.rep("  ", t) .. obj.Name .. " [" .. obj.ClassName .. "]\n"
        for _, c in ipairs(obj:GetChildren()) do
            s = s .. deep(c, t + 1)
        end
        return s
    end
    writefile("QuanDump.txt", deep(game, 0))
end)

local function createBox(name, color)
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
        for _, v in pairs(Items) do if v.Remove then v:Remove() end end
        Items = {}
        return
    end

    for obj, draw in pairs(Items) do
        if not obj or not obj.Parent then
            if draw.Remove then draw:Remove() end
            Items[obj] = nil
            touchedItems[obj] = nil
        end
    end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Transparency < 1 and obj.Name ~= "" then
            if not Items[obj] then
                local d = createBox(obj.Name, Color3.fromRGB(255, 255, 255))
                Items[obj] = d
                if not itemLog[obj:GetFullName()] then
                    itemLog[obj:GetFullName()] = true
                    appendfile("ItemsLoaded.txt", obj:GetFullName() .. "\n")
                end
                pcall(function()
                    obj.Touched:Connect(function() touchedItems[obj] = true end)
                end)
            end

            local draw = Items[obj]
            local show = not toggles["Touch ESP"]() or touchedItems[obj]
            if show then
                local pos, visible = Camera:WorldToViewportPoint(obj.Position)
                if visible then
                    local hasPrompt = obj:FindFirstChildWhichIsA("ProximityPrompt") or obj:FindFirstChildWhichIsA("ClickDetector")
                    draw.Color = hasPrompt and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
                    draw.Position = Vector2.new(pos.X, pos.Y)
                    draw.Text = obj.Name
                    draw.Visible = true
                else
                    draw.Visible = false
                end
            else
                draw.Visible = false
            end
        end
    end
end

RunService.RenderStepped:Connect(updateItemESP)
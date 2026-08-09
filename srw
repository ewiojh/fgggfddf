local Env = getfenv()

local LogService = game:GetService("LogService")
local getconnections = Env.getconnections
local MessageOut = "MessageOut"
local cons = getconnections(LogService[MessageOut])
if cons then
    for _, v in pairs(cons) do
        pcall(function() v:Disable() end)
    end
end

local function cleanupConnections()
    pcall(function()
        for _, conn in ipairs(getconnections(LogService.MessageOut) or {}) do
            pcall(function() conn:Disable() end)
        end
    end)
end
cleanupConnections()

print("✅ 环境净化完成，LogService 干扰已禁用")

-- ==================== 北极星风格UI（替换原XIAOXI UI） ====================
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Potato5466794/Wind/refs/heads/main/Wind.luau"))()
local Window = WindUI:CreateWindow({
    Title = "北 极 星",
    Icon = "",
    Author = "by北极星团队",
    AuthorImage = 0,
    Folder = "CloudHub",
    Size = UDim2.fromOffset(600, 450),
    Transparent = true,
    Theme = "Dark",
    UserEnabled = true,
    SideBarWidth = 135,
    HasOutline = true,
    Background = "video:https://raw.githubusercontent.com/xiaoxi9008/Server./refs/heads/main/咪.mp4",
    BackgroundImageTransparency = 0.5,
    User = {
        Enabled = true,
        Callback = function()
            WindUI:Notify({
                Title = "欢迎使用北极星",
                Content = "感谢使用北极星脚本", 
                Duration = 2,
                Icon = ""
            })
        end,
        Anonymous = false
    },
    SideBarWidth = 200,
    ScrollBarEnabled = true
})

-- 添加雪花效果
AddSnowEffect(Window.UIElements.Main.Background, 30, 14, 0.5)

Window:Tag({
    Title = "北极星",
    Radius = 10,
    Color = Color3.fromHex("#00BFFF"),
})

Window:Tag({
    Title = "稳定版",
    Radius = 10,
    Color = Color3.fromHex("#00BFFF"),
})

WindUI.Themes.Dark.Button = Color3.fromRGB(255, 255, 255)
WindUI.Themes.Dark.ButtonBorder = Color3.fromRGB(255, 255, 255)

Window:CreateTopbarButton("theme-switcher", "moon", function()
    local themes_list = {"Dark", "Light", "Mocha", "Aqua"}
    currentThemeIndex = (currentThemeIndex % #themes_list) + 1
    local newTheme = themes_list[currentThemeIndex]
    WindUI:SetTheme(newTheme)
    WindUI:Notify({
        Title = "主题已切换",
        Content = "当前主题: "..newTheme,
        Duration = 2
    })
end, 990)

WindUI.Themes.Dark.Toggle = Color3.fromHex("00BFFF")
WindUI.Themes.Dark.Checkbox = Color3.fromHex("00BFFF")
WindUI.Themes.Dark.Button = Color3.fromHex("00BFFF")
WindUI.Themes.Dark.Slider = Color3.fromHex("00BFFF")

local COLOR_SCHEMES = {
    ["北极星蓝"] = {ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("00BFFF")),
        ColorSequenceKeypoint.new(0.33, Color3.fromHex("1E90FF")),
        ColorSequenceKeypoint.new(0.66, Color3.fromHex("00CED1")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("00BFFF"))
    }), "waves"},
    
    ["极光白"] = {ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("FFFFFF")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("E0F0FF")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("FFFFFF"))
    }), "waves"},
}

Window:EditOpenButton({
    Title = "北 极 星",
    CornerRadius = UDim.new(16,16),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("00BFFF")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("FFFFFF")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("00BFFF"))
    }),
    Draggable = true,
})

local function createRainbowBorder(window, colorScheme, speed)
    local mainFrame = window.UIElements.Main
    if not mainFrame then return nil end
    
    local existingStroke = mainFrame:FindFirstChild("RainbowStroke")
    if existingStroke then
        existingStroke:Destroy()
    end
    
    if not mainFrame:FindFirstChildOfClass("UICorner") then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 16)
        corner.Parent = mainFrame
    end
    
    local rainbowStroke = Instance.new("UIStroke")
    rainbowStroke.Name = "RainbowStroke"
    rainbowStroke.Thickness = 2
    rainbowStroke.Color = Color3.new(1, 1, 1)
    rainbowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    rainbowStroke.LineJoinMode = Enum.LineJoinMode.Round
    rainbowStroke.Parent = mainFrame
    
    local glowEffect = Instance.new("UIGradient")
    glowEffect.Name = "GlowEffect"
    
    local schemeData = COLOR_SCHEMES[colorScheme or "北极星蓝"]
    if schemeData then
        glowEffect.Color = schemeData[1]
    else
        glowEffect.Color = COLOR_SCHEMES["北极星蓝"][1]
    end
    
    glowEffect.Rotation = 0
    glowEffect.Parent = rainbowStroke
    
    return rainbowStroke
end

local function startBorderAnimation(window, speed)
    local mainFrame = window.UIElements.Main
    if not mainFrame then return nil end
    
    local rainbowStroke = mainFrame:FindFirstChild("RainbowStroke")
    if not rainbowStroke then return nil end
    
    local glowEffect = rainbowStroke:FindFirstChild("GlowEffect")
    if not glowEffect then return nil end
    
    local animation = game:GetService("RunService").Heartbeat:Connect(function()
        if not rainbowStroke or rainbowStroke.Parent == nil then
            animation:Disconnect()
            return
        end
        
        local time = tick()
        glowEffect.Rotation = (time * speed * 60) % 360
    end)
    
    return animation
end

local borderAnimation
local borderEnabled = true
local currentColor = "北极星蓝"
local animationSpeed = 5

local rainbowStroke = createRainbowBorder(Window, currentColor, animationSpeed)
if rainbowStroke then
    borderAnimation = startBorderAnimation(Window, animationSpeed)
end

-- ==================== 静默功能 Tab ====================
local SilentTab = Window:Tab({
    Title = "静默功能",
    Icon = "crosshair",
    Locked = false
})

SilentTab:Button({
    Title = "绕过反作弊",
    Callback = function()
        local v4 = next
        local v5, v6 = getgc(true)
        while true do
            local v7
            v6, v7 = v4(v5, v6)
            if v6 == nil then
                break
            end
            if typeof(v7) == "function" and (getfenv(v7).script and (getfenv(v7).script.Parent == nil and not isourclosure(v7))) then
                local v8 = debug.info(v7, "s")
                if v8 ~= "[C]" and not (v8:find("Network") or v8:find("PlayerGui.Client")) then
                    hookfunction(v7, function()
                        return coroutine.yield()
                    end)
                end
            end
        end
    end
})

local vu9 = game:GetService("Workspace")
local vu10 = game:GetService("Players")
local v11 = game:GetService("RunService")
local vu12 = vu10.LocalPlayer
local vu13 = vu9.CurrentCamera
local vu14 = false
local vu15 = "Head"
local vu16 = 250
local vu17 = false
local vu18 = 100
local vu19 = nil
local vu20 = nil
local vu21 = 0
local vu22 = 0.1
local vu23 = Drawing.new("Circle")
vu23.Visible = false
vu23.Radius = vu16
vu23.Color = Color3.fromRGB(255, 255, 255)
vu23.Thickness = 1
vu23.Transparency = 1
vu23.Filled = false
vu23.Position = Vector2.new(vu13.ViewportSize.X / 2, vu13.ViewportSize.Y / 2)
local v24 = vu13
vu13.GetPropertyChangedSignal(v24, "ViewportSize"):Connect(function()
    vu23.Position = Vector2.new(vu13.ViewportSize.X / 2, vu13.ViewportSize.Y / 2)
end)

-- 静默自瞄：复活监听
local silentAimCharacterConnections = {}

local function setupSilentAimCharacterWatcher(player)
    if player == vu12 then return end
    if silentAimCharacterConnections[player] then
        silentAimCharacterConnections[player]:Disconnect()
    end
    silentAimCharacterConnections[player] = player.CharacterAdded:Connect(function()
        task.wait(0.3)
    end)
end

vu10.PlayerAdded:Connect(function(player)
    setupSilentAimCharacterWatcher(player)
end)

vu10.PlayerRemoving:Connect(function(player)
    if silentAimCharacterConnections[player] then
        silentAimCharacterConnections[player]:Disconnect()
        silentAimCharacterConnections[player] = nil
    end
end)

for _, player in ipairs(vu10:GetPlayers()) do
    if player ~= vu12 then
        setupSilentAimCharacterWatcher(player)
    end
end

local function vu42()
    if vu14 then
        local v25 = math.huge
        local v26 = vu13.CFrame
        local v27 = v26.Position
        local v28 = v26.LookVector
        local v29 = vu10
        local v30, v31, v32 = ipairs(v29:GetPlayers())
        local v33 = nil
        while true do
            local v34
            v32, v34 = v30(v31, v32)
            if v32 == nil then
                break
            end
            if v34 ~= vu12 then
                if not PlayerExists(v34) then continue end
                if checkIsTeammate(v34) then continue end
                if not IsPlayerAlive(v34) then continue end
                if not CharacterExists(v34) then continue end
                
                local v35 = v34.Character
                local v36
                if vu15 ~= "随机" then
                    v36 = v35:FindFirstChild(vu15)
                else
                    local v37 = {
                        "Head",
                        "HumanoidRootPart",
                        "Left Arm",
                        "Right Arm",
                        "Left Leg",
                        "Right Leg"
                    }
                    v36 = v35:FindFirstChild(v37[math.random(1, #v37)])
                end
                if v36 and HumanoidExists(v35) then
                    local v38 = v35:FindFirstChildOfClass("Humanoid")
                    if v38.Health > 0 and not v35:FindFirstChild("ForceField") then
                        local v39 = v36.Position - v27
                        local v40 = v39.Magnitude
                        if math.deg(math.acos(v28:Dot(v39.Unit))) <= vu16 / 10 and v40 < v25 then
                            if vu17 then
                                local v41 = RaycastParams.new()
                                v41.FilterDescendantsInstances = {
                                    vu12.Character,
                                    v35
                                }
                                v41.FilterType = Enum.RaycastFilterType.Blacklist
                                if not vu9:Raycast(v27, v39, v41) then
                                    v33 = v36
                                    v25 = v40
                                end
                            else
                                v33 = v36
                                v25 = v40
                            end
                        end
                    end
                end
            end
        end
        vu20 = v33
    else
        vu20 = nil
    end
end

v11.RenderStepped:Connect(function()
    if vu22 < tick() - vu21 then
        vu21 = tick()
        vu42()
    end
end)

local function vu43()
    return vu20
end

vu19 = hookmetamethod(game, "__namecall", function(p44, ...)
    local v45 = getnamecallmethod()
    if checkcaller() or (p44 ~= vu9 or v45 ~= "Raycast" and v45 ~= "FindPartOnRay") then
        return vu19(p44, ...)
    end
    local v46 = vu43()
    if v46 and math.random(1, 100) <= vu18 then
        local v47 = {
            ...
        }
        local v48 = nil
        local v49 = nil
        if v45 == "Raycast" then
            v48 = v47[1]
            v49 = v47[2]
        else
            local v50 = v47[1]
            if typeof(v50) == "Ray" then
                v48 = v50.Origin
                v49 = v50.Direction
            end
        end
        if v48 and v49 then
            return {
                Instance = v46,
                Position = v46.Position,
                Normal = (v46.Position - v48).Unit,
                Material = Enum.Material.Plastic
            }
        end
    end
    return vu19(p44, ...)
end)

local vu51 = false
local vu52 = Drawing.new("Line")
vu52.Visible = false
vu52.Thickness = 1
vu52.Transparency = 1
vu52.Color = Color3.fromRGB(255, 255, 255)

local function vu65(p60)
    local v61, v62 = vu13:WorldToViewportPoint(p60)
    if not v62 then
        return false
    end
    local v63 = v61.X - vu23.Position.X
    local v64 = v61.Y - vu23.Position.Y
    return v63 * v63 + v64 * v64 <= vu16 * vu16
end

v11.RenderStepped:Connect(function()
    if vu51 and vu14 then
        local v66 = vu20
        if v66 then
            local v67 = v66.Parent
            if v67 then
                local v68 = vu10:GetPlayerFromCharacter(v67)
                if v68 then
                    if not PlayerExists(v68) then
                        vu52.Visible = false
                        return
                    end
                    if checkIsTeammate(v68) then
                        vu52.Visible = false
                        return
                    end
                    if not IsPlayerAlive(v68) then
                        vu52.Visible = false
                        return
                    end
                    
                    local v69 = v67:FindFirstChildOfClass("Humanoid")
                    if v69 and v69.Health > 0 then
                        if vu17 then
                            local v70 = RaycastParams.new()
                            v70.FilterDescendantsInstances = {
                                vu12.Character,
                                v67
                            }
                            v70.FilterType = Enum.RaycastFilterType.Blacklist
                            if vu9:Raycast(vu13.CFrame.Position, v66.Position - vu13.CFrame.Position, v70) then
                                vu52.Visible = false
                                return
                            end
                        end
                        if vu15 == "随机" then
                            v66 = v67:FindFirstChild("HumanoidRootPart") or v66
                        end
                        local v71 = v66.Position
                        if vu65(v71) then
                            local v72, v73 = vu13:WorldToViewportPoint(v71)
                            if v73 then
                                vu52.From = Vector2.new(vu23.Position.X, vu23.Position.Y)
                                vu52.To = Vector2.new(v72.X, v72.Y)
                                vu52.Visible = true
                            else
                                vu52.Visible = false
                            end
                        else
                            vu52.Visible = false
                            return
                        end
                    else
                        vu52.Visible = false
                        return
                    end
                else
                    vu52.Visible = false
                    return
                end
            else
                vu52.Visible = false
                return
            end
        else
            vu52.Visible = false
            return
        end
    else
        vu52.Visible = false
        return
    end
end)

SilentTab:Toggle({
    Title = "静默子踪",
    Value = false,
    Callback = function(p74)
        vu14 = p74
        vu23.Visible = p74
        if not p74 then
            vu52.Visible = false
        end
    end
})

SilentTab:Slider({
    Title = "fov范围",
    Value = {
        Min = 100,
        Max = 300,
        Default = 250
    },
    Callback = function(p75)
        vu16 = tonumber(p75)
        vu23.Radius = vu16
    end
})

SilentTab:Dropdown({
    Title = "默认部位",
    Multi = false,
    AllowNone = false,
    Value = "头部",
    Values = {
        "头部",
        "身体",
        "左手臂",
        "右手臂",
        "左腿",
        "右腿",
        "随机"
    },
    Callback = function(p76)
        if p76 == "头部" then vu15 = "Head"
        elseif p76 == "身体" then vu15 = "HumanoidRootPart"
        elseif p76 == "左手臂" then vu15 = "Left Arm"
        elseif p76 == "右手臂" then vu15 = "Right Arm"
        elseif p76 == "左腿" then vu15 = "Left Leg"
        elseif p76 == "右腿" then vu15 = "Right Leg"
        elseif p76 == "随机" then vu15 = "随机"
        else vu15 = p76 end
    end
})

SilentTab:Toggle({
    Title = "墙壁检测（关掉即可成为美国子弹）",
    Value = false,
    Callback = function(p77)
        vu17 = p77
    end
})

SilentTab:Slider({
    Title = "秒杀概率",
    Value = {
        Min = 1,
        Max = 100,
        Default = 100
    },
    Callback = function(p78)
        vu18 = tonumber(p78)
    end
})

SilentTab:Toggle({
    Title = "瞄人提示",
    Value = false,
    Callback = function(p79)
        vu51 = p79
        if not p79 then
            vu52.Visible = false
        end
    end
})

SilentTab:Toggle({
    Title = "队伍检测",
    Value = false,
    Callback = function(state)
        TeamCheckConfig.Enabled = state
    end
})

-- ==================== 透视功能 Tab ====================
local ESPTab = Window:Tab({
    Title = "透视功能",
    Icon = "eye",
    Locked = false
})

local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = game:GetService("CoreGui")
local lplayer = Players.LocalPlayer
local Cam = Workspace.CurrentCamera

local ESPSettings = {
    Enabled = false,
    MaxDistance = 200,
    FontSize = 11,
    TeamCheck = false,
    Drawing = {
        Names = { Enabled = true, RGB = Color3.fromRGB(255, 255, 255) },
        Distances = { Enabled = true, Position = "Text", RGB = Color3.fromRGB(255, 255, 255) },
        Weapons = { Enabled = true, WeaponTextRGB = Color3.fromRGB(119, 120, 255) },
        Healthbar = { Enabled = true, HealthText = true, HealthTextRGB = Color3.fromRGB(0, 255, 0), Width = 2.5 },
        Boxes = {
            Full = { Enabled = true, RGB = Color3.fromRGB(255, 255, 255) },
            Corner = { Enabled = true, RGB = Color3.fromRGB(255, 255, 255) },
            Filled = { Enabled = true, Transparency = 0.75, RGB = Color3.fromRGB(0, 0, 0) },
        },
    },
}

local function Create(Class, Properties)
    local _Instance = typeof(Class) == 'string' and Instance.new(Class) or Class
    for Property, Value in pairs(Properties) do
        _Instance[Property] = Value
    end
    return _Instance
end

local function FadeOutOnDist(element, distance)
    if not element then return end
    local transparency = math.max(0.1, 1 - (distance / ESPSettings.MaxDistance))
    if element:IsA("TextLabel") then
        element.TextTransparency = 1 - transparency
    elseif element:IsA("ImageLabel") then
        element.ImageTransparency = 1 - transparency
    elseif element:IsA("UIStroke") then
        element.Transparency = 1 - transparency
    elseif element:IsA("Frame") then
        element.BackgroundTransparency = 1 - transparency
    end
end

-- 内透系统
local Highlights = {}
local HighlightSettings = {
    Enabled = false,
    Color = Color3.fromRGB(255, 0, 0),
    FillTransparency = 0.5,
    OutlineTransparency = 0,
}

local function CreateHighlight(player)
    if not PlayerExists(player) then return end
    if not HighlightSettings.Enabled then return end
    if not IsPlayerAlive(player) then return end
    if checkIsTeammate(player) then return end
    if not CharacterExists(player) then return end
    
    if Highlights[player] then
        pcall(function() Highlights[player]:Destroy() end)
        Highlights[player] = nil
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "StandaloneHighlight"
    highlight.Adornee = player.Character
    highlight.FillTransparency = HighlightSettings.FillTransparency
    highlight.OutlineTransparency = HighlightSettings.OutlineTransparency
    highlight.FillColor = HighlightSettings.Color
    highlight.OutlineColor = HighlightSettings.Color
    highlight.Parent = player.Character
    Highlights[player] = highlight
end

local function RemoveHighlight(player)
    if Highlights[player] then
        pcall(function() Highlights[player]:Destroy() end)
        Highlights[player] = nil
    end
end

local function RefreshAllHighlights()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= lplayer then
            if HighlightSettings.Enabled and IsPlayerAlive(player) and not checkIsTeammate(player) then
                CreateHighlight(player)
            else
                RemoveHighlight(player)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= lplayer then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if HighlightSettings.Enabled and IsPlayerAlive(player) and not checkIsTeammate(player) then
                CreateHighlight(player)
            end
        end)
        RefreshAllHighlights()
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveHighlight(player)
end)

RunService.RenderStepped:Connect(function()
    if not HighlightSettings.Enabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= lplayer then
            local shouldShow = PlayerExists(player) and IsPlayerAlive(player) and not checkIsTeammate(player)
            local hasHighlight = Highlights[player] ~= nil
            if shouldShow and not hasHighlight then
                CreateHighlight(player)
            elseif not shouldShow and hasHighlight then
                RemoveHighlight(player)
            end
        end
    end
end)

-- ESP系统
local ScreenGui = nil
local vu88 = {}

local function CreatePlayerESP(plr)
    if not ScreenGui then return end
    if vu88[plr] then return end

    local Name = Create("TextLabel", { Parent = ScreenGui, Position = UDim2.new(0.5, 0, 0, -11), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESPSettings.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true })
    local Distance = Create("TextLabel", { Parent = ScreenGui, Position = UDim2.new(0.5, 0, 0, 11), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESPSettings.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true })
    local Weapon = Create("TextLabel", { Parent = ScreenGui, Position = UDim2.new(0.5, 0, 0, 31), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESPSettings.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true })
    local Box = Create("Frame", { Parent = ScreenGui, BackgroundColor3 = ESPSettings.Drawing.Boxes.Filled.RGB, BackgroundTransparency = 0.75, BorderSizePixel = 0 })
    local Outline = Create("UIStroke", { Parent = Box, Enabled = true, Transparency = 0, Color = ESPSettings.Drawing.Boxes.Full.RGB, LineJoinMode = Enum.LineJoinMode.Miter })
    local Healthbar = Create("Frame", { Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(0, 255, 0), BackgroundTransparency = 0 })
    local BehindHealthbar = Create("Frame", { Parent = ScreenGui, ZIndex = -1, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0 })
    local HealthText = Create("TextLabel", { Parent = ScreenGui, Position = UDim2.new(0.5, 0, 0, 31), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = ESPSettings.Drawing.Healthbar.HealthTextRGB, Font = Enum.Font.Code, TextSize = ESPSettings.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0) })
    local LeftTop = Create("Frame", { Parent = ScreenGui, BackgroundColor3 = ESPSettings.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0) })
    local LeftSide = Create("Frame", { Parent = ScreenGui, BackgroundColor3 = ESPSettings.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0) })
    local RightTop = Create("Frame", { Parent = ScreenGui, BackgroundColor3 = ESPSettings.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0) })
    local RightSide = Create("Frame", { Parent = ScreenGui, BackgroundColor3 = ESPSettings.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0) })
    local BottomSide = Create("Frame", { Parent = ScreenGui, BackgroundColor3 = ESPSettings.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0) })
    local BottomDown = Create("Frame", { Parent = ScreenGui, BackgroundColor3 = ESPSettings.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0) })
    local BottomRightSide = Create("Frame", { Parent = ScreenGui, BackgroundColor3 = ESPSettings.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0) })
    local BottomRightDown = Create("Frame", { Parent = ScreenGui, BackgroundColor3 = ESPSettings.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0) })

    local function HideESP()
        Box.Visible, Name.Visible, Distance.Visible, Weapon.Visible = false, false, false, false
        Healthbar.Visible, BehindHealthbar.Visible, HealthText.Visible = false, false, false
        LeftTop.Visible, LeftSide.Visible, RightTop.Visible, RightSide.Visible = false, false, false, false
        BottomSide.Visible, BottomDown.Visible, BottomRightSide.Visible, BottomRightDown.Visible = false, false, false, false
    end

    local function CleanupESP()
        HideESP()
        pcall(function() Name:Destroy() end)
        pcall(function() Distance:Destroy() end)
        pcall(function() Weapon:Destroy() end)
        pcall(function() Box:Destroy() end)
        pcall(function() Healthbar:Destroy() end)
        pcall(function() BehindHealthbar:Destroy() end)
        pcall(function() HealthText:Destroy() end)
        pcall(function() LeftTop:Destroy() end)
        pcall(function() LeftSide:Destroy() end)
        pcall(function() RightTop:Destroy() end)
        pcall(function() RightSide:Destroy() end)
        pcall(function() BottomSide:Destroy() end)
        pcall(function() BottomDown:Destroy() end)
        pcall(function() BottomRightSide:Destroy() end)
        pcall(function() BottomRightDown:Destroy() end)
    end

    local connection = RunService.RenderStepped:Connect(function()
        if not ESPSettings.Enabled then
            HideESP()
            return
        end

        if not PlayerExists(plr) then
            HideESP()
            return
        end
        
        if checkIsTeammate(plr) then
            HideESP()
            return
        end

        if not IsPlayerAlive(plr) then
            HideESP()
            return
        end

        if not CharacterExists(plr) then
            HideESP()
            return
        end

        if not PartExists(plr.Character, "HumanoidRootPart") then
            HideESP()
            return
        end

        local HRP = plr.Character.HumanoidRootPart
        local Humanoid = plr.Character:FindFirstChild("Humanoid")
        if not Humanoid then
            HideESP()
            return
        end
        
        local Pos, OnScreen = Cam:WorldToScreenPoint(HRP.Position)
        local Dist = (Cam.CFrame.Position - HRP.Position).Magnitude / 3.5714285714
        if OnScreen and Dist <= ESPSettings.MaxDistance then
            local Size = HRP.Size.Y
            local scaleFactor = (Size * Cam.ViewportSize.Y) / (Pos.Z * 2)
            local w, h = 3 * scaleFactor, 4.5 * scaleFactor

            FadeOutOnDist(Box, Dist)
            FadeOutOnDist(Outline, Dist)
            FadeOutOnDist(Name, Dist)
            FadeOutOnDist(Distance, Dist)
            FadeOutOnDist(Weapon, Dist)
            FadeOutOnDist(Healthbar, Dist)
            FadeOutOnDist(BehindHealthbar, Dist)
            FadeOutOnDist(HealthText, Dist)
            FadeOutOnDist(LeftTop, Dist)
            FadeOutOnDist(LeftSide, Dist)
            FadeOutOnDist(RightTop, Dist)
            FadeOutOnDist(RightSide, Dist)
            FadeOutOnDist(BottomSide, Dist)
            FadeOutOnDist(BottomDown, Dist)
            FadeOutOnDist(BottomRightSide, Dist)
            FadeOutOnDist(BottomRightDown, Dist)

            LeftTop.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
            LeftTop.Size = UDim2.new(0, w / 5, 0, 1)
            LeftTop.Visible = ESPSettings.Drawing.Boxes.Corner.Enabled
            LeftSide.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
            LeftSide.Size = UDim2.new(0, 1, 0, h / 5)
            LeftSide.Visible = ESPSettings.Drawing.Boxes.Corner.Enabled
            RightTop.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y - h / 2)
            RightTop.Size = UDim2.new(0, w / 5, 0, 1)
            RightTop.AnchorPoint = Vector2.new(1, 0)
            RightTop.Visible = ESPSettings.Drawing.Boxes.Corner.Enabled
            RightSide.Position = UDim2.new(0, Pos.X + w / 2 - 1, 0, Pos.Y - h / 2)
            RightSide.Size = UDim2.new(0, 1, 0, h / 5)
            RightSide.AnchorPoint = Vector2.new(0, 0)
            RightSide.Visible = ESPSettings.Drawing.Boxes.Corner.Enabled
            BottomSide.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y + h / 2)
            BottomSide.Size = UDim2.new(0, 1, 0, h / 5)
            BottomSide.AnchorPoint = Vector2.new(0, 5)
            BottomSide.Visible = ESPSettings.Drawing.Boxes.Corner.Enabled
            BottomDown.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y + h / 2)
            BottomDown.Size = UDim2.new(0, w / 5, 0, 1)
            BottomDown.AnchorPoint = Vector2.new(0, 1)
            BottomDown.Visible = ESPSettings.Drawing.Boxes.Corner.Enabled
            BottomRightSide.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y + h / 2)
            BottomRightSide.Size = UDim2.new(0, 1, 0, h / 5)
            BottomRightSide.AnchorPoint = Vector2.new(1, 1)
            BottomRightSide.Visible = ESPSettings.Drawing.Boxes.Corner.Enabled
            BottomRightDown.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y + h / 2)
            BottomRightDown.Size = UDim2.new(0, w / 5, 0, 1)
            BottomRightDown.AnchorPoint = Vector2.new(1, 1)
            BottomRightDown.Visible = ESPSettings.Drawing.Boxes.Corner.Enabled

            Box.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
            Box.Size = UDim2.new(0, w, 0, h)
            Box.Visible = ESPSettings.Drawing.Boxes.Full.Enabled
            Box.BackgroundColor3 = ESPSettings.Drawing.Boxes.Filled.RGB
            Box.BackgroundTransparency = ESPSettings.Drawing.Boxes.Filled.Enabled and ESPSettings.Drawing.Boxes.Filled.Transparency or 1
            Outline.Color = ESPSettings.Drawing.Boxes.Full.RGB

            local health = Humanoid.Health / Humanoid.MaxHealth
            Healthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2 + h * (1 - health))
            Healthbar.Size = UDim2.new(0, ESPSettings.Drawing.Healthbar.Width, 0, h * health)
            Healthbar.Visible = ESPSettings.Drawing.Healthbar.Enabled
            BehindHealthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2)
            BehindHealthbar.Size = UDim2.new(0, ESPSettings.Drawing.Healthbar.Width, 0, h)
            BehindHealthbar.Visible = ESPSettings.Drawing.Healthbar.Enabled

            if ESPSettings.Drawing.Healthbar.HealthText then
                local healthPercentage = math.floor(Humanoid.Health / Humanoid.MaxHealth * 100)
                HealthText.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2 + h * (1 - healthPercentage / 100) + 3)
                HealthText.Text = tostring(healthPercentage)
                HealthText.Visible = Humanoid.Health < Humanoid.MaxHealth
                HealthText.TextColor3 = ESPSettings.Drawing.Healthbar.HealthTextRGB
            else
                HealthText.Visible = false
            end

            Name.Text = plr.Name
            Name.Position = UDim2.new(0, Pos.X, 0, Pos.Y - h / 2 - 9)
            Name.Visible = ESPSettings.Drawing.Names.Enabled

            if ESPSettings.Drawing.Distances.Enabled then
                if ESPSettings.Drawing.Distances.Position == "Text" then
                    Distance.Visible = false
                    Name.Text = plr.Name .. " [" .. math.floor(Dist) .. "]"
                else
                    Distance.Position = UDim2.new(0, Pos.X, 0, Pos.Y + h / 2 + 7)
                    Distance.Text = math.floor(Dist) .. " meters"
                    Distance.Visible = true
                end
            end
        else
            HideESP()
        end
    end)

    vu88[plr] = {
        connection = connection,
        cleanup = CleanupESP
    }
end

local function removeESPForPlayer(plr)
    if vu88[plr] then
        if vu88[plr].connection then
            pcall(function() vu88[plr].connection:Disconnect() end)
        end
        if vu88[plr].cleanup then
            pcall(function() vu88[plr].cleanup() end)
        end
        vu88[plr] = nil
    end
end

Players.PlayerRemoving:Connect(function(plr)
    removeESPForPlayer(plr)
end)

Players.PlayerAdded:Connect(function(player)
    if player ~= lplayer then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if ESPSettings.Enabled and IsPlayerAlive(player) and not checkIsTeammate(player) then
                if vu88[player] then
                    removeESPForPlayer(player)
                end
                CreatePlayerESP(player)
            end
        end)
    end
end)

local function vu158()
    for player, _ in pairs(Highlights) do
        RemoveHighlight(player)
    end
    Highlights = {}

    for plr, data in pairs(vu88) do
        removeESPForPlayer(plr)
    end
    
    if ScreenGui then
        ScreenGui:Destroy()
        ScreenGui = nil
    end
    
    vu88 = {}
    ESPSettings.Enabled = false
    HighlightSettings.Enabled = false
end

local function vu153()
    vu158()
    ESPSettings.Enabled = true
    ScreenGui = Create("ScreenGui", { Parent = CoreGui, Name = "ESPHolder" })

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lplayer and not vu88[v] then
            CreatePlayerESP(v)
        end
    end

    vu88.PlayerAdded = Players.PlayerAdded:Connect(function(v)
        if v ~= lplayer and not vu88[v] then
            CreatePlayerESP(v)
        end
    end)
end

local ESPSection = ESPTab:Section({
    Title = "ESP 设置",
})

ESPSection:Toggle({
    Title = "总开关ESP",
    Value = false,
    Callback = function(state)
        if state then
            vu153()
        else
            vu158()
        end
    end
})

ESPSection:Toggle({
    Title = "ESP队伍检测",
    Value = false,
    Callback = function(state)
        ESPSettings.TeamCheck = state
    end
})

ESPSection:Toggle({
    Title = "内透 (Highlight)",
    Value = false,
    Callback = function(state)
        HighlightSettings.Enabled = state
        if state then
            RefreshAllHighlights()
        else
            for player, _ in pairs(Highlights) do
                RemoveHighlight(player)
            end
        end
    end
})

-- ==================== 自瞄功能 Tab ====================
local AimbotTab = Window:Tab({
    Title = "瞄准功能",
    Icon = "crosshair",
    Locked = false
})

local AimbotConfig = {
    Enabled = false,
    AimPart = "Head",
    CoverCheck = true,
    FOV = 400,
    Smoothness = 1
}

local aimbotCharacterConnections = {}

local function setupAimbotCharacterWatcher(player)
    if player == lplayer then return end
    if aimbotCharacterConnections[player] then
        aimbotCharacterConnections[player]:Disconnect()
    end
    aimbotCharacterConnections[player] = player.CharacterAdded:Connect(function()
        task.wait(0.3)
    end)
end

Players.PlayerAdded:Connect(function(player)
    if player ~= lplayer then
        setupAimbotCharacterWatcher(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if aimbotCharacterConnections[player] then
        aimbotCharacterConnections[player]:Disconnect()
        aimbotCharacterConnections[player] = nil
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= lplayer then
        setupAimbotCharacterWatcher(player)
    end
end

local function isTargetBehindCover(targetPart)
    if not AimbotConfig.CoverCheck then return false end
    if not CharacterExists(lplayer) then return true end
    local character = lplayer.Character
    local startPart = character:FindFirstChild("Head") or character:FindFirstChild("UpperTorso")
    if not startPart or not targetPart then return true end
    local startPos = startPart.Position
    local targetPos = targetPart.Position
    local direction = (targetPos - startPos).Unit
    local distance = (targetPos - startPos).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = { character, targetPart.Parent }
    raycastParams.IgnoreWater = true
    local raycastResult = Workspace:Raycast(startPos, direction * distance, raycastParams)
    return raycastResult ~= nil
end

local function smoothLookAt(targetPosition)
    local camera = Workspace.CurrentCamera
    local currentCFrame = camera.CFrame
    local targetCFrame = CFrame.new(currentCFrame.Position, targetPosition)
    if AimbotConfig.Smoothness > 1 then
        local smoothFactor = 1 / AimbotConfig.Smoothness
        camera.CFrame = currentCFrame:Lerp(targetCFrame, smoothFactor)
    else
        camera.CFrame = targetCFrame
    end
end

local function getClosestAimbotTarget()
    local nearest = nil
    local lastDistance = math.huge
    local camera = Workspace.CurrentCamera
    local mousePos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player == lplayer then continue end
        if not PlayerExists(player) then continue end
        if checkIsTeammate(player) then continue end
        if not IsPlayerAlive(player) then continue end
        if not CharacterExists(player) then continue end
        
        local aimPart = player.Character:FindFirstChild(AimbotConfig.AimPart) or player.Character:FindFirstChild("UpperTorso")
        if not aimPart then continue end
        
        if isTargetBehindCover(aimPart) then continue end
        local screenPos, onScreen = camera:WorldToViewportPoint(aimPart.Position)
        if not onScreen then continue end
        local screenPoint = Vector2.new(screenPos.X, screenPos.Y)
        local distance = (screenPoint - mousePos).Magnitude
        if distance < lastDistance and distance < AimbotConfig.FOV then
            lastDistance = distance
            nearest = player
        end
    end

    return nearest
end

local aimbotConnection = RunService.RenderStepped:Connect(function()
    if not AimbotConfig.Enabled then return end
    local target = getClosestAimbotTarget()
    if not target then return end
    if not CharacterExists(target) then return end
    local character = target.Character
    local aimPart = character:FindFirstChild(AimbotConfig.AimPart) or character:FindFirstChild("UpperTorso")
    if aimPart then
        smoothLookAt(aimPart.Position)
    end
end)

AimbotTab:Toggle({
    Title = "开启自瞄",
    Value = false,
    Callback = function(state)
        AimbotConfig.Enabled = state
    end
})

AimbotTab:Toggle({
    Title = "掩体检测",
    Value = true,
    Callback = function(state)
        AimbotConfig.CoverCheck = state
    end
})

AimbotTab:Dropdown({
    Title = "瞄准部位",
    Multi = false,
    AllowNone = false,
    Value = "头部",
    Values = { "头部", "身体", "左手臂", "右手臂", "左腿", "右腿" },
    Callback = function(value)
        if value == "头部" then AimbotConfig.AimPart = "Head"
        elseif value == "身体" then AimbotConfig.AimPart = "HumanoidRootPart"
        elseif value == "左手臂" then AimbotConfig.AimPart = "Left Arm"
        elseif value == "右手臂" then AimbotConfig.AimPart = "Right Arm"
        elseif value == "左腿" then AimbotConfig.AimPart = "Left Leg"
        elseif value == "右腿" then AimbotConfig.AimPart = "Right Leg"
        end
    end
})

AimbotTab:Slider({
    Title = "FOV范围",
    Value = { Min = 50, Max = 1000, Default = 400 },
    Callback = function(value)
        AimbotConfig.FOV = tonumber(value)
    end
})

AimbotTab:Slider({
    Title = "平滑度",
    Value = { Min = 1, Max = 10, Default = 1 },
    Callback = function(value)
        AimbotConfig.Smoothness = tonumber(value)
    end
})

-- ==================== 单枪愤怒 Tab ====================
local RS = game:GetService("ReplicatedStorage")
local Events = {
    Handle = RS:WaitForChild("Events"):WaitForChild("HandleShots"),
    Anim = RS:WaitForChild("URE_ViewmodelAnimStream"),
    Damage = RS:WaitForChild("Events"):WaitForChild("\224\182\189\224\183\128\224\182\158\224\182\169")
}

local RageConfig = {
    RageShootEnabled = false,
    RageShootMultiplier = 3,
    RageShootTarget = "Head",
    RageShootInterval = 0.001
}

local rageCharacterConnections = {}

local function setupRageCharacterWatcher(player)
    if player == lplayer then return end
    if rageCharacterConnections[player] then
        rageCharacterConnections[player]:Disconnect()
    end
    rageCharacterConnections[player] = player.CharacterAdded:Connect(function()
        task.wait(0.2)
    end)
end

Players.PlayerAdded:Connect(function(player)
    if player ~= lplayer then
        setupRageCharacterWatcher(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if rageCharacterConnections[player] then
        rageCharacterConnections[player]:Disconnect()
        rageCharacterConnections[player] = nil
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= lplayer then
        setupRageCharacterWatcher(player)
    end
end

local function playShootSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://6534948092"
    sound.Volume = 1
    sound.Parent = Workspace.CurrentCamera
    sound.PlayOnRemove = true
    sound:Destroy()
end

local function createBeam(startPos, endPos)
    local part1 = Instance.new("Part")
    part1.Anchored = true
    part1.CanCollide = false
    part1.Transparency = 1
    part1.Size = Vector3.new(0.1, 0.1, 0.1)
    part1.Position = startPos
    part1.Parent = Workspace

    local part2 = Instance.new("Part")
    part2.Anchored = true
    part2.CanCollide = false
    part2.Transparency = 1
    part2.Size = Vector3.new(0.1, 0.1, 0.1)
    part2.Position = endPos
    part2.Parent = Workspace

    local attachment1 = Instance.new("Attachment", part1)
    local attachment2 = Instance.new("Attachment", part2)

    local beam1 = Instance.new("Beam", part1)
    beam1.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
    beam1.Transparency = NumberSequence.new(0)
    beam1.Width0 = 0.25
    beam1.Width1 = 0.25
    beam1.Texture = "rbxassetid://7136858729"
    beam1.TextureSpeed = 0.8
    beam1.TextureMode = Enum.TextureMode.Wrap
    beam1.Brightness = 1
    beam1.LightEmission = 0
    beam1.FaceCamera = true
    beam1.Attachment0 = attachment1
    beam1.Attachment1 = attachment2

    local beam2 = Instance.new("Beam", part1)
    beam2.Color = ColorSequence.new(Color3.fromRGB(180, 200, 255))
    beam2.Transparency = NumberSequence.new(0.4)
    beam2.Width0 = 0.12
    beam2.Width1 = 0.12
    beam2.Texture = "rbxassetid://7136858729"
    beam2.TextureSpeed = 1.2
    beam2.TextureMode = Enum.TextureMode.Wrap
    beam2.Brightness = 1.2
    beam2.LightEmission = 0.6
    beam2.FaceCamera = true
    beam2.Attachment0 = attachment1
    beam2.Attachment1 = attachment2

    local shaking = true
    task.spawn(function()
        while shaking and part1 and part1.Parent do
            attachment1.Position = Vector3.new(math.random(-3, 3) / 100, math.random(-3, 3) / 100, math.random(-3, 3) / 100)
            attachment2.Position = Vector3.new(math.random(-3, 3) / 100, math.random(-3, 3) / 100, math.random(-3, 3) / 100)
            task.wait(0.02)
        end
    end)

    task.delay(math.random(10, 40) / 10, function()
        shaking = false
        for i = 0, 1, 0.05 do
            if not part1 or not part1.Parent then break end
            beam1.Transparency = NumberSequence.new(i)
            beam2.Transparency = NumberSequence.new(0.4 + i * 0.6)
            task.wait(0.03)
        end
        pcall(function() part1:Destroy() end)
        pcall(function() part2:Destroy() end)
    end)
end

local function getShootOrigin()
    if not CharacterExists(lplayer) then return nil end
    local char = lplayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        return hrp.Position + Vector3.new(0, 5, 0)
    end
    return nil
end

local function GetTarget()
    local target, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lplayer then
            if not PlayerExists(p) then continue end
            if checkIsTeammate(p) then continue end
            if not IsPlayerAlive(p) then continue end
            if not CharacterExists(p) then continue end
            if not PartExists(p.Character, RageConfig.RageShootTarget) then continue end
            
            local targetPart = p.Character[RageConfig.RageShootTarget]
            local origin = getShootOrigin()
            if origin then
                local d = (targetPart.Position - origin).Magnitude
                if d < dist then
                    dist = d
                    target = p.Character
                end
            end
        end
    end
    return target
end

local function RageShot()
    local targetChar = GetTarget()
    local weaponObj = RS.Weapons:FindFirstChild("G-17")
    if targetChar and weaponObj then
        local targetPart = targetChar:FindFirstChild(RageConfig.RageShootTarget)
        local origin = getShootOrigin()
        if targetPart and origin then
            playShootSound()
            createBeam(origin, targetPart.Position)
            Events.Handle:FireServer("2", "Shoot")
            Events.Anim:FireServer(true, "fire2", "fire")
            local hitData = {
                ["Normal"] = Vector3.new(-0.454, 0.225, 0.862),
                ["Hit"] = targetChar,
                ["PartName"] = RageConfig.RageShootTarget,
                ["hS"] = 2.4494898319244385,
                ["Position"] = targetPart.Position
            }
            local damageArgs = {
                [1] = hitData,
                [2] = weaponObj,
                [4] = true
            }
            for i = 1, RageConfig.RageShootMultiplier do
                Events.Damage:FireServer(unpack(damageArgs))
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(RageConfig.RageShootInterval)
        if RageConfig.RageShootEnabled then
            pcall(RageShot)
        end
    end
end)

local ViolenceTab1 = Window:Tab({
    Title = "单枪愤怒",
    Icon = "eye",
    Locked = false
})

ViolenceTab1:Toggle({
    Title = "愤怒机器人（迷你G手枪）",
    Value = false,
    Callback = function(state)
        RageConfig.RageShootEnabled = state
    end
})

ViolenceTab1:Slider({
    Title = "伤害倍率",
    Value = { Min = 1, Max = 10, Default = 3 },
    Callback = function(value)
        RageConfig.RageShootMultiplier = tonumber(value)
    end
})

ViolenceTab1:Dropdown({
    Title = "目标部位",
    Multi = false,
    AllowNone = false,
    Value = "Head",
    Values = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
    Callback = function(value)
        RageConfig.RageShootTarget = value
    end
})

-- ==================== 全枪愤怒 Tab ====================
local DamageRemote = RS:WaitForChild("Events"):WaitForChild("\224\182\189\224\183\128\224\182\158\224\182\169")

local WeaponConfigs = {
    { Name = "双管霰弹枪", WeaponName = "DB Shotgun", Normal = Vector3.new(0.9340000152587891, -0.289000004529953, -0.20800000429153442), hS = 2.4494898319244385, Arg3 = 1, Arg4 = false },
    { Name = "消音手枪", WeaponName = "USP", Normal = Vector3.new(0.871999979019165, 0.47099998593330383, -0.1379999965429306), hS = 2.4494898319244385, Arg3 = 1, Arg4 = false },
    { Name = "自动手枪", WeaponName = "TEC-9", Normal = Vector3.new(0.8489999771118164, 0.19699999690055847, 0.49000000953674316), hS = 2.4494898319244385, Arg3 = 1, Arg4 = false },
    { Name = "马格南手枪", WeaponName = "Deagle", Normal = Vector3.new(0.8669999837875366, -0.029999999329447746, 0.49799999594688416), hS = 3, Arg3 = 1, Arg4 = false },
    { Name = "鹿弹霰弹枪", WeaponName = "M77E", Normal = Vector3.new(-0.847000002861023, 0.10000000149011612, -0.5220000147819519), hS = 3, Arg3 = 1, Arg4 = true },
    { Name = "消音冲锋枪", WeaponName = "Vector", Normal = Vector3.new(-0.6850000023841858, -0.13199999928474426, 0.7170000076293945), hS = 3, Arg3 = 1, Arg4 = false },
    { Name = "紧凑型霰弹枪", WeaponName = "MAG-7", Normal = Vector3.new(0.8970000147819519, 0.05400000140070915, -0.4399999976158142), hS = 2.4494898319244385, Arg3 = 1, Arg4 = false },
    { Name = "打击者冲锋枪", WeaponName = "UMP-45", Normal = Vector3.new(0.4230000078678131, -0.6269999742507935, -0.6539999842643738), hS = 2.4494898319244385, Arg3 = false, Arg4 = true },
    { Name = "无托冲锋枪", WeaponName = "P90", Normal = Vector3.new(0.10499999672174454, -0.11400000005960464, -0.9879999756813049), hS = 3, Arg3 = 1, Arg4 = false },
    { Name = "苏联步枪", WeaponName = "AK-47", Normal = Vector3.new(0.8040000200271606, 0.5120000243186951, 0.30300000309944153), hS = 3, Arg3 = 1, Arg4 = false },
    { Name = "轻型狙击枪", WeaponName = "M40", Normal = Vector3.new(-0.9660000205039978, -0.2529999911785126, 0.061000000685453415), hS = 2.4494898319244385, Arg3 = 1, Arg4 = true },
    { Name = "消音步枪", WeaponName = "M4A1", Normal = Vector3.new(0.3529999852180481, -0.1459999978542328, 0.9240000247955322), hS = 3, Arg3 = 1, Arg4 = false },
    { Name = "瞄准镜步枪", WeaponName = "AUG", Normal = Vector3.new(-0.5199999809265137, 0.007000000216066837, -0.8539999723434448), hS = 3, Arg3 = 1, Arg4 = false, Noscope = true },
    { Name = "重型狙击枪", WeaponName = "Barrett", Normal = Vector3.new(-0.32100000977516174, -0.009999999776482582, 0.9470000267028809), hS = 3, Arg3 = 1, Arg4 = false }
}

local WeaponNames = {}
for _, config in ipairs(WeaponConfigs) do
    table.insert(WeaponNames, config.Name)
end

local AllWeaponRageConfig = {
    Enabled = false,
    SelectedWeapon = WeaponConfigs[1],
    TargetPart = "Head",
    TracerEnabled = true,
    TracerDuration = 0.2,
    WallCheck = false
}

local allWeaponRageCharacterConnections = {}

local function setupAllWeaponRageCharacterWatcher(player)
    if player == lplayer then return end
    if allWeaponRageCharacterConnections[player] then
        allWeaponRageCharacterConnections[player]:Disconnect()
    end
    allWeaponRageCharacterConnections[player] = player.CharacterAdded:Connect(function()
        task.wait(0.2)
    end)
end

Players.PlayerAdded:Connect(function(player)
    if player ~= lplayer then
        setupAllWeaponRageCharacterWatcher(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if allWeaponRageCharacterConnections[player] then
        allWeaponRageCharacterConnections[player]:Disconnect()
        allWeaponRageCharacterConnections[player] = nil
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= lplayer then
        setupAllWeaponRageCharacterWatcher(player)
    end
end

local function CreateTracer(startPos, endPos)
    if not AllWeaponRageConfig.TracerEnabled then return end
    local part = Instance.new("Part")
    part.Parent = Workspace
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Size = Vector3.new(0.1, 0.1, 0.1)
    part.Position = startPos

    local a0 = Instance.new("Attachment", part)
    local a1 = Instance.new("Attachment", part)
    a1.WorldPosition = endPos

    local beam = Instance.new("Beam", part)
    beam.Attachment0 = a0
    beam.Attachment1 = a1
    beam.Texture = "rbxassetid://6060542021"
    beam.Width0 = 0.08
    beam.Width1 = 0.08
    beam.LightEmission = 1
    beam.FaceCamera = true
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    beam.Transparency = NumberSequence.new(0.3)

    task.delay(AllWeaponRageConfig.TracerDuration, function()
        part:Destroy()
    end)
end

local function getAllWeaponBestTarget()
    local target = nil
    local dist = math.huge
    if not CharacterExists(lplayer) then return nil end
    local myChar = lplayer.Character
    if not myChar.PrimaryPart then return nil end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lplayer then
            if not PlayerExists(plr) then continue end
            if checkIsTeammate(plr) then continue end
            if not IsPlayerAlive(plr) then continue end
            if not CharacterExists(plr) then continue end

            if AllWeaponRageConfig.WallCheck then
                local myRoot = myChar.PrimaryPart
                if not PartExists(plr.Character, AllWeaponRageConfig.TargetPart) then continue end
                local theirPart = plr.Character:FindFirstChild(AllWeaponRageConfig.TargetPart)
                if myRoot and theirPart then
                    local rp = RaycastParams.new()
                    rp.FilterDescendantsInstances = { myChar, plr.Character }
                    rp.FilterType = Enum.RaycastFilterType.Blacklist
                    if Workspace:Raycast(myRoot.Position, theirPart.Position - myRoot.Position, rp) then
                        continue
                    end
                end
            end

            if not HumanoidExists(plr.Character) then continue end
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if not PartExists(plr.Character, AllWeaponRageConfig.TargetPart) then continue end
            local part = plr.Character:FindFirstChild(AllWeaponRageConfig.TargetPart)
            if hum.Health > 0 and part then
                local d = (part.Position - myChar.PrimaryPart.Position).Magnitude
                if d < dist then
                    dist = d
                    target = { Char = plr.Character, Part = part }
                end
            end
        end
    end
    return target
end

local function getActiveWeapon()
    if CharacterExists(lplayer) then
        local char = lplayer.Character
        local weapon = char:FindFirstChildOfClass("Tool")
        if weapon then return weapon end
    end
    return RS:FindFirstChild("Weapons") and RS.Weapons:FindFirstChild(AllWeaponRageConfig.SelectedWeapon.WeaponName)
end

local function fireAllWeaponRage()
    local targetData = getAllWeaponBestTarget()
    local weapon = getActiveWeapon()
    if not targetData or not weapon then return end

    local myChar = lplayer.Character
    local gunPos = myChar and myChar:FindFirstChild("Right Arm") and myChar["Right Arm"].Position or (myChar and myChar.PrimaryPart and myChar.PrimaryPart.Position or Vector3.zero)
    CreateTracer(gunPos, targetData.Part.Position)

    local hitInfo = {
        ["Normal"] = AllWeaponRageConfig.SelectedWeapon.Normal,
        ["Hit"] = targetData.Char,
        ["PartName"] = AllWeaponRageConfig.TargetPart,
        ["hS"] = AllWeaponRageConfig.SelectedWeapon.hS,
        ["Position"] = targetData.Part.Position
    }
    if AllWeaponRageConfig.SelectedWeapon.Noscope then
        hitInfo["Noscope"] = true
    end

    local args = {
        [1] = hitInfo,
        [2] = weapon,
        [3] = AllWeaponRageConfig.SelectedWeapon.Arg3,
        [4] = AllWeaponRageConfig.SelectedWeapon.Arg4
    }

    DamageRemote:FireServer(unpack(args))
end

local ViolenceTab2 = Window:Tab({
    Title = "全枪愤怒",
    Icon = "eye",
    Locked = false
})

ViolenceTab2:Dropdown({
    Title = "武器选择",
    Values = WeaponNames,
    Value = WeaponNames[1],
    Callback = function(value)
        for _, config in ipairs(WeaponConfigs) do
            if config.Name == value then
                AllWeaponRageConfig.SelectedWeapon = config
                break
            end
        end
    end
})

ViolenceTab2:Toggle({
    Title = "子弹轨迹",
    Value = true,
    Callback = function(value)
        AllWeaponRageConfig.TracerEnabled = value
    end
})

ViolenceTab2:Slider({
    Title = "轨迹持续时间",
    Value = { Min = 0.05, Max = 1, Default = 0.2 },
    Callback = function(value)
        AllWeaponRageConfig.TracerDuration = value
    end
})

ViolenceTab2:Input({
    Title = "目标部位",
    Value = "Head",
    Callback = function(value)
        if value ~= "" then
            AllWeaponRageConfig.TargetPart = value
        end
    end
})

ViolenceTab2:Toggle({
    Title = "墙壁检测",
    Value = false,
    Callback = function(value)
        AllWeaponRageConfig.WallCheck = value
    end
})

ViolenceTab2:Toggle({
    Title = "启用愤怒机器人",
    Value = false,
    Callback = function(value)
        AllWeaponRageConfig.Enabled = value
        if AllWeaponRageConfig.Enabled then
            task.spawn(function()
                while AllWeaponRageConfig.Enabled do
                    pcall(fireAllWeaponRage)
                    task.wait()
                end
            end)
        end
    end
})

-- ==================== 队伍检测 Tab ====================
local SettingsTab = Window:Tab({
    Title = "队伍检测",
    Icon = "settings",
    Locked = false
})

SettingsTab:Toggle({
    Title = "全功能队伍检测",
    Value = false,
    Callback = function(state)
        TeamCheckConfig.Enabled = state
    end
})

-- ==================== 主题 Tab ====================
local ThemeTab = Window:Tab({
    Title = "主题",
    Icon = "settings",
    Locked = false
})

ThemeTab:Keybind({
    Flag = "KeybindTest",
    Title = "快捷键",
    Desc = "打开UI的快捷键",
    Value = "G",
    Callback = function(v) 
        Window:SetToggleKey(Enum.KeyCode[v]) 
    end
})

local v184, v185, v186 = pairs(WindUI:GetThemes())
local v187 = {}
while true do
    local v188
    v186, v188 = v184(v185, v186)
    if v186 == nil then
        break
    end
    table.insert(v187, v186)
end

ThemeTab:Dropdown({
    Title = "自定义背景颜色",
    Multi = false,
    AllowNone = false,
    Value = "Dark",
    Values = v187,
    Callback = function(p189)
        WindUI:SetTheme(p189)
    end
})
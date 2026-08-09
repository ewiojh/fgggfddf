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

local WindUI

do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)

    if ok then
        WindUI = result
    else 
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Potato5466794/Wind/refs/heads/main/Wind.luau"))()
    end
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ========== ESP 相关变量 ==========
local ESPEnabled = false
local ESP_ScreenGui = nil
local ESPFolder = nil
local ESPNameColor = Color3.fromRGB(0, 255, 127)
local ESPBodyColor = Color3.fromRGB(0, 255, 127)
local ESPNameSize = 14
local ESPRainbowEnabled = false
local ESPRainbowSpeed = 5
local CurrentESPHue = 0
local ESPTeamCheck = false
local ESPMaxDistance = 1000

-- ========== ESP 辅助函数 ==========
local function GetRainbowColor(hue)
    hue = hue % 1
    local r, g, b
    local i = math.floor(hue * 6)
    local f = hue * 6 - i
    local p = 1
    local q = 1 - f
    local t = f
    if i % 6 == 0 then r, g, b = 1, t, p
    elseif i % 6 == 1 then r, g, b = q, 1, p
    elseif i % 6 == 2 then r, g, b = p, 1, t
    elseif i % 6 == 3 then r, g, b = p, q, 1
    elseif i % 6 == 4 then r, g, b = t, p, 1
    else r, g, b = 1, p, q end
    return Color3.new(r, g, b)
end

local function InitESP()
    ESP_ScreenGui = Instance.new("ScreenGui")
    ESP_ScreenGui.Name = "PlayerESP_System"
    ESP_ScreenGui.ResetOnSpawn = false
    ESP_ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ESP_ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "PlayerESPFolder"
    ESPFolder.Parent = ESP_ScreenGui
end

local function UpdateESPColors()
    if not ESPEnabled or not ESPFolder then return end
    pcall(function()
        for _, child in ipairs(ESPFolder:GetChildren()) do
            if child:IsA("BillboardGui") then
                local nameLabel = child:FindFirstChild("NameLabel")
                if nameLabel then
                    nameLabel.TextColor3 = ESPRainbowEnabled and GetRainbowColor(CurrentESPHue) or ESPNameColor
                    nameLabel.TextSize = ESPNameSize
                end
            elseif child:IsA("Highlight") then
                child.FillColor = ESPRainbowEnabled and GetRainbowColor(CurrentESPHue) or ESPBodyColor
                child.OutlineColor = ESPRainbowEnabled and GetRainbowColor(CurrentESPHue) or ESPBodyColor
            end
        end
    end)
end

local function UpdateESPNameSize()
    if not ESPEnabled or not ESPFolder then return end
    pcall(function()
        for _, child in ipairs(ESPFolder:GetChildren()) do
            if child:IsA("BillboardGui") then
                local nameLabel = child:FindFirstChild("NameLabel")
                if nameLabel then
                    nameLabel.TextSize = ESPNameSize
                end
            end
        end
    end)
end

local function CreatePlayerESP(player)
    if player == LocalPlayer or not ESPEnabled then return end
    pcall(function()
        local character = player.Character
        if not character then return end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        local existingESP = ESPFolder:FindFirstChild(player.Name)
        if existingESP then existingESP:Destroy() end
        
        local ESPGui = Instance.new("BillboardGui")
        ESPGui.Name = player.Name
        ESPGui.Adornee = humanoidRootPart
        ESPGui.Size = UDim2.new(0, 100, 0, 40)
        ESPGui.StudsOffset = Vector3.new(0, 3, 0)
        ESPGui.AlwaysOnTop = true
        ESPGui.MaxDistance = 10000
        ESPGui.Enabled = true
        ESPGui.Parent = ESPFolder
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.TextSize = ESPNameSize
        NameLabel.TextColor3 = ESPRainbowEnabled and GetRainbowColor(CurrentESPHue) or ESPNameColor
        NameLabel.TextStrokeTransparency = 0.5
        NameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        NameLabel.Text = player.Name
        NameLabel.Parent = ESPGui
        
        local DistanceLabel = Instance.new("TextLabel")
        DistanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
        DistanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
        DistanceLabel.BackgroundTransparency = 1
        DistanceLabel.Font = Enum.Font.Gotham
        DistanceLabel.TextSize = 12
        DistanceLabel.TextColor3 = Color3.fromRGB(240, 255, 245)
        DistanceLabel.TextStrokeTransparency = 0.5
        DistanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        DistanceLabel.Name = "DistanceLabel"
        DistanceLabel.Parent = ESPGui
        
        local Highlight = Instance.new("Highlight")
        Highlight.Name = player.Name .. "_Highlight"
        Highlight.Adornee = character
        Highlight.FillColor = ESPRainbowEnabled and GetRainbowColor(CurrentESPHue) or ESPBodyColor
        Highlight.FillTransparency = 0.7
        Highlight.OutlineColor = ESPRainbowEnabled and GetRainbowColor(CurrentESPHue) or ESPBodyColor
        Highlight.OutlineTransparency = 0
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.Enabled = true
        Highlight.Parent = ESPFolder
    end)
end

local function UpdateESP()
    if not ESPEnabled then return end
    pcall(function()
        local myCharacter = LocalPlayer.Character
        local myHRP = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = player.Character
                if character then
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local espGui = ESPFolder:FindFirstChild(player.Name)
                        if not espGui then
                            CreatePlayerESP(player)
                            espGui = ESPFolder:FindFirstChild(player.Name)
                        end
                        if espGui then
                            local distance = (myHRP.Position - hrp.Position).Magnitude
                            local distanceLabel = espGui:FindFirstChild("DistanceLabel")
                            if distanceLabel then
                                distanceLabel.Text = string.format("%.0f studs", distance)
                            end
                            if distance > ESPMaxDistance then
                                espGui.Enabled = false
                                local highlight = ESPFolder:FindFirstChild(player.Name .. "_Highlight")
                                if highlight then highlight.Enabled = false end
                            else
                                local teamHide = false
                                if ESPTeamCheck and LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then
                                    teamHide = true
                                end
                                if teamHide then
                                    espGui.Enabled = false
                                    local highlight = ESPFolder:FindFirstChild(player.Name .. "_Highlight")
                                    if highlight then highlight.Enabled = false end
                                else
                                    espGui.Enabled = true
                                    local highlight = ESPFolder:FindFirstChild(player.Name .. "_Highlight")
                                    if highlight then highlight.Enabled = true end
                                end
                            end
                        end
                    else
                        local espGui = ESPFolder:FindFirstChild(player.Name)
                        if espGui then espGui:Destroy() end
                        local highlight = ESPFolder:FindFirstChild(player.Name .. "_Highlight")
                        if highlight then highlight:Destroy() end
                    end
                else
                    local esp = ESPFolder:FindFirstChild(player.Name)
                    if esp then esp:Destroy() end
                    local highlight = ESPFolder:FindFirstChild(player.Name .. "_Highlight")
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end)
end

local function ToggleESP(state)
    ESPEnabled = state
    if state then
        pcall(function()
            if not ESP_ScreenGui then InitESP() end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    CreatePlayerESP(player)
                end
            end
            if WindUI then
                WindUI:Notify({
                    Title = "ESP",
                    Content = "玩家内透已开启",
                    Icon = "eye",
                })
            end
        end)
    else
        pcall(function()
            if ESPFolder then
                for _, esp in ipairs(ESPFolder:GetChildren()) do
                    esp:Destroy()
                end
            end
            if WindUI then
                WindUI:Notify({
                    Title = "ESP",
                    Content = "玩家内透已关闭",
                    Icon = "eye",
                })
            end
        end)
    end
end

-- 初始化ESP基础结构
InitESP()

-- 角色重生时重建ESP
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if ESPEnabled then
        pcall(function()
            if ESPFolder then
                for _, esp in ipairs(ESPFolder:GetChildren()) do
                    esp:Destroy()
                end
            end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    CreatePlayerESP(player)
                end
            end
        end)
    end
end)

-- 玩家加入时创建ESP
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESPEnabled then
            task.wait(1)
            pcall(function()
                CreatePlayerESP(player)
            end)
        end
    end)
end)

-- 玩家离开时清理ESP
Players.PlayerRemoving:Connect(function(player)
    pcall(function()
        if ESPFolder then
            local espGui = ESPFolder:FindFirstChild(player.Name)
            if espGui then espGui:Destroy() end
            local highlight = ESPFolder:FindFirstChild(player.Name .. "_Highlight")
            if highlight then highlight:Destroy() end
        end
    end)
end)

-- ========== 夜视模式相关变量 ==========
local NightVisionEnabled = false
local originalBrightness = Lighting.Brightness
local originalAmbient = Lighting.Ambient

-- ========== 偷袭检测相关变量 ==========
local BackstabCheckEnabled = false
local BackstabCooldown = 0
local BACKSTAB_COOLDOWN_TIME = 3

local function CheckBackstabThreat()
    if not BackstabCheckEnabled then return end
    if BackstabCooldown > 0 then return end
    pcall(function()
        local myCharacter = LocalPlayer.Character
        local myHRP = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local myPosition = myHRP.Position
        local myCFrame = myHRP.CFrame
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if hrp and humanoid and humanoid.Health > 0 then
                    local enemyPosition = hrp.Position
                    local distance = (myPosition - enemyPosition).Magnitude
                    if distance < 30 then
                        local toEnemy = (enemyPosition - myPosition).Unit
                        local myForward = myCFrame.LookVector
                        local dotProduct = toEnemy:Dot(myForward)
                        if dotProduct < 0.5 then
                            if WindUI then
                                WindUI:Notify({
                                    Title = "偷袭检测",
                                    Content = "不不不有人打你：" .. player.Name,
                                    Icon = "alert-triangle",
                                    Color = Color3.fromRGB(255, 100, 100),
                                    Duration = 5
                                })
                            end
                            BackstabCooldown = BACKSTAB_COOLDOWN_TIME
                            break
                        end
                    end
                end
            end
        end
    end)
end

-- ========== 死亡提醒相关变量 ==========
local DeathCheckEnabled = false

local function SetupDeathDetection()
    LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        pcall(function()
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.Died:Connect(function()
                if DeathCheckEnabled and WindUI then
                    WindUI:Notify({
                        Title = "死亡提醒",
                        Content = "恭喜你反打失败",
                        Icon = "skull",
                        Color = Color3.fromRGB(255, 0, 0),
                        Duration = 8
                    })
                end
            end)
        end)
    end)
    if LocalPlayer.Character then
        pcall(function()
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Died:Connect(function()
                    if DeathCheckEnabled and WindUI then
                        WindUI:Notify({
                            Title = "死亡提醒",
                            Content = "有人打你赶紧回头反打",
                            Icon = "skull",
                            Color = Color3.fromRGB(255, 0, 0),
                            Duration = 8
                        })
                    end
                end)
            end
        end)
    end
end

-- ========== 心跳循环更新ESP ==========
RunService.Heartbeat:Connect(function(deltaTime)
    pcall(function()
        UpdateESP()
        if ESPRainbowEnabled then
            CurrentESPHue = CurrentESPHue + deltaTime * ESPRainbowSpeed / 10
            UpdateESPColors()
        end
        if BackstabCooldown > 0 then
            BackstabCooldown = BackstabCooldown - deltaTime
        end
        CheckBackstabThreat()
    end)
end)

-- ========== 定期清理重建ESP（修复bug） ==========
coroutine.wrap(function()
    while true do
        task.wait(5)
        pcall(function()
            if ESPEnabled then
                if ESPFolder then
                    for _, child in ipairs(ESPFolder:GetChildren()) do
                        child:Destroy()
                    end
                end
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        CreatePlayerESP(player)
                    end
                end
            end
        end)
    end
end)()

-- ========== 创建UI主函数 ==========
local function createUI()
    local Window = WindUI:CreateWindow({
        Title = "<font color='#FFFFFF'>北</font><font color='#CCCCCC'>极</font><font color='#999999'>星</font> <font color='#666666'>H</font><font color='#444444'>U</font><font color='#222222'>B</font><font color='#FFAEC4'></font>",
        Folder = "ftgshub",
        NewElements = true,
        HideSearchBar = false,
        Size = UDim2.fromOffset(600, 450),
        Theme = "Dark",  
        UserEnabled = true,
        SideBarWidth = 135,
        HasOutline = true,
        Background = "video:https://raw.githubusercontent.com/xiaoxi9008/Server./refs/heads/main/7031d99b857842f7552a01db8f22cc3f.mp4",
        
        OpenButton = {
            Title = "<font color='#FFFFFF'>北</font><font color='#CCCCCC'>极</font><font color='#999999'>星</font> <font color='#666666'>H</font><font color='#444444'>U</font><font color='#222222'>B</font><font color='#FFAEC4'></font>",
            CornerRadius = UDim.new(1,0),
            StrokeThickness = 1.5,
            Enabled = true,
            Draggable = true,
            OnlyMobile = false,
            Color = ColorSequence.new(
                Color3.fromHex("FFFFFF"), 
                Color3.fromHex("FFFFFF")
            )
        },
        Topbar = {
            Height = 44,
            ButtonsType = "Mac",
        }
    })

    Window:Tag({
        Title = "付费版",
        Radius = 10,
        Color = Color3.fromHex("#ffffff"),
    })

    Window:Tag({
        Title = "枪地FFA",
        Radius = 10,
        Color = Color3.fromHex("#ffffff"),
    })

    local White = Color3.fromHex("#FFFFFF")
    local LightGray = Color3.fromHex("#CCCCCC")
    local Gray = Color3.fromHex("#999999")
    local DarkGray = Color3.fromHex("#666666")
    local AlmostBlack = Color3.fromHex("#333333")
    local Green = Color3.fromHex("#10C550")
    local Red = Color3.fromHex("#EF4F1D")

    -- ========== 公告标签页 ==========
    local AboutTab = Window:Tab({
        Title = "公告",
        Desc = "脚本信息", 
        Icon = "solar:info-square-bold",
        IconColor = Gray,
        IconShape = "Square",
        Border = true,
    })

    AboutTab:Paragraph({
        Title = "欢迎使用 <font color='#FFFFFF'>北</font><font color='#CCCCCC'>极</font><font color='#999999'>星</font> 脚本",
        Desc = "作者：北极星",
        ImageSize = 50,
        Thumbnail = "https://raw.githubusercontent.com/xiaoxi9008/-UI/refs/heads/main/920ce5d83c60d5193e79acd98e3e74408df827d6d2e5c1d25a56ed2e4a11177f.png",
        ThumbnailSize = 170
    })

    AboutTab:Keybind({
        Flag = "KeybindTest",
        Title = "快捷键",
        Desc = "打开UI的快捷键",
        Value = "G",
        Callback = function(v) 
            Window:SetToggleKey(Enum.KeyCode[v]) 
        end
    })

    -- ========== 主要功能标签页 ==========
    local shaluTab = Window:Tab({
        Title = "主要功能",
        Desc = "脚本信息", 
        Icon = "solar:info-square-bold",
        IconColor = Gray,
        IconShape = "Square",
        Border = true,
    })

    local mp = game:GetService("Players")
    local lp = mp.LocalPlayer
    
    -- 自动杀戮功能
    local autoKillEnabled = false
    local heartbeatConnection = nil
    local beamContainer = nil

    local function createBeam(startPos, endPos)
        if not beamContainer or not beamContainer.Parent then
            beamContainer = Instance.new("Folder")
            beamContainer.Name = "BeamContainer_" .. math.random(10000, 99999)
            beamContainer.Parent = workspace
        end

        local part1 = Instance.new("Part")
        part1.Anchored = true
        part1.CanCollide = false
        part1.Transparency = 1
        part1.Size = Vector3.new(0.1, 0.1, 0.1)
        part1.Position = startPos
        part1.Name = "BeamStart_" .. math.random(10000, 99999)
        part1.Parent = beamContainer

        local part2 = Instance.new("Part")
        part2.Anchored = true
        part2.CanCollide = false
        part2.Transparency = 1
        part2.Size = Vector3.new(0.1, 0.1, 0.1)
        part2.Position = endPos
        part2.Name = "BeamEnd_" .. math.random(10000, 99999)
        part2.Parent = beamContainer

        local attachment1 = Instance.new("Attachment")
        attachment1.Parent = part1
        local attachment2 = Instance.new("Attachment")
        attachment2.Parent = part2

        local beam = Instance.new("Beam")
        beam.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255))
        beam.Transparency = NumberSequence.new(0)
        beam.Width0 = 0.12
        beam.Width1 = 0.12
        beam.Texture = "rbxassetid://13233061051"
        beam.TextureSpeed = 1.5
        beam.TextureMode = Enum.TextureMode.Wrap
        beam.Brightness = 1
        beam.LightEmission = 0
        beam.FaceCamera = true
        beam.Attachment0 = attachment1
        beam.Attachment1 = attachment2
        beam.Parent = part1

        local shaking = true
        task.spawn(function()
            while shaking and part1 and part1.Parent do
                pcall(function()
                    attachment1.Position = Vector3.new(math.random(-2, 2) / 100, math.random(-2, 2) / 100, math.random(-2, 2) / 100)
                    attachment2.Position = Vector3.new(math.random(-2, 2) / 100, math.random(-2, 2) / 100, math.random(-2, 2) / 100)
                end)
                task.wait(0.02)
            end
        end)

        local fadeDelay = math.random(5, 15) / 10
        task.delay(fadeDelay, function()
            shaking = false
            for i = 0, 1, 0.1 do
                if not part1 or not part1.Parent then break end
                pcall(function()
                    beam.Transparency = NumberSequence.new(i)
                end)
                task.wait(0.02)
            end
            pcall(function() part1:Destroy() end)
            pcall(function() part2:Destroy() end)
        end)
    end

    local function getAllVisibleEnemies()
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return {} end
        
        local pos = hrp.Position
        local cam = workspace.CurrentCamera
        if not cam then return {} end
        
        local enemies = {}
        
        for _, plr in ipairs(mp:GetPlayers()) do
            if plr ~= lp and plr.Character then
                local enemyChar = plr.Character
                local hum = enemyChar:FindFirstChild("Humanoid")
                local enemyHrp = enemyChar:FindFirstChild("HumanoidRootPart")
                local head = enemyChar:FindFirstChild("Head")
                
                if hum and enemyHrp and head and hum.Health > 0 then
                    local headPos = head.Position
                    local dist = (headPos - pos).Magnitude
                    
                    local rayOrigin = cam.CFrame.Position
                    local rayDir = (headPos - rayOrigin)
                    local rayLength = rayDir.Magnitude
                    if rayLength > 0 then
                        local rayUnit = rayDir / rayLength
                        local rayParams = RaycastParams.new()
                        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                        rayParams.FilterDescendantsInstances = {lp.Character}
                        rayParams.IgnoreWater = true
                        
                        local rayResult = workspace:Raycast(rayOrigin, rayUnit * rayLength, rayParams)
                        
                        if not rayResult or rayResult.Instance:IsDescendantOf(enemyChar) then
                            table.insert(enemies, {
                                Character = enemyChar,
                                Head = head,
                                Distance = dist
                            })
                        end
                    end
                end
            end
        end
        
        table.sort(enemies, function(a, b) return a.Distance < b.Distance end)
        return enemies
    end

    local function shootTarget(enemyData)
        local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
        if not tool then return end
        
        local remotes = tool:FindFirstChild("Remotes")
        local checkShot = remotes and remotes:FindFirstChild("CheckShot")
        local config = tool:FindFirstChild("Configuration")
        local seed = tool:FindFirstChild("Seed")
        
        if not checkShot or not config or not seed then return end
        
        local head = enemyData.Head
        local headPos = head.Position
        local cam = workspace.CurrentCamera
        if not cam then return end
        
        local lookCF = CFrame.new(cam.CFrame.Position, headPos)
        
        pcall(function()
            checkShot:FireServer(
                config.Ammo.Value,
                config.spread.Value,
                config.Ammo.Value,
                config.reloadTime.Value,
                lookCF,
                Vector3.new(headPos.X, headPos.Y, headPos.Z),
                head,
                seed.Value,
                tick()
            )
        end)
        
        createBeam(cam.CFrame.Position, headPos)
    end

    local function autoKillLoop()
        local enemies = getAllVisibleEnemies()
        for _, enemy in ipairs(enemies) do
            shootTarget(enemy)
        end
    end

    shaluTab:Toggle({
        Title = "ragebot",
        Value = false,
        Callback = function(state)
            autoKillEnabled = state
            if autoKillEnabled then
                if heartbeatConnection then heartbeatConnection:Disconnect() end
                heartbeatConnection = RunService.Heartbeat:Connect(autoKillLoop)
            else
                if heartbeatConnection then
                    heartbeatConnection:Disconnect()
                    heartbeatConnection = nil
                end
                if beamContainer then
                    pcall(function() beamContainer:Destroy() end)
                    beamContainer = nil
                end
            end
        end
    })

    shaluTab:Divider()
    
    shaluTab:Paragraph({
        Title = "吸人",
        Desc = "神秘暴力功能强让别人在你前面"
    })
    
    local suckAllEnabled = false
    local suckSingleEnabled = false
    local suckConnection = nil
    local selectedPlayerForSuck = nil
    local playerDropdown = nil
    
    local function suckPlayer(targetPlayer)
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not targetPlayer then return end
        
        local targetChar = targetPlayer.Character
        local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        local targetHum = targetChar and targetChar:FindFirstChild("Humanoid")
        
        if targetHrp and targetHum and targetHum.Health > 0 then
            local myPos = hrp.Position
            local lookVector = hrp.CFrame.LookVector
            local targetPos = myPos + lookVector * 10
            targetHrp.CFrame = CFrame.new(targetPos, targetPos + lookVector)
        end
    end
    
    local function suckAllPlayers()
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local myPos = hrp.Position
        local lookVector = hrp.CFrame.LookVector
        
        for _, player in ipairs(mp:GetPlayers()) do
            if player ~= lp then
                local targetChar = player.Character
                local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                local targetHum = targetChar and targetChar:FindFirstChild("Humanoid")
                
                if targetHrp and targetHum and targetHum.Health > 0 then
                    local targetPos = myPos + lookVector * 10
                    targetHrp.CFrame = CFrame.new(targetPos, targetPos + lookVector)
                end
            end
        end
    end
    
    local function startSuckLoop()
        if suckConnection then 
            suckConnection:Disconnect() 
            suckConnection = nil
        end
        
        if suckAllEnabled then
            suckConnection = RunService.Heartbeat:Connect(suckAllPlayers)
        elseif suckSingleEnabled and selectedPlayerForSuck then
            suckConnection = RunService.Heartbeat:Connect(function()
                suckPlayer(selectedPlayerForSuck)
            end)
        end
    end
    
    local function refreshPlayerList()
        local players = {}
        for _, player in ipairs(mp:GetPlayers()) do
            if player ~= lp then
                table.insert(players, player.Name)
            end
        end
        if #players == 0 then
            table.insert(players, "无玩家")
        end
        if playerDropdown then
            playerDropdown:SetOptions(players)
        end
    end
    
    local function showNotify(title, text)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 2
            })
        end)
    end
    
    mp.PlayerAdded:Connect(function(player)
        if player ~= lp then
            showNotify("玩家加入", player.Name .. " 进入了游戏")
            refreshPlayerList()
        end
    end)
    
    mp.PlayerRemoving:Connect(function(player)
        if player ~= lp then
            showNotify("玩家退出", player.Name .. " 离开了游戏")
            refreshPlayerList()
            if selectedPlayerForSuck and selectedPlayerForSuck.Name == player.Name then
                selectedPlayerForSuck = nil
                if suckSingleEnabled then
                    suckSingleEnabled = false
                    suckAllEnabled = false
                    startSuckLoop()
                end
                if playerDropdown then
                    playerDropdown:SetValue("无玩家")
                end
            end
        end
    end)
    
    shaluTab:Toggle({
        Title = "吸全部玩家",
        Value = false,
        Callback = function(state)
            if state then
                if suckSingleEnabled then
                    suckSingleEnabled = false
                end
                suckAllEnabled = true
                startSuckLoop()
                showNotify("吸人", "已开启吸全部玩家")
            else
                if suckAllEnabled then
                    suckAllEnabled = false
                    if not suckSingleEnabled then
                        startSuckLoop()
                    end
                    showNotify("吸人", "已关闭吸全部玩家")
                end
            end
        end
    })

    shaluTab:Button({
        Title = "停止所有吸人",
        Callback = function()
            if suckConnection then
                suckConnection:Disconnect()
                suckConnection = nil
            end
            suckAllEnabled = false
            suckSingleEnabled = false
            showNotify("已停止", "所有吸人已停止")
        end
    })

    -- ========== ESP透视标签页 ==========
    local ESPTab = Window:Tab({
        Title = "ESP",
        Desc = "ESP设置", 
        Icon = "solar:eye-bold",
        IconColor = Gray,
        IconShape = "Square",
        Border = true,
    })

    ESPTab:Section({
        Title = "玩家透视 (ESP)",
        TextSize = 16,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    ESPTab:Toggle({
        Title = "玩家透视 (ESP)",
        Desc = "显示玩家描边和距离",
        Callback = function(enabled)
            ToggleESP(enabled)
        end
    })
    
    ESPTab:Space()
    
    ESPTab:Colorpicker({
        Title = "ESP玩家名字颜色",
        Desc = "设置玩家名字显示颜色",
        Default = ESPNameColor,
        Callback = function(color)
            ESPNameColor = color
            if ESPEnabled and not ESPRainbowEnabled then
                UpdateESPColors()
            end
        end
    })
    
    ESPTab:Colorpicker({
        Title = "ESP身体绘制颜色",
        Desc = "设置玩家身体颜色",
        Default = ESPBodyColor,
        Callback = function(color)
            ESPBodyColor = color
            if ESPEnabled and not ESPRainbowEnabled then
                UpdateESPColors()
            end
        end
    })
    
    ESPTab:Slider({
        Title = "ESP玩家名字大小",
        Desc = "设置玩家名字的文本大小",
        Value = {
            Min = 8,
            Max = 24,
            Default = ESPNameSize,
        },
        Callback = function(value)
            ESPNameSize = value
            if ESPEnabled then
                UpdateESPNameSize()
            end
        end
    })
    
    ESPTab:Space()
    
    ESPTab:Toggle({
        Title = "ESP彩虹渐变",
        Desc = "开启透视彩虹效果",
        Callback = function(enabled)
            ESPRainbowEnabled = enabled
            if ESPEnabled then
                UpdateESPColors()
            end
        end
    })
    
    ESPTab:Slider({
        Title = "ESP彩虹速度",
        Desc = "调整彩虹的速度",
        Value = {
            Min = 1,
            Max = 10,
            Default = ESPRainbowSpeed,
        },
        Callback = function(value)
            ESPRainbowSpeed = value
        end
    })
    
    ESPTab:Space()
    
    ESPTab:Slider({
        Title = "ESP最大显示距离",
        Desc = "设置ESP显示的最大距离（单位：studs）",
        Value = {
            Min = 50,
            Max = 10000,
            Default = ESPMaxDistance,
        },
        Callback = function(value)
            ESPMaxDistance = value
        end
    })
    
    ESPTab:Space()
    
    ESPTab:Toggle({
        Title = "队伍检测",
        Desc = "开启后只显示敌方队伍",
        Value = ESPTeamCheck,
        Callback = function(enabled)
            ESPTeamCheck = enabled
            if ESPEnabled then
                UpdateESP()
            end
        end
    })

    -- ========== 实用功能标签页 ==========
    local UtilityTab = Window:Tab({
        Title = "实用功能",
        Desc = "夜视/偷袭检测等", 
        Icon = "solar:eye-bold",
        IconColor = Gray,
        IconShape = "Square",
        Border = true,
    })

    UtilityTab:Section({
        Title = "视觉增强",
        TextSize = 16,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    UtilityTab:Toggle({
        Title = "夜视模式",
        Desc = "开启夜间模式，提高可见度",
        Callback = function(enabled)
            NightVisionEnabled = enabled
            if enabled then
                originalBrightness = Lighting.Brightness
                originalAmbient = Lighting.Ambient
                Lighting.Brightness = 2                Lighting.Ambient = Color3.fromRGB(200, 200, 200)
                Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
                if WindUI then
                    WindUI:Notify({
                        Title = "夜视模式",
                        Content = "夜视模式已开启",
                        Icon = "moon",
                    })
                end
            else
                Lighting.Brightness = originalBrightness
                Lighting.Ambient = originalAmbient
                Lighting.OutdoorAmbient = Color3.fromRGB(0.5, 0.5, 0.5)
                if WindUI then
                    WindUI:Notify({
                        Title = "夜视模式",
                        Content = "夜视模式已关闭",
                        Icon = "moon",
                    })
                end
            end
        end
    })

    UtilityTab:Space()

    UtilityTab:Section({
        Title = "安全检测",
        TextSize = 16,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    UtilityTab:Toggle({
        Title = "偷袭检测提醒",
        Desc = "检测背后或侧面的敌人并提醒",
        Callback = function(enabled)
            BackstabCheckEnabled = enabled
            if WindUI then
                WindUI:Notify({
                    Title = "偷袭检测",
                    Content = enabled and "偷袭检测已开启" or "偷袭检测已关闭",
                    Icon = "shield-alert",
                })
            end
        end
    })

    UtilityTab:Toggle({
        Title = "死亡提醒",
        Desc = "玩家死亡时显示提醒消息",
        Callback = function(enabled)
            DeathCheckEnabled = enabled
            if enabled then
                SetupDeathDetection()
            end
            if WindUI then
                WindUI:Notify({
                    Title = "死亡提醒",
                    Content = enabled and "死亡提醒已开启" or "死亡提醒已关闭",
                    Icon = "heart",
                })
            end
        end
    })

    print("UI创建完成")
end

-- 弹窗提示后创建UI
WindUI:Popup({
    Title = "<font color='#FFFFFF'>北</font><font color='#CCCCCC'>极</font><font color='#999999'>星</font> <font color='#666666'>H</font><font color='#444444'>U</font><font color='#222222'>B</font>",
    IconThemed = true,
    Content = "尊贵付费版用户" .. game.Players.LocalPlayer.Name .. "使用<font color='#FFFFFF'>北</font><font color='#CCCCCC'>极</font><font color='#999999'>星</font> <font color='#666666'>H</font><font color='#444444'>U</font><font color='#222222'>B</font>欢迎使用FFA",
    Buttons = {
        {
            Title = "取消",
            Callback = function() 
                createUI()
            end,
            Variant = "Secondary",
        },
        {
            Title = "执行",
            Icon = "arrow-right",
            Callback = function() 
                createUI()
            end,
            Variant = "Primary",
        }
    }
})
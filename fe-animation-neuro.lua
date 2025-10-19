-- FE Animation Editor (Reyfield-style) - LocalScript
-- Paste ke StarterPlayerScripts atau StarterGui (LocalScript)
-- Theme: dark + electric blue (#00BFFF)
-- Uses Reyfield if present in ReplicatedStorage, otherwise uses a minimal shim.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Theme colors
local THEME = {
    background = Color3.fromHex("0B0F15"), -- very dark
    panel = Color3.fromHex("0F1720"), -- panel dark
    accent = Color3.fromHex("00BFFF"), -- electric blue
    text = Color3.fromRGB(230,230,230),
    muted = Color3.fromRGB(180,180,190),
    danger = Color3.fromRGB(235,85,85),
}

-- Try to find Reyfield module in ReplicatedStorage
local ReyfieldModule
pcall(function()
    ReyfieldModule = ReplicatedStorage:FindFirstChild("Reyfield")
    if ReyfieldModule and ReyfieldModule:IsA("ModuleScript") then
        ReyfieldModule = require(ReyfieldModule)
    else
        ReyfieldModule = nil
    end
end)

-- Minimal Reyfield shim (only the parts we need) if actual Reyfield isn't present
local Rey = ReyfieldModule or (function()
    local Shim = {}
    -- Very small API: createWindow(title), addTab(name), addSection(tab, name), addButton, addTextbox, addToggle, addLabel
    function Shim:CreateWindow(opts)
        local title = opts and opts.Title or "FE Animation Editor"
        -- create ScreenGui + base frame
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "Reyfield_Fallback_FEAEditor"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = playerGui

        local base = Instance.new("Frame")
        base.Name = "Base"
        base.AnchorPoint = Vector2.new(0.5,0.5)
        base.Position = UDim2.new(0.5, 0.5, 0.5, 0)
        base.Size = UDim2.new(0, 920, 0, 560)
        base.BackgroundColor3 = THEME.panel
        base.BorderSizePixel = 0
        base.Parent = screenGui

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.Size = UDim2.new(1,0,0,40)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = THEME.text
        titleLabel.Font = Enum.Font.GOTHAMMEDIUM
        titleLabel.TextSize = 18
        titleLabel.Parent = base

        local content = Instance.new("Frame")
        content.Name = "Content"
        content.Size = UDim2.new(1,-20,1,-60)
        content.Position = UDim2.new(0,10,0,50)
        content.BackgroundTransparency = 1
        content.Parent = base

        -- tabs container
        local tabs = Instance.new("Frame")
        tabs.Name = "Tabs"
        tabs.Size = UDim2.new(0, 200, 1, 0)
        tabs.BackgroundTransparency = 1
        tabs.Parent = content

        local pages = Instance.new("Frame")
        pages.Name = "Pages"
        pages.Position = UDim2.new(0,210,0,0)
        pages.Size = UDim2.new(1,-210,1,0)
        pages.BackgroundTransparency = 1
        pages.Parent = content

        local api = { ScreenGui = screenGui, Base = base, Content = content, Tabs = tabs, Pages = pages, TabsList = {}, PagesList = {} }

        function api:AddTab(name)
            local idx = #api.TabsList + 1
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 36)
            btn.Position = UDim2.new(0, 5, 0, (idx-1)*42)
            btn.BackgroundColor3 = Color3.fromRGB(20,20,26)
            btn.Text = name
            btn.TextColor3 = THEME.text
            btn.Font = Enum.Font.GOTHAM
            btn.TextSize = 15
            btn.Parent = api.Tabs

            local page = Instance.new("Frame")
            page.Size = UDim2.new(1,0,1,0)
            page.BackgroundTransparency = 1
            page.Visible = (idx==1)
            page.Parent = api.Pages

            btn.MouseButton1Click:Connect(function()
                for i,p in pairs(api.PagesList) do p.Visible = false end
                page.Visible = true
            end)

            api.TabsList[#api.TabsList+1] = btn
            api.PagesList[#api.PagesList+1] = page

            return {
                Frame = page,
                AddLabel = function(_, txt)
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, -10, 0, 24)
                    label.Position = UDim2.new(0, 5, 0, (#page:GetChildren()-1)*28)
                    label.BackgroundTransparency = 1
                    label.Text = txt
                    label.TextSize = 15
                    label.TextColor3 = THEME.muted
                    label.Font = Enum.Font.GOTHAM
                    label.Parent = page
                    return label
                end,
                AddButton = function(_, txt, onClick)
                    local b = Instance.new("TextButton")
                    b.Size = UDim2.new(0, 140, 0, 34)
                    b.Position = UDim2.new(0, 5 + ((#page:GetChildren())%3)*150, 0, math.floor((#page:GetChildren())/3)*42)
                    b.BackgroundColor3 = Color3.fromRGB(12,12,16)
                    b.TextColor3 = THEME.text
                    b.Text = txt
                    b.Font = Enum.Font.GOTHAMMEDIUM
                    b.TextSize = 14
                    b.Parent = page
                    b.MouseButton1Click:Connect(function() if onClick then pcall(onClick) end end)
                    return b
                end,
                AddTextbox = function(_, placeholder, default, onChanged)
                    local box = Instance.new("TextBox")
                    box.Size = UDim2.new(1, -10, 0, 32)
                    box.Position = UDim2.new(0, 5, 0, (#page:GetChildren())*36)
                    box.BackgroundColor3 = Color3.fromRGB(18,18,22)
                    box.TextColor3 = THEME.text
                    box.PlaceholderText = placeholder or ""
                    box.Text = default or ""
                    box.Font = Enum.Font.GOTHAM
                    box.TextSize = 14
                    box.Parent = page
                    box.FocusLost:Connect(function(enter) if onChanged then pcall(onChanged, box.Text) end end)
                    return box
                end,
                AddToggle = function(_, labelText, default, callback)
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(1, -10, 0, 28)
                    frame.Position = UDim2.new(0,5,0,#page:GetChildren()*30)
                    frame.BackgroundTransparency = 1
                    frame.Parent = page

                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(0.8,0,1,0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = labelText
                    lbl.TextColor3 = THEME.text
                    lbl.Font = Enum.Font.GOTHAM
                    lbl.TextSize = 14
                    lbl.Parent = frame

                    local toggle = Instance.new("TextButton")
                    toggle.Size = UDim2.new(0,60,0,22)
                    toggle.Position = UDim2.new(1,-65,0,3)
                    toggle.BackgroundColor3 = default and THEME.accent or Color3.fromRGB(50,50,60)
                    toggle.Text = default and "On" or "Off"
                    toggle.TextColor3 = THEME.text
                    toggle.Font = Enum.Font.GOTHAMMEDIUM
                    toggle.TextSize = 13
                    toggle.Parent = frame

                    toggle.MouseButton1Click:Connect(function()
                        default = not default
                        toggle.BackgroundColor3 = default and THEME.accent or Color3.fromRGB(50,50,60)
                        toggle.Text = default and "On" or "Off"
                        if callback then pcall(callback, default) end
                    end)

                    return toggle
                end,
                AddLabelSmall = function(_, text)
                    local l = Instance.new("TextLabel")
                    l.Size = UDim2.new(1, -10, 0, 18)
                    l.Position = UDim2.new(0,5,0,#page:GetChildren()*22)
                    l.BackgroundTransparency = 1
                    l.Text = text
                    l.TextColor3 = THEME.muted
                    l.TextSize = 13
                    l.Font = Enum.Font.GOTHAM
                    l.Parent = page
                    return l
                end,
            }
        end

        return api
    end

    return Shim
end)()

-- Create window
local win = Rey:CreateWindow({ Title = "FE Animation Editor — Reyfield" })

-- Build tabs
local tabAnims = win:AddTab("Animations")
local tabPlayer = win:AddTab("Player")
local tabSettings = win:AddTab("Settings")

-- Helper utilities
local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "FEA",
            Text = text or "";
            Duration = 3
        })
    end)
end

-- Animation handling
local currentAnimationTrack = nil
local currentAnimator = nil
local loadedAnimation = nil

-- Wait for character / animator
local function getAnimator()
    if not player.Character then return nil end
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end
    return animator
end

-- UI Elements (Animations Tab)
local animIdBox = tabAnims:AddTextbox("AnimationId (e.g. 12345678)", "", function() end)
local loadBtn = tabAnims:AddButton("Load Animation", function()
    local txt = animIdBox.Text:gsub("%D", "") -- only digits
    if txt == "" then notify("Load failed","Enter an animation id") return end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://"..txt
    loadedAnimation = anim
    currentAnimator = getAnimator()
    notify("Loaded","Animation set. Use Play to preview.")
end)
local playBtn = tabAnims:AddButton("Play", function()
    if not loadedAnimation then notify("Play failed","Load an animation first") return end
    currentAnimator = currentAnimator or getAnimator()
    if not currentAnimator then notify("Play failed","No humanoid found") return end
    if currentAnimationTrack then
        currentAnimationTrack:Stop()
        currentAnimationTrack:Destroy()
        currentAnimationTrack = nil
    end
    local track = currentAnimator:LoadAnimation(loadedAnimation)
    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    currentAnimationTrack = track
    notify("Playing","Animation playing")
end)
local stopBtn = tabAnims:AddButton("Stop", function()
    if currentAnimationTrack then
        currentAnimationTrack:Stop()
        currentAnimationTrack:Destroy()
        currentAnimationTrack = nil
        notify("Stopped","Animation stopped")
    end
end)
local copyIdBtn = tabAnims:AddButton("Copy AnimationId to Clipboard", function()
    local txt = animIdBox.Text
    if txt == "" then notify("No ID","Type an animation id first") return end
    pcall(function()
        setclipboard(txt)
    end)
    notify("Copied","AnimationId copied to clipboard")
end)

-- Simple Keyframe system (client-only)
local Keyframes = {} -- { {name=, time=, pose={ partName = {CFrame=...} } } }
local selectedKeyIndex = 0

local function snapshotPose()
    if not player.Character then notify("Snapshot","No character loaded") return end
    local pose = {}
    for _, part in ipairs(player.Character:GetChildren()) do
        if part:IsA("BasePart") then
            pose[part.Name] = {
                CFrame = part.CFrame
            }
        end
    end
    return pose
end

local function applyPose(pose)
    if not player.Character or not pose then return end
    for name, data in pairs(pose) do
        local part = player.Character:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            part.CFrame = data.CFrame
        end
    end
end

-- Keyframe Controls UI
local recordBtn = tabAnims:AddButton("Record Keyframe", function()
    local pose = snapshotPose()
    local entry = {
        name = "Frame_"..(#Keyframes+1),
        time = #Keyframes+1,
        pose = pose
    }
    Keyframes[#Keyframes+1] = entry
    notify("Keyframe","Recorded "..entry.name)
end)

local prevBtn = tabAnims:AddButton("Prev Keyframe", function()
    if #Keyframes == 0 then notify("No keyframes","Record some first") return end
    selectedKeyIndex = math.max(1, (selectedKeyIndex==0) and 1 or (selectedKeyIndex-1))
    applyPose(Keyframes[selectedKeyIndex].pose)
    notify("Keyframe", "Showing "..Keyframes[selectedKeyIndex].name)
end)

local nextBtn = tabAnims:AddButton("Next Keyframe", function()
    if #Keyframes == 0 then notify("No keyframes","Record some first") return end
    selectedKeyIndex = math.min(#Keyframes, selectedKeyIndex+1)
    if selectedKeyIndex == 0 then selectedKeyIndex = 1 end
    applyPose(Keyframes[selectedKeyIndex].pose)
    notify("Keyframe","Showing "..Keyframes[selectedKeyIndex].name)
end)

local exportBtn = tabAnims:AddButton("Export Keyframes (Copy JSON)", function()
    if #Keyframes == 0 then notify("No keyframes","Nothing to export") return end
    -- convert poses to savable data (CFrame -> table)
    local function cframeToTable(cf)
        local p = cf.Position
        local r = {cf:ToEulerAnglesXYZ()}
        return {p.X, p.Y, p.Z, r[1], r[2], r[3]}
    end
    local export = {}
    for i,k in ipairs(Keyframes) do
        local e = { name = k.name, time = k.time, pose = {} }
        for pn, pd in pairs(k.pose) do
            e.pose[pn] = cframeToTable(pd.CFrame)
        end
        table.insert(export, e)
    end
    local json = game:GetService("HttpService"):JSONEncode(export)
    pcall(function() setclipboard(json) end)
    notify("Exported","Keyframes copied to clipboard")
end)

local importBox = tabAnims:AddTextbox("Paste JSON here then press Import", "", function() end)
local importBtn = tabAnims:AddButton("Import Keyframes from JSON", function()
    local txt = importBox.Text
    if txt == "" then notify("Import failed","Paste JSON into the box first") return end
    local ok, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(txt) end)
    if not ok or type(decoded) ~= "table" then notify("Import failed","Invalid JSON") return end
    Keyframes = {}
    local function tableToCFrame(t)
        -- t = {x,y,z,rx,ry,rz}
        local pos = Vector3.new(t[1], t[2], t[3])
        local rx,ry,rz = t[4], t[5], t[6]
        local cf = CFrame.new(pos) * CFrame.fromEulerAnglesXYZ(rx,ry,rz)
        return cf
    end
    for i,entry in ipairs(decoded) do
        local pose = {}
        for pn, pd in pairs(entry.pose or {}) do
            pose[pn] = { CFrame = tableToCFrame(pd) }
        end
        Keyframes[#Keyframes+1] = { name = entry.name or ("Frame_"..#Keyframes+1), time = entry.time or #Keyframes+1, pose = pose }
    end
    notify("Imported","Keyframes imported: "..#Keyframes)
end)

-- Player tab controls (appearance & toggles)
tabPlayer:AddLabelSmall("Character utilities")
local resetCharBtn = tabPlayer:AddButton("Respawn / Reset Character", function()
    if player.Character then
        player:LoadCharacter()
        notify("Respawned","Character respawned")
    end
end)
local freezeToggle = tabPlayer:AddToggle("Freeze Character (prevent physics)", false, function(state)
    if player.Character then
        for _,v in pairs(player.Character:GetChildren()) do
            if v:IsA("BasePart") then
                v.Anchored = state
            end
        end
    end
end)

-- Settings tab
tabSettings:AddLabelSmall("Theme & UI")
local accentBox = tabSettings:AddTextbox("Accent Color hex (without #)", "00BFFF", function(val)
    local ok, r, g, b = pcall(function() return tonumber("0x"..val:sub(1,2)), tonumber("0x"..val:sub(3,4)), tonumber("0x"..val:sub(5,6)) end)
    if ok and #val==6 then
        THEME.accent = Color3.fromHex(val)
        notify("Theme","Accent updated")
    else
        notify("Theme","Invalid hex")
    end
end)
local guiToggle = tabSettings:AddToggle("Show/Hide Editor", true, function(state)
    local sg = playerGui:FindFirstChild("Reyfield_Fallback_FEAEditor")
    if sg then sg.Enabled = state end
end)

-- Style tweaks: tint accent across buttons (if fallback used)
pcall(function()
    local sg = playerGui:FindFirstChild("Reyfield_Fallback_FEAEditor")
    if sg then
        local function tintButtons()
            for _, btn in pairs(sg:GetDescendants()) do
                if btn:IsA("TextButton") then
                    -- give accent border glow
                    btn.BorderSizePixel = 0
                    local u = Instance.new("UIStroke")
                    u.Thickness = 1
                    u.Transparency = 0.5
                    u.Color = THEME.accent
                    u.Parent = btn
                end
                if btn:IsA("TextLabel") then
                    btn.TextColor3 = THEME.text
                end
            end
        end
        tintButtons()
    end
end)

-- Keybind to toggle UI (RightShift)
do
    local uis = game:GetService("UserInputService")
    local visible = true
    uis.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            visible = not visible
            local sg = playerGui:FindFirstChild("Reyfield_Fallback_FEAEditor")
            if sg then sg.Enabled = visible end
        end
    end)
end

-- Finalize init
notify("FEA Editor", "Ready — theme: dark + electric blue. RightShift to toggle UI.")

-- End of script

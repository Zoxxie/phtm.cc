local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local PhantomUI = {}

-- Purple and Black Theme Constants
local Theme = {
    TopBar = Color3.fromRGB(12, 12, 12),
    PanelBg = Color3.fromRGB(18, 18, 18),
    ModBg = Color3.fromRGB(22, 22, 22),
    Accent = Color3.fromRGB(147, 51, 234), -- Deep Purple
    Text = Color3.fromRGB(240, 240, 240),
    DimText = Color3.fromRGB(160, 170, 180)
}

-- Config Folder Setup for Executors
if makefolder and not isfolder("PhantomUI_Configs") then
    makefolder("PhantomUI_Configs")
end

local function applyCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

function PhantomUI:CreateWindow(config)
    local Window = {
        Name = config.Name or "phantom.cc",
        Version = config.Version or "v1.0",
        ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift,
        Panels = 0,
        Keybinds = {},
        ActiveModules = {},           -- Stores bool state for toggles
        SliderValues = {},            -- Stores number values for sliders
        UpdateVisualCache = {},       -- Visual updaters
        ToggleCallbacks = {},         -- Toggle logic callbacks
        SliderSetters = {},           -- Allows remote setting of sliders by LoadConfig
        BindingModule = nil
    }

    local existing = CoreGui:FindFirstChild(Window.Name)
    if existing then existing:Destroy() end

    Window.ScreenGui = Instance.new("ScreenGui")
    Window.ScreenGui.Name = Window.Name
    Window.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Window.ScreenGui.IgnoreGuiInset = true
    Window.ScreenGui.Parent = CoreGui

    Window.Container = Instance.new("Frame")
    Window.Container.Name = "ClickGuiContainer"
    Window.Container.Size = UDim2.new(1, 0, 1, 0)
    Window.Container.BackgroundTransparency = 1
    Window.Container.Visible = false -- Hide until loaded
    Window.Container.Parent = Window.ScreenGui

    Window.Flags = setmetatable({}, {
        __index = function(self, key)
            if Window.ActiveModules[key] ~= nil then return Window.ActiveModules[key] end
            if Window.SliderValues[key] ~= nil then return Window.SliderValues[key] end
            if string.find(key, "Color") then return {Color = Color3.fromRGB(255,255,255), Transparency = 0} end
            if string.find(key, "Bind") or string.find(key, "Key") then return {active = false, Toggled = false} end
            -- maybe values are keybinds
            if Window.Keybinds[key] ~= nil then return {active = false, Toggled = false, Key = Window.Keybinds[key]} end
            return false
        end,
        __newindex = function(self, key, value)
            if type(value) == "boolean" then Window.ActiveModules[key] = value
            elseif type(value) == "number" then Window.SliderValues[key] = value end
        end
    })


    Window.Blur = Instance.new("BlurEffect")
    Window.Blur.Name = Window.Name .. "Blur"
    Window.Blur.Size = 0 -- Start without blur during loading
    Window.Blur.Parent = game:GetService("Lighting")

    -- Advanced Loading Sequence
    local loadFrame = Instance.new("Frame")
    loadFrame.Size = UDim2.new(1, 0, 1, 0)
    loadFrame.BackgroundTransparency = 0.2
    loadFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    loadFrame.Parent = Window.ScreenGui

    local logoContainer = Instance.new("Frame")
    logoContainer.Size = UDim2.new(0, 100, 0, 100)
    logoContainer.Position = UDim2.new(0.5, -50, 0.5, -50)
    logoContainer.BackgroundTransparency = 1
    logoContainer.Parent = loadFrame

    -- Outer Thin Ring
    local ring1 = Instance.new("Frame")
    ring1.Size = UDim2.new(1, 0, 1, 0)
    ring1.Position = UDim2.new(0, 0, 0, 0)
    ring1.BackgroundColor3 = Theme.Accent
    ring1.BackgroundTransparency = 0.3
    ring1.Parent = logoContainer
    applyCorner(ring1, 50)
    
    local hole1 = Instance.new("Frame")
    hole1.Size = UDim2.new(1, -4, 1, -4)
    hole1.Position = UDim2.new(0, 2, 0, 2)
    hole1.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    hole1.Parent = ring1
    applyCorner(hole1, 50)

    -- Inner Reverse Ring
    local ring2 = Instance.new("Frame")
    ring2.Size = UDim2.new(0, 70, 0, 70)
    ring2.Position = UDim2.new(0.5, -35, 0.5, -35)
    ring2.BackgroundColor3 = Color3.new(1, 1, 1)
    ring2.BackgroundTransparency = 0.8
    ring2.Parent = logoContainer
    applyCorner(ring2, 35)
    
    local hole2 = Instance.new("Frame")
    hole2.Size = UDim2.new(1, -6, 1, -6)
    hole2.Position = UDim2.new(0, 3, 0, 3)
    hole2.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    hole2.Parent = ring2
    applyCorner(hole2, 35)

    -- Pulsing Core
    local core = Instance.new("Frame")
    core.Size = UDim2.new(0, 20, 0, 20)
    core.Position = UDim2.new(0.5, -10, 0.5, -10)
    core.BackgroundColor3 = Theme.Accent
    core.Parent = logoContainer
    applyCorner(core, 10)

    -- Text Elements
    local loadText = Instance.new("TextLabel")
    loadText.Size = UDim2.new(0, 300, 0, 30)
    loadText.Position = UDim2.new(0.5, -150, 0.5, 65)
    loadText.BackgroundTransparency = 1
    loadText.Text = ""
    loadText.TextColor3 = Color3.new(1, 1, 1)
    loadText.Font = Enum.Font.GothamBold
    loadText.TextSize = 18
    loadText.Parent = loadFrame

    local subText = Instance.new("TextLabel")
    subText.Size = UDim2.new(0, 300, 0, 20)
    subText.Position = UDim2.new(0.5, -150, 0.5, 90)
    subText.BackgroundTransparency = 1
    subText.Text = "initializing architecture..."
    subText.TextColor3 = Theme.Accent
    subText.Font = Enum.Font.Gotham
    subText.TextSize = 12
    subText.TextTransparency = 1
    subText.Parent = loadFrame

    -- Animation Tweens
    local t1 = TweenService:Create(ring1, TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
    local t2 = TweenService:Create(ring2, TweenInfo.new(1.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = -360})
    local t3 = TweenService:Create(core, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0.5, -15, 0.5, -15), BackgroundTransparency = 0.5
    })
    
    t1:Play()
    t2:Play()
    t3:Play()

    -- Execution Sequence
    task.spawn(function()
        local fullText = "phantom.cc"
        for i = 1, #fullText do
            loadText.Text = string.sub(fullText, 1, i)
            task.wait(0.05)
        end
        
        TweenService:Create(subText, TweenInfo.new(0.4), {TextTransparency = 0.2}):Play()
        task.wait(0.7)
        subText.Text = "bypassing security..."
        task.wait(0.7)
        subText.Text = "injection successful."
        subText.TextColor3 = Color3.fromRGB(50, 220, 50)
        
        task.wait(0.5)
        
        -- Explode & Fade transition
        t1:Cancel() t2:Cancel() t3:Cancel()
        TweenService:Create(ring1, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 300), Position = UDim2.new(0.5, -150, 0.5, -150), BackgroundTransparency = 1}):Play()
        TweenService:Create(ring2, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 200, 0, 200), Position = UDim2.new(0.5, -100, 0.5, -100), BackgroundTransparency = 1}):Play()
        TweenService:Create(core, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        
        TweenService:Create(loadText, TweenInfo.new(0.4), {TextTransparency = 1, Position = UDim2.new(0.5, -150, 0.5, 55)}):Play()
        TweenService:Create(subText, TweenInfo.new(0.4), {TextTransparency = 1, Position = UDim2.new(0.5, -150, 0.5, 80)}):Play()
        TweenService:Create(loadFrame, TweenInfo.new(0.7), {BackgroundTransparency = 1}):Play()
        
        task.wait(0.7)
        loadFrame:Destroy()
        
        -- UI Reveal
        Window.Container.Position = UDim2.new(0, 0, 0, 20)
        Window.Container.Visible = true
        TweenService:Create(Window.Container, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        TweenService:Create(Window.Blur, TweenInfo.new(0.4), {Size = 12}):Play()
    end)

    -- Watermark
    local watermarkFrame = Instance.new("Frame")
    watermarkFrame.Name = "Watermark"
    watermarkFrame.Size = UDim2.new(0, 0, 0, 26)
    watermarkFrame.Position = UDim2.new(0.5, 0, 0, 15)
    watermarkFrame.AnchorPoint = Vector2.new(0.5, 0)
    watermarkFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    watermarkFrame.BackgroundTransparency = 0.1
    watermarkFrame.BorderSizePixel = 0
    watermarkFrame.AutomaticSize = Enum.AutomaticSize.X
    watermarkFrame.Parent = Window.ScreenGui
    applyCorner(watermarkFrame, 6)

    local wmStroke = Instance.new("UIStroke")
    wmStroke.Color = Color3.fromRGB(30, 30, 30)
    wmStroke.Thickness = 1
    wmStroke.Parent = watermarkFrame

    local watermarkLabel = Instance.new("TextLabel")
    watermarkLabel.Name = "Label"
    watermarkLabel.Size = UDim2.new(0, 0, 1, 0)
    watermarkLabel.Position = UDim2.new(0, 0, 0, 0)
    watermarkLabel.BackgroundTransparency = 1
    watermarkLabel.Text = string.format("  %s | %s | 60 FPS  ", Window.Name, Window.Version)
    watermarkLabel.TextColor3 = Theme.Text
    watermarkLabel.Font = Enum.Font.GothamSemibold
    watermarkLabel.TextSize = 13
    watermarkLabel.AutomaticSize = Enum.AutomaticSize.X
    watermarkLabel.Parent = watermarkFrame

    local wmAccent = Instance.new("Frame")
    wmAccent.Name = "Accent"
    wmAccent.Size = UDim2.new(1, 0, 0, 2)
    wmAccent.Position = UDim2.new(0, 0, 0, 0)
    wmAccent.BackgroundColor3 = Theme.Accent
    wmAccent.BorderSizePixel = 0
    wmAccent.Parent = watermarkFrame
    applyCorner(wmAccent, 6)

    -- Dynamic FPS
    local frames = 0
    local lastUpdate = tick()
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        if tick() - lastUpdate >= 1 then
            watermarkLabel.Text = string.format("  %s | %s | %d FPS  ", Window.Name, Window.Version, frames)
            frames = 0
            lastUpdate = tick()
        end
    end)

    -- HUD
    Window.HUD = Instance.new("Frame")
    Window.HUD.Name = "HUD"
    Window.HUD.Size = UDim2.new(0, 200, 1, -40)
    Window.HUD.Position = UDim2.new(1, -210, 0, 20)
    Window.HUD.BackgroundTransparency = 1
    Window.HUD.Parent = Window.ScreenGui

    local hudLayout = Instance.new("UIListLayout")
    hudLayout.SortOrder = Enum.SortOrder.LayoutOrder
    hudLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    hudLayout.Padding = UDim.new(0, 2)
    hudLayout.Parent = Window.HUD

    function Window:ToggleHUD(moduleName, isEnabled)
        if isEnabled then
            if self.HUD:FindFirstChild(moduleName) then return end
            
            local label = Instance.new("TextLabel")
            label.Name = moduleName
            label.Size = UDim2.new(0, 0, 0, 22)
            label.BackgroundTransparency = 1
            label.Text = string.format("%s", moduleName)
            label.TextColor3 = Theme.Accent
            label.Font = Enum.Font.GothamSemibold
            label.TextSize = 15
            label.TextXAlignment = Enum.TextXAlignment.Right
            label.AutomaticSize = Enum.AutomaticSize.X
            label.LayoutOrder = -#moduleName
            
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(0, 0, 0)
            stroke.Transparency = 0.5
            stroke.Thickness = 1.2
            stroke.Parent = label
            
            label.Parent = self.HUD
            
            label.Position = UDim2.new(0, 30, 0, 0)
            label.TextTransparency = 1
            TweenService:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 0, 0, 0),
                TextTransparency = 0
            }):Play()
        else
            local label = self.HUD:FindFirstChild(moduleName)
            if label then
                local t = TweenService:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 30, 0, 0),
                    TextTransparency = 1
                })
                t:Play()
                t.Completed:Connect(function() label:Destroy() end)
            end
        end
    end

    -- Input Handling
    UserInputService.InputBegan:Connect(function(input, processed)
        if Window.BindingModule then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local bMod = Window.BindingModule
                if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                    Window.Keybinds[bMod] = nil
                else
                    Window.Keybinds[bMod] = input.KeyCode
                end
                
                if Window.UpdateVisualCache[bMod] then
                    Window.UpdateVisualCache[bMod]()
                end
                
                Window.BindingModule = nil
            end
            return
        end

        if processed then return end

        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Window.ToggleKey then
                Window.Container.Visible = not Window.Container.Visible
                TweenService:Create(Window.Blur, TweenInfo.new(0.3), {
                    Size = Window.Container.Visible and 12 or 0
                }):Play()
            else
                for modName, key in pairs(Window.Keybinds) do
                    if input.KeyCode == key and Window.ToggleCallbacks[modName] then
                        Window.ToggleCallbacks[modName]()
                    end
                end
            end
        end
    end)

    -- Config IO
    function Window:SaveConfig(filename)
        if not writefile then return false end
        local saveTable = {
            Toggles = Window.ActiveModules,
            Sliders = Window.SliderValues,
            Keybinds = {}
        }
        for mod, keycode in pairs(Window.Keybinds) do
            saveTable.Keybinds[mod] = keycode.Name -- Save Enum string
        end
        local success, encoded = pcall(function() return HttpService:JSONEncode(saveTable) end)
        if success then
            writefile("PhantomUI_Configs/" .. filename .. ".json", encoded)
            return true
        end
        return false
    end

    function Window:LoadConfig(filename)
        if not readfile or not isfile("PhantomUI_Configs/" .. filename .. ".json") then return false end
        local success, decoded = pcall(function() 
            return HttpService:JSONDecode(readfile("PhantomUI_Configs/" .. filename .. ".json")) 
        end)
        
        if success and type(decoded) == "table" then
            -- Load Keybinds
            if decoded.Keybinds then
                for mod, keyName in pairs(decoded.Keybinds) do
                    local enumMatch = Enum.KeyCode[keyName]
                    if enumMatch then
                        Window.Keybinds[mod] = enumMatch
                    end
                end
            end
            
            -- Load Sliders
            if decoded.Sliders then
                for sName, sVal in pairs(decoded.Sliders) do
                    if Window.SliderSetters[sName] then
                        Window.SliderSetters[sName](sVal)
                    end
                end
            end
            
            -- Load Toggles
            if decoded.Toggles then
                for tName, state in pairs(decoded.Toggles) do
                    -- Only trigger if the state actually needs changing
                    local currentState = Window.ActiveModules[tName] or false
                    if currentState ~= state and Window.ToggleCallbacks[tName] then
                        Window.ToggleCallbacks[tName](true) -- Programmatic call
                    end
                end
            end
            
            -- Refresh visuals
            for _, updater in pairs(Window.UpdateVisualCache) do
                updater()
            end
            return true
        end
        return false
    end

    function Window:BuildSettingsTab()
        local SetTab = self:CreateCategory("Settings")
        SetTab:CreateButton({
            Name = "Save Config (default)",
            Callback = function()
                self:SaveConfig("default")
            end
        })
        SetTab:CreateButton({
            Name = "Load Config (default)",
            Callback = function()
                self:LoadConfig("default")
            end
        })
    end

    function Window:CreateCategory(categoryName)
        local Category = { Name = categoryName }

        local startX = 20
        local panelWidth = 160
        local spacing = 15

        local panel = Instance.new("Frame")
        panel.Name = categoryName
        panel.Size = UDim2.new(0, panelWidth, 0, 30)
        panel.Position = UDim2.new(0, startX + self.Panels * (panelWidth + spacing), 0, 60)
        panel.BackgroundColor3 = Theme.PanelBg
        panel.BorderSizePixel = 0
        panel.Active = true
        panel.Draggable = true
        panel.AutomaticSize = Enum.AutomaticSize.Y
        panel.Parent = self.Container
        applyCorner(panel, 6)
        
        self.Panels = self.Panels + 1
        
        local dropShadow = Instance.new("UIStroke")
        dropShadow.Color = Color3.fromRGB(0, 0, 0)
        dropShadow.Transparency = 0.6
        dropShadow.Thickness = 1
        dropShadow.Parent = panel

        local topbar = Instance.new("Frame")
        topbar.Name = "Topbar"
        topbar.Size = UDim2.new(1, 0, 0, 30)
        topbar.BackgroundColor3 = Theme.TopBar
        topbar.BorderSizePixel = 0
        topbar.Parent = panel
        applyCorner(topbar, 5)
        
        local fixBottom = Instance.new("Frame")
        fixBottom.Size = UDim2.new(1, 0, 0, 6)
        fixBottom.Position = UDim2.new(0, 0, 1, -6)
        fixBottom.BackgroundColor3 = Theme.TopBar
        fixBottom.BorderSizePixel = 0
        fixBottom.Parent = topbar
        
        local topAccent = Instance.new("Frame")
        topAccent.Size = UDim2.new(1, 0, 0, 2)
        topAccent.BackgroundColor3 = Theme.Accent
        topAccent.BorderSizePixel = 0
        topAccent.Parent = topbar
        applyCorner(topAccent, 4)

        local catLabel = Instance.new("TextLabel")
        catLabel.Size = UDim2.new(1, 0, 1, 0)
        catLabel.BackgroundTransparency = 1
        catLabel.Text = categoryName
        catLabel.TextColor3 = Theme.Text
        catLabel.Font = Enum.Font.GothamBold
        catLabel.TextSize = 13
        catLabel.Parent = topbar

        local moduleContainer = Instance.new("Frame")
        moduleContainer.Name = "Modules"
        moduleContainer.Size = UDim2.new(1, 0, 0, 0)
        moduleContainer.Position = UDim2.new(0, 0, 0, 30)
        moduleContainer.BackgroundTransparency = 1
        moduleContainer.AutomaticSize = Enum.AutomaticSize.Y
        moduleContainer.Parent = panel

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = moduleContainer
        
        local padding = Instance.new("UIPadding")
        padding.PaddingBottom = UDim.new(0, 4)
        padding.Parent = moduleContainer
        
        function Category:CreateToggle(options)
            local modName = options.Flag or options.Name or "Unknown"
            local defaultKeybind = options.Keybind
            local callback = options.Callback or function() end
            
            if defaultKeybind then
                Window.Keybinds[modName] = defaultKeybind
            end

            local modBtn = Instance.new("TextButton")
            modBtn.Name = modName
            modBtn.Size = UDim2.new(1, 0, 0, 30)
            modBtn.BackgroundColor3 = Theme.ModBg
            modBtn.BorderSizePixel = 0
            modBtn.Text = ""
            modBtn.AutoButtonColor = false
            modBtn.Parent = moduleContainer
            
            local modLabel = Instance.new("TextLabel")
            modLabel.Name = "ModLabel"
            modLabel.Size = UDim2.new(1, -20, 1, 0)
            modLabel.Position = UDim2.new(0, 10, 0, 0)
            modLabel.BackgroundTransparency = 1
            modLabel.Text = modName
            modLabel.TextColor3 = Theme.DimText
            modLabel.Font = Enum.Font.GothamSemibold
            modLabel.TextSize = 13
            modLabel.TextXAlignment = Enum.TextXAlignment.Left
            modLabel.Parent = modBtn
            
            local bindLabel = Instance.new("TextLabel")
            bindLabel.Name = "BindLabel"
            bindLabel.Size = UDim2.new(0, 40, 1, 0)
            bindLabel.Position = UDim2.new(1, -45, 0, 0)
            bindLabel.BackgroundTransparency = 1
            bindLabel.Text = "[-]"
            bindLabel.TextColor3 = Color3.fromRGB(80, 80, 80)
            bindLabel.Font = Enum.Font.Gotham
            bindLabel.TextSize = 11
            bindLabel.TextXAlignment = Enum.TextXAlignment.Right
            bindLabel.Parent = modBtn

            local function updateToggleVisual()
                local isEnabled = Window.ActiveModules[modName]
                
                if Window.BindingModule == modName then
                    bindLabel.Text = "[...]"
                    bindLabel.TextColor3 = Theme.Accent
                else
                    local key = Window.Keybinds[modName]
                    bindLabel.Text = key and string.format("[%s]", key.Name) or "[-]"
                    bindLabel.TextColor3 = isEnabled and Color3.new(1, 1, 1) or Color3.fromRGB(80, 80, 80)
                end
                
                TweenService:Create(modBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = isEnabled and Theme.Accent or Theme.ModBg
                }):Play()
                TweenService:Create(modLabel, TweenInfo.new(0.2), {
                    TextColor3 = isEnabled and Color3.new(1, 1, 1) or Theme.DimText
                }):Play()
            end
            Window.UpdateVisualCache[modName] = updateToggleVisual
            updateToggleVisual()

            local function executeToggle(isProgrammaticCall)
                if Window.BindingModule and not isProgrammaticCall then return end
                local newState = not Window.ActiveModules[modName]
                Window.ActiveModules[modName] = newState
                
                updateToggleVisual()
                Window:ToggleHUD(modName, newState)
                callback(newState)
            end
            Window.ToggleCallbacks[modName] = executeToggle

            modBtn.MouseButton1Click:Connect(executeToggle)
            modBtn.MouseButton2Click:Connect(function()
                if Window.BindingModule == modName then
                    Window.BindingModule = nil
                else
                    Window.BindingModule = modName
                end
                updateToggleVisual()
            end)
            modBtn.MouseEnter:Connect(function()
                if not Window.ActiveModules[modName] and Window.BindingModule ~= modName then
                    TweenService:Create(modBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
                    TweenService:Create(modLabel, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
                end
            end)
            modBtn.MouseLeave:Connect(function()
                if not Window.ActiveModules[modName] and Window.BindingModule ~= modName then
                    TweenService:Create(modBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ModBg}):Play()
                    TweenService:Create(modLabel, TweenInfo.new(0.15), {TextColor3 = Theme.DimText}):Play()
                end
            end)
        return getChainingObject()
        end

        function Category:CreateButton(options)
            local modName = options.Flag or options.Name or "Button"
            local callback = options.Callback or function() end

            local modBtn = Instance.new("TextButton")
            modBtn.Name = modName
            modBtn.Size = UDim2.new(1, 0, 0, 30)
            modBtn.BackgroundColor3 = Theme.ModBg
            modBtn.BorderSizePixel = 0
            modBtn.Text = ""
            modBtn.AutoButtonColor = false
            modBtn.Parent = moduleContainer
            
            local modLabel = Instance.new("TextLabel")
            modLabel.Name = "ModLabel"
            modLabel.Size = UDim2.new(1, -20, 1, 0)
            modLabel.Position = UDim2.new(0, 10, 0, 0)
            modLabel.BackgroundTransparency = 1
            modLabel.Text = modName
            modLabel.TextColor3 = Theme.Text
            modLabel.Font = Enum.Font.GothamSemibold
            modLabel.TextSize = 13
            modLabel.TextXAlignment = Enum.TextXAlignment.Center
            modLabel.Parent = modBtn

            modBtn.MouseButton1Click:Connect(callback)

            modBtn.MouseEnter:Connect(function()
                TweenService:Create(modBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
            end)
            modBtn.MouseLeave:Connect(function()
                TweenService:Create(modBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ModBg}):Play()
            end)
            modBtn.MouseButton1Down:Connect(function()
                TweenService:Create(modBtn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
            end)
            modBtn.MouseButton1Up:Connect(function()
                TweenService:Create(modBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
            end)
        return getChainingObject()
        end

        function Category:CreateSlider(options)
            local modName = options.Flag or options.Name or "Slider"
            local min = options.Min or 0
            local max = options.Max or 100
            local default = options.Default or min
            local callback = options.Callback or function() end

            Window.SliderValues[modName] = default

            local sliderFrame = Instance.new("Frame")
            sliderFrame.Name = modName
            sliderFrame.Size = UDim2.new(1, 0, 0, 35)
            sliderFrame.BackgroundColor3 = Theme.ModBg
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Parent = moduleContainer
            
            local modLabel = Instance.new("TextLabel")
            modLabel.Size = UDim2.new(1, -20, 0, 15)
            modLabel.Position = UDim2.new(0, 10, 0, 5)
            modLabel.BackgroundTransparency = 1
            modLabel.Text = modName .. ": " .. tostring(default)
            modLabel.TextColor3 = Theme.DimText
            modLabel.Font = Enum.Font.GothamSemibold
            modLabel.TextSize = 12
            modLabel.TextXAlignment = Enum.TextXAlignment.Left
            modLabel.Parent = sliderFrame

            local barBg = Instance.new("Frame")
            barBg.Size = UDim2.new(1, -20, 0, 4)
            barBg.Position = UDim2.new(0, 10, 0, 24)
            barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            barBg.BorderSizePixel = 0
            barBg.Parent = sliderFrame
            applyCorner(barBg, 4)

            local barFill = Instance.new("Frame")
            barFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            barFill.BackgroundColor3 = Theme.Accent
            barFill.BorderSizePixel = 0
            barFill.Parent = barBg
            applyCorner(barFill, 4)

            local trigger = Instance.new("TextButton")
            trigger.Size = UDim2.new(1, 0, 1, 0)
            trigger.BackgroundTransparency = 1
            trigger.Text = ""
            trigger.Parent = sliderFrame

            local dragging = false
            local function updateSlider(input)
                local mathClamped = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                local finalValue = math.floor(min + ((max - min) * mathClamped))
                
                Window.SliderValues[modName] = finalValue
                modLabel.Text = modName .. ": " .. tostring(finalValue)
                TweenService:Create(barFill, TweenInfo.new(0.05), {Size = UDim2.new(mathClamped, 0, 1, 0)}):Play()
                callback(finalValue)
            end

            -- Setter for load config
            Window.SliderSetters[modName] = function(val)
                val = math.clamp(val, min, max)
                Window.SliderValues[modName] = val
                modLabel.Text = modName .. ": " .. tostring(val)
                local percent = (val - min) / (max - min)
                barFill.Size = UDim2.new(percent, 0, 1, 0)
                callback(val)
            end

            trigger.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
                end
            end)
            trigger.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            return getChainingObject()
        end

        
        local function getChainingObject()
            local Chain = {}
            function Chain:Toggle(opts) Category:CreateToggle(opts); return Chain end
            function Chain:CreateToggle(opts) Category:CreateToggle(opts); return Chain end
            function Chain:Button(opts) Category:CreateButton(opts); return Chain end
            function Chain:CreateButton(opts) Category:CreateButton(opts); return Chain end
            function Chain:Slider(opts) Category:CreateSlider(opts); return Chain end
            function Chain:CreateSlider(opts) Category:CreateSlider(opts); return Chain end
            function Chain:Dropdown(opts) Category:CreateDropdown(opts); return Chain end
            function Chain:CreateDropdown(opts) Category:CreateDropdown(opts); return Chain end
            function Chain:Label(opts) Category:CreateLabel(opts); return Chain end
            function Chain:CreateLabel(opts) Category:CreateLabel(opts); return Chain end
            function Chain:Colorpicker(opts) Category:CreateColorpicker(opts); return Chain end
            function Chain:CreateColorpicker(opts) Category:CreateColorpicker(opts); return Chain end
            function Chain:Keybind(opts) Category:CreateKeybind(opts); return Chain end
            function Chain:CreateKeybind(opts) Category:CreateKeybind(opts); return Chain end
            function Chain:Section(opts) Category:CreateSection(opts); return Chain end
            function Chain:CreateSection(opts) Category:CreateSection(opts); return Chain end
            return Chain
        end

        function Category:CreateDropdown(options)
            local modName = options.Flag or options.Name or "Dropdown"
            local modLabel = Instance.new("TextLabel")
            modLabel.Size = UDim2.new(1, -20, 0, 20)
            modLabel.Position = UDim2.new(0, 10, 0, 0)
            modLabel.BackgroundTransparency = 1
            modLabel.Text = modName .. " (Dropdown)"
            modLabel.TextColor3 = Theme.DimText
            modLabel.Font = Enum.Font.GothamSemibold
            modLabel.TextSize = 13
            modLabel.TextXAlignment = Enum.TextXAlignment.Left
            modLabel.Parent = moduleContainer
            return getChainingObject()
        end

        function Category:CreateLabel(options)
            local modName = type(options) == "string" and options or (options.Name or "Label")
            local modLabel = Instance.new("TextLabel")
            modLabel.Size = UDim2.new(1, -20, 0, 20)
            modLabel.Position = UDim2.new(0, 10, 0, 0)
            modLabel.BackgroundTransparency = 1
            modLabel.Text = modName
            modLabel.TextColor3 = Theme.Text
            modLabel.Font = Enum.Font.Gotham
            modLabel.TextSize = 12
            modLabel.TextWrapped = true
            modLabel.TextXAlignment = Enum.TextXAlignment.Left
            modLabel.Parent = moduleContainer
            return getChainingObject()
        end

        function Category:CreateColorpicker(options)
            local modName = options.Flag or options.Name or "Colorpicker"
            local modLabel = Instance.new("TextLabel")
            modLabel.Size = UDim2.new(1, -20, 0, 20)
            modLabel.Position = UDim2.new(0, 10, 0, 0)
            modLabel.BackgroundTransparency = 1
            modLabel.Text = modName .. " [Color]"
            modLabel.TextColor3 = type(options.Default) == "userdata" and options.Default or Theme.DimText
            modLabel.Font = Enum.Font.GothamSemibold
            modLabel.TextSize = 13
            modLabel.TextXAlignment = Enum.TextXAlignment.Left
            modLabel.Parent = moduleContainer
            return getChainingObject()
        end

        function Category:CreateKeybind(options)
            local modName = options.Flag or options.Name or "Keybind"
            local modLabel = Instance.new("TextLabel")
            modLabel.Size = UDim2.new(1, -20, 0, 20)
            modLabel.Position = UDim2.new(0, 10, 0, 0)
            modLabel.BackgroundTransparency = 1
            modLabel.Text = modName .. " [Bind]"
            modLabel.TextColor3 = Theme.DimText
            modLabel.Font = Enum.Font.GothamSemibold
            modLabel.TextSize = 13
            modLabel.TextXAlignment = Enum.TextXAlignment.Left
            modLabel.Parent = moduleContainer
            return getChainingObject()
        end

        function Category:CreateSection(options)
            local secName = type(options) == "string" and options or (options.Name or "Section")
            local secLabel = Instance.new("TextLabel")
            secLabel.Size = UDim2.new(1, 0, 0, 25)
            secLabel.Position = UDim2.new(0, 0, 0, 0)
            secLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            secLabel.BorderSizePixel = 0
            secLabel.Text = "  " .. secName
            secLabel.TextColor3 = Theme.Accent
            secLabel.Font = Enum.Font.GothamBold
            secLabel.TextSize = 11
            secLabel.TextXAlignment = Enum.TextXAlignment.Left
            secLabel.Parent = moduleContainer
            return getChainingObject()
        end
        
        Category.Toggle = Category.CreateToggle
        Category.Button = Category.CreateButton
        Category.Slider = Category.CreateSlider
        Category.Dropdown = Category.CreateDropdown
        Category.Label = Category.CreateLabel
        Category.Colorpicker = Category.CreateColorpicker
        Category.Keybind = Category.CreateKeybind
        Category.Section = Category.CreateSection

        return Category
    end

    -- Build the built-in Settings Manager tab
    Window:BuildSettingsTab()



    Window.Page = Window.CreateCategory
    
    function Window:Watermark(text)
        watermarkLabel.Text = "  " .. text .. string.format(" | %s | 60 FPS  ", Window.Version)
        
        local obj = {}
        function obj:SetVisibility(v) watermarkFrame.Visible = v end
        return obj
    end
    
    function Window:KeybindList()
        local obj = {}
        function obj:SetVisibility(v) end
        return obj
    end
    
    function Window:ArmorViewer()
        local obj = {}
        function obj:SetVisibility(v) end
        return obj
    end


    return Window
end

function PhantomUI:CreateSettingsPage(...) return end

return PhantomUI

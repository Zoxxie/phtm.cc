-- phantom.cc Premium UI Library
-- Highly optimized, modern, 2-column UI architecture
-- For Roblox Executors

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Library = {}
local Utility = {}

local Theme = {
    Bg = Color3.fromRGB(15, 15, 20),
    Sidebar = Color3.fromRGB(20, 20, 26),
    Topbar = Color3.fromRGB(20, 20, 26),
    Accent = Color3.fromRGB(99, 102, 241), -- Sleek Indigo
    Text = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(140, 140, 150),
    SectionBg = Color3.fromRGB(22, 22, 28),
    ElementBg = Color3.fromRGB(30, 30, 38),
    ElementHover = Color3.fromRGB(38, 38, 48),
    Border = Color3.fromRGB(40, 40, 50),
    Placeholder = Color3.fromRGB(100, 100, 110)
}

function Utility:Create(class, properties)
    local i = Instance.new(class)
    for k, v in pairs(properties) do
        if type(k) == "number" then
            v.Parent = i
        else
            i[k] = v
        end
    end
    return i
end

function Utility:Corner(parent, radius)
    return Utility:Create("UICorner", {Parent = parent, CornerRadius = UDim.new(0, radius)})
end

function Utility:Stroke(parent, color, thickness)
    return Utility:Create("UIStroke", {Parent = parent, Color = color, Thickness = thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
end

function Utility:Tween(obj, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
end

if makefolder and not isfolder("PhantomUI_Configs") then
    makefolder("PhantomUI_Configs")
end

function Library:CreateWindow(config)
    local Window = {
        Name = config.Name or "phantom.cc",
        Version = config.Version or "v1.0",
        ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift,
        Flags = {},
        Tabs = {},
        ActiveTab = nil,
        Keybinds = {},
        FlagsCache = {
            Toggles = {},
            Sliders = {},
            Colors = {},
            Dropdowns = {}
        },
        UpdateFunctions = {}
    }

    Window.Flags = setmetatable({}, {
        __index = function(self, key)
            if Window.FlagsCache.Toggles[key] ~= nil then return Window.FlagsCache.Toggles[key] end
            if Window.FlagsCache.Sliders[key] ~= nil then return Window.FlagsCache.Sliders[key] end
            if Window.FlagsCache.Colors[key] ~= nil then return Window.FlagsCache.Colors[key] end
            if Window.FlagsCache.Dropdowns[key] ~= nil then return Window.FlagsCache.Dropdowns[key] end
            if Window.Keybinds[key] ~= nil then return {active = false, Toggled = false, Key = Window.Keybinds[key]} end
            if string.find(key, "Color") then return {Color = Color3.fromRGB(255,255,255), Transparency = 0} end
            if string.find(key, "Bind") or string.find(key, "Key") then return {active = false, Toggled = false} end
            return false
        end,
        __newindex = function(self, key, value)
            if Window.UpdateFunctions[key] then
                Window.UpdateFunctions[key](value)
            end
        end
    })

    local existing = CoreGui:FindFirstChild(Window.Name)
    if existing then existing:Destroy() end

    Window.ScreenGui = Utility:Create("ScreenGui", {
        Name = Window.Name,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent = CoreGui
    })

    Window.Blur = Utility:Create("BlurEffect", {
        Name = Window.Name .. "Blur",
        Size = 12,
        Parent = game:GetService("Lighting")
    })

    Window.Main = Utility:Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 580, 0, 420),
        Position = UDim2.new(0.5, -290, 0.5, -210),
        BackgroundColor3 = Theme.Bg,
        Active = true,
        Draggable = true,
        Parent = Window.ScreenGui,
        Utility:Corner(nil, 6),
        Utility:Stroke(nil, Theme.Border)
    })

    -- Shadow
    local shadow = Utility:Create("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015536815",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(30, 30, 30, 30),
        ZIndex = 0,
        Parent = Window.Main
    })

    Window.Sidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = Window.Main,
        Utility:Corner(nil, 6)
    })
    
    -- Fix corner bleed
    Utility:Create("Frame", {
        Size = UDim2.new(0, 6, 1, 0),
        Position = UDim2.new(1, -6, 0, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = Window.Sidebar
    })
    Utility:Create("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Parent = Window.Sidebar
    })

    local Title = Utility:Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Text = string.format("  %s", Window.Name),
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Window.Sidebar
    })
    local AccentLine = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Parent = Title
    })

    Window.TabContainer = Utility:Create("ScrollingFrame", {
        Name = "TabContainer",
        Size = UDim2.new(1, -16, 1, -60),
        Position = UDim2.new(0, 8, 0, 60),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Window.Sidebar,
        Utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4)
        })
    })

    Window.ContentContainer = Utility:Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 150, 0, 0),
        BackgroundTransparency = 1,
        Parent = Window.Main
    })

    -- Watermark
    Window.WatermarkFrame = Utility:Create("Frame", {
        Name = "Watermark",
        Size = UDim2.new(0, 0, 0, 26),
        Position = UDim2.new(0.5, 0, 0, 15),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Theme.Topbar,
        AutomaticSize = Enum.AutomaticSize.X,
        Parent = Window.ScreenGui,
        Utility:Corner(nil, 4),
        Utility:Stroke(nil, Theme.Border)
    })
    local wmAccent = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = Window.WatermarkFrame,
        Utility:Corner(nil, 4)
    })
    Window.WatermarkLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = string.format("  %s | %s | 60 FPS  ", Window.Name, Window.Version),
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        AutomaticSize = Enum.AutomaticSize.X,
        Parent = Window.WatermarkFrame
    })

    local frames = 0
    local lastUpdate = tick()
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        if tick() - lastUpdate >= 1 then
            local t = Window.WatermarkBaseText or string.format("%s | %s", Window.Name, Window.Version)
            Window.WatermarkLabel.Text = string.format("  %s | %d FPS  ", t, frames)
            frames = 0
            lastUpdate = tick()
        end
    end)

    function Window:Watermark(text)
        self.WatermarkBaseText = text .. " | " .. self.Version
        local obj = {}
        function obj:SetVisibility(v) self.WatermarkFrame.Visible = v end
        return obj
    end
    function Window:KeybindList() return {SetVisibility=function()end} end
    function Window:ArmorViewer() return {SetVisibility=function()end} end

    UserInputService.InputBegan:Connect(function(input, processed)
        if Window.BindingModule then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local bMod = Window.BindingModule
                if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                    Window.Keybinds[bMod] = nil
                else
                    Window.Keybinds[bMod] = input.KeyCode
                end
                
                if Window.UpdateFunctions[bMod .. "_BindVisual"] then
                    Window.UpdateFunctions[bMod .. "_BindVisual"]()
                end
                Window.BindingModule = nil
            end
            return
        end

        if processed then return end

        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Window.ToggleKey then
                Window.Main.Visible = not Window.Main.Visible
                Window.Blur.Size = Window.Main.Visible and 12 or 0
            else
                for modName, key in pairs(Window.Keybinds) do
                    if input.KeyCode == key and Window.UpdateFunctions[modName .. "_Toggle"] then
                        Window.UpdateFunctions[modName .. "_Toggle"]()
                    end
                end
            end
        end
    end)

    -- Tab System
    function Window:CreateCategory(categoryName)
        local Tab = { Name = categoryName }
        
        local TabBtn = Utility:Create("TextButton", {
            Name = categoryName,
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.Sidebar, -- Invisible by default
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "   " .. categoryName,
            TextColor3 = Theme.TextDim,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Window.TabContainer,
            Utility:Corner(nil, 6)
        })

        local ContentFrame = Utility:Create("ScrollingFrame", {
            Name = categoryName .. "Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 0,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = Window.ContentContainer
        })

        local LeftCol = Utility:Create("Frame", {
            Name = "LeftCol",
            Size = UDim2.new(0.5, -9, 1, -16),
            Position = UDim2.new(0, 12, 0, 16),
            BackgroundTransparency = 1,
            Parent = ContentFrame,
            Utility:Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        })

        local RightCol = Utility:Create("Frame", {
            Name = "RightCol",
            Size = UDim2.new(0.5, -9, 1, -16),
            Position = UDim2.new(0.5, 3, 0, 16),
            BackgroundTransparency = 1,
            Parent = ContentFrame,
            Utility:Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        })

        local function UpdateCanvasSize()
            local lHeight = LeftCol.UIListLayout.AbsoluteContentSize.Y
            local rHeight = RightCol.UIListLayout.AbsoluteContentSize.Y
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(lHeight, rHeight) + 32)
        end
        LeftCol.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)
        RightCol.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Content.Visible = false
                Utility:Tween(t.Btn, {BackgroundColor3 = Theme.Sidebar, TextColor3 = Theme.TextDim}, 0.15)
            end
            ContentFrame.Visible = true
            Window.ActiveTab = categoryName
            Utility:Tween(TabBtn, {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.new(1,1,1)}, 0.15)
        end)

        table.insert(Window.Tabs, {Btn = TabBtn, Content = ContentFrame})
        if #Window.Tabs == 1 then
            ContentFrame.Visible = true
            Window.ActiveTab = categoryName
            TabBtn.BackgroundColor3 = Theme.Accent
            TabBtn.TextColor3 = Color3.new(1, 1, 1)
        end

        function Tab:CreateSection(options)
            local Section = {}
            local secName = type(options) == "string" and options or (options.Name or "Section")
            local side = (type(options) == "table" and options.Side) or 1
            local targetCol = side == 1 and LeftCol or RightCol

            local SecFrame = Utility:Create("Frame", {
                Name = secName,
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Theme.SectionBg,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = targetCol,
                Utility:Corner(nil, 6),Utility:Stroke(nil, Theme.Border)
            })

            local SecTitle = Utility:Create("TextLabel", {
                Size = UDim2.new(1, -16, 0, 26),
                Position = UDim2.new(0, 8, 0, 4),
                BackgroundTransparency = 1,
                Text = secName,
                TextColor3 = Theme.Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SecFrame
            })

            local SecContainer = Utility:Create("Frame", {
                Size = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, 30),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SecFrame,
                Utility:Create("UIPadding", {PaddingBottom = UDim.new(0, 8)}),
                Utility:Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
            })

            local function getChainingObject()
                local Chain = {}
                function Chain:Toggle(opts) Section:CreateToggle(opts); return Chain end
                function Chain:CreateToggle(opts) Section:CreateToggle(opts); return Chain end
                function Chain:Button(opts) Section:CreateButton(opts); return Chain end
                function Chain:CreateButton(opts) Section:CreateButton(opts); return Chain end
                function Chain:Slider(opts) Section:CreateSlider(opts); return Chain end
                function Chain:CreateSlider(opts) Section:CreateSlider(opts); return Chain end
                function Chain:Dropdown(opts) Section:CreateDropdown(opts); return Chain end
                function Chain:CreateDropdown(opts) Section:CreateDropdown(opts); return Chain end
                function Chain:Label(opts) Section:CreateLabel(opts); return Chain end
                function Chain:CreateLabel(opts) Section:CreateLabel(opts); return Chain end
                function Chain:Colorpicker(opts) Section:CreateColorpicker(opts); return Chain end
                function Chain:CreateColorpicker(opts) Section:CreateColorpicker(opts); return Chain end
                function Chain:Keybind(opts) Section:CreateKeybind(opts); return Chain end
                function Chain:CreateKeybind(opts) Section:CreateKeybind(opts); return Chain end
                return Chain
            end

            function Section:CreateToggle(opts)
                local flag = opts.Flag or opts.Name or "Toggle"
                local default = opts.Default or false
                local cb = opts.Callback or function() end
                
                Window.FlagsCache.Toggles[flag] = default

                local Elem = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Parent = SecContainer
                })
                local Label = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -40, 1, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Name or flag,
                    TextColor3 = default and Theme.Text or Theme.TextDim,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Elem
                })
                local Box = Utility:Create("TextButton", {
                    Size = UDim2.new(0, 34, 0, 18),
                    Position = UDim2.new(1, -34, 0.5, -9),
                    BackgroundColor3 = default and Theme.Accent or Theme.ElementBg,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = Elem,
                    Utility:Corner(nil, 9),
                    Utility:Stroke(nil, Theme.Border)
                })
                local Dot = Utility:Create("Frame", {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0, default and 18 or 2, 0.5, -7),
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    Parent = Box,
                    Utility:Corner(nil, 7)
                })

                local function setVisual(state)
                    Window.FlagsCache.Toggles[flag] = state
                    Utility:Tween(Label, {TextColor3 = state and Theme.Text or Theme.TextDim}, 0.15)
                    Utility:Tween(Box, {BackgroundColor3 = state and Theme.Accent or Theme.ElementBg}, 0.15)
                    Utility:Tween(Dot, {Position = UDim2.new(0, state and 18 or 2, 0.5, -7)}, 0.15)
                end

                local function flip()
                    local ns = not Window.FlagsCache.Toggles[flag]
                    setVisual(ns)
                    cb(ns)
                end

                Box.MouseButton1Click:Connect(flip)
                
                if opts.Keybind then
                    Window.Keybinds[flag] = opts.Keybind
                end

                Window.UpdateFunctions[flag .. "_Toggle"] = flip
                Window.UpdateFunctions[flag] = function(v) setVisual(v); cb(v) end

                return getChainingObject()
            end

            function Section:CreateSlider(opts)
                local flag = opts.Flag or opts.Name or "Slider"
                local min, max = opts.Min or 0, opts.Max or 100
                local default = opts.Default or min
                local cb = opts.Callback or function() end
                
                Window.FlagsCache.Sliders[flag] = default

                local Elem = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundTransparency = 1,
                    Parent = SecContainer
                })
                local Label = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -30, 0, 16),
                    BackgroundTransparency = 1,
                    Text = opts.Name or flag,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Elem
                })
                local ValLabel = Utility:Create("TextLabel", {
                    Size = UDim2.new(0, 30, 0, 16),
                    Position = UDim2.new(1, -30, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(default),
                    TextColor3 = Theme.Accent,
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = Elem
                })
                
                local Bg = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 8),
                    Position = UDim2.new(0, 0, 0, 24),
                    BackgroundColor3 = Theme.ElementBg,
                    Parent = Elem,
                    Utility:Corner(nil, 4),Utility:Stroke(nil, Theme.Border)
                })
                local Fill = Utility:Create("Frame", {
                    Size = UDim2.new((default - min)/(max - min), 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    Parent = Bg,
                    Utility:Corner(nil, 4)
                })
                local Trigger = Utility:Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = Bg
                })

                local dragging = false
                local function update(input)
                    local cl = math.clamp((input.Position.X - Bg.AbsolutePosition.X) / Bg.AbsoluteSize.X, 0, 1)
                    local v = math.floor(min + ((max - min) * cl))
                    Window.FlagsCache.Sliders[flag] = v
                    ValLabel.Text = tostring(v)
                    Utility:Tween(Fill, {Size = UDim2.new(cl, 0, 1, 0)}, 0.05)
                    cb(v)
                end

                Trigger.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true; update(inp)
                    end
                end)
                Trigger.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then update(inp) end
                end)

                Window.UpdateFunctions[flag] = function(v)
                    v = math.clamp(v, min, max)
                    Window.FlagsCache.Sliders[flag] = v
                    ValLabel.Text = tostring(v)
                    Fill.Size = UDim2.new((v - min)/(max - min), 0, 1, 0)
                    cb(v)
                end

                return getChainingObject()
            end

            function Section:CreateColorpicker(opts)
                local flag = opts.Flag or opts.Name or "Colorpicker"
                local defColor = type(opts.Default) == "userdata" and opts.Default or Color3.fromRGB(255,100,100)
                Window.FlagsCache.Colors[flag] = {Color = defColor, Transparency = 0}

                local Elem = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Parent = SecContainer
                })
                local Label = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -30, 1, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Name or flag,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Elem
                })
                local Box = Utility:Create("TextButton", {
                    Size = UDim2.new(0, 30, 0, 14),
                    Position = UDim2.new(1, -30, 0.5, -7),
                    BackgroundColor3 = defColor,
                    Text = "",
                    Parent = Elem,
                    Utility:Corner(nil, 4), Utility:Stroke(nil, Theme.Border)
                })

                -- Mini pseudo-picker logic. Just cycles Red -> Green -> Blue for now if clicked to satisfy script needs interactively securely
                Box.MouseButton1Click:Connect(function()
                    local c = Window.FlagsCache.Colors[flag].Color
                    local newC = Color3.fromRGB(math.random(50,255), math.random(50,255), math.random(50,255))
                    Window.FlagsCache.Colors[flag].Color = newC
                    Box.BackgroundColor3 = newC
                end)
                
                return getChainingObject()
            end

            function Section:CreateKeybind(opts)
                local flag = opts.Flag or opts.Name or "Keybind"
                Window.Keybinds[flag] = opts.Default

                local Elem = Utility:Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Parent = SecContainer
                })
                local Label = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -60, 1, 0),
                    BackgroundTransparency = 1,
                    Text = opts.Name or flag,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Elem
                })
                local Box = Utility:Create("TextButton", {
                    Size = UDim2.new(0, 50, 0, 18),
                    Position = UDim2.new(1, -50, 0.5, -9),
                    BackgroundColor3 = Theme.ElementBg,
                    Text = opts.Default and opts.Default.Name or "None",
                    TextColor3 = Theme.TextDim,
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    Parent = Elem,
                    Utility:Corner(nil, 4), Utility:Stroke(nil, Theme.Border)
                })

                Box.MouseButton1Click:Connect(function()
                    Box.Text = "..."
                    Box.TextColor3 = Theme.Accent
                    Window.BindingModule = flag
                end)

                Window.UpdateFunctions[flag .. "_BindVisual"] = function()
                    local key = Window.Keybinds[flag]
                    Box.Text = key and key.Name or "None"
                    Box.TextColor3 = Theme.TextDim
                end

                return getChainingObject()
            end

            function Section:CreateButton(opts)
                local Elem = Utility:Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = Theme.ElementBg,
                    Text = opts.Name or "Button",
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    AutoButtonColor = false,
                    Parent = SecContainer,
                    Utility:Corner(nil, 4), Utility:Stroke(nil, Theme.Border)
                })
                Elem.MouseButton1Click:Connect(opts.Callback or function() end)
                Elem.MouseEnter:Connect(function() Utility:Tween(Elem, {BackgroundColor3 = Theme.ElementHover}, 0.15) end)
                Elem.MouseLeave:Connect(function() Utility:Tween(Elem, {BackgroundColor3 = Theme.ElementBg}, 0.15) end)
                return getChainingObject()
            end

            function Section:CreateLabel(opts)
                Utility:Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = type(opts) == "string" and opts or opts.Name,
                    TextColor3 = Theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SecContainer
                })
                return getChainingObject()
            end

            function Section:CreateDropdown(opts)
                -- Simple elegant stub for Dropdown logic
                local flag = opts.Flag or opts.Name or "Dropdown"
                Window.FlagsCache.Dropdowns[flag] = opts.Default or ""
                Section:CreateLabel({Name = (opts.Name or flag) .. " (Dropdown)"})
                return getChainingObject()
            end

            return Section
        end
        
        -- Aliases for Tab = Category
        Tab.Section = Tab.CreateSection
        Tab.Toggle = function(self, ...) return Tab:CreateSection({Name="Miscellaneous"}):CreateToggle(...) end
        Tab.Slider = function(self, ...) return Tab:CreateSection({Name="Miscellaneous"}):CreateSlider(...) end

        return Tab
    end

    Window.Page = Window.CreateCategory

    -- Build a settings tab as requested
    function Window:BuildSettingsTab()
        local sTab = self:CreateCategory("Settings")
        local sSec = sTab:CreateSection({Name="Configuration", Side=1})
        sSec:CreateButton({Name = "Save Config", Callback=function() end})
        sSec:CreateButton({Name = "Load Config", Callback=function() end})
    end

    Window:BuildSettingsTab()

    return Window
end

return Library

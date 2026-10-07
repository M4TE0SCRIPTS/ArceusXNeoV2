--[[
    ArceusXLibraryV2  v3.0  -  (móvil y PC)

    UI:  Window, Tab, Section, Label, Paragraph, Divider, Button, Toggle, Slider,
         Dropdown, TextBox, Keybind, ColorPicker, Dialog, Stats HUD, Perfil
    Extras: animaciones, notificaciones por tipo, borde RGB, botón UI RGB,
            configs (guardar/cargar/borrar), ArceusXLibrary.Utils (utilidades)
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local StatsService = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")

local ArceusXLibrary = {
    Version = "3.0",
    Flags = {},
    Windows = {},
    Utils = {},
    AutoNotify = false,        -- notificaciones automáticas en todos los elementos (opcional)
    Animations = true,         -- animaciones activadas
    NotifyPosition = "TopRight", -- TopRight / BottomRight / TopLeft / BottomLeft
    _connections = {},
    _theme = nil,
}

local Themes = {
    Dark = {
        Main = Color3.fromRGB(25, 25, 32), Top = Color3.fromRGB(32, 32, 42),
        Element = Color3.fromRGB(40, 40, 52), Accent = Color3.fromRGB(120, 90, 255),
        Text = Color3.fromRGB(240, 240, 245), SubText = Color3.fromRGB(160, 160, 175),
    },
    Light = {
        Main = Color3.fromRGB(235, 235, 240), Top = Color3.fromRGB(220, 220, 228),
        Element = Color3.fromRGB(250, 250, 253), Accent = Color3.fromRGB(90, 110, 255),
        Text = Color3.fromRGB(30, 30, 40), SubText = Color3.fromRGB(100, 100, 115),
    },
    Red = {
        Main = Color3.fromRGB(28, 22, 22), Top = Color3.fromRGB(38, 28, 28),
        Element = Color3.fromRGB(50, 36, 36), Accent = Color3.fromRGB(235, 70, 70),
        Text = Color3.fromRGB(245, 240, 240), SubText = Color3.fromRGB(175, 160, 160),
    },
}
ArceusXLibrary.Themes = Themes

local NotifyTypes = {
    Info = { Color = Color3.fromRGB(80, 150, 255), Icon = "i" },
    Success = { Color = Color3.fromRGB(60, 200, 110), Icon = "✓" },
    Warning = { Color = Color3.fromRGB(255, 180, 60), Icon = "!" },
    Error = { Color = Color3.fromRGB(235, 70, 70), Icon = "✕" },
}

local Rainbow = {
    Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 0, 255),
}

-- ========== Utilidades internas ==========
local function Make(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    inst.Parent = parent
    return inst
end

local function Round(inst, r)
    return Make("UICorner", { CornerRadius = UDim.new(0, r or 6) }, inst)
end

local function Pad(inst, p)
    return Make("UIPadding", {
        PaddingTop = UDim.new(0, p), PaddingBottom = UDim.new(0, p),
        PaddingLeft = UDim.new(0, p), PaddingRight = UDim.new(0, p),
    }, inst)
end

local function Tween(inst, props, t, style, dir)
    local d = ArceusXLibrary.Animations and (t or 0.15) or 0
    local tw = TweenService:Create(inst, TweenInfo.new(d, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function Connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(ArceusXLibrary._connections, c)
    return c
end

local function Safe(fn, ...)
    if typeof(fn) == "function" then
        local ok, err = pcall(fn, ...)
        if not ok then warn("[ArceusXLibraryV2] Error en callback: " .. tostring(err)) end
    end
end

local function GetParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local ok2 = pcall(function() return CoreGui.Name end)
    if ok2 then return CoreGui end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function IsPress(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end

local function IsMove(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
end

local function Draggable(handle, target)
    local dragging, startPos, startInput
    Connect(handle.InputBegan, function(input)
        if IsPress(input) then
            dragging, startInput, startPos = true, input.Position, target.Position
        end
    end)
    Connect(UIS.InputChanged, function(input)
        if dragging and IsMove(input) then
            local d = input.Position - startInput
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    Connect(UIS.InputEnded, function(input)
        if IsPress(input) then dragging = false end
    end)
end

-- Lista de colores -> ColorSequence cíclica
local function ToSequence(list)
    local n = #list
    if n == 0 then list, n = Rainbow, #Rainbow end
    if n == 1 then return ColorSequence.new(list[1]) end
    local kps = {}
    for i = 1, n do kps[i] = ColorSequenceKeypoint.new((i - 1) / n, list[i]) end
    kps[n + 1] = ColorSequenceKeypoint.new(1, list[1])
    return ColorSequence.new(kps)
end

-- Color en la posición t (0-1) de una lista, cíclico
local function SampleColors(list, t)
    local n = #list
    if n == 0 then list, n = Rainbow, #Rainbow end
    if n == 1 then return list[1] end
    local x = (t % 1) * n
    local i = math.floor(x)
    return list[i % n + 1]:Lerp(list[(i + 1) % n + 1], x - i)
end

-- ========== ArceusXLibrary.Utils (utilidades) ==========
local Utils = ArceusXLibrary.Utils
local LP = Players.LocalPlayer
Utils._loops = {}

-- FPS (se mide con un contador ligero)
local fpsCount, fpsLast, fpsValue = 0, os.clock(), 60
RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    local now = os.clock()
    if now - fpsLast >= 0.5 then
        fpsValue = fpsCount / (now - fpsLast)
        fpsCount, fpsLast = 0, now
    end
end)

function Utils.GetFPS() return math.floor(fpsValue + 0.5) end

function Utils.GetPing()
    local ok, v = pcall(function() return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue() end)
    return ok and math.floor(v + 0.5) or 0
end

function Utils.GetCharacter() return LP.Character end

function Utils.GetHumanoid()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

function Utils.GetRoot()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

function Utils.GetPlayerNames(includeSelf)
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if includeSelf or p ~= LP then table.insert(list, p.Name) end
    end
    table.sort(list)
    return list
end

-- Teleport a Vector3 | CFrame | BasePart | Player | nombre de jugador
function Utils.Teleport(target)
    local root = Utils.GetRoot()
    if not root then return false end
    if type(target) == "string" then target = Players:FindFirstChild(target) end
    local cf
    if typeof(target) == "CFrame" then
        cf = target
    elseif typeof(target) == "Vector3" then
        cf = CFrame.new(target)
    elseif typeof(target) == "Instance" then
        if target:IsA("BasePart") then
            cf = target.CFrame
        elseif target:IsA("Player") and target.Character then
            local r = target.Character:FindFirstChild("HumanoidRootPart")
            cf = r and r.CFrame
        end
    end
    if not cf then return false end
    root.CFrame = cf + Vector3.new(0, 3, 0)
    return true
end

function Utils.Copy(text)
    local f = setclipboard or toclipboard
    if f then return (pcall(f, tostring(text))) end
    return false
end

function Utils.Rejoin()
    if #Players:GetPlayers() <= 1 then
        LP:Kick("\nReconectando...")
        task.wait()
        TeleportService:Teleport(game.PlaceId, LP)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
    end
end

function Utils.ServerHop()
    local ok, data = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    if ok and data and data.data then
        for _, sv in ipairs(data.data) do
            if sv.id ~= game.JobId and sv.playing < sv.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, sv.id, LP)
                return true
            end
        end
    end
    return false
end

function Utils.AntiAFK(state)
    if state then
        if Utils._afk then return end
        Utils._afk = LP.Idled:Connect(function()
            local VU = game:GetService("VirtualUser")
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
    elseif Utils._afk then
        Utils._afk:Disconnect()
        Utils._afk = nil
    end
end

-- Bucles con nombre: Utils.Loop("nombre", segundos, función) / Utils.StopLoop("nombre")
function Utils.StopLoop(name)
    if Utils._loops[name] then
        Utils._loops[name]()
        Utils._loops[name] = nil
    end
end

function Utils.Loop(name, interval, fn)
    Utils.StopLoop(name)
    local alive = true
    Utils._loops[name] = function() alive = false end
    task.spawn(function()
        while alive do
            Safe(fn)
            task.wait(interval)
        end
    end)
end

function Utils.StopAllLoops()
    for name in pairs(Utils._loops) do Utils.StopLoop(name) end
end

function Utils.Debounce(fn, delay)
    local last
    return function(...)
        local args = table.pack(...)
        local token = {}
        last = token
        task.delay(delay, function()
            if last == token then fn(table.unpack(args, 1, args.n)) end
        end)
    end
end

function Utils.Throttle(fn, interval)
    local lastCall = 0
    return function(...)
        local now = os.clock()
        if now - lastCall >= interval then
            lastCall = now
            return fn(...)
        end
    end
end

function Utils.FormatNumber(n)
    local abs = math.abs(n)
    if abs >= 1e12 then return string.format("%.1fT", n / 1e12) end
    if abs >= 1e9 then return string.format("%.1fB", n / 1e9) end
    if abs >= 1e6 then return string.format("%.1fM", n / 1e6) end
    if abs >= 1e3 then return string.format("%.1fK", n / 1e3) end
    return tostring(math.floor(n))
end

function Utils.FormatTime(sec)
    sec = math.max(0, math.floor(sec))
    local h, m, s = math.floor(sec / 3600), math.floor(sec % 3600 / 60), sec % 60
    if h > 0 then return string.format("%d:%02d:%02d", h, m, s) end
    return string.format("%02d:%02d", m, s)
end

function Utils.RoundTo(n, decimals)
    local m = 10 ^ (decimals or 0)
    return math.floor(n * m + 0.5) / m
end

function Utils.RandomString(len)
    local chars, out = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", {}
    for i = 1, len or 8 do
        local r = math.random(1, #chars)
        out[i] = chars:sub(r, r)
    end
    return table.concat(out)
end

-- ========== Elementos (compartidos por Tab) ==========
local function AddElements(obj, container, theme)
    local function note(opts, title, content, ntype, duration)
        local enabled = opts.Notify
        if enabled == nil then enabled = ArceusXLibrary.AutoNotify end
        if enabled then
            ArceusXLibrary:Notify({
                Title = title, Content = content, Type = ntype or "Info",
                Theme = theme, Duration = duration or 2.5,
            })
        end
    end

    -- Métodos comunes de todo elemento: SetVisible / Destroy
    local function deco(api, frame)
        function api:SetVisible(v) frame.Visible = v and true or false end
        function api:Destroy() frame:Destroy() end
        return api
    end

    local function Row(height)
        local f = Make("Frame", {
            Size = UDim2.new(1, 0, 0, height or 36),
            BackgroundColor3 = theme.Element, BorderSizePixel = 0,
        }, container)
        Round(f, 8)
        local hover = theme.Element:Lerp(theme.Accent, 0.12)
        Connect(f.MouseEnter, function() Tween(f, { BackgroundColor3 = hover }, 0.12) end)
        Connect(f.MouseLeave, function() Tween(f, { BackgroundColor3 = theme.Element }, 0.15) end)
        return f
    end

    local function RowLabel(parent, text, width)
        return Make("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(width or 1, -12, 1, 0), Position = UDim2.new(0, 10, 0, 0),
            Text = text, TextColor3 = theme.Text,
            Font = Enum.Font.GothamMedium, TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        }, parent)
    end

    -- ---- Section / Label / Paragraph / Divider ----
    function obj:AddSection(text)
        local l = Make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
            Text = string.upper(text), TextColor3 = theme.Accent,
            Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        }, container)
        return deco({ SetText = function(_, t) l.Text = string.upper(t) end }, l)
    end

    function obj:AddLabel(text)
        local row = Row(30)
        local l = RowLabel(row, text)
        l.TextColor3 = theme.SubText
        return deco({ Set = function(_, t) l.Text = t end }, row)
    end

    function obj:AddParagraph(title, text)
        local row = Make("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = theme.Element, BorderSizePixel = 0,
        }, container)
        Round(row, 8)
        Pad(row, 10)
        Make("UIListLayout", { Padding = UDim.new(0, 4) }, row)
        local t = Make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = title or "",
            TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        local b = Make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, Text = text or "", TextColor3 = theme.SubText,
            Font = Enum.Font.Gotham, TextSize = 13, TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
        }, row)
        return deco({
            SetTitle = function(_, s) t.Text = s end,
            SetText = function(_, s) b.Text = s end,
        }, row)
    end

    function obj:AddDivider()
        local f = Make("Frame", { Size = UDim2.new(1, 0, 0, 8), BackgroundTransparency = 1 }, container)
        Make("Frame", {
            Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, 0.5, 0),
            BackgroundColor3 = theme.SubText, BackgroundTransparency = 0.7, BorderSizePixel = 0,
        }, f)
        return deco({}, f)
    end

    -- ---- Button ----
    function obj:AddButton(opts)
        opts = opts or {}
        local row = Row(36)
        local btn = Make("TextButton", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Text = opts.Name or "Button", TextColor3 = theme.Text,
            Font = Enum.Font.GothamMedium, TextSize = 14, AutoButtonColor = false,
        }, row)
        Connect(btn.MouseButton1Click, function()
            Tween(row, { BackgroundColor3 = theme.Accent }, 0.08)
            task.delay(0.12, function()
                if row.Parent then Tween(row, { BackgroundColor3 = theme.Element }, 0.25) end
            end)
            note(opts, opts.Name or "Botón", "Botón presionado")
            Safe(opts.Callback)
        end)
        return deco({ SetText = function(_, t) btn.Text = t end }, row)
    end

    -- ---- Toggle ----
    function obj:AddToggle(opts)
        opts = opts or {}
        local row = Row(36)
        RowLabel(row, opts.Name or "Toggle", 0.8)
        local box = Make("Frame", {
            Size = UDim2.new(0, 42, 0, 20), Position = UDim2.new(1, -52, 0.5, -10),
            BackgroundColor3 = Color3.fromRGB(70, 70, 85), BorderSizePixel = 0,
        }, row)
        Round(box, 10)
        local knob = Make("Frame", {
            Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
        }, box)
        Round(knob, 8)
        local click = Make("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }, row)

        local api = { Value = opts.Default or false }
        function api:Set(v, silent)
            self.Value = v and true or false
            Tween(box, { BackgroundColor3 = self.Value and theme.Accent or Color3.fromRGB(70, 70, 85) }, 0.2)
            Tween(knob, { Position = self.Value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) },
                0.25, Enum.EasingStyle.Back)
            if not silent then Safe(opts.Callback, self.Value) end
        end
        function api:Get() return self.Value end
        function api:Toggle() self:Set(not self.Value) end
        Connect(click.MouseButton1Click, function()
            api:Set(not api.Value)
            note(opts, opts.Name or "Toggle", api.Value and "Activado" or "Desactivado",
                api.Value and "Success" or "Info")
        end)
        api:Set(api.Value, true)
        if opts.Flag then ArceusXLibrary.Flags[opts.Flag] = api end
        if api.Value then Safe(opts.Callback, api.Value) end
        return deco(api, row)
    end

    -- ---- Slider ----
    function obj:AddSlider(opts)
        opts = opts or {}
        local min, max = opts.Min or 0, opts.Max or 100
        local inc = opts.Increment or 1
        local row = Row(50)
        local title = RowLabel(row, opts.Name or "Slider", 0.7)
        title.Size = UDim2.new(0.7, -12, 0, 26)
        local valLbl = Make("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.new(0.3, -10, 0, 26),
            Position = UDim2.new(0.7, 0, 0, 0), Text = "", TextColor3 = theme.SubText,
            Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right,
        }, row)
        local bar = Make("Frame", {
            Size = UDim2.new(1, -20, 0, 8), Position = UDim2.new(0, 10, 0, 33),
            BackgroundColor3 = Color3.fromRGB(70, 70, 85), BorderSizePixel = 0,
        }, row)
        Round(bar, 4)
        local fill = Make("Frame", {
            Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = theme.Accent, BorderSizePixel = 0,
        }, bar)
        Round(fill, 4)
        local knob = Make("Frame", {
            Size = UDim2.new(0, 14, 0, 14), AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
        }, bar)
        Round(knob, 7)

        local api = { Value = opts.Default or min }
        function api:Set(v, silent)
            v = math.clamp(math.floor(v / inc + 0.5) * inc, min, max)
            v = math.floor(v * 1000 + 0.5) / 1000
            self.Value = v
            local rel = (max - min) == 0 and 0 or (v - min) / (max - min)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, 0, 0.5, 0)
            valLbl.Text = tostring(v) .. (opts.Suffix or "")
            if not silent then Safe(opts.Callback, v) end
        end
        function api:Get() return self.Value end

        local dragging = false
        local function update(x)
            local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            api:Set(min + (max - min) * rel)
        end
        Connect(bar.InputBegan, function(i)
            if IsPress(i) then
                dragging = true
                Tween(knob, { Size = UDim2.new(0, 18, 0, 18) }, 0.12)
                update(i.Position.X)
            end
        end)
        Connect(UIS.InputChanged, function(i)
            if dragging and IsMove(i) then update(i.Position.X) end
        end)
        Connect(UIS.InputEnded, function(i)
            if IsPress(i) and dragging then
                dragging = false
                Tween(knob, { Size = UDim2.new(0, 14, 0, 14) }, 0.15)
                note(opts, opts.Name or "Slider", "Valor: " .. tostring(api.Value) .. (opts.Suffix or ""))
            end
        end)
        api:Set(api.Value, true)
        if opts.Flag then ArceusXLibrary.Flags[opts.Flag] = api end
        return deco(api, row)
    end

    -- ---- Dropdown ----
    function obj:AddDropdown(opts)
        opts = opts or {}
        local options = opts.Options or {}
        local holder = Make("Frame", {
            Size = UDim2.new(1, 0, 0, 36), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = theme.Element, BorderSizePixel = 0, ClipsDescendants = true,
        }, container)
        Round(holder, 8)
        Make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, holder)
        local head = Make("TextButton", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, Text = "" }, holder)
        local title = RowLabel(head, "", 0.9)
        local arrow = Make("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -30, 0, 0),
            Text = "v", TextColor3 = theme.SubText, Font = Enum.Font.GothamBold, TextSize = 14,
        }, head)
        local list = Make("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, Visible = false,
        }, holder)
        Make("UIListLayout", { Padding = UDim.new(0, 2) }, list)

        local api = { Value = opts.Default, Options = options }
        local function refreshTitle()
            title.Text = (opts.Name or "Dropdown") .. ": " .. tostring(api.Value or "-")
        end
        function api:Set(v, silent)
            self.Value = v
            refreshTitle()
            if not silent then Safe(opts.Callback, v) end
        end
        function api:Get() return self.Value end
        function api:Refresh(newOptions)
            for _, c in ipairs(list:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            self.Options = newOptions
            for _, name in ipairs(newOptions) do
                local b = Make("TextButton", {
                    Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = theme.Top, BorderSizePixel = 0,
                    Text = tostring(name), TextColor3 = theme.Text, Font = Enum.Font.Gotham,
                    TextSize = 13, AutoButtonColor = true,
                }, list)
                Connect(b.MouseButton1Click, function()
                    api:Set(name)
                    note(opts, opts.Name or "Dropdown", "Seleccionado: " .. tostring(name))
                    list.Visible = false
                    Tween(arrow, { Rotation = 0 }, 0.2)
                end)
            end
        end
        Connect(head.MouseButton1Click, function()
            list.Visible = not list.Visible
            Tween(arrow, { Rotation = list.Visible and 180 or 0 }, 0.2, Enum.EasingStyle.Back)
        end)
        api:Refresh(options)
        refreshTitle()
        if opts.Flag then ArceusXLibrary.Flags[opts.Flag] = api end
        return deco(api, holder)
    end

    -- ---- TextBox ----
    function obj:AddTextBox(opts)
        opts = opts or {}
        local row = Row(36)
        RowLabel(row, opts.Name or "TextBox", 0.5)
        local box = Make("TextBox", {
            Size = UDim2.new(0.5, -14, 0, 24), Position = UDim2.new(0.5, 4, 0.5, -12),
            BackgroundColor3 = theme.Top, BorderSizePixel = 0,
            Text = opts.Default or "", PlaceholderText = opts.Placeholder or "...",
            TextColor3 = theme.Text, PlaceholderColor3 = theme.SubText,
            Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false,
        }, row)
        Round(box, 6)
        local stroke = Make("UIStroke", { Color = theme.Accent, Thickness = 1.5, Transparency = 1 }, box)
        Connect(box.Focused, function() Tween(stroke, { Transparency = 0 }, 0.15) end)
        local api = { Value = box.Text }
        function api:Set(v, silent)
            box.Text = tostring(v)
            self.Value = box.Text
            if not silent then Safe(opts.Callback, self.Value) end
        end
        function api:Get() return self.Value end
        Connect(box.FocusLost, function()
            Tween(stroke, { Transparency = 1 }, 0.2)
            api.Value = box.Text
            note(opts, opts.Name or "TextBox", "Texto: " .. box.Text)
            Safe(opts.Callback, box.Text)
        end)
        if opts.Flag then ArceusXLibrary.Flags[opts.Flag] = api end
        return deco(api, row)
    end

    -- ---- Keybind ----
    function obj:AddKeybind(opts)
        opts = opts or {}
        local row = Row(36)
        RowLabel(row, opts.Name or "Keybind", 0.65)
        local btn = Make("TextButton", {
            Size = UDim2.new(0, 80, 0, 24), Position = UDim2.new(1, -90, 0.5, -12),
            BackgroundColor3 = theme.Top, BorderSizePixel = 0, TextColor3 = theme.Text,
            Font = Enum.Font.GothamMedium, TextSize = 12, Text = "",
        }, row)
        Round(btn, 6)
        local api = { Value = opts.Default or Enum.KeyCode.F }
        local listening = false
        function api:Set(key, silent)
            self.Value = key
            btn.Text = key.Name
            if not silent then Safe(opts.OnChange, key) end
        end
        function api:Get() return self.Value end
        Connect(btn.MouseButton1Click, function()
            listening = true
            btn.Text = "..."
            Tween(btn, { BackgroundColor3 = theme.Accent }, 0.15)
        end)
        Connect(UIS.InputBegan, function(input, gp)
            if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                Tween(btn, { BackgroundColor3 = theme.Top }, 0.2)
                api:Set(input.KeyCode)
                note(opts, opts.Name or "Keybind", "Tecla asignada: " .. input.KeyCode.Name)
            elseif not gp and not listening and input.KeyCode == api.Value then
                note(opts, opts.Name or "Keybind", "Atajo usado: " .. api.Value.Name, "Info", 1.5)
                Safe(opts.Callback, api.Value)
            end
        end)
        api:Set(api.Value, true)
        if opts.Flag then ArceusXLibrary.Flags[opts.Flag] = api end
        return deco(api, row)
    end

    -- ---- ColorPicker (H / S / V) ----
    function obj:AddColorPicker(opts)
        opts = opts or {}
        local holder = Make("Frame", {
            Size = UDim2.new(1, 0, 0, 36), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = theme.Element, BorderSizePixel = 0, ClipsDescendants = true,
        }, container)
        Round(holder, 8)
        Make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, holder)
        local head = Make("TextButton", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, Text = "" }, holder)
        RowLabel(head, opts.Name or "Color", 0.7)
        local preview = Make("Frame", {
            Size = UDim2.new(0, 34, 0, 20), Position = UDim2.new(1, -44, 0.5, -10), BorderSizePixel = 0,
        }, head)
        Round(preview, 6)
        Make("UIStroke", { Color = theme.SubText, Thickness = 1, Transparency = 0.5 }, preview)
        local panel = Make("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, Visible = false,
        }, holder)
        Pad(panel, 8)
        Make("UIListLayout", { Padding = UDim.new(0, 4) }, panel)

        local h, s, v = 0, 1, 1
        local api = { Value = opts.Default or Color3.fromRGB(255, 0, 0) }

        local function MiniBar(letter, onChange, rainbow)
            local row = Make("Frame", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1 }, panel)
            Make("TextLabel", {
                Size = UDim2.new(0, 16, 1, 0), BackgroundTransparency = 1, Text = letter,
                TextColor3 = theme.SubText, Font = Enum.Font.GothamBold, TextSize = 12,
            }, row)
            local bar = Make("Frame", {
                Size = UDim2.new(1, -34, 0, 10), Position = UDim2.new(0, 22, 0.5, -5),
                BackgroundColor3 = Color3.fromRGB(70, 70, 85), BorderSizePixel = 0,
            }, row)
            Round(bar, 5)
            if rainbow then Make("UIGradient", { Color = ToSequence(Rainbow) }, bar) end
            local knob = Make("Frame", {
                Size = UDim2.new(0, 14, 0, 14), AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
            }, bar)
            Round(knob, 7)
            Make("UIStroke", { Color = Color3.fromRGB(30, 30, 30), Thickness = 1 }, knob)
            local dragging = false
            local function upd(x)
                local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                knob.Position = UDim2.new(rel, 0, 0.5, 0)
                onChange(rel)
            end
            Connect(bar.InputBegan, function(i) if IsPress(i) then dragging = true upd(i.Position.X) end end)
            Connect(UIS.InputChanged, function(i) if dragging and IsMove(i) then upd(i.Position.X) end end)
            Connect(UIS.InputEnded, function(i) if IsPress(i) then dragging = false end end)
            return function(rel) knob.Position = UDim2.new(math.clamp(rel, 0, 1), 0, 0.5, 0) end
        end

        local function apply()
            local c = Color3.fromHSV(h, s, v)
            api.Value = c
            preview.BackgroundColor3 = c
            Safe(opts.Callback, c)
        end
        local setH = MiniBar("H", function(r) h = r apply() end, true)
        local setS = MiniBar("S", function(r) s = r apply() end)
        local setV = MiniBar("V", function(r) v = r apply() end)

        function api:Set(c, silent)
            self.Value = c
            preview.BackgroundColor3 = c
            h, s, v = c:ToHSV()
            setH(h) setS(s) setV(v)
            if not silent then Safe(opts.Callback, c) end
        end
        function api:Get() return self.Value end
        Connect(head.MouseButton1Click, function() panel.Visible = not panel.Visible end)
        api:Set(api.Value, true)
        if opts.Flag then ArceusXLibrary.Flags[opts.Flag] = api end
        return deco(api, holder)
    end
end

-- ========== Notificaciones (animadas, por tipo) ==========
function ArceusXLibrary:SetNotifyPosition(pos)
    self.NotifyPosition = pos or "TopRight"
    if self._notifGui then pcall(function() self._notifGui:Destroy() end) end
    self._notifGui, self._notifHolder = nil, nil
end

function ArceusXLibrary:Notify(opts)
    opts = opts or {}
    local theme = type(opts.Theme) == "table" and opts.Theme or Themes[opts.Theme or "Dark"] or Themes.Dark
    local pos = self.NotifyPosition or "TopRight"
    local right = string.find(pos, "Right") ~= nil
    local bottom = string.find(pos, "Bottom") ~= nil

    if not self._notifHolder or not self._notifHolder.Parent then
        local gui = Make("ScreenGui", { Name = "ArceusXV2_Notifs", ResetOnSpawn = false, DisplayOrder = 999 }, GetParent())
        local h = Make("Frame", {
            Size = UDim2.new(0, 270, 1, -20),
            Position = right and UDim2.new(1, -280, 0, 10) or UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
        }, gui)
        Make("UIListLayout", {
            Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = bottom and Enum.VerticalAlignment.Bottom or Enum.VerticalAlignment.Top,
        }, h)
        self._notifGui, self._notifHolder, self._notifCount = gui, h, 0
    end

    -- máximo 5 a la vez
    local active = {}
    for _, c in ipairs(self._notifHolder:GetChildren()) do
        if c:IsA("Frame") then table.insert(active, c) end
    end
    if #active >= 5 then active[1]:Destroy() end

    local style = NotifyTypes[opts.Type]
    local accent = style and style.Color or theme.Accent
    local icon = style and style.Icon or "i"
    local duration = opts.Duration or 4

    self._notifCount = (self._notifCount or 0) + 1
    local wrapper = Make("Frame", {
        Size = UDim2.new(1, 0, 0, 58), BackgroundTransparency = 1, LayoutOrder = self._notifCount,
    }, self._notifHolder)

    local card = Make("Frame", {
        Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(right and 1.25 or -1.25, 0, 0, 0),
        BackgroundColor3 = theme.Main, BorderSizePixel = 0,
    }, wrapper)
    Round(card, 10)
    Make("UIStroke", { Color = accent, Thickness = 1, Transparency = 0.45 }, card)

    local iconBg = Make("Frame", {
        Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 10, 0.5, -15),
        BackgroundColor3 = accent, BorderSizePixel = 0,
    }, card)
    Round(iconBg, 15)
    Make("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = icon,
        TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 16,
    }, iconBg)
    Make("TextLabel", {
        Size = UDim2.new(1, -62, 0, 18), Position = UDim2.new(0, 50, 0, 7),
        BackgroundTransparency = 1, Text = opts.Title or "Aviso", TextColor3 = accent,
        Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, card)
    Make("TextLabel", {
        Size = UDim2.new(1, -62, 0, 24), Position = UDim2.new(0, 50, 0, 25),
        BackgroundTransparency = 1, Text = opts.Content or "", TextColor3 = theme.Text,
        Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true,
    }, card)

    local bar = Make("Frame", {
        Size = UDim2.new(1, -20, 0, 3), Position = UDim2.new(0, 10, 1, -6),
        BackgroundColor3 = accent, BackgroundTransparency = 0.2, BorderSizePixel = 0,
    }, card)
    Round(bar, 2)

    local click = Make("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }, card)

    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        if not wrapper.Parent then return end
        Tween(card, { Position = UDim2.new(right and 1.25 or -1.25, 0, 0, 0) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.3)
        if not wrapper.Parent then return end
        Tween(wrapper, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
        task.wait(0.2)
        if wrapper.Parent then wrapper:Destroy() end
    end

    Tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.4, Enum.EasingStyle.Back)
    Tween(bar, { Size = UDim2.new(0, 0, 0, 3) }, duration, Enum.EasingStyle.Linear)
    click.MouseButton1Click:Connect(function() task.spawn(dismiss) end)
    task.delay(duration, function() task.spawn(dismiss) end)

    return { Dismiss = function() task.spawn(dismiss) end }
end

-- ========== Config ==========
local function Serialize(v)
    if typeof(v) == "EnumItem" then return { _enum = v.Name } end
    if typeof(v) == "Color3" then return { _color = { v.R, v.G, v.B } } end
    return v
end

local function Deserialize(v)
    if type(v) == "table" then
        if v._enum then return Enum.KeyCode[v._enum] end
        if v._color then return Color3.new(v._color[1], v._color[2], v._color[3]) end
    end
    return v
end

local function ConfigFile(name) return "ArceusXV2_" .. name .. ".json" end

function ArceusXLibrary:SaveConfig(name)
    if not writefile then return false end
    local data = {}
    for flag, api in pairs(self.Flags) do data[flag] = Serialize(api:Get()) end
    local ok = pcall(writefile, ConfigFile(name), HttpService:JSONEncode(data))
    if self.AutoNotify then
        self:Notify({
            Title = "Config", Content = ok and ("Guardada: " .. name) or "No se pudo guardar",
            Type = ok and "Success" or "Error", Theme = self._theme,
        })
    end
    return ok
end

function ArceusXLibrary:LoadConfig(name)
    local function fail()
        if self.AutoNotify then
            self:Notify({ Title = "Config", Content = "No se encontró: " .. name, Type = "Error", Theme = self._theme })
        end
        return false
    end
    if not (readfile and isfile) then return fail() end
    if not isfile(ConfigFile(name)) then return fail() end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile(name))) end)
    if not ok then return fail() end
    for flag, v in pairs(data) do
        local api = self.Flags[flag]
        if api then api:Set(Deserialize(v)) end
    end
    if self.AutoNotify then
        self:Notify({ Title = "Config", Content = "Cargada: " .. name, Type = "Success", Theme = self._theme })
    end
    return true
end

function ArceusXLibrary:DeleteConfig(name)
    if not (delfile and isfile) or not isfile(ConfigFile(name)) then return false end
    return (pcall(delfile, ConfigFile(name)))
end

function ArceusXLibrary:GetConfigs()
    local out = {}
    if not listfiles then return out end
    local ok, files = pcall(listfiles, "")
    if not ok then return out end
    for _, path in ipairs(files) do
        local n = string.match(path, "ArceusXV2_([^/\\]+)%.json$")
        if n then table.insert(out, n) end
    end
    table.sort(out)
    return out
end

-- ========== Ventana ==========
function ArceusXLibrary:CreateWindow(opts)
    opts = opts or {}
    self.Animations = opts.Animations ~= false
    self.AutoNotify = opts.AutoNotify == true
    if opts.NotifyPosition then self:SetNotifyPosition(opts.NotifyPosition) end

    local theme = {}
    for k, v in pairs(Themes[opts.Theme or "Dark"]) do theme[k] = v end
    for k, v in pairs(opts.CustomTheme or {}) do theme[k] = v end
    self._theme = theme

    local gui = Make("ScreenGui", {
        Name = "ArceusXLibraryV2", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, GetParent())

    local size = opts.Size or UDim2.new(0, 460, 0, 300)
    local sizeW, sizeH = size.X.Offset, size.Y.Offset
    local userScale = opts.Scale or 1
    local cr = opts.CornerRadius or 14

    local main = Make("Frame", {
        Size = size, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = theme.Main, BorderSizePixel = 0, ClipsDescendants = true,
    }, gui)
    Round(main, cr)
    local mainScale = Make("UIScale", { Scale = userScale }, main)

    -- Barra superior (redondeada arriba, recta abajo)
    local top = Make("Frame", {
        Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = theme.Top, BorderSizePixel = 0,
    }, main)
    Round(top, cr)
    local topFill = Make("Frame", {
        Size = UDim2.new(1, 0, 0, cr), Position = UDim2.new(0, 0, 1, -cr),
        BackgroundColor3 = theme.Top, BorderSizePixel = 0,
    }, top)
    local titleLabel = Make("TextLabel", {
        Size = UDim2.new(1, -90, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, Text = opts.Title or "ArceusX Library V2",
        TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, top)

    local function topBtn(text, offset)
        local b = Make("TextButton", {
            Size = UDim2.new(0, 28, 0, 24), Position = UDim2.new(1, offset, 0.5, -12),
            BackgroundColor3 = theme.Element, BorderSizePixel = 0, Text = text,
            TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = false,
        }, top)
        Round(b, 7)
        Connect(b.MouseEnter, function() Tween(b, { BackgroundColor3 = theme.Accent }, 0.12) end)
        Connect(b.MouseLeave, function() Tween(b, { BackgroundColor3 = theme.Element }, 0.15) end)
        return b
    end
    local minBtn, closeBtn = topBtn("-", -66), topBtn("X", -34)
    Draggable(top, main)

    -- Barra lateral (pestañas + perfil opcional)
    local profile = opts.Profile
    local hasProfile = profile ~= nil and profile ~= false
    local sbW = hasProfile and 130 or 110

    local sidebar = Make("Frame", {
        Size = UDim2.new(0, sbW, 1, -34), Position = UDim2.new(0, 0, 0, 34),
        BackgroundColor3 = theme.Top, BorderSizePixel = 0,
    }, main)
    Round(sidebar, cr)
    Make("Frame", { Size = UDim2.new(1, 0, 0, cr), BackgroundColor3 = theme.Top, BorderSizePixel = 0 }, sidebar)
    Make("Frame", {
        Size = UDim2.new(0, cr, 1, 0), Position = UDim2.new(1, -cr, 0, 0),
        BackgroundColor3 = theme.Top, BorderSizePixel = 0,
    }, sidebar)

    local tabBar = Make("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, hasProfile and -58 or 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
    }, sidebar)
    Pad(tabBar, 6)
    Make("UIListLayout", { Padding = UDim.new(0, 4) }, tabBar)

    if hasProfile then
        local info = type(profile) == "table" and profile or {}
        local userId = info.UserId or LP.UserId
        local dispName = info.Name or LP.DisplayName
        local sub = info.Subtitle
        if sub == nil and not info.UserId then sub = "@" .. LP.Name end

        local card = Make("Frame", {
            Size = UDim2.new(1, -12, 0, 46), Position = UDim2.new(0, 6, 1, -52),
            BackgroundColor3 = theme.Element, BorderSizePixel = 0,
        }, sidebar)
        Round(card, 10)
        local avatar = Make("ImageLabel", {
            Size = UDim2.new(0, 34, 0, 34), Position = UDim2.new(0, 6, 0.5, -17),
            BackgroundColor3 = theme.Main, BorderSizePixel = 0, ScaleType = Enum.ScaleType.Crop,
            Image = info.Image or ("rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=150&h=150"),
        }, card)
        Round(avatar, 17)
        Make("UIStroke", { Color = theme.Accent, Thickness = 1.5 }, avatar)
        Make("TextLabel", {
            Size = UDim2.new(1, -50, 0, 18), Position = UDim2.new(0, 46, 0, sub and 6 or 14),
            BackgroundTransparency = 1, Text = dispName, TextColor3 = theme.Text,
            Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, card)
        if sub then
            Make("TextLabel", {
                Size = UDim2.new(1, -50, 0, 14), Position = UDim2.new(0, 46, 0, 24),
                BackgroundTransparency = 1, Text = sub, TextColor3 = theme.SubText,
                Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, card)
        end
    end

    local pages = Make("Frame", {
        Size = UDim2.new(1, -sbW, 1, -34), Position = UDim2.new(0, sbW, 0, 34),
        BackgroundTransparency = 1, ClipsDescendants = true,
    }, main)

    -- Borde RGB opcional
    local stroke = Make("UIStroke", {
        Thickness = opts.BorderThickness or 2, Color = Color3.new(1, 1, 1),
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Enabled = false,
    }, main)
    local grad = Make("UIGradient", { Color = ToSequence(opts.RGBColors or Rainbow) }, stroke)
    local rgbOn = false
    local rgbSpeed = opts.RGBSpeed or 120

    -- Botón flotante "UI" (fijo, RGB y colores opcionales)
    local bo = opts.Button or {}
    local bSize = bo.Size or 44
    local bBase = bo.Color or theme.Accent
    local bColors = bo.Colors or Rainbow
    local float = Make("TextButton", {
        Size = UDim2.new(0, bSize, 0, bSize), Position = UDim2.new(0, 10, 0.5, -bSize / 2),
        BackgroundColor3 = bBase, Text = bo.Text or "UI", TextColor3 = bo.TextColor or Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold, TextSize = math.floor(bSize * 0.45), BorderSizePixel = 0,
        AutoButtonColor = false, Visible = bo.Visible ~= false,
    }, gui)
    Round(float, bSize / 2)
    local floatScale = Make("UIScale", { Scale = 1 }, float)
    local fStroke = Make("UIStroke", {
        Thickness = bo.BorderThickness or 2.5, Color = Color3.new(1, 1, 1),
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Enabled = false,
    }, float)
    local fGrad = Make("UIGradient", { Color = ToSequence(bColors) }, fStroke)
    local btnRGB, btnFill = false, false
    local btnSpeed = bo.Speed or 120
    local btnT = 0

    -- Stats HUD (FPS / Ping / hora)
    local statsOn = false
    local statsFrame = Make("Frame", {
        Size = UDim2.new(0, 0, 0, 26), AutomaticSize = Enum.AutomaticSize.X,
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, -40),
        BackgroundColor3 = theme.Main, BorderSizePixel = 0, Visible = false,
    }, gui)
    Round(statsFrame, 13)
    Make("UIStroke", { Color = theme.Accent, Thickness = 1, Transparency = 0.4 }, statsFrame)
    Make("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, statsFrame)
    local statsLabel = Make("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1,
        Text = "", TextColor3 = theme.Text, Font = Enum.Font.GothamMedium, TextSize = 12,
    }, statsFrame)
    local statsAcc = 0

    -- Un solo bucle de animación para borde, botón y stats
    Connect(RunService.RenderStepped, function(dt)
        if rgbOn then grad.Rotation = (grad.Rotation + dt * rgbSpeed) % 360 end
        if btnRGB or btnFill then
            btnT = (btnT + dt * btnSpeed / 360) % 1
            if btnRGB then fGrad.Rotation = btnT * 360 end
            if btnFill then float.BackgroundColor3 = SampleColors(bColors, btnT) end
        end
        if statsOn then
            statsAcc = statsAcc + dt
            if statsAcc >= 0.5 then
                statsAcc = 0
                statsLabel.Text = string.format("FPS %d   |   Ping %d ms   |   %s",
                    Utils.GetFPS(), Utils.GetPing(), os.date("%H:%M"))
            end
        end
    end)

    local window = { Gui = gui, Tabs = {}, _visible = true }
    local minimized = false
    local toggleKey = opts.ToggleKey

    -- ----- Mostrar / ocultar con animación -----
    function window:Toggle(state)
        if state == nil then state = not self._visible end
        if state == self._visible then return end
        self._visible = state
        if not ArceusXLibrary.Animations then
            main.Visible = state
            return
        end
        if state then
            main.Visible = true
            mainScale.Scale = userScale * 0.85
            Tween(mainScale, { Scale = userScale }, 0.35, Enum.EasingStyle.Back)
        else
            Tween(mainScale, { Scale = userScale * 0.85 }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.delay(0.2, function()
                if not window._visible then
                    main.Visible = false
                    mainScale.Scale = userScale
                end
            end)
        end
    end

    function window:Minimize(state)
        if state == nil then state = not minimized end
        minimized = state
        local newH = state and 34 or sizeH
        local curH = main.Size.Y.Offset
        Tween(main, {
            Size = UDim2.new(0, sizeW, 0, newH),
            Position = main.Position + UDim2.new(0, 0, 0, (newH - curH) / 2),
        }, 0.28, Enum.EasingStyle.Quint)
        if state then
            task.delay(0.28, function()
                if minimized then
                    sidebar.Visible, pages.Visible, topFill.Visible = false, false, false
                end
            end)
        else
            sidebar.Visible, pages.Visible, topFill.Visible = true, true, true
        end
    end

    function window:Destroy() gui:Destroy() end
    function window:SetTitle(t) titleLabel.Text = tostring(t) end
    function window:SetToggleKey(key) toggleKey = key end
    function window:SetScale(n)
        userScale = math.clamp(n, 0.5, 1.6)
        Tween(mainScale, { Scale = userScale }, 0.2)
    end

    function window:SetRGBBorder(state)
        rgbOn = state and true or false
        stroke.Enabled = rgbOn
    end
    function window:SetRGBSpeed(n) rgbSpeed = n end
    function window:SetBorderColors(list) grad.Color = ToSequence(list or Rainbow) end

    function window:SetButtonRGB(state)
        btnRGB = state and true or false
        fStroke.Enabled = btnRGB
    end
    function window:SetButtonFill(state)
        btnFill = state and true or false
        if not btnFill then Tween(float, { BackgroundColor3 = bBase }, 0.2) end
    end
    function window:SetButtonColor(color)
        bBase = color
        if not btnFill then Tween(float, { BackgroundColor3 = color }, 0.2) end
    end
    function window:SetButtonColors(list)
        bColors = (list and #list > 0) and list or Rainbow
        fGrad.Color = ToSequence(bColors)
    end
    function window:SetButtonSpeed(n) btnSpeed = n end
    function window:SetButtonText(text) float.Text = tostring(text) end
    function window:SetButtonVisible(state) float.Visible = state and true or false end

    function window:SetStats(state)
        statsOn = state and true or false
        if statsOn then
            statsLabel.Text = string.format("FPS %d   |   Ping %d ms   |   %s",
                Utils.GetFPS(), Utils.GetPing(), os.date("%H:%M"))
            statsFrame.Visible = true
            Tween(statsFrame, { Position = UDim2.new(0.5, 0, 0, 8) }, 0.4, Enum.EasingStyle.Back)
        else
            Tween(statsFrame, { Position = UDim2.new(0.5, 0, 0, -40) }, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.delay(0.25, function() if not statsOn then statsFrame.Visible = false end end)
        end
    end

    -- ----- Diálogo animado: Window:Dialog({Title, Content, Buttons = {{Text, Callback}}}) -----
    function window:Dialog(d)
        d = d or {}
        local overlay = Make("TextButton", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 100,
        }, main)
        Round(overlay, cr)
        local panel = Make("Frame", {
            Size = UDim2.new(0, 260, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundColor3 = theme.Element, BorderSizePixel = 0,
        }, overlay)
        Round(panel, 12)
        Make("UIStroke", { Color = theme.Accent, Thickness = 1, Transparency = 0.4 }, panel)
        Pad(panel, 12)
        Make("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, panel)
        local pScale = Make("UIScale", { Scale = 0.8 }, panel)

        Make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = d.Title or "Aviso",
            TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1,
        }, panel)
        Make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
            Text = d.Content or "", TextColor3 = theme.SubText, Font = Enum.Font.Gotham, TextSize = 13,
            TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = 2,
        }, panel)
        local btnRow = Make("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, LayoutOrder = 3 }, panel)
        Make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, btnRow)

        local closed = false
        local function close()
            if closed then return end
            closed = true
            Tween(overlay, { BackgroundTransparency = 1 }, 0.2)
            Tween(pScale, { Scale = 0.8 }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.delay(0.22, function() overlay:Destroy() end)
        end

        local buttons = d.Buttons or { { Text = "OK" } }
        local n = #buttons
        for i, b in ipairs(buttons) do
            local btn = Make("TextButton", {
                Size = UDim2.new(1 / n, -(8 * (n - 1)) / n, 1, 0), LayoutOrder = i,
                BackgroundColor3 = i == 1 and theme.Accent or theme.Top, BorderSizePixel = 0,
                Text = b.Text or "OK", TextColor3 = i == 1 and Color3.new(1, 1, 1) or theme.Text,
                Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = true,
            }, btnRow)
            Round(btn, 8)
            btn.MouseButton1Click:Connect(function()
                close()
                Safe(b.Callback)
            end)
        end

        Tween(overlay, { BackgroundTransparency = 0.45 }, 0.2)
        Tween(pScale, { Scale = 1 }, 0.3, Enum.EasingStyle.Back)
        return { Close = close }
    end

    -- ----- Eventos de la ventana -----
    Connect(float.MouseButton1Click, function()
        floatScale.Scale = 0.85
        Tween(floatScale, { Scale = 1 }, 0.3, Enum.EasingStyle.Back)
        window:Toggle()
    end)
    Connect(closeBtn.MouseButton1Click, function() window:Toggle(false) end)
    Connect(minBtn.MouseButton1Click, function() window:Minimize() end)
    Connect(UIS.InputBegan, function(i, gp)
        if not gp and toggleKey and i.KeyCode == toggleKey then window:Toggle() end
    end)

    -- ----- Pestañas -----
    function window:AddTab(name)
        local btn = Make("TextButton", {
            Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = theme.Element,
            BorderSizePixel = 0, Text = name, TextColor3 = theme.SubText,
            Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false,
        }, tabBar)
        Round(btn, 8)

        local page = Make("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 3, ScrollBarImageColor3 = theme.Accent, Visible = false,
            AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
        }, pages)
        Pad(page, 8)
        Make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, page)

        local tab = { Name = name }
        AddElements(tab, page, theme)

        local function select()
            for _, t in ipairs(window.Tabs) do
                t._page.Visible = false
                Tween(t._btn, { BackgroundColor3 = theme.Element }, 0.2)
                t._btn.TextColor3 = theme.SubText
            end
            page.Visible = true
            page.Position = UDim2.new(0, 0, 0, 16)
            Tween(page, { Position = UDim2.new(0, 0, 0, 0) }, 0.3, Enum.EasingStyle.Quint)
            Tween(btn, { BackgroundColor3 = theme.Accent }, 0.2)
            btn.TextColor3 = Color3.new(1, 1, 1)
            window.CurrentTab = tab
        end
        tab._page, tab._btn, tab._select = page, btn, select
        function tab:Select() select() end
        Connect(btn.MouseButton1Click, select)
        table.insert(window.Tabs, tab)
        if #window.Tabs == 1 then select() end
        return tab
    end

    function window:Select(name)
        for _, t in ipairs(self.Tabs) do
            if t.Name == name then t._select() return true end
        end
        return false
    end

    -- ----- Opciones iniciales + animación de entrada -----
    window:SetRGBBorder(opts.RGBBorder == true)
    window:SetButtonRGB(bo.RGB == true)
    window:SetButtonFill(bo.Fill == true)
    if opts.Stats then window:SetStats(true) end

    if ArceusXLibrary.Animations then
        mainScale.Scale = userScale * 0.8
        Tween(mainScale, { Scale = userScale }, 0.5, Enum.EasingStyle.Back)
        floatScale.Scale = 0
        Tween(floatScale, { Scale = 1 }, 0.5, Enum.EasingStyle.Back)
    end

    table.insert(ArceusXLibrary.Windows, window)
    return window
end

function ArceusXLibrary:Destroy()
    Utils.StopAllLoops()
    Utils.AntiAFK(false)
    for _, c in ipairs(self._connections) do pcall(function() c:Disconnect() end) end
    for _, w in ipairs(self.Windows) do pcall(function() w:Destroy() end) end
    if self._notifGui then pcall(function() self._notifGui:Destroy() end) end
    self.Windows, self._connections, self.Flags = {}, {}, {}
    self._notifGui, self._notifHolder = nil, nil
end

return ArceusXLibrary

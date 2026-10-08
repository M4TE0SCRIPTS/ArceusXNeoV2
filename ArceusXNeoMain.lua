--[[
    ArceusXLibraryV2  v4.0  -  Librería de UI para Roblox (móvil y PC)

    Elementos: Section, Label, Paragraph, Divider, Button, Toggle, Slider, Dropdown,
               TextBox, Keybind, ColorPicker  (+ búsqueda opcional por pestaña)
    Ventana:   Subtitle, Icon, Version, Watermark, Position, Resizable, Draggable,
               Transparency, Blur, TabPosition (Left/Top), iconos de pestañas, Font,
               TextScale, Sounds, Language, StartMinimized, StartHidden, Stats,
               LoadingScreen, WelcomeMessage, AutoSave/AutoLoad, ConfirmClose, Perfil,
               borde RGB, botón UI RGB, AllowedPlaces/AllowedUsers/BlockedUsers
    KeySystem: integrado en CreateWindow (KeySystem = true, KeySettings = {...}) con nota,
               botón Copy, varios links, expiración de keys, bloqueo temporal, kick y key guardada
    Extras:    notificaciones por tipo, diálogos, configs, ArceusXLibrary.Utils
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local StatsService = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")

local ArceusXLibrary = {
    Version = "4.1",
    Flags = {},
    Windows = {},
    Utils = {},
    AutoNotify = false,          -- notificaciones automáticas en todos los elementos (opcional)
    Animations = true,           -- animaciones activadas
    NotifyPosition = "TopRight", -- TopRight / BottomRight / TopLeft / BottomLeft
    Language = "ES",             -- ES / EN
    Sounds = {
        Enabled = false, Volume = 0.5,
        Click = "rbxasset://sounds/clickfast.wav",
        Notify = "rbxasset://sounds/electronicpingshort.wav",
    },
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

-- ========== Idiomas ==========
local Strings = {
    ES = {
        notice = "Aviso", ok = "OK", cancel = "Cancelar", close = "Cerrar",
        button = "Botón", pressed = "Botón presionado", on = "Activado", off = "Desactivado",
        value = "Valor: ", selected = "Seleccionado: ", text = "Texto: ",
        keyset = "Tecla asignada: ", keyused = "Atajo usado: ",
        close_title = "Cerrar menú",
        close_hide = "¿Seguro que quieres cerrar el menú? Podrás abrirlo de nuevo con el botón flotante.",
        close_destroy = "¿Seguro que quieres cerrar y descargar el menú?",
        cfg = "Config", cfg_saved = "Guardada: ", cfg_save_fail = "No se pudo guardar",
        cfg_missing = "No se encontró: ", cfg_loaded = "Cargada: ",
        search = "Buscar...", welcome = "Bienvenido, ",
        denied = "Acceso denegado", deny_place = "Este script no funciona en este juego",
        deny_user = "No tienes permiso para usar este script", deny_blocked = "Tu usuario está bloqueado",
        loading = "Cargando...",
        loading_steps = { "Cargando módulos...", "Preparando interfaz...", "Aplicando ajustes...", "Listo" },
        key_title = "Key System", key_note = "NOTA", key_placeholder = "Pega tu key aquí...",
        key_verify = "Verificar", key_getkey = "Obtener key", key_empty = "Escribe tu key primero",
        key_checking = "Verificando...", key_ok = "Key correcta", key_bad = "Key incorrecta",
        key_saved_valid = "Key guardada válida", key_granted = "Acceso concedido",
        key_invalid = "La key no es válida", key_too_many = "Demasiados intentos",
        key_copied = "Copiado al portapapeles", key_copied_short = "Copiado", key_copy = "Copiar",
        key_expired = "Tu key expiró", key_locked = "Bloqueado: %ds",
        key_kick = "Demasiados intentos con una key incorrecta",
    },
    EN = {
        notice = "Notice", ok = "OK", cancel = "Cancel", close = "Close",
        button = "Button", pressed = "Button pressed", on = "Enabled", off = "Disabled",
        value = "Value: ", selected = "Selected: ", text = "Text: ",
        keyset = "Key set: ", keyused = "Shortcut used: ",
        close_title = "Close menu",
        close_hide = "Are you sure you want to close the menu? You can reopen it with the floating button.",
        close_destroy = "Are you sure you want to close and unload the menu?",
        cfg = "Config", cfg_saved = "Saved: ", cfg_save_fail = "Could not save",
        cfg_missing = "Not found: ", cfg_loaded = "Loaded: ",
        search = "Search...", welcome = "Welcome, ",
        denied = "Access denied", deny_place = "This script does not work in this game",
        deny_user = "You are not allowed to use this script", deny_blocked = "Your user is blocked",
        loading = "Loading...",
        loading_steps = { "Loading modules...", "Preparing interface...", "Applying settings...", "Done" },
        key_title = "Key System", key_note = "NOTE", key_placeholder = "Paste your key here...",
        key_verify = "Verify", key_getkey = "Get key", key_empty = "Enter your key first",
        key_checking = "Checking...", key_ok = "Correct key", key_bad = "Wrong key",
        key_saved_valid = "Saved key is valid", key_granted = "Access granted",
        key_invalid = "The key is not valid", key_too_many = "Too many attempts",
        key_copied = "Copied to clipboard", key_copied_short = "Copied", key_copy = "Copy",
        key_expired = "Your key expired", key_locked = "Locked: %ds",
        key_kick = "Too many attempts with a wrong key",
    },
}

local function L(key)
    local t = Strings[ArceusXLibrary.Language] or Strings.ES
    local v = t[key]
    if v == nil then v = Strings.ES[key] end
    return v ~= nil and v or key
end

-- ========== Fuentes y tamaño de texto ==========
local function FontByName(name)
    local ok, v = pcall(function() return Enum.Font[name] end)
    return ok and v or Enum.Font.Gotham
end

local FontFamilies = {
    Gotham = { Enum.Font.Gotham, Enum.Font.GothamMedium, Enum.Font.GothamBold },
    SourceSans = { Enum.Font.SourceSans, Enum.Font.SourceSansSemibold, Enum.Font.SourceSansBold },
    Arial = { Enum.Font.Arial, Enum.Font.Arial, Enum.Font.ArialBold },
    Ubuntu = { FontByName("Ubuntu"), FontByName("Ubuntu"), FontByName("Ubuntu") },
    Code = { Enum.Font.Code, Enum.Font.Code, Enum.Font.Code },
    Nunito = { FontByName("Nunito"), FontByName("Nunito"), FontByName("Nunito") },
    Montserrat = { FontByName("Montserrat"), FontByName("Montserrat"), FontByName("Montserrat") },
    Fredoka = { FontByName("FredokaOne"), FontByName("FredokaOne"), FontByName("FredokaOne") },
}

local Fonts = { Regular = Enum.Font.Gotham, Medium = Enum.Font.GothamMedium, Bold = Enum.Font.GothamBold }
local TextScale = 1
local function TS(n) return math.max(8, math.floor(n * TextScale + 0.5)) end

local function ApplyStyle(opts)
    if opts.Language then ArceusXLibrary.Language = string.upper(tostring(opts.Language)) end
    if opts.Font ~= nil then
        local fam = type(opts.Font) == "string" and FontFamilies[opts.Font] or nil
        if fam then
            Fonts.Regular, Fonts.Medium, Fonts.Bold = fam[1], fam[2], fam[3]
        elseif typeof(opts.Font) == "EnumItem" then
            Fonts.Regular, Fonts.Medium, Fonts.Bold = opts.Font, opts.Font, opts.Font
        end
    end
    if opts.TextScale then TextScale = math.clamp(opts.TextScale, 0.7, 1.4) end
end

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

-- Sonidos de interfaz (opcional)
local function PlaySfx(kind)
    local S = ArceusXLibrary.Sounds
    if not S.Enabled or not S[kind] then return end
    pcall(function()
        local snd = Instance.new("Sound")
        snd.SoundId = S[kind]
        snd.Volume = S.Volume or 0.5
        snd.Parent = SoundService
        snd:Play()
        task.delay(3, function() snd:Destroy() end)
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

local function Trim(str)
    return (tostring(str):gsub("^%s+", ""):gsub("%s+$", ""))
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
    local registry = {}
    local query = ""

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

    -- Búsqueda: registra cada elemento con su nombre
    local function matches(entry)
        if query == "" then return true end
        if entry.header then return false end
        return string.find(entry.name, query, 1, true) ~= nil
    end
    local function refresh(entry)
        if entry.frame.Parent then entry.frame.Visible = (not entry.hidden) and matches(entry) end
    end
    function obj:_Filter(q)
        query = string.lower(q or "")
        for _, e in ipairs(registry) do refresh(e) end
    end

    -- Métodos comunes de todo elemento: SetVisible / Destroy
    local function deco(api, frame, name, header)
        local entry = { frame = frame, name = string.lower(tostring(name or "")), header = header, hidden = false }
        table.insert(registry, entry)
        function api:SetVisible(v)
            entry.hidden = not v
            refresh(entry)
        end
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
            Font = Fonts.Medium, TextSize = TS(14),
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        }, parent)
    end

    -- ---- Section / Label / Paragraph / Divider ----
    function obj:AddSection(text)
        local l = Make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
            Text = string.upper(text), TextColor3 = theme.Accent,
            Font = Fonts.Bold, TextSize = TS(12), TextXAlignment = Enum.TextXAlignment.Left,
        }, container)
        return deco({ SetText = function(_, t) l.Text = string.upper(t) end }, l, text, true)
    end

    function obj:AddLabel(text)
        local row = Row(30)
        local l = RowLabel(row, text)
        l.TextColor3 = theme.SubText
        return deco({ Set = function(_, t) l.Text = t end }, row, text)
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
            TextColor3 = theme.Text, Font = Fonts.Bold, TextSize = TS(14),
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        local b = Make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, Text = text or "", TextColor3 = theme.SubText,
            Font = Fonts.Regular, TextSize = TS(13), TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
        }, row)
        return deco({
            SetTitle = function(_, s) t.Text = s end,
            SetText = function(_, s) b.Text = s end,
        }, row, (title or "") .. " " .. (text or ""))
    end

    function obj:AddDivider()
        local f = Make("Frame", { Size = UDim2.new(1, 0, 0, 8), BackgroundTransparency = 1 }, container)
        Make("Frame", {
            Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, 0.5, 0),
            BackgroundColor3 = theme.SubText, BackgroundTransparency = 0.7, BorderSizePixel = 0,
        }, f)
        return deco({}, f, "", true)
    end

    -- ---- Button ----
    function obj:AddButton(opts)
        opts = opts or {}
        local row = Row(36)
        local btn = Make("TextButton", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            Text = opts.Name or "Button", TextColor3 = theme.Text,
            Font = Fonts.Medium, TextSize = TS(14), AutoButtonColor = false,
        }, row)
        Connect(btn.MouseButton1Click, function()
            PlaySfx("Click")
            Tween(row, { BackgroundColor3 = theme.Accent }, 0.08)
            task.delay(0.12, function()
                if row.Parent then Tween(row, { BackgroundColor3 = theme.Element }, 0.25) end
            end)
            note(opts, opts.Name or L("button"), L("pressed"))
            Safe(opts.Callback)
        end)
        return deco({ SetText = function(_, t) btn.Text = t end }, row, opts.Name)
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
            PlaySfx("Click")
            api:Set(not api.Value)
            note(opts, opts.Name or "Toggle", api.Value and L("on") or L("off"),
                api.Value and "Success" or "Info")
        end)
        api:Set(api.Value, true)
        if opts.Flag then ArceusXLibrary.Flags[opts.Flag] = api end
        if api.Value then Safe(opts.Callback, api.Value) end
        return deco(api, row, opts.Name)
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
            Font = Fonts.Regular, TextSize = TS(13), TextXAlignment = Enum.TextXAlignment.Right,
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
                note(opts, opts.Name or "Slider", L("value") .. tostring(api.Value) .. (opts.Suffix or ""))
            end
        end)
        api:Set(api.Value, true)
        if opts.Flag then ArceusXLibrary.Flags[opts.Flag] = api end
        return deco(api, row, opts.Name)
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
            Text = "v", TextColor3 = theme.SubText, Font = Fonts.Bold, TextSize = TS(14),
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
                    Text = tostring(name), TextColor3 = theme.Text, Font = Fonts.Regular,
                    TextSize = TS(13), AutoButtonColor = true,
                }, list)
                Connect(b.MouseButton1Click, function()
                    PlaySfx("Click")
                    api:Set(name)
                    note(opts, opts.Name or "Dropdown", L("selected") .. tostring(name))
                    list.Visible = false
                    Tween(arrow, { Rotation = 0 }, 0.2)
                end)
            end
        end
        Connect(head.MouseButton1Click, function()
            PlaySfx("Click")
            list.Visible = not list.Visible
            Tween(arrow, { Rotation = list.Visible and 180 or 0 }, 0.2, Enum.EasingStyle.Back)
        end)
        api:Refresh(options)
        refreshTitle()
        if opts.Flag then ArceusXLibrary.Flags[opts.Flag] = api end
        return deco(api, holder, opts.Name)
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
            Font = Fonts.Regular, TextSize = TS(13), ClearTextOnFocus = false,
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
            note(opts, opts.Name or "TextBox", L("text") .. box.Text)
            Safe(opts.Callback, box.Text)
        end)
        if opts.Flag then ArceusXLibrary.Flags[opts.Flag] = api end
        return deco(api, row, opts.Name)
    end

    -- ---- Keybind ----
    function obj:AddKeybind(opts)
        opts = opts or {}
        local row = Row(36)
        RowLabel(row, opts.Name or "Keybind", 0.65)
        local btn = Make("TextButton", {
            Size = UDim2.new(0, 80, 0, 24), Position = UDim2.new(1, -90, 0.5, -12),
            BackgroundColor3 = theme.Top, BorderSizePixel = 0, TextColor3 = theme.Text,
            Font = Fonts.Medium, TextSize = TS(12), Text = "",
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
            PlaySfx("Click")
            listening = true
            btn.Text = "..."
            Tween(btn, { BackgroundColor3 = theme.Accent }, 0.15)
        end)
        Connect(UIS.InputBegan, function(input, gp)
            if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                Tween(btn, { BackgroundColor3 = theme.Top }, 0.2)
                api:Set(input.KeyCode)
                note(opts, opts.Name or "Keybind", L("keyset") .. input.KeyCode.Name)
            elseif not gp and not listening and input.KeyCode == api.Value then
                note(opts, opts.Name or "Keybind", L("keyused") .. api.Value.Name, "Info", 1.5)
                Safe(opts.Callback, api.Value)
            end
        end)
        api:Set(api.Value, true)
        if opts.Flag then ArceusXLibrary.Flags[opts.Flag] = api end
        return deco(api, row, opts.Name)
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
                TextColor3 = theme.SubText, Font = Fonts.Bold, TextSize = TS(12),
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
        Connect(head.MouseButton1Click, function()
            PlaySfx("Click")
            panel.Visible = not panel.Visible
        end)
        api:Set(api.Value, true)
        if opts.Flag then ArceusXLibrary.Flags[opts.Flag] = api end
        return deco(api, holder, opts.Name)
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

    PlaySfx("Notify")

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
        TextColor3 = Color3.new(1, 1, 1), Font = Fonts.Bold, TextSize = TS(16),
    }, iconBg)
    Make("TextLabel", {
        Size = UDim2.new(1, -62, 0, 18), Position = UDim2.new(0, 50, 0, 7),
        BackgroundTransparency = 1, Text = opts.Title or L("notice"), TextColor3 = accent,
        Font = Fonts.Bold, TextSize = TS(14), TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, card)
    Make("TextLabel", {
        Size = UDim2.new(1, -62, 0, 24), Position = UDim2.new(0, 50, 0, 25),
        BackgroundTransparency = 1, Text = opts.Content or "", TextColor3 = theme.Text,
        Font = Fonts.Regular, TextSize = TS(12), TextXAlignment = Enum.TextXAlignment.Left,
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

-- Texto estable de todos los flags (para detectar cambios en AutoSave)
function ArceusXLibrary:_Snapshot()
    local keys = {}
    for flag in pairs(self.Flags) do table.insert(keys, flag) end
    table.sort(keys)
    local parts = {}
    for _, flag in ipairs(keys) do
        local ok, enc = pcall(function() return HttpService:JSONEncode({ Serialize(self.Flags[flag]:Get()) }) end)
        table.insert(parts, flag .. "=" .. (ok and enc or "?"))
    end
    return table.concat(parts, "|")
end

function ArceusXLibrary:SaveConfig(name, silent)
    if not writefile then return false end
    local data = {}
    for flag, api in pairs(self.Flags) do data[flag] = Serialize(api:Get()) end
    local ok = pcall(writefile, ConfigFile(name), HttpService:JSONEncode(data))
    if self.AutoNotify and not silent then
        self:Notify({
            Title = L("cfg"), Content = ok and (L("cfg_saved") .. name) or L("cfg_save_fail"),
            Type = ok and "Success" or "Error", Theme = self._theme,
        })
    end
    return ok
end

function ArceusXLibrary:LoadConfig(name, silent)
    local function fail()
        if self.AutoNotify and not silent then
            self:Notify({ Title = L("cfg"), Content = L("cfg_missing") .. name, Type = "Error", Theme = self._theme })
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
    if self.AutoNotify and not silent then
        self:Notify({ Title = L("cfg"), Content = L("cfg_loaded") .. name, Type = "Success", Theme = self._theme })
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

-- ========== Restricciones de acceso ==========
local function CheckAccess(opts)
    if type(opts.AllowedPlaces) == "table" and #opts.AllowedPlaces > 0 then
        local ok = false
        for _, id in ipairs(opts.AllowedPlaces) do
            if id == game.PlaceId or id == game.GameId then ok = true break end
        end
        if not ok then return false, L("deny_place") end
    end
    local function listed(list)
        for _, v in ipairs(list or {}) do
            if type(v) == "number" and v == LP.UserId then return true end
            if type(v) == "string" then
                local lv = string.lower(v)
                if lv == string.lower(LP.Name) or lv == string.lower(LP.DisplayName) or v == tostring(LP.UserId) then
                    return true
                end
            end
        end
        return false
    end
    if type(opts.BlockedUsers) == "table" and listed(opts.BlockedUsers) then
        return false, L("deny_blocked")
    end
    if type(opts.AllowedUsers) == "table" and #opts.AllowedUsers > 0 and not listed(opts.AllowedUsers) then
        return false, L("deny_user")
    end
    return true
end

-- ========== Pantalla de carga ==========
function ArceusXLibrary:LoadingScreen(opts)
    opts = opts or {}
    ApplyStyle(opts)
    local theme = {}
    for k, v in pairs(Themes[opts.Theme or "Dark"]) do theme[k] = v end
    for k, v in pairs(opts.CustomTheme or {}) do theme[k] = v end
    local cr = opts.CornerRadius or 14
    local duration = opts.Duration or 2.5
    local steps = opts.Steps or L("loading_steps")
    if type(steps) ~= "table" or #steps == 0 then steps = { L("loading") } end

    local gui = Make("ScreenGui", {
        Name = "ArceusXV2_Loading", ResetOnSpawn = false, DisplayOrder = 600,
        IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, GetParent())
    local backdrop = Make("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, gui)
    local panel = Make("Frame", {
        Size = UDim2.new(0, 280, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = theme.Main, BorderSizePixel = 0,
    }, backdrop)
    Round(panel, cr)
    Pad(panel, 16)
    Make("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, panel)
    local pScale = Make("UIScale", { Scale = 1 }, panel)

    local stroke = Make("UIStroke", {
        Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = opts.RGBBorder and Color3.new(1, 1, 1) or theme.Accent,
        Transparency = opts.RGBBorder and 0 or 0.5,
    }, panel)
    local grad, rgbConn
    if opts.RGBBorder then
        grad = Make("UIGradient", { Color = ToSequence(opts.RGBColors or Rainbow) }, stroke)
        rgbConn = RunService.RenderStepped:Connect(function(dt)
            grad.Rotation = (grad.Rotation + dt * (opts.RGBSpeed or 120)) % 360
        end)
    end

    Make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = opts.Title or "ArceusX",
        TextColor3 = theme.Text, Font = Fonts.Bold, TextSize = TS(18),
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = 1,
    }, panel)
    Make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = opts.Subtitle or L("loading"),
        TextColor3 = theme.SubText, Font = Fonts.Regular, TextSize = TS(12),
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2,
    }, panel)

    local barBg = Make("Frame", {
        Size = UDim2.new(1, 0, 0, 8), BackgroundColor3 = Color3.fromRGB(70, 70, 85),
        BorderSizePixel = 0, LayoutOrder = 3,
    }, panel)
    Round(barBg, 4)
    local fill = Make("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = theme.Accent, BorderSizePixel = 0 }, barBg)
    Round(fill, 4)

    local statusRow = Make("Frame", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, LayoutOrder = 4 }, panel)
    local stepLbl = Make("TextLabel", {
        Size = UDim2.new(0.75, 0, 1, 0), BackgroundTransparency = 1, Text = steps[1],
        TextColor3 = theme.SubText, Font = Fonts.Medium, TextSize = TS(12),
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    }, statusRow)
    local pctLbl = Make("TextLabel", {
        Size = UDim2.new(0.25, 0, 1, 0), Position = UDim2.new(0.75, 0, 0, 0), BackgroundTransparency = 1,
        Text = "0%", TextColor3 = theme.Text, Font = Fonts.Bold, TextSize = TS(12),
        TextXAlignment = Enum.TextXAlignment.Right,
    }, statusRow)

    if self.Animations then
        pScale.Scale = 0.8
        Tween(pScale, { Scale = 1 }, 0.4, Enum.EasingStyle.Back)
    end
    Tween(backdrop, { BackgroundTransparency = opts.BackdropTransparency or 0.25 }, 0.3)

    local t0 = os.clock()
    repeat
        local p = math.clamp((os.clock() - t0) / duration, 0, 1)
        fill.Size = UDim2.new(p, 0, 1, 0)
        pctLbl.Text = math.floor(p * 100) .. "%"
        stepLbl.Text = steps[math.min(#steps, math.floor(p * #steps) + 1)]
        task.wait()
    until os.clock() - t0 >= duration
    fill.Size = UDim2.new(1, 0, 1, 0)
    pctLbl.Text = "100%"
    stepLbl.Text = steps[#steps]
    task.wait(0.25)

    Tween(pScale, { Scale = 0.8 }, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    Tween(backdrop, { BackgroundTransparency = 1 }, 0.25)
    task.wait(0.27)
    if rgbConn then rgbConn:Disconnect() end
    gui:Destroy()
end

-- ========== KeySystem ==========
function ArceusXLibrary:ClearSavedKey(fileName)
    fileName = fileName or "ArceusXV2_Key.txt"
    if not (delfile and isfile) or not isfile(fileName) then return false end
    return (pcall(delfile, fileName))
end

--[[
    Normalmente se usa desde CreateWindow:  KeySystem = true, KeySettings = { ... }
    KeySettings: Title, Subtitle, Note,
      Key = "a" | Key = { "a", "b" }  (también Keys y entradas sueltas), KeyUrl, Validate,
      Copy = "texto"                   -- botón "Copiar" que copia ese texto (ej. la key)
      KeyExpiry = { ["key"] = os.time{...} }   -- fecha límite absoluta por key
      KeyDurations = { ["key"] = horas }       -- duración desde el primer uso (requiere SaveKey)
      SaveDuration = horas                     -- duración por defecto de la key guardada
      GetKeyLink = "url" | { {Text = "Discord", Link = "url"}, ... }  (también Links)
      GetKeyText, SaveKey, FileName, RGBBorder(s), RGBColors, MaxAttempts,
      LockTime (segundos de bloqueo al agotar intentos), KickOnFail, KickMessage,
      Placeholder, VerifyText, Width, AllowClose, Notify, StopScript,
      OnSuccess, OnFail, OnClose
    Devuelve true si la key fue correcta (la función espera a que el usuario termine).
]]
function ArceusXLibrary:KeySystem(opts)
    opts = opts or {}
    ApplyStyle(opts)
    if opts.Animations ~= nil then self.Animations = opts.Animations end

    local theme = {}
    for k, v in pairs(Themes[opts.Theme or "Dark"]) do theme[k] = v end
    for k, v in pairs(opts.CustomTheme or {}) do theme[k] = v end

    local fileName = opts.FileName or "ArceusXV2_Key.txt"
    local notify = opts.Notify ~= false
    local rgbBorder = opts.RGBBorder or opts.RGBBorders -- se aceptan ambos nombres

    -- Keys: Key = "a" | Keys = "a" | Keys = { "a", "b" } | y también entradas sueltas { "a", "b" }
    local keys = {}
    local function addKeys(v)
        if type(v) == "string" or type(v) == "number" then
            table.insert(keys, Trim(v))
        elseif type(v) == "table" then
            for _, k in ipairs(v) do
                if type(k) == "string" or type(k) == "number" then table.insert(keys, Trim(k)) end
            end
        end
    end
    addKeys(opts.Key)   -- Key = "a"  o  Key = { "a", "b" }
    addKeys(opts.Keys)  -- Keys = "a"  o  Keys = { "a", "b" }
    addKeys(opts)       -- entradas sueltas
    if #keys == 0 and not opts.KeyUrl and type(opts.Validate) ~= "function" then
        warn("[ArceusXLibraryV2] KeySystem sin keys configuradas (usa Keys, KeyUrl o Validate)")
    end

    -- Links para obtener la key (uno o varios)
    local links = {}
    local function addLink(l, defaultText)
        if type(l) == "string" or type(l) == "number" then
            table.insert(links, { Text = defaultText, Link = tostring(l) })
        elseif type(l) == "table" then
            local url = l.Link or l.Url or l.Value or l[1]
            if url then table.insert(links, { Text = l.Text or l.Name or defaultText, Link = tostring(url) }) end
        end
    end
    local defaultLinkText = opts.GetKeyText or L("key_getkey")
    if type(opts.GetKeyLink) == "string" then
        addLink(opts.GetKeyLink, defaultLinkText)
    elseif type(opts.GetKeyLink) == "table" then
        for _, l in ipairs(opts.GetKeyLink) do addLink(l, defaultLinkText) end
    end
    if type(opts.Links) == "table" then
        for _, l in ipairs(opts.Links) do addLink(l, defaultLinkText) end
    end
    -- Copy = "2026"  ->  botón "Copiar" que copia ese texto al portapapeles
    local copyText = opts.CopyText or L("key_copy")
    if type(opts.Copy) == "table" and opts.Copy.Text == nil and opts.Copy.Value == nil and opts.Copy.Link == nil then
        for _, c in ipairs(opts.Copy) do addLink(c, copyText) end
    else
        addLink(opts.Copy, copyText)
    end

    -- Devuelve ok, motivo ("expired")
    local function check(input)
        input = Trim(input)
        if input == "" then return false end
        local valid = false
        if type(opts.Validate) == "function" then
            local ok, res = pcall(opts.Validate, input)
            if ok and res then valid = true end
        end
        if not valid then
            for _, k in ipairs(keys) do
                if input == k then valid = true break end
            end
        end
        if not valid and opts.KeyUrl then
            local ok, body = pcall(function() return game:HttpGet(opts.KeyUrl) end)
            if ok and type(body) == "string" then
                for line in string.gmatch(body, "[^\r\n]+") do
                    if Trim(line) == input then valid = true break end
                end
            end
        end
        if not valid then return false end
        local exp = type(opts.KeyExpiry) == "table" and opts.KeyExpiry[input] or nil
        if exp and os.time() > exp then return false, "expired" end
        return true
    end

    -- Key guardada de una sesión anterior
    local startStatus
    if opts.SaveKey and readfile and isfile and isfile(fileName) then
        local ok, raw = pcall(readfile, fileName)
        if ok and raw then
            local savedKey, savedTime = raw, nil
            local okj, data = pcall(function() return HttpService:JSONDecode(raw) end)
            if okj and type(data) == "table" and data.key then savedKey, savedTime = data.key, data.time end
            local valid, reason = check(savedKey)
            if valid then
                local hours = type(opts.KeyDurations) == "table" and opts.KeyDurations[Trim(savedKey)] or nil
                hours = hours or opts.SaveDuration
                if hours and (not savedTime or (os.time() - savedTime) > hours * 3600) then
                    valid = false
                    reason = "expired"
                end
            end
            if valid then
                if notify then
                    self:Notify({ Title = L("key_title"), Content = L("key_saved_valid"), Type = "Success", Theme = theme, Duration = 3 })
                end
                Safe(opts.OnSuccess)
                return true
            end
            if reason == "expired" then startStatus = L("key_expired") end
        end
    end

    local green, red = Color3.fromRGB(60, 200, 110), Color3.fromRGB(235, 70, 70)
    local cr = opts.CornerRadius or 14
    local hasSub = opts.Subtitle ~= nil and opts.Subtitle ~= ""
    local hasNote = opts.Note ~= nil and opts.Note ~= ""

    local gui = Make("ScreenGui", {
        Name = "ArceusXV2_KeySystem", ResetOnSpawn = false, DisplayOrder = 500,
        IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, GetParent())
    local backdrop = Make("TextButton", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
    }, gui)

    local panel = Make("Frame", {
        Size = UDim2.new(0, opts.Width or 340, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = theme.Main, BorderSizePixel = 0,
    }, backdrop)
    Round(panel, cr)
    Pad(panel, 16)
    Make("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, panel)
    local pScale = Make("UIScale", { Scale = 1 }, panel)

    -- Borde (RGB opcional)
    local stroke = Make("UIStroke", {
        Thickness = opts.BorderThickness or 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = rgbBorder and Color3.new(1, 1, 1) or theme.Accent,
        Transparency = rgbBorder and 0 or 0.5,
    }, panel)
    local grad, rgbConn
    if rgbBorder then
        grad = Make("UIGradient", { Color = ToSequence(opts.RGBColors or Rainbow) }, stroke)
        rgbConn = RunService.RenderStepped:Connect(function(dt)
            grad.Rotation = (grad.Rotation + dt * (opts.RGBSpeed or 120)) % 360
        end)
    end

    -- Cabecera: título + subtítulo + X
    local header = Make("Frame", {
        Size = UDim2.new(1, 0, 0, hasSub and 40 or 24), BackgroundTransparency = 1, LayoutOrder = 1,
    }, panel)
    Make("TextLabel", {
        Size = UDim2.new(1, -34, 0, 22), BackgroundTransparency = 1, Text = opts.Title or L("key_title"),
        TextColor3 = theme.Text, Font = Fonts.Bold, TextSize = TS(18),
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    }, header)
    if hasSub then
        Make("TextLabel", {
            Size = UDim2.new(1, -34, 0, 14), Position = UDim2.new(0, 0, 0, 24),
            BackgroundTransparency = 1, Text = opts.Subtitle, TextColor3 = theme.SubText,
            Font = Fonts.Regular, TextSize = TS(12), TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, header)
    end
    local closeBtn
    if opts.AllowClose ~= false then
        closeBtn = Make("TextButton", {
            Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -26, 0, -2),
            BackgroundColor3 = theme.Element, BorderSizePixel = 0, Text = "X",
            TextColor3 = theme.Text, Font = Fonts.Bold, TextSize = TS(13), AutoButtonColor = false,
        }, header)
        Round(closeBtn, 7)
        closeBtn.MouseEnter:Connect(function() Tween(closeBtn, { BackgroundColor3 = red }, 0.12) end)
        closeBtn.MouseLeave:Connect(function() Tween(closeBtn, { BackgroundColor3 = theme.Element }, 0.15) end)
    end

    -- Nota (opcional)
    if hasNote then
        local noteBox = Make("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = theme.Element, BorderSizePixel = 0, LayoutOrder = 2,
        }, panel)
        Round(noteBox, 8)
        Pad(noteBox, 10)
        Make("UIListLayout", { Padding = UDim.new(0, 3) }, noteBox)
        Make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = L("key_note"),
            TextColor3 = theme.Accent, Font = Fonts.Bold, TextSize = TS(11),
            TextXAlignment = Enum.TextXAlignment.Left,
        }, noteBox)
        Make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
            Text = opts.Note, TextColor3 = theme.Text, Font = Fonts.Regular, TextSize = TS(13),
            TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
        }, noteBox)
    end

    -- Caja de la key
    local box = Make("TextBox", {
        Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = theme.Element, BorderSizePixel = 0,
        Text = "", PlaceholderText = opts.Placeholder or L("key_placeholder"),
        TextColor3 = theme.Text, PlaceholderColor3 = theme.SubText, Font = Fonts.Medium,
        TextSize = TS(14), ClearTextOnFocus = false, LayoutOrder = 3,
    }, panel)
    Round(box, 8)
    Make("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, box)
    local boxStroke = Make("UIStroke", { Color = theme.Accent, Thickness = 1.5, Transparency = 1 }, box)
    box.Focused:Connect(function() Tween(boxStroke, { Transparency = 0 }, 0.15) end)

    local status = Make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "", TextColor3 = theme.SubText,
        Font = Fonts.Medium, TextSize = TS(12), LayoutOrder = 4,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, panel)
    local function setStatus(text, color)
        status.Text = text
        status.TextColor3 = color or theme.SubText
    end
    if startStatus then setStatus(startStatus, red) end

    -- Botones: Verificar (fila 1) + links (fila 2)
    local function buttonRow(order)
        local row = Make("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, LayoutOrder = order }, panel)
        Make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, row)
        return row
    end
    local function mkBtn(row, text, order, count, primary)
        local b = Make("TextButton", {
            Size = UDim2.new(1 / count, -(8 * (count - 1)) / count, 1, 0), LayoutOrder = order,
            BackgroundColor3 = primary and theme.Accent or theme.Element, BorderSizePixel = 0,
            Text = text, TextColor3 = primary and Color3.new(1, 1, 1) or theme.Text,
            Font = Fonts.Medium, TextSize = TS(14), AutoButtonColor = true,
        }, row)
        Round(b, 8)
        return b
    end
    local verifyBtn = mkBtn(buttonRow(5), opts.VerifyText or L("key_verify"), 1, 1, true)
    local linkButtons = {}
    if #links > 0 then
        local lrow = buttonRow(6)
        for i, l in ipairs(links) do
            local b = mkBtn(lrow, l.Text, i, #links, false)
            table.insert(linkButtons, { btn = b, link = l.Link })
        end
    end

    -- Lógica
    local done, result, busy, locked, attempts = false, false, false, false, 0

    local function finish(res)
        if done then return end
        done, result = true, res
        if rgbConn then rgbConn:Disconnect() end
        Tween(pScale, { Scale = 0.8 }, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        Tween(backdrop, { BackgroundTransparency = 1 }, 0.25)
        task.delay(0.27, function() gui:Destroy() end)
    end

    local function shake()
        task.spawn(function()
            local base = panel.Position
            for _, dx in ipairs({ 10, -10, 7, -7, 3, 0 }) do
                Tween(panel, { Position = base + UDim2.new(0, dx, 0, 0) }, 0.05)
                task.wait(0.05)
            end
        end)
    end

    local function startLock(seconds)
        locked = true
        task.spawn(function()
            for remaining = seconds, 1, -1 do
                if done then return end
                setStatus(string.format(L("key_locked"), remaining), red)
                task.wait(1)
            end
            locked = false
            attempts = 0
            if not done then setStatus("", theme.SubText) end
        end)
    end

    local function verify()
        if busy or locked or done then return end
        local input = box.Text
        if Trim(input) == "" then
            setStatus(L("key_empty"), red)
            shake()
            return
        end
        busy = true
        setStatus(L("key_checking"), theme.SubText)
        task.spawn(function()
            local ok, reason = check(input)
            busy = false
            if done then return end
            if ok then
                setStatus(L("key_ok"), green)
                if not rgbBorder then Tween(stroke, { Color = green, Transparency = 0 }, 0.2) end
                if opts.SaveKey and writefile then
                    pcall(writefile, fileName, HttpService:JSONEncode({ key = Trim(input), time = os.time() }))
                end
                if notify then
                    self:Notify({ Title = L("key_title"), Content = L("key_granted"), Type = "Success", Theme = theme, Duration = 3 })
                end
                task.wait(0.45)
                finish(true)
                Safe(opts.OnSuccess)
            else
                attempts = attempts + 1
                setStatus(reason == "expired" and L("key_expired") or L("key_bad"), red)
                if not rgbBorder then
                    Tween(stroke, { Color = red, Transparency = 0 }, 0.1)
                    task.delay(0.6, function()
                        if not done then Tween(stroke, { Color = theme.Accent, Transparency = 0.5 }, 0.3) end
                    end)
                end
                shake()
                if notify then
                    self:Notify({
                        Title = L("key_title"),
                        Content = reason == "expired" and L("key_expired") or L("key_invalid"),
                        Type = "Error", Theme = theme, Duration = 3,
                    })
                end
                Safe(opts.OnFail, attempts)
                if opts.MaxAttempts and attempts >= opts.MaxAttempts then
                    if opts.KickOnFail then
                        LP:Kick(opts.KickMessage or L("key_kick"))
                        finish(false)
                        Safe(opts.OnClose)
                    elseif opts.LockTime then
                        startLock(opts.LockTime)
                    else
                        setStatus(L("key_too_many"), red)
                        task.wait(0.8)
                        finish(false)
                        Safe(opts.OnClose)
                    end
                end
            end
        end)
    end

    verifyBtn.MouseButton1Click:Connect(verify)
    box.FocusLost:Connect(function(enter)
        Tween(boxStroke, { Transparency = 1 }, 0.2)
        if enter then verify() end
    end)

    for _, lb in ipairs(linkButtons) do
        lb.btn.MouseButton1Click:Connect(function()
            local ok = Utils.Copy(lb.link)
            if ok then
                setStatus(L("key_copied"), green)
                if notify then
                    self:Notify({ Title = L("key_title"), Content = L("key_copied_short"), Type = "Success", Theme = theme, Duration = 2.5 })
                end
            else
                setStatus(tostring(lb.link), theme.SubText)
            end
        end)
    end

    if closeBtn then
        closeBtn.MouseButton1Click:Connect(function()
            if done then return end
            finish(false)
            Safe(opts.OnClose)
        end)
    end

    -- Animación de entrada
    if self.Animations then
        pScale.Scale = 0.8
        Tween(pScale, { Scale = 1 }, 0.45, Enum.EasingStyle.Back)
    end
    Tween(backdrop, { BackgroundTransparency = opts.BackdropTransparency or 0.35 }, 0.3)

    -- Espera a que el usuario termine
    repeat task.wait() until done
    return result
end

-- ========== Ventana ==========
function ArceusXLibrary:CreateWindow(opts)
    opts = opts or {}
    ApplyStyle(opts)
    self.Animations = opts.Animations ~= false
    self.AutoNotify = opts.AutoNotify == true
    if opts.NotifyPosition then self:SetNotifyPosition(opts.NotifyPosition) end
    if opts.Sounds then
        self.Sounds.Enabled = true
        if type(opts.Sounds) == "table" then
            for k, v in pairs(opts.Sounds) do self.Sounds[k] = v end
        end
    end

    local winTitle = opts.Title or "ArceusX Library V2"
    local cleanTitle = (string.gsub(winTitle, "[^%w_]", ""))

    -- 1) Restricciones: lugares y usuarios
    local allowed, deniedReason = CheckAccess(opts)
    if not allowed then
        self:Notify({ Title = L("denied"), Content = deniedReason, Type = "Error", Duration = 6 })
        Safe(opts.OnDenied, deniedReason)
        if opts.StopOnDenied == false then return nil end
        error("[ArceusXLibraryV2] " .. L("denied") .. ": " .. deniedReason, 0)
    end

    -- 2) Key System integrado: se muestra antes de crear la ventana
    local usedKeySettings
    if opts.KeySystem or opts.Keysystem then
        local ks = {}
        for k, v in pairs(opts.KeySettings or opts.Keysettings or {}) do ks[k] = v end -- copia (incluye keys sueltas)
        if ks.Title == nil or ks.Title == "" then ks.Title = winTitle .. ": Key System" end
        if ks.Subtitle == nil or ks.Subtitle == "" then ks.Subtitle = "Key System" end
        if ks.Theme == nil then ks.Theme = opts.Theme end
        if ks.CustomTheme == nil then ks.CustomTheme = opts.CustomTheme end
        if ks.CornerRadius == nil then ks.CornerRadius = opts.CornerRadius end
        if ks.Animations == nil then ks.Animations = opts.Animations end
        if ks.RGBBorder == nil and ks.RGBBorders == nil then ks.RGBBorder = opts.RGBBorder end
        if ks.FileName == nil then ks.FileName = "ArceusXV2_Key_" .. cleanTitle .. ".txt" end
        usedKeySettings = ks
        local granted = self:KeySystem(ks)
        if not granted then
            if ks.StopScript == false then return nil end
            error("[ArceusXLibraryV2] Key System: " .. L("denied"), 0) -- detiene el script
        end
    end

    -- 3) Pantalla de carga
    if opts.LoadingScreen then
        local ls = {}
        if type(opts.LoadingScreen) == "table" then
            for k, v in pairs(opts.LoadingScreen) do ls[k] = v end
        end
        if ls.Title == nil then ls.Title = winTitle end
        if ls.Theme == nil then ls.Theme = opts.Theme end
        if ls.CustomTheme == nil then ls.CustomTheme = opts.CustomTheme end
        if ls.CornerRadius == nil then ls.CornerRadius = opts.CornerRadius end
        if ls.RGBBorder == nil then ls.RGBBorder = opts.RGBBorder end
        self:LoadingScreen(ls)
    end

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
    local subtitle = opts.Subtitle
    local hasSub = subtitle ~= nil and subtitle ~= ""
    local topH = hasSub and 40 or 34
    local tabMode = (opts.TabPosition == "Top") and "Top" or "Left"
    local topTabH = 34
    local iconId = opts.Icon
    local hasIcon = iconId ~= nil and iconId ~= ""
    local versionText = opts.Version and tostring(opts.Version) or nil
    local versionW = versionText and (#versionText * 7 + 22) or 0
    local transparency = 0

    local main = Make("Frame", {
        Size = size, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = opts.Position or UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = theme.Main, BorderSizePixel = 0, ClipsDescendants = true,
    }, gui)
    Round(main, cr)
    local mainScale = Make("UIScale", { Scale = userScale }, main)

    -- Barra superior (redondeada arriba, recta abajo)
    local top = Make("Frame", {
        Size = UDim2.new(1, 0, 0, topH), BackgroundColor3 = theme.Top, BorderSizePixel = 0,
    }, main)
    Round(top, cr)
    local topFill = Make("Frame", {
        Size = UDim2.new(1, 0, 0, cr), Position = UDim2.new(0, 0, 1, -cr),
        BackgroundColor3 = theme.Top, BorderSizePixel = 0,
    }, top)

    local iconLabel = Make("ImageLabel", {
        Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 10, 0.5, -11),
        BackgroundTransparency = 1, Image = hasIcon and tostring(iconId) or "",
        ScaleType = Enum.ScaleType.Crop, Visible = hasIcon,
    }, top)
    Round(iconLabel, 6)

    local titleLabel = Make("TextLabel", {
        Size = UDim2.new(1, -90, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, Text = winTitle,
        TextColor3 = theme.Text, Font = Fonts.Bold, TextSize = TS(15),
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    }, top)
    local subtitleLabel = Make("TextLabel", {
        Size = UDim2.new(1, -90, 0, 14), Position = UDim2.new(0, 12, 0, 23),
        BackgroundTransparency = 1, Text = subtitle or "", TextColor3 = theme.SubText,
        Font = Fonts.Regular, TextSize = TS(11), TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, Visible = hasSub,
    }, top)

    local versionPill = Make("Frame", {
        Size = UDim2.new(0, versionW, 0, 18), AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -76, 0.5, 0), BackgroundColor3 = theme.Element,
        BorderSizePixel = 0, Visible = versionText ~= nil,
    }, top)
    Round(versionPill, 9)
    local versionLabel = Make("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = versionText or "",
        TextColor3 = theme.Accent, Font = Fonts.Bold, TextSize = TS(10),
    }, versionPill)

    local function topBtn(text, offset)
        local b = Make("TextButton", {
            Size = UDim2.new(0, 28, 0, 24), Position = UDim2.new(1, offset, 0.5, -12),
            BackgroundColor3 = theme.Element, BorderSizePixel = 0, Text = text,
            TextColor3 = theme.Text, Font = Fonts.Bold, TextSize = TS(14), AutoButtonColor = false,
        }, top)
        Round(b, 7)
        Connect(b.MouseEnter, function() Tween(b, { BackgroundColor3 = theme.Accent }, 0.12) end)
        Connect(b.MouseLeave, function() Tween(b, { BackgroundColor3 = theme.Element }, 0.15) end)
        return b
    end
    local minBtn, closeBtn = topBtn("-", -66), topBtn("X", -34)
    if opts.Draggable ~= false then Draggable(top, main) end

    -- Perfil (foto + nombre) opcional
    local profile = opts.Profile
    local hasProfile = profile ~= nil and profile ~= false
    local pInfo = type(profile) == "table" and profile or {}
    local pUserId = pInfo.UserId or LP.UserId
    local pImage = pInfo.Image or ("rbxthumb://type=AvatarHeadShot&id=" .. tostring(pUserId) .. "&w=150&h=150")

    -- Barra lateral (modo Left) o barra de pestañas superior (modo Top)
    local sbW = (tabMode == "Left") and (hasProfile and 130 or 110) or 0

    local sidebar = Make("Frame", {
        Size = UDim2.new(0, sbW, 1, -topH), Position = UDim2.new(0, 0, 0, topH),
        BackgroundColor3 = theme.Top, BorderSizePixel = 0, Visible = tabMode == "Left",
    }, main)
    Round(sidebar, cr)
    local sbFillTop = Make("Frame", {
        Size = UDim2.new(1, 0, 0, cr), BackgroundColor3 = theme.Top, BorderSizePixel = 0,
    }, sidebar)
    local sbFillRight = Make("Frame", {
        Size = UDim2.new(0, cr, 1, 0), Position = UDim2.new(1, -cr, 0, 0),
        BackgroundColor3 = theme.Top, BorderSizePixel = 0,
    }, sidebar)

    local tabsTop = Make("Frame", {
        Size = UDim2.new(1, 0, 0, topTabH), Position = UDim2.new(0, 0, 0, topH),
        BackgroundColor3 = theme.Top, BorderSizePixel = 0, Visible = tabMode == "Top",
    }, main)

    local tabBar
    if tabMode == "Left" then
        tabBar = Make("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, hasProfile and -58 or 0), BackgroundTransparency = 1,
            BorderSizePixel = 0, ScrollBarThickness = 0,
            AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
        }, sidebar)
        Pad(tabBar, 6)
        Make("UIListLayout", { Padding = UDim.new(0, 4) }, tabBar)

        if hasProfile then
            local sub = pInfo.Subtitle
            if sub == nil and not pInfo.UserId then sub = "@" .. LP.Name end
            local card = Make("Frame", {
                Size = UDim2.new(1, -12, 0, 46), Position = UDim2.new(0, 6, 1, -52),
                BackgroundColor3 = theme.Element, BorderSizePixel = 0,
            }, sidebar)
            Round(card, 10)
            local avatar = Make("ImageLabel", {
                Size = UDim2.new(0, 34, 0, 34), Position = UDim2.new(0, 6, 0.5, -17),
                BackgroundColor3 = theme.Main, BorderSizePixel = 0, ScaleType = Enum.ScaleType.Crop,
                Image = pImage,
            }, card)
            Round(avatar, 17)
            Make("UIStroke", { Color = theme.Accent, Thickness = 1.5 }, avatar)
            Make("TextLabel", {
                Size = UDim2.new(1, -50, 0, 18), Position = UDim2.new(0, 46, 0, sub and 6 or 14),
                BackgroundTransparency = 1, Text = pInfo.Name or LP.DisplayName, TextColor3 = theme.Text,
                Font = Fonts.Bold, TextSize = TS(12), TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, card)
            if sub then
                Make("TextLabel", {
                    Size = UDim2.new(1, -50, 0, 14), Position = UDim2.new(0, 46, 0, 24),
                    BackgroundTransparency = 1, Text = sub, TextColor3 = theme.SubText,
                    Font = Fonts.Regular, TextSize = TS(10), TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                }, card)
            end
        end
    else
        tabBar = Make("ScrollingFrame", {
            Size = UDim2.new(1, hasProfile and -44 or 0, 1, 0), BackgroundTransparency = 1,
            BorderSizePixel = 0, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X,
            AutomaticCanvasSize = Enum.AutomaticSize.X, CanvasSize = UDim2.new(),
        }, tabsTop)
        Make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, tabBar)
        Make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4),
            VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
        }, tabBar)
        if hasProfile then
            local avatar = Make("ImageLabel", {
                Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -34, 0.5, -13),
                BackgroundColor3 = theme.Main, BorderSizePixel = 0, ScaleType = Enum.ScaleType.Crop,
                Image = pImage,
            }, tabsTop)
            Round(avatar, 13)
            Make("UIStroke", { Color = theme.Accent, Thickness = 1.5 }, avatar)
        end
    end

    local pages = Make("Frame", {
        BackgroundTransparency = 1, ClipsDescendants = true,
    }, main)

    -- Recalcula las posiciones (barra superior, pestañas y páginas)
    local function layoutTop()
        topH = hasSub and 40 or 34
        top.Size = UDim2.new(1, 0, 0, topH)
        local leftX = hasIcon and 40 or 12
        local reserved = 84 + (versionText and (versionW + 8) or 0)
        iconLabel.Visible = hasIcon
        titleLabel.Size = hasSub and UDim2.new(1, -(leftX + reserved), 0, 20) or UDim2.new(1, -(leftX + reserved), 1, 0)
        titleLabel.Position = UDim2.new(0, leftX, 0, hasSub and 4 or 0)
        subtitleLabel.Size = UDim2.new(1, -(leftX + reserved), 0, 14)
        subtitleLabel.Position = UDim2.new(0, leftX, 0, 23)
        subtitleLabel.Visible = hasSub
        versionPill.Visible = versionText ~= nil
        sidebar.Size = UDim2.new(0, sbW, 1, -topH)
        sidebar.Position = UDim2.new(0, 0, 0, topH)
        tabsTop.Position = UDim2.new(0, 0, 0, topH)
        local pageY = topH + (tabMode == "Top" and topTabH or 0)
        pages.Position = UDim2.new(0, sbW, 0, pageY)
        pages.Size = UDim2.new(1, -sbW, 1, -pageY)
    end
    layoutTop()

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
        Font = Fonts.Bold, TextSize = math.floor(bSize * 0.45), BorderSizePixel = 0,
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

    -- Watermark (texto fijo en pantalla)
    local wmPositions = {
        TopLeft = { Vector2.new(0, 0), UDim2.new(0, 10, 0, 8) },
        TopCenter = { Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 8) },
        TopRight = { Vector2.new(1, 0), UDim2.new(1, -10, 0, 8) },
        BottomLeft = { Vector2.new(0, 1), UDim2.new(0, 10, 1, -8) },
        BottomCenter = { Vector2.new(0.5, 1), UDim2.new(0.5, 0, 1, -8) },
        BottomRight = { Vector2.new(1, 1), UDim2.new(1, -10, 1, -8) },
    }
    local wm = opts.Watermark
    local wmText = type(wm) == "table" and wm.Text or (type(wm) == "string" and wm or "")
    local wmPos = wmPositions[type(wm) == "table" and wm.Position or "BottomCenter"] or wmPositions.BottomCenter
    local wmFrame = Make("Frame", {
        Size = UDim2.new(0, 0, 0, 24), AutomaticSize = Enum.AutomaticSize.X,
        AnchorPoint = wmPos[1], Position = wmPos[2], BackgroundColor3 = theme.Main,
        BackgroundTransparency = 0.25, BorderSizePixel = 0, Visible = wmText ~= "",
    }, gui)
    Round(wmFrame, 12)
    Make("UIStroke", { Color = theme.Accent, Thickness = 1, Transparency = 0.5 }, wmFrame)
    Make("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, wmFrame)
    local wmLabel = Make("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1,
        Text = wmText, TextColor3 = theme.Text, Font = Fonts.Medium, TextSize = TS(11),
    }, wmFrame)

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
        Text = "", TextColor3 = theme.Text, Font = Fonts.Medium, TextSize = TS(12),
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

    local window = {
        Gui = gui, Tabs = {}, _visible = true, ConfigName = opts.ConfigName or cleanTitle,
        KeySettings = usedKeySettings, -- settings usados por el Key System (nil si no se usó)
    }
    local minimized = false
    local toggleKey = opts.ToggleKey

    -- ----- Blur de fondo (opcional) -----
    local blurEffect
    local blurSize = 0
    if opts.Blur then blurSize = type(opts.Blur) == "number" and opts.Blur or 16 end
    local function applyBlur(visible)
        if blurSize <= 0 then
            if blurEffect then Tween(blurEffect, { Size = 0 }, 0.3) end
            return
        end
        if not blurEffect then
            blurEffect = Make("BlurEffect", { Name = "ArceusXV2_Blur", Size = 0 }, Lighting)
        end
        Tween(blurEffect, { Size = visible and blurSize or 0 }, 0.35)
    end

    -- ----- Redimensionar (opcional) -----
    local resizeHandle
    if opts.Resizable then
        local minSize = opts.MinSize or Vector2.new(340, 220)
        local maxSize = opts.MaxSize or Vector2.new(900, 650)
        resizeHandle = Make("TextButton", {
            Size = UDim2.new(0, 24, 0, 24), AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1, Text = "", ZIndex = 50, AutoButtonColor = false,
        }, main)
        for _, p in ipairs({ { 15, 15 }, { 15, 9 }, { 9, 15 } }) do
            local dot = Make("Frame", {
                Size = UDim2.new(0, 3, 0, 3), Position = UDim2.new(0, p[1], 0, p[2]),
                BackgroundColor3 = theme.SubText, BorderSizePixel = 0, ZIndex = 51,
            }, resizeHandle)
            Round(dot, 2)
        end
        local resizing, startInput, startSize = false, nil, nil
        Connect(resizeHandle.InputBegan, function(i)
            if IsPress(i) then
                resizing, startInput, startSize = true, i.Position, Vector2.new(sizeW, sizeH)
            end
        end)
        Connect(UIS.InputChanged, function(i)
            if resizing and IsMove(i) and not minimized then
                local s = mainScale.Scale
                local d = (i.Position - startInput) / s
                local newW = math.clamp(startSize.X + d.X, minSize.X, maxSize.X)
                local newH = math.clamp(startSize.Y + d.Y, minSize.Y, maxSize.Y)
                local dw, dh = newW - sizeW, newH - sizeH
                sizeW, sizeH = newW, newH
                main.Size = UDim2.new(0, sizeW, 0, sizeH)
                -- mantiene fija la esquina superior izquierda (la ventana está anclada al centro)
                main.Position = main.Position + UDim2.new(0, dw / 2 * s, 0, dh / 2 * s)
            end
        end)
        Connect(UIS.InputEnded, function(i)
            if IsPress(i) then resizing = false end
        end)
    end

    -- ----- Mostrar / ocultar con animación -----
    function window:Toggle(state)
        if state == nil then state = not self._visible end
        if state == self._visible then return end
        self._visible = state
        applyBlur(state)
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

    local function setBody(v)
        sidebar.Visible = v and tabMode == "Left"
        tabsTop.Visible = v and tabMode == "Top"
        pages.Visible = v
        topFill.Visible = v
        if resizeHandle then resizeHandle.Visible = v end
    end

    function window:Minimize(state)
        if state == nil then state = not minimized end
        minimized = state
        local newH = state and topH or sizeH
        local curH = main.Size.Y.Offset
        Tween(main, {
            Size = UDim2.new(0, sizeW, 0, newH),
            Position = main.Position + UDim2.new(0, 0, 0, (newH - curH) / 2),
        }, 0.28, Enum.EasingStyle.Quint)
        if state then
            task.delay(0.28, function()
                if minimized then setBody(false) end
            end)
        else
            setBody(true)
        end
    end

    function window:Destroy()
        if window._autoSaveStop then window._autoSaveStop() end
        if blurEffect then pcall(function() blurEffect:Destroy() end) end
        gui:Destroy()
    end

    function window:SetTitle(t) titleLabel.Text = tostring(t) end
    function window:SetSubtitle(t)
        t = t and tostring(t) or ""
        subtitleLabel.Text = t
        hasSub = t ~= ""
        layoutTop()
    end
    function window:SetIcon(id)
        hasIcon = id ~= nil and id ~= ""
        iconLabel.Image = hasIcon and tostring(id) or ""
        layoutTop()
    end
    function window:SetVersion(t)
        versionText = (t ~= nil and t ~= "") and tostring(t) or nil
        versionW = versionText and (#versionText * 7 + 22) or 0
        versionPill.Size = UDim2.new(0, versionW, 0, 18)
        versionLabel.Text = versionText or ""
        layoutTop()
    end
    function window:SetWatermark(t)
        t = t and tostring(t) or ""
        wmLabel.Text = t
        wmFrame.Visible = t ~= ""
    end
    function window:SetToggleKey(key) toggleKey = key end
    function window:SetPosition(pos) Tween(main, { Position = pos }, 0.3, Enum.EasingStyle.Quint) end
    function window:SetScale(n)
        userScale = math.clamp(n, 0.5, 1.6)
        Tween(mainScale, { Scale = userScale }, 0.2)
    end
    function window:SetBlur(n)
        blurSize = (n == true) and 16 or (tonumber(n) or 0)
        if window._visible then applyBlur(true) end
    end

    -- Transparencia de la ventana (0 = opaca). Con transparencia se ocultan los rellenos de esquinas.
    function window:SetTransparency(t)
        transparency = math.clamp(tonumber(t) or 0, 0, 0.85)
        main.BackgroundTransparency = transparency
        top.BackgroundTransparency = transparency
        sidebar.BackgroundTransparency = transparency
        tabsTop.BackgroundTransparency = transparency
        local fillT = transparency > 0 and 1 or 0
        topFill.BackgroundTransparency = fillT
        sbFillTop.BackgroundTransparency = fillT
        sbFillRight.BackgroundTransparency = fillT
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
        if window._activeDialog then return window._activeDialog end
        if minimized then window:Minimize(false) end
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
            Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = d.Title or L("notice"),
            TextColor3 = theme.Text, Font = Fonts.Bold, TextSize = TS(16),
            TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1,
        }, panel)
        Make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
            Text = d.Content or "", TextColor3 = theme.SubText, Font = Fonts.Regular, TextSize = TS(13),
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
            window._activeDialog = nil
            Tween(overlay, { BackgroundTransparency = 1 }, 0.2)
            Tween(pScale, { Scale = 0.8 }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.delay(0.22, function() overlay:Destroy() end)
        end

        local buttons = d.Buttons or { { Text = L("ok") } }
        local n = #buttons
        for i, b in ipairs(buttons) do
            local btn = Make("TextButton", {
                Size = UDim2.new(1 / n, -(8 * (n - 1)) / n, 1, 0), LayoutOrder = i,
                BackgroundColor3 = i == 1 and theme.Accent or theme.Top, BorderSizePixel = 0,
                Text = b.Text or L("ok"), TextColor3 = i == 1 and Color3.new(1, 1, 1) or theme.Text,
                Font = Fonts.Medium, TextSize = TS(13), AutoButtonColor = true,
            }, btnRow)
            Round(btn, 8)
            btn.MouseButton1Click:Connect(function()
                PlaySfx("Click")
                close()
                Safe(b.Callback)
            end)
        end

        Tween(overlay, { BackgroundTransparency = 0.45 }, 0.2)
        Tween(pScale, { Scale = 1 }, 0.3, Enum.EasingStyle.Back)
        local handle = { Close = close }
        window._activeDialog = handle
        return handle
    end

    -- ----- Cierre con confirmación -----
    local confirmClose = opts.ConfirmClose ~= false
    local closeAction = opts.CloseAction or "Hide" -- "Hide" oculta el menú, "Destroy" lo descarga
    local function doClose()
        if closeAction == "Destroy" then ArceusXLibrary:Destroy() else window:Toggle(false) end
    end
    function window:SetConfirmClose(state) confirmClose = state and true or false end
    function window:Close(force) -- pide confirmación salvo que force = true
        if force or not confirmClose then
            doClose()
            return
        end
        window:Dialog({
            Title = opts.CloseTitle or L("close_title"),
            Content = opts.CloseMessage or (closeAction == "Destroy" and L("close_destroy") or L("close_hide")),
            Buttons = { { Text = L("close"), Callback = doClose }, { Text = L("cancel") } },
        })
    end

    -- ----- Eventos de la ventana -----
    Connect(float.MouseButton1Click, function()
        PlaySfx("Click")
        floatScale.Scale = 0.85
        Tween(floatScale, { Scale = 1 }, 0.3, Enum.EasingStyle.Back)
        window:Toggle()
    end)
    Connect(closeBtn.MouseButton1Click, function()
        PlaySfx("Click")
        window:Close()
    end)
    Connect(minBtn.MouseButton1Click, function()
        PlaySfx("Click")
        window:Minimize()
    end)
    Connect(UIS.InputBegan, function(i, gp)
        if not gp and toggleKey and i.KeyCode == toggleKey then window:Toggle() end
    end)

    -- ----- Pestañas (con ícono opcional y búsqueda opcional) -----
    function window:AddTab(name, icon)
        local imageIcon = icon and (tonumber(icon) ~= nil or string.find(tostring(icon), "rbx") ~= nil)
        local textIcon = (icon and not imageIcon) and tostring(icon) or nil
        local isTop = tabMode == "Top"

        local btn = Make("TextButton", {
            Size = isTop and UDim2.new(0, 0, 0, 26) or UDim2.new(1, 0, 0, 30),
            AutomaticSize = isTop and Enum.AutomaticSize.X or Enum.AutomaticSize.None,
            BackgroundColor3 = theme.Element, BorderSizePixel = 0,
            Text = (textIcon and (textIcon .. " ") or "") .. name, TextColor3 = theme.SubText,
            Font = Fonts.Medium, TextSize = TS(13), AutoButtonColor = false,
            LayoutOrder = #window.Tabs + 1,
        }, tabBar)
        Round(btn, 8)
        if isTop or imageIcon then
            Make("UIPadding", {
                PaddingLeft = UDim.new(0, (isTop and 12 or 0) + (imageIcon and 22 or 0)),
                PaddingRight = UDim.new(0, isTop and 12 or 0),
            }, btn)
        end
        local iconImg
        if imageIcon then
            local id = tostring(icon)
            if tonumber(id) then id = "rbxassetid://" .. id end
            iconImg = Make("ImageLabel", {
                Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, isTop and 10 or 8, 0.5, -8),
                BackgroundTransparency = 1, Image = id, ImageColor3 = theme.SubText,
            }, btn)
        end

        local page = Make("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 3, ScrollBarImageColor3 = theme.Accent, Visible = false,
            AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
        }, pages)
        Pad(page, 8)
        Make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, page)

        local tab = { Name = name }
        AddElements(tab, page, theme)

        if opts.Search then
            local sb = Make("Frame", {
                Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = theme.Element,
                BorderSizePixel = 0, LayoutOrder = -1000,
            }, page)
            Round(sb, 8)
            local sbox = Make("TextBox", {
                Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1,
                Text = "", PlaceholderText = L("search"), PlaceholderColor3 = theme.SubText,
                TextColor3 = theme.Text, Font = Fonts.Regular, TextSize = TS(13),
                TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
            }, sb)
            Connect(sbox:GetPropertyChangedSignal("Text"), function() tab:_Filter(sbox.Text) end)
        end

        local function select()
            for _, t in ipairs(window.Tabs) do
                t._page.Visible = false
                Tween(t._btn, { BackgroundColor3 = theme.Element }, 0.2)
                t._btn.TextColor3 = theme.SubText
                if t._icon then t._icon.ImageColor3 = theme.SubText end
            end
            page.Visible = true
            page.Position = UDim2.new(0, 0, 0, 16)
            Tween(page, { Position = UDim2.new(0, 0, 0, 0) }, 0.3, Enum.EasingStyle.Quint)
            Tween(btn, { BackgroundColor3 = theme.Accent }, 0.2)
            btn.TextColor3 = Color3.new(1, 1, 1)
            if iconImg then iconImg.ImageColor3 = Color3.new(1, 1, 1) end
            window.CurrentTab = tab
        end
        tab._page, tab._btn, tab._icon, tab._select = page, btn, iconImg, select
        function tab:Select() select() end
        Connect(btn.MouseButton1Click, function()
            PlaySfx("Click")
            select()
        end)
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

    -- ----- Opciones iniciales -----
    window:SetTransparency(opts.Transparency or 0)
    window:SetRGBBorder(opts.RGBBorder == true)
    window:SetButtonRGB(bo.RGB == true)
    window:SetButtonFill(bo.Fill == true)
    if opts.Stats then window:SetStats(true) end

    -- ----- Animación de entrada / estado inicial -----
    if opts.StartHidden then
        window._visible = false
        main.Visible = false
    else
        applyBlur(true)
        if ArceusXLibrary.Animations then
            mainScale.Scale = userScale * 0.8
            Tween(mainScale, { Scale = userScale }, 0.5, Enum.EasingStyle.Back)
            floatScale.Scale = 0
            Tween(floatScale, { Scale = 1 }, 0.5, Enum.EasingStyle.Back)
        end
        if opts.StartMinimized then
            task.delay(0.55, function() window:Minimize(true) end)
        end
    end

    -- ----- Mensaje de bienvenida -----
    if opts.WelcomeMessage then
        local w = opts.WelcomeMessage
        local n = { Title = winTitle, Type = "Success", Duration = 4, Theme = theme }
        if w == true then
            n.Content = L("welcome") .. LP.DisplayName .. "!"
        elseif type(w) == "string" then
            n.Content = w
        elseif type(w) == "table" then
            for k, v in pairs(w) do n[k] = v end
        end
        task.delay(0.7, function() self:Notify(n) end)
    end

    -- ----- Config automática (AutoLoad / AutoSave) -----
    local cfgName = window.ConfigName
    local loadDelay = opts.AutoLoadDelay or 0.6
    if opts.AutoLoad then
        task.spawn(function()
            task.wait(loadDelay) -- espera a que el script cree sus elementos
            ArceusXLibrary:LoadConfig(cfgName, true)
        end)
    end
    if opts.AutoSave then
        local alive = true
        window._autoSaveStop = function() alive = false end
        task.spawn(function()
            task.wait(loadDelay + 0.8)
            local last = ArceusXLibrary:_Snapshot()
            while alive do
                task.wait(opts.AutoSaveInterval or 3)
                if not alive then break end
                local cur = ArceusXLibrary:_Snapshot()
                if cur ~= last then
                    last = cur
                    ArceusXLibrary:SaveConfig(cfgName, true)
                end
            end
        end)
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

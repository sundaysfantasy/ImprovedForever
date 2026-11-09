-- The fork's own fine tuning of the HUD: sizes, places, times and limits the
-- modules had as fixed numbers, each a setting of the Immersion tab (its
-- fields added to InterfaceEditor.lua's, in their sections). Kept in one
-- file, and in a table of its own (IF.db.interfaceTune), so the modules
-- themselves change by a line each: where one read its constant, it asks
-- IN.Tune(key).
--
-- Two kinds:
-- * live: read where it's used, applied as the slider moves;
-- * at login: sizes the game's own lists are made with once (an aura
--   container's icons, their count). Read once, before any module's login
--   (C.AtLogin), so every part of a module sees one value; changed, they
--   take a /reload.
local IF = ImprovedForever
local IN = IF.Interface

local C = {}
IN.Custom = C

local DEFAULTS = {
    padScale = 100, padX = 0, padY = 0, -- the action bar's size (%) and place (px right, px up)
    castW = 460, castH = 3,             -- the cast line's length and thickness (px)
    timelineIcon = 75,                  -- the buff and cooldown rows' icons: % of the Cooldown Manager's (login)
    timelineDebuffs = 8,                -- the buff row's debuffs at most (login)
    powerShow = "peek",                 -- the power line: "peek" (in a fight or not full), "always"
    lineHold = 0.8,                     -- the lines whole again: shown this long before fading (s)
    chatDim = 22,                       -- the chat's lines while not in use: opacity (%)
    chatBright = 10,                    -- a new chat line stays bright this long (s)
    chatFade = 3,                       -- and fades back over this long (s)
    plateOtherScale = 80,               -- the nameplates that aren't your target's: size (%)
    plateOtherAlpha = 85,               -- and opacity (%)
    plateDrop = 34,                     -- ours this far under the game's plate centre (px)
    plateDebuffSize = 16,               -- a nameplate's debuff icons (px, login)
    plateDebuffMax = 5,                 -- and how many at most (login)
    targetOutAlpha = 35,                -- the target's health line out of reach: opacity (%)
    targetAuraSize = 22,                -- the target's buff and debuff icons (px, login)
    targetAuraMax = 8,                  -- and how many of each at most (login)
    zoneNames = "all",                  -- the zone banner: "all" (zones and subzones), "zone" (new zones only)
    zoneHold = 4,                       -- the zone's name shown this long (s)
    levelHold = 5,                      -- a level up (s)
    progressHold = 3,                   -- quest progress (s)
    arrowArrived = 8,                   -- the quest arrow stops pointing this near (yards)
}

-- A tuned value: the player's, else its default. Before the saved
-- variables are in (a file's own load): the default
function IN.Tune(key)
    local db = IF.db
    local t = db and db.interfaceTune
    local v = t and t[key]
    if v == nil then return DEFAULTS[key] end
    return v
end

local function Set(key, value)
    IF.db.interfaceTune = IF.db.interfaceTune or {}
    -- (the default itself isn't kept: a later change of it reaches the player)
    if value == DEFAULTS[key] then value = nil end
    IF.db.interfaceTune[key] = value
end

-- Read once at login, before the modules' own login (this file is loaded
-- right after Module.lua, so its callback is their first)
local atLogin = {}
function C.AtLogin(fn)
    atLogin[#atLogin + 1] = fn
end
IF.OnLogin(function()
    for _, fn in ipairs(atLogin) do
        local ok, err = pcall(fn)
        if not ok then IF.Print("Immersion: a tuned size was left at its default: " .. tostring(err)) end
    end
end)

---------------------------------------------------------------------------
-- Applying: each live setting's module told (the ones that place or size
-- something; the rest read their value as they run)
---------------------------------------------------------------------------
local function Call(module, fn)
    local m = IN[module]
    if m and m[fn] then
        local ok, err = pcall(m[fn])
        if not ok then IF.Print("Immersion: " .. module .. "." .. fn .. ": " .. tostring(err)) end
    end
end

local APPLY = {
    pad = function() Call("GamepadBar", "Place") end,
    cast = function() Call("PlayerCast", "Place") end,
    chat = function() Call("ChatView", "Tune") end,
    plates = function() Call("Nameplates", "Apply") end,
    power = function() Call("PlayerHealth", "Apply") end,
}

function C.ApplyAll()
    for _, fn in pairs(APPLY) do fn() end
end

---------------------------------------------------------------------------
-- The fields (SettingsPage.lua's items), each in a section of the
-- Immersion tab
---------------------------------------------------------------------------
local RELOAD = " Takes a /reload."

local function Px(n) return n .. " px" end
local function Percent(n) return n .. "%" end
local function Secs(n) return (n % 1 == 0 and "%d s" or "%.1f s"):format(n) end
local function Yards(n) return n .. " yd" end
local function Count(n) return tostring(n) end

local function Slider(key, group, section, label, tip, min, max, step, format, apply)
    return {
        key = key, group = group, section = section, label = label, tip = tip,
        slider = {
            min = min, max = max, step = step,
            get = function() return IN.Tune(key) end,
            set = function(n)
                -- (a step of a fraction: no 0.6000000001 kept)
                Set(key, math.floor(n / step + 0.5) * step)
                if apply then APPLY[apply]() end
            end,
            format = format,
        },
    }
end

local function Choice(key, group, section, label, tip, choices, apply)
    return {
        key = key, group = group, section = section, label = label, tip = tip,
        value = function() return IN.Tune(key) end,
        text = function()
            for _, c in ipairs(choices) do
                if c[1] == IN.Tune(key) then return c[2] end
            end
            return choices[1][2]
        end,
        options = function()
            local list = {}
            for _, c in ipairs(choices) do list[#list + 1] = { action = c[1], name = c[2] } end
            return list
        end,
        choose = function(action)
            Set(key, action)
            if apply then APPLY[apply]() end
        end,
    }
end

local ITEMS = {
    -- Header
    Slider("targetOutAlpha", "top", "Target", "Target out of reach: opacity",
        "How faint the target's health line gets while it's out of reach of your spells. 100%: not dimmed. "
            .. "Needs \"Target range\" on.", 10, 100, 5, Percent),
    Slider("targetAuraSize", "top", "Target", "Target buffs: icon size",
        "How big the icons under the target header are." .. RELOAD, 14, 40, 1, Px),
    Slider("targetAuraMax", "top", "Target", "Target buffs: how many",
        "How many of your debuffs, and how many of its buffs, show under the target header at most." .. RELOAD,
        2, 16, 1, Count),
    Slider("plateOtherScale", "top", "Nameplates", "Other nameplates: size",
        "How big the nameplates that aren't your target's are, against your target's.", 50, 100, 5, Percent,
        "plates"),
    Slider("plateOtherAlpha", "top", "Nameplates", "Other nameplates: opacity",
        "How solid the nameplates that aren't your target's are.", 20, 100, 5, Percent, "plates"),
    Slider("plateDrop", "top", "Nameplates", "Nameplate: lower",
        "How far under the game's own nameplate place ours sits, in pixels: more is closer to the mob's head.",
        0, 80, 2, Px, "plates"),
    Slider("plateDebuffSize", "top", "Nameplates", "Nameplate debuffs: icon size",
        "How big your debuffs under a nameplate are." .. RELOAD, 10, 30, 1, Px),
    Slider("plateDebuffMax", "top", "Nameplates", "Nameplate debuffs: how many",
        "How many of your debuffs show under a nameplate at most." .. RELOAD, 1, 10, 1, Count),
    Slider("arrowArrived", "top", "Quests", "Quest arrow: arrived within",
        "How near the quest's place the arrow stops pointing, in yards.", 2, 40, 1, Yards),
    Slider("progressHold", "top", "Quests", "Quest progress: shown for",
        "How long quest progress stays in the header after its last count.", 1, 10, 0.5, Secs),
    Choice("zoneNames", "top", "Banners", "Zone names: show",
        "Zones and subzones: every name, as the game shows them. New zones only: the banner stays away as "
            .. "you cross from one part of a zone to another.",
        { { "all", "Zones and subzones" }, { "zone", "New zones only" } }),
    Slider("zoneHold", "top", "Banners", "Zone names: shown for",
        "How long a zone's name stays in the header.", 1, 15, 0.5, Secs),
    Slider("levelHold", "top", "Banners", "Level ups: shown for",
        "How long a level up stays in the header.", 2, 20, 1, Secs),
    -- Body
    Slider("castW", "body", "Cast bar", "Cast bar: length",
        "How long your cast bar is, end to end, in pixels. /if casttest shows it.", 200, 900, 20, Px, "cast"),
    Slider("castH", "body", "Cast bar", "Cast bar: thickness",
        "How thick your cast bar's line is, in pixels.", 2, 12, 1, Px, "cast"),
    -- Footer
    Choice("powerShow", "bottom", "Player frame", "Power line: shown",
        "When your mana, rage or energy line shows. In a fight or not full: it fades away once you're at "
            .. "rest. Always: it stays, as the health line does. Needs the power line on.",
        { { "peek", "In a fight or not full" }, { "always", "Always" } }, "power"),
    Slider("lineHold", "bottom", "Player frame", "Lines: stay after full",
        "How long the lines along the bottom edge stay once you're whole and at rest again, before they fade.",
        0, 10, 0.2, Secs),
    Slider("padScale", "bottom", "Action bar", "Action bar: size",
        "How big the action bar's spell tiles are, in percent. Out of combat only.", 60, 150, 5, Percent, "pad"),
    Slider("padX", "bottom", "Action bar", "Action bar: right",
        "Moves the action bar to the right (left with a minus), in pixels. It's kept on the screen. Out of "
            .. "combat only.", -1400, 100, 10, Px, "pad"),
    Slider("padY", "bottom", "Action bar", "Action bar: up",
        "Moves the action bar up (down with a minus), in pixels. Out of combat only.", -30, 700, 10, Px, "pad"),
    Slider("timelineIcon", "bottom", "Buffs & cooldowns", "Buff and cooldown rows: icon size",
        "How big the round icons of the buff row and the cooldown row are, as a share of the game's "
            .. "Cooldown Manager's icons." .. RELOAD, 40, 130, 5, Percent),
    Slider("timelineDebuffs", "bottom", "Buffs & cooldowns", "Buff row: debuffs at most",
        "How many debuffs the buff row shows at most; the buffs get the room that's left." .. RELOAD,
        2, 16, 1, Count),
    Slider("chatDim", "bottom", "Chat", "Chat at rest: opacity",
        "How solid the chat's lines are while you aren't using it. 0%: only new lines show, until they fade.",
        0, 100, 2, Percent, "chat"),
    Slider("chatBright", "bottom", "Chat", "Chat: new line bright for",
        "How long a new chat line stays at full before it fades back to the rest.", 2, 60, 1, Secs, "chat"),
    Slider("chatFade", "bottom", "Chat", "Chat: fade time",
        "How long a new chat line takes to fade back.", 0, 10, 0.5, Secs, "chat"),
    {
        key = "tuneReset", group = "bottom", section = "Fine tuning", label = "Reset the fine tuning",
        tip = "Puts every size, place, time and limit of this fork's fine tuning back to its default (the "
            .. "on / off switches are left alone). The sizes that take a /reload change after one.",
        button = "Reset",
        confirm = true, confirmText = "Reset the fine tuning to its defaults?",
        run = function()
            IF.db.interfaceTune = nil
            C.ApplyAll()
            IF.Print("Immersion: fine tuning reset. /reload for the icon sizes.")
        end,
    },
}

-- Added to the Immersion tab's fields (InterfaceEditor.lua): each after the
-- last field of its own section, so a section stays in one piece; a section
-- the tab doesn't have goes at its end
function C.AddItems(list)
    for _, item in ipairs(ITEMS) do
        local at
        for i, other in ipairs(list) do
            if other.group == item.group and other.section == item.section then at = i end
        end
        table.insert(list, at and at + 1 or #list + 1, item)
    end
end

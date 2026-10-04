"""
Offline behaviour check for TitanReputation - no WoW client needed.

Loads the addon in TOC order into a Lua 5.1 VM with stubbed WoW + Titan APIs, drives it through
its real entry points (event handler, Titan registry callbacks, menu callbacks) and records what
a player would see. Every scenario runs twice - on a git ref (default HEAD) and on the working
tree - and prints IDENTICAL or both outputs, so a refactor can be shown to keep behaviour and a
fix to change only what it targets.

    pip install lupa
    python tools/harness.py [--base REF] [SCENARIO ...]

Exits with 1 when the working tree raised Lua errors in any scenario. Files missing from REF
(the gitignored packager externals such as libs/UTF8) are loaded from the working tree.
"""
import argparse
import copy
import io
import json
import pathlib
import re
import subprocess
import sys
import tarfile
import tempfile

import lupa.lua51 as lupa

REPO = pathlib.Path(__file__).resolve().parents[1]


def locate(tree, rel):
    """Path of `rel` in `tree`, falling back to the working tree for gitignored externals."""
    for root in (tree, REPO):
        if (root / rel).is_file():
            return root / rel
    return None


def load_order(tree):
    """Lua files in the order WoW loads them: TOC lines, with XML Script/Include expanded."""
    def expand(rel):
        rel = rel.replace("\\", "/")
        if rel.endswith(".lua"):
            return [rel]
        xml = locate(tree, rel).read_text(encoding="utf-8-sig")
        folder = pathlib.PurePosixPath(rel).parent
        files = []
        for kind, ref in re.findall(r'<(Script|Include)\s+file="([^"]+)"', xml):
            ref = ref.replace("\\", "/")
            # WoW looks next to the XML first, then from the addon root (main.xml uses the latter)
            nested = str(folder / ref)
            ref = nested if locate(tree, nested) else ref
            files += expand(ref) if kind == "Include" else [ref]
        return files

    toc = next(tree.glob("*.toc"))
    order = []
    for line in toc.read_text(encoding="utf-8-sig").splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            order += expand(line)
    return order

STUBS = r"""
NOW = 1000.0
ERRORS, CHAT, ALERTS, BUTTON_RENDERS = {}, {}, {}, {}
local BUILD = { retail = 120100, mop = 50504, era = 11509 }
function GetBuildInfo() return "x", "1", "d", BUILD[MODE] end
function GetTime() return NOW end
function GetLocale() return LOCALE or "enUS" end
tinsert, tremove, floor, format = table.insert, table.remove, math.floor, string.format
function wipe(t) for k in pairs(t) do t[k] = nil end return t end
function tContains(t, v) for _, x in ipairs(t) do if x == v then return true end end return false end
function hooksecurefunc(a, b, c)
  local tbl, key, fn = a, b, c
  if type(a) ~= "table" then tbl, key, fn = _G, a, b end
  local orig = tbl[key]
  tbl[key] = function(...) local r = { orig(...) }; fn(...); return unpack(r) end
end
function PlaySound() end
function print(...) CHAT[#CHAT + 1] = table.concat({ ... }, " ") end
DEFAULT_CHAT_FRAME = { AddMessage = function(_, msg) CHAT[#CHAT + 1] = msg end }
function IsControlKeyDown() return false end
function IsShiftKeyDown() return SHIFT or false end
function ToggleCharacter() end
SlashCmdList = {}
ACHIEVEMENT_UNLOCKED = "Achievement Unlocked"
for i, l in ipairs({ "Hated", "Hostile", "Unfriendly", "Neutral", "Friendly", "Honored", "Revered", "Exalted" }) do
  _G["FACTION_STANDING_LABEL" .. i] = l
end
GameFontNormal, GameFontNormalSmall = {}, {}
C_PetBattles = { IsInBattle = function() return false end }
TextureKitConstants = { UseAtlasSize = 1 }
AchievementFrame = {}
function AchievementShield_SetPoints() end
local function NewFrame(name)
  local f = { name = name }
  function f:RegisterEvent() end
  function f:UnregisterEvent() end
  function f:UnregisterAllEvents() end
  function f:SetScript() end
  function f:GetName() return self.name end
  return f
end
function CreateFrame(_, name) local f = NewFrame(name); if name then _G[name] = f end; return f end
local function NewTooltip()
  local t = { _scale = 1 }
  function t:GetOwner() return self._owner end
  function t:GetScale() return self._scale end
  function t:SetScale(s) self._scale = s end
  function t:Show() end
  return t
end
GameTooltip, TitanPanelTooltip = NewTooltip(), NewTooltip()
AlertFrame = { AddQueuedAlertFrameSubSystem = function()
  local sys = {}
  function sys:SetCanShowMoreConditionFunc() end
  function sys:AddAlert(p) ALERTS[#ALERTS + 1] = p.text .. ": " .. tostring(p.standingText) end
  return sys
end }
C_AddOns = {
  GetAddOnMetadata = function(name, field)
    if name == "Titan" then return "9.3.3" end
    if name == "TitanReputation" then return "1.0.0" end
    error("Couldn't find addon " .. tostring(name))
  end,
  IsAddOnLoaded = function() return false end,
}

-- Titan API (semantics mirrored from Titan 9.3.3)
TitanPluginSettings, TitanAll, PEW_DONE = nil, {}, false
function TitanGetVar(id, var)
  if id and var and TitanPluginSettings and TitanPluginSettings[id] then return TitanPluginSettings[id][var] end
end
function TitanSetVar(id, var, value)
  if id and var and TitanPluginSettings and TitanPluginSettings[id] then
    if value then TitanPluginSettings[id][var] = value else TitanPluginSettings[id][var] = false end
  end
end
function TitanAllGetVar(var) if TitanAll[var] == false then return nil end return TitanAll[var] end
function TitanPluginDebug(id, msg) CHAT[#CHAT + 1] = "<" .. tostring(id) .. "> " .. tostring(msg) end
local function Encode(hex, text) return "|cff" .. hex .. tostring(text) .. "|r" end
function TitanUtils_GetRedText(t) return Encode("ff2020", t) end
function TitanUtils_GetGoldText(t) return Encode("f2e699", t) end
function TitanUtils_GetGreenText(t) return Encode("19ff19", t) end
function TitanUtils_GetNormalText(t) return Encode("ffd200", t) end
function TitanUtils_GetHighlightText(t) return Encode("ffffff", t) end
function TitanUtils_GetColoredText(text, color)
  if color and text then
    return Encode(format("%02x", color.r * 255) .. format("%02x", color.g * 255) .. format("%02x", color.b * 255), text)
  elseif text then return tostring(text) end
  return ""
end
function TitanPanelButton_UpdateButton(id)
  local reg = TitanPanelReputationButton and TitanPanelReputationButton.registry
  if PEW_DONE and reg then BUTTON_RENDERS[#BUTTON_RENDERS + 1] = reg.buttonTextFunction(id) end
end
function TitanPanelButton_UpdateTooltip() end
function TitanPanelButton_OnLoad() end
function TitanPanelButton_OnClick() end
local function Node(kind, label) return { kind = kind, label = label, children = {} } end
local function Add(owner, n) owner.children[#owner.children + 1] = n; return n end
Titan_Menu = {}
function Titan_Menu.AddDivider(o) return Add(o, Node("divider")) end
function Titan_Menu.AddButton(o, label) return Add(o, Node("button", label)) end
function Titan_Menu.AddSelector(o, id, label, opt)
  local n = Add(o, Node("selector", label))
  n.isSelected = function() return TitanGetVar(id, opt) end
  n.setSelected = function() TitanSetVar(id, opt, not TitanGetVar(id, opt)); TitanPanelButton_UpdateButton(id) end
  return n
end
function Titan_Menu.AddSelectorGeneric(o, label, isSelected, setSelected)
  local n = Add(o, Node("check", label)); n.isSelected = isSelected; n.setSelected = setSelected; return n
end
function Titan_Menu.AddSelectorList(o, id, label, opt, list, sel_func, ...)
  local params = ...
  Titan_Menu.AddDivider(o)
  for _, item in ipairs(list) do
    local n = Add(o, Node("radio", item[1]))
    n.isSelected = function() return TitanGetVar(id, opt) == item[2] end
    n.setSelected = function()
      TitanSetVar(id, opt, item[2]); if sel_func then sel_func(params) end; TitanPanelButton_UpdateButton(id)
    end
  end
end
function Titan_Menu.AddCommand(o, id, label, fn, ...)
  local params = ...
  local n = Add(o, Node("command", label)); n.setSelected = function() fn(params) end; return n
end

-- Timers run when the driver flushes them, at the current NOW (keeps both trees' clocks equal)
TIMERS = {}
C_Timer = { After = function(delay, fn) TIMERS[#TIMERS + 1] = fn end }
function FLUSH_TIMERS()
  while #TIMERS > 0 do
    local fn = table.remove(TIMERS, 1)
    local ok, err = pcall(fn)
    if not ok then ERRORS[#ERRORS + 1] = "timer: " .. tostring(err) end
  end
end

-- Reputation data: rows in Blizzard display order, values absolute like the client API. As in the
-- client, rows under a collapsed header (or hidden by a list filter) are not listed by index but
-- can still be looked up by ID. SCANS counts list scans (GetNumFactions calls).
FACTIONS, PARAGON, MAJOR, FRIEND, SCANS = {}, {}, {}, {}, 0
local function Visible()
  local rows, rootCollapsed, nestedCollapsed = {}, false, false
  for _, f in ipairs(FACTIONS) do
    if f.hidden then
      -- filtered out of the list
    elseif f.isHeader and not f.isChild then
      rows[#rows + 1] = f
      rootCollapsed, nestedCollapsed = f.isCollapsed or false, false
    elseif not rootCollapsed then
      if f.isHeader then
        rows[#rows + 1] = f
        nestedCollapsed = f.isCollapsed or false
      elseif f.isChild then
        if not nestedCollapsed then rows[#rows + 1] = f end
      else
        nestedCollapsed = false
        rows[#rows + 1] = f
      end
    end
  end
  return rows
end
local function ById(id) for _, f in ipairs(FACTIONS) do if f.id == id then return f end end end
local function FactionData(f)
  if not f then return nil end
  return { name = f.name, description = "", reaction = f.reaction, currentReactionThreshold = f.cur,
    nextReactionThreshold = f.next, currentStanding = f.standing, atWarWith = false, canToggleAtWar = false,
    isHeader = f.isHeader or false, isCollapsed = f.isCollapsed or false, isHeaderWithRep = f.hasRep or false,
    isWatched = false, isChild = f.isChild or false, factionID = f.id, hasBonusRepGain = false,
    canSetInactive = true, isAccountWide = false }
end
local function FactionInfo(f)
  if not f then return nil end
  return f.name, "", f.reaction, f.cur, f.next, f.standing, false, false, f.isHeader or false,
    f.isCollapsed or false, f.hasRep or false, false, f.isChild or false, f.id, false, true
end
C_Reputation = {
  GetNumFactions = function() SCANS = SCANS + 1; return #Visible() end,
  GetFactionDataByIndex = function(i) return FactionData(Visible()[i]) end,
  GetFactionDataByID = function(id) return FactionData(ById(id)) end,
  IsFactionActive = function(i) local f = Visible()[i]; return f ~= nil and not f.inactive end,
  IsFactionParagon = function(id) return PARAGON[id] ~= nil end,
  GetFactionParagonInfo = function(id)
    local p = PARAGON[id]; if not p then return nil end
    return p.current, p.threshold, 0, p.pending, p.tooLow
  end,
  IsMajorFaction = function(id) return MAJOR[id] ~= nil end,
}
C_MajorFactions = {
  GetMajorFactionData = function(id)
    local m = MAJOR[id]; if not m then return nil end
    return { renownLevel = m.level, renownReputationEarned = m.earned, renownLevelThreshold = m.threshold }
  end,
  HasMaximumRenown = function(id) return MAJOR[id] and MAJOR[id].max or false end,
}
C_GossipInfo = { GetFriendshipReputation = function(id)
  local fr = FRIEND[id]
  if not fr then return { friendshipFactionID = 0, standing = 0, maxRep = 0, reaction = "", reactionThreshold = 0, text = "", texture = 0, reversedColor = false } end
  return { friendshipFactionID = id, standing = fr.standing, maxRep = 0, reaction = fr.reaction, reactionThreshold = fr.threshold,
    nextThreshold = fr.nextThreshold, text = "", texture = 0, reversedColor = false }
end }
function GetNumFactions() SCANS = SCANS + 1; return #Visible() end
function GetFactionInfo(i) return FactionInfo(Visible()[i]) end
function GetFactionInfoByID(id) return FactionInfo(ById(id)) end
function IsFactionInactive(i) local f = Visible()[i]; return f ~= nil and f.inactive or false end
-- Each client only has its own API: retail removed the globals in 11.0, Classic lacks the newer ones
if MODE == "retail" then
  GetNumFactions, GetFactionInfo, GetFactionInfoByID, IsFactionInactive = nil, nil, nil, nil
else
  C_Reputation.GetNumFactions, C_Reputation.GetFactionDataByIndex = nil, nil
  C_Reputation.GetFactionDataByID, C_Reputation.IsFactionActive = nil, nil
  C_MajorFactions = nil
end

-- Driver helpers
function FIRE(event, ...)
  local ok, err = pcall(TitanPanelReputationButton_OnEvent, event, ...)
  if not ok then ERRORS[#ERRORS + 1] = event .. ": " .. tostring(err) end
end
-- Titan's profile load at PLAYER_ENTERING_WORLD (TitanVariables_SyncRegisterSavedVariables): missing
-- settings get the registry default, settings the registry does not declare are dropped.
function SIM_PEW(saved)
  local reg = TitanPanelReputationButton.registry
  local s = saved or {}
  for k, v in pairs(reg.savedVariables) do if s[k] == nil then s[k] = v end end
  for k in pairs(s) do if reg.savedVariables[k] == nil then s[k] = nil end end
  TitanPluginSettings = { [reg.id] = s }
  PEW_DONE = true
end
function SET(var, value) TitanSetVar("Reputation", var, value) end
function GET(var) return TitanGetVar("Reputation", var) end
function BUTTON() local ok, r = pcall(TitanPanelReputationButton.registry.buttonTextFunction, "Reputation"); return ok and r or ("ERR " .. tostring(r)) end
function TOOLTIP() local ok, r = pcall(TitanPanelReputationButton.registry.tooltipTextFunction); return ok and r or ("ERR " .. tostring(r)) end
local function Plain(s) return (tostring(s or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")) end
function MENU()
  local root = Node("root")
  local ok, err = pcall(TitanPanelReputationButton.registry.menuContextFunction, TitanPanelReputationButton, root)
  if not ok then ERRORS[#ERRORS + 1] = "menu: " .. tostring(err) end
  return root
end
function MENU_DUMP(node, depth, out)
  out = out or {}; depth = depth or 0
  for _, n in ipairs(node.children) do
    local sel = ""
    if n.isSelected then local ok, v = pcall(n.isSelected); sel = ok and (v and " [x]" or " [ ]") or " [ERR]" end
    out[#out + 1] = string.rep("  ", depth) .. n.kind .. ": " .. tostring(n.label) .. sel
    MENU_DUMP(n, depth + 1, out)
  end
  return table.concat(out, "\n")
end
function CLICK(path)
  local node = MENU()
  for _, want in ipairs(path) do
    local found
    for _, n in ipairs(node.children) do
      if n.label and Plain(n.label) == want then found = n; break end
    end
    if not found then ERRORS[#ERRORS + 1] = "click: no menu entry '" .. want .. "'"; return end
    node = found
  end
  local ok, err = pcall(node.setSelected)
  if not ok then ERRORS[#ERRORS + 1] = "click " .. table.concat(path, " > ") .. ": " .. tostring(err) end
end
function SNAPSHOT_VARS()
  local out = {}
  for _, var in ipairs({ "FactionHeaders", "FactionShowOverrides", "HeaderSelfOverrides" }) do
    local v = GET(var)
    local parts = {}
    if type(v) == "table" then
      local keys = {}
      for k in pairs(v) do keys[#keys + 1] = tostring(k) end
      table.sort(keys)
      for _, k in ipairs(keys) do
        local val = v[k] ; if type(val) == "string" then parts[#parts + 1] = val
        elseif type(val) == "table" then local inner = {} for _, x in ipairs(val) do inner[#inner+1] = x end parts[#parts + 1] = k .. "=[" .. table.concat(inner, ",") .. "]"
        else parts[#parts + 1] = k end
      end
    end
    out[#out + 1] = var .. ": " .. table.concat(parts, " | ")
  end
  return table.concat(out, "\n")
end
function RTS()
  local keys = {}
  for k in pairs(NS.RTS) do keys[#keys + 1] = k end
  table.sort(keys)
  local parts = {}
  for _, k in ipairs(keys) do parts[#parts + 1] = k .. "=" .. tostring(NS.RTS[k]) end
  return table.concat(parts, ", ")
end
"""

# Raw client values per standing: (reaction, currentReactionThreshold, nextReactionThreshold)
LADDER = {1: (-42000, -6000), 2: (-6000, -3000), 3: (-3000, 0), 4: (0, 3000), 5: (3000, 9000),
          6: (9000, 21000), 7: (21000, 42000), 8: (42000, 43000)}


def row(name, fid, reaction=4, progress=0, header=False, child=False, rep=False, inactive=False):
    lo, hi = LADDER[reaction]
    return {"name": name, "id": fid, "reaction": reaction, "cur": lo, "next": hi, "standing": lo + progress,
            "isHeader": header, "isChild": child, "hasRep": rep, "inactive": inactive}


def retail_rows():
    return [
        row("The War Within", 9001, header=True),
        row("Council of Dornogal", 2590, 5),
        row("The Severed Threads", 2600, 5, header=True, child=True, rep=True),
        row("The General", 2605, 5, child=True),
        row("The Vizier", 2607, 5, child=True),
        row("Hallowfall Arathi", 2570, 8, 999),
        row("Dragonflight", 9002, header=True),
        row("Valdrakken Accord", 2510, 8, 999),
        row("Sabellian", 2518, 5, child=False),
        row("Classic", 9003, header=True),
        row("Stormwind", 72, 8, 999),
        row("Steamwheedle Cartel", 169, 4, header=True, child=True),
        row("Booty Bay", 21, 5, 1000, child=True),
        row("Gadgetzan", 369, 6, 1000, child=True),
        row("Bloodsail Buccaneers", 87, 2, 500),
        row("The Burning Crusade", 9004, header=True),
        row("Shattrath City", 9005, 4, header=True, child=True),
        row("The Aldor", 932, 5, 2000, child=True),
        row("The Scryers", 934, 4, 2500, child=True),
        row("Cenarion Expedition", 942, 4, 100),
        row("Inactive", 9006, header=True),
        row("Old Faction", 999, 4, 0, inactive=True),
    ]


def retail_extras():
    return {
        "MAJOR": {2590: dict(level=12, earned=2400, threshold=2500, max=False),
                  2600: dict(level=5, earned=100, threshold=2500, max=False),
                  2570: dict(level=25, earned=2500, threshold=2500, max=True),
                  2510: dict(level=30, earned=2500, threshold=2500, max=True)},
        "PARAGON": {2570: dict(current=10500, threshold=10000, pending=True, tooLow=False)},
        "FRIEND": {2605: dict(standing=9000, threshold=8400, nextThreshold=12600, reaction="Comrade"),
                   2607: dict(standing=42000, threshold=42000, nextThreshold=None, reaction="Exalted Ally"),
                   2518: dict(standing=21000, threshold=16800, nextThreshold=33600, reaction="Ally")},
    }


def declared_saved_variables(tree):
    """Globals the TOC declares as SavedVariables / SavedVariablesPerCharacter."""
    toc = next(tree.glob("*.toc")).read_text(encoding="utf-8-sig")
    names = []
    for value in re.findall(r"^##\s*SavedVariables(?:PerCharacter)?:\s*(.+)$", toc, re.MULTILINE):
        names += [n.strip() for n in value.split(",") if n.strip()]
    return names


class Env:
    """One game session: load the addon, then drive it. `saved` carries the previous session's
    saved variables (see `relog`)."""

    def __init__(self, tree, mode="retail", rows=None, extras=None, locale="enUS", saved=None):
        self.tree, self.mode, self.locale, self.saved_state = tree, mode, locale, saved or {}
        self.lua = lupa.LuaRuntime(unpack_returned_tuples=True)
        g = self.lua.globals()
        g.MODE, g.LOCALE = mode, locale
        self.lua.execute(STUBS)
        self.set_data(rows if rows is not None else retail_rows(), extras if extras is not None else retail_extras())
        ns = self.lua.table()
        g.NS = ns
        loader = self.lua.eval(
            "function(code, name, ns) "
            "  local function safe(e) return (tostring(e):gsub('[\\128-\\255]', function(c) return string.format('\\\\%d', c:byte()) end)) end "
            "  local f, err = loadstring(code, '@' .. name); if not f then return 'compile: ' .. safe(err) end "
            "  local ok, rerr = pcall(f, 'TitanReputation', ns); if not ok then return 'runtime: ' .. safe(rerr) end "
            "end")
        for rel in load_order(tree):
            code = locate(tree, rel).read_bytes()
            if code.startswith(b"\xef\xbb\xbf"):  # WoW's loader skips a UTF-8 BOM, loadstring does not
                code = code[3:]
            failure = loader(code, rel, ns)
            if failure:
                raise RuntimeError(f"{rel}: {failure}")
        # main.xml: create the button and run its OnLoad script
        self.lua.execute("TitanPanelReputationButton = CreateFrame('Button', 'TitanPanelReputationButton'); "
                         "TitanPanelReputationButton_OnLoad(TitanPanelReputationButton); "
                         "TitanPanelButton_OnLoad(TitanPanelReputationButton)")

    def set_data(self, rows, extras):
        """Replace the client's reputation data (rows may carry isCollapsed / hidden)."""
        self.rows, self.extras = rows, extras
        g = self.lua.globals()
        g.FACTIONS = self.lua.table_from([self.lua.table_from(r) for r in rows])
        for key in ("MAJOR", "PARAGON", "FRIEND"):
            t = self.lua.table()
            for fid, data in extras.get(key, {}).items():
                t[fid] = self.lua.table_from({k: v for k, v in data.items() if v is not None})
            g[key] = t

    def edit_rows(self, **changes_by_name):
        """Change rows by faction name, e.g. edit_rows(**{"Classic": {"isCollapsed": True}})."""
        for r in self.rows:
            r.update(changes_by_name.get(r["name"], {}))
        self.set_data(self.rows, self.extras)

    def run(self, code):
        return self.lua.execute(code)

    def ev(self, expr):
        return self.lua.eval(expr)

    def to_lua(self, value):
        if isinstance(value, dict):
            t = self.lua.table()
            for k, v in value.items():
                t[k] = self.to_lua(v)
            return t
        return value

    def to_py(self, value):
        if lupa.lua_type(value) == "table":
            return {k: self.to_py(v) for k, v in value.items()}
        return value

    def login(self, settings=None, scan_at=1003.0):
        """Saved variables load, ADDON_LOADED at t=1000, Titan's PLAYER_ENTERING_WORLD (plugin
        settings), first UPDATE_FACTION."""
        g = self.lua.globals()
        for name, value in self.saved_state.get("svs", {}).items():
            g[name] = self.to_lua(value)
        self.run("FIRE('ADDON_LOADED', 'TitanReputation')")
        plugin_settings = dict(self.saved_state.get("settings", {}))
        plugin_settings.update(settings or {})
        g.SIM_PEW(self.to_lua(plugin_settings))
        self.update(scan_at)

    def update(self, at):
        self.burst(at, 1)

    def burst(self, at, events):
        """`events` UPDATE_FACTION events at time `at`, then whatever timers they scheduled."""
        self.run(f"NOW = {at}" + "; FIRE('UPDATE_FACTION')" * events + "; FLUSH_TIMERS()")

    def saved(self):
        """What WoW would write to disk at logout: plugin settings and declared saved variables."""
        g = self.lua.globals()
        svs = {name: self.to_py(g[name]) for name in declared_saved_variables(self.tree) if g[name] is not None}
        return {"settings": self.to_py(g.TitanPluginSettings["Reputation"]), "svs": svs}

    def relog(self, rows=None, extras=None):
        """A new session of the same character, carrying over the saved variables."""
        return Env(self.tree, self.mode, copy.deepcopy(rows if rows is not None else self.rows),
                   copy.deepcopy(extras if extras is not None else self.extras), self.locale, saved=self.saved())

    def errors(self):
        return list(self.lua.globals().ERRORS.values())

    def chat(self):
        return [re.sub(r"\|c[0-9a-f]{8}|\|r", "", m) for m in self.lua.globals().CHAT.values()]

    def alerts(self):
        return list(self.lua.globals().ALERTS.values())


def plain(s):
    return re.sub(r"\|c[0-9a-f]{8}|\|r", "", s or "")


# ---------------------------------------------------------------------------- scenarios

def sc_render(tree, color=1):
    e = Env(tree)
    e.login({"WatchedFaction": "The Aldor", "ColorValue": color})
    return {"button": e.ev("BUTTON()"), "tooltip": e.ev("TOOLTIP()"),
            "menu": e.ev("MENU_DUMP(MENU())"), "errors": e.errors()}


def sc_render_era(tree):
    rows = [r for r in retail_rows() if r["id"] in (9003, 72, 169, 21, 369, 87, 9006, 999)]
    e = Env(tree, mode="era", rows=rows, extras={})
    e.login({"WatchedFaction": "Booty Bay"})
    return {"button": e.ev("BUTTON()"), "tooltip": e.ev("TOOLTIP()"), "menu": e.ev("MENU_DUMP(MENU())"),
            "errors": e.errors()}


def sc_visibility(tree):
    e = Env(tree)
    e.login({"WatchedFaction": "The Aldor"})
    steps = [
        ["Classic"],                                           # hide whole branch
        ["Classic", "Steamwheedle Cartel", "Booty Bay - Friendly"],  # re-show one child under hidden root
        ["The War Within", "The Severed Threads", "The Severed Threads - 5"],  # header-self toggle (hide)
        ["The Burning Crusade", "Shattrath City"],             # hide nested branch
        ["The War Within", "The Severed Threads", "The Severed Threads - 5"],  # header-self toggle (show)
        ["Classic"],                                           # show branch again
        ["The Burning Crusade", "Shattrath City", "The Scryers - Neutral"],
    ]
    out = []
    for path in steps:
        e.run("CLICK({" + ",".join(json.dumps(p) for p in path) + "})")
        out.append(" > ".join(path) + "\n" + e.ev("SNAPSHOT_VARS()") + "\nTOOLTIP:\n" + plain(e.ev("TOOLTIP()")) +
                   "\nMENU:\n" + plain(e.ev("MENU_DUMP(MENU())")))
    return {"steps": out, "errors": e.errors()}


def sc_gain_and_loss(tree):
    e = Env(tree)
    e.login({"WatchedFaction": "Stormwind", "AutoChange": True})
    rows = retail_rows()
    for r in rows:
        if r["name"] == "The Aldor":
            r["standing"] += 250        # +250 (Friendly 2000 -> 2250)
        if r["name"] == "The Scryers":
            r["standing"] -= 275        # -275 (Neutral 2500 -> 2225)
    e.set_data(rows, retail_extras())
    e.update(1010.0)
    after_change = {"watched": e.ev("GET('WatchedFaction')"), "rts": e.ev("RTS()"), "button": plain(e.ev("BUTTON()"))}
    e.update(1010.5)                     # follow-up event, nothing changed
    after_followup = e.ev("GET('WatchedFaction')")
    e.run("SET('WatchedFaction', 'Stormwind')")   # player picks a faction by hand
    e.update(1020.0)                     # unrelated UPDATE_FACTION (e.g. header collapsed)
    return {"after change": after_change, "after follow-up event": after_followup,
            "after manual pick + unrelated event": e.ev("GET('WatchedFaction')"), "errors": e.errors()}


def sc_renown_wrap(tree):
    e = Env(tree)
    e.login({"WatchedFaction": "Council of Dornogal"})
    extras = retail_extras()
    extras["MAJOR"][2590] = dict(level=13, earned=150, threshold=2500, max=False)   # 2400/2500 +250 -> L13 150/2500
    e.set_data(retail_rows(), extras)
    e.update(1010.0)
    return {"rts": e.ev("RTS()"), "button": plain(e.ev("BUTTON()")), "errors": e.errors()}


def sc_paragon_collect(tree):
    e = Env(tree)
    e.login({"WatchedFaction": "Hallowfall Arathi", "ShowSessionSummaryTTL": True})
    extras = retail_extras()
    extras["PARAGON"][2570] = dict(current=10500, threshold=10000, pending=False, tooLow=False)   # reward collected
    e.set_data(retail_rows(), extras)
    e.update(1010.0)
    return {"rts": e.ev("RTS()"), "button": plain(e.ev("BUTTON()")), "errors": e.errors()}


def sc_ttl_over_cap(tree):
    e = Env(tree)
    e.login({"WatchedFaction": "Hallowfall Arathi", "ShowSessionSummaryTTL": True,
             "ShowTipSessionSummaryTTL": True})
    extras = retail_extras()
    extras["PARAGON"][2570] = dict(current=10900, threshold=10000, pending=True, tooLow=False)  # +400 while pending
    e.set_data(retail_rows(), extras)
    e.update(1600.0)
    tip = plain(e.ev("TOOLTIP()"))
    return {"rts": e.ev("RTS()"), "button": plain(e.ev("BUTTON()")),
            "tooltip session line": [l for l in tip.splitlines() if "Hallowfall" in l and "/h" in l],
            "errors": e.errors()}


def sc_login_toast(tree):
    rows = [row("Classic", 9003, header=True), row("Stormwind", 72, 8, 999), row("Ironforge", 47, 7, 5000),
            row("Ravenholdt", 349, 4, 1200)]                       # the only Neutral faction with progress
    e = Env(tree, rows=rows, extras={})
    e.login({"WatchedFaction": "Stormwind", "ShowAnnounceFrame": True}, scan_at=1003.0)
    at_login = e.alerts()
    rows.append(row("Wildhammer Clan", 1174, 4, 50))              # genuinely discovered later
    e.set_data(rows, {})
    e.update(1100.0)
    return {"toasts after login": at_login, "toasts after discovery": e.alerts()[len(at_login):],
            "errors": e.errors()}


def sc_mop_friendship(tree, show_friends):
    rows = [row("Pandaria", 9010, header=True), row("The Tillers", 1272, 6, 3000),
            row("Jogu the Drunk", 1273, 5, 1500, child=False), row("Golden Lotus", 1269, 7, 100)]
    extras = {"FRIEND": {1273: dict(standing=9000, threshold=8400, nextThreshold=16800, reaction="Buddy")}}
    e = Env(tree, mode="mop", rows=rows, extras=extras)
    e.login({"WatchedFaction": "Jogu the Drunk", "ShowFriendsOnBar": show_friends})
    tip = plain(e.ev("TOOLTIP()"))
    return {"button": plain(e.ev("BUTTON()")), "tooltip row": [l for l in tip.splitlines() if "Jogu" in l],
            "errors": e.errors()}


def sc_color_after_reload(tree, color):
    e = Env(tree)
    e.login({"WatchedFaction": "The Aldor", "ColorValue": color})
    return {"button": e.ev("BUTTON()"), "errors": e.errors()}


def sc_tooltip_scale(tree):
    e = Env(tree)
    e.login({"WatchedFaction": "The Aldor"})
    for _ in range(9):
        e.run('CLICK({"Tooltip Options", "Tooltip Scale (" .. math.floor(GET("ToolTipScale") * 100 + 0.5) .. "%)", "- Decrease Tooltip Scale"})')
    low = e.ev("GET('ToolTipScale')")
    for _ in range(12):
        e.run('CLICK({"Tooltip Options", "Tooltip Scale (" .. math.floor(GET("ToolTipScale") * 100 + 0.5) .. "%)", "+ Increase Tooltip Scale"})')
    return {"min reached": repr(low), "max reached": repr(e.ev("GET('ToolTipScale')")), "errors": e.errors()}


def sc_locale_de(tree):
    e = Env(tree, locale="deDE")
    e.login({"WatchedFaction": "The Aldor"})
    return {"chat": e.chat(), "tooltip head": plain(e.ev("TOOLTIP()")).splitlines()[-1], "errors": e.errors()}


def sc_standing_changes(tree):
    e = Env(tree)
    e.login({"WatchedFaction": "Booty Bay", "ShowAnnounceFrame": True, "AutoChange": True})
    rows = retail_rows()
    for r in rows:
        if r["name"] == "Booty Bay":       # Friendly 1000/6000 -> Revered 500 (skips Honored)
            r["reaction"], r["cur"], r["next"], r["standing"] = 7, 21000, 42000, 21500
        if r["name"] == "Gadgetzan":       # Honored 1000/12000 -> Friendly 5900/6000
            r["reaction"], r["cur"], r["next"], r["standing"] = 5, 3000, 9000, 8900
    e.set_data(rows, retail_extras())
    e.update(1010.0)
    return {"toasts": e.alerts(), "rts": e.ev("RTS()"), "watched": e.ev("GET('WatchedFaction')"),
            "errors": e.errors()}


def sc_color_menu_click(tree):
    e = Env(tree)
    e.login({"WatchedFaction": "The Aldor"})
    e.run('CLICK({"Color Options", "Armory"})')
    armory = e.ev("BUTTON()")
    e.run('CLICK({"Color Options", "Basic"})')
    return {"armory": armory, "basic": e.ev("BUTTON()"), "menu": plain(e.ev("MENU_DUMP(MENU())")),
            "errors": e.errors()}


def sc_debug_toast(tree):
    e = Env(tree)
    e.login({"WatchedFaction": "The Aldor"})
    e.run("NS:SetDebugMode(true, true)")
    e.run("for _, d in ipairs({'The Aldor', 'Council of Dornogal', 'The Vizier'}) do "
          "NS:FactionDetailsProvider(function(x) if x.name == d then NS:TriggerDebugStandingToast(x) end end) end")
    return {"toasts": e.alerts(), "errors": e.errors()}


SCENARIOS = {
    "standing up/down announcements": sc_standing_changes,
    "color option click": sc_color_menu_click,
    "debug toast": sc_debug_toast,
    "render (default colors)": lambda t: sc_render(t, 1),
    "render (Classic Era)": sc_render_era,
    "visibility clicks": sc_visibility,
    "Aldor gain + Scryers loss, AutoChange": sc_gain_and_loss,
    "renown level-up wrap": sc_renown_wrap,
    "paragon reward collected": sc_paragon_collect,
    "TTL above cap (reward pending)": sc_ttl_over_cap,
    "new-faction toast on login": sc_login_toast,
    "MoP Classic friendship, ShowFriendsOnBar=on": lambda t: sc_mop_friendship(t, True),
    "MoP Classic friendship, ShowFriendsOnBar=off": lambda t: sc_mop_friendship(t, False),
    "color theme Armory after reload": lambda t: sc_color_after_reload(t, 2),
    "color theme Basic after reload": lambda t: sc_color_after_reload(t, 3),
    "tooltip scale bounds": sc_tooltip_scale,
    "deDE locale": sc_locale_de,
}

def snapshot(ref, dest):
    """Extract the tracked files of git `ref` into `dest`."""
    tar = subprocess.run(["git", "-C", str(REPO), "archive", "--format=tar", ref],
                         check=True, capture_output=True).stdout
    with tarfile.open(fileobj=io.BytesIO(tar)) as archive:
        archive.extractall(dest, filter="data")
    return pathlib.Path(dest)


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--base", default="HEAD", help="git ref to compare the working tree against")
    parser.add_argument("scenarios", nargs="*", metavar="SCENARIO", help="run only these (default: all)")
    args = parser.parse_args()
    unknown = [s for s in args.scenarios if s not in SCENARIOS]
    if unknown:
        parser.error(f"unknown scenario(s) {unknown}; available: {list(SCENARIOS)}")
    sys.stdout.reconfigure(encoding="utf-8")

    work_errors = False
    with tempfile.TemporaryDirectory() as tmp:
        trees = {args.base: snapshot(args.base, tmp), "WORK": REPO}
        for name in args.scenarios or SCENARIOS:
            res = {label: SCENARIOS[name](tree) for label, tree in trees.items()}
            work_errors = work_errors or bool(res["WORK"].get("errors"))
            same = json.dumps(res[args.base], sort_keys=True, default=str) == json.dumps(res["WORK"], sort_keys=True, default=str)
            print(f"=== {name}: {'IDENTICAL' if same else 'DIFFERS'}")
            if not same:
                for label in trees:
                    print(f"--- {label}")
                    for k, v in res[label].items():
                        if isinstance(v, str) and "\n" in v:
                            v = "\n      " + v.replace("\n", "\n      ")
                        print(f"  {k}: {v}")
            elif res["WORK"].get("errors"):
                print("  errors (both):", res["WORK"]["errors"])
    return 1 if work_errors else 0


if __name__ == "__main__":
    sys.exit(main())

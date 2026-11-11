-- RE9 Insanity Autosave
-- Enables the game's checkpoint autosaves on Insanity (the highest difficulty) in Resident Evil Requiem.
-- Requires REFramework.
-- Author: syk0x01
-- Version: 1.0.0
-- License: MIT
-- https://github.com/salmon111/re9-insanity-autosave
--
-- How it works:
--   Story checkpoint autosaves are run by
--     app.LevelFlowBehaviorTreeAction_FSM_AutoSaveAction.start
--     app.LevelFlowBehaviorTreeAction_FSM_BikeAutoSaveAction.start
--   Each one calls isFilterDifficulty(), which returns true only when the current
--   difficulty is in that checkpoint's difficulty list; otherwise the save is skipped.
--   This mod makes isFilterDifficulty() return true while you play on the selected
--   difficulties. The game itself picks the save slot (Insanity keeps its own autosave slot).

local cfg = {
    enable_auto_save = true,
    -- true : only on Insanity (GameDifficultyID ID0040)
    -- false: on every difficulty (also forces checkpoints that are authored for other difficulties only)
    insanity_only = true,
}

local cfg_path = "re9_insanity_autosave/config.json"
local INSANITY = "ID0040"

local function dump_cfg()
    json.dump_file(cfg_path, cfg)
end

-- json.load_file logs an error when the file does not exist yet (first launch), so check first.
local function cfg_exists()
    local ok, files = pcall(fs.glob, [[re9_insanity_autosave\\config\.json]])
    if not ok or type(files) ~= "table" then return true end   -- fs.glob unavailable: just try to load
    return #files > 0
end

local function load_cfg()
    if not cfg_exists() then
        dump_cfg()
        return
    end
    local loaded = json.load_file(cfg_path)
    if loaded == nil then
        dump_cfg()
        return
    end
    for k, v in pairs(loaded) do
        if cfg[k] ~= nil then cfg[k] = v end
    end
end

load_cfg()
re.on_config_save(dump_cfg)

local function current_difficulty()
    local name = nil
    pcall(function()
        local mgr = sdk.get_managed_singleton("app.GameDifficultyManager")
        if not mgr then return end
        local id = mgr:call("get_DifficultyID")
        if id ~= nil then name = tostring(id:call("ToString")) end
    end)
    return name
end

local function should_force()
    if not cfg.enable_auto_save then return false end
    if not cfg.insanity_only then return true end
    return current_difficulty() == INSANITY
end

local TRUE_PTR = sdk.to_ptr(true)
local stats = { forced = 0, hooked = {} }

local function hook_filter(type_name)
    local td = sdk.find_type_definition(type_name)
    local m = td and td:get_method("isFilterDifficulty")
    if not m then
        log.info("[re9_insanity_autosave] not found: " .. type_name .. ".isFilterDifficulty")
        return
    end
    sdk.hook(m, nil, function(retval)
        if sdk.to_int64(retval) % 2 == 1 then return retval end   -- the game already allows it
        local ok, force = pcall(should_force)
        if ok and force then
            stats.forced = stats.forced + 1
            log.info("[re9_insanity_autosave] autosave allowed (" .. type_name .. ")")
            return TRUE_PTR
        end
        return retval
    end)
    stats.hooked[#stats.hooked + 1] = type_name
end

hook_filter("app.LevelFlowBehaviorTreeAction_FSM_AutoSaveAction")
hook_filter("app.LevelFlowBehaviorTreeAction_FSM_BikeAutoSaveAction")

local function tooltip(text)
    if imgui.is_item_hovered() then imgui.set_tooltip(text) end
end

re.on_draw_ui(function()
    if imgui.tree_node("RE9 Insanity Autosave") then
        local changed, value = imgui.checkbox("Enable autosave", cfg.enable_auto_save)
        if changed then cfg.enable_auto_save = value; dump_cfg() end
        changed, value = imgui.checkbox("Insanity only", cfg.insanity_only)
        tooltip("On: force checkpoint autosaves only on Insanity.\nOff: force them on every difficulty.")
        if changed then cfg.insanity_only = value; dump_cfg() end
        imgui.text("Current difficulty: " .. tostring(current_difficulty()))
        imgui.text("Autosaves allowed by this mod: " .. tostring(stats.forced))
        imgui.text("Hooks: " .. tostring(#stats.hooked) .. "/2")
        imgui.tree_pop()
    end
end)

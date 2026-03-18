--[[

	«CENTERED COMMAND MENU AND RADIO MESSAGES v0.07»

	This EXPERIMENTAL hook patches some DCS UI files to relocate the command menu and radio messages
	containers to other position (usually to the center of the viewport).

	Passes the multiplayer integrity check.

	«BACKGROUND»

	I wrote this hook simply because I have a 57'' ultrawide monitor with a horizontal resolution of
	7680px, and having the command menu and radio messages at the extreme edges of my field of view
	forced me to constantly turn my head to the right and left like a fool to give commands or read
	messages, losing focus on what was happening in the middle.

	«INSTALLATION»

	Copy the content of the zip file to your "Saved Games\DCS\Scripts\Hooks" folder.

	«USAGE»

	This hook comes with a preconfigured configuration file (with sane defaults) to relocate the
	command menu and radio messages (usally to the center of the viewport as in the the attached
	screenshot), but which can still be customized to your preferences.

	Unfortunately, hooks are executed by DCS only AFTER the UI has been initialized, so each time
	you change the configuration file you need to run DCS twice: the first time for the hook to
	notice the changed parameters and modify the UI files according to the new configuration, and
	the second time for the new configuration to be loaded when DCS starts.

	This is annoying, but I think it is acceptable considering that after you have found your
	optimal configuration you will most likely not change it again.

	I am considering providing a graphical utility to edit and activate the configuration without
	having to launch DCS twice any time you change the config, but I am not sure if it is worth
	having an additional graphical tool on top of all the utilities you probably already use
	(mod managers, kneeboard builders ect etc). Let me know your thoughts on this.

	«CONFIGURATION OPTIONS»

	- defaultCommandMenu = false
		This boolean parameter controls whether to apply the custom configuration to the command menu
		or restore the default positioning

	- commandMenuOffset = 0
		Positioning of the left side of the command menu container relative to the vertical axis of the
		DCS window. A negative value indicates a left shift relative to the axis, a positive value a
		right shift relative to the axis. For example, an offset of 0 will align the left side of the
		menu container with the vertical axis.

	- defaultRadioMessages = false
		This boolean parameter controls whether to apply the custom configuration to the radio messages
		or restore the default positioning

	- radioMessagesOffset = -450
		Positioning of the left side of the radio messages container relative to the vertical axis of
		the DCS window. A negative value indicates a left shift relative to the axis, a positive value
		a right shift relative to the axis.

	- radioMessagesWidth = 400
		The size of the radio messages container.

	- defaultSystemMessages = false
		This boolean parameter controls whether to apply the custom configuration to the system/tutorial
		messages or restore the default positioning

	- systemMessagesOffset = -450
		Positioning of the left side of the system messages container relative to the vertical axis of
		the DCS window.

	- systemMessagesWidth = 400
		The size of the system messages container.

	«NOTICE»

	There are no checks for potential overlaps between the command menu containers and radio messages
	because I wouldn't know how to notify the user other than through an error in the log file, but I
	doubt many people read it.

	I should also warn you that I am a complete novice to both DCS and Lua programming and have not
	had a chance to test this script as extensively as I would have liked/needed to, so please report
	any problems or suggestions in the comments or via email to <annibale.x@gmail.com>.

	«NOTES»

	This hook automatically applies the patch after each DCS update or after any modification of the
	config file.

	«CHANGELOG»

	2026-03-18 v0.07 - Added the ability to center game messages, like tutorials (author - Racter)

	2024-06-15 v0.04 - Fixed typo error
	2024-06-13 v0.03 - Full rewrite to manage the position and size of the command menu and radio message containers via config file
	2024-06-08 v0.02 - Minor fix
	2024-06-08 v0.01 - First release

]] --

local DEBUG = true
local version = 0.07

local function dlog(str)
    if DEBUG then
        log.info("[CenterGaze] " .. str)
    end
end

local lfs = require("lfs")
local dcsd = lfs.currentdir()
local hook = debug.getinfo(1).source
local hdir = string.sub(hook, 1, -5)
local patch = {}
local target = {}
local cmo
local rmo
local rmw


local function file_exists(name)
    return lfs.attributes(name, "mode") == "file"
end

local function dir_exists(name)
    return lfs.attributes(name, "mode") == "directory"
end

local function files(id)
    local of = target[id]
    local dir = hdir .. "\\" .. id
    return of, dir .. ".bkp", dir .. ".t"
end

local function get_modification_time(id)
    local of = files(id)
    local mt = lfs.attributes(of, "modification")
    return mt
end

local function get_stored_modification_time(id)
    local _, _, tf = files(id)
    local mth = io.open(tf, "r")

    if mth then
        local mt = mth:read("*l")
        mth:close()
        return tonumber(mt)
    else
        return 0
    end
end

local function store_modification_time(id)
    local _, _, tf = files(id)
    local mt = get_modification_time(id)
    local mth = io.open(tf, "w")
    mth:write(mt)
    mth:close()
end

local function file_changed(id)
    return get_modification_time(id) ~= get_stored_modification_time(id)
end

local function remove_old_version()
    local path = hook:match("(.*\\)")

    if file_exists(path .. "CenteredCommandMenuHook.lua") then
        os.remove(path .. "CenteredCommandMenuHook.lua")
        os.remove(path .. "CenteredCommandMenuHook.t")
    end
end

local function undo_patch(id)
    local of, bf, tf = files(id)

    if not file_exists(bf) then return 0 end

    dlog("Removing " .. id .. " patch")

    local ofh = io.open(of, "w")
    local bfh = io.open(bf, "r")

    for line in bfh:lines() do
        ofh:write(line .. "\n")
    end

    bfh:close()
    ofh:close()
    os.remove(bf)
    os.remove(tf)
end

local function apply_patch(id)
    local of, bf, tf = files(id)

    dlog("Applying " .. id .. " patch")

    local fn = patch[id].fn
    local insert = true
    local done = false
    local fixed = false
    local lines = {}
    local bfh = io.open(bf, "w")
    local ofh = io.open(of, "r")

    for line in ofh:lines() do
        if id == "cmd" and not fixed and string.match(line, "^[ \t]+%-%-return%s280%s%*%sfontScale") then
            line = "\tif true then return 280 * fontScale end"
            fixed = true
        end

        bfh:write(line .. "\n")

        if fn then
            if not done then
                if string.match(line, "^" .. fn) then
                    insert = false
                    table.insert(lines, fn .. "()")
                    for _, l in ipairs(patch[id].fc) do
                        table.insert(lines, l)
                    end
                elseif not insert and string.match(line, "^end") then
                    insert = true
                    done = true
                end
            end
            if insert then table.insert(lines, line) end
        else
            local matched = false

            if type(patch[id].sw) == "table" then
                for i, search_str in ipairs(patch[id].sw) do
                    if string.find(line, search_str) then
                        table.insert(lines, patch[id].nl[i])
                        matched = true
                        break
                    end
                end
            end

            if not matched then table.insert(lines, line) end
        end
    end

    bfh:close()
    ofh:close()

    ofh = io.open(of, "w")
    for _, line in ipairs(lines) do
        ofh:write(line .. "\n")
    end
    ofh:close()

    store_modification_time(id)
end

local function center_gaze_hook()
    remove_old_version()

    if not dir_exists(hdir) then lfs.mkdir(hdir) end

    local cfgf = hdir .. ".cfg"

    if not file_exists(cfgf) then
        local cfgh = io.open(cfgf, "w")
        cfgh:write("-- Command Menu config --\n")
        cfgh:write("defaultCommandMenu = false\n")
        cfgh:write("commandMenuOffset  = 0\n\n")
        cfgh:write("-- Radio Messages --\n")
        cfgh:write("defaultRadioMessages = false\n")
        cfgh:write("radioMessagesOffset  = -450\n")
        cfgh:write("radioMessagesWidth  = 400\n\n")
        cfgh:write("-- Tutorial / System Messages --\n")
        cfgh:write("defaultSystemMessages = false\n")
        cfgh:write("systemMessagesOffset  = -450\n")
        cfgh:write("systemMessagesWidth  = 400\n")
        cfgh:close()
    end

    local f, err = loadfile(cfgf, "t", configEnv)
    if f then f() else return end

    local dsm = defaultSystemMessages
    if dsm == nil then dsm = false end

    local smo = systemMessagesOffset or -450
    local smw = systemMessagesWidth or 400

    rmo = radioMessagesOffset or -450
    rmw = radioMessagesWidth or 400
    cmo = -1 * (commandMenuOffset or 0)

    target = {
        cmd = dcsd .. "Scripts\\UI\\RadioCommandDialogPanel\\CommandMenu.lua",
        msg = dcsd .. "Scripts\\UI\\gameMessages.lua",
        cfg = cfgf
    }

    patch = {
        cmd = {
            df = defaultCommandMenu,
            fn = "function getMenuWidth",
            fc = {
                "\tlocal fontScale = getFontScale()",
                "\tlocal screenWidth, screenHeigt = Gui.GetWindowSize()",
                "\treturn ( screenWidth / 2 ) + " .. cmo
            }
        },
        msg = {
            df = defaultRadioMessages and dsm,
            sw = {},
            nl = {}
        }
    }

    if not defaultRadioMessages then
        table.insert(patch.msg.sw, "autoScrollTextRadio:setBounds%(")
        table.insert(patch.msg.nl,
            "\tautoScrollTextRadio:setBounds( (main_w/2) + " .. rmo .. ", 40, " .. rmw .. ", main_h - 40)")
    end

    if not dsm then
        table.insert(patch.msg.sw, "autoScrollTextTrig:setBounds%(")
        table.insert(patch.msg.nl,
            "\tautoScrollTextTrig:setBounds( (main_w/2) + " .. smo .. ", 100, " .. smw .. ", main_h - 100)")
    end

    if file_changed("cfg") then
        for id, _ in pairs(patch) do
            local of, bf, tf = files(id)
            if file_exists(bf) then undo_patch(id) end
            if not patch[id].df then apply_patch(id) end
        end
        store_modification_time("cfg")
    else
        for id, _ in pairs(patch) do
            if file_changed(id) then
                if not patch[id].df then apply_patch(id) end
            end
        end
    end
end

local status, err = pcall(center_gaze_hook)
if not status then log.error("[CenterGaze] Error: " .. tostring(err)) end

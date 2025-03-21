-- Multiplayer Check

mp_marked = {}
local incomp = {}

local text_x, text_y
local box_x, box_y, box_w, box_h
local initial_fadein
local ui_hook = 0     -- Have the hook automatically stop itself (so it doesn't make unnecessary checks later)


-- MP check all RMT-dependent mods for
mods.on_all_mods_loaded(function()
    for _, m_id in ipairs(mods.loading_order) do
        local m = mods[m_id]

        -- Check if mod has RMT as a dependency
        if Helper.table_has(
            m._PLUGIN.dependencies_no_version_number,
            "RoRRModdingToolkit-RoRR_Modding_Toolkit"
        ) then

            -- Add to incompatibility list if not marked
            if not Helper.table_has(mp_marked, m["!guid"]) then
                local split = GM.string_split(m_id, "-")
                table.insert(incomp, {split[1], split[2]})
            end

        end
    end
end)


gm.post_code_execute("gml_Object_oStartMenu_Draw_73", function(self, other, code, result, flags)
    if #incomp <= 0 then return end

    -- oStartMenu seems very prone to deleting itself from
    -- all means of finding it except by looping through this
    local startMenu = nil
    for i = 1, #gm.CInstance.instances_active do
        local inst = gm.CInstance.instances_active[i]
        if inst.object_index == gm.constants.oStartMenu then
            startMenu = Instance.wrap(inst)
            break
        end
    end

    -- Disable Online button
    local opacity = 1.0
    if startMenu and startMenu:exists() then
        startMenu.menu[3].disabled = true
        opacity = 1.0 - startMenu.menu_transition
    end

    -- Initial opacity fade-in on first title screen load (minor but looks better)
    if initial_fadein then
        if initial_fadein < 1.0 then
            initial_fadein = initial_fadein + 1/15
            opacity = Helper.ease_in(initial_fadein)
        end
    end

    ui_hook = 10
    if (not text_x) or (not text_y) then return end

    -- "x incompatible mod(s)" text
    gm.draw_set_font(2.0)
    gm.draw_set_halign(1)
    gm.draw_set_valign(1)
    local str = #incomp.." incompatible mod"..((#incomp > 1) and "s" or "")
    local col = {Color.ORANGE, Color.BLACK, Color.BLACK}
    for i = 3, 1, -1 do
        local c = col[i]
        gm.draw_text_color(text_x, text_y + i, str, c, c, c, c, opacity)
    end

    -- Incompatible mod list
    local mx, my = gm.variable_global_get("mouse_x"), gm.variable_global_get("mouse_y")
    if Helper.is_true(gm.point_in_rectangle(mx, my, box_x, box_y, box_x + box_w, box_y + box_h)) then
        -- Box
        gm.draw_set_alpha(0.4 * opacity)
        local c = Color.BLACK
        gm.draw_rectangle_color(text_x - 136, text_y + 24, text_x + 136, text_y + 32 + (#incomp * 16), c, c, c, c, false)

        -- Mod names
        gm.draw_set_alpha(1.0)
        gm.draw_set_valign(2)
        gm.draw_set_halign(0)
        local c = Color.WHITE
        for i = 1, #incomp do
            gm.draw_text_color(text_x - 128, text_y + 26 + (i * 16), incomp[i][2]:gsub("_", " "), c, c, c, c, opacity)
        end

        -- Mod authors
        gm.draw_set_halign(2)
        local c = Color.GRAY
        for i = 1, #incomp do
            gm.draw_text_color(text_x + 130, text_y + 26 + (i * 16), "by "..incomp[i][1], c, c, c, c, opacity)
        end
    end
end)


gm.post_script_hook(gm.constants._ui_draw_box_text, function(self, other, result, args)
    if #incomp <= 0 then return end
    if ui_hook <= 0 then return end

    if args[5].value == Language.translate_token("ui.title.startOnline") then
        text_x = args[1].value - 20 + args[3].value/2
        text_y = args[2].value - 2 + args[4].value/2
        box_x, box_y, box_w, box_h = args[1].value, args[2].value, args[3].value, args[4].value
        if not initial_fadein then initial_fadein = 0 end
    end
    ui_hook = ui_hook - 1
end)
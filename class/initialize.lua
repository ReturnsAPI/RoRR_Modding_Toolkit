-- Initialize

Initialize = Proxy.new()

initialized = false
local funcs = {}
local post_funcs = {}

local legacy_load = {}



-- ========== Metatable ==========

metatable_initialize = {
    __call = function(t, func, post)
        if initialized then return end

        if not post then
            if not funcs[envy.getfenv(2)["!guid"]] then funcs[envy.getfenv(2)["!guid"]] = {} end
            table.insert(funcs[envy.getfenv(2)["!guid"]], func)
            return
        end

        if not post_funcs[envy.getfenv(2)["!guid"]] then post_funcs[envy.getfenv(2)["!guid"]] = {} end
        table.insert(post_funcs[envy.getfenv(2)["!guid"]], func)
    end,
    
    __metatable = "Initialize"
}
Initialize:setmetatable(metatable_initialize)



-- ========== Initialize ==========

gm.pre_script_hook(gm.constants.__input_system_tick, function()
    if not initialized then
        initialized = true

        -- Initialize RMT first
        __initialize()

        -- Run initialize functions in load order
        for _, m_id in ipairs(mods.loading_order) do
            if funcs[m_id] then
                for _, fn in ipairs(funcs[m_id]) do
                    local status, err = pcall(fn)
                    if not status then
                        log.warning(m_id.." : Initialize failed to execute fully.\n"..err)
                    end
                end
            end
        end

        -- Run legacy __initialize
        for _, m in ipairs(legacy_load) do
            if m.__initialize then
                local status, err = pcall(m.__initialize)
                if not status then
                    log.warning(m["!guid"].." : __initialize failed to execute fully.\n"..err)
                end
            end
        end

        -- Run post_initialize functions in load order
        for _, m_id in ipairs(mods.loading_order) do
            if post_funcs[m_id] then
                for _, fn in ipairs(post_funcs[m_id]) do
                    local status, err = pcall(fn)
                    if not status then
                        log.warning(m_id.." : Post initialize failed to execute fully.\n"..err)
                    end
                end
            end
        end

        -- Run legacy __post_initialize
        for _, m in ipairs(legacy_load) do
            if m.__post_initialize then
                local status, err = pcall(m.__post_initialize)
                if not status then
                    log.warning(m["!guid"].." : __post_initialize failed to execute fully.\n"..err)
                end
            end
        end
    end
end)



-- ========== Legacy RMT autoload ==========

mods.on_all_mods_loaded(function()
    for _, m_id in ipairs(mods.loading_order) do
        local m = mods[m_id]

        -- Check if mod has RMT as a dependency
        if Helper.table_has(
            m._PLUGIN.dependencies_no_version_number,
            "RoRRModdingToolkit-RoRR_Modding_Toolkit"
        ) then

            if m.__initialize or m.__post_initialize then
                -- Add RMT class references
                local status, err = pcall(function()
                    for k, v in pairs(class_refs) do
                        m._G[k] = v
                    end
                end)
                if not status then
                    log.warning(m["!guid"].." : Failed to add RMT class references.\n"..err)
                end

                -- Add to language autoload
                Language.register_autoload(m)

                table.insert(legacy_load, m)
            end

        end
    end
end)



return Initialize
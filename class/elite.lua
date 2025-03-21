-- Elite

Elite = class_refs["Elite"]

local callbacks = {}



-- ========== Static Methods ==========

Elite.new = function(namespace, identifier)
    -- Check if elite already exist
    local elite = Elite.find(namespace, identifier)
    if elite then return elite end

    -- Create elite
    elite = Elite.wrap(
        gm.elite_type_create(
            namespace,      -- Namespace
            identifier      -- Identifier
        )
    )

    return elite
end



-- ========== Instance Methods ==========

methods_elite = {

    add_callback = function(self, callback, func)

        if callback == "onApply" then 
            local callback_id = self.on_apply
            if not callbacks[callback_id] then callbacks[callback_id] = {} end
            table.insert(callbacks[callback_id], func)
        else log.error("Invalid callback name", 2) end

    end,

    clear_callbacks = function(self)
        callbacks[self.on_apply] = nil
    end,

    set_palette = function(self, palette, blend_col)
        if type(palette) ~= "number" then log.error("Palette should be a number, got a "..type(palette), 2) return end
    
        self.palette = palette
        self.blend_col = blend_col
    end,

    set_healthbar_icon = function(self, healthbar)
        if type(healthbar) ~= "number" then log.error("Healthbar should be a number, got a "..type(healthbar), 2) return end
    
        self.healthbar_icon = healthbar
    end,

    -- effect_display setup?


    -- Callbacks
    onApply     = function(self, func) self:add_callback("onApply", func) end
    
}



-- ========== Metatables ==========

metatable_class["Elite"] = {
    __index = function(table, key)
        -- Methods
        if methods_elite[key] then
            return methods_elite[key]
        end

        -- Pass to next metatable
        return metatable_class_gs["Elite"].__index(table, key)
    end,
    

    __newindex = function(table, key, value)
        metatable_class_gs["Elite"].__newindex(table, key, value)
    end,


    __metatable = "Elite"
}



-- ========== Hooks ==========

gm.post_script_hook(gm.constants.callback_execute, function(self, other, result, args)
    if callbacks[args[1].value] then
        for _, fn in pairs(callbacks[args[1].value]) do
            fn(Instance.wrap(args[2].value)) --(actor)
        end
    end
end)



return Elite

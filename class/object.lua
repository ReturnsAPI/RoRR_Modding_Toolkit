-- Object

Object = Proxy.new()

local callbacks = {}
local other_callbacks = {
    "onCreate",
    "onDestroy",
    "onStep",
    "onDraw"
}
local serialize_callbacks = {
	"onSerialize",
	"onDeserialize",
}

object_cognant_blacklist = {}

local serialize = {}
local deserialize = {}

-- ========== Enums ==========

Object.ARRAY = Proxy.new({
    base        = 0,
    obj_depth   = 1,
    obj_sprite  = 2,
    identifier  = 3,
    namespace   = 4,
    on_create   = 5,
    on_destroy  = 6,
    on_step     = 7,
    on_draw     = 8
}):lock()


Object.PARENT = Proxy.new({
    actor               = gm.constants.pActor,
    enemyClassic        = gm.constants.pEnemyClassic,
    enemyFlying         = gm.constants.pEnemyFlying,
    boss                = gm.constants.pBoss,
    bossClassic         = gm.constants.pBossClassic,
    pickupItem          = gm.constants.pPickupItem,
    pickupEquipment     = gm.constants.pPickupEquipment,
    drone               = gm.constants.pDrone,
    mapObjects          = gm.constants.pMapObjects,
    interactable        = gm.constants.pInteractable,
    interactableChest   = gm.constants.pInteractableChest,
    interactableCrate   = gm.constants.pInteractableCrate,
    interactableDrone   = gm.constants.pInteractableDrone
}):lock()


Object.CUSTOM_START = 800



-- ========== Static Methods ==========

Object.new = function(namespace, identifier, parent)
    local obj = Object.find(namespace, identifier)
    if obj then return obj end

    local obj = gm.object_add_w(namespace, identifier, Wrap.unwrap(parent))

    -- Add to Cognition artifact blacklist
    gm.ds_map_set(Global.artifact_cognation_enemy_blacklist, obj, true)

    -- Add to deserialization map for onlne syncing
    gm.ds_map_set(Global.__mtd_deserialize, obj, gm.constants.__lf_init_multiplayer_globals_customobject_deserialize)

    return Object.wrap(obj)
end


Object.find = function(namespace, identifier)
    -- Vanilla object_index
    if type(namespace) == "number" then
        return Object.wrap(namespace)
    end

    if identifier then namespace = namespace.."-"..identifier end

    -- Custom objects
    local ind = gm.object_find(namespace)
    if ind then
        return Object.wrap(ind)
    end

    -- Vanilla namespaced objects
    if string.sub(namespace, 1, 3) == "ror" then
        local obj = gm.constants["o"..string.upper(string.sub(namespace, 5, 5))..string.sub(namespace, 6, #namespace)]
        if obj then
            return Object.wrap(obj)
        end
        return nil
    end

    return nil
end


Object.wrap = function(value)
    value = Wrap.unwrap(value)

    local mt = metatable_object
    local lt = lock_table_object

    if gm.object_is_ancestor(value, gm.constants.pInteractable) == 1.0
    or gm.object_is_ancestor(value, gm.constants.pInteractableChest) == 1.0
    or gm.object_is_ancestor(value, gm.constants.pInteractableCrate) == 1.0
    or gm.object_is_ancestor(value, gm.constants.pInteractableDrone) == 1.0 then
        mt = metatable_interactable_object
        lt = lock_table_interactable_object
    end
    
    if value >= Object.CUSTOM_START then
        local custom_object = Array.wrap(gm.variable_global_get("custom_object"))
        local obj_array = custom_object:get(value - Object.CUSTOM_START)
        local obj_index = obj_array:get(0)

        if obj_index == gm.constants.oCustomObject_pInteractable
        or obj_index == gm.constants.oCustomObject_pInteractableChest
        or obj_index == gm.constants.oCustomObject_pInteractableCrate
        or obj_index == gm.constants.oCustomObject_pInteractableDrone then
            mt = metatable_interactable_object
            lt = lock_table_interactable_object
        end
    end

    return make_wrapper(value, mt, lt)
end



-- ========== Instance Methods ==========

methods_object = {

    create = function(self, x, y)
        local inst = gm.instance_create(x or 0, y or 0, self.value)
        return Instance.wrap(inst)
    end,


    add_callback = function(self, callback, func)
        self:add_callback_obj_actual(callback, func)
    end,


    add_callback_obj_actual = function(self, callback, func)
        if self.value < Object.CUSTOM_START then return end

        if Helper.table_has(other_callbacks, callback) then 
            local callback_id = self["on_"..string.lower(string.sub(callback, 3, 3))..string.sub(callback, 4, #callback)]
            if not callbacks[callback_id] then callbacks[callback_id] = {} end
            table.insert(callbacks[callback_id], func)
			return
        end

        if callback == "onSerialize" then
			serialize[self.value] = func
			return
		end
        if callback == "onDeserialize" then
			deserialize[self.value] = func
			return
		end
		log.error("Invalid callback name", 2)
    end,


    clear_callbacks = function(self)
        self:clear_callbacks_obj_actual()
    end,


    clear_callbacks_obj_actual = function(self)
        callbacks[self.on_create] = nil
        callbacks[self.on_destroy] = nil
        callbacks[self.on_step] = nil
        callbacks[self.on_draw] = nil

        serialize[self.value] = nil
        deserialize[self.value] = nil
    end,


    get_sprite = function(self)
        return gm.object_get_sprite_w(self.value)
    end,


    set_sprite = function(self, sprite)
        gm.object_set_sprite_w(self.value, sprite)
    end,


    get_depth = function(self)
        local depths = Array.wrap(gm.variable_global_get("object_depths"))
        return depths:get(self.value)
    end,


    set_depth = function(self, depth)
        -- Does not apply retroactively to existing instances
        local depths = Array.wrap(gm.variable_global_get("object_depths"))
        depths:set(self.value, depth)
    end,


    allow_cognant = function(self, bool)
        -- Vanilla
        if self.value < Object.CUSTOM_START then
            if bool then
                gm.ds_map_set(Global.artifact_cognation_enemy_blacklist, self.value, false)
                return
            end
            gm.ds_map_set(Global.artifact_cognation_enemy_blacklist, self.value, true)
            return
        end

        -- Custom
        if bool then
            object_cognant_blacklist[self.value] = nil
            return
        end
        object_cognant_blacklist[self.value] = true
    end,


    -- Callbacks
    onCreate        = function(self, func) self:add_callback("onCreate", func) end,
    onDestroy       = function(self, func) self:add_callback("onDestroy", func) end,
    onStep          = function(self, func) self:add_callback("onStep", func) end,
    onDraw          = function(self, func) self:add_callback("onDraw", func) end,

    onSerialize     = function(self, func) self:add_callback("onSerialize", func) end,
    onDeserialize   = function(self, func) self:add_callback("onDeserialize", func) end,

}
lock_table_object = Proxy.make_lock_table({"value", "RMT_object", table.unpack(Helper.table_get_keys(methods_object))})



-- ========== Metatables ==========

metatable_object_gs = {
    -- Getter
    __index = function(table, key)
        if table.value >= Object.CUSTOM_START then
            local index = Object.ARRAY[key]
            if index then
                local custom_object = Array.wrap(gm.variable_global_get("custom_object"))
                local obj_array = custom_object:get(table.value - Object.CUSTOM_START)
                return obj_array:get(index)
            end
            log.error("Non-existent object property", 2)
            return nil
        end
        log.error("No object properties for vanilla objects", 2)
        return nil
    end,


    -- Setter
    __newindex = function(table, key, value)
        if table.value >= Object.CUSTOM_START then
            local index = Object.ARRAY[key]
            if index then
                local custom_object = Array.wrap(gm.variable_global_get("custom_object"))
                local obj_array = custom_object:get(table.value - Object.CUSTOM_START)
                obj_array:set(index, value)
                return
            end
            log.error("Non-existent object property", 2)
            return
        end
        log.error("No object properties for vanilla objects", 2)
    end
}


metatable_object = {
    __index = function(table, key)
        -- Methods
        if methods_object[key] then
            return methods_object[key]
        end

        -- Pass to next metatable
        return metatable_object_gs.__index(table, key)
    end,
    

    __newindex = function(table, key, value)
        metatable_object_gs.__newindex(table, key, value)
    end,


    __metatable = "Object"
}



-- ========== Hooks ==========

gm.post_script_hook(gm.constants.callback_execute, function(self, other, result, args)
    -- Custom object callbacks
    if callbacks[args[1].value] then
        local inst = Instance.wrap(args[2].value)
        if not inst:exists() then return end
        for _, fn in pairs(callbacks[args[1].value]) do
            fn(inst)   -- Instance
        end
    end
end)


gm.post_script_hook(gm.constants.__lf_init_multiplayer_globals_customobject_serialize, function(self, other, result, args)
	local fn = serialize[self.__object_index]
	if fn then
		fn(Instance.wrap(self), Message.new(-1, Global.multiplayer_buffer, false))
	end
end)

gm.post_script_hook(gm.constants.__lf_init_multiplayer_globals_customobject_deserialize, function(self, other, result, args)
	local fn = deserialize[self.__object_index]
	if fn then
		fn(Instance.wrap(self), Message.new(-1, Global.multiplayer_buffer, true))
	end
end)


return Object

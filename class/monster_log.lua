-- Monster_Log

Monster_Log = class_refs["Monster_Log"]



-- ========== Static Methods ==========

Monster_Log.new = function(namespace, identifier)
    -- Check if monster_log already exist
    local monster_log = Monster_Log.find(namespace, identifier)
    if monster_log then return monster_log end

    -- Create monster_log
    monster_log = Monster_Log.wrap(
        gm.monster_log_create(
            namespace,      -- Namespace
            identifier      -- Identifier
        )
    )

    monster_log.sprite_id = gm.constants.sLizardWalk
    monster_log.portrait_id = gm.constants.sPortrait

    monster_log:set_is_boss(false)

    return monster_log
end

-- Monster_Log.new = function(monster_card)
    
--     if type(monster_card) ~= "table" or monster_card.RMT_object ~= "Monster_Card" then log.error("monster_card is not a RMT Monster_Card, got a "..type(monster_card), 2) return end
    
--     -- Check if monster_log already exist
--     local monster_log = Monster_Log.find(monster_card.namespace, monster_card.identifier)
--     if monster_log then return monster_log end

--     -- Create monster_log
--     monster_log = Monster_Log.wrap(
--         gm.monster_log_create(
--             monster_card.namespace,      -- Namespace
--             monster_card.identifier      -- Identifier
--         )
--     )

--     -- Make monster_log abstraction
--     local abstraction = Monster_Log.wrap(monster_log)

--     -- Set the Log backdrop index based on the is_boss field of the monster card

--     -- Create Log book object (IMPORTANT: log book object of rorr monster are outside the 800 object index)

--     -- Set the enemy tracking kills and deaths
--     -- Both array may be different if the enemy is composite (like lemurian rider)
--     local enemy_kills = Array.wrap(abstraction.enemy_object_ids_kills)
--     local enemy_deaths = Array.wrap(abstraction.enemy_object_ids_deaths)
--     enemy_kills:push(monster_card.object_id)
--     enemy_deaths:push(monster_card.object_id)

--     return monster_log
-- end


-- ========== Instance Methods ==========

methods_monster_log = {
    set_sprite = function(self, sprite_id, portrait_id, portrait_index)
        if type(sprite_id) ~= "number" then log.error("Sprite_id should be a number, got a "..type(sprite_id), 2) return end
        if type(portrait_id) ~= "number" then log.error("Portrait_id should be a number, got a "..type(portrait_id), 2) return end
        if type(portrait_index) ~= "number" and type(portrait_index) ~= "nil" then log.error("Portrait_index should be a number, got a "..type(portrait_index), 2) return end

        self.sprite_id = sprite_id
        self.portrait_id = portrait_id
        self.portrait_index = portrait_index or self.portrait_index
    end,

    set_sprite_offsets = function(self, offset_x, offset_y, height_offset)
        if type(offset_x) ~= "number" then log.error("Offset_x should be a number, got a "..type(offset_x), 2) return end
        if type(offset_y) ~= "number" then log.error("Offset_y should be a number, got a "..type(offset_y), 2) return end
        if type(height_offset) ~= "number" and type(height_offset) ~= "nil" then log.error("Height_offset should be a number, got a "..type(height_offset), 2) return end
    
        self.sprite_offset_x = offset_x
        self.sprite_offset_y = offset_y
        self.sprite_height_offset = height_offset or self.sprite_height_offset
    end,

    set_sprite_force_horizontal_align = function(self, force_Halign)
        if type(force_Halign) ~= "boolean" then log.error("Force_Halign should be a boolean, got a "..type(force_Halign), 2) return end
    
        self.sprite_force_horizontal_align = force_Halign
    end,

    set_stats = function(self, stats)
        if type(stats) ~= "table" then log.error("Stats should be a table, got a "..type(stats), 2) return end
        
        if type(stats.hp) ~= "number" and type(stats.hp) ~= "nil" then log.error("HP should be a number, got a "..type(stats.hp), 2) return end
        if type(stats.damage) ~= "number" and type(stats.damage) ~= "nil" then log.error("Damage should be a number, got a "..type(stats.damage), 2) return end
        if type(stats.speed) ~= "number" and type(stats.speed) ~= "nil" then log.error("Speed should be a number, got a "..type(stats.speed), 2) return end
    
        self.stat_hp = stats.hp or 100
        self.stat_damage = stats.damage or 14
        self.stat_speed = stats.speed or 1.2
    end,

    add_kill_track_enemy = function(self, ...)
        local monster_object_ids = {...}
        if type(monster_object_ids[1]) == "table" then monster_object_ids = monster_object_ids[1] end

        local enemy_kills = self.enemy_object_ids_kills
        
        for _, monster_object_id in ipairs(monster_object_ids) do
            if type(monster_object_id) ~= "number" then log.error("Monster_object_ids should be number(s), got a "..type(monster_object_id), 2) return end

            if enemy_kills:size() == 0 or not enemy_kills:contains(monster_object_id) then
                enemy_kills:push(monster_object_id)
            end
        end
        
    end,

    add_death_track_enemy = function(self, ...)
        local monster_object_ids = {...}
        if type(monster_object_ids[1]) == "table" then monster_object_ids = monster_object_ids[1] end
        
        local enemy_deaths = self.enemy_object_ids_deaths

        for _, monster_object_id in ipairs(monster_object_ids) do
            if type(monster_object_id) ~= "number" then log.error("Monster_object_ids should be number(s), got a "..type(monster_object_id), 2) return end

            if enemy_deaths:size() == 0 or not enemy_deaths:contains(monster_object_id) then
                enemy_deaths:push(monster_object_id)
            end
        end
    end,

    set_is_boss = function(self, is_boss)
        if type(is_boss) ~= "boolean" then log.error("is_boss should be a boolean, got a "..type(is_boss), 2) return end

        if is_boss then
            self.log_backdrop_index = 1
        else
            self.log_backdrop_index = 0
        end

        -- Remove previous monster log position (if found)
        local monster_log_order = List.wrap(gm.variable_global_get("monster_log_display_list"))
        local pos = monster_log_order:find(self)
        if pos then monster_log_order:delete(pos) end

        local pos = Class.MONSTER_LOG:size()
        for i, log_id in ipairs(monster_log_order) do
            local log_ = Class.MONSTER_LOG:get(log_id)
            local comparison_log = Monster_Log.find(log_:get(0), log_:get(1))

            if comparison_log.log_backdrop_index > self.log_backdrop_index then
                pos = i
                break
            end
        end
        monster_log_order:insert(pos - 1, self)
    end,
}



-- ========== Metatables ==========

metatable_class["Monster_Log"] = {
    __index = function(table, key)
        -- Methods
        if methods_monster_log[key] then
            return methods_monster_log[key]
        end

        -- Pass to next metatable
        return metatable_class_gs["Monster_Log"].__index(table, key)
    end,
    

    __newindex = function(table, key, value)
        metatable_class_gs["Monster_Log"].__newindex(table, key, value)
    end,


    __metatable = "Monster_Log"
}



return Monster_Log
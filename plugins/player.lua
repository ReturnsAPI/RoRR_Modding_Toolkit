-- Player

Player = {}



-- ========== Static Methods ==========

Player.get_client = function(obj)
    local players = Instance.find_all(gm.constants.oP)

    -- Return the first player if there is only one player
    if #players == 1 then return players[1] end

    -- Loop through players and return the one that "is_local"
    for _, p in ipairs(players) do
        if p.is_local then
            return Instance.wrap(p)
        end
    end

    -- None
    return Instance.wrap_invalid()
end


Player.get_host = function()
    -- Return the player that has an m_id of 1.0
    local players = Instance.find_all(gm.constants.oP)
    for _, p in ipairs(players) do
        if p.m_id == 1.0 then
            return Instance.wrap(p)
        end
    end

    -- None
    return Instance.wrap_invalid()
end


Player.get_from_name = function(name)
    local players = Instance.find_all(gm.constants.oP)
    for _, p in ipairs(players) do
        if p.user_name == name then
            return Instance.wrap(p)
        end
    end

    -- None
    return Instance.wrap_invalid()
end



-- ========== Instance Methods ==========

methods_player = {

    get_equipment = function(self)
        local equip = gm.equipment_get(self.value)
        if equip >= 0 then
            return Equipment.wrap(equip)
        end
        return nil
    end,


    set_equipment = function(self, equipment)
        equipment = Wrap.unwrap(equipment)
        gm.equipment_set(self.value, equipment)
    end,


    get_equipment_cooldown = function(self)
        return gm.player_get_equipment_cooldown(self.value)
    end,


    reduce_equipment_cooldown = function(self, amount)
        gm.player_grant_equipment_cooldown_reduction(self.value, amount)
    end,


    get_equipment_use_direction = function(self)
        local num = self.value:player_util_local_player_get_equipment_activation_direction()
        local bool = true
        if num == true then num = 1.0 end
        if num == false then num = -1.0 end
        if num == -1.0 then bool = false end
        return num, bool
    end

}



-- ========== Metatables ==========

metatable_player = {
    __index = function(table, key)
        -- Methods
        if methods_player[key] then
            return methods_player[key]
        end

        -- Pass to next metatable
        return metatable_actor.__index(table, key)
    end,
    

    __newindex = function(table, key, value)
        metatable_instance_gs.__newindex(table, key, value)
    end
}
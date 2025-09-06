-- Particle

Particle = Proxy.new()



-- ========== Enums ==========

Particle.SYSTEM = Proxy.new({
    above           = 0,
    below           = 1,
    middle          = 2,
    background      = 3,
    veryAbove       = 4,
    damage          = 5,
    damage_above    = 6
}):lock()


Particle.SHAPE = Proxy.new({
    pixel       = 0,
    disk        = 1,
    square      = 2,
    line        = 3,
    star        = 4,
    circle      = 5,
    ring        = 6,
    sphere      = 7,
    flare       = 8,
    spark       = 9,
    explosion   = 10,
    cloud       = 11,
    smoke       = 12,
    snow        = 13
}):lock()



-- ========== Static Methods ==========

Particle.new = function(namespace, identifier)
    local part = Particle.find(namespace, identifier)
    if part then return part end

    local part = gm.part_type_create_w(namespace, identifier)
    return Particle.wrap(part)
end


Particle.find = function(namespace, identifier)
    if not identifier then
        local array = GM.string_split(namespace, "-")
        namespace, identifier = array[1], array[2]
        if not identifier then
            log.warning("Particle identifier not provided", 2)
            return nil
        end
    end

    local lookup = gm.variable_global_get("ResourceManager_particleTypes").__namespacedAssetLookup
    local np = gm.ds_map_find_value(lookup, namespace)
    if not np then return nil end
    local id = gm.ds_map_find_value(np, identifier)
    if not id then return nil end
    return Particle.wrap(id)
end


Particle.find_all = function(namespace)
    local lookup = gm.variable_global_get("ResourceManager_particleTypes").__namespacedAssetLookup
    local np = gm.ds_map_find_value(lookup, namespace)
    if not np then return {}, 0 end

    local parts = {}
    local values = gm.ds_map_values_to_array(np)
    local size = gm.ds_map_size(np)
    for i=0, size do
        table.insert(parts,Particle.wrap(values[i]))
    end
    return parts, #parts > 0
end


Particle.wrap = function(value)
    return make_wrapper(value, metatable_particle)
end



-- ========== Instance Methods ==========

methods_particle = {

    create = function(self, x, y, count, system)
        GM.part_particles_create(system or Particle.SYSTEM.above, x, y, self, count or 1)
    end,


    create_color = function(self, x, y, color, count, system)
        GM.part_particles_create_color(system or Particle.SYSTEM.above, x, y, self, color, count or 1)
    end,

    create_colour = function(self, x, y, color, count, system)
        self:create_color(x, y, color, count, system)
    end

}



-- ========== Metatables ==========

metatable_particle = {
    __index = function(table, key)
        -- Methods
        if methods_particle[key] then
            return methods_particle[key]
        end

        -- GML part_type_ methods
        if key:sub(1, 4) == "set_" then
            local fn = key:sub(5, #key)
            return GM["part_type_"..fn]
        end

        return nil
    end,


    __newindex = function(table, key, value)
        log.error("Particle has no settable properties; use methods instead", 2)
    end,


    __metatable = "Particle"
}



return Particle
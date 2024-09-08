-- List

List = {}



-- ========== Static Methods ==========

List.new = function()
    return List.wrap(gm.ds_list_create())
end


List.wrap = function(list)
    local abstraction = {
        RMT_wrapper = "List",
        value = list
    }
    setmetatable(abstraction, metatable_list)
    return abstraction
end



-- ========== Instance Methods ==========

methods_list = {

    exists = function(self)
        return gm.ds_exists(self.value, 2) == 1.0
    end,


    destroy = function(self)
        gm.ds_list_destroy(self.value)
        self.value = -1
    end,


    get = function(self, index)
        return Wrap.wrap(gm.ds_list_find_value(self.value, index))
    end,


    set = function(self, index, value)
        gm.ds_list_set(self.value, index, Wrap.unwrap(value))
    end,


    size = function(self)
        return gm.ds_list_size(self.value)
    end,


    add = function(self, ...)
        local values = {...}
        for _, v in ipairs(values) do
            gm.ds_list_add(self.value, Wrap.unwrap(v))
        end
    end,


    insert = function(self, index, value)
        gm.ds_list_insert(self.value, index, Wrap.unwrap(value))
    end,
    

    delete = function(self, index)
        gm.ds_list_delete(self.value, index)
    end,

    
    clear = function(self)
        gm.ds_list_clear(self.value)
    end,


    contains = function(self, value)
        return gm.ds_list_find_index(self.value, Wrap.unwrap(value)) >= 0
    end,


    find = function(self, value)
        local pos = gm.ds_list_find_index(self.value, Wrap.unwrap(value))
        if pos < 0 then return nil end
        return pos
    end,


    sort = function(self, descending)
        gm.ds_list_sort(self.value, not descending)
    end

}



-- ========== Metatables ==========

metatable_list_gs = {
    -- Getter
    __index = function(table, key)
        key = tonumber(key)
        if key and key >= 1 and key <= table:size() then
            return Wrap.wrap(gm.ds_list_find_value(table.value, key - 1))
        end
        return nil
    end,


    -- Setter
    __newindex = function(table, key, value)
        if (key == "value" and value ~= -1) or key == "RMT_wrapper" then
            log.error("Cannot change wrapper value", 2)
            return
        end
        
        key = tonumber(key)
        if key then
            gm.ds_list_set(table.value, key - 1, Wrap.unwrap(value))
        end
    end
}


metatable_list = {
    __index = function(table, key)
        -- Methods
        if methods_list[key] then
            return methods_list[key]
        end

        -- Pass to next metatable
        return metatable_list_gs.__index(table, key)
    end,
    

    __newindex = function(table, key, value)
        metatable_list_gs.__newindex(table, key, value)
    end,
    
    
    __len = function(table)
        return gm.ds_list_size(table.value)
    end
}
-- RoRR Modding Toolkit

-- ENVY initial setup
mods["LuaENVY-ENVY"].auto()
envy = mods["LuaENVY-ENVY"]
class_refs = {}


-- Require internal files
local names = path.get_files(_ENV["!plugins_mod_folder_path"].."/internal")
for _, name in ipairs(names) do require(name) end


-- Require public classes (these first)
local names = path.get_files(_ENV["!plugins_mod_folder_path"].."/class_first")
for _, name in ipairs(names) do
    local class = capitalize_class_name(path.filename(name):sub(1, -5))
    class_refs[class] = require(name)
end


-- Require public classes
local names = path.get_files(_ENV["!plugins_mod_folder_path"].."/class")
for _, name in ipairs(names) do
    local class = capitalize_class_name(path.filename(name):sub(1, -5))
    class_refs[class] = require(name)
end


-- Require internal files (these last)
local names = path.get_files(_ENV["!plugins_mod_folder_path"].."/internal_last")
for _, name in ipairs(names) do require(name) end


-- Extra public refs
class_refs["Proxy"] = Proxy     -- Making this public too; might be useful to someone
class_refs["Colour"] = Color


-- Lock public classes after finalization
for _, ref in pairs(class_refs) do
    if getmetatable(ref) == "Proxy" then ref:lock() end
end


-- ENVY public setup
require("./envy_setup")



-- ========== Initialize ==========

function __initialize()
    initialize_class()
    initialize_helper()

    initialize_instance()
end
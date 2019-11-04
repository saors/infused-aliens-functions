infused_aliens_functions = {}
infused_aliens_functions["entries"] = {}
infused_aliens_functions["dictionary"] = {}
infused_aliens_functions["staged_units"] = {
  ["small-biter"] = {{0.0, 0.3}, {0.6, 0.0}},
  ["medium-biter"] = {{0.2, 0.0}, {0.6, 0.3}, {0.7, 0.1}},
  ["big-biter"] = {{0.5, 0.0}, {1.0, 0.4}},
  ["behemoth-biter"] = {{0.9, 0.0}, {1.0, 0.3}},
  ["small-spitter"] = {{0.0, 0.3}, {0.35, 0}},
  ["medium-spitter"] = {{0.4, 0.0}, {0.7, 0.3}, {0.9, 0.1}},
  ["big-spitter"] = {{0.5, 0.0}, {1.0, 0.4}},
  ["behemoth-spitter"] = {{0.9, 0.0}, {1.0, 0.3}}
}
infused_aliens_functions["staged_spawners"] = {"biter-spawner", "spitter-spawner"}

local small_unit_spawn_rate = {{0.0, 0.3}, {0.35, 0}}
local medium_unit_spawn_rate =  {{0.4, 0.0}, {0.7, 0.3}, {0.9, 0.1}}
local big_unit_spawn_rate =  {{0.5, 0.0}, {1.0, 0.4}}
local behemoth_unit_spawn_rate = {{0.9, 0.0}, {1.0, 0.3}}

infused_aliens_functions.get_template = function()
  local template = {
    ["buff_key"] = "coolname", -- single-word, lowercase string for the buff/infusion
    ["buff_value"] = { 
      ["locale"] = {
        ["append_name"] = true,
        ["append_description"] = true,
      },
      ["modifications"] = {
      }
    }
  }
  return template
end

infused_aliens_functions.get_vanilla_units = function()
  return {
    ["small-biter"] = true, 
    ["medium-biter"] = true, 
    ["big-biter"] = true, 
    ["behemoth-biter"] = true, 
    ["biter-spawner"] = true, 
    
    ["small-spitter"] = true, 
    ["medium-spitter"] = true, 
    ["big-spitter"] = true, 
    ["behemoth-spitter"] = true, 
    ["spitter-spawner"] = true,
  }
end

infused_aliens_functions.merge_tables = function(t1,t2)
  for k,v in pairs(t2) do
    if type(v) == "table" then
        if type(t1[k] or false) == "table" then
          infused_aliens_functions.merge_tables(t1[k] or {}, t2[k] or {})
        else
            t1[k] = v
        end
    else
        t1[k] = v
    end
  end
  return t1
end

infused_aliens_functions.reset_dictionary = function()
  infused_aliens_functions.dictionary = {}
end

infused_aliens_functions.get_buff_names = function()
  local buff_names = {}
    for _,entry in pairs(infused_aliens_functions["entries"] ) do 
      table.insert( buff_names, entry.buff_key )
    end
  return buff_names
end

infused_aliens_functions.convert_to_buff_list = function(buff_string)
  buffs = {}
  for w in buff_string:gmatch("([^-]+)") do --regex to split on hyphens
    table.insert( buffs, w )
  end
  return buffs
end

infused_aliens_functions.capitalize_string = function(str)
  return (str:gsub("^%l", string.upper))
end

infused_aliens_functions.extend = function(modified_units)
  for _,entry in pairs(modified_units) do
    data:extend{entry}
  end
end

infused_aliens_functions.create_new_unit_prototypes = function(buff_string)
  local buffs = infused_aliens_functions.convert_to_buff_list(buff_string) --buff list for a single dictionary entry
  local modified_units = {}
  local modified_spawners = {}
  local applicable_entries = {}

  --subset all entries for ones that are relevent to buff_string
  for _, buff in pairs(buffs) do
    for _2, entry in pairs(infused_aliens_functions["entries"]) do
      if(buff == entry["buff_key"]) then
        table.insert(applicable_entries, entry)
      end
    end
  end

  --iterate over staged_units -> for each, deep-copy the unit, change the name, add it to modified_units
  for unit, spawn_rate_value in pairs(infused_aliens_functions["staged_units"]) do
    local unit_key = buff_string.."-"..unit
    modified_units[unit_key] = table.deepcopy(data.raw["unit"][unit])
    modified_units[unit_key].name = unit_key

    modified_units[unit_key]["localised_name"] = string.gsub(unit_key, "-", " ")
    modified_units[unit_key]["localised_description"] = string.gsub(unit_key, "-", " ")

    
    --iterate applicable buffs and apply the modifications
    for _1, entry in pairs(applicable_entries) do
      for attribute_key, mod_type in pairs(entry["buff_value"]["modifications"]) do
        for mod_key, mod_val in pairs(mod_type) do
          if mod_key == unit then
            modified_units[unit_key][attribute_key] = infused_aliens_functions.merge_tables(modified_units[unit_key][attribute_key], mod_val)
          end
        end
      end
    end
  end

  for _, spawner in pairs(infused_aliens_functions["staged_spawners"]) do
    local spawner_key = buff_string.."-"..spawner
    modified_spawners[spawner_key] = table.deepcopy(data.raw["unit-spawner"][spawner])
    modified_spawners[spawner_key].name = spawner_key

    modified_spawners[spawner_key]["localised_name"] = string.gsub(spawner_key, "-", " ")
    modified_spawners[spawner_key]["localised_description"] = string.gsub(spawner_key, "-", " ")

    --reset result units after deepcopy
    modified_spawners[spawner_key]["result_units"] = {}

    --get spawner type
    local spawner_type = "biter"
    if string.find(spawner, "spitter") then
      spawner_type = "spitter"
    end
    
    --set results units
    for unit_key, spawn_rate_value in pairs(infused_aliens_functions["staged_units"]) do
      local unit_type = "biter"
      if string.find(unit_key, "spitter") then
        unit_type = "spitter"
      end

      if(unit_type == spawner_type) then
        local unit = buff_string.."-"..unit_key
        local result_units_table = {unit, spawn_rate_value}
        table.insert(modified_spawners[spawner_key]["result_units"], result_units_table)
      end
    end

    --set spawner modifications
    for _1, entry in pairs(applicable_entries) do
      if string.find(entry.buff_key, "sharpened") then
      end
      for attribute_key, mod_type in pairs(entry["buff_value"]["modifications"]) do
        for mod_key, mod_val in pairs(mod_type) do
          if mod_key == spawner then
            if(mod_val == "nil") then
              mod_val = nil
            end
            if type(mod_val) == "table" then
              modified_spawners[spawner_key][attribute_key] = infused_aliens_functions.merge_tables(modified_spawners[spawner_key][attribute_key], mod_val)           
            else
              modified_spawners[spawner_key][attribute_key] = mod_val
            end
          end
        end
      end
    end
  end

  local new_prototypes = {
    ["units"] = modified_units,
    ["spawners"] = modified_spawners
  }

  return new_prototypes
  
end

infused_aliens_functions.infuse = function()
  local modified_units = {}
  local modified_spawners = {}

  for _, buff_string in pairs(infused_aliens_functions.dictionary) do
    local new_prototypes = infused_aliens_functions.create_new_unit_prototypes(buff_string)
    local new_units = new_prototypes["units"]
    local new_spawners = new_prototypes["spawners"]
    for _, unit in pairs(new_units) do
      table.insert(modified_units, unit)
    end
    for _, spawners in pairs(new_spawners) do
      table.insert(modified_spawners, spawners)
    end
  end

  infused_aliens_functions.extend(modified_units)
  infused_aliens_functions.extend(modified_spawners)
end

infused_aliens_functions.build_dictionary = function(set)
  for _,v in pairs(set) do 
    local ex = ""
    for key,val in pairs(v) do 
      if(key == 1) then
        ex = val
      else
        ex = val.."-"..ex
      end
    end
    if(ex ~= "") then
      table.insert( infused_aliens_functions.dictionary, ex )
    end
  end
  infused_aliens_functions.infuse()
end

infused_aliens_functions.add_to_entries = function(entry)
  table.insert( infused_aliens_functions["entries"], entry )
end

infused_aliens_functions.stage_entries = function()
  infused_aliens_functions.reset_dictionary()
  table.sort( infused_aliens_functions["entries"], function(a,b) return a.buff_key < b.buff_key end)
  local names = infused_aliens_functions.get_buff_names()
  local ret = {{}}
  for i = 1, #names do
    local k = #ret
    for j = 1, k do
      ret[k + j] = {names[i], unpack(ret[j])}
    end
  end
  infused_aliens_functions.build_dictionary(ret)
end
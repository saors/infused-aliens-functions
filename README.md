# Infused Aliens Functions

This is a utility mod that is meant to be used in other mods. It quickly generates new prototypes based on limited input.

By using the get_template() function, you are provided with a table that you can extend to create new buffs.

template:
```
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
```

The buff_key must be a unique single-word, lowercase string

Setting the locale values to true will append them so they show up in the name/description on the entities

The modifications can be specified per attribute, per unit. Example:

```
#-- in data.lua
require("__infused_aliens_functions__.data.functions")
local fast_buff = infused_aliens_functions.get_template()
fast_buff["buff_key"] = "speedy"
fast_buff["buff_value"]["modifications"]["movement_speed"] = {}
fast_buff["buff_value"]["modifications"]["movement_speed"]["small-biter"] = 0.4
fast_buff["buff_value"]["modifications"]["movement_speed"]["big-biter"] = 0.46
```

This template describes a buff that will double the speed of small-biter and big-biter units (base move-speed for small and big-biters is .2 and .23 respectively).

You can then add the buff, via the add_to_entries() function.

Once all of the buffs have been added, call the function stage_entries() to have the prototypes generated.

## Prototype generation

This is the bread and butter of this mod, as it will take all of the buff templates that were input earlier and generate prototypes for every combination of them.
This uses a [power set](https://rosettacode.org/wiki/Power_set) (thanks TehFreek)
in order to create every combination with an without each buff.

In [my other mod](https://mods.factorio.com/mod/infused_aliens), I push 4 buff templates into this mod, which then creates 15 different buff combinations, which are applied to 2 different spawner type and 8 vanilla units. This comes out to 15\*2 = 30 new spawner prototypes and 15\*8=120 new unit prototypes.

## Acknowledgments
#mod-making on the Factorio Discord channel  
Calcwizard for answering a ton of my questions  
Rseding91 for dealing with my not-actually-a-bug reports   







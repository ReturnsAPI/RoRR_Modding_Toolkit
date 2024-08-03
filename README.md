Friendly abstractions of the game's internal functions for easier modding.  
Documentation can be found [here](https://github.com/RoRRModdingToolkit/RoRR_Modding_Toolkit/wiki).  

To use, include the following line in your code:  
```lua
mods.on_all_mods_loaded(function() for _, m in pairs(mods) do if type(m) == "table" and m.RoRR_Modding_Toolkit then Buff = m.Buff Callback = m.Callback Helper = m.Helper Instance = m.Instance Item = m.Item Net = m.Net Player = m.Player Resources = m.Resources Survivor = m.Survivor break end end end)

```

### Current Functionality
* General-purpose helper functions
* Instance finding
* Callback setup
* Network syncing
* Custom content
    * Buffs
    * Items
    * Survivors (sort of; no documentation yet)

---

### Installation Instructions
Follow the instructions [listed here](https://docs.google.com/document/d/1NgLwb8noRLvlV9keNc_GF2aVzjARvUjpND2rxFgxyfw/edit?usp=sharing).

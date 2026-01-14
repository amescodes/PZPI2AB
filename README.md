![Put it in a #$!% bag! mod - poster.](https://github.com/amescodes/PZPI2AB/blob/main/images/poster.png?raw=true)

#### Put it in a #$!% bag! (PI2AB) Compatible with Build 41 & 42 MP!

A Project Zomboid mod that automatically transfers the results of crafting/dismantling items to your specified target container. Safe to add/remove mid-game!

[![Steam Workshop Logo](https://github.com/amescodes/PZPI2AB/blob/main/images/workshop_logo.png?raw=true)](https://steamcommunity.com/id/ames_games/myworkshopfiles/?appid=108600)

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/amescodes)

[![Support me on ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/E1E11KCLJV)



## Features

### Target Container System

Assign an equipped bag as the "Target Container" that receives the resulting items of various tasks.

- Right-click any equipped bag or container to set it as your target container

![Target container right-click option on backpacks and other containers.](https://github.com/amescodes/PZPI2AB/blob/main/images/targetcontainer.png?raw=true)

- Crafted and dismantled items will automatically transfer to the target container if there's room and it is equipped
- If the target container is full or not set, items will go to the default target (configurable from the PI2AB tab in the character panel)
- To reset your target container, right-click the main character inventory and select "Reset Target Container"

![Reset target container back to default option from player inventory.](https://github.com/amescodes/PZPI2AB/blob/main/images/resettarget.png?raw=true)



---

### Configuration

![PI2AB table in the character panel.](https://github.com/amescodes/PZPI2AB/blob/main/images/configtab.png?raw=true)

The mod adds a new "PI2AB" tab in your character info panel with several options:

#### Default Target

When there's no target container set, the target container is unequipped, or when the target container is full, items will be transferred to the default target. You have two options:

- **Player Inventory**: Items go to your main inventory (default setting)
- **Item Source Container**: Items return to the container where one of the crafting ingredients came from 

#### Transfer Items on All

When crafting/dismantling multiple items at once ("All" option), you can choose when the items get transferred:

- **After Each**: Items are transferred immediately after each individual craft/dismantle task

- **At End**: Items are transferred only after all crafting/dismantling tasks are completed

  

---

### Affected Actions

The following actions should trigger automatic transferring:

- Craft/dismantle items
- Dismantle car wreck
- Uninstall car part
- Take engine parts
- Disassemble furniture/moveable objects

Note: Automatic transfer of 'Cooking' craft recipes is not currently supported because personally, I don't usually want those to transfer. Look to planned features if you find this annoying. 😊



## Known Mod Incompatibilities

If you experience any issues alongside other mods, please provide a mod list and console log [here](). Without at least a mod list, I won't be able to determine what the incompatibility is.

#### B41 (Updated 1/13/2026)

- [Inventory Tetris - Grid Based Inventory Overhaul [B41 Legacy Version]](https://steamcommunity.com/sharedfiles/filedetails/?id=2982070344)

#### B42 (Updated 1/13/2026)

- [Inventory Tetris - Grid Based Inventory Overhaul [B42]](https://steamcommunity.com/sharedfiles/filedetails/?id=3397561666)



## Planned Features

- Player option to filter ingredients from automatically transferring (eg, scrap wood)
- Player option to filter recipes from automatically transferring their result(s)
- Player option to filter recipe categories from automatically transferring their result(s)
- Sandbox option for traits to affect ability to transfer items (eg, a player with Disorganized or All Thumbs won't transfer automatically)



## Mod Notes

- No items are created, removed, or affected in any way by PI2AB. Only new transfer actions are added to the player's queue depending on the player's configuration set in the PI2AB character window tab.
- When using the 'At End' transfer option, some items may not transfer correctly, especially if the target container is close to capacity or if items were transferred out of the target container to perform the action (eg, unpacking screwdriver to dismantle watch.) I will dig into it deeper at a later time, but for now the behavior is more than tolerable.



## Credits

- PZ modding community for the [repo template](https://github.com/Project-Zomboid-Community-Modding/pzmc-template) and being a helpful resource


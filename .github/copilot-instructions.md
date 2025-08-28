# World of Warcraft AddOns Repository - AI Coding Guidelines

## Project Overview

This repository contains World of Warcraft Classic AddOns written in Lua. Each addon is a self-contained directory providing UI enhancements, combat tracking, or utility features for the WoW Classic client.

## Addon Architecture Patterns

### Core Structure

Every addon follows the `.toc` + `.lua` pattern:

- **`.toc` files** define metadata and load order (e.g., `ParryHasteTracker.toc`)
- **Main `.lua` files** contain the addon logic (e.g., `ParryHasteTracker.lua`)
- **Multi-expansion support** via separate `.toc` files (`Addon_Classic.toc`, `Addon_Wrath.toc`, etc.)

### TOC File Format

```
## Interface: 11507               # Client version compatibility
## Title: Addon Display Name
## Notes: Brief description
## Author: Author Name
## Version: 1.0
## SavedVariables: AddonDB       # Persistent data storage
## OptionalDeps: Ace3, LibStub   # Optional library dependencies

MainFile.lua                     # Load order matters
```

### Lua Addon Pattern

Standard initialization follows this pattern:

```lua
-- Namespace creation
local ADDON_NAME, _ = ...
AddonName = {}
local addon = AddonName

-- Event frame setup
local frame = CreateFrame("Frame", "AddonEventFrame", UIParent)
frame:SetScript("OnEvent", function(self, event, ...)
    if addon[event] then
        addon[event](addon, ...)
    end
end)

-- Event registration
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
```

## Development Conventions

### Library Integration

- **Ace3 Framework**: Large addons use `libraries.xml` + `embeds.xml` pattern (see `Gargul/`, `Details/`)
- **LibStub**: Standard library loading mechanism
- **Embedded vs External**: Libraries can be embedded (`Libs/`) or listed as `OptionalDeps`

### File Organization

- **Simple addons**: Single `.lua` file (e.g., `ParryHasteTracker/`)
- **Complex addons**: Directory structure with `Classes/`, `Interface/`, `Data/` folders (e.g., `Gargul/`)
- **Localization**: `locales/` or `Localization/` for multi-language support

### Data Persistence

- Use `SavedVariables` in `.toc` for account-wide settings
- Use `SavedVariablesPerCharacter` for character-specific data
- Initialize with defaults: `AddonDB = AddonDB or {}`

### Combat & Event Handling

Focus on these WoW events for combat addons:

- `COMBAT_LOG_EVENT_UNFILTERED` for detailed combat parsing
- `PLAYER_ENTERING_WORLD` for initialization
- `ADDON_LOADED` for saved variable loading

## Key Integration Points

### UI Framework Dependencies

- **Frame creation**: Use `CreateFrame()` for UI elements
- **Event registration**: Register specific events, not blanket listeners
- **Settings persistence**: Leverage WoW's built-in SavedVariables system

### Cross-Addon Communication

- **Addon messaging**: Use `SendAddonMessage()` for raid coordination features
- **Library sharing**: Common libraries like LibStub, Ace3 enable addon interoperability

## Testing & Deployment

- **In-game testing**: Load addons via WoW client, use `/console scriptErrors 1` for debugging
- **Multiple expansions**: Test with appropriate `.toc` files for each WoW Classic version
- **SavedVariables**: Verify data persistence across login sessions

## Examples

- **Simple tracker**: `ParryHasteTracker/` - event-driven combat statistics
- **Complex framework**: `Gargul/` - multi-file structure with Classes, Interface layers
- **UI-heavy addon**: `Details/` - extensive frame management and data visualization

When working on addons, prioritize WoW API compatibility and performance - addons run in the game client's Lua 5.1 environment with strict memory and CPU constraints.

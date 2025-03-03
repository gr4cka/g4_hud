# g4_hud - Enhanced FiveM HUD

A lightweight, customizable HUD for FiveM servers with multi-framework support.

## Features

- **Multi-framework Support:**
  - ox_core
  - ESX (with esx_status)
  - QBCore
  - Standalone mode (without framework)

- **Status Indicators:**
  - Health
  - Armor
  - Hunger
  - Thirst
  - Stress
  - Energy/Stamina (ESX and standalone only where stress is not available)

- **Vehicle Information:**
  - Current Speed (km/h or mph)
  - Fuel Level

- **Performance Optimized:**
  - Efficient update intervals
  - Updates only when values change
  - Reduced resource usage

- **Status indicators:**
  - When status goes below 10% icon starts flashing.
  - When status is equal to 0 opacity of icon is reduced.

## Installation

1. Place the `g4_hud` folder in your FiveM server's resources directory
2. Add `ensure g4_hud` to your server.cfg
3. Configure the HUD in the `config.lua` file to meet your needs
4. Restart your server or start the resource

## Configuration

All configuration options are available in the `config.lua` file:

```lua
Config = {
    -- General settings
    isUnitMetric = true, -- false for imperial units (mph)
    
    -- Update intervals (milliseconds)
    updateInterval = 500, -- Default update interval
    vehicleUpdateInterval = 100, -- Update interval when in vehicle
    
    -- Display settings
    hideInPauseMenu = true, -- Hide HUD when pause menu is active
    
    -- Custom colors
    colors = {
        health = "#FF0000",
        armour = "#0000FF",
        hunger = "#FFA500",
        thirst = "#00FFFF",
        stress = "#800080",
        energy = "#FFFF00"
    },
}
```

## Framework-Specific Information

### ox_core
Automatically works with ox status events. Shows all status values provided by the framework.

### ESX (with esx_status)
Works with esx_status events to display hunger and thirst values.

### QBCore
Utilizes player metadata to display hunger, thirst, and stress values.

### Standalone Mode
When no framework is detected, the HUD will show basic information:
- Health
- Armor
- Energy/Stamina
- Vehicle data (when in a vehicle)

## Customization

The HUD interface can be customized by modifying the UI files in the `ui/src` directory. The UI is built with **Svelte 5** and **Tailwind CSS** for modern, responsive design and efficient reactivity. After making changes, you'll need to rebuild the UI:

```
cd ui
pnpm install
pnpm run build
```

## License

This resource is provided as-is. Feel free to modify and use as needed.

## Credits

- Original author: gr4cka 
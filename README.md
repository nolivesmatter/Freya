# Freya

Freya is a framework and template for developing with Roblox. Everything which Freya provides is designed to aid and accelerate the development of features on Roblox, alongside enabling other third-party developers to use the Freya infrastructure to provide inherent integration and compatability with existing code and other Freya-ready models.

## Features

- BaseLib libraries
- Intents
- Custom Events
- Input
- Admin
- Permissions
- OOP
- Colour palettes
- Extended type support
- Tween library
- `os.time` and `tick` parser.
- Translations support
- General utility
- Moonscript-optimized interfaces
- Valkyrie support

### Planned features

- Nevermore compatibility
- Networking management
- Player loading management
- Passive game rules
- Cancelable behaviour
- Extended Instance behaviour and management.

## Setting up Freya

### Adding it to your game

Adding Freya will be as simple as copying and pasting a small script into your command bar. Just, not right now. You can't test it yet.

### Configuring Freya

All active modules will have a BoolValue in them called `Enabled`. Ticking the checkbox in it will enable the module and it will load and run automatically, providing control through the configuration, and providing API through Intents as IPCs.

All passive modules can be loaded via the main Freya controller, or by requiring them manually.
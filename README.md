# Freya

Freya is a framework and template for developing with Roblox. Everything which Freya provides is designed to aid and accelerate the development of features on Roblox, alongside enabling other third-party developers to use the Freya infrastructure to provide inherent integration and compatibility with existing code and other Freya-ready models.

## Features

- BaseLib libraries
- Intents
- Custom Events
- Input
- Admin
- Permissions
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
- LiteLib libraries
- OOP

## Setting up Freya

### Adding it to your game

Currently, adding Freya to your game is simple: Because there are no branches to choose from for Freya, simply run `require(480740831)` in your Studio command bar and it will install Freya to your game. Isn't that easy? Freya can be found scattered about various services in folders called Freya.

### Configuring Freya

All active modules will have a BoolValue in them called `Enabled`. Ticking the checkbox in it will enable the module and it will load and run automatically, providing control through the configuration, and providing API through Intents as IPCs.

All passive modules can be loaded via the main Freya controller, or by requiring them manually. Their settings are handled via `Freya.Settings` in the relevant section.

## Why use Freya?

You would probably benefit from using Freya if you are:

- **Making a new game**<br>
  If you are making a new game, from scratch, you will benefit from being able to use Freya as a template for starting your game so that you can get straight to the content before you worry about all the little bits of polish which you might want to add. You'll also benefit from the utilities which Freya provides all the way through development, and the extended support provided by third-party modules supporting or relying on Freya.
- **A third-party developer**<br>
  As a third-party developer, you may find it convenient to use Freya's features to allow immediate integration and native support with games, in a higher level than would have previously been simple to implement due to a lack of standards or common hooks. Freya provides features convenient for anything from game templates and other frameworks, all the way through to simple weapons and zoning mechanisms.
- **Using a Freya-compatible model**<br>
  If you are using something else which has Freya compatibility, you may benefit from the additional integration it provides to your game. If you are using multiple Freya-compatible models, you may find that adding Freya also allows them to integrate with eachother and interface easily, allowing them to support eachother as if they were designed to be used together.
- **Using something which relies on Freya**<br>
  Some models may have Freya as a dependency, and will simply refuse to work without Freya. This may be because they were built around Freya, because they are designed as compatibility layers, or because they were designed as extensions to Freya. Whatever the reason is, you will need Freya in your game for them to work.

## What's in a name?

Freya (Freyja, traditionally) is the Norse god of a lot of things, but mostly the reason Freya was chosen is due to her relationship with valkyries, which made it a suitable name for the successor of the development section of [Valkyrie](https://github.com/CrescentCode/ValkyrieFramework)

## Acknowledgements

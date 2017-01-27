# Freya

Freya is a framework and template for developing with Roblox. Everything which Freya provides is designed to aid and accelerate the development of features on Roblox, alongside enabling other third-party developers to use the Freya infrastructure to provide inherent integration and compatibility with existing code and other Freya-ready models.

## Features

- [Extended Events](https://docs.crescentcode.net/Freya/Components/Events)
- [All-to-all networkable signals](https://docs.crescentcode.net/Freya/Components/Intents)
- [Powerful permissions](https://docs.cresentcode.net/Freya/Components/Permissions)
- [Stateful Input](https://docs.crescentcode.net/Freya/Components/Input)
- [Valkyrie](https://valkyrie.crescentcode.net/) support
- [Package management](https://docs.crescentcode.net/Freya/Core/Vulcan)
- Magical seamless wrappers ([BaseLib](https://docs.crescentcode.net/Freya/Libraries) and [LiteLib](https://docs.crescentcode.net/Freya/LiteLibraries))
- [Bit stream manipulation](https://docs.crescentcode.net/Freya/Components/BitStream)

### Planned features

- Nevermore compatibility
- Extended networking management
- Extended serialization/deserialization
- Freya package repository
- Extended game rules API
- Freya standards

## Setting up Freya

### Adding it to your game

Currently, adding Freya to your game is simple: Because there are no branches to choose from for Freya, simply run `require(480740831)` in your Studio command bar and it will install Freya to your game. Isn't that easy? Freya can be found scattered about various services in folders called Freya.

### Configuring Freya

All active modules will have a BoolValue in them called `Enabled`. Ticking the checkbox in it will enable the module and it will load and run automatically, providing control through the configuration, and providing API through Intents.

All passive modules can be loaded via the main Freya controller, or by requiring them manually. Their settings should handled via `Freya.Settings` in the relevant section, when available.

### Uninstalling Freya

Didn't like Freya? That's a shame. If you have FreyaStudio loaded, you can do `_G.Freya.Uninstall()` and it will clean up Freya for you. If you don't have FreyaStudio injected, you can load it with `require(game.ServerStorage.Freya.FreyaStudio)`.

## Why use Freya?

You would probably benefit from using Freya if you are:

- **Making a new game**<br>
  If you are making a new game, from scratch, you will benefit from being able to use Freya as a template for starting your game so that you can get straight to the content before you worry about all the little bits of polish which you might want to add. You'll also benefit from the utilities which Freya provides all the way through development, and the extended support provided by third-party modules supporting or relying on Freya.
- **A third-party developer**<br>
  As a third-party developer, you may find it convenient to use Freya's features to allow immediate integration and native support with games, in a higher level than would have previously been simple to implement due to a lack of standards or common hooks. Freya provides features convenient for anything simple weapons and zoning mechanics, all the way through to entire game templates and frameworks.
- **Using a Freya-compatible model**<br>
  If you are using something else which has Freya compatibility, you may benefit from the additional integration it provides to your game. If you are using multiple Freya-compatible models, you may find that adding Freya also allows them to integrate with eachother and interface easily, allowing them to support eachother as if they were designed to be used together.
- **Using something which relies on Freya**<br>
  Some models may have Freya as a dependency, and will simply refuse to work without Freya. This may be because they were built around Freya, because they are designed as compatibility layers, or because they were designed as extensions to Freya. Whatever the reason is, you will need Freya in your game for them to work.
  
## Where is the documentation?
The documentation can be found at [https://docs.crescentcode.net/Freya](), and provides examples and standards. If anything is missing, feel free to [contribute](https://github.com/CrescentCode/Enchiridion/tree/master/site/Freya) or [suggest some changes](https://github.com/CrescentCode/Enchiridion/issues)

## What's in a name?

Freya (Freyja, traditionally) is the Norse god of a lot of things, but mostly the reason Freya was chosen is due to her relationship with valkyries, which made it a suitable name for the successor of the development section of [Valkyrie](https://github.com/CrescentCode/ValkyrieFramework)

## Acknowledgements

- Freya BitStream uses a modified version of the [BitBuffer](https://www.roblox.com/library/174612085/BitBuffer-Module) module by [Stravant](https://www.roblox.com/users/80119/profile/). 

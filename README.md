# Pokedex-iOS
A native iOS app to browse Pokémon, view their details, and store a list of favourites on your device.

## Features
- Browse a list of Pokemon
- View detailed information about each Pokemon
- Search for Pokemons using name or ID
- Filter Pokemons based on their type (Fire, Ice, Water etc.)
- Add and manage your favourite Pokémon using SwiftData
- Supports landscape orientation. (iPhone and iPad)

## API Client
- Generated API client using [Swift OpenAPI Generator Plugin](https://github.com/apple/swift-openapi-generator) and the `openapi.yml` file available from [PokeAPI github repository](https://github.com/PokeAPI/pokeapi/)
- I made some modifications in the schema definitions of pokeapi's `openapi.yml` since they were incorrect. Eg. Some properties were null in the response but stated as required in the schema definition. 

## Requirements
- iOS 18.0+
- Xcode 16.4+
- Swift 6.0+

## Known Issues
- Delete icon on top left corner is visible sometimes even without selecting any pokemon, this is because items from a list can be selected by tapping on it without having to enter edit mode on iOS 16+. The workaround is to monitor `editMode` of the list using `.environment(\.editMode, $editMode)` viewModifier but doing so hides the check box on list items.
- Any api call in simulators in Xcode 16.3 will fail on subsequent runs due to a bug in the simulator. This is because simulators do not support HTTP/3 and QUIC. Refer this [page](https://developer.apple.com/forums/thread/777999) for more details.

---

Made with ❤️ using SwiftUI.

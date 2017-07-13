# Fighty Dot
Fighty Dot is a Swift implementation of [nine men's morris](https://en.wikipedia.org/wiki/Nine_Men%27s_Morris) for iOS.

[App store link](#) (**TODO**)

### Features
- Player vs. AI
- Player vs. Player (turn-based)
- Global leaderboards and analytics implemented with [Firebase](https://firebase.google.com/) (**TODO**)

### Motivation
> "You must begin by studying the endgame"

Nine men's morris is an interesting game. Get three pieces in a row (a "mill") and you can take an opponent's piece. Take all but two of your opponent's pieces and you win. It seems simple, but rushing in and making mills right from the start can leave you boxed in while your opponent is free to move and get into position for a counter-attack.

In some ways, the game can be seen as a battle between strength and manoeuvrability, which is a fight that comes up again and again in life, both metaphorically and literally.

Little wonder the game was apparently popular with the Romans too.

## Installation
Open FightyDot.xcworkspace in Xcode. The project should build cleanly, but you need to setup your own Firebase config :) 

### Firebase Setup (~10 minutes)
The Firebase pods are included in the project, so you don't need to download them.

You do need to get your own `GoogleService-Info.plist` file though. That way you can use your own API key, etc.
There are instructions on how to get this file [here](https://firebase.google.com/docs/ios/setup).

After you've copied over your `GoogleService-Info.plist` file, you'll need to set up your realtime database (**TODO**)

## Exploring the Code

### Architecture
The code is built using a standard Swift [delegation](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Protocols.html#//apple_ref/doc/uid/TP40014097-CH25-ID276) pattern.

The basic flow is as follows:

- `GameVC.swift` handles users interactions and passes them off to `Engine.swift` 
- `Engine.swift` handles the game logic, and holds references to the board, players and game state
- After `Engine.swift` has processed the game logic, it delegates view updates, animations and so on back to the view

The `ModelViews` encapsulate parts of the view that naturally belong together. For example, a `PlayerView` encapsulates all of the labels, counters, and icons for a player.

The board is described using an [adjacency list](https://en.wikipedia.org/wiki/Adjacency_list), with the related view images connected in storyboard.

`Animations.swift` contains some custom Core Animation animations, and `AudioPlayer.swift`...well, what do you think it does? :)

Both of these are pretty generic and could probably be reused or extracted to a separate library.

### AI 
(**TODO**)

## Screenshots
(**TODO**)

## Acknowledgements
### Fonts
Lato fonts are licensed under the [Open Font License](http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=OFL)

### Icons
Help page gesture and tap icons by Maxim Kulikov, obtained from nounproject.com under the [Creative Commons license](https://creativecommons.org/licenses/by/3.0/us/), with shadows added by app developer. 

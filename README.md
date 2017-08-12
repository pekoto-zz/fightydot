# Fighty Dot
Fighty Dot is a Swift implementation of [nine men's morris](https://en.wikipedia.org/wiki/Nine_Men%27s_Morris) for iOS.

[App store link](#) (**TODO**)

### Features
- Player vs. AI
- Player vs. Player (turn-based)
- Analytics implemented with [Firebase](https://firebase.google.com/)

### Motivation
> "You must begin by studying the endgame"

Nine men's morris is an interesting game. Get three pieces in a row (a "mill") and you can take an opponent's piece. Know your opponent down to two pieces and you win. It seems simple, but rushing in and making mills right from the start can leave you boxed in while your opponent is free to move and get into position for a counter-attack.

In some ways, the game can be seen as a battle between strength and manoeuvrability, which is a fight that comes up again and again in life, both metaphorically and literally.

Little wonder the game was apparently popular with the Romans too.

## Setup
Open FightyDot.xcworkspace in Xcode. The project should build cleanly, but you need to setup your own Firebase config :) 

### Firebase Setup (~10 minutes)
The Firebase pods are included in the project, so you don't need to download them.

You do need to get your own `GoogleService-Info.plist` file though. That way you can use your own API key, etc.
There are instructions on how to get this file [here](https://firebase.google.com/docs/ios/setup).

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
The AI player uses [negamax](https://en.wikipedia.org/wiki/Negamax) with alpha-beta pruning to make moves.
This is the same kind of algorithm that is used in chess or go AI to look ahead to all possible game states and pick the best possible move while restricting the best possible moves for the opponent (see more about the game theory [here](https://en.wikipedia.org/wiki/Minimax).

#### AI Challenges
There are three stages in nine men's morris: placing pieces, moving pieces, and flying pieces. Add to this the fact that players can potentially choose to take from selection of opponent pieces after moving and things can get a little tricky.

Debugging and checking correctness of minimax algorithms is tough due to the size of the tree, and the fact you must balance heuristic weighting. I've left a simple class, `TreeNode.swift`, which you can insert into the algorithm and print a tree of all the possible states to check correctness, if you want.

In general, the problem with the minimax family of algorithms (which negamax is a part of) is that they tend to lead to combinatorial explosion due to the number of possible game states. This is where pruning comes in: you can cut off ("prune") searches of possible game states by keeping track of the best possible values for the alternate players. By ordering the moves in terms of those that form mills, the pruning seems to work well, and I managed to get a decent lookahead in a reasonable time while running on iPhone.

Overall, I would say the AI plays a good game. I've only managed to beat it once or twice even on normal.
Setting the difficulty to easy will cut the lookahead distance to one -- probably the same as a beginner human player -- and should be relatively easy to beat if you know what you're doing.

#### Heuristic evalation
All minimax-type algorithms require a heuristic evalation function so that they can judge how good a game state is for a particular player. Nine men's morris is complicated that the game takes place in three phases: placing, moving, and flying. A good move in one phase is not necessarily a good move in another.

Fighty Dot uses the following heuristics:
* Whether a mill was closed
* The number of mills
* the number of blocked opponent pieces
* The number of player pieces on the board
* The number of two piece configurations (adding one more piece closes the mill)
* The number of three piece configurations (two two-piece configuration mills that intersect -- this is great during the placement phase because then your opponent can't stop you forming a mill)
* The number of open mills (A two-piece configuration where the empty piece has a neighbour that is the same colour. When moving, that piece can then be moved into the empty spot, forming a mill.)
* The number of double mills (a piece can be moved back and forth between two mills, completing one of them every turn)

These are based on the heuristics in [this](http://www.dasconference.ro/papers/2008/B7.pdf) paper, though I tweaked the weights for what seemed to give a better game.

See `HeuristicWeights.swift` for the code implementation and exact weights.

## Screenshots
(**TODO**)

## Acknowledgements
### Fonts
Lato fonts are licensed under the [Open Font License](http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=OFL)

### Icons
Help page gesture and tap icons by Maxim Kulikov, obtained from nounproject.com under the [Creative Commons license](https://creativecommons.org/licenses/by/3.0/us/), with shadows added by app developer. 

### More
If you like this app, you can check out another one I made [here](https://itunes.apple.com/us/app/stop-swipe-photos/id1104741007?mt=8).

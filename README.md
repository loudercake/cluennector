# Cluennector

Connect clues puzzle game.

# How to create levels

(Forget about json, it's not meant to, the thing is custom resources)

Inside `/levels/` there are 2 base resource files: `clue.tres` and `level.tres`. You can use those as base for clues and levels. The idea behind this is that we might want to make clues more than just an image and levels more than just a list of clues, scalability! A clue takes a texture (a png) and a description. You can copy those .tres, duplicate, etc, and double click on them from godot to edit then on the rigth pane.

The custom resource file `level.tres` takes two lists and another resource of the same type that is the next level. The list `story` is the textures in order to win the game. There is also the `decoy` list which are just red herrings (But that would be too long of a name for a variable so i called decoy). Their order doesn't matter.

This way you can have multiple of this level resource connect one to next.


Press backspace to reset the level and see the clues be randomly placed (this is just a debug mode thing).

# TODO

- [ ] Music
- [ ] Sound effects
- [ ] Main menu
- [ ] Animation effect on filling the board with clues
- [x] Fill board grid
- [x] Randomize clues order
- [ ] Draw canvas to connect clues (node connecting sorta system)
- [ ] Approach to clue on hover, show description
- [ ] Win effect
- [ ] Load next level on win
- [ ] If there is no next level, game beat win congratulations credits yay animation.

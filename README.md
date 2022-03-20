# Cluennector

Connect clues puzzle game. It includes a main mode (detective) and 3 extras: geography, history and pokemon,

Live demo at: https://cluennector.herokuapp.com/

This game was developed having in mind the march's 2022 godot game jam with the theme "connect".

## Detective

This is the main mode where you try to solve the crime by connecting the clues to the criminal.

## Geography

Connect the biggest country with its neighbors and them with their smaller neighbors as well. (Oh yeah that can be really hard).

## History

This mode can be imperfect because we are using wikipedia's api: https://api.wikimedia.org/wiki/API_reference/Feed/On_this_day

You must connect the things related to an event with the event itself. There can be multiple events on a same level that will be randomly generated from a same day/month of different years.


## Pokemon

This was created using the Pokeapi: https://pokeapi.co/

Your goal is to connect the pokemon evolutions. There can be multiple or none chains on a level and also unrelated pokemons to confuse you.


# How to create levels

Inside `/levels/` there are 2 base resource files: `clue.tres` and `level.tres`. You can use those as base for clues and levels. The idea behind this is that we might want to make clues more than just an image and levels more than just a list of clues, scalability! A clue takes a texture (a png) and a description. You can copy those .tres, duplicate, etc, and double click on them from godot to edit then on the rigth pane.

The custom resource file `level.tres` takes two lists and another resource of the same type that is the next level. The list `story` is the textures in order to win the game. There is also the `decoy` list which are just red herrings (But that would be too long of a name for a variable so i called decoy). Their order doesn't matter.

This way you can have multiple of this level resource connect one to next.


# TODO

- [x] Music
- [x] Sound effects
- [x] Fonts
- [ ] Better buttons, ui's, etc
- [x] Main menu
- [ ] Animation effect on filling the board with clues
- [x] Fill board grid
- [x] Randomize clues order
- [x] Draw canvas to connect clues (node connecting sorta system)
- [x] Approach to clue on hover, show description
- [x] Check connections validity
- [x] Win effect
- [x] Load next level on win
- [x] If there is no next level, game beat win congratulations credits yay animation.


# BUGS
- [ ] Something is wrong with the connections click handling (sometimes starts dashed line when it should just click)

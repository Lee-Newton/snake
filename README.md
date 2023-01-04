# **Snake** - By _Lee Newton_

# DESCRIPTION

This is a recreation of the famous game **"Snake"** coded in PowerShell. The game includes high quality sounds and a score card. Bragging rights are on the table for highest score but do remember this is PowerShell so sadly no raytracing but happily no 4090 required either.
Have fun playing the game, It isn't pretty but it sure was fun to create.

# REQUIREMENTS

- To play this game you will need to run the script in a PowerShell Core terminal.
- Bash, CMD , VSC integrated terminal or PowerShell 5.1 and below will **not** run this game.
- PowerShell window dimensions needs to be set at 105x40 as a minimum. There is no maximum window size.
- Sound will be set during the game to 50% of system volume ( you can alter this during the game )
- A keyboard that has arrow keys :)

If you do not have PowerShell Core you can find the latest version here
<https://tinyurl.com/2xuzvdc9> You can choose either the LTS or the Stable version I recommend you install the stable version.

# HOW TO PLAY

To start the game, open the PowerShell Core window and change directory to where the script is being ran from. Enter the command **_.\snake.ps1_** and hit the enter key.

Read the instructions from the screen and enter your name to begin the game. If at this point you want to quit just input **_exit_** and this will stop the game. A Three second timer will display in the centre of the gameboard, get ready with the arrow keys because once the timer ends the snake will be moving.
Use the arrow keys on your keyboard to direct the snake to the **_@_** symbol which will be randomly placed within the screen.

Every time the snake 'eats' an apple the snake will grow by _**1**_ and a new apple will appear in a random position. Each apple is worth _**50**_ points, the object of the game is to get as many points as you can without letting the snake touch its own body OR any of the walls. Please note once you have eaten an apple turning the snake directly backwards will direct the snake straight into its own tail.
The game ends when you hit a wall OR the snakes body.

# ABOUT ME

I am new to PowerShell scripting and wanted to apply my very limited knowledge to re-create this classic fun game. The code is in no way perfect and may well benefit from a lot of TLC, some best practises and some refactoring thrown in.
The only rubber stamp I am going to give this code is - as of today - _on my local machine_ - it works... **:)**

feel free to clone and alter the code as you see fit. Explore your imagination and most of all have fun with it.

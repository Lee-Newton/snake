
# |---------------------------------------------|
# |          The All New Snake Game             |
# |              By Lee Newton                  |
# |---------------------------------------------|

#display game title
function DisplayTitle() {
  Clear-Host
  $verticalSpace = 3
  $titleWidth = 50
  $currcoords.x = ($console.windowsize.width - $titleWidth) / 2
  $currcoords.y = $verticalSpace
  $console.cursorposition = $currcoords
  
  $titleContents = @(
    ('-' * $titleWidth),
    ((' ' * 14) + 'The All New Snake Game' + (' ' * 14)),
    " ",
    ((' ' * 18) + 'By Lecs - 2022' + (' ' * 18)),
    ('-' * $titleWidth)
  )
  for ($i = 0; $i -lt 5; $i++) {
    $currcoords.y = $verticalSpace + $i
    $console.cursorposition = $currcoords
    Write-Host $titleContents[$i] -ForegroundColor Magenta
  }
}
#display game instructions
function DisplayInstructions() {
  $verticalSpace = 12
  $currcoords.x = ($console.windowsize.width) / 8
  $currcoords.y = $verticalSpace
  $console.cursorposition = $currcoords

  # game instructions
  $instructions = @(
    [PSCustomObject]@{
      Number      = '[1]';
      Instruction = " Start the game by typing the command [start]"
    }
    [PSCustomObject]@{
      Number      = '[2]';
      Instruction = " A snake will appear in the middle of the game area and will auto move in a direction "
    }
    [PSCustomObject]@{
      Number      = '[3]';
      Instruction = " Using the arrow keys guide the snake to the apple on the screen"
    }
    [PSCustomObject]@{
      Number      = '[4]';
      Instruction = " Everytime the snake eats an apple its tail will grow by 1 and a new apple will appear"
    }
    [PSCustomObject]@{
      Number      = '[5]';
      Instruction = " For every apple eaten you will get 10 points"
    }
    [PSCustomObject]@{
      Number      = '[6]';
      Instruction = " Get as many points as you can without hitting the walls or the snakes own tail"
    }
    [PSCustomObject]@{
      Number      = '[7]';
      Instruction = " If the snake hits a wall or its own tail you loose!"
    }
    [PSCustomObject]@{
      Number      = '[8]';
      Instruction = " At the end of the game you will be given a total score"
    }
    [PSCustomObject]@{
      Number      = '[Hint]';
      Instruction = " Running this game in full screen mode will make life easier for you :)"
    }
  )
  Write-Host "[ INSTRUCTIONS ]" -ForegroundColor Cyan
  $currcoords.y += 1
  for ($i = 0; $i -lt $instructions.length; $i++) {
    $currcoords.y += 2
    $console.cursorposition = $currcoords
    Write-Host $instructions[$i].Number -NoNewline -ForegroundColor Cyan
    Write-Host $instructions[$i].Instruction -ForegroundColor Yellow
  }
  $currcoords.y += 5
  $console.cursorposition = $currcoords
  Write-Host "Good Luck and have fun!" -ForegroundColor Green
}
# draws the walls of the game
function DrawBorder() {
  Clear-Host
  for ($i = 0; $i -lt $gameWidth; $i++) {
    $currcoords.x = $borderSpacePerSide + $i 
    $currcoords.y = $borderSpacePerSide
    $console.cursorposition = $currcoords
  
    if ($currcoords.x -eq $borderSpacePerSide -and $currcoords.y -eq $borderSpacePerSide) {
      Write-Host "`u{2554}" -ForegroundColor red -NoNewline 
    } elseif ($currcoords.x -eq $borderSpacePerSide + ($gameWidth - 1) -and $currcoords.y -eq $borderSpacePerSide) {
      Write-Host -ForegroundColor red -NoNewline "`u{2557}"
    } elseif ($currcoords.x -gt $borderSpacePerSide -and $currcoords.x -lt $borderSpacePerSide + ($gameWidth - 1)) {
      Write-Host -ForegroundColor red -NoNewline "`u{2550}"
    }

    $currcoords.y = $borderSpacePerSide + ($gameHeight - 1)
    $console.cursorposition = $currcoords
    if ($currcoords.x -eq $borderSpacePerSide -and $currcoords.y -eq $borderSpacePerSide + ($gameHeight - 1)) {
      Write-Host -ForegroundColor red -NoNewline "`u{255A}"
    } elseif ($currcoords.x -eq $borderSpacePerSide + ($gameWidth - 1) -and $currcoords.y -eq $borderSpacePerSide + ($gameHeight - 1)) {
      Write-Host -ForegroundColor red -NoNewline "`u{255D}"
    } elseif ($currcoords.x -gt $borderSpacePerSide -and $currcoords.x -lt $borderSpacePerSide + ($gameWidth - 1)) {
      Write-Host -ForegroundColor red -NoNewline "`u{2550}"
    }
  
  }
  for ($i = $borderSpacePerSide + 1 ; $i -lt $borderSpacePerSide + ($gameHeight - 1); $i++) {
    $currcoords.x = $borderSpacePerSide
    $currcoords.y = $i
    $console.cursorposition = $currcoords
    Write-Host -ForegroundColor red -NoNewline "`u{2551}"
    $currcoords.x = $borderSpacePerSide + ($gameWidth - 1)
    $console.cursorposition = $currcoords
    Write-Host -ForegroundColor red -NoNewline "`u{2551}"
  }
  Write-Host "`n"
}

#draw the snake and remove the last position
function DrawSnake() {
  # $console.cursorposition = $snakePos
  # Write-Host " " -ForegroundColor green -BackgroundColor green
 
  switch ($direction) {
    UpArrow {
      $snakePos.y += $snake.count
      $console.cursorposition = $snakePos
      Write-Host " "
      $snakePos.y -= $snake.count
      break 
    }
    DownArrow {
      $snakePos.y -= $snake.count 
      $console.cursorposition = $snakePos
      Write-Host " "
      $snakePos.y += $snake.count
      break 
    }
    LeftArrow {
      $snakePos.x += $snake.count 
      $console.cursorposition = $snakePos
      Write-Host " "
      $snakePos.x -= $snake.count
      break 
    }
    RightArrow {
      $snakePos.x -= $snake.count 
      $console.cursorposition = $snakePos
      Write-Host " "
      $snakePos.x += $snake.count
      break 
    }
  }
}

#draw the apple making sure not to place it over the snake
function DrawApple() {
  $applePos.X = (Get-Random -min 8 -max ($console.windowsize.width - 8))
  $applePos.y = (Get-Random -min 8 -max ($console.windowsize.height - 8))
  $console.cursorposition = $applePos
  if ($applePos -eq $snakePos) {
    DrawApple
  } else {
    Write-Host "@" -ForegroundColor Cyan
  }
}

#move the snake
function MoveSnake {
  switch ($direction) {
    UpArrow { $snakePos.y --; break }
    DownArrow { $snakePos.y ++; break }
    LeftArrow { $snakePos.x --; break }
    RightArrow { 
      $snakePos.x = $snake[-1][0]
      $snakePos.y = $snake[-1][1]
      $console.cursorposition = $snakePos
      Write-Host " "
      $snakePos.x = $snake[0][0]
      $snakePos.y = $snake[0][1]
      $snakePos.x++
      $console.cursorposition = $snakePos
      Write-Host " " -ForegroundColor green -BackgroundColor green
      for ($i = 0; $i -lt ($snake.count - 1); $i++) {
        $snake[$i][0] = $snake[$i + 1][0]
        $snake[$i][1] = $snake[$i + 1][1]
      }
      break 
    }
  }
  Start-Sleep -Milliseconds 100
  # DrawSnake
}

#check to see if snake hit wall or its own tail
function CheckForCollision() {
  if (
    ($snakePos.x -gt ($gameWidth - 2) + $borderSpacePerSide) -or 
    ($snakePos.x -eq $borderSpacePerSide) -or
    ($snakePos.y -gt ($gameHeight - 2) + $borderSpacePerSide) -or
    ($snakePos.y -eq $borderSpacePerSide)
  ) {
    $script:gameFinished = $true
    $currcoords.x = ($console.windowsize.width / 2) - 4
    $currcoords.y = $console.windowsize.height / 2
    $console.cursorposition = $currcoords
    Write-Host "`Game Over" -ForegroundColor Red
  }
  if ($snakePos -eq $applePos) {
    $snake.add(@(1, 2))
    DrawApple
  }
}

#display game score 
function displayScore() {
  $currcoords.x = ($console.windowsize.width / 2) - 5
  $currcoords.y = ($console.windowsize.height / 2) + 1
  $console.cursorposition = $currcoords
  Write-Host "score : $score" -ForegroundColor Red
}

# |---------------------------------|
# |---------------------------------|
# |           Start Script          |
# |---------------------------------|
# |---------------------------------|


# ensure game is ran only in a powershell core window no VSC, CMD or PS5 allowed
if (($env:TERM_PROGRAM -eq "vscode") -or !($PSEdition -eq "core")) {
  Write-Host "`nThis script needs to be ran in a Powershell core window`n" -ForegroundColor Red
  exit
}

#check min window size
if ($host.ui.rawui.windowsize.width -lt 110 -or $host.ui.rawui.windowsize.height -lt 45) {
  Write-Host "`n this game requires a min window size of 100h x 50w - please increase window size to play this game`n" -ForegroundColor Red
  exit
}

#global Objects and variables defined 
$currcoords = New-Object System.Management.Automation.Host.Coordinates
$applePos = New-Object System.Management.Automation.Host.Coordinates
$snakePos = New-Object System.Management.Automation.Host.Coordinates
$console = $host.ui.rawui
$borderSpacePerSide = 3;
$gameWidth = [math]::Round($console.windowsize.width - ($borderSpacePerSide * 2) )
$gameHeight = [math]::Round($console.windowsize.height - ($borderSpacePerSide * 2) )
$score = 0
$snakePos.X = [math]::Round($console.windowsize.width / 2)
$snakePos.y = [math]::Round($console.windowsize.height / 2)
$snake = [System.Collections.Generic.List[array]]@($snakePos.x, $snakePos.y)
$direction = "RightArrow"
$gameFinished = $false

DisplayTitle
DisplayInstructions

# place command line at bottom of terminal window and wait for start command
$currcoords.x = 1
$currcoords.y = [math]::Round($console.windowsize.height - 2)
$console.cursorposition = $currcoords
$startGame = $(Write-Host "Command : " -NoNewline -ForegroundColor Cyan; Read-Host)

if ($startGame -ne "start") {
  Write-Host "`nInvalid command - game aborted! `n" -ForegroundColor Red
  exit
}

DrawBorder
$curSize = $console.CursorSize
$console.CursorSize = 0
# DrawSnake
DrawApple

while (!$gameFinished) {
  #this next while loop unblocks the ReadKey command and only blocks when a key is pressed and waiting in the buffer to be processed
  while ([Console]::KeyAvailable) {
    $keyPressed = [Console]::ReadKey($true)
    $direction = $keyPressed.Key
  }
  MoveSnake
  CheckForCollision
}

displayScore
$snake[-1][0]
$snake[0][0]
Write-Host $snake -NoNewline
#keep cmd line at bottom of window for end of game
$currcoords.x = 1
$currcoords.y = [math]::Round($console.windowsize.height - 2)
$console.cursorposition = $currcoords
$console.CursorSize = $curSize
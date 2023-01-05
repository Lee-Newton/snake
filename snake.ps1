
# |---------------------------------------------|
# |          The All New Snake Game             |
# |              By Lee Newton                  |
# |---------------------------------------------|

# ensure game is ran only in a powershell core window no VSC, CMD or PS5 allowed
if (($env:TERM_PROGRAM -eq "vscode") -or !($PSEdition -eq "core")) {
  Write-Host "`nThis script needs to be ran in a Powershell core window`n" -ForegroundColor Red
  exit
}

#check min window size
if ($host.ui.rawui.windowsize.width -lt 105 -or $host.ui.rawui.windowsize.height -lt 40) {
  Write-Host "`n this game requires a min window size of 105w x 40h - please increase window size to play this game`n" -ForegroundColor Red
  exit
}

# The following TypeDef is to access the Core Audio API. Original code used SendKeys but some users were reporting issues with this so the following boiler plate has been coppied, I have no knowledge as of yet of any support for automation hence this boilerplate code. skip along as this is only so I can access static classes like  'Volume' and 'Mute
Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;
[Guid("5CDF2C82-841E-4546-9722-0CF74078229A"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioEndpointVolume
{
    // f(), g(), ... are unused COM method slots. Define these if you care
    int f(); int g(); int h(); int i();
    int SetMasterVolumeLevelScalar(float fLevel, System.Guid pguidEventContext);
    int j();
    int GetMasterVolumeLevelScalar(out float pfLevel);
    int k(); int l(); int m(); int n();
    int SetMute([MarshalAs(UnmanagedType.Bool)] bool bMute, System.Guid pguidEventContext);
    int GetMute(out bool pbMute);
}
[Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDevice
{
    int Activate(ref System.Guid id, int clsCtx, int activationParams, out IAudioEndpointVolume aev);
}
[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDeviceEnumerator
{
    int f(); // Unused
    int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice endpoint);
}
[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] class MMDeviceEnumeratorComObject { }
public class Audio
{
    static IAudioEndpointVolume Vol()
    {
        var enumerator = new MMDeviceEnumeratorComObject() as IMMDeviceEnumerator;
        IMMDevice dev = null;
        Marshal.ThrowExceptionForHR(enumerator.GetDefaultAudioEndpoint(/*eRender*/ 0, /*eMultimedia*/ 1, out dev));
        IAudioEndpointVolume epv = null;
        var epvid = typeof(IAudioEndpointVolume).GUID;
        Marshal.ThrowExceptionForHR(dev.Activate(ref epvid, /*CLSCTX_ALL*/ 23, 0, out epv));
        return epv;
    }
    public static float Volume
    {
        get { float v = -1; Marshal.ThrowExceptionForHR(Vol().GetMasterVolumeLevelScalar(out v)); return v; }
        set { Marshal.ThrowExceptionForHR(Vol().SetMasterVolumeLevelScalar(value, System.Guid.Empty)); }
    }
    public static bool Mute
    {
        get { bool mute; Marshal.ThrowExceptionForHR(Vol().GetMute(out mute)); return mute; }
        set { Marshal.ThrowExceptionForHR(Vol().SetMute(value, System.Guid.Empty)); }
    }
}

'@
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
  $marginFromTop = 11
  $currcoords.x = ($console.windowsize.width) / 10
  $currcoords.y = $marginFromTop
  $console.cursorposition = $currcoords

  # game instructions
  $instructions = @(
    @('[1]', " Start the game by typing your name or exit the game by typing exit"),
    @('[2]', " A 3 second count down timer will begin - Get ready!"),
    @('[3]', " A moving snake will appear in the centre of the screen once the timer expires"),
    @('[4]', " Using the arrow keys, guide the snake to the apple on the screen"),
    @('[5]', " Everytime the snake eats an apple its tail will grow by 1 and a new apple will appear"),
    @('[6]', " For every apple eaten you gain 50 points"),
    @('[7]', " Get as many points as you can without hitting a wall or the snakes tail"),
    @('[8]', " If the snake hits a wall or its tail you loose!"),
    @('[9]', " At the end of the game you will be given a total score"),
    @('[NOTE]', " System Sound has been set to 50%. Mute your system now for a quiet game")
  )

  Write-Host "[ INSTRUCTIONS ]" -ForegroundColor Cyan
  $currcoords.y ++
  for ($i = 0; $i -lt $instructions.count; $i++) {
    $currcoords.y += 2
    $console.cursorposition = $currcoords
    Write-Host $instructions[$i][0] -NoNewline -ForegroundColor Cyan
    Write-Host $instructions[$i][1] -ForegroundColor Yellow
  }
  $currcoords.y += 4
  $console.cursorposition = $currcoords
  Write-Host "Good Luck and have fun!" -ForegroundColor Green
}

# draws the walls of the game
function DrawBorder() {
  Clear-Host
  function BorderPiece($unicode) {
    Write-Host -ForegroundColor red -NoNewline "$($unicode)"
  }
  for ($i = 0; $i -lt $gameWidth; $i++) {

    # position cursor for top border and corners
    $currcoords.x = $borderSpacePerSide + $i 
    $currcoords.y = $borderSpacePerSide
    $console.cursorposition = $currcoords

    # assign variables to keep IF checks readable 
    $topLeft = ($currcoords.x -eq $borderSpacePerSide -and $currcoords.y -eq $borderSpacePerSide)
    $topRight = ($currcoords.x -eq $borderSpacePerSide + ($gameWidth - 1) -and $currcoords.y -eq $borderSpacePerSide)
    $top = ($currcoords.x -gt $borderSpacePerSide -and $currcoords.x -lt $borderSpacePerSide + ($gameWidth - 1))

    if ($topLeft) {
      BorderPiece("`u{2554}")
    } elseif ($topRight) {
      BorderPiece("`u{2557}")
    } elseif ($top) {
      BorderPiece("`u{2550}")
    }

    # position cursor for the bottom border and corners
    $currcoords.y = $borderSpacePerSide + ($gameHeight - 1)
    $console.cursorposition = $currcoords

    # assign variables to keep IF checks readable 
    $bottomLeft = ($currcoords.x -eq $borderSpacePerSide -and $currcoords.y -eq $borderSpacePerSide + ($gameHeight - 1))
    $bottomRight = ($currcoords.x -eq $borderSpacePerSide + ($gameWidth - 1) -and $currcoords.y -eq $borderSpacePerSide + ($gameHeight - 1))
    $bottom = ($currcoords.x -gt $borderSpacePerSide -and $currcoords.x -lt $borderSpacePerSide + ($gameWidth - 1)) 

    if ($bottomLeft) {
      BorderPiece("`u{255A}")
    } elseif ($bottomRight) {
      BorderPiece("`u{255D}")
    } elseif ($bottom) {
      BorderPiece("`u{2550}")
    }
  }

  #left and right borders to finish off
  for ($i = $borderSpacePerSide + 1 ; $i -lt $borderSpacePerSide + ($gameHeight - 1); $i++) {
    $currcoords.x = $borderSpacePerSide
    $currcoords.y = $i
    $console.cursorposition = $currcoords
    BorderPiece("`u{2551}")
    $currcoords.x = $borderSpacePerSide + ($gameWidth - 1)
    $console.cursorposition = $currcoords
    BorderPiece("`u{2551}")
  }
  Write-Host "`n"
}

# display countdown timer 
function countDownTimer {
  $countdown = 3
  $currcoords.x = [math]::Round($console.windowsize.width / 2)
  $currcoords.y = [math]::Round($console.windowsize.height / 2)
  function Timer($seconds) {
    $console.cursorposition = $currcoords
    Write-Host "$seconds" -ForegroundColor green
    if ($OS.contains('Windows')) {
      $voice.speak("$($seconds)") > null
    } elseif ($OS.contains('Darwin')) {
      say "$($seconds)"
    }
  }
  for ($i = 0; $i -lt $countdown; $i++) {
    Timer($countdown - $i)
  }
}

#position segments of snake and draw snake
function DrawSnake() {
  # move the snake segments along
  for ($i = 0; $i -lt ($snake.count - 1); $i++) {
    $snake[$i][0] = $snake[$i + 1][0]
    $snake[$i][1] = $snake[$i + 1][1]
  }
  # Set the last segment to the current position
  $snake[-1][0] = $snakePos.x
  $snake[-1][1] = $snakePos.y

  #draw the snake
  for ($i = 0; $i -lt $snake.count; $i++) {
    $snakePos.x = $snake[$i][0]
    $snakePos.y = $snake[$i][1]
    $console.cursorposition = $snakePos
    Write-Host " " -ForegroundColor green -BackgroundColor green
  }
}

#draw the apple
function DrawApple() {
  $console.cursorposition = $applePos
  Write-Host "@" -ForegroundColor Cyan
}

#move the apple somewhere the snake is not.
function MoveApple() {
  $positionClear = $false;
  while (!$positionClear) {
    $applePos.X = (Get-Random -min 8 -max ($console.windowsize.width - 8))
    $applePos.y = (Get-Random -min 8 -max ($console.windowsize.height - 8))
    $positionClear = $true
    for ($i = 0; $i -lt ($snake.count - 1); $i++) {
      if ($applePos.x -eq $snake[$i][0] -and $applePos.y -eq $snake[$i][1]) {
        $positionClear = $false
      }
    }
  }
}

#move the snake position and remove the old snake position from screen
function MoveSnake {
  $snakePos.x = $snake[0][0]
  $snakePos.y = $snake[0][1] 
  $console.cursorposition = $snakePos
  Write-Host " "
  switch ($direction) {
    UpArrow { 
      $snakePos.y = $snake[-1][1]
      $snakePos.x = $snake[-1][0]
      $snakePos.y--
      break 
    }
    DownArrow { 
      $snakePos.y = $snake[-1][1]
      $snakePos.x = $snake[-1][0]
      $snakePos.y++
      break 
    }
    LeftArrow { 
      $snakePos.x = $snake[-1][0]
      $snakePos.y = $snake[-1][1]
      $snakePos.x--
      break 
    }
    RightArrow {
      $snakePos.x = $snake[-1][0]
      $snakePos.y = $snake[-1][1]
      $snakePos.x++
      break 
    }
  }
}

#check to see if snake hit a wall or its own body
function CheckForCollision() {
  #wall
  $hitLeft = ($snakePos.x -eq $borderSpacePerSide)
  $hitRight = ($snakePos.x -gt ($gameWidth - 2) + $borderSpacePerSide)
  $hitTop = ($snakePos.y -eq $borderSpacePerSide)
  $hitBottom = ($snakePos.y -gt ($gameHeight - 2) + $borderSpacePerSide)

  if ( $hitRight -or $hitLeft -or $hitBottom -or $hitTop) {
    $script:gameFinished = $true
  }
  #body
  for ($i = 0; $i -lt $snake.count - 1; $i++) {
    if ($snakePos.x -eq $snake[$i][0] -and $snakePos.y -eq $snake[$i][1]) {
      $script:gameFinished = $true
    }
  }
}

#display game score 
function displayScore() {
  $currcoords.x = ($console.windowsize.width / 2) - 6
  $currcoords.y = $console.windowsize.height / 2
  if ($OS.contains('Windows')) {
    [console]::beep(630, 40) 
    [console]::beep(500, 100)
    [console]::beep(350, 200)
    [console]::beep(150, 350)
  }
  $console.cursorposition = $currcoords
  Write-Host "[  Game Over  ]" -ForegroundColor Red
  $currcoords.y++
  $console.cursorposition = $currcoords
  $score = ($snake.count - 1) * 50
  Write-Host "  Score : $score " -ForegroundColor Red
  Start-Sleep -Milliseconds 1000 
  if ($OS.contains('Windows')) {
    $voice.speak(" Game Over $($playerName). Your score was $($score)") > null
  } elseif ($OS.contains('Darwin')) {
    say " Game Over $($playerName). Your score was $($score)"
  }

}

#set system volume level - this is no longer needed as using the Audio API. keeping for refrence sake only - no calls made to this function
function SetSystemVolume($volume) { 
  $wshShell = New-Object -com wscript.shell
  1..50 | ForEach-Object { $wshShell.SendKeys([char]174) }
  $volume = $volume / 2
  1..$volume | ForEach-Object { $wshShell.SendKeys([char]175) }
}

# |---------------------------------|
# |---------------------------------|
# |           Start Script          |
# |---------------------------------|
# |---------------------------------|

#global Objects and variables defined
$currcoords = New-Object System.Management.Automation.Host.Coordinates
$applePos = New-Object System.Management.Automation.Host.Coordinates
$snakePos = New-Object System.Management.Automation.Host.Coordinates
$console = $host.ui.rawui
$OS = $PSVersionTable.OS
$borderSpacePerSide = 3;
$gameWidth = [math]::Round($console.windowsize.width - ($borderSpacePerSide * 2) )
$gameHeight = [math]::Round($console.windowsize.height - ($borderSpacePerSide * 2) )
$score = 0
$snakePos.X = [math]::Round($console.windowsize.width / 2)
$snakePos.y = [math]::Round($console.windowsize.height / 2)
$snake = [Collections.Generic.List[array]]@($snakePos.x, $snakePos.y)
$direction = "RightArrow"
$gameFinished = $false
$voice = New-Object -ComObject Sapi.spvoice
DisplayTitle
DisplayInstructions
if ($OS.contains('Windows')) {
  [Audio]::Mute = $false
  [Audio]::Volume = 0.50
}

# place command line at bottom of terminal window and wait for start command
$currcoords.x = 1
$currcoords.y = [math]::Round($console.windowsize.height - 2)
$console.cursorposition = $currcoords
$playerName = $(Write-Host "Name : " -NoNewline -ForegroundColor Cyan; Read-Host)

if ($playerName -eq "exit") {
  Write-Host "`ngame aborted - Goodbye `n" -ForegroundColor Red
  exit
}
if ($OS.contains('Windows')) {
  $curSize = $console.CursorSize
  $console.CursorSize = 0
}
DrawBorder
countDownTimer
DrawSnake
MoveApple
DrawApple

while (!$gameFinished) {
  #this next while loop unblocks the ReadKey command and only blocks when a key is pressed and waiting in the buffer to be processed
  while ([Console]::KeyAvailable) {
    $keyPressed = [Console]::ReadKey($true)
    $direction = $keyPressed.Key
  }
  MoveSnake
  CheckForCollision
  if ($snakePos -eq $applePos) {
    $snake.add(@($null, $null))
    if ($OS.contains('Windows')) {
      [console]::beep(450, 20)
    }
    MoveApple
    DrawApple
  }
  DrawSnake
  Start-Sleep -Milliseconds 50
}
displayScore

#keep cmd line at bottom of window for end of game
$currcoords.x = 1
$currcoords.y = [math]::Round($console.windowsize.height - 2)
if ($OS.contains('Windows')) {
  $console.cursorposition = $currcoords
  $console.CursorSize = $curSize
}
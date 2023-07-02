# Place next to your option folder
# Right click -> Run with powershell

$enc = New-Object System.Text.UTF8Encoding $False

function String-To-Bytes ($x) {
  return $enc.GetBytes($x)
}

function Count-Resource ($filename) {
  return $(gci -r -fi "*$($filename)").Count
}

function Unlock-MusicResource ($filename) {
  $locked = String-To-Bytes "<PossessingFromTheBeginning>false</PossessingFromTheBeginning>"
  $unlocked = String-To-Bytes "<PossessingFromTheBeginning>true</PossessingFromTheBeginning>"
  $lockedNext = String-To-Bytes "<IsLockedAtTheBeginning>true</IsLockedAtTheBeginning>"
  $unlockedNext = String-To-Bytes "<IsLockedAtTheBeginning>false</IsLockedAtTheBeginning>"
  $x = 0

  gci -r -fi "*$($filename)" | ForEach-Object {
    $filename = $_.FullName
    $filenamebak = "$filename.bak"

    if (-not (Test-Path "$filenamebak")) {
      $x++
      Write-Host "Unlocking $filename"
      cp "$filename" "$filenamebak"

      $data = [System.IO.File]::ReadAllBytes("$filenamebak")
      $data = [Byte[]]("$data" -Replace "\b$locked\b", "$unlocked" -Split '\s+')
      $data = [Byte[]]("$data" -Replace "\b$lockedNext\b", "$unlockedNext" -Split '\s+')
      [System.IO.File]::WriteAllBytes("$filename", $data)
    } else {
      Write-Host "Already unlocked $filename"
    }
  }

  return $x
}

function Restore-Resource ($filename) {
  $x = 0

  gci -r -fi "*$($filename).bak" | ForEach-Object {
    $filenamebak = $_.FullName
    $filename = $filenamebak.replace('.bak', '')

    $x++
    Write-Host "Restoring $filename"
    cp -force "$filenamebak" "$filename"
    rm "$filenamebak"
  }

  return $x
}

while($true)
{
  Write-Host "----------------------------------------"
  Write-Host "O.K.G.E.K.I Resource Unlocker"
  Write-Host "----------------------------------------"
  Write-Host "Found $(Count-Resource 'Music.xml') song(s), with $(Count-Resource 'Music.xml.bak') force unlock(s)"
  Write-Host "----------------------------------------"
  Write-Host "Press [1] to force unlock all songs"
  Write-Host "Press [2] to restore all songs to original state"
  Write-Host "Press any other key to exit"
  Write-Host "----------------------------------------"
  $key = $Host.UI.RawUI.ReadKey().Character
  Write-Host ""
  if ($key -eq "1") {
    $x += Unlock-MusicResource "Music.xml"
    Write-Host "Unlocked $($x) song(s)"
  } elseif ($key -eq "2") {
    $x = Restore-Resource "Music.xml"
    Write-Host "Restored $($x) song(s)"
  } else {
    Write-Host "----------------------------------------"
    Write-Host "Exiting..."
    Write-Host "----------------------------------------"
    break
  }
  Write-Host ""
}

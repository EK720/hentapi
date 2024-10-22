<#
.SYNOPSIS
    Just another imageboard API linkgrabber, with image tagging as well as download & update support.
    It's more of a passion project than something that fills a need, though I hope it works well for you.

.DESCRIPTION
    A more detailed description of what the function does. (remember to add)

.PARAMETER Server
    Specifies the server (website) that will be searched.
    Arguments should be simple domain names. (i.e. "example.com") or "*" to search all servers.

.PARAMETER Tags
    The tags that will be searched for. Use " " to see all posts (maybe).
    *Cannot be used with -Post.

.PARAMETER Post
    The post ID # to retrieve.
    *Cannot be used with -Tags.

.PARAMETER ListServers
    Specify this option to list servers from the config file as a string array.
    *This option overrides most others.
    
.PARAMETER ToClipboard
    If this parameter is specified, the program will output directly to your clipboard instead of the CLI.
    *Does not work with -Download or -Update.

.PARAMETER Count
    If this parameter is specified, only the amount of posts matching the command will be output.
    This parameter overrides ALL other options.

.PARAMETER ServerConfig
    Here you can give a path to a custom configuration file. I don't think this one works, but I don't care.
    Every time the program is run, it checks for a config file, and generates one if it doesn't exist.
    Let's say (for the sake of argument), that you got a really full config file from somewhere else.
    Perhaps you got one from the Internet because you didn't want to waste hours going through API docs. Sensible.

    Move that file to the same directory as this script, and boom. It'll be loaded the next time hentapi runs.
    Easy. Simple. Why did I add this option? Nobody's going to have that much trouble with this.

.PARAMETER UserConfig
    TBA

.PARAMETER Download
    This one's actually 2 parameters, but don't worry too much about that. If you want to download the results of
    your search, you would use this option with the output directory as the argument. If no argument is given, it 
    defaults to your current directory. Have fun..
    *Cannot be used with -Update

.PARAMETER Array
    If this parameter is specified, the program will output raw result data in various forms. this is kinda one 
    of those "only use if you know what you're doing" options, since the raw output can get a little confusing.

.PARAMETER Update
    Similar to -Download, this option updates from an already existing collection. Just run it in a folder
    that has already had stuff downloaded to it and watch it work its magic!
    *Cannot be used with -Download

.PARAMETER Recurse
    Makes update commands search for collections recursively down the file structure.

.PARAMETER IgnoreHashCheck
    Skips MD5 hash checking for all downloads. This can be used when you don't care about possible data
    corruption, or when your downloads are breaking for seemingly no reason. Most well-known imageboards
    compress large videos, which can lead to the verification hash and the actual file hash being
    different even though the file isn't corrupted.

.PARAMETER MD5
    This program names downloaded files after their IDs by default. Use this parameter to instead name
    the files after their MD5 hash.

.EXAMPLE
    The example below would return links for all images with Gardevoir that are SFW from e621.net.
    PS C:\> hentapi -Server e621.net -Tags "gardevoir rating:safe"

.EXAMPLE
    The example below downloads post #177013 from gelbooru.com to the current folder.
    PS C:\> hentapi -Server gelbooru -Post 177013 -Download

.EXAMPLE
    The example below checks the amount of posts matching the VTuber "Amelia Watson" on your self-hosted booru, and returns the total post count.
    PS C:\> hentapi -Server mybooru -Tags amelia_watson -Count
    273

.NOTES
    Author: Fuzion
    Created: 2019-04-30
    Last Edit: 2024-10-22
    Version 1.0 - this is a thing now
    Version 1.1 - now allows you to search by post ID and put output directly into your clipboard
    Version 1.2 - you can now use the -ListServers argument to list all servers in the config file
    Version 1.3 - made this cool helpfile thing actually work
    Version 1.4 - added verbose output
    Version 1.5 - fixed a weird bug where some API clients start from 0
    Version 1.6 - added the -Count option
    Version 1.7 - added the -Download option but it doesn't work yet
    Version 1.8 - added the ability to search all servers by using * in place of the server name
    Version 1.9 - made the -Download option work (mostly) and added the -Array option to output raw post data
    Version 2.0 - It's really come a long way from 1.0, hasn't it? Anyway, in this version I made the -Download option record tags & ratings on the posts it downloads, added a much more polished progress bar, and implemented some basic MD5 error checking. You're welcome!
    version 2.1 - added -Update. it's only half implemented because I'm tired and it's 4 am on a school night.
    Version 2.11- Made -Update work better, but it's not perfect yet. I'll get there.
    Version 2.2 - Changed download mode to asynchronous and added a LOT of progress bars. i have a lot of work at the moment, so I wasn't able to polish this or 2.1 yet. There'll hopefully soon be a "general polish" update, because things are getting pretty rough in here.
    Version 2.3 - kind of polished stuff, but progress bars are still shit.
    Version 2.33- A bit more polish, but not quite there yet.
    Version 2.35- Added more polish, fixed some progress bars, made it less likely for special characters to break the tagging system. More polished but still not shiny.
    Version 2.37- Added a neat new feature: If a post fails to download due to a 404 or something, download the post yourself and put it in the download dir with the name [id].[ext]meta, where [id] is whatever the program told you failed to download, and [ext] is just the default extension of the image.
    Version 2.39- 2.4 will be polished, I swear. Added the "-Recurse" option for updates.
    Version 2.4 - Finally polished the progress bars and this help file. Happy new year!
    Version 2.5 - Added json support, but the page/post count is a bit wonky now. I might be able to fix it but I really don't care right now. This was a giant ordeal and I had to rework most of the program to get this working. Have fun.
    Version 2.6 - Polished code for first Github release, and laid the foundations for a large rework of the configuration system.
    Version 2.7 - Massively reworked the config file system, which will make it much easier and smoother to add new servers and server types. I also added the -Limit option, which can be used to limit the amount of posts you get from a query.
    Version 2.72- Made some general improvements to efficiency.
    Version 2.75- Added Sankaku Complex as a server type and made some general internal improvements.
    Version 2.8 - Added a way to remove servers from your configuration. Just use the -Remove option with the server you want to delete.
    Version 2.81- Made the program work better on other operating systems.
    Version 2.9 - Made -Count and -Update more efficient and user-friendly.
    Version 2.92- Made the program more efficient and less buggy.
    Version 2.94- Fixed a small bug involving video files not being tagged correctly.
    Version 2.96- Over a year since last update... Anyway, I fixed a bug that resulted in query files for a collection being fucked up if the update errored while working on that collection.
    Version 2.98- Changed the update system to be resumable (e.g no files are fucked up if a crash occurs mid-update). Large overhaul of update system.
    Version 2.99- Fixed some miscellaneous bugs and improved performance. Version 3 will have booru.org support and then the program will pretty much be finished.
    Version 3.0 - Finally added booru.org and gelbooru 0.1 support, and now I believe this program is pretty much complete. If I find some terrible bugs or get inspiration for new good features, there may be another update. (bugfix update likely)
    Version 3.01- Fixed bugs with the Paheal and Sankaku APIs. You should see far less errors now.
#>
[CmdletBinding(DefaultParameterSetName='TagSearch')]
Param(
    [parameter(Mandatory,ParameterSetName="TagSearch",ValueFromPipeline,HelpMessage="The server that will be queried. Use -ListServers for a list of already configured servers.")]
    [parameter(Mandatory,ParameterSetName="PostSearch",ValueFromPipeline,HelpMessage="The server that will be queried. Use -ListServers for a list of already configured servers.")]
    [parameter(Mandatory,ParameterSetName="RemoveServer",ValueFromPipeline,HelpMessage="The server that will be removed. Use -ListServers for a list of servers.")]
    [alias("ServerURL","URL")]
    [string]
    $Server,

    [string]
    $ServerConfig = "$PSScriptRoot\server-config.dat",

    [string]
    $UserConfig = "$PSScriptRoot\user-config.dat",

    [parameter(Mandatory,ParameterSetName="ListServers",HelpMessage="Prints a list of all servers in the config file.")]
    [alias("ListServer")]
    [switch]
    $ListServers,

    [parameter(Mandatory,ParameterSetName="TagSearch",HelpMessage="The tag(s) to search.")]
    [alias("Tag")]
    [string]
    $Tags,

    [parameter(Mandatory,ParameterSetName="PostSearch",HelpMessage="The ID of the post you want. This may not work with some servers.")]
    [alias("ID","PID","Posts")]
    [int]
    $Post,

    [parameter(ParameterSetName="PostSearch")]
    [parameter(ParameterSetName="TagSearch")]
    [switch]
    $ToClipboard,

    [switch]
    $Count,

    [alias("DownloadTo","DownloadPath","DownloadLocation", "dl")]
    [parameter(ParameterSetName="PostSearch")]
    [parameter(ParameterSetName="TagSearch")]
    [switch]
    $Download,

    [parameter(ParameterSetName="PostSearch",ValueFromRemainingArguments)]
    [parameter(ParameterSetName="TagSearch",ValueFromRemainingArguments)]
    [parameter(ParameterSetName="Update",ValueFromRemainingArguments)]
    [string]
    $DLPath=$PWD.Path,

    [parameter(ParameterSetName="PostSearch")]
    [parameter(ParameterSetName="TagSearch")]
    [switch]
    $MD5,

    [alias("arr","raw")]
    [switch]
    $Array,

    [parameter(Mandatory,ParameterSetName="Update")]
    [alias("upd8", "upd")]
    [switch]
    $Update,

    [parameter(ParameterSetName="PostSearch")]
    [parameter(ParameterSetName="TagSearch")]
    [parameter(ParameterSetName="Update")]
    [switch]
    $IgnoreHashCheck,

    [parameter(ParameterSetName="Update",HelpMessage="Makes updater search for collections recursively through the file structure from where the command was run.")]
    [alias("r","Recursive")]
    [switch]
    $Recurse,

    [parameter(ParameterSetName="TagSearch",HelpMessage="Limits the maximum amount of posts this program will output/download.")]
    [alias("lim","max")]
    [int]
    $Limit=-1,

    [parameter(Mandatory,ParameterSetName="RemoveServer")]
    [switch]
    $Remove
)

#functions
function Add-Metadata {
    param([string]$Path, $Post)
    Write-Progress -Activity "Editing file" -Status " " -PercentComplete 0 -ParentId 0 -Id 1
    
    if($Post.tags.getType().Name -eq "String"){
        $tagsList = $Post.tags.Split(" ")
    }

    if($Post.ext -ne $null){
        $oldFile = Get-Item $Path
        Rename-Item $Path ($oldFile.BaseName + "." + $Post.ext)
        $Path = ($oldFile.DirectoryName + "\" + $oldFile.BaseName + "." + $Post.ext)
    }

    $metaTags = $tagsList -join ";"
    $file = Get-Item $Path
    $name = $file.BaseName
    $PathDir = $file.DirectoryName + "\"
    $oldExt = $Path.split(".")[-1]
    $ext=$oldExt
    
    $metaTags = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($metaTags))

    try {
        if($writable -eq $null){
            $global:writable = (exiftool -listwf) -join ""
        }

        switch($oldExt){
            "png" {
                Write-Progress -Activity "Editing file" -Id 1 -Status "Changing filetype (png -> jpg)" -PercentComplete 50 -ParentId 0
                mogrify -format jpg $Path
                del $Path
                $Path = $PathDir + $name + ".jpg"
                $ext="jpg"
            }

            "webm"{
                Write-Progress -Activity "Editing file" -Id 1 -Status "Changing filetype (webm -> mp4, may take a while)" -PercentComplete 50 -ParentId 0
                ffmpeg -i $Path "$PathDir$name.mp4" -hide_banner -loglevel panic > $null
                del $Path
                $Path = "$PathDir$name.mp4"
                exiftool -Artist="${Server}" $Path -overwrite_original -q -ignoreMinorErrors
                $ext="mp4"
            }

            "webp"{
                Write-Progress -Activity "Editing file" -Id 1 -Status "Changing filetype (webp -> jpeg)" -PercentComplete 50 -ParentId 0
                mogrify -format jpeg $Path
                del $Path
                $Path = "$PathDir$name.jpeg"
                $ext="jpeg"
            }
        }
        
        if($writable.indexOf($ext.ToUpper()) -eq -1){
            Write-Verbose ("Unsupported file format (." + $ext + "), skipping metadata write.")
            return
        }

        if($Post.rating -match "^s" -or $Post.rating -ieq "safe"){
            $rating=1
        }elseif($Post.rating -match "^q" -or $Post.rating -ieq "questionable"){
            $rating=2
        }elseif($Post.rating -match "^e" -or $Post.rating -ieq "explicit"){
            $rating=3
        }else{
            $rating=0
        }

        $time = $Post.created_at
        if($time -eq $null){
            $time = $Post.uploaded
        }
        
        try{
            if($ssconfig.format -eq $null) {
                $creationTime = Get-Date $time
            } elseif($ssconfig.format -eq "unix"){
                [dateTime]$origin = '1970-01-01 00:00:00'
                $creationTime = $origin.addSeconds($time)
            }else{
                $creationTime = [dateTime]::ParseExact($time,$ssconfig.format,$null)
            }
        } catch{
            Write-Verbose "The time format was wrong. This could be caused by a lot of things, but I'd have to take a look at it to figure it out. Oops!"
            Write-Verbose "Here's the error:`n"$_
            $creationTime = Get-Date
        }
        
        Write-Progress -Activity "Editing file" -Status "Writing metadata (tags/author/date)" -PercentComplete 75 -Id 1 -ParentId 0
        if($ext -eq "mp4"){
            ffmpeg -i $Path -metadata genre="${metaTags}" -c copy "${PathDir}tmp_$name.mp4" -hide_banner -loglevel panic > $null
            Remove-Item $Path
            Rename-Item "${PathDir}tmp_$name.mp4" $Path
        }
        exiftool -Artist="${Server}" -XPKeywords="${metaTags}" -Rating="${rating}" $Path -overwrite_original -q -ignoreMinorErrors
        (get-item $Path).CreationTime = $Post.uploaded
    }
    catch [System.SystemException] {
        Write-Verbose "ExifTool/ImageMagick/FFMpeg not found. Not writing image metadata..."
    }
    Write-Progress -Activity "Editing file" -Status "All operations complete." -PercentComplete 100 -ParentId 0 -Id 1 -Completed
    return $ext
}

function HashCheck {
    param([string]$Path, $Post, [int]$Count=1)
    
    $maxTries=3
    Write-Progress -Activity "Checking file hash.." -PercentComplete 0 -ParentId 0 -Id 1

    if($Count -gt $maxTries){
        Write-Warning ("Gave up on file `"${Path}`" after " + ($Count-1) + " attempts.")
        return
    }

    if($ignoreHashCheck -or ($Post.md5 -eq "SKIP")){
        return
    }

    $DL=New-Object System.Net.WebClient
    $DL.Headers['User-Agent']=$UserAgent

    if((Test-Path $Path) -eq $false){
        Write-Verbose ("File `"${Path}`" was not successfully downloaded, retrying...(" + $Count + ")")
        try{
            $DL.DownloadFile($Post.file, $Path)
        } catch{
            throw "$_`nAn error has occurred during the download of file `"$($Post.file)`" to $Path."
            #remove this line to see the real error location ^
            exit
        }
        HashCheck -Path $Path -Post $Post
        return
    }else{
        Write-Progress -Activity "Checking file hash.." -Status "Hashing file (Attempt $Count of $maxTries)" -PercentComplete 50 -ParentId 0 -Id 1
        $hash = (get-fileHash $Path -algorithm MD5).hash
    }
    
    if($hash -eq $Post.md5){
        if($Count -gt 1){
            Write-Verbose ("Successfully downloaded file `"" + $Path + "`" after " + $Count + " attempts.")
        }
        Write-Progress -Activity "Checking file hash.." -Status "Successfully verified file integrity" -PercentComplete 100 -ParentId 0 -Id 1 -Completed
        return
    }
        
    Write-Verbose ("MD5 hashes for file `"" + $Path + "`" do not match, retrying...(" + $Count + ")")
    while(Test-Path $Path){del $Path}
    try{
        $DL.DownloadFile($Post.file, $Path)
    }
    catch{
        if($_.ToString().Contains("(404) Not Found")){
            Write-Warning ("Error 404 on post #"+$Path.split("\")[-1].Split(".")[0]+", skipping..")
            return
        } else {
            throw $_
        }
    }
    HashCheck -Path $Path -Post $Post -Count $($Count+1)

    return
}

function ToBase64{
    param([parameter(ValueFromRemainingArguments=$true)][string]$in)
    
    $input=$in
    $bytes=[System.Text.Encoding]::Unicode.GetBytes($input)
    $encodedText=[Convert]::ToBase64String($bytes)
    return $encodedText
}

function FromBase64{
    param([parameter(ValueFromRemainingArguments=$true)]$in,[string]$enc="unset")
    if($enc -ne "unset"){
        $input=$enc
        $decodeText=[System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($input))
        return $decodeText
    }

    try{
        $encoded = $in
        
        if((Test-Path $in) -and (get-item $in).mode -eq "-a----"){
            $encoded = Get-Content $in
        }
        
        if($encoded.getType().BaseType.Name -eq "Array"){
            $decoded = $encoded
            for($i=0;$i -lt $decoded.Length;$i++){
                $decoded[$i] = FromBase64 -enc $encoded[$i]
            }
            return $decoded
        }else{
            return FromBase64 -enc $encoded
        }
    }catch{
        #throw $_
        return FromBase64 -enc $in
    }
}

function Clear-Lines {
    Param([Parameter(Position=1)][int32]$Count=1)

    $CurrentLine  = $Host.UI.RawUI.CursorPosition.Y
    $ConsoleWidth = $Host.UI.RawUI.BufferSize.Width

    $i = 1
    for ($i; $i -le $Count; $i++) {
	
	    [Console]::SetCursorPosition(0,($CurrentLine - $i))
	    [Console]::Write("{0,-$ConsoleWidth}" -f " ")

    }

    [Console]::SetCursorPosition(0,($CurrentLine - $Count))
}

Function Create-Menu {
    Param(
        [Parameter(Mandatory=$True)][String]$MenuTitle,
        [Parameter(Mandatory=$True)][array]$MenuOptions,
        [int]$DefaultSelection = 0
    )
    $MaxValue = $MenuOptions.count-1
    $Selection = $DefaultSelection % $MenuOptions.Count
    $EnterPressed = $False
    While($EnterPressed -eq $False){
        Write-Host "$MenuTitle"
        For ($i=0; $i -le $MaxValue; $i++){
            If ($i -eq $Selection){
                Write-Host -BackgroundColor Cyan -ForegroundColor Black "[ $($MenuOptions[$i]) ]"
            } Else {
                Write-Host "  $($MenuOptions[$i])  "
            }

        }
        $KeyInput = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown").virtualkeycode
        Switch($KeyInput){
            13{
                $EnterPressed = $True
                Return $Selection
                Clear-Lines ($MenuOptions.Length+1)
                break
            }
            38{
                If ($Selection -eq 0){
                    $Selection = $MaxValue
                } Else {
                    $Selection -= 1
                }
                Clear-Lines ($MenuOptions.Length+1)
                break
            }
            40{
                If ($Selection -eq $MaxValue){
                    $Selection = 0
                } Else {
                    $Selection +=1
                }
                Clear-Lines ($MenuOptions.Length+1)
                break
            }
            Default{
                Clear-Lines ($MenuOptions.Length+1)
            }
        }
    }
}

Function Get-MetaData{
    Param([parameter(ValueFromRemainingArguments=$true)][string[]]$File,[int]$ExifID=-1,[switch]$listId)
    #make a forEach and string[] param
    $objShell = New-Object -ComObject Shell.Application
    $MetaDataArray = New-Object PSObject

    forEach($fl in $File){
        $FileItem = get-item $File
        
        $objFolder = $objShell.namespace($FileItem.Directory.FullName)
        $objFile = $objFolder.items()|where Name -Match $FileItem.Name
        
        $FileMetaData = New-Object PSOBJECT 
        
        if($ExifID -gt -1){
            return $objFolder.getDetailsOf($objFile, $exifID)
        }
        
        for ($a=0 ; $a -le 266; $a++){
            if($listId){
                $hash += @{$a = $($objFolder.getDetailsOf($FileItem, $a)) }
                $FileMetaData | Add-Member $hash 
                $hash.clear()
            }elseif($objFolder.getDetailsOf($objFile, $a)){
                $hash += @{$($objFolder.getDetailsOf($objFolder.items, $a))  = $($objFolder.getDetailsOf($objFile, $a)) }
                $FileMetaData | Add-Member $hash 
                $hash.clear()  
            } #end if 
        } #end for
        $MetaDataArray | Add-Member $FileMetaData
    }
    return $MetaDataArray
}

function GetTaggedPosts{
    param([String]$tags,[switch]$raw,[int]$limit=-1)

    $posts = @()
    try{
        $posts = Get-TaggedPosts -Tags $tags -raw:$raw -limit $limit
    }catch [System.Management.Automation.CommandNotFoundException]{
        Invoke-Expression $ssconfig.getTaggedPosts
        Invoke-Expression $ssconfig.getPost
        $posts = Get-TaggedPosts -Tags $tags -raw:$raw -limit $limit
    }

    if($posts.Length -eq 0){
        Write-Host "No results for that tag combination. Please try a different sequence."
        exit
    }

    return $posts
}

if( $(Test-Path $ServerConfig) -eq $false ) {
    Write-Output "No server configuration file was found. Please download the provided server config and place it in the same directory as this program, otherwise hentapi won't work correctly."
    exit
}

$settings = [ordered]@{}

if( $(Test-Path $UserConfig) -eq $false ) {
    Write-Output "No user configuration file was found. Creating a config for you..."
} else {
    $tempSettings = Get-Content "${UserConfig}" | ConvertFrom-JSON
    Foreach($property in $tempSettings.servers.psobject.properties) { $settings[$property.Name] = $property.Value }
}

if($ListServers){
    if($(Test-Path $UserConfig)){
        if($Count){
            $settings.keys.Count
            exit
        }

        $serverArray=@()

        if(($VerbosePreference -eq "Continue") -or ($array)){
            ForEach-Object -InputObject $settings {$serverArray += $_}
        } else {
            ForEach-Object -InputObject $settings.keys {$serverArray += [string]$_ -split " "}
        }

        Write-Output $serverArray
        exit
    } else {
        throw "Configuration file does not have any servers in it."
    }
}

if($Update){
    #reads query file
    #if queries file exists, pull queries file to variable (qvar)
    #load temp file into array/if file not exist create array
    #creates hashtable of arrays like: #{done=@();notDone=@()}
    #add qvar to "not done" sec of array
    #forEach element in notDone,decode,process query,add encoded processed query string to done,remove 1st element of notDone,write to updateCheckpoint file
    #once all done, combine on newlines and append to the current queries file
    #delete updateCheckpoint
    if(Test-Path $DLPath){
        if((Get-Item $DLPath).Mode -notmatch "d"){
            throw "The update target is not a directory. Please check your path and try again."
            exit
        }
    }else{
        throw "The specified folder doesn't exist. Please check your path and try again."
        exit
    }

    $UpdatePath = (get-item $DLPath).FullName
    if($UpdatePath[-1] -notmatch "\\|/"){$UpdatePath += "/"}
    $origPath = $PWD.Path

    if($Recurse){
        $qFiles = Get-ChildItem $UpdatePath -name queries -Recurse
        $qFiles += Get-ChildItem $UpdatePath -name updateCheckpoint -Recurse
        Write-Host ("Updating collections in folder `""+(get-item $UpdatePath).name+"`"..")
        forEach($qFile in $qFiles){
            $matches = ""
            $qFile -match "(.+)\\[^\\]+$" > $nul
            $out=$updatePath+$matches[1]+"\"
            $ext=""
            
            if($Array){$ext += " -Array"}
            if($Count){$ext += " -Count"}
            
            Invoke-Expression ($MyInvocation.InvocationName+" -Update `""+$out+"`""+$ext)
        }
        exit
    }

    if(-not ((Test-Path ($UpdatePath + "queries")) -or (Test-Path ($UpdatePath + "updateCheckpoint")))){
        throw "The update file does not exist. Please make sure that your file path is valid, and that at least one download operation has been allowed to complete in your target path."
        exit
    }

    $query=$null
    
    if(Test-Path $UpdatePath"updateCheckpoint"){
        $qArray = ConvertFrom-JSON -InputObject (Get-Content $UpdatePath"updateCheckpoint")
        if($Array -or $Count){
            $qArray.done += $qArray.notDone
            $qArray.notDone = $qArray.done
        }
    }else{
        $qArray = @{done=@();notDone=@()}
    }

    if(Test-Path $UpdatePath"queries"){
        $qData = Get-Content $UpdatePath"queries"
        $qArray.notDone += $qData -split "`n"
        if(-not ($Array -or $Count)){
            ConvertTo-Json $qArray -Compress > $UpdatePath"updateCheckpoint"
            del $UpdatePath"queries"
        }
    }

    try{
        if($Count){$totalDiff = 0}
        if($Array){$queries=""}
        
        forEach($counter in $qArray.notDone){
            if($qArray.notDone[0] -match "^\s*$"){
                $qArray.notDone = $qArray.notDone[1..($qArray.notDone.length)]
                continue
            }
            Write-Progress -Activity "Clearing progress bars" -Id 0 -Completed
            $query = ConvertFrom-Json $(FromBase64 $qArray.notDone[0])
            $baseExpression = $MyInvocation.InvocationName+" -server " + $query.server + ' -tags "' + $query.tags + '"'
            $currentCount = Invoke-Expression ($baseExpression + " -count")
            $isMD5 = $query.md5
            $diff = $currentCount-$query.count
            if($isMD5){$baseExpression += " -MD5"}
            if($Count){
                $totalDiff += $diff
                $qArray.notDone = $qArray.notDone[1..($qArray.notDone.length)]
                continue
            }
            if($array){
                $queries += $baseExpression+" -Download"
                if($diff -gt 0){$queries += " -Limit $diff"}
                $queries += "`n"
                $qArray.notDone = $qArray.notDone[1..($qArray.notDone.length)]
                continue
            }
        
            if(($PWD.Path + "\") -ne $UpdatePath){cd $UpdatePath}
            $query.count = $currentCount

            if($diff -eq 0){
                Write-Host ("Found no new posts on server `""+$query.server+"`".")
                $qArray.done += $qArray.notDone[0]
                $qArray.notDone = $qArray.notDone[1..($qArray.notDone.length)]
                continue
            } elseif($diff -eq 1) {
                Write-Host ("Found 1 new post on server `""+$query.server+"`". Updating...")
            } elseif($diff -lt 0) {
                Write-Host ("Found a negative difference on server `""+$query.server+"`". Skipping...")
                $qArray.done += $qArray.notDone[0]
                $qArray.notDone = $qArray.notDone[1..($qArray.notDone.length)]
                continue
            } else {
                Write-Host ("Found $diff new posts on server `""+$query.server+"`". Updating...")
            }

            ToBase64 "http://www.ostracodfiles.com/dots/main.html" > update
            ToBase64 $diff >> update
            Invoke-Expression($baseExpression + " -Download -Limit $diff")
            $qArray.done += ToBase64 ($query|ConvertTo-Json -Compress)
            $qArray.notDone = $qArray.notDone[1..($qArray.notDone.length)]
            ConvertTo-Json $qArray -Compress > "updateCheckpoint"
        }

        if($Count){$totalDiff;exit}
        if($Array){$queries;exit}

        $qArray.done -join "`n" > "queries"
        if(Test-Path "updateCheckpoint"){
            del "updateCheckpoint"
        }
        Write-Host ("Collection `""+$UpdatePath.split('\')[-2]+"`" successfully updated.")
    }catch{
        Write-Error $_
        Write-Error "There was an error during the update process. See line 697 for more information."
    }finally{
        if(Test-Path "update"){
            del "update"
        }
        cd $origPath
        exit
    }
    #end
}

if($Server -eq "*"){
    foreach($key in $settings.keys){
        Write-Host ($key+": ")
        Invoke-Expression $MyInvocation.line.replace("*",${key})
    }

    exit
}

$trueName = $server.Split(".")[0]

if($Remove){
    if($settings.$trueName -eq $null){
        Write-Host "The server you're trying to remove doesn't exist.`nYou can use the -ListServers parameter to get a list of your currently configured servers."
        exit
    }
    $confirm = Create-Menu -MenuTitle "Are you sure you want to delete the server `"$Server`"?" -MenuOptions ("Yes","No") -DefaultSelection 1
    if($confirm -eq 0){
        $settings.remove($trueName)
        $saveConfig = (Get-Content "${UserConfig}" | ConvertFrom-JSON)
        $saveConfig.servers=$settings
        (ConvertTo-JSON $saveConfig -Depth 6 ) > $UserConfig
        Write-Host "Server `"$Server`" successfully deleted."
        exit
    }
    Write-Host "Server deletion cancelled."
    exit
}


if( $settings.$trueName -eq $null ) {
    Write-Host "Server was not found in config file. Commencing manual setup..."
    $settings.$trueName = @{}

    $newUrl = Read-Host "Please enter the url for $server (ex: https://gelbooru.com)"
    $types = (Get-Content "${ServerConfig}" | ConvertFrom-JSON).psobject.properties.name
    $options = $types + "Other/Automatic"
    $choice = Create-Menu -MenuTitle "Please select server type for `"$server`": (UP/DOWN/ENTER)" -MenuOptions $options
    if($newUrl.Contains("://")){$newUrl=$newUrl.Substring($newUrl.IndexOf("://")+3)}
    $ssconfig=@{}
    $ssconfig.url=$newUrl

    if($choice -eq $types.length){
        Write-Host "Attempting to detect server type..."
        $typeFunctions=(Get-Content "${ServerConfig}" | ConvertFrom-JSON)
        forEach($typeName in $types){
            Invoke-Expression $typeFunctions.$typeName.getTaggedPosts
            try{
                $testPost = Get-TaggedPosts -Tags " " -Limit 1
                if($testPost.id -ne $null){$settings.$trueName.type=$typeName}
            } catch {
                continue
            }
        }
        if($settings.$trueName.type -eq $null){
            Write-Output "The server type couldn't be automatically detected. Please submit a feature request on hentapi's Github repo (https://github.com/EK720/hentapi) if you want it to be added faster."
            exit
        }
    }else{
        Write-Host "Verifying server type..."
        Invoke-Expression (Get-Content "${ServerConfig}" | ConvertFrom-JSON).($types[$choice]).getTaggedPosts
        try{
            $testPost = Get-TaggedPosts -Tags " " -Limit 1
            if($testPost.id -ne $null){
                $settings.$trueName.type=$types[$choice]
            }else{
                Write-Host "The server type didn't match the type you selected. Please try choosing another type, or using the `"Other/Automatic`" option if you don't know what to choose."
                exit
            }
        } catch {
            if($_.Exception.Message.contains("404")){
                Write-Host "The server type didn't match the type you selected.`nPlease try choosing another type, or using the `"Other/Automatic`" option if you don't know what to choose."
                exit
            }else{
                throw "oh noes! an unknown ewwow occuwwed!`n$_"
            }
        }
    }
    $settings.$trueName.url = $newUrl
    
    if(Test-Path $UserConfig){
        $saveConfig = (Get-Content "${UserConfig}" | ConvertFrom-JSON)
    }else{
        $saveConfig = @{}
    }
    $saveConfig.servers=$settings
    (ConvertTo-JSON $saveConfig -Depth 6 ) > $UserConfig
    Write-Output "Server `"$server`" successfully registered."

    #I have to reset the settings variable, otherwise it's not in the right datatype to be put into $ssconfig.
    $settings=[ordered]@{}
    $tempSettings = Get-Content "$UserConfig" | ConvertFrom-JSON
    Foreach($property in $tempSettings.servers.psobject.properties) { $settings[$property.Name] = $property.Value }
}

$ssconfig = @{}

$tempSettings = (Get-Content "${ServerConfig}" | ConvertFrom-JSON).($settings.$trueName.type)
Foreach($property in $tempSettings.psobject.properties) { $ssconfig[$property.Name] = $property.Value }
Foreach($property in $settings.$trueName.psobject.properties) { $ssconfig[$property.Name] = $property.Value }
Foreach($property in (Get-Content "${UserConfig}" | ConvertFrom-JSON).other.psobject.properties) { $ssconfig[$property.Name] = $property.Value }

if($Download){
    if($DLPath[0] -eq "." -and $DLPath[1] -match "\\|/"){
        $DLPath=(Get-Location).path + $DLPath.Substring(1)
    }
    $hashes=""

    if($(Test-Path -Path $DLPath) -eq $false){
        $DLPath=(New-Item $DLPath -Force -ItemType "d").FullName
    }else{
        $DLPath = (Get-Item $DLPath).FullName
        if($(Test-Path -Path "${DLPath}\hashlist") -eq $true){
            $hashes=(Get-Content "${DLPath}\hashlist") -join ";"
        }
    }
    $invalidExtensions = @{
        png="jpg"
        webp="jpeg"
        webm="mp4"
    }
    $Global:isDownloaded = $false
    $Global:Data = $null
    $UserAgent="hentapi"
}

if($DLPath[-1] -ne "\" -and $DLPath[-1] -ne "/"){$DLPath += "\"}

if($PSCmdlet.ParameterSetName -eq "PostSearch"){
    Invoke-Expression $ssconfig.getPost
    $postRaw = Get-Post -id $Post -raw
    if($postRaw -eq $null){
        if($Count){
            0
        }else{
            Write-Host "Post #$post does not exist."
        }
        exit
    }
    
    if($Count){
        1
        exit
    }

    if($array -and !$Download){
        #outputs raw post
        return $postRaw
    }

    $postData = Get-Post -id $Post

    if($Download){
        Write-Host "Downloading post #${Post} from server `"${Server}`".."
        $id = $Post

        if($MD5){
            $id = $postData.md5
        }

        Get-EventSubscriber -Force | Unregister-Event -Force
        Get-Job | Remove-Job -Force

        $DLExt = $postData.file.split('\.')[-1] -replace '\W.+',''
        $DLFile = $DLPath + $id + "." + $DLExt
        $DLClient = New-Object System.Net.WebClient
        $DLClient.Headers['User-Agent']=$UserAgent
        $Global:isDownloaded = $false
        $Global:Data = $null
        
        if($invalidExtensions.$DLExt -ne $null){
            $badExt = $DLExt + "|" + $invalidExtensions.$DLExt
        } else {
            $badExt = $DLExt
        }

        Register-ObjectEvent -InputObject $DLClient -EventName DownloadProgressChanged -SourceIdentifier Web.DownloadProgressChanged -SupportEvent -Action {
            $Global:Data = $event
        }

        Register-ObjectEvent -InputObject $DLClient -EventName DownloadFileCompleted -SourceIdentifier Web.DownloadFileCompleted -SupportEvent -Action {    
            $Global:isDownloaded = $True
        }
        
        if($hashes.IndexOf($postData.md5) -eq -1){
            if((get-childitem ($DLPath+"*") | where Name -match "$id\.(${badExt})").count -eq 0){
            try{
            $DLClient.DownloadFileAsync($postData.file, $DLFile)
            Write-Progress -Activity "Downloading file" -Id 0 -Status "Connecting..." -PercentComplete 0


            while(!$isDownloaded){
                $progress = $Data.SourceArgs.ProgressPercentage
                if($Data.SourceArgs.ProgressPercentage -eq $null){$progress = 0}
                $sizeBytes = $Data.SourceArgs.TotalBytesToReceive
                $downloadedBytes = $Data.SourceArgs.BytesReceived
                Write-Progress -Activity "Downloading file" -Id 0 -Status " " -PercentComplete $progress -CurrentOperation "Downloading file $DLFile, have $downloadedBytes of $sizeBytes bytes"
            }

                if($array){break}
                if(!$IgnoreHashCheck){HashCheck -Path $DLFile -Post $postData}
                $postData.md5>>$DLPath\hashlist
                $metaExt = Add-Metadata -Path $DLFile -Post $postData
                if($metaExt -ne $null){
                    $DLFile = $DLFile.Substring(0,$DLFile.Length-3) + $metaExt
                }
            }finally{
                if(!$isDownloaded){
                    $DLClient.CancelAsync()
                    Remove-Item $DLFile
                    Write-Verbose "Ctrl-C recieved, deleting file"
                    exit
                }
                $Data = $null
            }
            }else{
                $postData.md5>>$DLPath\hashlist
            }
        }else{
            Write-Verbose ("Skipping download of file `""+$DLFile.split("\")[-1]+"`".")
        }

        if(Test-Path -Path $DLFile){
            Write-Host "Post #$Post was successfully downloaded to $DLFile."
        }else{
            throw "Something went wrong during download. Is your file path valid?"
        }
        exit
    }else{
        if($md5){
            $output = $postData.md5
        }else{
            $output = $postData.file
        }
    }
} elseif($PSCmdlet.ParameterSetName -eq "TagSearch") {
    Invoke-Expression $ssconfig.getTaggedPosts
    Invoke-Expression $ssconfig.getCount

    if($array -and !$Download){
        $arrayFull = $false
        try{
            $global:postArray = GetTaggedPosts -tags $tags -limit $Limit -raw
            $arrayFull = $true
        }finally{
            $postArray
            if(!$arrayFull){
                Write-Host "The command did not complete successfully. If you want complete results, please re-run the command.`nTo see partial results, check '`$postArray'."
            }
            exit
        }
    }

    <#if($getFirstID){
        (GetTaggedPosts -tags $Tags -limit 1).id
        exit
    }#>

    if($Count){
        Get-Count -tags $Tags -limit $limit
        return
    }

    $postData = GetTaggedPosts -tags $tags -limit $Limit
    $postCount = $postData.length
    $updateMode = Test-Path $DLPath"update"

    Write-Verbose $("Found $postCount posts matching tag(s) `"$Tags`".")

    if($postCount -eq 1){
        if($Download){
            $id = $postData.id

            Write-Host "Downloading post #${id} from server `"${Server}`"..."

            if($MD5){
                $id = $postData.md5
            }

            Get-EventSubscriber -Force | Unregister-Event -Force
            Get-Job | Remove-Job -Force

            $DLClient = New-Object System.Net.WebClient
            $DLClient.Headers['User-Agent']=$UserAgent
            $DLExt = $postData.file.split('.')[-1] -replace '\W.+',''
            $DLFile = $DLPath + $id + "." + $DLExt
            $Global:isDownloaded = $false
            $Global:Data = $null
            
            Register-ObjectEvent -InputObject $DLClient -EventName DownloadProgressChanged -SourceIdentifier Web.DownloadProgressChanged -SupportEvent -Action {
                $Global:Data = $event
            }
            
            Register-ObjectEvent -InputObject $DLClient -EventName DownloadFileCompleted -SourceIdentifier Web.DownloadFileCompleted -SupportEvent -Action {    
                $Global:isDownloaded = $True
            }

            if($invalidExtensions.$DLExt -ne $null){
                $badExt = $DLExt + "|" + $invalidExtensions.$DLExt
            } else {
                $badExt = $DLExt
            }

            if($hashes.IndexOf($postData.md5) -eq -1){
                if((get-childitem ($DLPath+"*") | where Name -match "$id\.(${badExt})").count -eq 0){
                    try{
                        $DLClient.DownloadFileAsync($postData.file, $DLFile)
                    
                        while(!$isDownloaded){
                            $progress = $Data.SourceArgs.ProgressPercentage
                            if($Data.SourceArgs.ProgressPercentage -eq $null){$progress = 0}
                            $sizeBytes = $Data.SourceArgs.TotalBytesToReceive
                            $downloadedBytes = $Data.SourceArgs.BytesReceived
                            Write-Progress -Activity "Downloading file" -Id 0 -Status " " -PercentComplete $progress -CurrentOperation "Downloading file $DLFile, have $downloadedBytes of $sizeBytes bytes"
                        }

                        if($array){return}
                        if(!$IgnoreHashCheck){HashCheck -Path $DLFile -Post $postData}
                        $postData.md5>>$DLPath\hashlist
                        $metaExt = Add-Metadata -Path $DLFile -Post $Postdata
                        if($metaExt -ne $null){
                            $DLFile = $DLPath + $id + "." + $metaExt
                        }
                    }finally{
                        if(!$isDownloaded){
                            $DLClient.CancelAsync()
                            Remove-Item $DLFile
                            Write-Verbose "Ctrl-C recieved, deleting file"
                            exit
                        }
                    }
                } else {
                    $postData.md5>>$DLPath\hashlist
                }
            }else{
                $hashDupe = $True
            }

            if((get-childitem ("$DLPath/$id.*") | where Name -match "$id\.($badExt)").count -gt 0){
                Write-Host "Post #$id was successfully downloaded to $DLPath."
            }elseif($hashDupe){
                Write-Host "Post #$id not downloaded because it matches an already downloaded image."
            }else{
                throw "Something went wrong during download. Is your file path valid?"
            }

            if(!$updateMode){
                $query = @{}
                $query.server = $Server
                $query.tags = $Tags
                $query.count = 1
                $query.md5 = if($MD5){$true}else{$false}
                $queryString = ConvertTo-JSON $query -Compress
                ToBase64 $queryString >> ($DLPath + "queries")
            }

            return
        }else{
            $output = $postData.file
        }
    } else {
        [String[]]$imageLinks = @()
        $pages = [Math]::ceiling($postCount/[int](Get-Count -tags $tags -Pages))

        if($Download){
            Get-EventSubscriber -Force | Unregister-Event -Force
            Get-Job | Remove-Job -Force
            $Global:Data = $null
            $Global:isDownloaded = $False
            $DLClient = New-Object System.Net.WebClient
            $dataJob = Register-ObjectEvent -InputObject $DLClient -EventName DownloadProgressChanged -SourceIdentifier Web.DownloadProgressChanged -SupportEvent -Action {$Global:Data = $event;$Global:dataRegistered = $True}
            $completedJob = Register-ObjectEvent -InputObject $DLClient -EventName DownloadFileCompleted -SourceIdentifier Web.DownloadFileCompleted -MaxTriggerCount 999999999 -Action {$Global:isDownloaded = $True}
            $children = get-childitem $DLPath

            if($DLPath[-1] -ne "\" -and $DLPath[-1] -ne "/"){$DLPath += "\"}
            if($updateMode){$updPosts = FromBase64 (Get-Content $DLPath"update")[1]}
            
            #download function
            if($updateMode){
                Write-Progress -Activity ("Updating collection in `"$DLPath`"") -Id 0 -Status ("Server: " + $ssconfig.url) -PercentComplete 0 -CurrentOperation ("Retrieving post data")
            }else{
                Write-Progress -Activity ("Downloading from " + $ssconfig.url) -Id 0 -Status "Loading..." -PercentComplete 0 -CurrentOperation ("Retrieving post data")
            }

            for($i=0;$i -lt $postData.Length;$i++){
                $pageNum = [Math]::ceiling(($i+1)*$pages/$postCount)
                if($updateMode){
                    Write-Progress -Activity ("Updating collection in `"$DLPath`"") -Id 0 -Status ("Server: " + $ssconfig.url) -PercentComplete ([Math]::ceiling($i*100/$postData.Length)) -CurrentOperation ("Downloading post #$($i+1)" )
                }else{
                    Write-Progress -Activity ("Downloading from " + $ssconfig.url) -Id 0 -Status ("Page $pageNum/"+ [Math]::ceiling(($postData.length*$pages)/$postCount)) -PercentComplete ([Math]::ceiling($i*100/$postData.Length)) -CurrentOperation ("Downloading post #$($i+1)" )
                }
                $id = $postData.id

                if($MD5){
                    $id = $postData.md5
                }

                if($hashes.IndexOf($postData[$i].md5) -eq -1){
                    $DLExt = $postData[$i].file.split('.')[-1] -replace '\W.+',''
                    $DLID = $id[$i]
                    $DLFile = $DLPath + $DLID + "." + $DLExt

                    if($invalidExtensions.$DLExt -ne $null){
                        $badExt = $DLExt + "|" + $invalidExtensions.$DLExt
                    } else {
                        $badExt = $DLExt
                    }

                    if(($children | where Name -match "$DLID\.(${badExt})meta").count -eq 1 -and !$updateMode){
                        $untagged = $children | where Name -match "$DLID\.(${badExt})meta"
                        $newName = $untagged.name.Substring(0,$untagged.Name.Length-4)
                        Rename-Item $untagged.fullname $newName
                        Add-Metadata -Path ($DLPath+$newName) -Post $postData[$i] > $null
                        $postData[$i].md5>>($DLPath+"hashlist")
                        continue
                    }

                    if(($children | where Name -match "$DLID\.($badExt)").count -eq 0){
                        try{
                            $Global:isDownloaded = $False
                            $Global:dataRegistered = $False
                            $DLClient.Headers['User-Agent']=$UserAgent
                            $DLClient.DownloadFileAsync($postData[$i].file, $DLFile)
                                
                            while(!$isDownloaded){
                                $progress = $Data.SourceArgs.ProgressPercentage
                                if(!$dataRegistered){$progress = 0}
                                $sizeBytes = $Data.SourceArgs.TotalBytesToReceive
                                $downloadedBytes = $Data.SourceArgs.BytesReceived
                                Write-Progress -Activity "Downloading file" -Id 1 -ParentId 0 -Status " " -PercentComplete $progress -CurrentOperation "Downloading file $DLFile, have $downloadedBytes of $sizeBytes bytes"
                            }
                            $DLClient.CancelAsync()

                            Get-Job | Stop-Job
                            Get-job | Remove-Job -Force

                            Get-EventSubscriber -Force | Unregister-Event -Force
                            $dataJob = Register-ObjectEvent -InputObject $DLClient -EventName DownloadProgressChanged -SourceIdentifier Web.DownloadProgressChanged -SupportEvent -Action {$Global:Data = $event;$Global:dataRegistered = $True}
                            $completedJob = Register-ObjectEvent -InputObject $DLClient -EventName DownloadFileCompleted -SourceIdentifier Web.DownloadFileCompleted -MaxTriggerCount 999999999 -Action {$Global:isDownloaded = $True}
                        } finally{
                            if(!$isDownloaded){
                                $DLClient.CancelAsync()
                                Remove-Item $DLFile
                                Write-Verbose "Ctrl-C recieved, cancelling download..."
                            }
                        }

                        if($array){continue}
                        if(!$IgnoreHashCheck){HashCheck -Path $DLFile -Post $postData[$i]}
                        Add-Metadata -Path $DLFile -Post $postData[$i] > $null
                    }else{
                        <#if($updateMode){
                            if((Get-MetaData -File ($children | where Name -match "$DLID\.(${badExt})").Name -ExifID 20) -eq $trueName){
                                Remove-Item $DLPath"update"
                                return "done"
                            }
                        }#>
                        Write-Verbose ("Skipping download of file `"" + $DLID + "." + $DLExt + "`".")
                    }
                    $postData[$i].md5>>($DLPath+"hashlist")
                <#}elseif($updateMode){
                    $DLExt = $postData[$i].file.split('.')[-1]
                    $DLID = $id[$i]
                    $DLFile = $DLPath + $DLID + "." + $DLExt

                    if($invalidExtensions.$DLExt -ne $null){
                        $badExt = $DLExt + "|" + $invalidExtensions.$DLExt
                    } else {
                        $badExt = $DLExt
                    }

                    if(($children | where Name -match "$DLID\.(${badExt})").count -ne 0){
                        if((Get-MetaData -File ($children | where Name -match "$DLID\.(${badExt})").Name -ExifID 20) -eq $trueName){
                            del $DLPath"update"
                            exit
                        }else{
                            Write-Verbose ("Skipping download of file `"" + $DLID + "." + $DLExt + "`".")
                        }
                    }else{
                        Write-Verbose ("Skipping download of file `"" + $DLID + "." + $DLExt + "`".")
                    }#>
                }else{
                    Write-Verbose ("Skipping download of file `"" + $id[$i] + "." + $postData[$i].file.split('\.')[-1] + "`".")
                }

                if($updateMode){
                    Write-Progress -Activity ("Updating collection in `"" + $DLPath + "`"") -Id 0 -Status ("Server: " + $ssconfig.url) -CurrentOperation ("Downloading post #$i" )
                }else{
                    Write-Progress -Activity ("Downloading from " + $ssconfig.url) -Id 0 -Status ("Page $pageNum") -CurrentOperation ("Downloading post #$i" )
                }
            }
                
            if($updateMode){
                Write-Host ("Updated page $pageNum.")
            }else{
                Write-Host ("Downloaded page $pageNum.")
                $query = @{}
                $query.server = $Server
                $query.tags = $Tags
                $query.count = $postCount
                $query.md5 = if($MD5){$true}else{$false}
                $queryString = ConvertTo-JSON $query -Compress
                ToBase64 $queryString >> ($DLPath + "queries")
            }
            return
        }
    }
        
        
    #$posts = Get-TaggedPosts -tags $tags -limit $Limit

    if($md5){
        $output = $postData.md5
    } else {
        $output = $postData.file
    }
}


if( $ToClipBoard ){
    Set-Clipboard -Text ($output -join "`n")
} else {
    $output
}
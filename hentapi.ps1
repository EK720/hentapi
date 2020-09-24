<#
.SYNOPSIS
    Just another imageboard API linkgrabber, with image tagging as well as download & update support.
    It's more of a passion project than something that fills a need, though. I hope it works well for you.

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

.PARAMETER ConfigFile
    Here you can give a path to a custom configuration file. I don't think this one works, but I don't care.
    Every time the program is run, it checks for a config file, and generates one if it doesn't exist.
    Let's say (for the sake of argument), that you got a really full config file from somewhere else.
    Perhaps you got one from the Internet because you didn't want to waste hours going through API docs. Sensible.

    Move that file to the same directory as this script, and boom. It'll be loaded the next time hentapi runs.
    Easy. Simple. Why did I add this option? Nobody's going to have that much trouble with this.

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
    I'm sorry if these are bad. I don't know how to do examples.

.NOTES
    Author: Fuzion
    Created: 2019-04-30
    Last Edit: 2020-09-24
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
    Version 2.37- Added a neat new feature: If a post fails to download due to some error, download the post yourself and put it in the download dir with the name [id].[ext]meta, where [id] is whatever the program told you failed to download, and [ext] is just the default extension of the image.
    Version 2.39- 2.4 will be polished, I swear. Added the "-Recurse" option for updates.
    Version 2.4 - Finally polished the progress bars and this help file. Happy new year!
    Version 2.5 - Added json support, but the page/post count is a bit wonky now. I might be able to fix it but I really don't care right now. This was a giant ordeal and I had to rework most of the program to get this working. Have fun.
    Version 2.6 - Polished code for first Github release, and laid the foundations for a large rework of the configuration system.
#>
#TODO: REWORK CONFIG SYSTEM TO USE 3 FILES; ONE BEING HENTAPI.PS1, TWO IS A LIST OF SERVERS THAT THE USER HAS, AND THREE IS A FILE CONTAINING INSTRUCTIONS FOR HENTAPI ON HOW TO DEAL WITH EACH SERVER.
[CmdletBinding(DefaultParameterSetName='TagSearch')]
Param(
    [parameter(Mandatory=$true,ParameterSetName="TagSearch",ValueFromPipeline=$true,HelpMessage="The server that will be queried. Use -ListServers for a list of already configured servers.")]
    [parameter(Mandatory=$true,ParameterSetName="PostSearch",ValueFromPipeline=$true,HelpMessage="The server that will be queried. Use -ListServers for a list of already configured servers.")]
    [alias("ServerURL","URL")]
    [string]
    $Server,

    [string]
    $ConfigFile = "$PSScriptRoot\hentapi-config.dat",

    [parameter(Mandatory=$true,ParameterSetName="ListServers",HelpMessage="Prints a list of all servers in the config file.")]
    [alias("ListServer")]
    [switch]
    $ListServers,

    [parameter(Mandatory=$true,ParameterSetName="TagSearch",HelpMessage="The tag(s) to search.")]
    [alias("Tag")]
    [string]
    $Tags,

    [parameter(Mandatory=$true,ParameterSetName="PostSearch",HelpMessage="The ID of the post you want. This may not work with some servers.")]
    [alias("ID","PID","Posts")]
    [int]
    $Post,

    [parameter(ParameterSetName="PostSearch",HelpMessage="Tells the program to output to your clipboard instead of the CLI.")]
    [parameter(ParameterSetName="TagSearch",HelpMessage="Tells the program to output to your clipboard instead of the CLI.")]
    [switch]
    $ToClipboard,

    [parameter(HelpMessage="Tells the program to output how many results your command returned instead of the actual results. Niche, but useful for automation.")]
    [switch]
    $Count,

    [alias("DownloadTo","DownloadPath","DownloadLocation", "dl")]
    [parameter(ParameterSetName="PostSearch",HelpMessage="Tells the program to download the search results somewhere. Defaults to your current folder, but you can put a path after this parameter to tell it to download somewhere else.")]
    [parameter(ParameterSetName="TagSearch",HelpMessage="Tells the program to download the search results somewhere. Defaults to your current folder, but you can put a path after this parameter to tell it to download somewhere else.")]
    [switch]
    $Download,

    [parameter(ParameterSetName="PostSearch",ValueFromRemainingArguments=$true,HelpMessage="You don't have to specify this parameter on its own. Just put the path after the -Download parameter and it should work fine.")]
    [parameter(ParameterSetName="TagSearch",ValueFromRemainingArguments=$true,HelpMessage="You don't have to specify this parameter on its own. Just put the path after the -Download parameter and it should work fine.`nSIDE NOTE: if anyone knows how I can make the -Download parameter work as a switch and a string, let me know")]
    [string]
    $DLPath=$PWD.Path,

    [parameter(ParameterSetName="PostSearch")]
    [parameter(ParameterSetName="TagSearch")]
    [switch]
    $MD5,

    [alias("arr","raw")]
    [switch]
    $Array,

    [parameter(mandatory=$true,ParameterSetName="Update")]
    [alias("upd8", "upd")]
    [switch]
    $Update,

    [parameter(ParameterSetName="Update",ValueFromRemainingArguments=$true)]
    [string]
    $UpdatePath=$PWD.Path,

    [parameter(ParameterSetName="PostSearch")]
    [parameter(ParameterSetName="TagSearch")]
    [parameter(ParameterSetName="Update")]
    [switch]
    $IgnoreHashCheck,

    [parameter(ParameterSetName="Update",HelpMessage="Makes updater search for collections recursively through the file structure from where the command was run.")]
    [alias("r","Recursive")]
    [switch]
    $Recurse,

    [parameter(HelpMessage="Returns the first post ID from your search results. This is mostly an internal parameter, so don't worry about it too much.")]
    [switch]
    $getFirstID
)

#functions
function Split-ServerName {
    $a, $b = $Server -split "\."
    $a
}

function Get-PageData {
    param( [string]$Url )
    
    if($ssconfig.json){
        $webRead = $((Invoke-WebRequest -Uri $Url -UserAgent "HentAPI/2.5 (by Fuzion)").Content) -replace "&","" | ConvertFrom-JSON
    } else {
        [xml]$webRead = $((Invoke-WebRequest -Uri $Url).Content) -replace "&",""
    }
    $webRead
}

function Get-TotalPages {
    param( [string]$file, [PsObject]$var )
    if( $file -ne "" -and $var -ne $null ){
        throw "Something went fucky. This is probably not your fault, I just fucked up some code. Go back to where you got this script and complain."
        exit
    }
    
    if( $file -ne ""){
        [xml]$APIFile = Get-Content $file
    } else {
        $APIFile = $var
    }

    if( $APIFile.posts.count -eq 0 ) {
        Write-Host "No results for that tag combination. Please try a different sequence."
        exit
    }

    if($APIFile.posts.count -eq 1){return 1}

    $fullPage = $APIFile.posts.post.Length
    if($fullPage -eq 0){
        $fullPage = $APIFile.posts.count
    }

    [decimal]$pages = $APIFile.posts.count/$fullPage
    $roundPages = [math]::Ceiling($pages)
    $roundPages
}

function Add-Metadata {
    param([string]$Path, $Post)
    Write-Progress -Activity "Editing file" -Status " " -PercentComplete 0 -ParentId 0 -Id 1
    
    if($Post.tags.getType().Name -eq "String"){
        $tagsList = $Post.tags.Split(" ")
    } else {
        $tagsList = Invoke-Expression $ssconfig.tags_exp
    }

    $author = $Post.author
    $metaTags = $tagsList -join ";"
    $file=$Path.split("\")[-1]
    $name = $file.Substring(0,$file.LastIndexOf("."))
    $PathDir = $Path.Substring(0,$Path.LastIndexOf("\")+1)
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
                #I got mp4tags after some pretty heavy internet digging. I don't know where it is now, but you can probably check archive.org. I'm sorry.
                #Note: The file libmp4v2.dll needs to be in the same directory as mp4tags, otherwise it won't work.
                #And this program works just fine without it, anyway. (i think)
                mp4tags -g ($tagsList -join "; ") $Path
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

        if($Post.rating -eq "s" -or $Post.rating -eq "safe"){
            $rating=1
        }elseif($Post.rating -eq "q" -or $Post.rating -eq "questionable"){
            $rating=2
        }elseif($Post.rating -eq "e" -or $Post.rating -eq "explicit"){
            $rating=3
        }else{
            $rating=0
        }

        $time = $Post.created_at
        if($time -eq $null){
            $time = $Post.date
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
        exiftool -Artist="${Server}" -XPKeywords="${metaTags}" -Rating="${rating}" $Path -overwrite_original -q -ignoreMinorErrors
        (get-item $Path).CreationTime = $creationTime
    }
    catch [System.SystemException] {
        Write-Verbose "ExifTool/ImageMagick/FFMpeg not found. Not writing image metadata..."
    }
    Write-Progress -Activity "Editing file" -Status "All operations complete." -PercentComplete 100 -ParentId 0 -Id 1 -Completed
    return $ext
}

function HashCheck {
    param([string]$Path, $Post, [int]$Count=1)
    
    Write-Progress -Activity "Checking file hash.." -PercentComplete 0 -ParentId 0 -Id 1

    if($Count -gt 30){
        Write-Warning ("Gave up on file `"${Path}`" after " + ($Count-1) + " attempts.")
        return
    }

    if($ignoreHashCheck){
        return
    }

    if((Test-Path $Path) -eq $false){
        Write-Verbose ("File `"${Path}`" was not successfully downloaded, retrying...(" + $Count + ")")
        try{
            (New-Object System.Net.WebClient).DownloadFile((Invoke-Expression "`$Post.$($ssconfig.file_loc)"), $Path)
        } catch{
            throw "$_`ni didn't know what to do here so please fill this in thanks"
            #remove this line to see the real error location ^
            exit
        }
        HashCheck -Path $Path -Post $Post
        return
    }else{
        $hash = (get-fileHash $Path -algorithm MD5).hash
        Write-Progress -Activity "Checking file hash.." -Status "Hashing file" -PercentComplete 50 -ParentId 0 -Id 1
    }
    
    if($hash -eq (Invoke-Expression "`$Post.$($ssconfig.md5_loc)")){
        if($Count -gt 1){
            Write-Verbose ("Successfully downloaded file `"" + $Path + "`" after " + $Count + " attempts.")
        }
        Write-Progress -Activity "Checking file hash.." -Status "Successfully verified file integrity" -PercentComplete 100 -ParentId 0 -Id 1 -Completed
        return
    }
        
    Write-Verbose ("MD5 hashes for file `"" + $Path + "`" do not match, retrying...(" + $Count + ")")
    while(Test-Path $Path){del $Path}
    try{
        (New-Object System.Net.WebClient).DownloadFile((Invoke-Expression "`$Post.$($ssconfig.file_loc)"), $Path)
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
            return $($objFolder.getDetailsOf($objFile, $exifID))
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

$settings = [ordered]@{}

if( $(Test-Path $ConfigFile) -eq $false ) {
    Write-Output "No configuration file was found. Creating new config file..."
} else {
    $tempSettings = Get-Content "${ConfigFile}" | ConvertFrom-JSON
    Foreach($property in $tempSettings.psobject.properties) { $settings[$property.Name] = $property.Value }
}

if($ListServers){
    if($(Test-Path $ConfigFile)){
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
    if(Test-Path $UpdatePath){
        if((Get-Item $UpdatePath).Mode -ne "d-----"){
            throw "The update target is not a directory. Please check your path and try again."
            exit
        }
    }else{
        throw "The specified folder doesn't exist. Please check your path and try again."
        exit
    }

    $UpdatePath = (get-item $UpdatePath).FullName
    if($UpdatePath[-1] -ne "\"){$UpdatePath += "\"}
    $origPath = $PWD.Path

    if($Recurse){
        $qFiles = Get-ChildItem $UpdatePath -name queries -Recurse
        Write-Host ("Updating collections in folder `""+(get-item $UpdatePath).name+"`"..")
        forEach($qFile in $qFiles){
            $out=$updatePath+$qFile.substring(0,$qFile.length-7)
            
            if($Array){$out += " -Array"}
            if($Count){$out += " -Count"}
            
            Invoke-Expression ($MyInvocation.InvocationName+" -Update `""+$out+"`"")
        }
        exit
    }

    if(-not (Test-Path ($UpdatePath + "queries"))){
        throw "The update file does not exist. Please make sure that your file path is valid, and that at least one download operation has been allowed to complete in your target path."
        exit
    }

    $query=$null
    $qData = Get-Content $UpdatePath"queries"

    try{
        if($Count){$totalDiff = 0}
        if($Array){$queries=""}
        
        forEach($encodedQuery in ($qData -split "`n")){
            Write-Progress -Activity "Clearing progress bars" -Id 0 -Completed
            $query = ConvertFrom-Json $(FromBase64 $encodedQuery)
            $baseExpression = $MyInvocation.InvocationName+" -server " + $query.server + ' -tags "' + $query.tags + '"'
            $currentID = Invoke-Expression ($baseExpression + " -getFirstID")
            $isMD5 = $query.md5
            $diff = $currentID-$query.firstID
            if($isMD5){$baseExpression += " -MD5"}
            
            if($Count){
                $totalDiff += $diff
                continue
            }

            if($array){
                $queries += $baseExpression+" -Download`n"
                continue
            }
        
            if(($PWD.Path + "\") -ne $UpdatePath){cd $UpdatePath}
            $query.firstID = $currentID
            $queryJSON = ConvertTo-JSON $query -Compress
            ToBase64 $queryJSON >> "tempQueries"

            if($diff -eq 0){
                Write-Output ("Found no new posts on server `""+$query.server+"`".")
                continue
            } elseif($diff -eq 1) {
                Write-Output ("Found 1 new post on server `""+$query.server+"`". Updating...")
            } elseif($diff -lt 0) {
                Write-Output ("Found a negative difference on server `""+$query.server+"`". Skipping...")
                continue
            } else {
                Write-Output ("Found new posts on server `""+$query.server+"`". Updating...")
            }

            ToBase64 "http://www.ostracodfiles.com/dots/main.html" > update
            ToBase64 $diff >> update
            Invoke-Expression($baseExpression + " -Download")
        }

        if($Count){$totalDiff;exit}
        if($Array){$queries;exit}
        
        Write-Host ("Collection `""+$UpdatePath.split('\')[-2]+"`" successfully updated.")

    }catch{
        throw $_
        exit
    }finally{
        if(Test-Path "queries"){
            del "queries"
            ren "tempQueries" "queries"
        }
        if(Test-Path "update"){
            del "update"
        }
        cd $origPath
        exit
    }
}

if($Server -eq "*"){
    foreach($key in $settings.keys){
        Write-Host ($key+": ")
        Invoke-Expression $MyInvocation.line.replace("*",${key})
    }

    exit
}

$trueName = Split-ServerName

if( $settings.$trueName -eq $null ) {
    Write-Host "Server was not found in config file. Commencing manual setup..."
    $settings.$trueName = @{}

    $APIUrl = Read-Host "Please enter the API url for ${Server}"
    $p1, $p2 = $APIUrl -split "\?"
    if($p1 -eq $APIUrl){
        $settings.$trueName.url = $APIUrl + "?"
    } else {
        $settings.$trueName.url = $APIUrl + "&"
    }

    $settings.$trueName.post = Read-Host "Please enter the post ID query suffix"
    $settings.$trueName.page = Read-Host "Please enter the page # query suffix"
    $settings.$trueName.tags = Read-Host "Please enter the tag query suffix"
    ConvertTo-JSON $settings -Compress -Depth 6 >$ConfigFile
}

#populates the config variable
$ssconfig = $settings.$trueName
#if certain server-specific settings are null, this populates them
if($ssconfig.post_loc -eq $null){
    Add-Member "post_loc" "posts.post" -InputObject $ssconfig
}
if($ssconfig.file_loc -eq $null){
    Add-Member "file_loc" "file_url" -InputObject $ssconfig
}
if($ssconfig.md5_loc -eq $null){
    Add-Member "md5_loc" "md5" -InputObject $ssconfig
}
if($ssconfig.json -eq $null){
    Add-Member "json" $False -InputObject $ssconfig
}

if($Download){
    if($DLPath[0] -eq "." -and $DLPath[1] -eq "\"){
        $DLPath=(Get-Location).path + $DLPath.Substring(1)
    }
    $hashes=""

    if($(Test-Path -Path $DLPath) -eq $false){
        mkdir $DLPath >$null
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
}

if($DLPath[-1] -ne "\"){$DLPath += "\"}

if($PSCmdlet.ParameterSetName -eq "PostSearch"){
    if($Count){
        1
        exit
    }

    $postXML = Get-PageData -Url $(($ssconfig).url + ($ssconfig).post + "=${Post}")
    if((Invoke-Expression "`$postXML.$($ssconfig.post_loc).count") -gt 1){
        Write-Host "Sorry, this server doesn't support searching for individual posts. Please try searching with tags instead."
        exit
    }

    if($array -and !$Download){
        #outputs raw post
        return (Invoke-Expression "`$postXML.$($ssconfig.post_loc)")
    }

    if($Download){
        Write-Host "Downloading post #${Post} from server `"${Server}`".."
        $id = Invoke-Expression "`$postXML.$($ssconfig.post_loc).id"

        if($MD5){
            $id = Invoke-Expression "`$postXML.$($ssconfig.post_loc).$($ssconfig.md5_loc)"
        }

        Get-EventSubscriber -Force | Unregister-Event -Force
        Get-Job | Remove-Job -Force

        $DLExt = (Invoke-Expression "`$postXML.$($ssconfig.post_loc).$($ssconfig.file_loc)").split('\.')[-1]
        $DLFile = $DLPath + $id + "." + $DLExt
        $DLClient = New-Object System.Net.WebClient
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
        
        if($hashes.IndexOf((Invoke-Expression "`$postXML.$($ssconfig.post_loc).$($ssconfig.md5_loc)")) -eq -1){
            if((get-childitem ($DLPath+"*") | where Name -match "$id\.(${badExt})").count -eq 0){
            try{
            $DLClient.DownloadFileAsync((Invoke-Expression "`$postXML.$($ssconfig.post_loc).$($ssconfig.file_loc)"), $DLFile)
            Write-Progress -Activity "Downloading file" -Id 0 -Status "Connecting..." -PercentComplete 0


            while(!$isDownloaded){
                $progress = $Data.SourceArgs.ProgressPercentage
                if($Data.SourceArgs.ProgressPercentage -eq $null){$progress = 0}
                $sizeBytes = $Data.SourceArgs.TotalBytesToReceive
                $downloadedBytes = $Data.SourceArgs.BytesReceived
                Write-Progress -Activity "Downloading file" -Id 0 -Status " " -PercentComplete $progress -CurrentOperation "Downloading file $DLFile, have $downloadedBytes of $sizeBytes bytes"
            }

                if($array){break}
                if(!$IgnoreHashCheck){HashCheck -Path $DLFile -Post (Invoke-Expression "`$postXML.$($ssconfig.post_loc)")}
                Invoke-Expression "`$postXML.$($ssconfig.post_loc).$($ssconfig.md5_loc)">>$DLPath\hashlist
                $metaExt = Add-Metadata -Path $DLFile -Post (Invoke-Expression "`$postXML.$($ssconfig.post_loc)")
                if($metaExt -ne $null){
                    $DLFile = $DLFile.Substring(0,$DLFile.Length-3) + $metaExt
                }
            }finally{
                if(!$isDownloaded){
                    $DLClient.CancelAsync()
                    del $DLFile
                    Write-Verbose "Ctrl-C recieved, deleting file"
                    exit
                }
                $Data = $null
            }
            }else{
                Invoke-Expression "`$postXML.$($ssconfig.post_loc).$($ssconfig.md5_loc)">>$DLPath\hashlist
            }
        }else{
            Write-Verbose ("Skipping download of file `""+$DLFile.split("\")[-1]+"`".")
        }

        if(Test-Path -Path $DLFile){
            Write-Host "Post #${Post} was successfully downloaded to ${DLPath}."
        }else{
            throw "Something went wrong during download. Is your file path valid?"
        }
        exit
    }else{
        $output = ($ssconfig).pre + (Invoke-Expression "`$postXML.$($ssconfig.post_loc).$($ssconfig.file_loc)")
    }
} elseif($PSCmdlet.ParameterSetName -eq "TagSearch") {
    $testData = Get-PageData -Url $(($ssconfig).url + ($ssconfig).page + "=1&" + ($ssconfig).tags + "=${Tags}")
    $pages = Get-TotalPages -var $testData
    $startPage = 1

    if($Count){
        if($ssconfig.json){ if($tags.Contains(" ") -or $tags.Contains(":") -or $($ssconfig.single_tag_url -eq $null)){
            $cont = Read-Host -Prompt "Counting search results on this server could take a very long time (>10 min!) Would you like to proceed? (Y/N)"
            if($cont[0] -ieq 'Y'){
                $page = Get-PageData -Url $($ssconfig.url + $ssconfig.tags + "=${Tags}&limit=" + $ssconfig.post_limit)
                $num = Invoke-Expression "`$page.$($ssconfig.post_loc).count"
                while((Invoke-Expression "`$page.$($ssconfig.post_loc).count") -eq $ssconfig.post_limit){
                    $lastCountID = Invoke-Expression "`$page.$($ssconfig.post_loc)[-1].id"
                    $page = Get-PageData -Url $($ssconfig.url + $ssconfig.tags + "=${Tags}&" + $ssconfig.page + "=b" + $lastCountID + "&limit=" + $ssconfig.post_limit)
                    $num += Invoke-Expression "`$page.$($ssconfig.post_loc).count"
                }
                return $num
            }
        } else {
            $tag=Get-PageData -Url $($ssconfig.single_tag_url+"search[name_matches]="+${Tags})
            if($tag.post_count -eq $null){
                $tag=Get-PageData -Url $($ssconfig.single_alias_url+"search[name_matches]="+${Tags})
            }
            $tag.post_count
        }
        } else {
            $testData.posts.count
        }
        exit
    }

    if($ssconfig.json){
        Write-Verbose $("Found posts matching tag(s) `"$Tags`".")
    } else {
        Write-Verbose $("Found " + ($testData).posts.count + " posts matching tag(s) `"$Tags`".")
    }

    if($testData.posts.offset -gt 0 -or (Invoke-Expression "`$testData.$($ssconfig.post_loc).length") -eq 0){
        $startPage = 0
        $testData = Get-PageData -Url $(($ssconfig).url + ($ssconfig).page + "=0&" + ($ssconfig).tags + "=${Tags}")
        $pages--
    }

    $firstID = Invoke-Expression "`$testData.$($ssconfig.post_loc)[0].id"

    if($getFirstID){
        $firstID
        exit
    }

    if((Invoke-Expression "`$testData.$($ssconfig.post_loc).count") -eq 1){
        if($array -and !$Download){
            $output = Invoke-Expression "`$testData.$($ssconfig.post_loc)"
        }elseif($Download){
            $id = Invoke-Expression "`$testData.$($ssconfig.post_loc).id"

            Write-Host "Downloading post #${id} from server `"${Server}`"..."

            if($MD5){
                $id = Invoke-Expression "`$testData.$($ssconfig.post_loc).$($ssconfig.md5_loc)"
            }

            Get-EventSubscriber -Force | Unregister-Event -Force
            Get-Job | Remove-Job -Force

            $DLClient = New-Object System.Net.WebClient
            $Post = Invoke-Expression "`$testData.$($ssconfig.post_loc)"
            if((Invoke-Expression "`$post.$($ssconfig.file_loc)") -eq $null){
                Invoke-Expression $ssconfig.blacklist_exp
                $Post = reconstruct $Post
            }
            $DLExt = (Invoke-Expression "`$Post.$($ssconfig.file_loc)").split('.')[-1]
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

            if($hashes.IndexOf((Invoke-Expression "`$Post.$($ssconfig.md5_loc)")) -eq -1){
                if((get-childitem ($DLPath+"*") | where Name -match "$id\.(${badExt})").count -eq 0){
                try{
                    $DLClient.DownloadFileAsync((Invoke-Expression "`$Post.$($ssconfig.file_loc)"), $DLFile)
                    
                    while(!$isDownloaded){
                        $progress = $Data.SourceArgs.ProgressPercentage
                        if($Data.SourceArgs.ProgressPercentage -eq $null){$progress = 0}
                        $sizeBytes = $Data.SourceArgs.TotalBytesToReceive
                        $downloadedBytes = $Data.SourceArgs.BytesReceived
                        Write-Progress -Activity "Downloading file" -Id 0 -Status " " -PercentComplete $progress -CurrentOperation "Downloading file $DLFile, have $downloadedBytes of $sizeBytes bytes"
                    }

                    if($array){return}
                    if(!$IgnoreHashCheck){HashCheck -Path $DLFile -Post $Post}
                    $testData.posts.post.md5>>$DLPath\hashlist
                    $metaExt = Add-Metadata -Path $DLFile -Post $Post
                    if($metaExt -ne $null){
                        $DLFile = $DLPath + $id + "." + $metaExt
                    }
                }finally{
                    if(!$isDownloaded){
                        $DLClient.CancelAsync()
                        del $DLFile
                        Write-Verbose "Ctrl-C recieved, deleting file"
                        exit
                    }
                }
                } else {
                    Invoke-Expression "`$Post.$($ssconfig.md5_loc)">>$DLPath\hashlist
                }
            }

            if((get-childitem (".\"+$id+".*") | where Name -match "$id\.(${badExt})").count -gt 0){
                Write-Host "Post #${id} was successfully downloaded to ${DLPath}."
            }else{
                throw "Something went wrong during download. Is your file path valid?"
            }

            $query = @{}
            $query.server = $Server
            $query.tags = $Tags
            $query.firstID = $firstID
            $query.md5 = if($MD5){$true}else{$false}
            $queryString = ConvertTo-JSON $query -Compress
            ToBase64 $queryString >> ($DLPath + "queries")

            exit
        }else{
            $output = Invoke-Expression "`$testData.$($ssconfig.post_loc).$($ssconfig.file_loc)"
        }
    } else {
        [String[]]$imageLinks = @()
        $Posts = $testData.posts.count
        $updateMode = Test-Path $DLPath"update"

        if($Download){
            Get-EventSubscriber -Force | Unregister-Event -Force
            Get-Job | Remove-Job -Force
            $Global:Data = $null
            $Global:isDownloaded = $False
            $DLClient = New-Object System.Net.WebClient
            $dataJob = Register-ObjectEvent -InputObject $DLClient -EventName DownloadProgressChanged -SourceIdentifier Web.DownloadProgressChanged -SupportEvent -Action {$Global:Data = $event;$Global:dataRegistered = $True}
            $completedJob = Register-ObjectEvent -InputObject $DLClient -EventName DownloadFileCompleted -SourceIdentifier Web.DownloadFileCompleted -MaxTriggerCount 999999999 -Action {$Global:isDownloaded = $True}
            $children = get-childitem $DLPath

            if($DLPath[-1] -ne "\"){$DLPath += "\"}
            if($updateMode){$updPosts = FromBase64 (Get-Content $DLPath"update")[1]}

            #download function for json servers
            if($ssconfig.json){
                if($updateMode){
                    Write-Progress -Activity ("Updating collection in `"" + $DLPath + "`"") -Id 0 -Status ("Server: " + $ssconfig.url.split("/")[0]) -PercentComplete 0 -CurrentOperation ("Retrieving data for page 1")
                }else{
                    Write-Progress -Activity ("Downloading from " + $ssconfig.url.split("/")[0]) -Id 0 -Status "Page 1" -PercentComplete 0 -CurrentOperation ("Retrieving data for page 1")
                }

                $CurrentPage = Get-PageData -Url $(($ssconfig).url + ($ssconfig).tags + "=${Tags}")
                $pageNum=1
                $postNum=1

                while((Invoke-Expression "`$CurrentPage.$($ssconfig.post_loc).count") -gt 0){
                    
                    if($updateMode){
                        Write-Progress -Activity ("Updating collection in `"" + $DLPath + "`"") -Id 0 -Status ("Server: " + $ssconfig.url.split("/")[0]) -PercentComplete 0 -CurrentOperation ("Downloading post #$postNum" )
                    }else{
                        Write-Progress -Activity ("Downloading from " + $ssconfig.url.split("/")[0]) -Id 0 -Status ("Page $pageNum") -PercentComplete 0 -CurrentOperation ("Downloading post #$postNum" )
                    }
                    ForEach-Object -InputObject (Invoke-Expression "`$CurrentPage.$($ssconfig.post_loc)") {
                        $id = $_.id
                        
                        if($MD5){
                            $id = Invoke-Expression "`$_.$($ssconfig.md5_loc)"
                        }

                        for($l=0; $l -lt $_.length; $l++){
                            if($hashes.IndexOf((Invoke-Expression "`$_[$l].$($ssconfig.md5_loc)")) -eq -1){
                                if((Invoke-Expression "`$_[$l].$($ssconfig.file_loc)") -eq $null){
                                    Invoke-Expression $ssconfig.blacklist_exp
                                    $_[$l] = reconstruct $_[$l]
                                }
                                $DLExt = (Invoke-Expression "`$_[$l].$($ssconfig.file_loc)").split('.')[-1]
                                $DLID = $id[$l]
                                $DLFile = $DLPath + $DLID + "." + $DLExt

                                if($invalidExtensions.$DLExt -ne $null){
                                    $badExt = $DLExt + "|" + $invalidExtensions.$DLExt
                                } else {
                                    $badExt = $DLExt
                                }

                                if(($children | where Name -match "$DLID\.(${badExt})meta").count -eq 1 -and !$updateMode){
                                    $untagged = $children | where Name -match "$DLID\.(${badExt})meta"
                                    $newName = $untagged.name.Substring(0,$untagged.Name.Length-4)
                                    ren $untagged.fullname $newName
                                    Add-Metadata -Path ($DLPath+$newName) -Post $_[$l] > $null
                                    Invoke-Expression "`$_[$l].$($ssconfig.md5_loc)">>($DLPath+"hashlist")
                                    continue
                                }

                                if(($children | where Name -match "$DLID\.(${badExt})").count -eq 0){
                                    try{
                                    $Global:isDownloaded = $False
                                    $Global:dataRegistered = $False
                                    $DLClient.DownloadFileAsync(($ssconfig).pre + (Invoke-Expression "`$_[$l].$($ssconfig.file_loc)"), $DLFile)
                                
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
                                            del $DLFile
                                            Write-Verbose "Ctrl-C recieved, cancelling download..."
                                        }
                                    }

                                    if($array){continue}
                                    if(!$IgnoreHashCheck){HashCheck -Path $DLFile -Post $_[$l]}
                                    Add-Metadata -Path $DLFile -Post $_[$l] > $null
                                }elseif($updateMode){
                                    if((Get-MetaData -File ($children | where Name -match "$DLID\.(${badExt})").Name -ExifID 20) -eq $trueName){
                                        del $DLPath"update"
                                        exit
                                    }else{
                                        Write-Verbose ("Skipping download of file `"" + $DLID + "." + $DLExt + "`".")
                                    }
                                }
                                Invoke-Expression "`$_[$l].$($ssconfig.md5_loc)">>($DLPath+"hashlist")
                            }elseif($updateMode){
                                $DLExt = (Invoke-Expression "`$_[$l].$($ssconfig.file_loc)").split('.')[-1]
                                $DLID = $id[$l]
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
                                }
                            }else{
                                Write-Verbose ("Skipping download of file `"" + $id[$l] + "." + (Invoke-Expression "`$_[$l].$($ssconfig.file_loc)").split('\.')[-1] + "`".")
                            }

                            $postNum++

                            if($updateMode){
                                Write-Progress -Activity ("Updating collection in `"" + $DLPath + "`"") -Id 0 -Status ("Server: " + $ssconfig.url.split("/")[0]) -CurrentOperation ("Downloading post #$postNum" )
                            }else{
                                Write-Progress -Activity ("Downloading from " + $ssconfig.url.split("/")[0]) -Id 0 -Status ("Page $pageNum") -CurrentOperation ("Downloading post #$postNum" )
                            }
                        }
                    }
                    $CurrentPage = Get-PageData -Url $(($ssconfig).url + ($ssconfig).page + "=b" + $id[-1] + "&" + ($ssconfig).tags + "=${Tags}")

                    if($updateMode){
                        Write-Host ("Updated page $pageNum.")
                    }else{
                        Write-Host ("Downloaded page $pageNum.")
                    }
                    $pageNum++
                }
                $query = @{}
                $query.server = $Server
                $query.tags = $Tags
                $query.firstID = $firstID
                $query.md5 = if($MD5){$true}else{$false}
                $queryString = ConvertTo-JSON $query -Compress
                ToBase64 $queryString >> ($DLPath + "queries")

                exit
            }

            #download function for xml servers
            for( $i=$startPage; $i -le $pages; $i++){
                if($updateMode){
                    Write-Progress -Activity ("Updating collection in `"" + $DLPath + "`"") -Id 0 -Status ("Server: " + $ssconfig.url.split("/")[0]) -PercentComplete 0 -CurrentOperation ("Retrieving data for page " + ($i-$startPage+1))
                }else{
                    Write-Progress -Activity ("Downloading from " + $ssconfig.url.split("/")[0]) -Id 0 -Status ("Page " + $($i + (1-$startPage)) + " of " + ($pages + (1-$startPage))) -PercentComplete 0 -CurrentOperation ("Retrieving data for page " + ($i-$startPage+1))
                }
                
                $CurrentPage = Get-PageData -Url $(($ssconfig).url + ($ssconfig).page + "=$i&" + ($ssconfig).tags + "=${Tags}")

                if($updateMode){
                    Write-Progress -Activity ("Updating collection in `"" + $DLPath + "`"") -Id 0 -Status ("Server: " + $ssconfig.url.split("/")[0]) -PercentComplete 0 -CurrentOperation ("Downloading post " + $(1+(($i-$startPage)*$_.length)) + "/${updPosts}" )
                }else{
                    Write-Progress -Activity ("Downloading from " + $ssconfig.url.split("/")[0]) -Id 0 -Status ("Page " + $($i + (1-$startPage)) + " of " + ($pages + (1-$startPage))) -PercentComplete 0 -CurrentOperation ("Downloading post " + $(1+(($i-$startPage)*$_.length)) + "/${Posts}" )
                }
                ForEach-Object -InputObject $CurrentPage.posts.post {
                    $id = $_.id

                    if($MD5){
                        $id = $_.md5
                    }

                    for($l=0; $l -lt $_.length; $l++){
                        if($hashes.IndexOf($_[$l].md5) -eq -1){
                            $DLExt = ($_[$l].file_url).split('.')[-1]
                            $DLID = $id[$l]
                            $DLFile = $DLPath + $DLID + "." + $DLExt

                            if($invalidExtensions.$DLExt -ne $null){
                                $badExt = $DLExt + "|" + $invalidExtensions.$DLExt
                            } else {
                                $badExt = $DLExt
                            }

                            if(($children | where Name -match "$DLID\.(${badExt})meta").count -eq 1 -and !$updateMode){
                                $untagged = $children | where Name -match "$DLID\.(${badExt})meta"
                                $newName = $untagged.name.Substring(0,$untagged.Name.Length-4)
                                ren $untagged.fullname $newName
                                Add-Metadata -Path ($DLPath+$newName) -Post $_[$l] > $null
                                $_[$l].md5>>($DLPath+"hashlist")
                                continue
                            }

                            if(($children | where Name -match "$DLID\.(${badExt})").count -eq 0){
                                try{
                                $Global:isDownloaded = $False
                                $Global:dataRegistered = $False
                                $DLClient.DownloadFileAsync(($ssconfig).pre + $_[$l].file_url, $DLFile)
                                
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
                                        del $DLFile
                                        Write-Verbose "Ctrl-C recieved, stopping download..."
                                    }
                                }

                                if($array){continue}
                                if(!$IgnoreHashCheck){HashCheck -Path $DLFile -Post $_[$l]}
                                Add-Metadata -Path $DLFile -Post $_[$l] > $null
                            }elseif($updateMode){
                                if((Get-MetaData -File ($children | where Name -match "$DLID\.(${badExt})").Name -ExifID 20) -eq $trueName){
                                    del $DLPath"update"
                                    exit
                                }else{
                                    Write-Verbose ("Skipping download of file `"" + $DLID + "." + $DLExt + "`".")
                                }
                            }
                            $_[$l].md5>>($DLPath+"hashlist")
                        }elseif($updateMode){
                            $DLExt = ($_[$l].file_url).split('.')[-1]
                            $DLID = $id[$l]
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
                            }
                        }else{
                            Write-Verbose ("Skipping download of file `"" + $id[$l] + "." + ($_[$l].file_url).split('.')[-1] + "`".")
                        }

                        if($updateMode){
                            $progress=[math]::Round(($l+1)*100/$updPosts)
                            if($progress -gt 100){$progress = 100}
                            Write-Progress -Activity ("Updating collection in `"" + $DLPath + "`"") -Id 0 -Status ("Server: " + $ssconfig.url.split("/")[0]) -PercentComplete $progress -CurrentOperation ("Downloading post " + $(($l+1)+(($i-$startPage)*$_.length)) + "/${updPosts}" )
                        }else{
                            Write-Progress -Activity ("Downloading from " + $ssconfig.url.split("/")[0]) -Id 0 -Status ("Page " + $($i + (1-$startPage)) + " of " + ($pages + (1-$startPage))) -PercentComplete $([math]::Round(($l+1)*100/$_.length)) -CurrentOperation ("Downloading post " + $(($l+1)+(($i-$startPage)*$_.length)) + "/${Posts}" )
                        }
                    }
                }

                if($updateMode){
                    Write-Host ("Updated page " + $($i + (1-$startPage)) + "/" + [math]::Ceiling($UpdPosts/[math]::Round($Posts/$pages)) + ".")
                }else{
                    Write-Host ("Downloaded page " + $($i + (1-$startPage)) + "/" + ($pages + (1-$startPage)) + ".")
                }
            }

            $query = @{}
            $query.server = $Server
            $query.tags = $Tags
            $query.firstID = $firstID
            $query.md5 = if($MD5){$true}else{$false}
            $queryString = ConvertTo-JSON $query -Compress
            ToBase64 $queryString >> ($DLPath + "queries")

            exit
        }

        if($array){
            $arrayFull = $false
            try{
                $global:postArray = @{}
                for( $i=$startPage; $i -le $pages; $i++){
                    $CurrentPage = Get-PageData -Url $(($ssconfig).url + ($ssconfig).page + "=$i&" + ($ssconfig).tags + "=${Tags}")
                    $postArray.("page"+($i + (1-$startPage))) = Invoke-Expression "`$CurrentPage.$($ssconfig.post_loc)"
                    Write-Host $("Added page " + $($i + (1-$startPage)) + "/" + ($pages + (1-$startPage)) + " to array.")
                }
                $arrayFull = $true
            }finally{
                $postArray
                if(!$arrayFull){
                    Write-Host "The command did not complete successfully. To see`npartial results, run '`$postArray', or if you want complete results, please re-run the command."
                }
                exit
            }
        }

        try{
            $didComplete = $false
            
            for( $i=$startPage; $i -le $pages; $i++){
                $CurrentPage = Get-PageData -Url $(($ssconfig).url + ($ssconfig).page + "=$i&" + ($ssconfig).tags + "=${Tags}")
                if($md5){
                    ForEach-Object -InputObject $CurrentPage.posts.post {$imageLinks += $_.md5}
                } else {
                    ForEach-Object -InputObject $CurrentPage.posts.post {$imageLinks += $_.file_url}
                }
                Write-Host $("Read page " + $($i + (1-$startPage)) + "/" + ($pages + (1-$startPage)) + ".")
            }
            $output = ForEach-Object -InputObject $imageLinks {$_ -replace " ","`n"}
            $didComplete = $true
        } finally{
            if(!$didComplete){
                if( $ToClipBoard ){
                    Set-Clipboard -Value ($imageLinks -join "`n")
                } else {
                    Write-Host ($imageLinks -join "`n")
                }
            }
        }
    }
}

if( $ToClipBoard ){
    Set-Clipboard -Value $output
} else {
    $output
}
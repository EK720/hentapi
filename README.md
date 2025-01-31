# hentapi
A Powershell-based imageboard search/download tool. Can programatically download and update images from many common booru types, including:
- Gelbooru
- Danbooru
- Shimmie
- MyImouto
- Sankaku Complex
- Booru.org

# Documentation
Documentation is contained in the script. To view it, run the command `Get-Help .\hentapi.ps1` in the same directory as the program itself.
Basic usage is done through the command `hentapi -server <Server Name> -tags "<Tags>" -limit <Limit> -Download`

# Other Info
 - If you have any issues with the program or suggestions for its improvement, please open an issue and let me know.
 - The program has an optional functionality that adds metadata tags to your downloaded images. To use this on images, you'll need to put [ExifTool](https://exiftool.org/) and [ImageMagick](https://imagemagick.org/) in your PATH. To use this on video files, you'll need to put [FFMpeg](https://ffmpeg.org/) and [mp4v2](https://archive.org/details/mp4v2-r504-win32.7z) in your PATH.

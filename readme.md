## webm2gif
convert webm to gif  
require [**ffmpeg(ffprobe)**](https://ffmpeg.zeranoe.com/builds/) and [**gifski**](https://gif.ski/)

Installed and add to environment variable  
run powershell or cmd to check:  

ffmpeg -version  
ffprobe -version  
gifski -V  

### usage
* set pnglib (a folder to save extracted png file)
* drag *.webm into this batch
* wait
* gif will save to same path as webm

### notice
if you interrupted this batch  
you need to delete the lastest folder it created  
recommend interrupt when it generating gif

you may want clean pnglib folder regularly  
it can take massive disk space if you convert frequently  

### update
In theory, this batch can handle all the video formats supported by ffmpeg  
Maybe I will update when I have time


## rotategif
lossless rotate gif (and other formats supported by magick)  
require [**ImageMagick**](https://imagemagick.org/script/download.php)

### usage
* set angle
* drag gif into this batch

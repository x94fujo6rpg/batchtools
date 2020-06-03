## webm2gif
convert webm to gif  
require  
[**ffmpeg(ffprobe)**](https://ffmpeg.zeranoe.com/builds/)  
[**gifski**](https://gif.ski/) Highest-quality GIF encoder  


Installed and add to environment variable  
run powershell or cmd to check:  

ffmpeg -version  
ffprobe -version  
gifski -V  

### usage
* set pnglib (a folder to save extracted png file)
* drag video into this batch
* wait
* gif will save to same path as webm

gif, log, pnglib(if not set) will at same path as webm  
can be execute wherever this batch at

### notice
if you interrupted this batch 
you need to delete the lastest folder/file it created  

you may want clean pnglib folder regularly  
it can take massive disk space if you convert frequently  

### update
2020/06/02 rewritten  
now it can execute anywhere, just drag file into it  
in theory, this batch can handle all the video formats supported by ffmpeg  
now support: **webm, mp4, mkv**  
untest: **webp, m4v, mov, avi, wmv, flv, hls, gif**

---

## rotategif
lossless rotate gif (and other formats supported by magick)  
require [**ImageMagick**](https://imagemagick.org/script/download.php)

### usage
* set angle
* drag gif into this batch

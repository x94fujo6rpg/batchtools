# personal batch tool box
**if you have garbled problem**  
**make sure you save batch file as utf-8 (no BOM)**

## webm2gif
convert webm to gif  
require **ffmpeg(ffprobe)** and **gifski**

Installed and set as environment variable  
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

## rotategif
lossless rotate gif (or other file magick supported)  
require **ImageMagick**

### usage
* set angle
* drag gif into this batch

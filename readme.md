## webm2gif(dragfile)
convert webm to gif  
require **ffmpeg(ffprobe)** and **gifski**

Installed and set as environment variable  
run powershell or cmd to check:  

ffmpeg -version  
ffprobe -version  
gifski -V  


### usage
1. set pnglib (a folder to save extracted png file)
2. drag *.webm in to this batch
3. wait
4. gif will save to same path as webm


### notice
if you interrupted this batch  
you need to delete the lastest folder it created  
recommend interrupt when it generating gif

you may want clean pnglib folder regularly  
it can take massive disk space if you convert frequently  
@echo off
::this batch require ffmpeg(ffprobe) and gifski
::installed and set as environment variable
::run powershell or cmd to check

::ffmpeg -version
::ffprobe -version
::gifski -V

::convert all webm drag into this batch to gif
::you can modify it to any format that ffmpeg support

::if you have garbled problem 
::make sure you save this file as utf-8 (no BOM)
chcp 65001

::for !variables!
setlocal EnableDelayedExpansion

::set a folder to save extracted png file
::so this or other batch don't have to extract everytime (if already extract once)
::you may want clean this folder regularly , this can take massive disk space if you convert frequently
set pnglib=""
::if you have interrupted this batch , you need to delete the lastest folder it created
::recommend interrupt when it generating gif

::set 1~100 , recommend set this higher than 50 , 100 is best quality
set gifquality=80

::threshold ex: min=15 max=30 then gif will be 15~30fps (auto selected via r_frame_rate from ffprobe)
set minfps=15
set maxfps=30

::set max gif width/height (if width/height bigger than this , auto down scale to this value)
set ow=500

::set calculate accurate to N decimal
set /a dec=2

if %pnglib% == "" (
	echo [pnglib] is not set , please set a folder for png extract
	goto end
)
set mypath=%cd%
cd /d %pnglib%
set pnglib=%cd%
cd /d %mypath%

set /a dec2=1
for /l %%s in (1,1,%dec%) do set /a dec2=dec2*10

echo [!date! !time!] ==============================new work 
echo [!date! !time!] maxfps=%maxfps%,minfps=%minfps%
echo [!date! !time!] gifquality=%gifquality%,max width/height:%ow%
echo [!date! !time!] pnglib=%pnglib%
echo [!date! !time!] decimal=%dec%
echo [!date! !time!] ____________________________________________________________

echo: >> webm2gif_drag.log
echo [!date! !time!] ==============================new work >> webm2gif_drag.log
echo [!date! !time!] maxfps=%maxfps%,minfps=%minfps% >> webm2gif_drag.log
echo [!date! !time!] gifquality=%gifquality%,max width/height:%ow% >> webm2gif_drag.log
echo [!date! !time!] pnglib=%pnglib% >> webm2gif_drag.log
echo [!date! !time!] decimal=%dec% >> webm2gif_drag.log
echo [!date! !time!] ____________________________________________________________ >> webm2gif_drag.log

:loop
if "%~1" == "" (
	echo [!date! !time!] no file input
	echo [!date! !time!] no file input >> webm2gif_drag.log
	goto end
)

if not "%~x1" == ".webm" (
	echo [!date! !time!] unsupported file extension
	echo [!date! !time!] skip %~nx1
	echo [!date! !time!] unsupported file extension >> webm2gif_drag.log
	echo [!date! !time!] skip %~nx1 >> webm2gif_drag.log
	shift
	goto loop
)

echo [!date! !time!] [%~n1] start
echo [!date! !time!] [%~n1] start >> webm2gif_drag.log

::get file source path
set sourcepath=%~dp1
echo [!date! !time!] path="!sourcepath!"
echo [!date! !time!] path="!sourcepath!" >> webm2gif_drag.log

::get video info via ffprobe
for /f "delims=" %%g in ('ffprobe -hide_banner -show_streams "%~dp1%~n1.webm" 2^>nul ^| findstr "^width= ^height= ^r_frame_rate="') do set res_%%g
set w=!res_width!
set h=!res_height!
set /a autofps=100*!res_r_frame_rate!
set /a mod=!autofps!%%100

::roundup fps ex:15.1~15.9 will be roundup to 16
if !mod! GTR 0 ( 
	set /a "autofps=(!autofps!+100)/100"
	echo [!date! !time!] roundup fps+1 >> webm2gif_drag.log
) else (
	set /a "autofps=!autofps!/100"
)

::fix fps to set value
if !autofps! GTR %maxfps% (
	set autofps=%maxfps%
	echo [!date! !time!] fps too high,set to %maxfps%
	echo [!date! !time!] fps too high,set to %maxfps% >> webm2gif_drag.log
)
if !autofps! LSS %minfps% (
	set autofps=%minfps%
	echo [!date! !time!] fps too low,set to %minfps%
	echo [!date! !time!] fps too low,set to %minfps% >> webm2gif_drag.log
)

echo [!date! !time!] fps=!autofps! >> webm2gif_drag.log
echo [!date! !time!] width=!res_width!,height=!res_height!,max=%ow% >> webm2gif_drag.log

::test and creat folder then extract png via ffmpeg
::not perfect , if you have interrupted this batch , you need to delete lastest folder it created
::if you have to , recommend interrupt when it generating gif
IF EXIST "%pnglib%\%~n1_f!autofps!\f0001.png" (
	echo [!date! !time!] extract exist,skip
	echo [!date! !time!] extract exist,skip >> webm2gif_drag.log
) ELSE (
	echo [!date! !time!] extracting...
	echo [!date! !time!] extracting... >> webm2gif_drag.log
	md "%pnglib%"\%~n1_f!autofps!
	ffmpeg -i "%~dp1%~n1.webm" -r !autofps! "%pnglib%\%~n1_f!autofps!\f%%04d.png" -n -hide_banner -v quiet
	echo [!date! !time!] complete extract png 
	echo [!date! !time!] complete extract png >> webm2gif_drag.log
)

::calculate aspect ratio
set /a asp=!dec2!*!w!/!h!	
::auto scale width and height so it doesn't exceed max value
if !h! GTR !w! (
	if !h! GTR %ow% (
		set /a asp=!dec2!*!h!/!ow!
		set /a res=!dec2!*!w!/!asp!
		echo [!date! !time!] width^<height and height^>max,scale down to [!res!] >> webm2gif_drag.log
	) else (
		set res=!w!
		echo [!date! !time!] width^<height but height^<max,use original width [!res!] >> webm2gif_drag.log
	)
) else (
	if !w! GTR %ow% (
		set res=%ow%
		echo [!date! !time!] width^>height and width^>max,scale down to [!res!] >> webm2gif_drag.log
	) else (
		set res=!w!
		echo [!date! !time!] width^>height but width^<max,use original width [!res!] >> webm2gif_drag.log
	)
)

::use gifski to generate gif
IF EXIST "!sourcepath!%~n1_w!res!_f!autofps!_q%gifquality%.gif" (
	echo [!date! !time!] gif exist,skip
	echo [!date! !time!] gif exist,skip >> webm2gif_drag.log
) ELSE (
	echo [!date! !time!] converting...
	echo [!date! !time!] converting... >> webm2gif_drag.log
	gifski -o "!sourcepath!%~n1_w!res!_f!autofps!_q%gifquality%.gif" "%pnglib%"\%~n1_f!autofps!\f*.png -W !res! --quality %gifquality% --fps !autofps!
	echo [!date! !time!] complete convert gif
	echo [!date! !time!] complete convert gif >> webm2gif_drag.log
)
echo [!date! !time!] ____________________________________________________________
echo [!date! !time!] ____________________________________________________________ >> webm2gif_drag.log

::moving to next file
shift
::if there is any file left , continue
if not "%~1" == "" goto loop
::pause when all complete
echo [!date! !time!] all done
echo [!date! !time!] all done >> webm2gif_drag.log
:end
pause
exit

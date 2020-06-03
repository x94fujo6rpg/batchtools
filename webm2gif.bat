@echo off
chcp 65001
setlocal EnableDelayedExpansion
cls
::convert all webm drag into this batch to gif
::you can modify it to any format that ffmpeg support

::this batch require ffmpeg(ffprobe) and gifski
::installed and set as environment variable
::run powershell or cmd to check
::ffmpeg -version
::ffprobe -version
::gifski -V

::if you have garbled problem 
::make sure you save this file as utf-8 (no BOM)

::=====================================================================
::settings
::=====================================================================
::set a folder to save extracted png file
::so this or other batch don't have to extract everytime (if already extract once)
::you may want clean this folder regularly , this can take massive disk space if you convert frequently
set _pnglib=""
::if not set,this batch will creat a folder at video path

::set 1~100 , recommend set this higher than 50 , 100 is best quality
set _gifquality=100

::threshold ex: min=15 max=30 then gif will be 15~30fps (auto selected via r_frame_rate from ffprobe)
set _minfps=30
set _maxfps=30

::set max gif width/height (if width/height bigger than this , auto down scale to this value)
set _ow=720

::set calculate accurate to N decimal
set _dec=2

::enable log or not (True/False)
set _log=True

::=====================================================================
::start
::=====================================================================

call :echo2 "=========================================================="

::get current path
set _mypath="%cd%"

::set log path
set _mylog="%_mypath%\%~n0.log"

::set source path
set _sourcepath="%~dp1"

call :echo2 "check pnglib..."
call :lib_check %_pnglib% %_sourcepath% %_mypath%
call :echo2 "=========================================================="
call :echo2 "[batch start]"
call :echo2 "=========================================================="
call :echo2 "enable log=%_log%"
call :echo2 "maxfps=%_maxfps%,minfps=%_minfps%"
call :echo2 "gifquality=%_gifquality%,max size:%_ow%"
call :echo2 "decimal=%_dec%"
call :echo2 1 "pnglib=" %_pnglib%
call :echo2 1 "sourcepath=" %_sourcepath%
call :echo2 "=========================================================="

:loop
call :check_ext %1
call :echo2 1 "start" "%~nx1"
call :getvideoinfo %1 %_ow%
call :roundup %_autofps%
call :fixfps %_autofps% %_minfps% %_maxfps%
call :extractpng %1 %_pnglib% %_autofps%
call :calasp %_w% %_h% %_dec% %_ow% %_asp%
call :gengif %1 %_pnglib% %_sourcepath% %_autofps% %_gifquality% !_res!
call :echo2 "============================"

::moving to next file
shift
::continue
if not "%~1" == "" goto loop
:end
::pause when all complete
call :echo2 "all done"
pause
exit

::=====================================================================
::pnglib check
::%_pnglib% %_sourcepath% %_mypath%
::=====================================================================
:lib_check
	if EXIST %1 (
		call :echo2 "pnglib is set"
		GOTO :eof
	) else (
		cd /d %2
			if EXIST "%cd%\png(extract)" (
				call :echo2 "found at source path,set as pnglib"
				goto :lib_check_skip
			) else (
				call :echo2 "[31mpnglib not set[0m,creat a folder at source path"
				md "png(extract)"
			)
		:lib_check_skip
		set _pnglib="%cd%\png(extract)"
		cd /d %3
	)
GOTO :eof

::=====================================================================
::format check
::%1
::=====================================================================
:check_ext
	if "%~1" == "" (
		call :echo2 "no file input,end batch"
		goto end
	)

	if "%~x1" == ".webm" GOTO :eof
	if "%~x1" == ".mp4" GOTO :eof
	if "%~x1" == ".mkv" GOTO :eof
	
	::untest
	if "%~x1" == ".m4v" GOTO :eof
	if "%~x1" == ".flv" GOTO :eof	
	if "%~x1" == ".hls" GOTO :eof
	if "%~x1" == ".gif" GOTO :eof
	if "%~x1" == ".mov" GOTO :eof
	if "%~x1" == ".webp" GOTO :eof
	if "%~x1" == ".avi" GOTO :eof
	if "%~x1" == ".wmv" GOTO :eof	
	
	call :echo2 "[error] %~nx1 is an unsupported format , ignore"
	call :echo2 "____________________________________________________________"
	shift
	goto loop
GOTO :eof


::=====================================================================
::get video info via ffprobe
::%1 %_ow%
::=====================================================================
:getvideoinfo
	SETLOCAL
		for /f "delims=" %%g in ('ffprobe -hide_banner -show_streams %1 2^>nul ^| findstr "^width= ^height= ^r_frame_rate="') do set res_%%g
		call :echo2 "width=!res_width!,height=!res_height!,max=%_ow%"
	ENDLOCAL & set _w=%res_width% & set _h=%res_height% & set _autofps=%res_r_frame_rate%
GOTO :eof


::=====================================================================
::roundup fps ex:15.1~15.9 will be roundup to 16
::%_autofps%
::=====================================================================
:roundup
	SETLOCAL
	set __num=%1
	set /a __num=100*%__num%
	set /a __mod=%__num%%%100
	if %__mod% GTR 0 ( 
		set /a "__num=(%__num%+100)/100"
		call :echo2 "roundup"
	) ELSE (
		set /a "__num=%__num%/100"
	)
	ENDLOCAL & set _autofps=%__num% & call :echo2 "video_fps=%_autofps%"
GOTO :eof


::=====================================================================
::fix fps to set value
::%_autofps% %_minfps% %_maxfps%
::=====================================================================
:fixfps
	SETLOCAL
	set __fps=%~1
	set __min=%~2
	set __max=%3
	
	if %__fps% GTR %__max% (
		set __fps=%__max%
		call :echo2 "fps too high,set gif_fps=%__max%"
	) else (
		if %__fps% LSS %__min% (
			set __fps=%__min%
			call :echo2 "fps too low,set gif_fps=%__min%"
		) else (
			call :echo2 "set gif_fps=%__fps%"
		)
	)	
	ENDLOCAL & set _autofps=%__fps%
GOTO :eof


::=====================================================================
::test and creat folder then extract png via ffmpeg
::not perfect , if you have interrupted this batch , you need to delete lastest folder it created
::if you have to , recommend interrupt when it generating gif
::%1 %_pnglib% %_autofps%
::=====================================================================
:extractpng
	SETLOCAL
	set __pnglib=%~2
	set __fps=%~3
	set __png=%__pnglib%\%~n1_f%__fps%
	
	IF EXIST !__png! (
		call :echo2 "extract exist,skip"
	) ELSE (
		call :echo2 "extracting..."
		md "!__png!"
		ffmpeg -i %1 -r %__fps% "%__pnglib%\%~n1_f%__fps%\f%%04d.png" -n -hide_banner -v quiet
		call :echo2 "png extract complete"
	)
	ENDLOCAL
GOTO :eof

::=====================================================================
::calculate aspect ratio
::auto scale width and height so it doesn't exceed max value
::%w% %h% %_dec% %_ow% %asp%
::=====================================================================
:calasp 
	SETLOCAL
	set __w=%~1
	set __h=%~2
	set __dec=%~3
	set __ow=%~4
	set __asp=%~5
	set __dec2=1
	
	for /l %%s in (1,1,%__dec%) do (set /a __dec2=!__dec2!*10)

	set /a __asp=!__dec2!*!__w!/!__h!

	if %__h% GTR %__w% (
		if %__h% GTR %__ow% (
			set /a __asp=!__dec2!*!__h!/!__ow!
			set /a __res=!__dec2!*!__w!/!__asp!
			call :echo2 "width＜height and height＞max,width scale down to [!__res!]"
		) ELSE (
			set __res=%__w%
			call :echo2 "width＜height but height＜max,use original width [!__res!]"
		)
	) ELSE (
		if %__w% GTR %__ow% (
			set __res=%__ow%
			call :echo2 "width＞height and width＞max,width scale down to [!__res!]"
		) ELSE (
			set __res=%__w%
			call :echo2 "width＞height but width＜max,use original width [!__res!]"
		)
	)
	ENDLOCAL & set _res=%__res%
GOTO :eof


::=====================================================================
::use gifski to generate gif
::%1 %_pnglib% %_sourcepath% %_autofps% %_gifquality% %_res%
::=====================================================================
:gengif 
	SETLOCAL
	set __file=%~n1
	set __pnglib=%~2
	set __sourcepath=%~3
	set __fps=%~4
	set __quality=%~5
	set __res=%~6
	set __gif=%__sourcepath%%__file%_w%__res%_f%__fps%_q%__quality%.gif
	set __png=%__pnglib%\%~n1_f%__fps%
	IF EXIST !__gif! (
		call :echo2 "gif exist,skip"
	) ELSE (
		call :echo2 "converting..."
		cd /d "%__png%"
		gifski -o "%__gif%" f*.png -W %__res% --quality %__quality% --fps %__fps%
		cd /d "%_mypath%"
		echo:
		call :echo2 "gif convert complete"
	)
	ENDLOCAL
GOTO :eof


::=====================================================================
::echo to screen and file if enable log
::=====================================================================
:echo2
	SETLOCAL
	if %1 == 1 (
		if "%_log%" == "True" (
			echo [%date% %time%] %~2%3
			echo [%date% %time%] %~2%3 >> !_mylog!
		) else (
			echo [%date% %time%] %~2%3
		)
	) else (
		if "%_log%" == "True" (
			echo [%date% %time%] %~1
			echo [%date% %time%] %~1 >> !_mylog!
		) else (
			echo [%date% %time%] %~1
		)
	)
	ENDLOCAL
GOTO :eof

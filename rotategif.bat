@echo off
::if you have code problem 
::make sure you save this file as utf-8 (no BOM)
chcp 65001
cls

:: for !variables!
setlocal EnableDelayedExpansion

:: set rotate angle
set angle=180
echo rotate angle=%angle%

:: set file name that will add to rotated file
set nname=r%angle%_

:loop
if "%~1" == "" (
	echo no file input
	goto end
)

set newname="%~dp1%nname%%~nx1"

if not exist !newname! (
	echo convert %~nx1 to %nname%%~nx1
	convert %1 -rotate %angle% !newname!
) else (
	echo file exist , skip %~nx1
)

shift
if not "%~1" == "" goto loop
:end
exit
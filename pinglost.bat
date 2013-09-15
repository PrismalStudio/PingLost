@echo off
GOTO pingloststart
/////////////////////////
DOCUMENTATION




/////////////////////////
:pingloststart
setlocal enabledelayedexpansion
set hostIP=%1

REM Set Filename with Date and Time
For /f "tokens=1-4 delims=- " %%a in ('date /t') do (set mydate=%%a-%%b-%%c)
For /f "tokens=1-2 delims=:" %%a in ('time /t') do (set mytime=%%ah%%b)

set startTimeStamp=%mydate%_%mytime%
set filename=Ping_%hostIP%_%startTimeStamp%

REM file creation and setting the header
echo USAGE: pinglog [host or IP] [number of ping] > %filename%.txt
echo Only lost packets are logged. >> %filename%.txt
echo Ping started at %startTimeStamp% >> %filename%.txt
echo -------------------------------------- >> %filename%.txt

REM iterate x times, where x is %2
for /l %%x in (2, 1, %2) do (
	call :pingcommand
	REM hack to wait 1 second approx., works on every PC
	PING -n 2 127.0.0.1>nul 
)
:exit /b

REM FUNCTION the ping command and echoing only lost packets
:pingcommand
set pingline=1
for /f "delims=" %%A in ('ping -n 1 -w 500 -l 255 %hostIP%') do (
	if !pingline! equ 2 (
		set logline=!date! !time! "%%A"
		echo !logline! | find "TTL=">nul || echo !logline! >> %filename%.txt
		)
	set /a pingline+=1
	)
echo %logline%
exit /b
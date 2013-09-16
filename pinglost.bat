@echo off
GOTO documentationend
/////////////////////////
DOCUMENTATION

Author: E. Bergeron
Website: www.prismalstudio.com
Email: contact@prismalstudio.com

Options parsing provided by dbenham on stackoverflow.com
http://stackoverflow.com/a/8162578/1218980

Useful when you want to know when a packet was lost. Use it to ping 
multiple hostname and see if both were losing packets at the same time.

For help:
pinglost /?

To add:
+ Ping statistic

/////////////////////////
:documentationend
	setlocal enabledelayedexpansion
	
	:: Can't run without param
	IF "%~1"=="" (
		echo Use the "/?" flag for help
		exit /b
	)
	:: Default help call
	IF "%~1"=="/?" (
		call :help
		exit /b
	)
	
	:: start the program
	goto :pingloststart
		
:help
	:: Called when the flag /? is the first param
	echo.
	echo The pinglost command sends a ping request to "hostname_or_IP" then logs the
	echo lost packets and state changes into a file called 
	echo "PingLost_hostname_AAAAMMDD_HHMM.txt" with a timestamp.
	echo.
	echo call: pinglost hostname_or_IP [-n count] [-l size] [-w timeout]
	echo.
	echo -n count         Specifies the number of Echo Request messages sent.
	echo                  The default is 4.
	echo -l size          Specifies the length, in bytes, of the Data field in 
	echo                  the Echo Request messages sent. The default is 32. 
	echo                  The maximum size is 65,527.
	echo -w timeout       Specifies the amount of time, in milliseconds, to wait 
	echo                  for the Echo Reply message that corresponds to a given 
	echo                  Echo Request message to be received. If the Echo Reply 
	echo                  message is not received within the time-out, the "Request 
	echo                  timed out" error message is displayed. The default 
	echo                  time-out is 4000 (4 seconds).
	echo.
	echo The parameters following the hostname can be in any order.
	exit /b

:pingloststart
	:: Define the option names along with default values, using a <space>
	:: delimiter between options.
	::
	:: Each option has the format -name:[default]
	::
	:: The option names are NOT case sensitive.
	::
	:: Options that have a default value expect the subsequent command line
	:: argument to contain the value. If the option is not provided then the
	:: option is set to the default. If the default contains spaces, contains
	:: special characters, or starts with a colon, then it should be enclosed
	:: within double quotes. The default can be undefined by specifying the
	:: default as empty quotes "".
	:: NOTE - defaults cannot contain * or ? with this solution.
	::
	:: Options that are specified without any default value are simply flags
	:: that are either defined or undefined. All flags start out undefined by
	:: default and become defined if the option is supplied.
	::
	:: The order of the definitions is not important.
	:: example:
	:: set "options=-n:4 -option2:"" -option3:"three word default" -help: -flag2:"
	::
	set "options=-n:4 -l:32 -w:4000"

	:: Set the default option values
	for %%O in (%options%) do for /f "tokens=1,* delims=:" %%A in ("%%O") do set "%%A=%%~B"

:loopoptions
	:: Validate and store the options, one at a time, using a loop.
	:: Options start at arg 3 in this example. Each SHIFT is done starting at
	:: the first option so required args are preserved.
	::
	if not "%~2"=="" (
		set "test=!options:*%~2:=! "
		if "!test!"=="!options! " (
			rem No substitution was made so this is an invalid option.
			rem Error handling goes here.
			rem I will simply echo an error message.
			echo Error: Invalid option %~2
		) else if "!test:~0,2!"==" " (
			rem Set the flag option using the option name.
			rem The value doesn't matter, it just needs to be defined.
			set "%~2=1"
		) else (
			rem Set the option value using the option as the name.
			rem and the next arg as the value
			set "%~2=%~3"
			shift /2
		)
		shift /2
		goto :loopoptions
	)
	
:pinglostcommand
	:: default param for the IP or hostname
	set hostIP=%1

	:: format and sets the Date and Time vars
	For /f "tokens=1-4 delims=- " %%a in ('date /t') do (set mydate=%%a%%b%%c)
	For /f "tokens=1-2 delims=:" %%a in ('time /t') do (set mytime=%%a%%b)

	set startTimeStamp=%mydate%_%mytime%
	set filename=PingLost_%hostIP%_%startTimeStamp%

	:: file creation and setting the header
	echo Use "/?" for help. > %filename%.txt
	echo Only lost packets and state changes are logged. >> %filename%.txt
	echo Ping to %hostIP% started at %startTimeStamp% with options: >> %filename%.txt
	set - >> %filename%.txt
	echo -------------------------------------- >> %filename%.txt
	echo Trying to connect to %hostIP% ... >> %filename%.txt

	set state=fail
	set laststate=fail
	:: iterate x times, where x is the -n option
	for /l %%x in (2, 1, %-n%) do (
		call :pingfunction
		REM hack to wait 1 second approx., works on every PC
		ping -n 2 127.0.0.1 >nul: 2>nul:
	)
:exit /b

:pingfunction
	:: FUNCTION the ping command and echoing only lost packets
	:: in order to output properly into a text file, it only send one ping
	:: at the time.
	set logline=error
	set state=fail
	for /f "delims=" %%A in ('ping -n 1 -w %-w% -l %-l% %hostIP% ^| find "TTL="') do (
		set logline=%%A
		set state=success
	)

	echo !date! !time! !logline!
	if not !state!==!laststate! echo !date! !time! state changed to !state! >> %filename%.txt
	if !logline!==error echo !date! !time! Lost packet >> %filename%.txt
	
	set laststate=!state!
	exit /b
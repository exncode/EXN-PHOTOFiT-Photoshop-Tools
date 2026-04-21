@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
set _ver=v1.1.0
mode con: cols=50 lines=15


::Colors
set rst=[m
set bbe=[m[48;2;000;030;054m[38;2;049;168;255m
set fbe=[m[38;2;049;168;255m
set fgn=[92m
set bgn=[102m[30m
set frd=[31m
set "bsm=echo %bbe%       %rst%"
set "bbg=echo %bbe%                                                  %rst%"
set "gsm=echo %bgn%       %rst%"


::Title
title EXN PHOTOFiT %_ver%
echo %bbe%                                                  %rst%
echo %bbe%       EXN PHOTOFiT: Photoshop Tools %_ver%       %rst%
echo %bbe%                                                  %rst%


:chk_admin :: Check admin
FLTMC >nul 2>&1

if %errorlevel%==1 (
	goto run_as_admin
	) else (
	goto chk_req
)

:run_as_admin
echo:
echo  Trying to elevate the script...
powershell -command "try { Start-Process -FilePath '%0' -ArgumentList 'am_admin' -Verb RunAs -ErrorAction Stop } catch { exit 1 }"

if %errorlevel%==1 goto not_admin
exit /b

:not_admin
echo:
echo %frd% The program was unable to acquire
echo  administrator privileges.%rst%
echo:
echo  Run this program as administrator to
echo  ensure it functions correctly.
echo:
echo  Press any key to exit...
pause >nul
exit




:chk_req ::Verify Requeriments

del /f /s /q "%temp%\exnps.txt" >nul 2>&1
dir /b "%ProgramFiles%\Adobe\*Photoshop*" > %temp%\exnps.txt
set "ps_cmd=type %temp%\exnps.txt ^| find"
set "error_old=call :er & echo %frd% You are using an very old version of Photoshop.%rst%&echo  Press any key to exit. & pause >nul & exit"


::One version?
for /f %%G in (

	'type %temp%\exnps.txt ^| find /c /i "Photoshop"'

) do (
	
	if %%G GTR 1 (
		call :er
		echo There are multiple versions of Photoshop
		echo installed on the system.
		echo:
		echo Press any key to exit.
		pause >nul
		exit

	)
)


::CS?
findstr /i "CS" %temp%\exnps.txt >nul 2>&1
if %errorlevel%==0 %error_old%


::CC?
findstr /i "CC" %temp%\exnps.txt >nul 2>&1
if %errorlevel%==0 %error_old%


::PS Version
for /f "tokens=3" %%G in ('%ps_cmd%str /r "[0-9]"') do (set ps_ver=%%G)
set "ps_dir=%ProgramFiles%\Adobe\Adobe Photoshop %ps_ver%"


::Op
set "nop=msg * This isn't a valid option. Choose a number from the list."


::N of functions
for /l %%G in (1,1,5) do (set ps_op%%G=1)


:menu
mode con: cols=50 lines=15
cls
title EXN PHOTOFiT %_ver%
call :ps_top
echo [7A[43C%bbe%%fgn%PS %ps_ver% [1H[6B
echo %bbe%   1   %fbe%  Kill Background Processes
echo %bbe%   2   %fbe%  Debloat Photoshop
echo %bbe%   3   %fbe%  Firewall - Block PS
echo %bbe%   4   %fbe%  Project Page
echo %bbe%   5   %fbe%  Exit
%bsm%
echo:
set /p choice=── Type a number and press ENTER: 
if !ps_op%choice%! NEQ 1 (%nop% & goto menu) else (goto ps_op%choice%)


:ps_op1
cls
call :ps_top
echo %bbe%   ─   %fbe%  Kill Background Processes%rst%
%bsm%
call :yn
set /p ps_op1_c=── 
if %ps_op1_c%==1 echo [6A&call :act&call :ps_op1_go &echo [5A&call :ok& pause >nul & goto menu
if %ps_op1_c%==2 goto menu
%nop% & goto ps_op1


:ps_op1_go
:: Kill processes
for %%G in (
"Adobe CEF Helper.exe"
"Adobe Desktop Service.exe"
"Adobe Installer.exe"
"AdobeGCClient.exe"
"AdobeIPCBroker.exe"
"AdobeNotificationClient.exe"
"AdobeUpdateService.exe"
"AGMService.exe"
"AGSService.exe"
"CCLibrary.exe"
"CCXProcess.exe"
"CoreSync.exe"
"Creative Cloud.exe"
"LogTransport2.exe"
) do (taskkill /f /im %%G >nul 2>&1)


:: Disable Services
for %%G in (AGSService AdobeUpdateService AGMService AdobeARMservice) do (sc stop %%G >nul 2>&1 & sc config %%G start= disabled >nul 2>&1)
schtasks /change /tn "Adobe Creative Cloud" /Disable >nul 2>&1
goto:eof


:ps_op2
cls
call :ps_top
echo %bbe%   ─   %fbe%  Debloat Photoshop%rst%
%bsm%  Core Sync, CCX Process and A LOT more
%bsm%
call :yn
set /p ps_op2_c=── 
if %ps_op2_c%==2 goto menu
if %ps_op2_c%==1 goto ps_op2_go
%nop% & goto ps_op2


:ps_op2_go
echo [6A
call :act
::Kill processes first
call :ps_op1_go

::Start debloat process
for %%G in (
"%ProgramFiles%\Adobe\Adobe Photoshop %ps_ver%\Adobe Crash Processor.exe.bak"
"%ProgramFiles%\Adobe\Adobe Photoshop %ps_ver%\CRLogTransport.exe.bak"
"%ProgramFiles%\Adobe\Adobe Photoshop %ps_ver%\dvaappsupport.dll.bak"
"%ProgramFiles%\Adobe\Adobe Photoshop %ps_ver%\LogTransport2.exe.bak"
"%ProgramFiles%\Adobe\Adobe Photoshop %ps_ver%\Photoshop.exe.bak"
"%ProgramFiles(x86)%\Common Files\Adobe\Installers\Install.log"
"%ProgramFiles(x86)%\Common Files\Adobe\Installers\CoreSyncInstall.log"
"%CommonProgramFiles(x86)%\Adobe\Adobe Desktop Common\IPCBox\CRLOGTransport.exe"
"%CommonProgramFiles(x86)%\Adobe\Adobe Desktop Common\IPCBox\CRWindowsClientService.exe"
) do (
	del /s /f /q %%G >nul 2>&1
)


for %%G in (
"%appdata%\Adobe\Adobe PDF"
"%appdata%\Adobe\CameraRaw\Logs"
"%appdata%\Adobe\Common\Media Cache Files"
"%appdata%\Adobe\Common\Media Cache"
"%appdata%\Adobe\Common\Peak Files"
"%appdata%\Adobe\Common\Team Projects Cache"
"%appdata%\Adobe\Common\Team Projects Local Hub"
"%appdata%\Adobe\CRLogs"
"%appdata%\Adobe\Team Projects Local Hub"
"%CommonProgramFiles%\Adobe\Adobe Desktop Common"
"%CommonProgramFiles%\Adobe\Adobe Unlicensed Pop-up Blocker"
"%CommonProgramFiles%\Adobe\AdobeGCClient"
"%CommonProgramFiles%\Adobe\CoreSyncExtension"
"%CommonProgramFiles%\Adobe\Creative Cloud Libraries"
"%CommonProgramFiles%\Adobe\Microsoft"
"%CommonProgramFiles%\Adobe\UXP"
"%CommonProgramFiles(x86)%\Adobe\ADCRefs"
"%CommonProgramFiles(x86)%\Adobe\Adobe Desktop Common\AdobeGenuineClient"
"%CommonProgramFiles(x86)%\Adobe\Adobe Desktop Common\ADS"
"%CommonProgramFiles(x86)%\Adobe\Adobe Desktop Common\HDBox"
"%CommonProgramFiles(x86)%\Adobe\Adobe Desktop Common\LCC"
"%CommonProgramFiles(x86)%\Adobe\Adobe Desktop Common\Runtime"
"%CommonProgramFiles(x86)%\Adobe\Adobe PCD"
"%CommonProgramFiles(x86)%\Adobe\Adobe Photoshop %ps_ver%"
"%CommonProgramFiles(x86)%\Adobe\AdobeApplicationManager"
"%CommonProgramFiles(x86)%\Adobe\CoreSyncExtension"
"%CommonProgramFiles(x86)%\Adobe\HelpCfg"
"%CommonProgramFiles(x86)%\Adobe\OOBE"
"%CommonProgramFiles(x86)%\Adobe\PCF"
"%CommonProgramFiles(x86)%\Adobe\Scripting Dictionaries CC"
"%CommonProgramFiles(x86)%\Adobe\SLCache"
"%CommonProgramFiles(x86)%\Adobe\Startup Scripts CC"
"%CommonProgramFiles(x86)%\Adobe\Vulcan"
"%Homepath%\AppData\LocalLow\Adobe"
"%Homepath%\Creative Cloud Files"
"%LocalAppData%\Adobe\CameraRaw"
"%LocalAppData%\Adobe\licflags"
"%LocalAppData%\Adobe\NGL"
"%LocalAppData%\Adobe\OOBE"
"%ProgramData%\Adobe\CameraRaw\CameraProfiles"
"%ProgramData%\Adobe\CameraRaw\LensProfiles"
"%ProgramData%\Adobe\CameraRaw\Libraries"
"%ProgramData%\Adobe\CameraRaw\Settings\Adobe\Profiles\Camera"
"%ProgramData%\Adobe\Installer"
"%ProgramData%\Adobe\SLStore"
"%ProgramFiles%\Adobe\Adobe Creative Cloud Experience"
"%ProgramFiles%\Adobe\Adobe Creative Cloud"
"%ProgramFiles%\Adobe\Common"
"%ProgramFiles%\Adobe\Adobe Photoshop %ps_ver%\Required\CEP\extensions\com.adobe.DesignLibraryPanel.html"
"%ProgramFiles%\Adobe\Adobe Photoshop %ps_ver%\Required\DynamicLinkMediaServer"
"%ProgramFiles%\Adobe\Adobe Photoshop %ps_ver%\Required\Linguistics"
"%ProgramFiles%\Adobe\Adobe Photoshop %ps_ver%\Required\UXP\com.adobe.cclibrariespanel"
"%ProgramFiles%\Adobe\Adobe Photoshop %ps_ver%\Required\UXP\com.adobe.ccx.comments-webview"
"%ProgramFiles%\Adobe\Adobe Photoshop %ps_ver%\Required\UXP\com.adobe.photoshop.inAppMessaging"
"%ProgramFiles%\Adobe\Adobe Photoshop %ps_ver%\Required\UXP\com.adobe.photoshop.sharepanel"
"%ProgramFiles%\Adobe\Adobe Photoshop %ps_ver%\Required\UXP\com.adobe.unifiedpanel\assets"
"%ProgramFiles%\Common Files\Adobe\HelpCfg"
"%ProgramFiles(x86)%\Adobe"
"%SystemDrive%\Users\Public\Documents\Adobe"
) do (
	rd /s /q %%G >nul 2>&1
)


for /d %%G in ("%CommonProgramFiles%\Adobe\CEP\extensions\CC_LIBRARIES*") do (rd /s /q "%%G")
for /d %%G in ("%CommonProgramFiles%\Adobe\UXP\extensions\com.adobe.ccx.start-*") do (rd /s /q "%%G")


pushd "%ProgramFiles%\Adobe\Adobe Photoshop %ps_ver%\Required\CEP\CEPHtmlEngine\locales" >nul 2>&1
for %%G in (*.pak) do (if not "%%~G"=="en-US.pak" (del /f /s /q "%%~G" >nul 2>&1))
for %%G in (*.info) do (if not "%%~G"=="en-US.pak.info" (del /f /s /q "%%~G" >nul 2>&1))
popd >nul 2>&1

if exist "%ps_dir%\Required\Sky_Presets" (

	curl -L -o %temp%\Sky_Presets.zip https://raw.githubusercontent.com/exncode/EXN-PHOTOFiT-Photoshop-Tools/refs/heads/main/files/Sky_Presets/Sky_Presets.zip >nul 2>&1 & tar -xf %temp%\Sky_Presets.zip -C "%ps_dir%\Required\Sky_Presets" >nul 2>&1

)

echo [5A
call :ok
pause >nul
goto menu

:ps_op3
cls
call :ps_top
echo %bbe%   ─   %fbe%  Firewall - Block Photoshop%rst%
%bsm%
call :yn
set /p ps_op3_c=── 
if %ps_op3_c%==2 goto menu
if %ps_op3_c%==1 goto ps_op3_go

:ps_op3_go
echo [6A
call :act
for %%G in (in out) do (

	netsh advfirewall firewall add rule name="Photoshop.exe" dir=%%G program="%ps_dir%\Photoshop.exe" action=block enable=yes >nul 2>&1

)
echo [5A
call :ok
pause >nul
goto menu


:ps_op4
start https://github.com/exncode/EXN-PHOTOFiT-Photoshop-Tools & goto menu


:ps_op5
exit


:ps_top
%bbg%
echo %bbe%   EXN                                            %rst%
echo %bbe%   █▀█ █ █ █▀█ ▀█▀ █▀█ █▀▀ ▀ ▀█▀                  %rst%
echo %bbe%   █▀▀ █▀█ █▄█  █  █▄█ █▀  █  █                   %rst%
echo %bbe%   10kb - Fast, small and easy.                   %rst%
echo %bbe%                                                  %rst%
echo %bbe%       %rst%
goto:eof


:yn
echo %bbe%   1   %bgn%  Start    %rst%
echo %bbe%   2     Go back  %rst%
echo:
goto:eof


:act
%bsm%
%bsm%  Working, wait...
%bsm%                  
echo:
goto:eof


:ok
%gsm%
echo %bgn%  Done [m%fgn%  Press any key to go back.
%gsm%                                           
goto:eof


:er
title Something went wrong.
echo [41m[97m              Something went wrong^^!^^!              %rst%
echo:
goto:eof


:error_old
call :er
echo %frd% You are using an very old version of Photoshop.%rst%
echo  Press any key to exit.
pause >nul
exit

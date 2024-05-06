@echo off

set exitBeforeApplyingPatches=false

setlocal enabledelayedexpansion
set working_dir=%~dp0
set patch_file=patch.txt
set output_dir=app
set patch_dir=patch

:: find apk file 
for %%F in (%cd%\*.apk) do (
 set apk_file_path=%%F
 set apk_file_name=%%~nF
 echo. Found %%~nxF
 goto label_validate_signature
)
echo. *.apk file not found

goto :EOF


:: validate signature of apk file
:label_validate_signature
echo. Validating signature...
for /f %%F in ('"%working_dir%bin\md5 -n !apk_file_path!"') do (
set apk_hash=%%F
)
if "!apk_hash!"=="CCA75A823CE69193E52E8E031742BAE3" (
goto label_decomile_apk
) 
echo. invalid apk file. 
echo. Required apk with MD5: CCA75A823CE69193E52E8E031742BAE3 
pause
goto :EOF


:label_decomile_apk
echo. Decompiling APK...
if "%exitBeforeApplyingPatches%"=="true" goto label_skipCheck_1
if exist "%working_dir%..\%output_dir%" (
echo. apk file seems to be already decompiled
echo. remove "%working_dir%..\%output_dir%" to continue
pause
goto :EOF
)
:label_skipCheck_1
if exist "%working_dir%%output_dir%" (
echo. apk file seems to be already decompiled
echo. remove "%working_dir%%output_dir%" to continue
pause
goto :EOF
)
call "%working_dir%bin\apktool" d -s "!apk_file_path!" -o "%output_dir%">nul
call :label_check_error
goto label_decompile_dex
goto :EOF


:label_decompile_dex
echo. Decompiling DEX...
pushd "%working_dir%%output_dir%"
FOR /F "tokens=*" %%G IN ('dir /b *.dex') DO (
call "%working_dir%bin\dex-tools\d2j-dex2jar" -d -o "%%~nG.jar" "%%G"
)
popd
call :label_check_error
goto label_decompile_jar
goto :EOF

:label_decompile_jar
pushd "%working_dir%%output_dir%"
call "%working_dir%bin\procyon" -fsb -ec -ss -jar "classes.jar" -o "%working_dir%%output_dir%\java"
popd
goto :label_shrink_sources
goto :EOF


:label_shrink_sources
pushd "%working_dir%%output_dir%\java"
for /r %%I in (*) do (
set temp_file_name=%%~nI
set temp_file_path="%%I"
call :label_delete_src_if_matches
)
popd
call :label_check_error
goto label_shrink_resources
goto :EOF


:label_shrink_resources
echo. Removing Extra Resources...
pushd "%working_dir%%output_dir%\res"
for /r %%I in (*) do (
set temp_file_name=%%~nI
set temp_file_path="%%I"
call :label_delete_res_if_matches
)
popd
call :label_check_error
goto label_remove_translations
goto :EOF


:label_remove_translations
echo. Removing Lang Resources...
pushd "%working_dir%%output_dir%\res"
for /d /r %%i in (values-*) do rmdir /s /q "%%i" 
popd
call :label_check_error
goto label_remove_empty_dirs
goto :EOF


:label_remove_empty_dirs
echo. Removing Empty Folders...
pushd "%working_dir%%output_dir%"
rem Remove all empty directories
rem https://superuser.com/questions/39674/recursively-delete-empty-directories-in-windows
robocopy "%cd%" "%cd%" /S /MOVE >nul
popd
call :label_check_error

goto label_cleanup_files
goto :EOF


:label_cleanup_files
echo. Rearraging Files...
pushd "%working_dir%%output_dir%"
rmdir /s /q original
REM rmdir /s /q java\android
REM rmdir /s /q java\androidx
REM rmdir /s /q java\com\google
del classes.dex >nul
del classes.jar >nul
del apktool.yml >nul
mkdir src
mkdir src\main>nul
move java src\main\>nul
move res src\main\>nul
move AndroidManifest.xml src\main\>nul
popd
call :label_check_error
goto label_apply_patch
goto :EOF

:label_apply_patch
echo. Applying Patches...
if "%exitBeforeApplyingPatches%"=="true" (
goto :EOF
)
pushd "%working_dir%%output_dir%"
"%working_dir%bin\patch" -p1 -i "%working_dir%%patch_dir%\%patch_file%"
popd
call :label_check_error
goto label_add_custom_sources
goto :EOF

:label_add_custom_sources
echo. Adding Custom Source Files...
robocopy "%working_dir%%patch_dir%\src" "%working_dir%%output_dir%\src" /s > nul
copy "%working_dir%%patch_dir%\build.gradle.kts" "%working_dir%%output_dir%" > nul
copy "%working_dir%%patch_dir%\proguard-rules.pro" "%working_dir%%output_dir%" > nul
copy "%working_dir%%patch_dir%\.gitignore" "%working_dir%%output_dir%" > nul
copy "%working_dir%%patch_dir%\checksums.sha256" "%working_dir%%output_dir%" > nul
call :label_check_error
goto label_move_project_files
goto :EOF


:label_move_project_files
echo. Moving Project Files...
pushd ..
move "%working_dir%%output_dir%" "%cd%" > nul
popd
goto label_end_of_file
goto :EOF

:label_end_of_file
:: END OF FILE
echo. Finished! 
echo. Now you can import project to IDE
echo. Window may be safely closed
echo.
echo. =)
pause
goto :EOF


:: FUNCTIONS

:label_delete_res_if_matches
if "!temp_file_name!"=="public" (
del !temp_file_path!
goto :EOF
)

goto :EOF

:label_delete_src_if_matches
if "!temp_file_name!"=="BaseConfigChooser" (
del !temp_file_path!
goto :EOF
)
if "!temp_file_name!"=="DefaultContextFactory" (
del !temp_file_path!
goto :EOF
)
if "!temp_file_name!"=="DefaultWindowSurfaceFactory" (
del !temp_file_path!
goto :EOF
)
if "!temp_file_name:~0,3!"=="EGL" (
del !temp_file_path!
goto :EOF
)
if "!temp_file_name:~0,3!"=="Egl" (
del !temp_file_path!
goto :EOF
)
if "!temp_file_name:~0,2!"=="GL" (
del !temp_file_path!
goto :EOF
)
if "!temp_file_name!"=="LogWriter" (
del !temp_file_path!
goto :EOF
)
if "!temp_file_name!"=="MasterResetReceiver" (
del !temp_file_path!
goto :EOF
)
if "!temp_file_name!"=="R" (
del !temp_file_path!
goto :EOF
)
if "!temp_file_name!"=="ThemeChangeReceiver" (
del !temp_file_path!
goto :EOF
)
if "!temp_file_name!"=="Config" (
del !temp_file_path!
goto :EOF
)
if "!temp_file_name!"=="Customization" (
del !temp_file_path!
goto :EOF
)
if "!temp_file_name!"=="ColorPicker" (
del !temp_file_path!
goto :EOF
)
if "!temp_file_name!"=="Settings" (
del !temp_file_path!
goto :EOF
)

goto :EOF

:label_decompile_class
call "%working_dir%bin\procyon" -fsb -ec !temp_file_path! -o "%working_dir%%output_dir%\java"
goto :EOF


:label_check_error
IF ERRORLEVEL 1 (
echo. 
echo. -------------------------
echo.
echo. An error ocurred : %errorlevel%
echo. Press enter to continue ^(unperdicatable results^)
echo. Or close the window
echo.
echo. =^(
echo.
echo. -------------------------
echo. 
pause>nul
)
goto :EOF
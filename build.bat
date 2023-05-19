
@echo OFF
setlocal 

setlocal 

if exist ".\dot.env" (
    echo Building with dot.env config: && (
       FOR /F "usebackq tokens=1* delims==" %%A in (".\dot.env") do (
        echo %%A=%%B && SET "%%A=%%B"
    )   
)
    
) else (
    echo 'Set dot.env file' && copy /y template.env dot.env && exit 1
)


if exist "%GOTHIC_VDFS_PATH%" (
    call "%GOTHIC_VDFS_PATH%" -B .\vdfs.vm && for %%A in ("%SEMICOLON_SEPARATED_EXTRA_OUTPUT_PATHS:;=";"%") do (
        if exist "%%~A" ( 
            echo COPYING TO %%~A
            copy /y .\build\*.vdf "%%~A" 
        )
    )
) else (
    echo Invalid Gothic VDFS tool path %GOTHIC_VDFS_PATH% && exit 1
)
endlocal
@echo off
setlocal EnableExtensions

set "UAT=G:\UE_Source\Engine\Build\BatchFiles\RunUAT.bat"
set "ProjectPath=G:\UE_Source\Samples\Games\Titan\Titan.uproject"
set "BuildPath=G:\UE_Source\Samples\Games\Titan\Saved\StagedBuilds\Windows"

set "TestName=AutomatedPerfTest.SequenceTest"
set "MapSequenceName=LevelStreaming"
set "Iterations=1"
set "PauseWhenFinished=1"

REM In-game console commands passed through -ExecCmds.
set "CmdArgs="
set "CmdArgs=%CmdArgs%Scalability 3"
set "CmdArgs=%CmdArgs%,r.setRes 1920x1080f"
set "CmdArgs=%CmdArgs%,r.ScreenPercentage 70"
set "CmdArgs=%CmdArgs%,r.VSync 0"
set "CmdArgs=%CmdArgs%,Stat UnitGraph"

set "PerfArgs="
set "PerfArgs=%PerfArgs% -AutomatedPerfTest.SequencePerfTest.MapSequenceName=%MapSequenceName%"
set "PerfArgs=%PerfArgs% -AutomatedPerfTest.GenerateLocalReports"
::set "PerfArgs=%PerfArgs% -AutomatedPerfTest.DoInsightsTrace"
::set "PerfArgs=%PerfArgs% -AutomatedPerfTest.TraceChannels=default,task"
::set "PerfArgs=%PerfArgs% -AutomatedPerfTest.DoVideoCapture"
set "PerfArgs=%PerfArgs% -AutomatedPerfTest.DoCSVProfiler"
set "PerfArgs=%PerfArgs% -AutomatedPerfTest.DoPerf"
set "PerfArgs=%PerfArgs% -AutomatedPerfTest.IgnoreTestBuildLogging"
set "PerfArgs=%PerfArgs% -iterations=%Iterations%"


set "ClientArgs="

if not exist "%UAT%" (
    echo [ERROR] RunUAT.bat was not found: "%UAT%"
    set "ExitCode=1"
    goto :Finish
)

if not exist "%ProjectPath%" (
    echo [ERROR] Project file was not found: "%ProjectPath%"
    set "ExitCode=1"
    goto :Finish
)

if not exist "%BuildPath%" (
    echo [ERROR] Staged build directory was not found: "%BuildPath%"
    set "ExitCode=1"
    goto :Finish
)

call "%UAT%" ^
    -nop4 ^
    -uselocalbuildstorage ^
    -NoCompile ^
    RunUnreal ^
    -project="%ProjectPath%" ^
    -test="%TestName%" ^
    -build="%BuildPath%" ^
    -unattended ^
    -verbose ^
    -ResumeOnCriticalFailure ^
    %PerfArgs% ^
    -ExecCmds="%CmdArgs%" ^
    -ClientArgs="%ClientArgs%"

set "ExitCode=%ERRORLEVEL%"

echo.
if "%ExitCode%"=="0" (
    echo Perf test completed successfully.
) else (
    echo [ERROR] Perf test failed with exit code %ExitCode%.
)

:Finish
if "%PauseWhenFinished%"=="1" pause

endlocal & exit /b %ExitCode%

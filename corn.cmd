@echo off

:: 后台cmd任务 [依赖 wind vb]
:: 结束任务后,需要手动杀死后台运行的 cmd 命令行 进程

set script="../work/artisan"

if "%1"=="hide" goto DaemonCmdApp
    start mshta vbscript:createobject("wscript.shell").run("""%~0"" hide",0)(window.close)&&exit
:DaemonCmdApp
    start /b php %script%  run:daemon --start=corn@corn
    start /b php %script%  run:daemon --start=fes_join_person@join_app
    set script=""
@echo on

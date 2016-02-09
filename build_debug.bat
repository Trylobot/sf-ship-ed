del /F sf-ship-ed.debug.exe
set "BMK_LD_OPTS=-lmsvcrt -lgcc"
bmk makeapp -a -o sf-ship-ed.debug.exe sf-ship-ed.bmx
pause

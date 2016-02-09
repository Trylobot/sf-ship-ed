del /F sf-ship-ed.exe
set "BMK_LD_OPTS=-lmsvcrt -lgcc"
bmk makeapp -a -r -t gui -o sf-ship-ed.exe sf-ship-ed.bmx
upx sf-ship-ed.exe
pause

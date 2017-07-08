del /F json_test.debug.exe
set "BMK_LD_OPTS=-lmsvcrt -lgcc"
bmk makeapp -a -o json_test.debug.exe json_test.bmx
pause

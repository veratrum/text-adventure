:: create game.zip containing all relevant files using 7zip
bin\7zip\7z.exe a game.zip .\src\engine\* .\src\*.lua font\*.ttf img\*.png

:: concatenate lovec.exe and game.zip
copy /b .\bin\love2d\lovec.exe+game.zip gamec.exe

del game.zip

start gamec.exe
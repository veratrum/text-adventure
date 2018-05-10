:: create game.zip containing all relevant files using 7zip
bin\7zip\7z.exe a game.zip .\src\engine\* .\src\*.lua font\*.ttf img\*.png

:: concatenate love.exe and game.zip
copy /b .\bin\love2d\love.exe+game.zip game.exe

del game.zip

start game.exe
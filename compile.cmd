nim c -d:cmdlet=clojure -d:release --opt:size -o:clojure.exe clojure.nim
@if ERRORLEVEL 1 GOTO error
nim c -d:cmdlet=clj -d:release --opt:size -o:clj.exe clojure.nim
@if ERRORLEVEL 1 GOTO error

@rd /S /Q release
@md release
7z a release\clojure-win-cli-wrap.zip clojure.exe clj.exe

@GOTO:EOF
:error
@ECHO ******** STOP ON ERROR *********

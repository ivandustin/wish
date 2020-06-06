@echo off
rem echo %username% > C:\helloworld.txt
sc create HelloWorldApp binpath= C:\Windows\System32\cmd.exe

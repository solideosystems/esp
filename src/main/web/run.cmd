@echo off

netstat -an | findstr /RC:":8088 .*LISTENING" && echo already running... && timeout 2 && EXIT 1

start /b quasar d

EXIT 1

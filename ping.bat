ping -t 127.0.0.1|cmd /q /v /c "(pause&pause)>nul & for /l %%a in () do (set /p "data=" && echo(!date! !time! !data!)&ping -n 2 127.0.0.1>nul" >>C:\testy\test.txt

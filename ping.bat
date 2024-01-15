ping -t 127.0.0.1|cmd /q /v /c "(pause&pause)>nul & for /l %%a in () do (set /p "data=" && echo(!date! !time! !data!)&ping -n 2 81.15.175.134>nul" >>C:\testy\test.txt

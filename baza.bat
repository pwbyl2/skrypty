@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

for /f "skip=1" %%x in ('wmic os get localdatetime') do if not defined MyDate set MyDate=%%x
set data=%MyDate:~0,4%-%MyDate:~4,2%-%MyDate:~6,2%

for /f "delims== tokens=1,2" %%G in (settings.txt) do set %%G=%%H

set /p pass="Podaj haslo: "
mkdir baza

:loop
echo Firma %loopcount% !name%loopcount%!
echo Firma %loopcount% !name%loopcount%! !ip%loopcount%! !port%loopcount%! >> "baza\baza_%data%.txt"
echo. yes | plink -ssh !ip%loopcount%! -P !port%loopcount%! -l root -pw %pass% (rm count_komis.sql; wget http://pwbyl2/count_komis.sql --no-check-certificate;chmod 777 count_komis.sql) >> "baza\baza_%data%.txt"
echo. yes | plink -ssh !ip%loopcount%! -P !port%loopcount%! -l root -pw %pass% (psql -U postgres -d pgpb -q -f count_komis.sql) >> "baza\baza_%data%.txt"
echo. yes | plink -ssh !ip%loopcount%! -P !port%loopcount%! -l root -pw %pass% (echo "=====================================================================") >> "baza\baza_%data%.txt"
echo. >> "baza\baza_%data%.txt"
set /a loopcount=loopcount-1
if %loopcount%==0 goto exitloop
goto loop
:exitloop

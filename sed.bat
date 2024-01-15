@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

for /f "skip=1" %%x in ('wmic os get localdatetime') do if not defined MyDate set MyDate=%%x
set data=%MyDate:~0,4%-%MyDate:~4,2%-%MyDate:~6,2%

for /f "delims== tokens=1,2" %%G in (settings2.txt) do set %%G=%%H

set /p pass="Podaj haslo: "
mkdir pobieraczka

:loop
echo Firma %loopcount% !name%loopcount%!
echo Firma %loopcount% !name%loopcount%! !ip%loopcount%! !port%loopcount%! >> "pobieraczka\pobieraczka_%data%.txt"
echo. yes | plink -ssh !ip%loopcount%! -P !port%loopcount%! -l root -pw %pass% (cp /home/samba/Pobieraczka/Pobieraczka.sh /home/samba/Pobieraczka/prefiks.sh; chmod 777 /home/samba/Pobieraczka/prefiks.sh;cp /home/samba/Pobieraczka/konfiguracja.xml /home/samba/Pobieraczka/prefiks.xml;) >> "pobieraczka\pobieraczka_%data%.txt"
echo. yes | plink -ssh !ip%loopcount%! -P !port%loopcount%! -l root -pw %pass% (sed -i 's/konfiguracja/prefiks/g' /home/samba/Pobieraczka/prefiks.sh; "sed -i 's#.*<Prefiksy>.*#  <Prefiksy>tutaj|wpisz|prefiks</Prefiksy>#' /home/samba/Pobieraczka/prefiks.xml"; "sed -i 's|.*<WszystkiePrefiksy>.*|  <WszystkiePrefiksy>false</WszystkiePrefiksy>|' /home/samba/Pobieraczka/prefiks.xml") >> "pobieraczka\pobieraczka_%data%.txt"
echo. >> "pobieraczka\pobieraczka_%data%.txt"
set /a loopcount=loopcount-1
if %loopcount%==0 goto exitloop
goto loop
:exitloop

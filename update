#!/bin/bash

pass="$1"

# Record the start time
start_time=$(date +"%Y-%m-%d %H:%M:%S")

current_dir=$(dirname "$(realpath "$0")")
cd $(dirname "$(realpath "$0")")
find "$current_dir" -mindepth 1 ! \( -name 'wdrupdate.sh2' -o -name 'wdrupdate.sh' -o -name 'wdrupdate_bez_dmp.sh2' \) -delete


log_file="script.log"

# Redirect all output to the log file
exec > >(tee -a "$log_file") 2>&1



wget -P "$current_dir" http://pwbyl2/update/update.zip

# Check if the download was successful
if [ $? -eq 0 ]; then
	echo ""
    echo "Download completed successfully."
	echo ""
    unzip update.zip
else
	echo ""
    echo "Download failed."
	exit 1
fi


psql -U postgres -d pgpb -q -f /root/killusers.sql


echo ""
echo "Doing backup"
echo ""
/home/postgres/pg_backup.sh -backdir:/home/postgres/BackupBazy -upg:postgres



back_dir="/home/postgres"

# Find the last .log file
last_log=$(find "$back_dir" -name "*.log" -type f -printf "%T@ %p\n" | sort -nr | head -n 1 | cut -d' ' -f2-)

cp "$last_log" "$current_dir"

# Check if the last log file ends with "OK - Backup zakończony"
if [[ -f "$last_log" ]] && grep -q "OK - Backup zakończony" "$last_log"; then
    echo ""
    echo "OK - Backup zakończony found in file"
    echo ""
else
    echo ""
    echo "'OK - Backup zakończony' not found in the log file, ending script"
    echo ""
    exit 1
fi




# Create the destination directory
mkdir /home/KOPIE
source_dir="/home/webservice/public_html"
destination_dir="/home/KOPIE"
date=$(date +"%Y-%m-%d_%H-%M-%S")
destination="$destination_dir/$date"
mkdir -p "$destination"

if find /root/wdrupdate -type f -name '*_ProfiBiznesWS*' -print -quit | grep -q .; then
	echo ""
    echo "run ProfiBiznesWS"
	echo ""
	echo "stop apache"
	echo ""
systemctl stop apache2.service
mkdir "$(basename -s .zip *ProfiBiznesWS.zip)" && unzip *ProfiBiznesWS.zip -d "$(basename -s .zip *ProfiBiznesWS.zip)"
cp -R "$source_dir/MotoWS" "$destination"
cp -R "$source_dir/MotoWS_ZEW" "$destination"
cp -R "$(basename -s .zip *ProfiBiznesWS.zip)"/* "$source_dir/MotoWS"
cp -R "$(basename -s .zip *ProfiBiznesWS.zip)"/* "$source_dir/MotoWS_ZEW"
cp "$current_dir/changelog.txt" "$source_dir/MotoWS/"
cp "$current_dir/changelog.txt" "$source_dir/MotoWS_ZEW/"
systemctl start apache2.service
echo ""
echo "start apache"
	if systemctl is-active apache2.service; then
		echo ""
		echo "Apache running"
		else 
		echo "Apache not running"
		echo ""
	fi	
else
	echo ""
    echo "no ProfiBiznesWS"
	echo ""
fi



if find /root/wdrupdate -type f -name '*_ProfiBiznesSerwis*' -print -quit | grep -q .; then
	echo ""
    echo "run ProfiBiznesSerwis"
	echo ""
mkdir "$(basename -s .zip *ProfiBiznesSerwis.zip)" && unzip *ProfiBiznesSerwis.zip -d "$(basename -s .zip *ProfiBiznesSerwis.zip)"
cp -R /home/postgres/PBSerwis "$destination"
cp -R "$(basename -s .zip *ProfiBiznesSerwis.zip)"/* /home/postgres/PBSerwis
else
	echo ""
    echo "no ProfiBiznesSerwis"
	echo ""
fi



if find /root/wdrupdate -type f -name '*_Pobieraczka*' -print -quit | grep -q .; then
	echo ""
    echo "run Pobieraczka"
	echo ""
mkdir "$(basename -s .zip *Pobieraczka.zip)" && unzip *Pobieraczka.zip -d "$(basename -s .zip *Pobieraczka.zip)"
cp -R /home/samba/Pobieraczka "$destination"
cp -R "$(basename -s .zip *Pobieraczka.zip)"/"$(basename -s .zip *Pobieraczka.zip)"/PobieranieArtykulow/* /home/samba/Pobieraczka
else
	echo ""
    echo "no Pobieraczka"
	echo ""
fi


if find /root/wdrupdate -type f -name '*_Terminale*' -print -quit | grep -q .; then
	echo ""
    echo "run Terminale"
	echo ""
mkdir -p /home/samba/Terminale/
mkdir "$(basename -s .zip *Terminale.zip)" && unzip *Terminale.zip -d "$(basename -s .zip *Terminale.zip)"
cp -R  "$(ls -td /home/samba/Terminale/*/ | head -1)" "$destination"
cp -R "$(basename -s .zip *Terminale.zip)"/"$(basename -s .zip *Terminale.zip)"/ /home/samba/Terminale/"$(basename *_Terminale "_Terminale")"

psql -U postgres pgpb -c "update mbiz.terminal_wersje set zaktualizowano = 'T';"
psql -U postgres pgpb -c "INSERT INTO mbiz.terminal_wersje VALUES ((SELECT COALESCE(MAX(wersja_id), 0) + 1 FROM mbiz.terminal_wersje),'Skanowanie.exe','"$(ls -td /home/samba/Terminale/*/ | head -1 | sed 's/[^0-9]//g')"','"$(ls -td /home/samba/Terminale/* | head -1)"',(SELECT CURRENT_TIMESTAMP),'N');"
else
	echo ""
    echo "no Terminale"
	echo ""
fi



if find /root/wdrupdate -type f -name '*_BazaSkrypty*' -print -quit | grep -q .; then
	echo ""
    echo "run BazaSkrypty"
	echo ""
mkdir "$(basename -s .zip *BazaSkrypty.zip)" && unzip *BazaSkrypty.zip -d "$(basename -s .zip *BazaSkrypty.zip)"
chmod +x -R "$(basename -s .zip *BazaSkrypty.zip)"
update_file=$(find "$(basename -s .zip *BazaSkrypty.zip)" -type f -name "*.sh" -printf "%f\n")
"$(basename -s .zip *BazaSkrypty.zip)"/"$update_file" -p:"$pass" </dev/null
psql -U postgres pgpb -c "select * from mbiz.v\$versions order by data_modyfikacji desc limit 1;"
else
	echo ""
    echo "no BazaSkrypty"
	echo ""
fi



# Record the end time
end_time=$(date +"%Y-%m-%d %H:%M:%S")
# Calculate the total runtime
start_seconds=$(date -d "$start_time" +%s)
end_seconds=$(date -d "$end_time" +%s)
total_seconds=$((end_seconds - start_seconds))

# Format the total runtime
hours=$((total_seconds / 3600))
minutes=$(( (total_seconds % 3600) / 60 ))
seconds=$((total_seconds % 60))
total_runtime=$(printf "%02d:%02d:%02d" "$hours" "$minutes" "$seconds")

# Print the start time, end time, and total runtime
echo ""
echo "Start time: $start_time"
echo "End time: $end_time"
echo "Total runtime: $total_runtime"
echo ""


source_file="$current_dir"/"$log_file"
last_folder=$(find "$destination_dir" -maxdepth 1 -type d -printf '%T@ %p\n' | sort -n | tail -n 1 | cut -f2- -d' ')

# Check if a valid folder was found
if [ -n "$last_folder" ]; then
    # Copy the source file to the last created folder
    cp "$source_file" "$last_folder"
    echo "Copied $log_file"
else
    echo "No folders found in $destination_dir"
fi

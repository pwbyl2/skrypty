#!/bin/bash

current_dir="/root/komis"
timestamp=$(date +"%Y%m%d_%H%M%S")
output_filename="komis_${timestamp}.txt"
psql -U postgres -d pgpb -f "${current_dir}/komis_stany.sql" > "${current_dir}/${output_filename}" 2>&1

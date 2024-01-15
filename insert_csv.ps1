# Set the input and output files.
$input_file = "input.csv"
$output_file = "output.txt"

# Set the name of the table you want to insert into.
$table_name = "mbiz.artykul_kodkreskowy"

# Loop through the lines of the CSV file and generate the INSERT statements.
Import-Csv $input_file -Delimiter ";" | ForEach-Object {
  # Generate the column names for the INSERT statement.
  $columns = $_.PSObject.Properties.Name -join ","

  # Generate the values for the INSERT statement.
  $values = $_.PSObject.Properties.Value -join "','"
  $values = "'$values'"

  # Write the INSERT statement to the output file.
  "INSERT INTO $table_name ($columns) VALUES ($values);" | Add-Content $output_file
}

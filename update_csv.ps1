# Set the input and output files.
$input_file = "input.csv"
$output_file = "output.txt"

# Set the name of the table you want to update.
$table_name = "kontrahent"

# Set the name of the primary key or unique key column.
$primary_key = "zwrot_tymcz"

# Loop through the lines of the CSV file and generate the UPDATE statements.
Import-Csv $input_file -Delimiter ";" | ForEach-Object {
  # Get the value of the primary key column.
  $primary_key_value = $_.$primary_key

  # Generate the SET clause of the UPDATE statement.
  $set_clause = ""
  foreach ($column in $_.PSObject.Properties) {
    if ($column.Name -ne $primary_key) {
      $set_clause += "$($column.Name)='$($column.Value)',"
    }
  }
  $set_clause = $set_clause.TrimEnd(",")

  # Generate the WHERE clause of the UPDATE statement.
  $where_clause = "$primary_key='$primary_key_value'"

  # Write the UPDATE statement to the output file.
  "UPDATE $table_name SET $set_clause WHERE $where_clause;" | Add-Content $output_file

}

#!/bin/bash

local prisma_file=${PWD}/schema.prisma
local output_file=${PWD}/database.csv
declare -a model_names=()  # Array to hold all model and type names
model_names=("$(awk '/^(model|type)/ {print $2}' "$prisma_file")")

# Generate CSV
awk -v models="${model_names[*]}" '
BEGIN {
  split(models, model_array);
  print "Model,Field,Type";
}
{
  if ($1 == "model") in_model = 1;
  else if ($1 == "}" && in_model) in_model = 0;
  else if (in_model && $1 ~ /^[a-zA-Z]/) {
    field_name = $1;
    field_type = $2;
    print model_name "," field_name "," field_type;
  }
  if (in_model && $1 == "model") model_name = $2;
}
' "$prisma_file" > "$output_file"

echo "CSV schema exported to $output_file"

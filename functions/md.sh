#!/bin/bash

local prisma_file=${PWD}/schema.prisma
local output_file=${PWD}/database.md
declare -a model_names=()  # Array to hold all model and type names
model_names=("$(awk '/^(model|type)/ {print $2}' "$prisma_file")")

# Generate Markdown
awk -v models="${model_names[*]}" '
BEGIN {
  split(models, model_array);
  print "# Prisma Schema Documentation\n";
}
{
  if ($1 == "model") {
    in_model = 1;
    model_name = $2;
    print "## Model: " model_name "\n";
    print "| Field | Type |";
    print "|-------|------|";
  } else if ($1 == "}" && in_model) {
    in_model = 0;
    print "\n";
  } else if (in_model && $1 ~ /^[a-zA-Z]/) {
    field_name = $1;
    field_type = $2;
    print "| " field_name " | " field_type " |";
  }
}
' "$prisma_file" > "$output_file"

echo "Markdown schema exported to $output_file"

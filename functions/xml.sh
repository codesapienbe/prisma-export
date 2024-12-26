#!/bin/bash

local prisma_file=${PWD}/schema.prisma
local output_file=${PWD}/database.xml
declare -a model_names=()  # Array to hold all model and type names
model_names=("$(awk '/^(model|type)/ {print $2}' "$prisma_file")")

# Generate XML
awk -v models="${model_names[*]}" '
BEGIN {
  split(models, model_array);
  print "<database>";
}
{
  if ($1 == "model") {
    in_model = 1;
    model_name = $2;
    print "  <model name=\"" model_name "\">";
  } else if ($1 == "}" && in_model) {
    in_model = 0;
    print "  </model>";
  } else if (in_model && $1 ~ /^[a-zA-Z]/) {
    field_name = $1;
    field_type = $2;
    print "    <field name=\"" field_name "\" type=\"" field_type "\" />";
  }
}
END {
  print "</database>";
}
' "$prisma_file" > "$output_file"

echo "XML schema exported to $output_file"

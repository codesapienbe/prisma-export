#!/bin/bash

local prisma_file=${PWD}/schema.prisma
local output_file=${PWD}/database.json
declare -a model_names=()  # Array to hold all model and type names
model_names=("$(awk '/^(model|type)/ {print $2}' "$prisma_file")")

# Generate JSON
awk -v models="${model_names[*]}" '
BEGIN {
  split(models, model_array);
  print "{";
}
{
  if ($1 == "model") {
    in_model = 1;
    model_name = $2;
    if (model_count++) print ",";
    print "  \"" model_name "\": {";
    print "    \"fields\": [";
  } else if ($1 == "}" && in_model) {
    in_model = 0;
    print "    ]";
    print "  }";
  } else if (in_model && $1 ~ /^[a-zA-Z]/) {
    field_name = $1;
    field_type = $2;
    if (field_count++) print ",";
    print "      { \"name\": \"" field_name "\", \"type\": \"" field_type "\" }";
  }
}
END {
  print "}";
}
' "$prisma_file" > "$output_file"

echo "JSON schema exported to $output_file"

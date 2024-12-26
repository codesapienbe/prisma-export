#!/bin/bash

prisma_file="${PWD}/schema.prisma"
output_file="${PWD}/database.mmd"

declare -a model_names=()
model_names=($(awk '/^(model|type)/ {print $2}' "$prisma_file"))

awk -v models="${model_names[*]}" '
BEGIN {
  split(models, model_array);
  print "erDiagram";
}
{
  if ($1 == "model") {
    in_model = 1;
    model_name = $2;
    print "  " model_name " {";
  } else if ($1 == "}" && in_model) {
    in_model = 0;
    print "  }";
  } else if (in_model && $1 ~ /^[a-zA-Z]/) {
    field_name = $1;
    field_type = $2;

    gsub(/\[\]/, "", field_type); # Remove array notation
    gsub(/\?/, "", field_type);  # Remove optional indicators

    is_relation = 0;
    relation_description = "belongs to";  # Default relationship description

    for (j in model_array) {
      if (field_type == model_array[j] && field_type != model_name) {
        is_relation = 1;
        break;
      }
    }

    if (is_relation) {
      relation = model_name " ||--o| " field_type " : \"" relation_description "\"";
      if (!(relation in relations)) {
        relations[relation] = 1;
      }
    } else {
      print "    " field_name " " field_type;
    }
  }
}
END {
  print "";
  for (relation in relations) {
    print relation;
  }
}
' "$prisma_file" > "$output_file"

echo "Mermaid diagram exported to $output_file"

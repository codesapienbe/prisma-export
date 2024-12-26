#!/bin/bash

mongo_export() {
  
    local prisma_file=${PWD}/schema.prisma
    local output_file=${PWD}/database.js
    declare -a model_names=()  # Array to hold all model and type names
    model_names=("$(awk '/^(model|type)/ {print $2}' "$prisma_file")")

    echo "Generating MongoDB schema from $prisma_file into $output_file..."

    awk -v models="${model_names[*]}" '
    BEGIN {
    split(models, model_array);  # Split the model names into an array
    print "// MongoDB schema generated from Prisma schema";
    }
    /^model/ {
    in_model = 1;
    model_name = $2;
    printf "\ndb.createCollection(\"%s\", {\n  validator: {\n    $jsonSchema: {\n      bsonType: \"object\",\n      required: [", model_name;
    required_fields = "";
    }
    /^}/ && in_model {
    in_model = 0;
    print required_fields "],\n      properties: {";
    for (i in properties) {
        # Skip FK fields if the corresponding object field exists
        if (i ~ /Id$/ && substr(i, 1, length(i) - 2) in properties) continue;
        print "        \"" i "\": " properties[i] ",";
    }
    print "      }\n    }\n  }\n});";
    delete properties;
    }
    in_model && $1 ~ /^[a-zA-Z]/ {
    field_name = $1;
    field_type = $2;

    # Add to required fields if the field is annotated with @id
    if ($0 ~ /@id/) {
        required_fields = required_fields (required_fields ? ", " : "") "\"" field_name "\"";
    }

    # Check if the field is a relation by matching model/type names
    is_relation = 0;
    for (j in model_array) {
        if (field_type == model_array[j]) {
        is_relation = 1;
        break;
        }
    }

    # Map Prisma types to MongoDB BSON types
    if (field_type ~ /String/) bson_type = "{ bsonType: \"string\" }";
    else if (field_type ~ /Int/) bson_type = "{ bsonType: \"int\" }";
    else if (field_type ~ /Float/) bson_type = "{ bsonType: \"double\" }";
    else if (field_type ~ /Boolean/) bson_type = "{ bsonType: \"bool\" }";
    else if (field_type ~ /DateTime/) bson_type = "{ bsonType: \"date\" }";
    else if (field_type ~ /Json/) bson_type = "{ bsonType: \"object\" }";
    else if (field_type ~ /\[\]/) {
        sub(/\[\]/, "", field_type); # Remove [] for array fields
        bson_type = "{ bsonType: \"array\", items: { bsonType: \"object\" } }";
    } else if (is_relation) {
        bson_type = "{ bsonType: \"object\" }"; # Reference to related model
    } else {
        bson_type = "{ bsonType: \"string\" }"; # Default fallback
    }

    # Handle @unique annotation
    if ($0 ~ /@unique/) bson_type = bson_type ", uniqueItems: true";

    properties[field_name] = bson_type;
    }
    ' "$prisma_file" > "$output_file"
    echo "MongoDB schema written to $output_file"

}

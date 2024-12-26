#!/bin/bash

mysql_export() {
    
    local prisma_file=${PWD}/schema.prisma
    local output_file=${PWD}/database.sql
    declare -a model_names=()  # Array to hold all model and type names
    model_names=("$(awk '/^(model|type)/ {print $2}' "$prisma_file")")

    echo "Generating SQL schema for $db_provider from $prisma_file into $output_file..."

    awk -v db_provider="$db_provider" -v models="${model_names[*]}" '
    BEGIN {
    split(models, model_array);  # Split the model names into an array
    print "-- SQL schema generated from Prisma schema";
    }
    /^model/ {
    in_model = 1;
    model_name = $2;
    printf "\nCREATE TABLE %s (\n", model_name;
    }
    /^}/ && in_model {
    in_model = 0;
    # Add timestamps based on db_provider
    if (db_provider == "mysql" || db_provider == "mariadb") {
        print "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,";
        print "  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,";
    } else if (db_provider == "postgres") {
        print "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,";
        print "  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,";
    } else if (db_provider == "sqlite") {
        print "  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,";
        print "  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,";
    }
    print primary_key;  # Add the primary key at the end
    print ");";
    primary_key = "";  # Reset primary key
    }
    in_model && $1 ~ /^[a-zA-Z]/ {
    field_name = $1;
    field_type = $2;

    # Check if the field is a relation by matching model/type names
    is_relation = 0;
    for (j in model_array) {
        if (field_type == model_array[j]) {
        is_relation = 1;
        break;
        }
    }

    # Map Prisma types to SQL types
    if (field_type ~ /String/) sql_type = "VARCHAR(255)";
    else if (field_type ~ /Int/) sql_type = "INTEGER";
    else if (field_type ~ /Float/) sql_type = "FLOAT";
    else if (field_type ~ /Boolean/) sql_type = "BOOLEAN";
    else if (field_type ~ /DateTime/) sql_type = "TIMESTAMP";
    else if (field_type ~ /Json/) sql_type = "JSON";
    else if (field_type ~ /\[\]/) {
        sub(/\[\]/, "", field_type); # Remove [] for array fields
        sql_type = "JSON";
    } else if (is_relation) {
        sql_type = "INTEGER"; # Foreign key for related model
    } else {
        sql_type = "TEXT"; # Default fallback
    }

    # Handle @id annotation for primary keys
    if ($0 ~ /@id/) {
        primary_key = "  PRIMARY KEY (" field_name "),";
        sql_type = "INTEGER AUTO_INCREMENT";  # Set primary key type
    }

    # Handle @unique annotation
    if ($0 ~ /@unique/) sql_type = sql_type " UNIQUE";

    # Avoid duplicate `id` definitions
    if (field_name != "id" || !primary_key) {
        print "  " field_name, sql_type ",";
    }
    }
    ' "$prisma_file" > "$output_file"
    echo "SQL schema written to $output_file"
}

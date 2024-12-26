#!/bin/bash

api_export() {
    
    local prisma_file=${PWD}/schema.prisma
    local output_file=${PWD}/database.api
    declare -a model_names=()  # Array to hold all model and type names
    model_names=("$(awk '/^(model|type)/ {print $2}' "$prisma_file")")

    echo "Generating OpenAPI JSON schema for basic CRUD operations into $output_file..."

    awk -v models="${model_names[*]}" '
    BEGIN {
    split(models, model_array);  # Split the model names into an array
    print "{";
    print "  \"openapi\": \"3.0.0\",";
    print "  \"info\": {";
    print "    \"title\": \"API Generated from Prisma Schema\",";
    print "    \"version\": \"1.0.0\"";
    print "  },";
    print "  \"paths\": {";
    first_path = 1;  # Track the first path entry
    }
    /^model/ {
    if (!first_path) print "    },";  # Close the previous path object with a comma
    first_path = 0;  # After the first path
    in_model = 1;
    model_name = $2;
    print "    \"/" model_name "\": {";
    print "      \"get\": {";
    print "        \"summary\": \"Retrieve a list of " model_name "\",";
    print "        \"responses\": {";
    print "          \"200\": {";
    print "            \"description\": \"A list of " model_name "\",";
    print "            \"content\": { \"application/json\": { \"schema\": { \"type\": \"array\", \"items\": { \"$ref\": \"#/components/schemas/" model_name "\" } } } }";
    print "          }";
    print "        }";
    print "      },";
    print "      \"post\": {";
    print "        \"summary\": \"Create a new " model_name "\",";
    print "        \"requestBody\": {";
    print "          \"content\": { \"application/json\": { \"schema\": { \"$ref\": \"#/components/schemas/" model_name "\" } } }";
    print "        },";
    print "        \"responses\": {";
    print "          \"201\": {";
    print "            \"description\": \"" model_name " created successfully\"";
    print "          }";
    print "        }";
    print "      }";
    print "    },";
    print "    \"/" model_name "/{id}\": {";
    print "      \"get\": {";
    print "        \"summary\": \"Retrieve a specific " model_name " by ID\",";
    print "        \"parameters\": [";
    print "          { \"name\": \"id\", \"in\": \"path\", \"required\": true, \"schema\": { \"type\": \"string\" } }";
    print "        ],";
    print "        \"responses\": {";
    print "          \"200\": {";
    print "            \"description\": \"The requested " model_name "\",";
    print "            \"content\": { \"application/json\": { \"schema\": { \"$ref\": \"#/components/schemas/" model_name "\" } } }";
    print "          }";
    print "        }";
    print "      },";
    print "      \"put\": {";
    print "        \"summary\": \"Update a specific " model_name " by ID\",";
    print "        \"parameters\": [";
    print "          { \"name\": \"id\", \"in\": \"path\", \"required\": true, \"schema\": { \"type\": \"string\" } }";
    print "        ],";
    print "        \"requestBody\": {";
    print "          \"content\": { \"application/json\": { \"schema\": { \"$ref\": \"#/components/schemas/" model_name "\" } } }";
    print "        },";
    print "        \"responses\": {";
    print "          \"200\": {";
    print "            \"description\": \"" model_name " updated successfully\"";
    print "          }";
    print "        }";
    print "      },";
    print "      \"delete\": {";
    print "        \"summary\": \"Delete a specific " model_name " by ID\",";
    print "        \"parameters\": [";
    print "          { \"name\": \"id\", \"in\": \"path\", \"required\": true, \"schema\": { \"type\": \"string\" } }";
    print "        ],";
    print "        \"responses\": {";
    print "          \"204\": {";
    print "            \"description\": \"" model_name " deleted successfully\"";
    print "          }";
    print "        }";
    print "      }"; # Close the path object without an extra curly bracket
    }
    END {
    if (in_model) print "    }";  # Ensure the last path closes correctly
    print "  },";
    print "  \"components\": {";
    print "    \"schemas\": {";
    for (i in model_array) {
        if (i > 1) print ",";
        print "      \"" model_array[i] "\": { \"type\": \"object\", \"properties\": {} }";
    }
    print "    }";
    print "  }";
    print "}";
    }
    ' "$prisma_file" > "$output_file"

    echo "OpenAPI JSON schema written to $output_file"
}

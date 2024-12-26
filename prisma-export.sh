#!/bin/bash

# Directory containing function scripts
FUNCTIONS_DIR="$(dirname "$0")/functions"

# Ensure a function script exists for the provided db_provider
function load_function_script() {
  local provider=$1
  local script_path="$FUNCTIONS_DIR/$provider.sh"

  if [[ -f "$script_path" ]]; then
    source "$script_path"
  else
    echo "Error: Unsupported database provider '$provider'."
    echo "Available providers are: $(ls "$FUNCTIONS_DIR" | sed 's/.sh//g' | tr '\n' ', ' | sed 's/, $//')"
    exit 1
  fi
}

# Main function
prisma_export() {
  local db_provider

  # Handle arguments
  if [[ $# -eq 1 ]]; then
    db_provider="$1"            # Assign the argument to db_provider
  else
    echo "Usage: prisma-export <db_provider>"
    echo "Example: prisma-export mongo"
    exit 1
  fi

  # Load the appropriate script for the db_provider
  load_function_script "$db_provider"

  # Call the function provided by the script
  "${db_provider}_export"
}

# Run the main function
prisma_export "$@"

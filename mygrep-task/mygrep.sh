#!/bin/bash

show_help() {
    echo "Usage: $0 [OPTIONS] PATTERN FILE"
    echo "Search for PATTERN in FILE (case-insensitive)"
    echo ""
    echo "Options:"
    echo "  -n         Show line numbers for each match"
    echo "  -v         Invert the match (print lines that do not match)"
    echo "  --help     Display this help message and exit"
}

# Initialize variables
show_line_numbers=false
invert_match=false

# Process options with getopts
while getopts ":nv-:" opt; do
    case $opt in
        n) show_line_numbers=true ;;
        v) invert_match=true ;;
        -)
            if [ "$OPTARG" = "help" ]; then
                show_help
                exit 0
            else
                echo "Error: Invalid option --$OPTARG" >&2
                show_help
                exit 1
            fi
            ;;
        \?) 
            echo "Error: Invalid option -$OPTARG" >&2
            show_help
            exit 1
            ;;
    esac
done

# Shift to non-option arguments
shift $((OPTIND-1))

# Check for required arguments
if [ $# -lt 2 ]; then
    # First check if there are exactly 0 arguments
    if [ $# -eq 0 ]; then
        echo "Error: Missing search pattern and filename" >&2
        show_help
        exit 1
    # Then check if it's just 1 argument
    elif [ $# -eq 1 ]; then
        # Check if the argument is a readable file - if so, likely missing pattern
        if [ -f "$1" ] && [ -r "$1" ]; then
            echo "Error: Missing search string" >&2
        else
            echo "Error: Missing filename" >&2
        fi
        show_help
        exit 1
    fi
fi

pattern="$1"
file="$2"

# Check if file exists and is readable
if [ ! -f "$file" ] || [ ! -r "$file" ]; then
    echo "Error: File '$file' does not exist or is not readable" >&2
    exit 1
fi

# Process the file and output results
line_number=0
while IFS= read -r line; do
    ((line_number++))
    
    if [[ "${line,,}" == *"${pattern,,}"* ]]; then
        [ "$invert_match" = true ] && continue
    else
        [ "$invert_match" = false ] && continue
    fi
    
    if [ "$show_line_numbers" = true ]; then
        echo "$line_number:$line"
    else
        echo "$line"
    fi
done < "$file"


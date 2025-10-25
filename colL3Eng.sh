#!/data/data/com.termux/files/usr/bin/bash

# ==============================================
# Script Version Information
# ==============================================
VERSION="1.0.0"

# ==============================================
# Display Help Information
# ==============================================
show_help() {
    echo "=========================================="
    echo "        🟡🟠 colL $VERSION 🟠🟡"
    echo "     Multi-language Compile and Run Tool (Lightweight)"
    echo "=========================================="
    echo ""
    echo "📋 Supported Languages:"
    echo "   Java, C, C++, Python, Shell, JavaScript,"
    echo "   PHP, Octave, Fortran, Rust, Kotlin"
    echo ""
    echo "🔍 Features:"
    echo "   • Supports Termux environment"
    echo "   • Recursive source file search"
    echo "   • Shows configuration seed on Ctrl+C exit"
    echo ""
    echo "🚀 Quick Start:"
    echo "   ./colL2.sh [configuration seed]"
    echo ""
    echo "⚙️  Configuration Seed Options:"
    echo "   f-<source file path>     Configure source file path"
    echo "   t-<build output path>    Configure build output path"
    echo "   op-<mapping>             Configure compiler-language mapping"
    echo ""
    echo "🎮 Usage:"
    echo "   <filename>               Run specified file"
    echo "   <filename> <compiler>    Run once with specified compiler"
    echo "   checkavails              Show compiler availability"
    echo "   -h, --help               Show help information"
    echo "   -v, --version            Show version information"
    echo ""
    echo "📝 Examples:"
    echo "   ./colL2.sh f-./sources t-./builds op-clang-c,g++-cpp"
    echo "   test.c"
    echo "   test.c gcc"
    echo "   checkavails"
    echo "   Ctrl+C (exit and show configuration seed)"
    echo ""
    echo "💡 Tip: You can also enter --help or --version in interactive mode"
    echo "=========================================="
}

# ==============================================
# Display Version Information
# ==============================================
show_version() {
    echo "=============================="
    echo "      colL Multi-language Compiler Tool"
    echo "         (Lightweight)"
    echo "           v$VERSION"
    echo "=============================="
}

# ==============================================
# Capture Ctrl+C signal, show current configuration seed on exit
# ==============================================
trap 'show_exit_seed; echo -e "\n🛑 Program terminated"; exit 0' SIGINT

# ==============================================
# Utility Function: Format directory path display
# ==============================================
format_path_for_display() {
    local path="$1"
    
    # Get the full path
    local full_path=$(realpath "$path" 2>/dev/null || echo "$path")
    
    # Handle root directory
    if [[ "$full_path" == "/" ]]; then
        echo "/"
        return
    fi
    
    # Remove trailing slash
    full_path=${full_path%/}
    
    # Count slashes to determine depth
    local slash_count=$(echo "$full_path" | tr -cd '/' | wc -c)
    
    if [[ $slash_count -le 2 ]]; then
        # Shallow path, show as is
        echo "$full_path"
    else
        # Deep path, extract last 3 components
        local basename=$(basename "$full_path")
        local parent_dir=$(basename "$(dirname "$full_path")")
        local grandparent_dir=$(basename "$(dirname "$(dirname "$full_path")")")
        echo ".../$grandparent_dir/$parent_dir/$basename"
    fi
}

# ==============================================
# Show Exit Seed Information
# ==============================================
show_exit_seed() {
    echo ""
    echo "=============================="
    echo "        📦 Configuration Seed"
    echo "You can use this command to quickly initialize next time:"
    
    # Collect current configuration opcodes
    local current_ops=()
    
    for lang in "${!language_config[@]}"; do
        local current_compiler=${lang_default_compiler[$lang]}
        current_ops+=("${current_compiler}-${lang}")
    done
    
    # Build seed command
    local seed_command="./colL2.sh"
    seed_command+=" f-${source_dir}"
    seed_command+=" t-${output_dir}"
    #seed_command+=" v-${vcd}"
    seed_command+=" op-$(IFS=,; echo "${current_ops[*]}")"
    
    echo "   $seed_command"
    echo "=============================="
}

# ==============================================
# Load Seed from Command Line Arguments
# ==============================================
load_seed_from_args() {
    local args=("$@")
    local script_dir=$(dirname "$0")
    local default_source="$script_dir"
    local default_output="$script_dir"
    #local default_vcd="$script_dir"
    
    # Initialize paths to default values
    source_dir=$default_source
    output_dir=$default_output
    #vcd=$default_vcd
    op_codes=""
    
    # Parse arguments
    for arg in "${args[@]}"; do
        if [[ $arg == "-h" || $arg == "--help" ]]; then
            show_help
            exit 0
        elif [[ $arg == "-v" || $arg == "--version" ]]; then
            show_version
            exit 0
        elif [[ $arg == f-* ]]; then
            source_dir="${arg#f-}"
            echo "📁 Source file path: $source_dir (supports recursive search)"
        elif [[ $arg == t-* ]]; then
            output_dir="${arg#t-}"
            echo "📂 Build output path: $output_dir"
        #elif [[ $arg == v-* ]]; then
         #   vcd="${arg#v-}"
          #  echo "Using command line specified virtual working directory: $vcd"
        elif [[ $arg == op-* ]]; then
            op_codes="${arg#op-}"
            echo "⚙️  Compiler mapping: $op_codes"
        else
            echo "⚠️  Unknown parameter: $arg (ignored)"
        fi
    done
}

# ==============================================
# Script Internal Record: Language-Compiler Mapping Table (Core Configuration)
# Structure: language name -> [default default compiler, [alternative compiler list...]]
# ==============================================
declare -A language_config=(
    ["c"]="clang:gcc,clang"
    ["cpp"]="g++:g++,clang++"
    ["java"]="javac:javac"
    ["python"]="python3:python3,pypy,pypy3"
    ["shell"]="bash:bash,sh"
    ["javascript"]="node:node"
    ["php"]="php:php"
    ["octave"]="octave:octave"
    ["fortran"]="gfortran:gfortran"
    ["rust"]="rustc:rustc"
    ["kotlin"]="kotlinc:kotlinc"
)

# State variables
declare -A lang_default_compiler  # User-set default compiler for each language
source_dir=""                     # Source file path
output_dir=""                     # Build output path
#vcd=""                            # Virtual working directory
default_vcd=""                    # Default virtual working directory
execute=true                      # Whether to execute after compilation
delete_after=true                 # Whether to delete output after running
declare -A extension_commands     # Extension command dictionary (reserved but not used)
declare -A extension_files        # Extension name to filename mapping (reserved but not used)

# ==============================================
# Utility Function: Parse Language Configuration
# ==============================================
get_default_default() {
    echo "${language_config[$1]%%:*}"
}

get_candidates() {
    echo "${language_config[$1]#*:}" | tr ',' ' '
}

# ==============================================
# Utility Function: Check if Command is Installed
# ==============================================
is_installed() {
    command -v "$1" &> /dev/null
}

# ==============================================
# Utility Function: Recursively Find File
# ==============================================
find_file_recursive() {
    local filename="$1"
    local search_dir="$2"
    
    # Find files in source directory and its subdirectories
    local found_files=()
    while IFS= read -r -d '' file; do
        found_files+=("$file")
    done < <(find "$search_dir" -name "$filename" -type f -print0 2>/dev/null)
    
    # If not found in current search directory, try to handle Android storage paths
    if [[ ${#found_files[@]} -eq 0 && "$search_dir" == .* ]]; then
        # Try to find in common Android storage locations
        local android_paths=(
            "/storage/emulated/0/"
            "/sdcard/"
            "$HOME/storage/shared/"
        )
        
        for android_path in "${android_paths[@]}"; do
            if [[ -d "$android_path" ]]; then
                while IFS= read -r -d '' file; do
                    found_files+=("$file")
                done < <(find "$android_path" -name "$filename" -type f -print0 2>/dev/null)
                if [[ ${#found_files[@]} -gt 0 ]]; then
                    break
                fi
            fi
        done
    fi
    
    # Return search results
    echo "${found_files[@]}"
}

# ==============================================
# Apply Compiler-Language Mapping (for automatic initialization)
# ==============================================
apply_compiler_language_pairs() {
    local ops=$1
    if [[ -z "$ops" ]]; then
        return 0
    fi
    
    local op_list=(${ops//,/ })  # Separate multiple mappings with commas
    
    for op in "${op_list[@]}"; do
        # Check for path configuration parameters
        if [[ $op == f-* ]]; then
            source_dir="${op#f-}"
            echo "📁 Source file path set: $source_dir"
        elif [[ $op == t-* ]]; then
            output_dir="${op#t-}"
            echo "📂 Build output path set: $output_dir"
        #elif [[ $op == v-* ]]; then
        #    vcd="${op#v-}"
        #    echo "Virtual working directory set: $vcd"
        # Handle compiler-language mappings
        elif [[ $op == *-* ]]; then
            # Parse compiler-language pair
            local compiler=$(echo "$op" | cut -d'-' -f1)
            local lang=$(echo "$op" | cut -d'-' -f2)
            
            # Verify if language is supported
            if [[ -z "${language_config[$lang]}" ]]; then
                echo "⚠️  Unsupported language '$lang' (ignored)"
                continue
            fi
            
            # Verify if compiler is in the candidate list for this language
            local candidates=$(get_candidates "$lang")
            if [[ ! " $candidates " =~ " $compiler " ]]; then
                echo "⚠️  Compiler '$compiler' is not supported for $lang language (ignored)"
                continue
            fi
            
            # Apply configuration
            lang_default_compiler[$lang]=$compiler
            echo "✅ ${lang} language compiler set to: $compiler"
            
            # Check if installation prompt is needed
            if ! is_installed "$compiler"; then
                echo "⚠️  Note: $compiler is not installed"
                case "$compiler" in
                    python3|pypy|pypy3) echo "   💡 Suggested installation: pkg install python" ;;
                    gcc|g++|clang|clang++) echo "   💡 Suggested installation: pkg install clang" ;;
                    javac) echo "   💡 Suggested installation: pkg install openjdk-17" ;;
                    node) echo "   💡 Suggested installation: pkg install nodejs" ;;
                    php) echo "   💡 Suggested installation: pkg install php" ;;
                    bash|sh) echo "   💡 Suggested installation: pkg install bash" ;;
                    gfortran) echo "   💡 Suggested installation: pkg install gcc-gfortran" ;;
                    rustc) echo "   💡 Suggested installation: pkg install rust" ;;
                    kotlinc) echo "   💡 Suggested installation: pkg install kotlin" ;;
                    octave) echo "   💡 Suggested installation: pkg install octave" ;;
                esac
            fi
        else
            echo "⚠️  Unknown configuration '$op' (ignored)"
        fi
    done
}

# ==============================================
# Initialize Configuration Process
# ==============================================
initialize() {
    # Get script directory as default path
    local script_dir=$(dirname "$0")
    
    # 1. Configure source file path
    local default_source="$script_dir"
    source_dir=${source_dir:-$default_source}
    
    # Handle relative paths
    if [[ "$source_dir" != /* && "$source_dir" != "." ]]; then
        source_dir="$default_source/$source_dir"
    fi
    
    if [[ ! -d "$source_dir" ]]; then
        echo "⚠️  Source file path does not exist, will use default path"
        source_dir=$default_source
    fi
    
    # 2. Configure build output path
    local default_output="$script_dir"
    output_dir=${output_dir:-$default_output}
    
    # Handle relative paths
    if [[ "$output_dir" != /* && "$output_dir" != "." ]]; then
        output_dir="$default_output/$output_dir"
    fi
    
    if [[ ! -d "$output_dir" ]]; then
        echo "⚠️  Build output path does not exist, will use default path"
        output_dir=$default_output
    fi
    
    # 3. Configure virtual working directory
    #local default_vcd="$script_dir"
    #vcd=${vcd:-$default_vcd}
    
    # Handle relative paths
   # if [[ "$vcd" != /* && "$vcd" != "." ]]; then
    #    vcd="$default_vcd/$vcd"
    # fi
    
    #if [[ ! -d "$vcd" ]]; then
    #    echo "Warning: Virtual working directory does not exist, will use default path"
    #    vcd=$default_vcd
    # fi
    
    # Store the default VCD for later use
    # default_vcd="$vcd"
    
    # 4. Apply default compiler configuration
    # First set all languages to default recommended
    for lang in "${!language_config[@]}"; do
        lang_default_compiler[$lang]=$(get_default_default "$lang")
    done
    
    # Apply compiler-language mapping
    if [[ -n "$op_codes" ]]; then
        echo -e "\n🔧 Applying compiler-language mapping configuration..."
        apply_compiler_language_pairs "$op_codes"
    fi
    
    echo -e "\n✅ Initialization complete!"
    
    # Show script location and source directory full paths
    local script_full_path=$(realpath "$0" 2>/dev/null || echo "$0")
    local source_full_path=$(realpath "$source_dir" 2>/dev/null || echo "$source_dir")
    echo "📄 Script location: $script_full_path"
    echo "📁 Source file directory: $source_full_path"
}

# ==============================================
# Compile and Execute Core Logic
# ==============================================
execute_file() {
    local full_path="$1"
    local custom_compiler="$2"  # Optional: User-specified compiler for one-time use
    local lang=""
    local compiler=""
    local filename=$(basename "$full_path")
    
    # 1. Check if file exists
    if [[ ! -f "$full_path" ]]; then
        echo "❌ Error: File '$full_path' does not exist"
        return 1
    fi
    
    # 2. Determine language based on extension
    case "$filename" in
        *.c) lang="c" ;;
        *.cpp|*.cxx|*.cc) lang="cpp" ;;
        *.java) lang="java" ;;
        *.py) lang="python" ;;
        *.sh) lang="shell" ;;
        *.js) lang="javascript" ;;
        *.php) lang="php" ;;
        *.m) lang="octave" ;;
        *.f|*.f90|*.f95|*.f03|*.f08) lang="fortran" ;;
        *.rs) lang="rust" ;;
        *.kt) lang="kotlin" ;;
        *) 
            echo "❌ Error: Unsupported file type '$filename'"
            return 1
            ;;
    esac
    
    # 3. Determine which compiler to use
    if [[ -n "$custom_compiler" ]]; then
        # Prioritize user-specified compiler for one-time use
        compiler="$custom_compiler"
        echo "⚠️  One-time temporary use of compiler: $compiler"
    else
        # Use default compiler for this language
        compiler=${lang_default_compiler[$lang]}
    fi
    
    # 4. Check if compiler is installed
    if ! is_installed "$compiler"; then
        echo "❌ Error: Compiler '$compiler' is not installed"
        case "$compiler" in
            python3|pypy|pypy3) echo "   💡 Suggested installation: pkg install python" ;;
            gcc|g++|clang|clang++) echo "   💡 Suggested installation: pkg install clang" ;;
            javac) echo "   💡 Suggested installation: pkg install openjdk-17" ;;
            node) echo "   💡 Suggested installation: pkg install nodejs" ;;
            php) echo "   💡 Suggested installation: pkg install php" ;;
            bash|sh) echo "   💡 Suggested installation: pkg install bash" ;;
            gfortran) echo "   💡 Suggested installation: pkg install gcc-gfortran" ;;
            rustc) echo "   💡 Suggested installation: pkg install rust" ;;
            kotlinc) echo "   💡 Suggested installation: pkg install kotlin" ;;
            octave) echo "   💡 Suggested installation: pkg install octave" ;;
        esac
        return 1
    fi
    
    # 5. Execute compilation and run
    echo -e "\n=============================="
    echo "🔵        Executing $filename"
  
    echo "Language: $lang | Compiler: $compiler"
    
    # Save current directory
    local original_dir=$(pwd)
    
    # If virtual working directory is set, switch to that directory
    #if [[ -n "$vcd" && -d "$vcd" ]]; then
     #   echo "Using virtual working directory: $vcd"
     #   cd "$vcd" || { echo "Error: Unable to switch to virtual working directory $vcd"; return 1; }
    #fi
    
    # Execute appropriate compile/run commands
    case "$compiler" in
        # Python series
        python3|pypy|pypy3)
            echo "🚀 Running Python script..."
            "$compiler" "$full_path"
            ;;
        
        # C series
        gcc|clang)
            local output_file="${output_dir}/$(basename "$filename" .c)"
            echo "🔨 Compiling C file..."
            "$compiler" -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ Compilation successful: $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 Running program..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  Deleted build output: $output_file"
                    fi
                fi
            else
                echo "❌ Compilation failed"
                cd "$original_dir"  # Return to original directory
                return 1
            fi
            ;;
        
        # C++ series
        g++|clang++)
            local output_file="${output_dir}/$(basename "$filename" .cpp)"
            echo "🔨 Compiling C++ file..."
            "$compiler" -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ Compilation successful: $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 Running program..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  Deleted build output: $output_file"
                    fi
                fi
            else
                echo "❌ Compilation failed"
                cd "$original_dir"  # Return to original directory
                return 1
            fi
            ;;
        
        # Java
        javac)
            local classname=$(basename "$filename" .java)
            echo "🔨 Compiling Java file..."
            javac -d "$output_dir" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ Compilation successful: ${output_dir}/${classname}.class"
                if [[ $execute == true ]]; then
                    echo "🏃 Running program..."
                    (cd "$output_dir" && java "$classname")
                    if [[ $delete_after == true ]]; then
                        rm -f "${output_dir}/${classname}.class"
                        echo "🗑️  Deleted build output: ${classname}.class"
                    fi
                fi
            else
                echo "❌ Compilation failed"
                cd "$original_dir"  # Return to original directory
                return 1
            fi
            ;;
        
        # Shell
        bash|sh)
            echo "🚀 Running Shell script..."
            "$compiler" "$full_path"
            ;;
        
        # JavaScript
        node)
            echo "🚀 Running JavaScript file..."
            "$compiler" "$full_path"
            ;;
        
        # PHP
        php)
            echo "🚀 Running PHP script..."
            "$compiler" "$full_path"
            ;;
        
        # Fortran
        gfortran)
            local output_file="${output_dir}/$(basename "$filename" .f)"
            # Handle different Fortran extensions
            case "$filename" in
                *.f90) output_file="${output_dir}/$(basename "$filename" .f90)" ;;
                *.f95) output_file="${output_dir}/$(basename "$filename" .f95)" ;;
                *.f03) output_file="${output_dir}/$(basename "$filename" .f03)" ;;
                *.f08) output_file="${output_dir}/$(basename "$filename" .f08)" ;;
            esac
            echo "🔨 Compiling Fortran file..."
            "$compiler" -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ Compilation successful: $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 Running program..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  Deleted build output: $output_file"
                    fi
                fi
            else
                echo "❌ Compilation failed"
                cd "$original_dir"  # Return to original directory
                return 1
            fi
            ;;
        
        # Rust
        rustc)
            local output_file="${output_dir}/$(basename "$filename" .rs)"
            echo "🔨 Compiling Rust file..."
            "$compiler" --out-dir "$output_dir" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ Compilation successful: $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 Running program..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  Deleted build output: $output_file"
                    fi
                fi
            else
                echo "❌ Compilation failed"
                cd "$original_dir"  # Return to original directory
                return 1
            fi
            ;;
        
        # Kotlin
        kotlinc)
            local classname=$(basename "$filename" .kt)
            local jar_file="${output_dir}/${classname}.jar"
            echo "🔨 Compiling Kotlin file..."
            "$compiler" -d "$jar_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ Compilation successful: $jar_file"
                if [[ $execute == true ]]; then
                    echo "🏃 Running program..."
                    java -jar "$jar_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$jar_file"
                        echo "🗑️  Deleted build output: $jar_file"
                    fi
                fi
            else
                echo "❌ Compilation failed"
                cd "$original_dir"  # Return to original directory
                return 1
            fi
            ;;
        
        # Octave
        octave)
            echo "🚀 Running Octave script..."
            octave --no-gui --eval "run('$full_path')"
            ;;
        
        # Unknown compiler
        *)
            echo "❌ Error: Unsupported compiler '$compiler'"
            cd "$original_dir"  # Return to original directory
            return 1
            ;;
    esac
    
    # Return to original directory
    cd "$original_dir"
    
    echo "🔵        Execution completed"
    echo "=============================="
    return 0
}

# ==============================================
# Show Available Compiler Information
# ==============================================
check_availability() {
    echo ""
    echo "=============================="
    echo "     🟡🟠 Compiler Availability Check 🟠🟡"
    echo "=============================="
    
    for lang in "${!language_config[@]}"; do
        local default_compiler=$(get_default_default "$lang")
        local candidates=$(get_candidates "$lang")
        echo ""
        echo "🔷 $lang language available compilers:"
        echo "   Default compiler: $default_compiler"
        
        # Check each candidate compiler
        IFS=' ' read -ra COMPILERS <<< "$candidates"
        for compiler in "${COMPILERS[@]}"; do
            local status=""
            if is_installed "$compiler"; then
                status="✅ Installed"
            else
                status="❌ Not installed"
            fi
            
            # Check if this is the currently used compiler for this language
            if [[ "${lang_default_compiler[$lang]}" == "$compiler" ]]; then
                status="$status [In use]"
            fi
            
            echo "   • $compiler - $status"
        done
    done
    echo ""
    echo "=============================="
}

# ==============================================
# Main Interactive Interface
# ==============================================
main_interface() {
    echo ""
    echo "=============================="
    echo "        🟡🟠 Main Interface 🟠🟡"
    echo "=============================="
    echo "📝 Usage Instructions:"
    echo "   • Enter filename (and compiler) for one-time execution"
    echo "   • Press Ctrl+C to exit and show configuration seed"
    echo "=============================="
    
    while true; do
        # Get source directory for display (last 2 levels)
        local source_dir_display=$(format_path_for_display "$source_dir")
        read -p "🟢[colL] $source_dir_display ❯ " -a input
        
        if [[ ${#input[@]} -eq 0 ]]; then
            continue
        else
            # Check for special commands
            if [[ "${input[0]}" == "-h" || "${input[0]}" == "--help" ]]; then
                show_help
                continue
            elif [[ "${input[0]}" == "-v" || "${input[0]}" == "--version" ]]; then
                show_version
                continue
            elif [[ "${input[0]}" == "checkavails" ]]; then
                check_availability
                continue
            fi
            
            # Parse user input
            local filename="${input[0]}"
            local compiler="${input[1]}"
            
            # Recursively find file
            local found_files=($(find_file_recursive "$filename" "$source_dir"))
            
            if [[ ${#found_files[@]} -eq 0 ]]; then
                # Show full path in error message
                local source_full_path=$(realpath "$source_dir" 2>/dev/null || echo "$source_dir")
                echo "❌ Error: File '$filename' not found in '${source_full_path}' and its subdirectories"
                continue
            elif [[ ${#found_files[@]} -gt 1 ]]; then
                echo ""
                echo "🔍 Found multiple files named '$filename':"
                for i in "${!found_files[@]}"; do
                    echo "   $((i+1)). ${found_files[$i]}"
                done
                read -p "🔢 Please select the file number to execute: " selection
                if [[ $selection -lt 1 || $selection -gt ${#found_files[@]} ]]; then
                    echo "❌ Error: Invalid number"
                    continue
                fi
                local selected_file="${found_files[$((selection-1))]}"
                execute_file "$selected_file" "$compiler"
            else
                execute_file "${found_files[0]}" "$compiler"
            fi
        fi
    done
}

# ==============================================
# Main Function
# ==============================================
main() {
    echo ""
    echo "=============================="
    echo "     🟡🟠🔴 colL 🔴🟠🟡"
    echo "Multi-language Compile and Run Tool (Lightweight) v$VERSION"
    echo "=============================="
    echo "👋 Welcome to colL!"
    echo "   • Enter '--help' for help"
    echo "   • Enter 'checkavails' to check compiler status"
    echo "=============================="
    
    # Load seed configuration from command line arguments
    load_seed_from_args "$@"
    
    # Initialize configuration
    initialize
    
    # Enter main interface
    main_interface
}

# Start program
main "$@"
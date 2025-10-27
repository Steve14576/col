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
    echo "     😭😭😭😭 colL $VERSION ✍✍✍✍      "
    echo "     mI' chIm HablI' (loSmach)"
    echo "=========================================="
    echo ""
    echo "📋 chaw':"
    echo "   javal, Q'ap, Q'ap'a, ghew'ghew, choq, ja'chuq,"
    echo "   pe'ach, bav, for'tran, ruch, kot"
    echo ""
    echo "🔍 gahmoH:"
    echo "   • Termux chaw' tu'lu'"
    echo "   • nI'qu' raS teq"
    echo "   • Ctrl+C chugh configuration seed chIm"
    echo ""
    echo "🚀 chugh qI':"
    echo "   ./colL2.sh [configuration seed]"
    echo ""
    echo "⚙️  Configuration Seed mI':"
    echo "   f-<teq>     teq raS chIm"
    echo "   t-<nagh>   nagh raS chIm"
    echo "   op-<bIng>          HablI'-bIng chIm"
    echo ""
    echo "🎮 nuv:"
    echo "   <pIq>           pIq chIm"
    echo "   <pIq> <bIng>  wa'rub bIng chIm"
    echo "   checkavails      bIng chaw' chIm"
    echo "   -h, --help       Qagh chIm"
    echo "   -v, --version    mI' chIm"
    echo ""
    echo "📝 mI'lIj:"
    echo "   ./colL2.sh f-./sources t-./builds op-chang-Q'ap,guch'a-Q'ap'a"
    echo "   test.Q'ap"
    echo "   test.Q'ap guch"
    echo "   checkavails"
    echo "   Ctrl+C (chugh configuration seed chIm)"
    echo ""
    echo "💡 nugh: --help pagh --version chugh nuv tu'lu'"
    echo "=========================================="
}

# ==============================================
# Display Version Information
# ==============================================
show_version() {
    echo "=============================="
    echo "      colL mI' chIm HablI'"
    echo "         (loSmach)"
    echo "           v$VERSION"
    echo "=============================="
}

# ==============================================
# Capture Ctrl+C signal, show current configuration seed on exit
# ==============================================
trap 'show_exit_seed; echo -e "\n🛑 mI'"'"' chIm"; exit 0' SIGINT

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
    echo "wa'rub chugh qI' chIm:"
    
    # Collect current configuration opcodes
    local current_ops=()
    
    for lang in "${!language_config[@]}"; do
        local current_compiler=${lang_default_compiler[$lang]}
        local klingon_lang=$(translate_language "$lang")
        local klingon_compiler=$(translate_compiler "$current_compiler")
        current_ops+=("${klingon_compiler}-${klingon_lang}")
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
            echo "📁 teq: $source_dir (nI'qu' raS teq)"
        elif [[ $arg == t-* ]]; then
            output_dir="${arg#t-}"
            echo "📂 nagh: $output_dir"
        #elif [[ $arg == v-* ]]; then
         #   vcd="${arg#v-}"
          #  echo "Using command line specified virtual working directory: $vcd"
        elif [[ $arg == op-* ]]; then
            op_codes="${arg#op-}"
            echo "⚙️  HablI'-bIng: $op_codes"
        else
            echo "⚠️  Doch: $arg (chugh)"
        fi
    done
}

# ==============================================
# Script Internal Record: Language-Compiler Mapping Table (Core Configuration)
# Structure: language name -> [default default compiler, [alternative compiler list...]]
# ==============================================
declare -A language_config=(
    ["Q'ap"]="chang:guch,chang"
    ["Q'ap'a"]="guch'a:guch'a,chang'a"
    ["javal"]="javaluch:javaluch"
    ["ghew'ghew"]="ghew'ghew wej:ghew'ghew wej,pipi,pipi wej"
    ["choq"]="bach:bach,esh"
    ["ja'chuq"]="no'Daq:no'Daq"
    ["pe'ach"]="pe'ach:pe'ach"
    ["bav"]="bav:bav"
    ["for'tran"]="guch for'tran:guch for'tran"
    ["ruch"]="ruchuch:ruchuch"
    ["kot"]="kotluch:kotluch"
)

# State variables
declare -A lang_default_compiler  # User-set default compiler for each language
declare -A klingon_to_english_compiler  # Map Klingon compiler names to actual compiler names
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
# Translator Table for Compiler Names
# ==============================================
translate_compiler() {
    case "$1" in
        "gcc") echo "guch" ;;
        "clang") echo "chang" ;;
        "g++") echo "guch'a" ;;
        "clang++") echo "chang'a" ;;
        "javac") echo "javaluch" ;;
        "python3") echo "ghew'ghew wej" ;;
        "pypy") echo "pipi" ;;
        "pypy3") echo "pipi wej" ;;
        "bash") echo "bach" ;;
        "sh") echo "esh" ;;
        "node") echo "no'Daq" ;;
        "php") echo "pe'ach" ;;
        "gfortran") echo "guch for'tran" ;;
        "rustc") echo "ruchuch" ;;
        "kotlinc") echo "kotluch" ;;
        "octave") echo "bav" ;;
        *) echo "$1" ;;
    esac
}

# ==============================================
# Reverse Translator Table for Compiler Names
# ==============================================
reverse_translate_compiler() {
    case "$1" in
        "guch") echo "gcc" ;;
        "chang") echo "clang" ;;
        "guch'a") echo "g++" ;;
        "chang'a") echo "clang++" ;;
        "javaluch") echo "javac" ;;
        "ghew'ghew wej") echo "python3" ;;
        "pipi") echo "pypy" ;;
        "pipi wej") echo "pypy3" ;;
        "bach") echo "bash" ;;
        "esh") echo "sh" ;;
        "no'Daq") echo "node" ;;
        "pe'ach") echo "php" ;;
        "guch for'tran") echo "gfortran" ;;
        "ruchuch") echo "rustc" ;;
        "kotluch") echo "kotlinc" ;;
        "bav") echo "octave" ;;
        *) echo "$1" ;;
    esac
}

# ==============================================
# Translator Table for Language Names
# ==============================================
translate_language() {
    case "$1" in
        "c") echo "Q'ap" ;;
        "cpp") echo "Q'ap'a" ;;
        "java") echo "javal" ;;
        "python") echo "ghew'ghew" ;;
        "shell") echo "choq" ;;
        "javascript") echo "ja'chuq" ;;
        "php") echo "pe'ach" ;;
        "octave") echo "bav" ;;
        "fortran") echo "for'tran" ;;
        "rust") echo "ruch" ;;
        "kotlin") echo "kot" ;;
        *) echo "$1" ;;
    esac
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
            echo "📁 teq chIm: $source_dir"
        elif [[ $op == t-* ]]; then
            output_dir="${op#t-}"
            echo "📂 nagh chIm: $output_dir"
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
                echo "⚠️  HablI' Dung: '$lang' (chugh)"
                continue
            fi
            
            # Verify if compiler is in the candidate list for this language
            local candidates=$(get_candidates "$lang")
            if [[ ! " $candidates " =~ " $compiler " ]]; then
                echo "⚠️  bIng '$compiler' HablI' $lang chugh (chugh)"
                continue
            fi
            
            # Apply configuration
            lang_default_compiler[$lang]=$compiler
            
            # Map Klingon compiler name to actual compiler name
            local actual_compiler=$(reverse_translate_compiler "$compiler")
            klingon_to_english_compiler[$compiler]=$actual_compiler
            
            echo "✅ $lang HablI' bIng: $compiler"
            
            # Check if installation prompt is needed
            if ! is_installed "$actual_compiler"; then
                echo "⚠️  nugh: $compiler Dung"
                case "$actual_compiler" in
                    "python3"|"pypy"|"pypy3") echo "   💡 chugh: pkg install python" ;;
                    "gcc"|"g++"|"clang"|"clang++") echo "   💡 chugh: pkg install clang" ;;
                    "javac") echo "   💡 chugh: pkg install openjdk-17" ;;
                    "node") echo "   💡 chugh: pkg install nodejs" ;;
                    "php") echo "   💡 chugh: pkg install php" ;;
                    "bash"|"sh") echo "   💡 chugh: pkg install bash" ;;
                    "gfortran") echo "   💡 chugh: pkg install gcc-gfortran" ;;
                    "rustc") echo "   💡 chugh: pkg install rust" ;;
                    "kotlinc") echo "   💡 chugh: pkg install kotlin" ;;
                    "octave") echo "   💡 chugh: pkg install octave" ;;
                esac
            fi
        else
            echo "⚠️  Doch '$op' (chugh)"
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
        echo "⚠️  teq Dung, wa'rub chIm"
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
        echo "⚠️  nagh Dung, wa'rub chIm"
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
        # Map default compilers to their actual names
        local klingon_compiler=$(get_default_default "$lang")
        local actual_compiler=$(reverse_translate_compiler "$klingon_compiler")
        klingon_to_english_compiler[$klingon_compiler]=$actual_compiler
    done
    
    # Apply compiler-language mapping
    if [[ -n "$op_codes" ]]; then
        echo -e "\n🔧 HablI'-bIng chIm..."
        apply_compiler_language_pairs "$op_codes"
    fi
    
    echo -e "\n✅ nI'qu'!"
    
    # Show script location and source directory full paths
    local script_full_path=$(realpath "$0" 2>/dev/null || echo "$0")
    local source_full_path=$(realpath "$source_dir" 2>/dev/null || echo "$source_dir")
    echo "📄 mI': $script_full_path"
    echo "📁 teq: $source_full_path"
}

# ==============================================
# Compile and Execute Core Logic
# ==============================================
execute_file() {
    local full_path="$1"
    local custom_compiler="$2"  # Optional: User-specified compiler for one-time use
    local lang=""
    local compiler=""
    local actual_compiler=""  # The actual compiler command to use
    local filename=$(basename "$full_path")
    
    # 1. Check if file exists
    if [[ ! -f "$full_path" ]]; then
        echo "❌ Doch: '$full_path' Dung"
        return 1
    fi
    
    # 2. Determine language based on extension
    case "$filename" in
        *.c) lang="Q'ap" ;;
        *.cpp|*.cxx|*.cc) lang="Q'ap'a" ;;
        *.java) lang="javal" ;;
        *.py) lang="ghew'ghew" ;;
        *.sh) lang="choq" ;;
        *.js) lang="ja'chuq" ;;
        *.php) lang="pe'ach" ;;
        *.m) lang="bav" ;;
        *.f|*.f90|*.f95|*.f03|*.f08) lang="for'tran" ;;
        *.rs) lang="ruch" ;;
        *.kt) lang="kot" ;;
        *) 
            echo "❌ Doch: '$filename' Dung"
            return 1
            ;;
    esac
    
    # 3. Determine which compiler to use
    if [[ -n "$custom_compiler" ]]; then
        # Prioritize user-specified compiler for one-time use
        compiler="$custom_compiler"
        echo "⚠️  wa'rub bIng: $compiler"
        # Get the actual compiler name
        actual_compiler=$(reverse_translate_compiler "$compiler")
        if [[ "$actual_compiler" == "$compiler" ]]; then
            # If no translation found, use as is
            actual_compiler="$compiler"
        fi
    else
        # Use default compiler for this language
        compiler=${lang_default_compiler[$lang]}
        # Get the actual compiler name
        actual_compiler=${klingon_to_english_compiler[$compiler]}
        if [[ -z "$actual_compiler" ]]; then
            # If no mapping found, use the Klingon name as fallback
            actual_compiler="$compiler"
        fi
    fi
    
    # 4. Check if compiler is installed
    if ! is_installed "$actual_compiler"; then
        echo "❌ Doch: bIng '$compiler' Dung"
        case "$actual_compiler" in
            "python3"|"pypy"|"pypy3") echo "   💡 chugh: pkg install python" ;;
            "gcc"|"g++"|"clang"|"clang++") echo "   💡 chugh: pkg install clang" ;;
            "javac") echo "   💡 chugh: pkg install openjdk-17" ;;
            "node") echo "   💡 chugh: pkg install nodejs" ;;
            "php") echo "   💡 chugh: pkg install php" ;;
            "bash"|"sh") echo "   💡 chugh: pkg install bash" ;;
            "gfortran") echo "   💡 chugh: pkg install gcc-gfortran" ;;
            "rustc") echo "   💡 chugh: pkg install rust" ;;
            "kotlinc") echo "   💡 chugh: pkg install kotlin" ;;
            "octave") echo "   💡 chugh: pkg install octave" ;;
        esac
        return 1
    fi
    
    # 5. Execute compilation and run
    echo -e "\n=============================="
    echo "🔵        chIm $filename"
    echo "HablI': $lang | bIng: $compiler"
    
    # Save current directory
    local original_dir=$(pwd)
    
    # If virtual working directory is set, switch to that directory
    #if [[ -n "$vcd" && -d "$vcd" ]]; then
     #   echo "Using virtual working directory: $vcd"
     #   cd "$vcd" || { echo "Error: Unable to switch to virtual working directory $vcd"; return 1; }
    #fi
    
    # Execute appropriate compile/run commands
    case "$actual_compiler" in
        # Python series
        "python3"|"pypy"|"pypy3")
            echo "🚀 chIm ghew'ghew..."
            "$actual_compiler" "$full_path"
            ;;
        
        # C series
        "gcc"|"clang")
            local output_file="${output_dir}/$(basename "$filename" .c)"
            echo "🔨 chIm Q'ap..."
            "$actual_compiler" -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ nI'qu': $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 chIm..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  nagh: $output_file"
                    fi
                fi
            else
                echo "❌ nI'qu' Dung"
                cd "$original_dir"  # Return to original directory
                return 1
            fi
            ;;
        
        # C++ series
        "g++"|"clang++")
            local output_file="${output_dir}/$(basename "$filename" .cpp)"
            echo "🔨 chIm Q'ap'a..."
            "$actual_compiler" -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ nI'qu': $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 chIm..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  nagh: $output_file"
                    fi
                fi
            else
                echo "❌ nI'qu' Dung"
                cd "$original_dir"  # Return to original directory
                return 1
            fi
            ;;
        
        # Java
        "javac")
            local classname=$(basename "$filename" .java)
            echo "🔨 chIm javal..."
            javac -d "$output_dir" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ nI'qu': ${output_dir}/${classname}.class"
                if [[ $execute == true ]]; then
                    echo "🏃 chIm..."
                    (cd "$output_dir" && java "$classname")
                    if [[ $delete_after == true ]]; then
                        rm -f "${output_dir}/${classname}.class"
                        echo "🗑️  nagh: ${classname}.class"
                    fi
                fi
            else
                echo "❌ nI'qu' Dung"
                cd "$original_dir"  # Return to original directory
                return 1
            fi
            ;;
        
        # Shell
        "bash"|"sh")
            echo "🚀 chIm choq..."
            "$actual_compiler" "$full_path"
            ;;
        
        # JavaScript
        "node")
            echo "🚀 chIm ja'chuq..."
            "$actual_compiler" "$full_path"
            ;;
        
        # PHP
        "php")
            echo "🚀 chIm pe'ach..."
            "$actual_compiler" "$full_path"
            ;;
        
        # Fortran
        "gfortran")
            local output_file="${output_dir}/$(basename "$filename" .f)"
            # Handle different Fortran extensions
            case "$filename" in
                *.f90) output_file="${output_dir}/$(basename "$filename" .f90)" ;;
                *.f95) output_file="${output_dir}/$(basename "$filename" .f95)" ;;
                *.f03) output_file="${output_dir}/$(basename "$filename" .f03)" ;;
                *.f08) output_file="${output_dir}/$(basename "$filename" .f08)" ;;
            esac
            echo "🔨 chIm for'tran..."
            "$actual_compiler" -o "$output_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ nI'qu': $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 chIm..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  nagh: $output_file"
                    fi
                fi
            else
                echo "❌ nI'qu' Dung"
                cd "$original_dir"  # Return to original directory
                return 1
            fi
            ;;
        
        # Rust
        "rustc")
            local output_file="${output_dir}/$(basename "$filename" .rs)"
            echo "🔨 chIm ruch..."
            "$actual_compiler" --out-dir "$output_dir" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ nI'qu': $output_file"
                if [[ $execute == true ]]; then
                    echo "🏃 chIm..."
                    "$output_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$output_file"
                        echo "🗑️  nagh: $output_file"
                    fi
                fi
            else
                echo "❌ nI'qu' Dung"
                cd "$original_dir"  # Return to original directory
                return 1
            fi
            ;;
        
        # Kotlin
        "kotlinc")
            local classname=$(basename "$filename" .kt)
            local jar_file="${output_dir}/${classname}.jar"
            echo "🔨 chIm kot..."
            "$actual_compiler" -d "$jar_file" "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ nI'qu': $jar_file"
                if [[ $execute == true ]]; then
                    echo "🏃 chIm..."
                    java -jar "$jar_file"
                    if [[ $delete_after == true ]]; then
                        rm -f "$jar_file"
                        echo "🗑️  nagh: $jar_file"
                    fi
                fi
            else
                echo "❌ nI'qu' Dung"
                cd "$original_dir"  # Return to original directory
                return 1
            fi
            ;;
        
        # Octave
        "octave")
            echo "🚀 chIm bav..."
            octave --no-gui --eval "run('$full_path')"
            ;;
        
        # Unknown compiler
        *)
            echo "❌ Doch: bIng '$compiler' Dung"
            cd "$original_dir"  # Return to original directory
            return 1
            ;;
    esac
    
    # Return to original directory
    cd "$original_dir"
    
    echo "🔵        nI'qu'"
    echo "=============================="
    return 0
}

# ==============================================
# Show Available Compiler Information
# ==============================================
check_availability() {
    echo ""
    echo "=============================="
    echo "     🟡🟠 bIng chaw' 🟠🟡"
    echo "=============================="
    
    for lang in "${!language_config[@]}"; do
        local default_compiler=$(get_default_default "$lang")
        local candidates=$(get_candidates "$lang")
        echo ""
        echo "🔷 $lang bIng:"
        echo "   wa'rub: $default_compiler"
        
        # Check each candidate compiler
        IFS=' ' read -ra COMPILERS <<< "$candidates"
        for compiler in "${COMPILERS[@]}"; do
            # Get the actual compiler name for checking installation
            local actual_compiler=$(reverse_translate_compiler "$compiler")
            local status=""
            if is_installed "$actual_compiler"; then
                status="✅ chaw'"
            else
                status="❌ Dung"
            fi
            
            # Check if this is the currently used compiler for this language
            if [[ "${lang_default_compiler[$lang]}" == "$compiler" ]]; then
                status="$status [chIm]"
            fi
            
            # Translate compiler name to Klingon if possible
            local klingon_compiler=$(translate_compiler "$actual_compiler")
            echo "   • $klingon_compiler - $status"
        done
    done
    echo ""
    echo "=============================="
}

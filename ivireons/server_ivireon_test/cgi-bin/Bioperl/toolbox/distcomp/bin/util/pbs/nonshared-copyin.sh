# Non-shared filesystem - overwrite MDCE_STORAGE_LOCATION
MDCE_STORAGE_LOCATION=${PWD}
export MDCE_STORAGE_LOCATION

copyWithRetry() {
    echo "Copying: $@"
    
    # If we think the source file is local (no ":"), check we can read it
    case $2 in 
        *:*)   # remote file 
            ;; 
        *)     # local file
            if [ ! -r "$2" ] ; then
                echo "Local source file $2 is missing"
                exit 1
            fi
            ;;
    esac

    # Retry the RCP command
    failed=1
    for attempt in 1 2 3 4 5 ; do
        # Call the RCP command
        "$1" "$2" "$3"
        if [ $? -eq 0 ] ; then
            failed=0
            break;
        fi
        echo "Attempt ${attempt} to copy from $2 failed, trying again..."
        sleep ${attempt}
    done
    [ $failed -eq 1 ] && echo "Error copying from $2 to $3" && exit 1
}

echo "Copying in files to ${PWD}"

<COPY_FILES>

#!/usr/bin/env bash
# lib/services.sh - Systemd service management functions

# -------- Option 1: Active & Activating --------
run_option1() {
    echo "🟢 Active & Activating Services"
    echo "--------------------------------"

    mapfile -t active < <(systemctl list-units --type=service --state=active --no-pager | awk '{print $1}' | grep '\.service$')
    mapfile -t activating < <(systemctl list-units --type=service --state=activating --no-pager | awk '{print $1}' | grep '\.service$')

    echo "Active Services:"
    for i in "${!active[@]}"; do
        printf "  %2d. %s\n" $((i+1)) "${active[$i]}"
    done

    if [ ${#activating[@]} -gt 0 ]; then
        echo -e "\nActivating Services:"
        for i in "${!activating[@]}"; do
            printf "  %2d. %s\n" $((i+1+${#active[@]})) "${activating[$i]}"
        done
    fi

    all_services=("${active[@]}" "${activating[@]}")

    if [ ${#all_services[@]} -gt 0 ]; then
        echo
        read -rp "Enter the number of a service to stop (or press Enter to skip): " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice>=1 && choice<=${#all_services[@]} )); then
            svc_name="${all_services[$((choice-1))]}"
            echo "Stopping $svc_name ..."
            sudo systemctl stop "$svc_name"
            if systemctl is-active --quiet "$svc_name"; then
                echo "⚠️ Failed to stop $svc_name."
            else
                echo "✅ $svc_name stopped successfully."
                grep -qxF "$svc_name" "$RECORD_FILE" || echo "$svc_name" >> "$RECORD_FILE"
            fi
        else
            echo "No valid selection."
        fi
    else
        echo "No active or activating services found."
    fi

    read -rp "Press Enter to main menu..."
}

# -------- Option 2: Script History / Stopped Services --------
run_option2() {
    echo "⚙️ Services stopped by this script"
    echo "--------------------------------"

    if [ ! -s "$RECORD_FILE" ]; then
        echo "No services have been stopped by this script yet."
        read -rp "Press Enter to return..."
        return
    fi

    mapfile -t stopped_by_script < "$RECORD_FILE"

    for i in "${!stopped_by_script[@]}"; do
        svc="${stopped_by_script[$i]}"
        status=$(systemctl is-active "$svc" 2>/dev/null || echo "unknown")
        printf "  %2d. %-40s [%s]\n" $((i+1)) "$svc" "$status"
    done

    echo
    read -rp "Number of a service to Re-enable or Skip : " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice>=1 && choice<=${#stopped_by_script[@]} )); then
        svc_name="${stopped_by_script[$((choice-1))]}"
        echo "Starting $svc_name ..."
        sudo systemctl start "$svc_name"
        if systemctl is-active --quiet "$svc_name"; then
            echo "✅ $svc_name started successfully."
            grep -vxF "$svc_name" "$RECORD_FILE" > "$RECORD_FILE.tmp" && mv "$RECORD_FILE.tmp" "$RECORD_FILE"
        else
            echo "⚠️ Failed to start $svc_name."
        fi
    fi

    read -rp "Press Enter to main menu..."
}

# -------- Option 3: Inactive & Other Services --------
run_option3() {
    echo "📋 Inactive & Other Services (Grouped)"
    echo "--------------------------------------"

    mapfile -t all_inactive < <(
        systemctl list-units --type=service --all --no-pager \
        | awk '/\.service/ {print $1, $4}' | grep -vE '^UNIT|^\['
    )

    failed=()
    inactive=()
    dead=()
    others=()

    for line in "${all_inactive[@]}"; do
        svc=$(echo "$line" | awk '{print $1}')
        state=$(echo "$line" | awk '{print $2}')

        [[ "$state" == "exited" || "$state" == "activating" ]] && continue

        case $state in
            failed) failed+=("$svc [$state]") ;;
            inactive) inactive+=("$svc [$state]") ;;
            dead) dead+=("$svc [$state]") ;;
            *) others+=("$svc [$state]") ;;
        esac
    done

    show_group() {
        local code="$1"
        local title="$2"
        shift 2
        local items=("$@")
        if [ ${#items[@]} -gt 0 ]; then
            echo -e "\n$title"
            for i in "${!items[@]}"; do
                printf "  %s%3d. %s\n" "$code" $((i+1)) "${items[$i]}"
            done
        fi
    }

    show_group "a" "🔴 Failed Services:" "${failed[@]}"
    show_group "b" "🟡 Inactive Services:" "${inactive[@]}"
    show_group "c" "⚪ Other (Static/Masked/Unknown):" "${others[@]}"
    show_group "d" "⚫ Dead Services:" "${dead[@]}"

    total=$(( ${#failed[@]} + ${#inactive[@]} + ${#others[@]} + ${#dead[@]} ))
    echo -e "\n--------------------------------------"
    echo "Total inactive-related services: $total"

    read -rp "Enter service code to start (e.g., d5), or press Enter to skip: " code

    if [[ "$code" =~ ^[a-d][0-9]+$ ]]; then
        section="${code:0:1}"
        num="${code:1}"
        case $section in
            a) arr=("${failed[@]}") ;;
            b) arr=("${inactive[@]}") ;;
            c) arr=("${others[@]}") ;;
            d) arr=("${dead[@]}") ;;
        esac

        if (( num>=1 && num<=${#arr[@]} )); then
            svc_name=$(echo "${arr[$((num-1))]}" | awk '{print $1}')
            echo "Starting $svc_name ..."
            sudo systemctl start "$svc_name"
            if systemctl is-active --quiet "$svc_name"; then
                echo "✅ $svc_name started successfully."
            else
                echo "⚠️ Failed to start $svc_name."
            fi
        else
            echo "❌ Invalid number in section."
        fi
    elif [ -n "$code" ]; then
        echo "❌ Invalid input format. Use like a12, b4, etc."
    fi

    read -rp "Press enter to main menu..."
}
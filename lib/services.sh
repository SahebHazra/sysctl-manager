#!/usr/bin/env bash
# lib/services.sh - Systemd service management functions

record_stopped_service() {
    local svc_name="$1"
    touch -- "$RECORD_FILE" || return 1
    if grep -qxF -- "$svc_name" "$RECORD_FILE"; then
        return 0
    fi
    printf '%s\n' "$svc_name" >> "$RECORD_FILE"
}

confirm_service_action() {
    local action="$1"
    local svc_name="$2"
    local answer

    read -rp "Confirm $action for $svc_name? [Y/n]: " answer
    if [[ -z "$answer" || "$answer" == "y" || "$answer" == "Y" ]]; then
        return 0
    fi

    echo "Cancelled: $action for $svc_name."
    return 1
}

remove_stopped_service() {
    local svc_name="$1"
    local tmp_file
    [[ -f "$RECORD_FILE" ]] || return 0
    tmp_file=$(mktemp "${RECORD_FILE}.XXXXXX") || return 1
    if awk -v target="$svc_name" '$0 != target' "$RECORD_FILE" > "$tmp_file" &&
        mv -- "$tmp_file" "$RECORD_FILE"; then
        return 0
    fi
    rm -f -- "$tmp_file"
    return 1
}

# -------- Option 1: Active & Activating --------
run_option1() {
    echo "🟢 Active & Activating Services"
    echo "--------------------------------"

    local units_output
    if ! units_output=$(systemctl list-units --type=service --all --no-legend --no-pager --plain); then
        echo "Error: Unable to retrieve systemd services."
        read -rp "Press Enter to return..."
        return 1
    fi

    local -a active=()
    local -a activating=()
    local -a all_services=()
    mapfile -t active < <(awk '$1 ~ /\.service$/ && $3 == "active" { print $1 }' <<< "$units_output")
    mapfile -t activating < <(awk '$1 ~ /\.service$/ && $3 == "activating" { print $1 }' <<< "$units_output")

    echo "Active Services:"
    local i
    for i in "${!active[@]}"; do
        printf "  %2d. %s\n" "$((i + 1))" "${active[$i]}"
    done

    if (( ${#activating[@]} > 0 )); then
        printf '\nActivating Services:\n'
        for i in "${!activating[@]}"; do
            printf "  %2d. %s\n" "$((i + 1 + ${#active[@]}))" "${activating[$i]}"
        done
    fi

    all_services=("${active[@]}" "${activating[@]}")

    if (( ${#all_services[@]} > 0 )); then
        local choice svc_name
        echo
        read -rp "Enter the number of a service to stop (or press Enter to skip): " choice

        if [[ -z "$choice" ]]; then
            return 0
        fi

        if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#all_services[@]})); then
            svc_name="${all_services[$((choice - 1))]}"
            if confirm_service_action "stop" "$svc_name"; then
                echo "Stopping $svc_name ..."

                if sudo systemctl stop "$svc_name"; then
                    if systemctl is-active --quiet "$svc_name"; then
                        echo "Warning: $svc_name is still active; history was not changed."
                    elif record_stopped_service "$svc_name"; then
                        echo "$svc_name stopped and recorded in history."
                    else
                        echo "Warning: $svc_name stopped, but history could not be saved."
                    fi
                else
                    echo "Failed to stop $svc_name; history was not changed."
                fi
            fi
        else
            echo "Invalid selection. Enter a listed number or press Enter to skip."
        fi
    else
        echo "No active or activating services found."
    fi

    read -rp "Press Enter to return to the main menu..."
}

# -------- Option 2: Script History / Stopped Services --------
run_option2() {
    echo "⚙️ Services stopped by this script"
    echo "--------------------------------"

    if [[ ! -s "$RECORD_FILE" ]]; then
        echo "No services have been stopped by this script yet."
        read -rp "Press Enter to return..."
        return 0
    fi

    local -a stopped_by_script=()
    mapfile -t stopped_by_script < "$RECORD_FILE"

    local i svc status
    for i in "${!stopped_by_script[@]}"; do
        svc="${stopped_by_script[$i]}"
        status=$(systemctl is-active "$svc" 2>/dev/null || true)
        [[ -n "$status" ]] || status="unknown"
        printf "  %2d. %-40s [%s]\n" "$((i + 1))" "$svc" "$status"
    done

    local choice svc_name
    echo
    read -rp "Number of a service to restart, or press Enter to skip: " choice

    if [[ -z "$choice" ]]; then
        return 0
    fi

    if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#stopped_by_script[@]})); then
        svc_name="${stopped_by_script[$((choice - 1))]}"
        if confirm_service_action "start" "$svc_name"; then
            echo "Starting $svc_name ..."

            if sudo systemctl start "$svc_name"; then
                echo "Start command succeeded for $svc_name."
                # A successful start may return a one-shot service to inactive state.
                if remove_stopped_service "$svc_name"; then
                    echo "History updated."
                else
                    echo "Warning: Service start succeeded, but history could not be updated."
                fi
            else
                echo "Failed to start $svc_name; history was preserved."
            fi
        fi
    else
        echo "Invalid selection. Enter a listed number or press Enter to skip."
    fi

    read -rp "Press Enter to return to the main menu..."
}

# -------- Option 3: Inactive & Other Services --------
run_option3() {
    echo "📋 Inactive & Other Services"
    echo "--------------------------------------"

    local units_output
    if ! units_output=$(systemctl list-units --type=service --all --no-legend --no-pager --plain); then
        echo "Error: Unable to retrieve systemd services."
        read -rp "Press Enter to return..."
        return 1
    fi

    local -a failed=()
    local -a inactive=()
    local -a dead=()
    local -a others=()
    local line svc load active sub description

    # Output columns are UNIT LOAD ACTIVE SUB DESCRIPTION.
    while IFS= read -r line; do
        [[ -n "$line" ]] || continue
        read -r svc load active sub description <<< "$line"
        [[ "$svc" == *.service ]] || continue

        case "$active" in
            failed) failed+=("$svc [$active/$sub]") ;;
            inactive)
                if [[ "$sub" == "dead" ]]; then
                    dead+=("$svc [$active/$sub]")
                else
                    inactive+=("$svc [$active/$sub]")
                fi
                ;;
            active|activating|deactivating|reloading) ;;
            *) others+=("$svc [$active/$sub]") ;;
        esac
    done <<< "$units_output"

    show_group() {
        local code="$1"
        local title="$2"
        shift 2
        local -a items=("$@")
        local i

        if (( ${#items[@]} > 0 )); then
            printf '\n%s\n' "$title"
            for i in "${!items[@]}"; do
                printf "  %s%3d. %s\n" "$code" "$((i + 1))" "${items[$i]}"
            done
        fi
    }

    show_group "a" "🔴 Failed Services:" "${failed[@]}"
    show_group "b" "🟡 Inactive Services:" "${inactive[@]}"
    show_group "c" "⚪ Other Non-active States:" "${others[@]}"
    show_group "d" "⚫ Dead Services:" "${dead[@]}"

    local total=$((${#failed[@]} + ${#inactive[@]} + ${#dead[@]} + ${#others[@]}))
    printf '\n--------------------------------------\n'
    printf 'Total non-active services: %d\n' "$total"

    if ((total == 0)); then
        echo "No non-active services found."
        read -rp "Press Enter to return..."
        return 0
    fi

    local code section num svc_name
    local -a arr=()
    read -rp "Enter service code to start (e.g., d5), or press Enter to skip: " code

    if [[ -z "$code" ]]; then
        return 0
    fi

    if [[ "$code" =~ ^[a-d][0-9]+$ ]]; then
        section="${code:0:1}"
        num="${code:1}"

        case "$section" in
            a) arr=("${failed[@]}") ;;
            b) arr=("${inactive[@]}") ;;
            c) arr=("${others[@]}") ;;
            d) arr=("${dead[@]}") ;;
        esac

        if ((num >= 1 && num <= ${#arr[@]})); then
            svc_name="${arr[$((num - 1))]%% *}"
            if confirm_service_action "start" "$svc_name"; then
                echo "Starting $svc_name ..."

                if sudo systemctl start "$svc_name"; then
                    echo "Start command succeeded for $svc_name."
                else
                    echo "Failed to start $svc_name."
                fi
            fi
        else
            echo "Invalid service number for that category."
        fi
    else
        echo "Invalid input. Use a code such as a1 or d2."
    fi

    read -rp "Press Enter to return to the main menu..."
}

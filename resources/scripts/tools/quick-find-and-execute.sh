#!/usr/bin/env bash

# Configuration: define what you want to be warned about
dangerous_commands=("rm" "dd" "mkfs" "chmod" "chown")

# Prefix to identify commands run by this script (for internal filtering only, not added to history)
script_prefix="q "

# Load history from file. Using the history command didn't work and this is perfectly fine.
history_file=~/.bash_history

# ANSI escape codes for colored text
BLUE_BOLD='\033[1;34m'
BOLD_GRAY='\033[1;90m'
GREEN='\033[0;32m'
RED='\033[1;91m'
YELLOW='\033[1;33m'
RESET='\033[0m'

print_blue() {
  local message=$1
  echo -e "${BLUE_BOLD}${message}${RESET}"
}

print_green() {
  local message=$1
  echo -e "${GREEN}${message}${RESET}"
}

print_red() {
  local message=$1
  echo -e "${RED}${message}${RESET}"
}

print_yellow() {
  local message=$1
  echo -e "${YELLOW}${message}${RESET}"
}

if [ -z "$1" ]; then
  print_red "Please provide a search term."
  exit 1
fi

search_term=$1

if [ ! -f "$history_file" ]; then
  print_red "History file not found."
  exit 1
fi

matches=$(grep "$search_term" "$history_file" | grep -v "^$script_prefix" | tac | awk '!seen[$0]++' | head -5)

if [ -z "$matches" ]; then
  print_red "No matches found for '$search_term'."
  exit 1
fi

commands=()
counter=1

print_blue "Recent unique commands matching '$search_term':"
while IFS= read -r line; do
  # number should be bold, the cmd should be regular text
  echo -e "${BOLD_GRAY}${counter}.${RESET} ${line}"
  commands+=("$line")
  counter=$((counter + 1))
done <<< "$matches"

# Pressing enter is slower, this is supposed to be super fast and convenient. No need to press enter
print_yellow "Select a command number (1-${#commands[@]}), or press 0 or 'c' to cancel:"

while true; do
  read -n 1 -s choice
  case $choice in
    [1-5])
      if [[ $choice -ge 1 && $choice -le ${#commands[@]} ]]; then
        selected_command="${commands[$((choice-1))]}"

        # since we're not requiring anything but a number to execute, make sure the cmd isnt too dangerous
        for dangerous_command in "${dangerous_commands[@]}"; do
          if [[ $selected_command =~ ^$dangerous_command ]]; then
            print_red "\nThis command is potentially destructive: $selected_command"
            read -p "$(print_yellow 'Press Enter to confirm and any other key to cancel: ')" -n 1 -s confirm
            if [ -z "$confirm" ]; then
              print_green "\nExecuting: $selected_command"
              eval "$selected_command"
              # Add the executed command as the most recent in history without prefix
              echo "$selected_command" >> "$history_file"
            else
              print_red "\nCancelled. Exiting."
            fi
            exit 0
          fi
        done

        # execute with no confirming if the cmd isnt dangerous
        print_green "\nExecuting: $selected_command"
        # Add the executed command as the most recent in history without prefix
        echo "$selected_command" >> "$history_file"
        eval "$selected_command"
        break
      fi
      ;;
    0 | c | C)
      print_red "\nCancelled. Exiting."
      exit 0
      ;;
    *)
      print_red "\nInvalid selection. Please choose a valid number or press 0/c to cancel."
      ;;
  esac
done

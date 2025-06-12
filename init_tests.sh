#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\e[1m'
NC='\033[0m' # No Color

separator() {
	echo -e "${YELLOW}------------------------------------------------------------${NC}"
}

heading() {
	echo -e "\n${YELLOW}==> $1${NC}"
}

result_ok() {
	echo -e "${GREEN}[ OK ]${NC} $1"
}

result_fail() {
	echo -e "${RED}${BOLD}[FAIL]${NC} $1"
}

todo(){
	echo -e "  ${BLUE}${BOLD}TODO: ${NC}$1"
}

set -e

echo -e "\n${YELLOW}${BOLD}============ Ubuntu VM Setup Verification Script for WiSH 2025 ============${NC}"
date
echo -e "\n${YELLOW}${BOLD}#### SECTION 1: Hardware Info ####${NC}"

# Disk Space
heading "Disk Space on '/'"
df -h / | awk 'NR==1 || NR==2'

# Memory Status
heading "Memory Status"
free -h

# CPU Info
heading "CPU Info"
lscpu | grep -E 'Model name|CPU\(s\):|Thread|Core'

# Uptime
heading "System Uptime"
uptime -p


echo -e "\n${YELLOW}${BOLD}#### SECTION 2: System Tests ####${NC}"


# Internet connectivity
heading "Checking Internet Connectivity"
if (curl google.com &> /dev/null); then
	result_ok "curl is working"
elif (ping -c 1 8.8.8.8 &> /dev/null); then
	result_ok "ping is working"
else
	result_fail "Internet not working (neither ping nor curl)"
fi

# DNS resolution
heading "Checking DNS Resolution"
host google.com &> /dev/null && result_ok "DNS is working (resolved google.com)" || result_fail "DNS resolution failed"


# Essential Packages
heading "Checking Essential Packages"
ESSENTIAL_PACKAGES=(git python vim gvim iverilog gtkwave code libreoffice gh riscv32-unknown-elf-gcc)
for pkg in "${ESSENTIAL_PACKAGES[@]}"; do
	if command -v "$pkg" >/dev/null 2>&1; then
		echo -e " - ${pkg}: ${GREEN}Installed${NC}"
	else
		echo -e " - ${pkg}: ${RED}NOT Installed${NC}"
	fi
done

# Shared folder
heading "Checking shared folder access"
if !(groups $USER | grep -qw "vboxsf"); then
	result_fail "User '$USER' is NOT in vboxsf group"
	todo "Run command ${PURPLE}sudo adduser \$USER vboxsf${NC}"
else
	result_ok "User '$USER' is in vboxsf group"
	if !(id | grep -qw "vboxsf"); then
		result_fail "Group membership is not active"
		todo "Restart Virtual Machine's Ubuntu"
	else
		result_ok "Group membership is active"
		if !(mount | grep -q "vboxsf"); then
			result_fail "No shared folder is mounted"
			todo "Mount atleast one folder :: In VirtualBox: Go to settings -> Shared Folders -> Add a folder and enable 'Auto-mount' and 'Make Permanent'"
		else
			result_ok "Following folders are mounted"
			mount | grep vboxsf | while read -r line; do
				name=$(echo "$line" | cut -d' ' -f1)
				path=$(echo "$line" | cut -d' ' -f3)
				options=$(echo "$line" | grep -oP '\(.*\)' | tr -d '()')
				testfile="$path/.vbox_write_test"
				if touch "$testfile" 2>/dev/null; then
					ro=""
					rm "$testfile"
				else
					ro="[ READ-ONLY ]"
				fi
				echo -e "         - ${GREEN}${BOLD}$name${NC} : mounted at ${CYAN}$path${NC} ${BOLD}$ro${NC}"
			done

		fi
	fi
fi

# Python venv test
heading "Python virtual environment sanity check"

REQ_PY_VER="3.12"
REQ_PKG=(cocotb)
VENV_DIR="/home/wishuser/wish_venv"

if [ ! -d "$VENV_DIR" ]; then
	result_fail "Virtual environment NOT found at ${VENV_DIR}"
else
	result_ok "Virtual environment found :: ${BOLD}Path for venv:${NC} ${CYAN}${VENV_DIR}${NC}"
	ACTIVATE_FILE="$VENV_DIR/bin/activate"
	if [ ! -f "$ACTIVATE_FILE" ]; then
		result_fail "Activation script not found"
	else
		ACTIVATE_SCRIPT="source $ACTIVATE_FILE"
		$ACTIVATE_SCRIPT
		if [ -z "$VIRTUAL_ENV" ]; then
			result_fail "Failed to activate virtual environment"
		else
			result_ok "Activated virtual environment :: ${BOLD}Command to activate venv: ${PURPLE}$ACTIVATE_SCRIPT${NC}"
			if ! python --version &> /dev/null; then
				result_fail "Python is not functioning"
			else
				ENV_PY_VER=$(python --version 2>&1 | awk '{print $2}' | cut -d. -f1,2)
				if [[ $REQ_PY_VER != $ENV_PY_VER ]]; then
					result_fail "Wrong python version installed ($ENV_PY_VER), required ($REQ_PY_VER)"
				else
					result_ok "Python $ENV_PY_VER installed"
					for pkg in "${REQ_PKG[@]}"; do
						if ! pip show "$pkg" &> /dev/null; then
							echo -e "         ${RED}${BOLD}[ NOT FOUND ]${NC} Python package :: $pkg"
						else
							echo -e "         ${GREEN}[ FOUND ]    ${NC} Python package :: $pkg"

						fi
					done
					deactivate
					result_ok "Deactivating virtual environment :: ${BOLD}Command to deactivate venv: ${PURPLE}deactivate${NC}"
				fi
			fi
		fi
	fi
fi

# Course material directory test
heading "Checking course material"

LAB_DIR="/home/wishuser/wish25-course"
if [ -d $LAB_DIR ]; then
	result_ok "Course content found :: ${BOLD}Path for course content${NC} ${CYAN}$LAB_DIR${NC}"
	echo "Trying to update..."
	cd $LAB_DIR
	if GIT_ASKPASS=true git ls-remote &>/dev/null; then
		git pull origin master &>/dev/null
		result_ok "Updated"
	#else
	#	result_fail "Login required"
	fi
else
	result_fail "Course content NOT found at $LAB_DIR"
fi

echo -e ""
separator
date
echo -e "${YELLOW}Setup check complete.${NC}\n"


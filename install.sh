#!/usr/bin/env bash
set -Eeuo pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RESET='\033[0m'

info()  { printf "${GREEN}[INFO]${RESET} %s\n" "$*"; }
warn()  { printf "${YELLOW}[WARN]${RESET} %s\n" "$*"; }
die() {
       	printf "${RED}[ERROR]${RESET} %s\n" "$*" >&2
	exit 1
}

trap 'die "Failed on line $LINENO"' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/packages.sh"

main() {
	info "Updating package database"
	sudo apt update
	sudo apt full-upgrade -y

	install_packages
	install_ghostty
	install_fonts
	configure_services

	info "Done"
}

main "$@"

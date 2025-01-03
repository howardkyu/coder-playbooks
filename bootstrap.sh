#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

declare -r CODER_PLAYBOOKS_REPO="https://github.com/howardkyu/coder-playbooks"
declare -r BRANCH_NAME="${BRANCH_NAME:-main}"

function get_os_type() {
    uname
}

function get_linux_distro() {
    lsb_release -a | grep "Distributor ID" | awk -F':\t*' '{print $2}'
}

function initialize_os_linux() {
    # Install brew
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
}

function initialize_os_ubuntu() {
    # Install brew's Ubuntu dependencies
    sudo apt-get install build-essential
}

function initialize_os_env() {
    local ostype
    ostype="$(get_os_type)"

    echo "Detected OS type as ${ostype}"
    if [ "${ostype}" == "Linux" ]; then
        initialize_os_linux

        local linux_distro
        linux_distro="$(get_linux_distro)"
        echo "Detected Linux distro as ${linux_distro}"
        if [ "${linux_distro}" == "Ubuntu" ]; then
            initialize_os_ubuntu
        else
            echo "Invalid Linux distro: ${linux_distro}" >&2
            exit 1
        fi
    else
        echo "Invalid OS type: ${ostype}" >&2
        exit 1
    fi
}

function clone_repo() {
    rm -rf /tmp/coder-playbooks
    git clone --branch "${BRANCH_NAME}" "${CODER_PLAYBOOKS_REPO}" /tmp/coder-playbooks
}

function install_brew_deps() {
    brew install ansible
}

function main() {
    initialize_os_env
    clone_repo
    install_brew_deps
}

main

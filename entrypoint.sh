#!/bin/bash

readonly CLI_VERSION="${1:?Error: Please set CLI version}"
readonly AUTH="${2:?Error: Please set your API token}"
readonly APP="${3:?Error: Please set your application name}"
readonly CONTAINER="${4:?Error: Please set your container name}"
readonly IMAGE="${5:?Error: Please set your image like this = image:tag}"

if [ "$6" != "default" ]; then
  readonly NS="-n $6"
else
  readonly NS=""
fi

print_header() {
    printf "%s\n" "* * * * * * * * * * * * * * * * * * * * *"
    printf "%s\n" "*                                       *"
    printf "%s\n" "*   Welcome to ArvanCloud PaaS Action   *"
    printf "%s\n" "*                                       *"
    printf "%s\n" "* * * * * * * * * * * * * * * * * * * * *"
    printf "%s\n\n" ""
}

print_error() {
    printf " -----> Error: %s\n" "$1"
}

validate_arguments() {
    local errors=0
    for arg in "$@"; do
        if [ -z "$arg" ]; then
            print_error "Empty argument"
            (( errors ++ ))
        fi
    done
    return "$errors"
}

get_data() {
    printf " -----> Get data\n"
    printf "CLI version: %s\n" "$CLI_VERSION"
    printf "API token: %s\n" "$AUTH"
    printf "Namespace: %s\n" "$6"
    printf "Application name: %s\n" "$APP"
    printf "Container name: %s\n" "$CONTAINER"
    printf "Image: %s\n" "$IMAGE"
}

create_directory() {
    printf " -----> Create directory\n"
    mkdir -p /service
}

download_cli_tool() {
    printf " -----> Download ArvanCloud CLI tool version: %s\n" "$CLI_VERSION"
    wget -q "https://github.com/arvancloud/cli/releases/download/v${CLI_VERSION}/arvan_${CLI_VERSION}_linux_amd64.tar.gz" -O - | tar -xz -C /service/
}

login() {
    printf " -----> Login\n"
    /service/arvan login <<< "$AUTH"
}

deploy() {
    printf " -----> Deploy\n"
    /service/arvan paas ${NS} set image deployment ${APP} ${CONTAINER}=${IMAGE}
}

main() {
    set -e
    print_header
    validate_arguments "$@" || exit
    get_data
    create_directory
    download_cli_tool
    login
    deploy
}

main "$@"

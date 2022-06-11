#!/bin/bash 

set -e

# function print help
function print_help() {
    echo "Usage: $0 <region> <env> <command>"
    echo "  -r, --region <region>"
    echo "  -e, --env <env>"
    echo "  -c, --command <command>"
}


# function parser command line arguments
function parse_args() {
    while [[ $# -gt 0 ]]; do
        key="$1"

        case $key in
            -r|--region)
                REGION="$2"
                shift # past argument
                ;;
            -e|--env)
                ENV="$2"
                shift # past argument
                ;;
            -c|--command)
                COMMAND="$2"
                shift # past argument
                ;;
            -h|--help)
                print_help
                exit 1
                ;;
            *)
                # unknown option
                print_help
                exit 1
                ;;
        esac
        shift # past argument or value
    done
}

parse_args $@

# condition check command equal to "destroy" then ask for confirmation
if [ "$COMMAND" == "destroy" ]; then
    echo "Are you sure you want to destroy the environment $ENV in region $REGION?"
    read -p "Enter 'y' to continue: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Destroy environment $ENV in region $REGION"
    else
        echo "Abort"
        exit 1
    fi
fi

set -x 

cd ./aws/$REGION/$ENV
if [ $COMMAND == "destroy" ]; then
  for module in eks-cluster vpc; do
  	cd $module
	terragrunt run-all $COMMAND --terragrunt-non-interactive || true
	cd -
  done;
else
  terragrunt run-all $COMMAND --terragrunt-exclude-dir=ssm --terragrunt-non-interactive
fi


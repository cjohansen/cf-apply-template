#!/bin/bash

setArgs () {
    while [ "$1" != "" ]; do
        case $1 in
            "--stack-name")
                shift
                stack_name=$1
                ;;
            "--parameters")
                shift
                parameters=$1
                ;;
            "--tags")
                shift
                tags=$1
                ;;
            "--template-body")
                shift
                template=$1
                ;;
            "--profile")
                shift
                profile=$1
                ;;
            "--region")
                shift
                region=$1
                ;;
        esac
        shift
    done
}

setArgs $*

describe_args="--stack-name $stack_name"

if [ ! -z $profile ]; then
    describe_args="$describe_args --profile $profile"
fi

if [ ! -z $region ]; then
    describe_args="$describe_args --region $region"
fi

aws cloudformation describe-stacks $describe_args > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Updating stack"
    command="update-stack"
else
    echo "Creating stack"
    command="create-stack"
fi

template_hash=$(echo $(shasum ${template:7:${#template}} | awk '{ print $1 }'))
input_hash=$(echo $(echo "$parameters$tags$stack_name$region" | shasum --text | awk '{ print $1 }'))

aws cloudformation $command --client-request-token=$template_hash$input_hash $*

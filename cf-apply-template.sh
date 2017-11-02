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

addTags () {
    local tags="$1"
    shift
    local res=""
    local has_tags=0

    while [ "$1" != "" ]; do
        res="$res $1"

        if [ "$1" == "--tags" ]; then
            has_tags=1
            res="$res $2 $tags"
            shift
        fi

        shift
    done

    if [ $has_tags -eq 0 ]; then
        res="$res --tags $tags"
    fi

    echo $res
}

setArgs $*

describe_args="--stack-name $stack_name"

if [ ! -z $profile ]; then
    describe_args="$describe_args --profile $profile"
fi

if [ ! -z $region ]; then
    describe_args="$describe_args --region $region"
fi

description=`aws cloudformation describe-stacks $describe_args 2> /dev/null`

if [ $? -eq 0 ]; then
    echo "Updating stack"
    command="update-stack"
else
    echo "Creating stack"
    command="create-stack"
fi

template_hash=$(echo $(shasum ${template:7:${#template}} | awk '{ print $1 }'))
input_hash=$(echo $(echo "$parameters$tags$stack_name$region" | shasum --text | awk '{ print $1 }'))
crt="$template_hash$input_hash"
current_crt=`echo "$description" | jq -r '.Stacks[0].Tags[] | select(.Key=="ClientRequestToken").Value'`

if [ "$crt" == "$current_crt" ]; then
    echo "Current version is up to date, nothing to do"
    exit 0
else
    args=`addTags "Key=ClientRequestToken,Value=$crt" $*`
    echo "aws cloudformation $command $args"
fi

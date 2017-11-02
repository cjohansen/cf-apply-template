# cf-apply-template

A wrapper script that can be called like `aws cloudformation create-stack`
and/or `aws cloudformation update-stack`, and that uses `create-stack` if the
stack does not exist, and `update-stack` otherwise.

The script also computes a hash of your parameters, stack name, template body,
tags (if any), and region (if any) and tags your stack with it. Subsequent
updates will not be applied if the computed hash is the same as the tag on the
current version of the stack.

## Assumptions

The scripts assume that you pass the body template as a file URL, e.g.:

```sh
./cf-apply-template.sh --template-body file://path/to/file.yml
```

It makes no attempt to understand non-file URL template bodies.

The script also assumes all arguments are passed in as `--key value`, no equals
sign.

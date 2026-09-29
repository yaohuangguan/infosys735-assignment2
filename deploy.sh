#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
REGION="${AWS_REGION:-us-east-1}"
STACK="${STACK_NAME:-anygroupllc-a2}"
DIR="$(cd "$(dirname "$0")" && pwd)"
aws cloudformation validate-template --region "$REGION" --template-body "file://$DIR/template.yaml" >/dev/null
aws cloudformation deploy --region "$REGION" --stack-name "$STACK" --template-file "$DIR/template.yaml" --no-fail-on-empty-changeset
aws cloudformation describe-stacks --region "$REGION" --stack-name "$STACK" --query 'Stacks[0].Outputs' --output table

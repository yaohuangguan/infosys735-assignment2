#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/scripts/load-env.sh"
load_lab_env "$DIR/.env"
REGION="${AWS_REGION:-us-east-1}"
STACK="${STACK_NAME:-anygroupllc-a2}"
BUCKET=$(aws cloudformation describe-stacks --region "$REGION" --stack-name "$STACK" --query 'Stacks[0].Outputs[?OutputKey==`ForecastBucket`].OutputValue' --output text 2>/dev/null || true)
if [ -n "$BUCKET" ] && [ "$BUCKET" != "None" ]; then
  aws s3 rm "s3://$BUCKET" --recursive --region "$REGION" || true
fi
aws cloudformation delete-stack --region "$REGION" --stack-name "$STACK"
aws cloudformation wait stack-delete-complete --region "$REGION" --stack-name "$STACK"
echo "Deleted $STACK"

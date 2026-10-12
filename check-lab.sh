#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/load-env.sh
source "$DIR/scripts/load-env.sh"
load_lab_env "$DIR/.env"
export PATH="$HOME/.local/bin:$PATH"
REGION="${AWS_REGION:-us-east-1}"
if ! command -v aws >/dev/null; then
  echo "AWS CLI not installed or not on PATH" >&2
  exit 1
fi
if aws sts get-caller-identity --region "$REGION" --query Account --output text >/dev/null; then
  echo "PASS: AWS Learner Lab credentials are valid for region $REGION."
else
  echo "FAIL: AWS credentials missing/expired. Start the Lab, update .env, and retry." >&2
  exit 1
fi

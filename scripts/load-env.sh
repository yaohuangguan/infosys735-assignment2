#!/usr/bin/env bash
# Safely parse project .env OR AWS Academy's pasted [default] CLI snippet.
# Do not source/eval the file: AWS credentials should always be treated as data.
load_lab_env() {
  local file="${1:?path to .env is required}"
  [[ -f "$file" ]] || return 0

  local line key value
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    case "$line" in ''|'#'*|'['*']') continue ;; esac
    # Support both "KEY=VALUE" and "export KEY=VALUE".
    if [[ "$line" == export\ * ]]; then
      line="${line#export }"
    fi
    if [[ "$line" != *=* ]]; then
      printf 'Invalid .env line (expected KEY=VALUE); check your local .env format.\n' >&2
      return 1
    fi
    key="${line%%=*}"
    value="${line#*=}"
    key="${key%"${key##*[![:space:]]}"}"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    if [[ "$value" == \"*\" || "$value" == \'*\' ]]; then
      value="${value:1:${#value}-2}"
    fi
    # Empty placeholders must not mask pre-existing valid AWS CLI credentials.
    [[ -n "$value" ]] || continue
    case "$key" in
      AWS_ACCESS_KEY_ID|aws_access_key_id) export AWS_ACCESS_KEY_ID="$value" ;;
      AWS_SECRET_ACCESS_KEY|aws_secret_access_key) export AWS_SECRET_ACCESS_KEY="$value" ;;
      AWS_SESSION_TOKEN|aws_session_token) export AWS_SESSION_TOKEN="$value" ;;
      AWS_REGION|AWS_DEFAULT_REGION|region) export AWS_REGION="$value" ;;
      STACK_NAME) export STACK_NAME="$value" ;;
      ALARM_EMAIL) export ALARM_EMAIL="$value" ;;
      FORECAST_WAIT_SECONDS) export FORECAST_WAIT_SECONDS="$value" ;;
      *) printf 'Ignoring unrecognized .env field: %s\n' "$key" >&2 ;;
    esac
  done < "$file"

  # Fail safely when the file contains only part of a 3-key temporary session.
  if [[ -n "${AWS_ACCESS_KEY_ID:-}${AWS_SECRET_ACCESS_KEY:-}${AWS_SESSION_TOKEN:-}" ]]; then
    if [[ -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" || -z "${AWS_SESSION_TOKEN:-}" ]]; then
      printf 'AWS Learner Lab requires all three values: access key, secret key, session token.\n' >&2
      return 1
    fi
  fi
}

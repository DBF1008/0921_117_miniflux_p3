#!/bin/sh
# Unit test script: build, vet, format check, and run all unit tests.
#
# Usage: ./test.sh
#
# Optional environment variables:
#   GOTEST_FLAGS  Extra flags passed to "go test" (default: -cover -race -count=1)

set -e

cd "$(dirname "$0")"

echo "==> go build ./..."
go build ./...

echo "==> go vet ./..."
go vet ./...

echo "==> gofmt check"
# The repository uses CRLF line endings, so compare gofmt output
# after normalizing line endings instead of using "gofmt -l" directly.
UNFORMATTED=""
NORMTMP=$(mktemp)
trap 'rm -f "$NORMTMP"' EXIT
for file in $(find . -name '*.go' -not -path './.git/*'); do
	tr -d '\r' < "$file" > "$NORMTMP"
	if ! gofmt "$NORMTMP" | cmp -s - "$NORMTMP"; then
		UNFORMATTED="$UNFORMATTED $file"
	fi
done
if [ -n "$UNFORMATTED" ]; then
	echo "Unformatted files:$UNFORMATTED" >&2
	exit 1
fi

echo "==> go test ${GOTEST_FLAGS:--cover -race -count=1} ./..."
# shellcheck disable=SC2086
go test ${GOTEST_FLAGS:--cover -race -count=1} ./...

echo "==> All checks passed"

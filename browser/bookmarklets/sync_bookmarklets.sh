#!/bin/bash

# Sync bookmarklet source files with README.md

set -o nounset
set -o errexit
set -o pipefail

TARGET="${1:-README.md}"

gawk -i inplace 'BEGIN { bookmarklet = 0 }
# Filter existing content
match($0, /^<!-- BOOKMARKLET=(.*) -->$/, m) {
  bookmarklet = 1
  print
  print "```javascript"
  print "javascript:(function(){"
  while ( (getline<m[1]) > 0) { print }
  close(m[1])
  print "})()"
  print "```"
}
/^<!-- \/BOOKMARKLET -->$/ { bookmarklet = 0 }
# Print everything else
{ if (!bookmarklet) { print } }' "$TARGET"

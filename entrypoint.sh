#!/bin/bash

if [[ "$*" == "" ]]; then
	echo "Please specify paths in your repo to run Perl Critic on"
	exit 1
fi

echo "Getting checks"
PAYLOAD=$(echo '{}' | jq -nc --arg name "perlcritic results" --arg sha "$GITHUB_SHA" --arg status "in_progress" '. | .name = $name | .head_sha = $sha | .status = $status')
CHECK=$(curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/json" --header "Accept: application/vnd.github.antiope-preview+json" --data "$PAYLOAD" "https://api.github.com/repos/$GITHUB_REPOSITORY/check-runs")
CHECKID=$(jq ".id" <<< "$CHECK")
if [ -z "$CHECKID" ]; then
	echo "No check created. Result: $CHECK"
	exit 1
fi

echo "Created check $CHECKID"

echo "Testing Perl code"
violations=$(perlcritic --nocolor --quiet --verbose "%f[>]%l[>]%c[>]%s[>]%m[>]%e[>]%d[[END]]" $*)
success=$?

CHECK_URL="https://api.github.com/repos/$GITHUB_REPOSITORY/check-runs/$CHECKID"

conclusion="success"
if [ $success -ne 0 ]; then
	conclusion="failure"
    ANNOTATIONS=$(jq -nc -Rn '
( [inputs] | add | split("[[END]]") ) |
map(split("[>]")) |
map(try({"path": .[0], "start_line": .[1] | tonumber, "end_line": .[1] | tonumber, "annotation_level": "failure", "title": .[4], "message": .[5], "raw_details": .[6] }))
' <<< "$violations")
    jq -nc "[inputs] | .[0] | _nwise(50)" <<< "$ANNOTATIONS" |
	while IFS=$"\n" read -r c; do
    	OUTPUT=$(echo '{}' | jq -nc --arg title "perlcritic failed" --arg summary "perlcritic failed with errors" --argjson annotations "$c" '. | .title = $title | .summary = $summary | .annotations = $annotations')
    	PAYLOAD=$(echo '{}' | jq -nc --arg status "in_progress" --arg conclusion "failure" --argjson output "$OUTPUT" '. | .status = $status | .conclusion = $conclusion | .output = $output')
    	echo "Pushing batch of annotations ..."
    	curl -s -S -X PATCH -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/json" --header "Accept: application/vnd.github.antiope-preview+json" --data "$PAYLOAD" "$CHECK_URL" > /dev/null
	done;
fi

echo "Pushing payload to $CHECK_URL"
PAYLOAD=$(echo '{}' | jq -nc --arg status "completed" --arg conclusion "$conclusion" '. | .status = $status | .conclusion = $conclusion')
curl -s -S -X PATCH -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/json" --header "Accept: application/vnd.github.antiope-preview+json" --data "$PAYLOAD" "$CHECK_URL"  > /dev/null

exit 0
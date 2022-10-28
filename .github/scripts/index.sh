#!/bin/bash

# This script generates the readme for the repo by combining the readme_header markdown content
# with the appended index of sli content

README_HEADER_PATH="readme_header.md"
OUTPUT_FILE="readme.md"
CODEBUNDLE_PATH="./codebundles"

# Add readme content from readme_header
README_HEADER_CONTENT=$(cat $README_HEADER_PATH)
echo "$README_HEADER_CONTENT" > $OUTPUT_FILE
echo -e "\n" >> $OUTPUT_FILE


# set markdown headers
echo "## Codebundle Index" >> $OUTPUT_FILE
echo "| Folder Name | Type | Path | Documentation |" >> $OUTPUT_FILE
echo "|---|---|---|---|" >> $OUTPUT_FILE

# Build array of all codebundle .robot files
mapfile -d $'\0' codebundle_index < <(find $CODEBUNDLE_PATH -name "*.robot" -print0 | sort -z)

# create simple markdown table
for file in ${codebundle_index[@]}
    do 
        IFS='/' read -ra path_split <<< ${file}
        docstring=$(cat ${file} | grep Documentation | head -1 | sed s/"Documentation"//)
        if [[ ${path_split[3]} = "sli" || ${path_split[3]} = "sli.robot" ]]; then
        echo "| ${path_split[2]} | SLI | [sli.robot](${file}) | $docstring |" >> $OUTPUT_FILE

        elif  [[ ${path_split[3]} = "slo" || ${path_split[3]} = "slo.robot" ]]; then
        echo "| ${path_split[2]} | SLO | [slo.robot](${file}) | $docstring |" >> $OUTPUT_FILE

        elif  [[ ${path_split[3]} = "runbook" || ${path_split[3]} = "runbook.robot" ]]; then
        echo "| ${path_split[2]} | TaskSet | [runbook.robot](${file}) | $docstring |" >> $OUTPUT_FILE

        fi    
done
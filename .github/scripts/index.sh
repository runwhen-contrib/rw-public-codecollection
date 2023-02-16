#!/bin/bash

# This script generates the readme for the repo by combining the readme_header markdown content
# with the appended index of sli content

README_HEADER_PATH="readme_header.md"
OUTPUT_FILE="README.md"
CODEBUNDLE_PATH="./codebundles"

# Add readme content from readme_header
README_HEADER_CONTENT=$(cat $README_HEADER_PATH)
echo "$README_HEADER_CONTENT" > $OUTPUT_FILE
echo -e "\n" >> $OUTPUT_FILE


# set markdown headers
echo "## Codebundle Index" >> $OUTPUT_FILE
# echo "| Folder Name | Type | Path | Documentation | Use-Cases |" >> $OUTPUT_FILE
 echo "| Folder Name | Type | Path | Documentation | " >> $OUTPUT_FILE
# echo "| Folder Name | Type | Path | Documentation |" >> $OUTPUT_FILE
# echo "|---|---|---|---|---|" >> $OUTPUT_FILE
echo "|---|---|---|---|" >> $OUTPUT_FILE


# Build array of all codebundle .robot files
mapfile -d $'\0' codebundle_index < <(find $CODEBUNDLE_PATH -name "*.robot" -print0 | sort -z)

# create simple markdown table
for file in ${codebundle_index[@]}
    do 
        IFS='/' read -ra path_split <<< ${file}
        docstring=$(cat ${file} | grep Documentation | head -1 | sed s/"Documentation"//)
        readme_ref="${path_split[0]}/${path_split[1]}/${path_split[2]}/README.md"
        path_ref="${path_split[0]}/${path_split[1]}/${path_split[2]}/"
        sli_use_cases=$(cat ${readme_ref} | grep "Use Case: SLI" | sed 's/#* //' | sed 's/$/<br>/' | sed 's/Use Case: SLI:/**Use Case**:/')
        sli_use_cases=$(echo $sli_use_cases)
        taskset_use_cases=$(cat ${readme_ref} | grep "Use Case: TaskSet" | sed 's/#* //' | sed 's/$/<br>/' | sed 's/Use Case: TaskSet:/**Use Case**:/')
        taskset_use_cases=$(echo $tasket_use_cases)

        if [[ ${path_split[3]} = "sli" || ${path_split[3]} = "sli.robot" ]]; then
        echo "| [${path_split[2]}](${path_ref}) | SLI | [sli.robot](${file}) | $docstring<br>$sli_use_cases |" >> $OUTPUT_FILE

        elif  [[ ${path_split[3]} = "slo" || ${path_split[3]} = "slo.robot" ]]; then
        echo "| [${path_split[2]}](${path_ref}) | SLO | [slo.robot](${file}) | $docstring |" >> $OUTPUT_FILE

        elif  [[ ${path_split[3]} = "runbook" || ${path_split[3]} = "runbook.robot" ]]; then
        echo "| [${path_split[2]}](${path_ref}) | TaskSet | [runbook.robot](${file}) | $docstring<br>$taskset_use_cases | ">> $OUTPUT_FILE
        fi    

done
#!/bin/bash

source /etc/cloudshark.conf

cloudshark_url=${CLOUDSHARK_URL}
api_token=${CLOUDSHARK_API}
filename=${1}

cloudshark_upload() {

  response=$(curl -s -F file="@${filename}" ${cloudshark_url}/api/v1/${api_token}/upload)
  json_id=$(echo $response | python -m json.tool | grep id)

  if [ "$json_id" != "" ]; then
    # find the CloudShark ID for this session
    id=`echo $json_id | sed 's/:/ /1' | awk -F" " '{ print $2 }'| sed 's/\"//g'`

    # show a URL using the capture session in CloudShark
    echo "${cloudshark_url}/captures/$id"
  else
    echo -n "Could not upload capture to CloudShark:"
    echo $response | python -m json.tool
  fi
}

cloudshark_search() {
  name=$(basename ${filename})
  existing_id=$(curl -s -XGET "${cloudshark_url}/api/v1/${api_token}/search?search\[filename\]=${name}" | python -m json.tool | grep \"id\" | head -n 1 | sed 's/\"id\": \"//g;s/\"\,//g'| tr -d '[:space:]')
}

cloudshark_delete() {
  res=$(curl -s -XPOST "${cloudshark_url}/api/v1/${api_token}/delete/${existing_id}")
}

# Search for file with same name being uploaded
cloudshark_search

# If found delete it
if [ "$existing_id" != "" ]; then
  cloudshark_delete ${existing_id}
fi

# Upload new file
cloudshark_upload

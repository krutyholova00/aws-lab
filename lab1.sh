#!/bin/bash
#Create a project folder
# mkdir -p ~/$(whoami)/s3 && cd $_

BUCKET_NAME=kris-super-bucket-v1
REGION=us-east-2
PATH_TO_BUCKET_POLICY=/home/vladyslav/Rostik/Lab1/bucket_policy.json
CIDR_DENY="50.31.252.0/24"
INDEX_FILE=index.html
ERROR_FILE=error.html
PATH_TO_FOLDER=/home/vladyslav/Rostik/Lab1
URL=http://$BUCKET_NAME.s3-website.$REGION.amazonaws.com
MESSAGE="Ups...Please check out URL!!!\nYour status code: "
GET_STATUS_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" $URL)

PROC=chrome

echo '{
  "Id": "Policy1602322036956",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1602321977754",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::'$BUCKET_NAME'/*",
      "Principal": "*"
    },
    {
      "Sid": "IPAllow",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": "arn:aws:s3:::'$BUCKET_NAME'/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "'$CIDR_DENY'"
        }
      },
      "Principal": "*"
    }
  ]
}' > /$PATH_TO_FOLDER/bucket_policy.json

#aws s3 rm s3://"$BUCKET_NAME" \
aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION  --create-bucket-configuration LocationConstraint=$REGION  \
  &&  aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://$PATH_TO_BUCKET_POLICY  \
  &&  aws s3 sync /$PATH_TO_FOLDER s3://$BUCKET_NAME/  \
  &&  aws s3 website s3://$BUCKET_NAME/ --index-document $INDEX_FILE --error-document $ERROR_FILE \
  && sleep 3 \
  &&  if [[ $(curl -o /dev/null -s -w "%{http_code}\n" $URL) -eq "200" ]]; then
        nohup $1  --disable-setuid-sandbox $URL
      else 
          echo -e " $URL \n $MESSAGE \n $GET_STATUS_CODE"
     fi
exit

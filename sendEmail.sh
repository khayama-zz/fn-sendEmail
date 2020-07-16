#!/bin/bash
ARGS=$@
SL_USER=`echo "$ARGS" | jq -r '."SL_USER"'`
SL_APIKEY=`echo "$ARGS" | jq -r '."SL_APIKEY"'`
TO=`echo "$ARGS" | jq -r '."TO"'`
FROM=`echo "$ARGS" | jq -r '."FROM"'`
SUBJECT=`echo "$ARGS" | jq -r '."SUBJECT"'`
BODY=`echo "$ARGS" | jq -r '."BODY"'`

SENDGRID_ID=`curl -u "$SL_USER:$SL_APIKEY" -X GET 'https://api.softlayer.com/rest/v3.1/SoftLayer_Account/getNetworkMessageDeliveryAccounts.json' | jq -r '.[]|.id'`

curl -v -i -u "$SL_USER:$SL_APIKEY" \
-X POST \
-H "Content-Type: application/json" \
-d @- "https://api.softlayer.com/rest/v3.1/SoftLayer_Network_Message_Delivery_Email_Sendgrid/$SENDGRID_ID/sendEmail" > /tmp/result.txt << EOS
{"parameters": [{"body":"$BODY","from":"$FROM","to":"$TO","subject":"$SUBJECT"}]}
EOS

if [ $? -ne 0 ]; then
  echo "ERROR" > /tmp/result.txt
  exit 1
fi

RESULT=$(cat /tmp/result.txt)

echo "{ \
\"args\": $ARGS, \
\"result\": $(RESULT="$RESULT" jq -n 'env.RESULT') \
}"

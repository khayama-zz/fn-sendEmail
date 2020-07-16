#!/bin/bash
ARGS=$@
SL_USER=`echo "$ARGS" | jq -r '."SL_USER"'`
SL_APIKEY=`echo "$ARGS" | jq -r '."SL_APIKEY"'`
TO=`echo "$ARGS" | jq -r '."TO"'`
SUBJECT=`echo "$ARGS" | jq -r '."SUBJECT"'`
BODY=`echo "$ARGS" | jq -r '."BODY"'`

SENDGRID_ID=`curl -u "$SL_USER:$SL_APIKEY" -X GET 'https://api.softlayer.com/rest/v3.1/SoftLayer_Account/getNetworkMessageDeliveryAccounts.json' | jq -r '.[]|.id'`

curl -v -i -u "$SL_USER:$SL_APIKEY" \
-X POST "https://api.softlayer.com/rest/v3.1/SoftLayer_Network_Message_Delivery_Email_Sendgrid/$SENDGRID_ID/sendEmail.json" \
-H "Content-Type: application/json" \
-d '{"parameters": [{"body":"'$BODY'","from":"no-reply@ibmfunctions.com","to":"'$TO'","subject":"'$SUBJECT'"}]}' > /tmp/result.txt

if [ $? -ne 0 ]; then
  echo "ERROR" > /tmp/result.txt
  exit 1
fi

RESULT=$(cat /tmp/result.txt)

echo "{ \
\"args\": $ARGS, \
\"result\": $(RESULT="$RESULT" jq -n 'env.RESULT') \
}"

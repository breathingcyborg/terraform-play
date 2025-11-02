endpoint=$(terraform output --raw "api_gateway_endpoint")

curl -H "Authorization: Bearer 1" -X POST "${endpoint}/seed"

curl -H "Authorization: Bearer 1" "${endpoint}/todos?userId=1"

curl -X POST "${endpoint}/todos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer 1" \
  -d '{"todo":"New task from curl","userId":1}'

curl -H"Authorization: Bearer 1" "${endpoint}/todos/1"

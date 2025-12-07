set -e

cd ./ecs

endpoint="https://$(terraform output -raw domain_name)/"
echo "endpoint: " $endpoint;

minutes=3
parallel_requests=3

start_time=$(date +%s)
end_time=$(($start_time + 60*$minutes))

while true; do
  
  # seq $parallel_requests
  #   generate sequence of $parallel_request items
  # xargs -P $parallel_requests -I{}  
  #   -P parallel calls to make
  #   -I{} replace {} with input in command 
  #     since we dont have {} in command 
  #     we are basically telling xargs to ignore the input/argument
  #   curl -o /dev/null -s $endpoint 
  #        execute command for each arg
  echo "sending requests"
  seq $parallel_requests | \
    xargs -P $parallel_requests -I{} curl -o /dev/null -s $endpoint

  current_time=$(date +%s)
  if (($current_time >= $end_time)); then
    echo "done"
    break;
  fi
done
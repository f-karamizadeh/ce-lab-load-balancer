#!/bin/bash

# Define Variables
ALB_DNS="web-alb-1091871660.eu-north-1.elb.amazonaws.com"

echo "=== 1. Testing Basic Connectivity ==="
curl -i "http://${ALB_DNS}/"

echo -e "\n\n=== 2. Testing Health Check Endpoint ==="
curl -i "http://${ALB_DNS}/health"

echo -e "\n\n=== 3. Testing Traffic Distribution (20 Requests) ==="
for i in {1..20}; do
  curl -s "http://${ALB_DNS}/" | grep "Instance:" | sed 's/.*Instance: //'
done | sort | uniq -c

echo -e "\n=== Test Complete ==="

# Load Distribution Test Results

## Overview
This test evaluates how evenly the Application Load Balancer (ALB) distributes incoming HTTP requests across 3 EC2 instances deployed in 2 Availability Zones.


## Test Execution
A script executed 20 consecutive HTTP GET requests to the ALB DNS endpoint.
```bash
fkara@BOOK-G10VPP3E38 CLANGARM64 ~/.ssh
$ for i in {1..20}; do
  curl -s http://$ALB_DNS | grep "Instance:" | sed 's/.*Instance: //'
done | sort | uniq -c
      8 i-09d0e8dc48d9c77b7</p>
      6 i-0cda47840261428f8</p>
      6 i-0f6ceaed2caff7088</p>
```

## Summary
The distribution is balanced properly across all healthy instances using the default round-robin / least outstanding requests algorithm.
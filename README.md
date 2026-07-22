# Lab M3.03 - AWS Application Load Balancer with Health Checks

## Architecture Overview
This project deploys a high-availability web application using an AWS Application Load Balancer (ALB) distributing traffic across 3 EC2 instances deployed in 2 Availability Zones (AZs).

- Name: Faramarz Karamizadeh

------------
```
[ Internet Client ]
                                     │
                                     ▼
                         [ Application Load Balancer ]
                         (Public Subnets: 1a, 1b)
                                     │
               ┌─────────────────────┼─────────────────────┐
               ▼                     ▼                     ▼
          [ EC2 Instance 1 ]    [ EC2 Instance 2 ]    [ EC2 Instance 3 ]
          (AZ: us-east-1a)      (AZ: us-east-1a)      (AZ: us-east-1b)
            
 ```         



## Security Group Configuration

| Security Group | Inbound Rules | Source | Description |
| :--- | :--- | :--- | :--- |
| **`alb-sg`** | HTTP (80) | `0.0.0.0/0` | Allows public access to ALB |
| **`web-servers-sg`** | HTTP (80) | `alb-sg` | Restricts direct access; allows traffic only from ALB |

---

---

## Testing Methodology and Results

To ensure the Application Load Balancer operates correctly under normal and fault conditions, two primary testing phases were executed:

### Traffic Distribution Test
* **Objective:** Verify that the ALB balances requests evenly across all healthy instances using the default round-robin routing algorithm.
* **Methodology:** Executed a loop sending 20 automated HTTP `GET` requests to the ALB DNS endpoint and logged the responding Instance ID.

  ---

### Failover Scenario Documentation
Objective: Validate that the ALB detects an unhealthy instance quickly and stops sending traffic to it without disrupting user experience.



---

## Target Group & Health Check Settings

| Parameter | Value | Rationale |
| :--- | :--- | :--- |
| **Protocol / Port** | HTTP / 80 | Standard web server traffic |
| **Health Check Path** | `/health` | Isolated endpoint returning application health status |
| **Check Interval** | 10 seconds | Quick detection of instance failures |
| **Timeout** | 5 seconds | Prevents long waits on unresponsive instances |
| **Healthy Threshold** | 2 consecutive checks | Fast recovery validation |
| **Unhealthy Threshold** | 2 consecutive checks | Enables rapid failover (20 seconds total) |

---

## Reflection Answers

| Question | Answer |
| :--- | :--- |
| **1. How does the ALB know if an instance is healthy?** | The ALB sends periodic HTTP GET requests to the defined `/health` endpoint. If the target returns HTTP `200 OK` within the timeout window for the specified threshold count, it is marked healthy. |
| **2. What happens when an instance fails a health check?** | The ALB changes its status to `unhealthy` and stops routing new traffic to it. Requests are immediately redistributed to remaining healthy targets. |
| **3. Why deploy instances across multiple AZs?** | Multi-AZ deployment protects against data center outages. If an entire AWS Availability Zone fails, the ALB continues serving traffic from instances in other AZs. |
| **4. What is the purpose of the `/health` endpoint?** | It isolates health verification from main web content, allowing app-level checks (e.g., verifying database or cache connections) rather than just network reachability. |
| **5. How & when to implement sticky sessions?** | Implemented using Target Group attributes (`stickiness.enabled`). Useful for legacy apps storing session state in server memory rather than a shared database. |

---
### Best Practices Learned:
- Spreading targets across multiple AZs ensures zero downtime if an entire AWS zone experiences an outage.
- Web servers should never accept direct internet traffic. The server Security Group must only accept inbound traffic on port 80 from the alb-sg ID.
- Using a standalone /health endpoint avoids clogging application logs and allows lightweight status reporting without heavy database queries.
-  Setting low thresholds (Interval: 10s, Unhealthy Threshold: 2) ensures failover completes in 20 seconds instead of the 2-3 minute defaults.
- Enabling deregistration delay allows active HTTP requests to complete gracefully before an instance is terminated or detached.

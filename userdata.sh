#!/bin/bash
#create userdata.sh in your laptop and copy the following code into it. Then, when you launch your EC2 instance, specify this file as the user data script.
set -e

# Update packages and install Node.js + Git
yum update -y
yum install -y nodejs git

# Create the Node.js application
cat > /home/ec2-user/server.js <<'EOF'
const http = require('http');
const os = require('os');
const { execSync } = require('child_process');

// Get IMDSv2 token
function getToken() {
 try {
  return execSync(
   'curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"'
  ).toString().trim();
 } catch (err) {
  return null;
 }
}

const token = getToken();

// Get metadata using IMDSv2
function getMetadata(path) {
 try {
  if (token) {
   return execSync(
    `curl -s -H "X-aws-ec2-metadata-token: ${token}" http://169.254.169.254/latest/meta-data/${path}`
   ).toString().trim();
  }

  // Fallback to IMDSv1 if available
  return execSync(
   `curl -s http://169.254.169.254/latest/meta-data/${path}`
  ).toString().trim();
 } catch (err) {
  return 'unknown';
 }
}

const INSTANCE_ID = getMetadata('instance-id');
const AZ = getMetadata('placement/availability-zone');

let requestCount = 0;

const server = http.createServer((req, res) => {
 requestCount++;

 // Health check endpoint
 if (req.url === '/health') {
  res.writeHead(200, {'Content-Type': 'application/json'});
  res.end(JSON.stringify({
   status: 'healthy',
   instance: INSTANCE_ID,
   az: AZ,
   uptime: process.uptime()
  }));
  return;
 }

 // Main page
 res.writeHead(200, {'Content-Type': 'text/html'});
 res.end(`
<!DOCTYPE html>
<html>
<head>
 <title>Load Balanced App</title>
 <style>
  body {
   font-family: Arial;
   text-align: center;
   padding: 50px;
   background: #f0f0f0;
  }
  .container {
   background: white;
   padding: 40px;
   border-radius: 10px;
   box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  }
  .instance {
   color: #007bff;
   font-size: 24px;
   font-weight: bold;
  }
  .az {
   color: #28a745;
   font-size: 18px;
  }
 </style>
</head>
<body>
 <div class="container">
  <h1>:rocket: Cloud Engineering Bootcamp</h1>
  <h2>Load Balanced Application</h2>
  <p class="instance">Instance: ${INSTANCE_ID}</p>
  <p class="az">Availability Zone: ${AZ}</p>
  <p>Hostname: ${os.hostname()}</p>
  <p>Request count handled: ${requestCount}</p>
 </div>
</body>
</html>
 `);
});

server.listen(80, () => {
 console.log(`Server running on port 80 (Instance: ${INSTANCE_ID}, AZ: ${AZ})`);
});
EOF

# Start the application
cd /home/ec2-user
nohup node server.js > server.log 2>&1 &
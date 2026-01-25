#!/bin/bash

# Set strict error handling
set -euo pipefail

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Error handling function
error_exit() {
    log "ERROR: $1"
    exit 1
}

log "Starting user data script execution"

# Update package index and install required packages
log "Updating package index"
if ! sudo dnf update -y; then
    error_exit "Failed to update package index"
fi

log "Installing Apache web server"
if ! sudo dnf install -y httpd; then
    error_exit "Failed to install Apache"
fi

# Start and enable Apache web server
log "Starting and enabling Apache"
if ! sudo systemctl start httpd; then
    error_exit "Failed to start Apache"
fi

if ! sudo systemctl enable httpd; then
    error_exit "Failed to enable Apache"
fi

# Create a simple HTML file with instance metadata
log "Creating HTML page"
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>AWS Terraform Workshop</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            text-align: center;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
        }
        .container {
            margin-top: 40px;
            padding: 30px;
            background-color: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            color: #333;
        }
        h1 {
            color: #232f3e;
            margin-bottom: 30px;
            font-size: 2.5em;
        }
        .aws-color {
            color: #ff9900;
            font-weight: bold;
        }
        .metadata-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        .metadata-item {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            border-left: 4px solid #ff9900;
        }
        .metadata-label {
            font-weight: bold;
            color: #666;
            font-size: 0.9em;
        }
        .metadata-value {
            font-size: 1.1em;
            margin-top: 5px;
            word-break: break-all;
        }
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            color: #666;
            font-size: 0.9em;
        }
        .status {
            background: #28a745;
            color: white;
            padding: 10px 20px;
            border-radius: 20px;
            display: inline-block;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="status">🚀 Server Status: Running</div>
        <h1>Hello from <span class="aws-color">AWS</span> Terraform Workshop</h1>
        <p style="font-size: 1.2em; color: #666;">This server was provisioned using Infrastructure as Code with Terraform.</p>
        
        <div class="metadata-grid">
            <div class="metadata-item">
                <div class="metadata-label">Instance ID</div>
                <div class="metadata-value" id="instance-id">Loading...</div>
            </div>
            <div class="metadata-item">
                <div class="metadata-label">Availability Zone</div>
                <div class="metadata-value" id="availability-zone">Loading...</div>
            </div>
            <div class="metadata-item">
                <div class="metadata-label">Instance Type</div>
                <div class="metadata-value" id="instance-type">Loading...</div>
            </div>
            <div class="metadata-item">
                <div class="metadata-label">Public IP</div>
                <div class="metadata-value" id="public-ip">Loading...</div>
            </div>
        </div>
        
        <div class="footer">
            <p>🔧 Managed with Terraform | 📊 Monitored with CloudWatch</p>
            <p>Last updated: <span id="timestamp"></span></p>
        </div>
    </div>

    <script>
        // Fetch instance metadata
        async function fetchMetadata() {
            const metadataEndpoints = {
                'instance-id': '/latest/meta-data/instance-id',
                'availability-zone': '/latest/meta-data/placement/availability-zone',
                'instance-type': '/latest/meta-data/instance-type',
                'public-ip': '/latest/meta-data/public-ipv4'
            };

            for (const [id, endpoint] of Object.entries(metadataEndpoints)) {
                try {
                    const response = await fetch(\`http://169.254.169.254\${endpoint}\`);
                    const text = await response.text();
                    document.getElementById(id).textContent = text;
                } catch (error) {
                    document.getElementById(id).textContent = 'Unavailable';
                }
            }
            
            // Set timestamp
            document.getElementById('timestamp').textContent = new Date().toLocaleString();
        }

        // Load metadata when page loads
        fetchMetadata();
    </script>
</body>
</html>
EOF

# Set proper permissions
log "Setting file permissions"
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html

# Install CloudWatch agent for monitoring
log "Installing CloudWatch agent"
if ! sudo dnf install -y amazon-cloudwatch-agent; then
    error_exit "Failed to install CloudWatch agent"
fi

# Create basic CloudWatch agent configuration
log "Configuring CloudWatch agent"
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "metrics": {
        "append_dimensions": {
            "InstanceId": "\$\${aws:InstanceId}"
        },
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "diskio": {
                "measurement": [
                    "io_time"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start CloudWatch agent
log "Starting CloudWatch agent"
sudo systemctl enable amazon-cloudwatch-agent
sudo systemctl start amazon-cloudwatch-agent

log "User data script execution completed successfully"
exit 0

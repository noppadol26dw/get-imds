# get-imds

A bash script to query AWS Instance Metadata Service (IMDS) and return JSON formatted output for getting instance information without complex setup.

## What This Does

This script helps you get information about your EC2 instance in a clean JSON format. Whether you need the instance ID, region, or any other metadata.

## Features

- **No dependencies** - Just bash and curl
- **JSON output** - Clean, structured data
- **Individual keys** - Get specific metadata
- **IMDS v1 & v2** - Works with both versions
- **Simple** - Only 2 functions and simple to call each function.

## Quick Start
**Clone the repository:** on your local machine
   ```bash
   git clone https://github.com/noppadol26dw/get-imds.git
   cd get-imds
   ```

### Get All Metadata
```bash
./get-imds.sh
```

### Get Specific Information
```bash
./get-imds.sh instance-id
./get-imds.sh placement/region
./get-imds.sh instance-type
```

## Installation



## Usage Examples

### Basic Usage
```bash
# Get all metadata as JSON
./get-imds.sh

# Get instance ID only
./get-imds.sh instance-id

# Get region
./get-imds.sh placement/region

# Get instance type
./get-imds.sh instance-type
```

### With JSON Formatting
```bash
# Pretty print JSON (requires jq)
./get-imds.sh | jq
./get-imds.sh instance-id | jq
```

## Common Metadata Keys

| Key | Description |
|-----|-------------|
| `instance-id` | Your instance ID |
| `ami-id` | AMI ID used to launch |
| `instance-type` | Instance type (t2.micro, etc.) |
| `placement/region` | AWS region |
| `security-groups` | Security groups |
| `public-ipv4` | Public IP address |
| `local-ipv4` | Private IP address |
| `mac` | MAC address |
| `hostname` | Instance hostname |

## Testing on EC2

### 1: Create Test Instance
```bash
# Create an EC2 instance for testing
# All instruction will show.

./create-test-instance.sh
```

## Output Examples

### All Metadata
```json
{
  "instance-id": "i-1234567890abcdef0",
  "ami-id": "ami-0abcdef1234567890",
  "instance-type": "t2.micro",
  "placement/region": "us-east-1",
  "security-groups": "default",
  "public-ipv4": "54.123.45.67",
  "local-ipv4": "10.0.1.100"
}
```

### Specific Key
```json
{
  "instance-id": "i-1234567890abcdef0"
}
```

## How It Works

1. **Tries IMDS v2 first**: More secure with token authentication
2. **Falls back to v1**:If v2 fails, uses v1 (no token needed)
3. **Returns JSON**:Clean, structured output
4. **Handles errors**: Clear error messages for invalid keys

## Requirements

- Bash shell
- `curl` command
- Running on an EC2 instance
- (Optional) `jq` for JSON formatting

## Troubleshooting

### "Not running on an EC2 instance"
- Make sure you're running this on an EC2 instance
- Check that IMDS is accessible: `curl http://169.254.169.254/latest/meta-data/`

### "Key not found"
- Check the key name is correct
- Use `./get-imds.sh` to see all available keys

### JSON formatting issues
- Install jq: `sudo yum install -y jq`
- Or use online JSON formatters

## Security Notes

- Uses IMDS v2 by default (more secure)
- Falls back to v1 if needed
- No credentials stored or transmitted
- Only queries local metadata service
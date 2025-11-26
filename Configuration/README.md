# Configuration Files

This directory contains environment-specific configuration files for the Starling app.

## Setup for Local Development

1. **Copy the template files:**
   ```bash
   cp Debug.xcconfig.template Debug.xcconfig
   cp Release.xcconfig.template Release.xcconfig
   ```

2. **Add your credentials:**
   - Open `Debug.xcconfig`
   - Replace `YOUR_SANDBOX_TOKEN_HERE` with your Starling Bank sandbox API token
   - Save the file

3. **Never commit secrets:**
   - The `.xcconfig` files are already in `.gitignore`
   - Only commit the `.template` files

## CI/CD Setup

### Option 1: Environment Variables (Recommended)

In your CI/CD pipeline (GitHub Actions, GitLab CI, etc.), inject values:

```bash
# Create Debug.xcconfig from environment variables
cat > Configuration/Debug.xcconfig << EOF
STARLING_API_TOKEN = ${STARLING_SANDBOX_TOKEN}
STARLING_CERTIFICATES = starling-sandbox-api-certificate
STARLING_BASE_URL = https://api-sandbox.starlingbank.com
EOF
```

### Option 2: Encrypted Secrets

Use your CI platform's secret management:
- **GitHub Actions:** Repository Secrets
- **GitLab CI:** CI/CD Variables
- **Bitrise:** Secrets
- **Fastlane:** `.env` files with `fastlane-plugin-secret`

### Example GitHub Actions

```yaml
- name: Setup Configuration
  env:
    SANDBOX_TOKEN: ${{ secrets.STARLING_SANDBOX_TOKEN }}
  run: |
    sed 's/YOUR_SANDBOX_TOKEN_HERE/'"$SANDBOX_TOKEN"'/g' \
      Configuration/Debug.xcconfig.template > Configuration/Debug.xcconfig
```

## Configuration Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `STARLING_API_TOKEN` | API authentication token | `eyJhbGci...` |
| `STARLING_CERTIFICATES` | SSL pinning certificate names | `starling-sandbox-api-certificate` |
| `STARLING_BASE_URL` | API base URL | `https://api-sandbox.starlingbank.com` |

## Security Best Practices

✅ **DO:**
- Keep `.xcconfig` files in `.gitignore`
- Use environment-specific tokens (sandbox vs production)
- Rotate tokens regularly
- Use CI/CD secret management
- Document required variables in templates

❌ **DON'T:**
- Commit actual tokens to git
- Share tokens in Slack/email
- Use production tokens in development
- Hardcode tokens in source code
- Store tokens in screenshots or logs

## Troubleshooting

### "Configuration file not found" error
- Make sure you copied the template files and removed `.template`
- Check that files are in `Configuration/` directory

### "Invalid token" error
- Verify token is correct in `.xcconfig`
- Check for extra spaces or newlines
- Ensure token hasn't expired

### Build fails in CI
- Verify environment variables are set in CI
- Check that the token injection script runs before build
- Ensure `.xcconfig` files are created before Xcode build step

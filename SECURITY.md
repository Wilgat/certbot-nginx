# Security Policy

## Supported Versions
Only the latest version of `certbot-nginx` (from the `main` branch) is supported.

## Reporting a Vulnerability
If you discover a security vulnerability in this project, please report it responsibly.

**Preferred way:**
- Open a **private vulnerability report** on GitHub (if available), or
- Contact the maintainer directly via GitHub Issues with the title:  
  **"[Security] Vulnerability Report"**

Please include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

We will acknowledge your report within 48 hours and aim to address critical issues as quickly as possible.

## Security Considerations
`certbot-nginx` is a shell script that runs with **root privileges**.  
Before running it, we strongly recommend:

1. Review the full script content yourself:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/Wilgat/certbot-nginx/main/certbot-nginx | less
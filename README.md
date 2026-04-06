# certbot-nginx

[![Version](https://img.shields.io/badge/Version-1.8.0-blue?style=flat-square)](https://github.com/Wilgat/certbot-nginx)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

**Automated, defensive setup for Nginx + Let's Encrypt + Cloudflare origin protection**

A single-file, self-installing shell script that configures Nginx with free Let's Encrypt SSL certificates and **restricts all traffic to Cloudflare IPs only**.

Ideal for GitLab, self-hosted services, APIs, or any application running behind Cloudflare Proxy (orange cloud).

---

## ✨ Features

- One-command installation: `curl | sudo bash`
- Fully interactive setup with **explicit user choice** of the primary/main domain
- Automatic Let's Encrypt certificate issuance using `--standalone` (clean separation from Nginx)
- One certificate covering main domain + multiple SANs
- **Strong Cloudflare-only origin protection** (`deny all;` + official IP ranges)
- Persistent storage of email and domain list (`/etc/letsencrypt/`)
- **JSON mode** for scripting and automation (`--json`)
- Rich diagnostic sub-commands with clean output
- Regenerate Nginx configs only (`nginx-conf`) without touching certificates
- Self-update and self-uninstall
- Works as non-root for read-only commands (`domains`, `email`, `about`)
- Defensive coding style — survives minimal shells, interrupted runs, and edge cases

---

## 📋 Prerequisites

- Root/sudo access for full setup
- Domains with A/AAAA records pointing to your server
- **Cloudflare Proxy (orange cloud)** enabled on all domains (for IP restriction to work)
- Ports 80 and 443 open in your firewall

### Supported Platforms

| OS Family                  | Support     | Notes                              |
|---------------------------|-------------|------------------------------------|
| Ubuntu / Debian           | ★★★★★      | Best tested, recommended           |
| Alpine Linux              | ★★★★★      | Excellent for containers           |
| Fedora / Rocky / RHEL     | ★★★★☆      | Good (EPEL may be needed)          |
| openSUSE                  | ★★★☆☆      | Basic support                      |
| macOS (Homebrew)          | ★★★☆☆      | Installs, limited service control  |
| Git Bash / Windows        | Not recommended | Use WSL2 (Ubuntu)               |

---

## 🚀 Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/Wilgat/certbot-nginx/main/certbot-nginx | sudo bash
```

Then run the interactive setup:

```bash
sudo certbot-nginx
```

The script will:
1. Install Certbot + Nginx
2. Ask for your email and **primary domain**
3. Let you add extra domains (SANs)
4. Issue certificates (nginx is stopped during this step)
5. Generate secure Nginx configs with Cloudflare protection

---

## 📖 Commands & Options

### Main Commands

| Command                        | Description                                      |
|--------------------------------|--------------------------------------------------|
| `sudo certbot-nginx`           | Full interactive setup (recommended)             |
| `sudo certbot-nginx domains`   | Show saved domains (primary highlighted)         |
| `sudo certbot-nginx email`     | Show saved Let's Encrypt email                   |
| `sudo certbot-nginx nginx-conf`| Regenerate Nginx configs only                    |
| `sudo certbot-nginx about`     | Full diagnostics (version, shell, etc.)          |
| `sudo certbot-nginx version`   | Show script version                              |
| `sudo certbot-nginx version-check` | Compare with latest remote version            |
| `sudo certbot-nginx self-update` | Update to latest version                      |
| `sudo certbot-nginx self-uninstall` | Remove the script                           |

### Options

- `--quiet`, `-q` — Suppress all non-error messages
- `--json` — **Machine-readable JSON output** (implies `--quiet`). Perfect for scripts.
- `--no-cloudflare` — Disable Cloudflare IP restriction (open to all IPs)

### JSON Mode Examples

```bash
# Get domains as JSON
sudo certbot-nginx domains --json

# Get email
sudo certbot-nginx email --json

# Full diagnostics
sudo certbot-nginx about --json

# Parse with jq
sudo certbot-nginx domains --json | jq -r '.domains[]'
```

JSON output is consistent, compact, and includes fields like `type`, `domains`, `primary`, `count`, `email`, etc.

---

## 🔒 Cloudflare Origin Protection

By default the script:
- Adds official Cloudflare IPv4 + IPv6 ranges
- Enables `real_ip_header CF-Connecting-IP` so your backend sees real visitor IPs
- Uses `deny all;` → only Cloudflare traffic is allowed

**Result**: Direct access (bypassing Cloudflare) returns 403 Forbidden.

To temporarily disable for testing, use `--no-cloudflare` or comment the lines in the generated config.

---

## 📁 Generated Files

- `/etc/letsencrypt/email.conf`
- `/etc/letsencrypt/domains.conf` (main domain first)
- `/etc/nginx/cloudflare-ips.conf`
- `/etc/nginx/sites-available/<domain>.conf` + symlinks in `sites-enabled`
- `/var/www/<domain>/index.html` (placeholder page, owned by `www-data`)

---

## 🔄 Certificate Renewal

Recommended cron job (runs daily):

```bash
# /etc/cron.d/certbot-renew
0 3 * * * root certbot renew --quiet --standalone \
    --pre-hook "systemctl stop nginx" \
    --post-hook "systemctl restart nginx"
```

Or enable the built-in timer (if available):

```bash
sudo systemctl enable --now certbot.timer
```

---

## ⚠️ Important Notes

- Full setup requires an **interactive terminal** (TTY).
- Diagnostic commands (`domains`, `email`, `about`) work **without sudo**.
- The script uses `--standalone` (stops Nginx temporarily during issuance).
- First domain you choose becomes the **primary Common Name** of the certificate.
- Cloudflare proxy must be **enabled** for the IP restriction to function correctly.

---

## Why Defensive & Verbose?

The heavy comments, repeated checks, and "do not simplify" warnings are intentional. They protect against:
- Non-interactive shells
- Minimal environments (dash, ash)
- Interrupted runs
- Future "helpful" refactoring that could break reliability

This is the same philosophy used in other Wilgat tools.

---

## 📜 License

MIT License. See [LICENSE](LICENSE) for details.

---

## 🤝 Contributing

Contributions welcome! Especially:
- Support for more distributions
- Improved macOS service handling
- Common `proxy_pass` examples (GitLab, Docker, Node.js, etc.)
- Automatic Cloudflare IP range updates (optional)

---

Made with ❤️ for secure, simple, and reliable Nginx + Let's Encrypt setups behind Cloudflare.

**Repository**: https://github.com/Wilgat/certbot-nginx

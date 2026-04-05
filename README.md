# certbot-nginx

[![Version](https://img.shields.io/badge/Version-1.7.0-blue?style=flat-square)](https://github.com/Wilgat/countdown)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

**Automated setup for Nginx + Let's Encrypt + Cloudflare IP restriction**

A self-installing, defensive shell script that configures Nginx with free Let's Encrypt SSL certificates and restricts all traffic to **Cloudflare IP addresses only**.

Perfect for GitLab, self-hosted services, or any web application running behind Cloudflare proxy.

---

## ✨ Features

- One-command installation via `curl | sudo bash`
- Fully interactive setup with explicit main domain selection
- Automatic Let's Encrypt certificate issuance using `--standalone` mode
- Multi-domain support (one certificate covering main domain + SANs)
- **Strong Cloudflare-only origin protection** — direct access from other IPs is blocked
- Saves email and domains persistently for future runs
- Regenerate Nginx configs without re-issuing certificates (`nginx-conf`)
- Self-updating and self-uninstalling capabilities
- Clean JSON output mode for scripting (`--json`)
- Works as non-root for diagnostic commands (`email`, `domains`, `about`)

---

## 📋 Prerequisites

- **Root or sudo access** (required for full setup)
- Domains pointed to your server (A/AAAA records)
- **Cloudflare proxy (orange cloud)** enabled on all domains
- Ports 80 and 443 open (for certificate issuance and HTTPS)

### Supported Operating Systems

| Operating System                  | Package Manager | Support Level      | Notes |
|-----------------------------------|-----------------|--------------------|-------|
| **Ubuntu / Debian**               | apt             | Full ★★★★★        | Best tested, recommended |
| **Alpine Linux**                  | apk             | Full ★★★★★        | Lightweight environments |
| **Fedora / Rocky / CentOS / RHEL**| dnf / yum       | Full ★★★★☆        | Requires EPEL on some versions |
| **openSUSE**                      | zypper          | Partial ★★★☆☆     | Basic support |
| **macOS**                         | Homebrew        | Partial ★★★☆☆     | Installation works, limited service management |
| **Git Bash / MSYS2 (Windows)**    | -               | Not Supported ★☆☆☆☆ | Use WSL2 instead |
| **Native Windows**                | -               | Not Supported      | Use WSL2 (Ubuntu) |

> **Recommendation**: Ubuntu LTS or Debian is the most reliable platform for this script.

---

## 🚀 Quick Installation

```bash
curl -fsSL https://raw.githubusercontent.com/Wilgat/certbot-nginx/main/certbot-nginx | sudo bash
```

After installation, run the interactive setup:

```bash
sudo certbot-nginx
```

The script will guide you through:
1. Installing Certbot and Nginx
2. Choosing your **primary/main domain**
3. Adding additional domains (SANs)
4. Obtaining Let's Encrypt certificates
5. Setting up secure Nginx configuration with Cloudflare protection

---

## 📖 Usage

### Main Commands

| Command                          | Description |
|----------------------------------|-----------|
| `sudo certbot-nginx`             | Full interactive setup (recommended) |
| `sudo certbot-nginx --help`      | Show help |
| `sudo certbot-nginx email`       | Show saved Let's Encrypt email |
| `sudo certbot-nginx domains`     | Show saved domains (primary domain highlighted) |
| `sudo certbot-nginx nginx-conf`  | Regenerate Nginx configs only |
| `sudo certbot-nginx about`       | Show diagnostics and environment info |
| `sudo certbot-nginx version`     | Show script version |
| `sudo certbot-nginx self-update` | Update to latest version |
| `sudo certbot-nginx self-uninstall` | Remove the script |

### Options

- `--quiet`, `-q` — Suppress non-error output
- `--json` — Machine-readable JSON output (implies `--quiet`)
- `--no-cloudflare` — Not using cloudflare

---

## 🔒 Cloudflare IP Restriction

The script automatically:
- Creates `/etc/nginx/cloudflare-ips.conf` with official Cloudflare IPv4 and IPv6 ranges
- Configures `real_ip_header CF-Connecting-IP` and `real_ip_recursive on`
- Adds `include cloudflare-ips.conf;` + `deny all;` in every HTTPS server block

**Security Result**: Only traffic coming through Cloudflare is allowed. Direct access to port 443 is blocked (403 Forbidden).

> **Note**: Port 80 remains open for Let's Encrypt HTTP-01 challenges and HTTP → HTTPS redirect.

---

## 📁 Generated Files & Locations

- `/etc/letsencrypt/domains.conf` — List of managed domains (main domain first)
- `/etc/letsencrypt/email.conf` — Your Let's Encrypt email
- `/etc/nginx/cloudflare-ips.conf` — Official Cloudflare IP ranges
- `/etc/nginx/sites-available/*.conf` — Per-domain HTTPS configs
- `/var/www/<domain>/` — Basic placeholder index.html for each domain

---

## 🔄 Certificate Renewal

Certificates are valid for 90 days. Recommended renewal command:

```bash
# Run daily via cron
0 3 * * * root certbot renew --quiet --standalone \
    --pre-hook "systemctl stop nginx" \
    --post-hook "systemctl restart nginx"
```

Or enable Certbot's systemd timer if available:

```bash
systemctl enable --now certbot.timer
```

---

## ⚠️ Important Notes

- The full setup **requires root** and an interactive terminal (TTY).
- Diagnostic commands (`email`, `domains`, `about`) work without sudo.
- On macOS, nginx service management is limited (Homebrew does not use systemd).
- The script uses **standalone** mode for certificate issuance (temporarily stops Nginx).
- Cloudflare proxy **must** be enabled for the IP restriction to function correctly.
- First domain you enter becomes the **primary Common Name** of the certificate.

---

## 📜 License

Open source. Feel free to fork and modify.

---

## 🤝 Contributing

Pull requests are welcome! Especially for:
- Better support for more Linux distributions
- macOS service management improvements
- Adding common `proxy_pass` examples (GitLab, Docker, etc.)
- Automatic Cloudflare IP list updates

---

Made with ❤️ for secure, simple, and defensive Nginx + Let's Encrypt setups.

---

**Repository**: [https://github.com/Wilgat/certbot-nginx](https://github.com/Wilgat/certbot-nginx)

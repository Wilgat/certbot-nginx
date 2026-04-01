# certbot-nginx

**Automated setup for Nginx + Let's Encrypt + Cloudflare IP restriction**

A self-installing shell script that configures external Nginx with free Let's Encrypt SSL certificates and restricts all traffic to **Cloudflare IP addresses only**.

Perfect for GitLab, self-hosted services, or any web application running behind Cloudflare proxy.

---

## ✨ Features

- One-command installation via `curl | sudo bash`
- Fully interactive setup (or non-interactive basic install)
- Automatic Let's Encrypt certificate issuance using standalone mode
- Multi-domain support (one certificate for all domains)
- **Cloudflare-only access protection** — direct access from other IPs is blocked (403 Forbidden)
- Saves domains and email for easy re-runs
- Regenerate Nginx configs without re-issuing certificates
- Self-updating (can force reinstall the script itself)

---

## 📋 Prerequisites

- A Debian/Ubuntu-based server (tested on Ubuntu)
- Root or sudo access
- Domains pointed to your server (A/AAAA records)
- **Cloudflare proxy (orange cloud) enabled** on all domains
- Ports 80 and 443 open (for initial certificate issuance and HTTPS)

---

## 🚀 Quick Installation

```bash
curl -fsSL https://raw.githubusercontent.com/Wilgat/certbot-nginx/main/certbot-nginx | sudo bash
```

After installation, simply run:

```bash
sudo certbot-nginx
```

The script will guide you through domain selection and email setup.

---

## 📖 Usage

| Command                        | Description |
|-------------------------------|-----------|
| `sudo certbot-nginx`          | Run full interactive setup |
| `sudo certbot-nginx --help`   | Show all options |
| `sudo certbot-nginx --domains`| View saved domains |
| `sudo certbot-nginx --email`  | View saved Let's Encrypt email |
| `sudo certbot-nginx --nginx-conf` | Regenerate Nginx configs only |
| `sudo certbot-nginx --force-reinstall` | Force update the script itself |

---

## 🔒 Cloudflare IP Restriction

This script automatically:
- Creates `/etc/nginx/cloudflare-ips.conf` with current Cloudflare IPv4 and IPv6 ranges
- Enables `real_ip` module to get the real visitor IP via `CF-Connecting-IP` header
- Adds `allow` / `deny all;` rules in every HTTPS server block

**Result**: Only traffic coming through Cloudflare is allowed. Direct access to your server is blocked.

> **Note**: The restriction applies to port 443. Port 80 remains open for Let's Encrypt challenges.

---

## 📁 Generated Files

- `/etc/letsencrypt/domains.conf` — list of managed domains
- `/etc/nginx/letsencrypt-email.conf` — your Let's Encrypt email
- `/etc/nginx/cloudflare-ips.conf` — Cloudflare IP ranges
- Nginx configs in `/etc/nginx/sites-available/` and `sites-enabled/`

---

## 🔄 Certificate Renewal

Certificates are valid for 90 days. Set up renewal manually (recommended):

```bash
# Example cron job (run daily)
0 3 * * * root certbot renew --quiet --standalone --pre-hook "systemctl stop nginx" --post-hook "systemctl restart nginx"
```

Or use Certbot's built-in systemd timer if available.

---

## ⚠️ Important Notes

- The script must run as **root**.
- First run requires interactive terminal (TTY).
- Cloudflare proxy must be enabled for the IP restriction to work correctly.
- The script uses **standalone** mode for certificate issuance (temporarily stops Nginx).

---

## 📜 License

This project is open source. Feel free to fork and modify.

---

## 🤝 Contributing

Pull requests are welcome! Especially for:
- Supporting more distributions
- Adding proxy_pass examples for GitLab
- Improving Cloudflare IP list auto-update

---

Made with ❤️ for secure and simple Nginx + Let's Encrypt setups.

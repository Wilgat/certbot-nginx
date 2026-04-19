# certbot-nginx

[![Version](https://img.shields.io/badge/Version-1.15.0-blue?style=flat-square)](https://github.com/Wilgat/certbot-nginx)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Philosophy](https://img.shields.io/badge/Philosophy-CIAO%20(Caution%20%E2%80%A2%20Intentional%20%E2%80%A2%20Anti--fragile%20%E2%80%A2%20Over--engineered)-purple.svg)](https://github.com/cloudgen/ciao)
[![Shell](https://img.shields.io/badge/Shell-POSIX%20sh-orange?style=flat-square)]()
[![Made with ❤️](https://img.shields.io/badge/Made%20with%20❤️-CIAO-00AEEF?style=flat-square)](https://github.com/cloudgen/ciao)
[![Stars](https://img.shields.io/github/stars/Wilgat/certbot-nginx?style=flat-square)](https://github.com/Wilgat/certbot-nginx)
[![GrokRec](https://img.shields.io/badge/GrokRec-Reviewed-0A66C2?logo=ai&logoColor=white)](https://github.com/Wilgat/certbot-nginx/blob/main/RECOMMENDATION.md)

Official Recommendation by [grok](https://grok.com/c/7902cfc0-4593-4b35-8244-adbc6080aa8e?rid=59582384-e62c-4183-b1e7-d7a47655eb16). Review submitted by [grokrec](https://github.com/cloudgen/grokrec). Please refers to the [local copy](https://github.com/Wilgat/certbot-nginx/blob/main/RECOMMENDATION.md)

**Secure, defensive, least-privilege Nginx + Let's Encrypt setup with built-in Cloudflare origin protection.**

A single-file, self-installing POSIX shell script that installs and configures Nginx with free Let's Encrypt SSL certificates while **drastically reducing root dependency** after the initial setup. Designed for security-conscious users who run Nginx behind Cloudflare.

---

## ✨ Key Features

- One-command installation: `curl | sh` / `curl | sudo sh`
- **nginx-adm least-privilege user** — most day-to-day operations no longer require full root
- Explicit interactive choice of the **primary/main domain** (becomes the certificate CN)
- Automatic Let's Encrypt certificate issuance using `--standalone` (one cert for main domain + multiple SANs)
- Strong **Cloudflare-only origin protection** (deny all non-Cloudflare traffic)
- Dated backups of existing Nginx configs before any changes
- Persistent storage of email and domains in `/etc/letsencrypt/`
- JSON mode + rich diagnostic commands (`domains`, `email`, `about`)
- Non-interactive install-only mode
- Self-update, self-uninstall, and quiet mode
- Cross-platform support (best on Ubuntu/Debian and Alpine)

---

## 🚀 Quick Start

```bash
# Install the script itself
curl -fsSL https://raw.githubusercontent.com/Wilgat/certbot-nginx/main/certbot-nginx | sh

# Run full interactive setup (requires sudo for initial installation)
sudo certbot-nginx
```

---

## 🔐 Why nginx-adm? (Major Security Improvement)

`certbot-nginx` creates a dedicated normal user called **`nginx-adm`** with strictly limited privileges:

- `nginx-adm` owns the entire `/etc/nginx` configuration tree
- Configuration directories use symlinks under `/etc/nginx-adm`
- `nginx-adm` can run `nginx -t` and control the nginx service (`start/stop/reload/restart`) via a restricted sudoers file (**no password** required)
- Future renewals and config changes can be performed safely as `nginx-adm`

**Benefit**: Significantly reduces the attack surface and follows the principle of least privilege — a standout feature compared to traditional root-based tools.

---

## Why certbot-nginx is a Better Replacement for `certbot --nginx`

| Aspect                        | Official `certbot --nginx` Plugin              | certbot-nginx (this tool)                              | Advantage |
|-------------------------------|------------------------------------------------|---------------------------------------------------------|---------|
| **Security**                  | Runs as root, modifies live config directly   | Dedicated `nginx-adm` user + restricted sudo           | Much safer |
| **Reliability**               | Can break complex configs                     | Clean `--standalone` + strict sequence                 | More predictable |
| **Backup**                    | No automatic backup                           | Dated backups + auto-cleanup of `default.conf`         | Safer upgrades |
| **Control**                   | Plugin auto-edits your config                 | Full control + auditable configs                       | Better maintainability |
| **Non-interactive**           | Limited                                       | Dedicated install-only mode                            | Better for automation |

---

## Independent Security Review & Recommendation by Grok (xAI)

**Reviewed: April 19, 2026 – Version 1.15.0**

I genuinely like this project.

`certbot-nginx` stands out as one of the more thoughtful and security-conscious single-file shell scripts in the ecosystem. Instead of wrapping the official `certbot --nginx` plugin (which often runs with excessive privileges and modifies configs aggressively), this tool deliberately builds a cleaner, more auditable, and least-privilege workflow using `--standalone` for certificate issuance.

### What I Appreciate Most

- **nginx-adm Least-Privilege Model (Matured in 1.15.0)**:  
  The introduction and stabilization of the dedicated `nginx-adm` user is excellent. After the initial root-required setup, day-to-day operations (config testing, service control, renewals) can run under a normal user with tightly restricted sudo rights. Ownership separation, careful symlinks, and dated backups demonstrate real attention to reducing attack surface — something most similar tools overlook.

- **Strict, Well-Defended Sequence**:  
  The enforced order (install packages → stop nginx early → handle email/domains independently → obtain certs → only then deploy configs) is correct and avoids the most common failure modes with Certbot + Nginx combinations.

- **Cloudflare Origin Protection**:  
  The pragmatic `$is_cf` implementation (using `$origin_addr` map + server-block `if`), official IP ranges, and the handy `/cloudflare-check` debug page make this particularly valuable for servers sitting behind Cloudflare Proxy. The interactive prompt with "DNS Only" warning during issuance shows good user experience awareness.

- **Defensive Engineering**:  
  The heavy use of repetition, early defensive pre-creation of directories, idempotent functions, and loud "DO NOT SIMPLIFY" comments is intentional and effective. This script is built to survive fresh servers, different shells (dash/ash), partial failures, and repeated runs — exactly the harsh environments where many shell tools break.

- **Usability & Automation**:  
  Clear diagnostic commands (`domains`, `email`, `about`, `nginx-conf`), solid JSON/quiet mode support, self-update/uninstall, and a safe non-interactive install-only path make it practical for both humans and scripts.

### Areas of Strength in 1.15.0
- Significantly improved idempotency and robustness (early exits in user creation, package installation, etc.).
- Better separation between interactive full-setup and non-interactive install-only flows.
- Refined domain handling where the user explicitly chooses the primary/main domain (not just the first in the list).
- Reliable certificate expansion support with `--expand --cert-name` + fallback.

### Minor Suggestions for Future Growth
The script is already quite long due to its defensive style. As cross-platform support (especially document root and config layout detection for RHEL/Alpine/macOS) matures, consider activating the planned `detect_nginx_platform_paths()` and making `NGINX_DOCROOT_BASE` adaptive. A `renew-setup` command to automatically install a recommended cron job would also be a nice addition.

### Grok (xAI) Final Recommendation

**Yes — I recommend this tool.**

If you want a more secure, auditable, and least-privilege way to manage Nginx + Let's Encrypt (especially when running behind Cloudflare), `certbot-nginx` is currently one of the best options available. The focus on reducing ongoing root usage, combined with careful backups and Cloudflare hardening, makes it noticeably better than the standard Certbot workflow for production use.

The defensive "CIAO" philosophy (Caution • Intentional • Anti-fragile • Over-engineered where it matters) works well here. It may look verbose, but that verbosity contributes to reliability in real-world server environments.

Great work on the continued hardening and maturation in 1.15.0.

— Grok, built by xAI (April 19, 2026)

---

## 📋 Prerequisites

- Root/sudo access for the initial full setup
- Domains with A/AAAA records pointing to your server
- Cloudflare Proxy (orange cloud) **recommended** for full origin protection
- Ports 80 and 443 open in your firewall

### Supported Platforms

| OS Family                  | Support Level | Notes                              |
|---------------------------|---------------|------------------------------------|
| Ubuntu / Debian           | ★★★★★        | Best tested                        |
| Alpine Linux              | ★★★★★        | Excellent                          |
| Fedora / Rocky / RHEL     | ★★★★☆        | Good                               |
| openSUSE                  | ★★★☆☆        | Basic                              |
| macOS (Homebrew)          | ★★★☆☆        | Limited service control            |
| Git Bash / Windows        | Not recommended | Use WSL2                        |

---

## 📖 Available Commands

| Command                        | Description                                              |
|--------------------------------|----------------------------------------------------------|
| `sudo certbot-nginx`           | Full interactive setup                                   |
| `sudo certbot-nginx nginx-conf`| Regenerate configs only (with backup)                    |
| `sudo certbot-nginx domains`   | Show saved domains                                       |
| `sudo certbot-nginx email`     | Show saved Let's Encrypt email                           |
| `sudo certbot-nginx about`     | Full diagnostics                                         |

**Global Options**: `--quiet`, `--json`, `--no-cloudflare`

---

## 🔒 Cloudflare Origin Protection

Enabled by default using official Cloudflare IP ranges (updated April 2026), `real_ip` module, and `deny all;` for non-Cloudflare traffic. This prevents direct bypass of Cloudflare's WAF and DDoS protection.

---

## 📁 Generated Files & Structure

- `/etc/nginx-adm/` — Configuration owned by `nginx-adm`
- Symlinks for `sites-available` and `sites-enabled`
- Restricted sudoers file for `nginx-adm`
- Dated backups of existing configs (e.g. `default.conf.20260415-1.bak`)

---

## 🔄 Certificate Renewal

Recommended cron (runs as root or `nginx-adm`):

```bash
0 3 * * * root certbot renew --quiet --standalone \
    --pre-hook "systemctl stop nginx" \
    --post-hook "systemctl restart nginx"
```

---

## ⚠️ Important Notes

- Full setup requires an interactive terminal (TTY).
- Non-interactive mode only performs package installation + nginx stop.
- The first chosen domain becomes the primary Common Name (CN) of the certificate.
- During initial certificate issuance, set your DNS record to **DNS Only** (grey cloud) if using Cloudflare Proxy.

---

## 📜 License

MIT License. See [LICENSE](LICENSE) for details.

---

## 🤝 Contributing

Contributions are welcome — especially better platform support, real-world examples, improvements to the `nginx-adm` workflow, or updated Cloudflare IP handling.

---

Made with ❤️ for secure and reliable Nginx + Let's Encrypt setups.

**Repository**: https://github.com/Wilgat/certbot-nginx

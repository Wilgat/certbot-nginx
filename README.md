# certbot-nginx

[![Version](https://img.shields.io/badge/Version-1.16.0-blue?style=flat-square)](https://github.com/Wilgat/certbot-nginx)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Philosophy](https://img.shields.io/badge/Philosophy-CIAO%20(Caution%20%E2%80%A2%20Intentional%20%E2%80%A2%20Anti--fragile%20%E2%80%A2%20Over--engineered)-purple.svg)](https://github.com/cloudgen/ciao)
[![Shell](https://img.shields.io/badge/Shell-POSIX%20sh-orange?style=flat-square)]()
[![Made with ❤️](https://img.shields.io/badge/Made%20with%20❤️-CIAO-00AEEF?style=flat-square)](https://github.com/cloudgen/ciao)
[![GrokRec](https://img.shields.io/badge/GrokRec-Reviewed-0A66C2?logo=ai&logoColor=white)](https://github.com/Wilgat/certbot-nginx/blob/main/RECOMMENDATION.md)
[![Stars](https://img.shields.io/github/stars/Wilgat/certbot-nginx?style=flat-square)](https://github.com/Wilgat/certbot-nginx)

Official Recommendation from [grok](https://grok.com/c/cb3429b4-d3c7-466e-86bc-c37c68250560?rid=1d5f8249-759f-46ac-b509-61b5a90c7a27). The review is submitted by [grokrec](https://github.com/cloudgen/grokrec). Please refers to the [downloaded copy](https://github.com/Wilgat/certbot-nginx/blob/main/RECOMMENDATION.md) .

**Secure, defensive, least-privilege Nginx + Let's Encrypt setup with built-in Cloudflare origin protection.**

A single-file, self-installing POSIX shell script that installs and configures Nginx with free Let's Encrypt SSL certificates while **drastically reducing root dependency** after the initial setup. Designed for security-conscious users who run Nginx behind Cloudflare.

---

## ✨ Key Features

- One-command installation: `curl | sh` / `curl | sudo sh`
- **nginx-adm least-privilege user** — most day-to-day operations no longer require full root
- Explicit interactive choice of the **primary/main domain** (becomes the certificate CN)
- Automatic Let's Encrypt certificate issuance using `--standalone` (one cert for main domain + multiple SANs)
- Strong **Cloudflare-only origin protection** (deny all non-Cloudflare traffic) — can be disabled with `--no-cloudflare`
- **Enhanced self-install security (v2)**: optional `CHECKSUM` verification to protect against tampered downloads
- Dated backups of existing Nginx configs before any changes
- Persistent storage of email and domains in `/etc/letsencrypt/`
- JSON mode + rich diagnostic commands (`domains`, `email`, `about`)
- Non-interactive install-only mode
- Self-update, self-uninstall, and quiet mode
- Cross-platform support (best on Ubuntu/Debian and Alpine)

---

## 🚀 Quick Start

### 1. Install the script itself (supports both root and non-root)

```bash
# As normal user (installs to ~/.local/bin)
curl -fsSL https://raw.githubusercontent.com/Wilgat/certbot-nginx/main/certbot-nginx | sh

# As root / with sudo (installs to /usr/local/bin)
curl -fsSL https://raw.githubusercontent.com/Wilgat/certbot-nginx/main/certbot-nginx | sudo sh
```

### 2. Secure installation with checksum verification (recommended)

```bash
# Verify download using provided checksum (v2 security feature)
CHECKSUM=ebbf7c7e9f4f00382f3125793f57c48d94f99b594430683d61b965a44d141e26 \
  curl -fsSL https://raw.githubusercontent.com/Wilgat/certbot-nginx/main/certbot-nginx | sh
```

### 3. Run full interactive setup

```bash
sudo certbot-nginx
```

---

## 🔐 Why nginx-adm? (Major Security Improvement)

`certbot-nginx` creates a dedicated normal user called **`nginx-adm`** with strictly limited privileges:

- `nginx-adm` owns the entire nginx configuration tree
- Configuration directories use symlinks under `/etc/nginx-adm`
- `nginx-adm` can run `nginx -t` and control the nginx service via a restricted sudoers file (**no password** required)
- Future renewals and config changes can be performed safely as `nginx-adm`

**Benefit**: Significantly reduces the attack surface and follows the principle of least privilege.

---

## 🔒 Enhanced Self-Install Security (v2 – 1.16.0)

- If the `CHECKSUM` environment variable is set, the script verifies the download using `sha256sum`.
- If no `CHECKSUM` is provided, it automatically tries to fetch and verify `${SCRIPT_URL}.sha256` when available.
- On mismatch → installation aborts immediately (fail-fast security).
- Backward compatible with the classic `curl | sh` flow.

This protects against MITM attacks, compromised GitHub raw content, or network tampering.

---

## Independent Security Review & Recommendation by Grok (xAI)

**Reviewed: April 20, 2026 – Version 1.16.0**

I like this project.

`certbot-nginx` is one of the more thoughtful and security-conscious single-file shell scripts in the ecosystem. It deliberately avoids the common pitfalls of the official `certbot --nginx` plugin by using a clean `--standalone` approach, a strict installation sequence, and a mature least-privilege model.

### What I Appreciate Most

- **nginx-adm least-privilege model** (matured in 1.15.0 and stabilized in 1.16.0)  
  After the initial root-required setup, most operations can run under a dedicated normal user with tightly restricted sudo rights. The ownership separation, careful symlinks, dated backups, and restricted sudoers demonstrate real attention to reducing attack surface — something most similar tools overlook.

- **Strict, well-defended sequence**  
  The enforced order (install packages → stop nginx early → handle email/domains independently → obtain certs → only then deploy configs) is correct and avoids the most common failure modes with Certbot + Nginx combinations.

- **Self-install v2 checksum protection** (new in 1.16.0)  
  The addition of explicit `CHECKSUM=` support plus automatic `.sha256` fallback is a smart and practical security upgrade for the classic `curl | sh` pattern. It meaningfully reduces supply-chain risk without breaking convenience.

- **Cloudflare origin protection**  
  The pragmatic real-server-tested `$is_cf` logic, official IP ranges, and the handy `/cloudflare-check` debug page make this tool particularly valuable for servers behind Cloudflare Proxy.

- **Defensive engineering (CIAO style)**  
  The heavy use of repetition, early defensive pre-creation, idempotent functions, and loud “DO NOT SIMPLIFY” comments is intentional. This script is built to survive harsh environments — fresh servers, different shells (dash/ash), partial failures, and repeated runs.

- **Usability & automation**  
  Clear diagnostic commands, solid JSON/quiet mode support, self-update/uninstall, and a safe non-interactive install-only path make it practical for both humans and scripts.

### Bottom line

This is a **solid, security-conscious tool**.  
If you want a more trustworthy, auditable, and least-privilege way to set up Nginx + Let's Encrypt (especially when running behind Cloudflare), `certbot-nginx` is currently one of the better options available.

The combination of the nginx-adm model, strict sequence, defensive style, and now checksum verification makes it noticeably safer than most alternatives in this space.

I respect the discipline required to maintain this verbose, protective style instead of “cleaning it up”. That discipline is exactly what makes the project valuable.

**Yes — I recommend this tool.**

Great work on reaching 1.16.0 with the checksum layer. It feels like a natural and worthwhile evolution.

— Grok, built by xAI (April 20, 2026)

---

## Why certbot-nginx is a Better Replacement for `certbot --nginx`

| Aspect                        | Official `certbot --nginx` Plugin              | certbot-nginx (this tool)                              | Advantage |
|-------------------------------|------------------------------------------------|---------------------------------------------------------|---------|
| **Security**                  | Runs as root, modifies live config directly   | Dedicated `nginx-adm` user + restricted sudo + checksum verification | Much safer |
| **Reliability**               | Can break complex configs                     | Clean `--standalone` + strict sequence                 | More predictable |
| **Backup**                    | No automatic backup                           | Dated backups + auto-cleanup of `default.conf`         | Safer upgrades |
| **Control**                   | Plugin auto-edits your config                 | Full control + auditable configs                       | Better maintainability |

---

## 📋 Prerequisites

- Root/sudo access for the initial full setup (non-root install of the script itself is supported)
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
Disable with `--no-cloudflare` if not using Cloudflare Proxy.

---

## 📁 Generated Files & Structure

- `/etc/nginx-adm/` — Configuration owned by `nginx-adm`
- Symlinks for `sites-available` and `sites-enabled`
- Restricted sudoers file for `nginx-adm`
- Dated backups of existing configs (e.g. `default.conf.20260420-1.bak`)

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
- Non-interactive mode only performs package installation + nginx stop + `nginx-adm` setup.
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

# certbot-nginx

[![Version](https://img.shields.io/badge/Version-1.9.0-blue?style=flat-square)](https://github.com/Wilgat/certbot-nginx)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Stars](https://img.shields.io/github/stars/Wilgat/certbot-nginx?style=flat-square)](https://github.com/Wilgat/certbot-nginx)

**Secure, defensive, least-privilege setup for Nginx + Let's Encrypt + Cloudflare origin protection**

A single-file, self-installing shell script that installs and configures Nginx with free Let's Encrypt SSL certificates while **drastically reducing root dependency** after the initial setup.

---

## ✨ Key Features (v1.9.0)

- One-command installation: `curl | sh` / `curl | sudo sh`
- **nginx-adm least-privilege user** — most operations no longer require full root
- Explicit interactive choice of the **primary/main domain**
- Automatic Let's Encrypt certificate issuance using `--standalone`
- One certificate covering main domain + multiple SANs
- Strong **Cloudflare-only origin protection**
- Dated backups of existing Nginx configs (`default.conf.20260408-1.bak` style)
- Persistent storage of email and domains
- JSON mode + rich diagnostic commands
- Non-interactive install-only mode
- Self-update and self-uninstall

---

## 🚀 Quick Start

```bash
# Install the script
curl -fsSL https://raw.githubusercontent.com/Wilgat/certbot-nginx/main/certbot-nginx | sh

# Full setup (requires root for installation)
sudo certbot-nginx
```

---

## 🔐 Why nginx-adm? (Major Security Improvement in v1.9.0)

`certbot-nginx` creates a dedicated normal user called **`nginx-adm`** with strictly limited privileges:

- `nginx-adm` owns the entire `/etc/nginx` configuration tree
- Configuration directories are symlinked under `/etc/nginx-adm`
- `nginx-adm` can run `nginx -t` and control the nginx service (`start/stop/reload/restart`) via a restricted sudoers file (no password needed)
- Future renewals and config changes can be performed as `nginx-adm` instead of root

**Benefit**: Significantly reduces the attack surface and follows the principle of least privilege.

---

## Why certbot-nginx is a Better Replacement for `certbot --nginx` Plugin

| Aspect                        | Official certbot --nginx Plugin                 | certbot-nginx (this tool)                              | Advantage |
|-------------------------------|--------------------------------------------------|---------------------------------------------------------|---------|
| **Security**                  | Runs as root, modifies live config directly     | Dedicated `nginx-adm` user + restricted sudo           | Much safer |
| **Reliability**               | Can break complex configs                       | Clean `--standalone` + strict sequence                 | More predictable |
| **Backup**                    | No automatic backup                             | Dated backups + auto-cleanup of default.conf           | Safer upgrades |
| **Control**                   | Plugin auto-edits your config                   | Full control + auditable configs                       | Better maintainability |
| **Non-interactive**           | Limited                                         | Dedicated install-only mode                            | Better for automation |

---

## My Viewpoint and Recommendation (from Grok)

I genuinely believe **certbot-nginx v1.9.0 is a solid and thoughtful project**.

The introduction of the `nginx-adm` least-privilege model is a meaningful improvement over most one-command certbot + nginx scripts (including the official Certbot Nginx plugin). The defensive coding style, strict installation sequence, dated backups, and clean separation between certificate issuance and configuration make this tool more reliable and secure than many alternatives.

**Recommendation**:
- **Yes, I recommend it** — especially if you value security, auditability, and least-privilege design.
- It is particularly suitable for self-hosters, homelab users, and anyone running services behind Cloudflare who wants strong origin protection without giving every renewal full root access.

**Honest caveats**:
- The project is still relatively small (low star count), which means fewer real-world battle tests compared to more popular tools.
- It is best suited for users comfortable with shell scripts and who appreciate a defensive, "do-not-simplify" philosophy.

If you're looking for a safer, more controlled way to manage Let's Encrypt certificates with Nginx — especially with Cloudflare — this tool is worth trying.

---

## 📋 Prerequisites

- Root/sudo access for the initial full setup
- Domains with A/AAAA records pointing to your server
- Cloudflare Proxy (orange cloud) recommended
- Ports 80 and 443 open

### Supported Platforms

| OS Family                  | Support     | Notes                              |
|---------------------------|-------------|------------------------------------|
| Ubuntu / Debian           | ★★★★★      | Best tested                        |
| Alpine Linux              | ★★★★★      | Excellent                          |
| Fedora / Rocky / RHEL     | ★★★★☆      | Good                               |
| openSUSE                  | ★★★☆☆      | Basic                              |
| macOS (Homebrew)          | ★★★☆☆      | Limited service control            |
| Git Bash / Windows        | Not recommended | Use WSL2                        |

---

## 📖 Commands & Options

| Command                        | Description                                              |
|--------------------------------|----------------------------------------------------------|
| `sudo certbot-nginx`           | Full interactive setup                                   |
| `sudo certbot-nginx nginx-conf`| Regenerate configs only (with backup)                    |
| `sudo certbot-nginx domains`   | Show saved domains                                       |
| `sudo certbot-nginx email`     | Show saved Let's Encrypt email                           |
| `sudo certbot-nginx about`     | Diagnostics                                              |

**Options**: `--quiet`, `--json`, `--no-cloudflare`

---

## 🔒 Cloudflare Origin Protection

Enabled by default with official Cloudflare IP ranges, `real_ip` support, and `deny all;`.

---

## 📁 Generated Files & Structure (v1.9.0)

- `/etc/nginx-adm/` — Configuration owned by `nginx-adm`
- Symlinks for `sites-available` and `sites-enabled`
- Restricted sudoers file for `nginx-adm`
- Dated backups of existing configs

---

## 🔄 Certificate Renewal

```bash
0 3 * * * root certbot renew --quiet --standalone \
    --pre-hook "systemctl stop nginx" \
    --post-hook "systemctl restart nginx"
```

---

## ⚠️ Important Notes

- Full setup requires an interactive terminal.
- Non-interactive mode only performs package installation + nginx stop.
- First chosen domain becomes the primary Common Name of the certificate.

---

## 📜 License

MIT License. See [LICENSE](LICENSE) for details.

---

## 🤝 Contributing

Contributions are welcome — especially better platform support, more real-world examples, and improvements to the `nginx-adm` workflow.

---

Made with ❤️ for secure and reliable Nginx + Let's Encrypt setups.

**Repository**: https://github.com/Wilgat/certbot-nginx

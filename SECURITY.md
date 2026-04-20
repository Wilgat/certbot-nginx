# Security Policy

## Supported Versions
Only the **latest version** of `certbot-nginx` (from the `main` branch) is supported and receives security updates.

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly.

**Preferred reporting methods:**

- Open a **private vulnerability report** on GitHub (recommended), or
- Create a GitHub Issue with the title:  
  **[Security] Vulnerability Report**

Please include as much detail as possible:
- Clear description of the vulnerability
- Steps to reproduce
- Potential impact
- Any suggested mitigation or fix

We will acknowledge receipt of your report within **48 hours** and work to address critical issues as quickly as possible.

---

## Security Considerations & Design Philosophy

`certbot-nginx` follows the **CIAO** principles (**Caution • Intentional • Anti-fragile • Over-protect**).  
The project is deliberately designed to minimize risk in a high-privilege environment.

### Key Security Features (as of 1.16.0)

- **nginx-adm least-privilege model**  
  After initial setup, most operations (config testing, service control, renewals) can run as the dedicated `nginx-adm` user instead of full root.  
  Only a very restricted set of `systemctl` and `nginx -t` commands are allowed via sudoers (NOPASSWD).

- **Self-install v2 checksum verification** (new in 1.16.0)  
  - Supports explicit `CHECKSUM=<sha256>` environment variable for strict verification.  
  - Automatically attempts to verify against `${SCRIPT_URL}.sha256` when available.  
  - Installation aborts immediately on checksum mismatch (fail-fast protection against tampered downloads).  
  - Recommended command:
    ```bash
    CHECKSUM=ebbf7c7e9f4f00382f3125793f57c48d94f99b594430683d61b965a44d141e26 \
      curl -fsSL https://raw.githubusercontent.com/Wilgat/certbot-nginx/main/certbot-nginx | sh
    ```

- **Strict installation sequence**  
  Certificates are obtained with `--standalone` *before* any nginx configuration is written.  
  Nginx is stopped early and never runs with incomplete or broken config.

- **Defensive practices**  
  - Dated backups of existing configs before any modification (with special handling for `default.conf`).  
  - Persistent but minimal storage of email and domains in `/etc/letsencrypt/`.  
  - Heavy input validation, early directory/file pre-creation, and idempotent operations.  
  - No silent failures — errors are loud and clear.

### Important Warnings

- The initial full setup **requires root/sudo** (package installation, user creation, ownership changes, sudoers setup).  
- Always review the script before running `curl | sh` (or use the checksum verification method above).  
- Non-interactive mode is intentionally limited to installation + early nginx stop — full setup still requires an interactive terminal.

We strongly recommend:
1. Review the full script content yourself before the first run:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/Wilgat/certbot-nginx/main/certbot-nginx | less
   ```
2. Use the `CHECKSUM=` method for production or automated deployments.
3. After initial setup, prefer running day-to-day commands as `nginx-adm` where possible.

---

## Disclosure Policy

We follow responsible disclosure:
- Security issues will be fixed as quickly as possible.
- We will credit reporters (unless anonymity is requested).
- Patches will be released on the `main` branch.

Thank you for helping keep `certbot-nginx` secure.

---

Made with ❤️ and caution for secure Nginx + Let's Encrypt deployments.

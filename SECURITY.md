# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| **1.16.4** (current `main`) | Yes |
| **1.16.3** | Best-effort only |
| **1.16.2** | Best-effort only |
| **1.16.1** | Best-effort only |
| Older releases | Best-effort only; no pledged backports |

## Reporting a Vulnerability

Please **do not** open a public issue for security-sensitive reports when a private channel is available.

**Preferred reporting methods:**

- Open a **private vulnerability report** on GitHub (recommended), or
- Create a GitHub Issue with the title: **[Security] Vulnerability Report** (use only if a private report is unavailable)

**Maintainer contact (email):** not published on this surface yet. Product **author-email** SSOT is the Copyright line in [`LICENSE`](./LICENSE). That line currently has the author name only; do **not** treat this file as an email SSOT.

Please include:

- Clear description of the vulnerability
- Steps to reproduce
- Potential impact
- Any suggested mitigation or fix

We will acknowledge receipt of an actionable report within **48 hours** and work to address critical issues as quickly as possible. Do not include exploit weaponization guides in public channels.

---

## Security Design Principles (CIAO)

This project follows **[CIAO](https://github.com/cloudgen/ciao)** / **CIAO-Lite** defensive design. Security-relevant intent:

| Letter | Principle | Security application |
|--------|-----------|----------------------|
| **C** | **Caution** | Assume hostile input, hostile networks, and misconfiguration. Validate boundaries; fail closed on integrity **mismatch** when a companion digest is present; never fail silently on hard integrity errors. Host-mutating domain verbs (`setup` / `run` / `nginx-conf`) are root-gated before the first write. |
| **I** | **Intentional** | Privilege boundaries, install channel, and integrity modes are deliberate. **Automatic companion-checksum** is the default integrity path; optional `CHECKSUM` env pin is secondary (CI / out-of-band), not a public `help` / `about` setting. |
| **A** | **Anti-fragile** | Survive harsh environments (minimal containers, missing tools, non-interactive install). Dated backups before config rewrite; least-privilege **nginx-adm** after first setup; missing-sidecar policy is explicit (warn + continue). |
| **O** | **Over-protect** | Defense in depth on critical paths (integrity verify before install/update when a companion is present; no partial host mutation on non-root setup). Do not “simplify away” safety or transparency for brevity. |

Full principles: [CIAO Defensive Programming](https://github.com/cloudgen/ciao) · agent contract: [CIAO-Lite](https://github.com/cloudgen/ciao-lite).

This section describes **design posture**. It is **not** a claim of third-party certification (ISO, OWASP “compliant”, etc.).

---

## Install integrity and trust

The ship unit implements the **automatic checksum mechanism** (`requirement-shell-automatic-checksum`). Operator install steps live in [`README.md`](./README.md). This section states **trust posture** only.

| Fact | Honest statement |
|------|------------------|
| **Default path** | Automatic companion verification of `${SCRIPT_URL}.sha256` when no operator pin is set — **no** `CHECKSUM` env required for normal install / self-update. |
| **Algorithm** | SHA-256. |
| **Transparency** | Human mode reports companion **link**, expected **value**, and verification **result** (match / mismatch / missing). |
| **Mismatch** | Abort — do not install mismatched bytes. |
| **Missing sidecar** | Warn and continue (not “always verified”). |
| **Optional pin** | Process-env `CHECKSUM` is **secondary** (CI / out-of-band freeze). Same-origin pin fetch is **not** stronger than automatic companion. Do **not** treat pin as a `help` / `about` public setting. |
| **Trust bound** | Same-channel SHA-256 proves **byte consistency** (wrong blob / bit-flip / stale companion vs artifact). It is **not** independent authenticity (signing / separate trust root) by itself. |

Do not embed the expected digest of `./certbot-nginx` *inside* `./certbot-nginx` as “self-verify.”

---

## Product security features (1.16.4)

- **nginx-adm least-privilege model** — After initial setup, most config-test / service-control operations can run as the dedicated `nginx-adm` user instead of full root. Restricted sudoers allow only a narrow `systemctl` + `nginx -t` set (NOPASSWD).
- **Strict setup sequence** — Certificates are obtained with `--standalone` *before* nginx site configs are written. Nginx is stopped early and must not run with incomplete or broken config. `nginx -t` must pass before reload/start that applies new configs.
- **Defensive host practice** — Dated backups of existing site configs before rewrite; email/domains persisted under `/etc/letsencrypt/`; fail closed on non-root `setup` / `run` / `nginx-conf` (no partial host mutation).

### Important warnings

- The initial full host setup **requires root/sudo** (packages, user creation, ownership, sudoers).
- Always review the script before running `curl | sh`. Prefer automatic companion verify (or an out-of-band `CHECKSUM` pin you already trust).
- Empty argv is **install-ensure only** (Type O). Full host work uses explicit `setup` / `run`.

We strongly recommend:

1. Review the script before the first run:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/Wilgat/certbot-nginx/main/certbot-nginx | less
   ```
2. Prefer automatic `${SCRIPT_URL}.sha256` verification; use `CHECKSUM=` only when you already have an out-of-band digest.
3. After initial setup, prefer day-to-day nginx ops as `nginx-adm` where possible.

---

## Disclosure Policy

We follow responsible disclosure:

- Security issues will be fixed as quickly as possible.
- We will credit reporters (unless anonymity is requested).
- Patches will be released on the `main` branch.

Thank you for helping keep `certbot-nginx` secure.

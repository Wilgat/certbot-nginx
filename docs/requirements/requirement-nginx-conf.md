**file**: docs/requirements/requirement-nginx-conf.md  
**Requirement-ID**: `RQ-NGINX-CONF`  
**Status**: Active (Version 1.1.0)  
**Area**: webserver  
**Key**: `requirement-nginx-conf`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite  
**Specializes**: portable mold **LM-NGINX-CONF-STRUCTURE** (not product authority)

## 1. Purpose

This requirement is the **product Single Source of Truth** for **external Nginx conf structure** generated or required by **certbot-nginx**: artifact types, structural elements, location roles, and domain-root path/ownership defaults for type-2 sites.

**Not domain SSOT:** Domain verbs, elev (**EM-EXT**), Certbot sequence, email/domains persistence remain **`RQ-DOMAIN-CERTBOT-NGINX`**. This file is a **webserver/conf structure** peer that domain law **cites**.

**Scope:** Conf file roles + server/location/statement shape for product-written confs; type-2 docroot path/ownership defaults.  
**Out of scope:** Type 0 CLI; package install order (domain); full LPU leaf authoring (cite terms + **SK-CREATE-LEAST-PRIVILEGE-USER-TERMINOLOGY** when F1–F7 needed).

**Vocabulary SSOT:** All names below **MUST** match live glossary keys (§2.0 map). This REQ **owns product MUST behavior**; glossary terms **own definitions**.

### Dual structure (portable mold + product law)

| Layer | Artifact | Role |
|-------|----------|------|
| **Portable** | **LM-NGINX-CONF-STRUCTURE** · terms **nginx-conf** / **nginx-domain-root** / location roles · staging/check skills (portable procedures) | Transferable patterns and probes |
| **Product (this file)** | **RQ-NGINX-CONF** + ship unit `./certbot-nginx` + **RQ-DOMAIN-CERTBOT-NGINX** (elev/verbs) | What **this** product generates, writers, honesty gaps |

H1/seed carries portable mold + terms + skills; product REQ rebinds Implementation Notes and generate-or-not rows.

---

## 2. Core Rules (Mandatory)

### 2.0 Terminology alignment (normative map)

Product law **MUST** use these glossary keys (not invent synonyms as law IDs):

| Concern | Glossary key(s) | This REQ |
|---------|-----------------|----------|
| Parent product / surface | **nginx** | Context only |
| Conf artifact parent | **nginx-conf** | §2.1 dual taxonomies |
| Type 1 CF map/IP | **nginx-conf-shared-cloudflare** | §2.1 |
| Type 2 per-domain HTTPS | **nginx-conf-per-domain-https** | §2.1 · §2.1.1 · §2.2 |
| Type 3 redirect | **nginx-conf-redirect** | §2.1 honesty |
| Server / location blocks | **nginx-conf-server-block** · **nginx-conf-location-block** | §2.2 · §2.3 |
| Location roles | **nginx-conf-location-block-root** · **…-acme** · **…-cloudflare-check** | §2.3 |
| Statements (parent) | **nginx-conf-statement** | §2.2 |
| Common statements | **nginx-conf-listen-statement** · **nginx-conf-server-name-statement** · **nginx-conf-root-statement** · **nginx-conf-index-statement** · **nginx-conf-include-statement** · **nginx-conf-ssl-certificate-statement** · **nginx-conf-try-files-statement** · **nginx-conf-return-statement** · **nginx-conf-proxy-pass-statement** | §2.2 |
| Content path + ownership | **nginx-domain-root** | §2.6 |
| LPU home / F4 / F5 | **system-user-home** · **system-user-affected-folder** · **least-privilege-user** · leaf **nginx-adm** (conf, not content by default) | §2.6 LPU rows |
| Conf operator / elev / control | **nginx-adm** · **nginx-sudoers** · **nginx-ctl** · **nginx-least-privilege-model** | Domain SSOT primary; host probe **`SK-CHECK-NGINX-LEAST-PRIVILEGE`**; hygiene §2.5 may use `nginx -t` |

**Fixed basenames (when product generates):**

| Artifact type | Term | Canonical basename (default) |
|---------------|------|------------------------------|
| Type 1 | nginx-conf-shared-cloudflare | **`cloudflare-map.conf`** (or sole existing live primary) |
| Type 2 | nginx-conf-per-domain-https | **`{{domain-name}}.conf`** |
| Type 3 | nginx-conf-redirect | **`redirect.conf`** (or sole existing live primary; product may not write) |

### 2.1 Artifact subclasses (product)

| Type id | Term | Product generates? | Notes |
|---------|------|--------------------|--------|
| `shared-cloudflare` | nginx-conf-shared-cloudflare | **YES** | `create_cloudflare_map` → e.g. `cloudflare-map.conf`. **Staging** (temp, preserve-first): agent skill **`SK-CREATE-NGINX-CLOUDFLARE-MAP-CONF`** |
| `per-domain-https` | nginx-conf-per-domain-https | **YES** | **One file per domain**; basename **`{{domain-name}}.conf`** (see §2.1.1). **Staging** (temp, preserve-first): **`SK-CREATE-NGINX-PER-DOMAIN-CONF`** |
| `redirect` | nginx-conf-redirect | **NO (taxonomy + host)** | Common on hosts (`redirect.conf`); product comments may mention HTTP→HTTPS but **MUST NOT** claim a dedicated type-3 writer until implemented. **Staging** for later copy: agent skill **`SK-CREATE-NGINX-REDIRECT-CONF`** (temp only; one basename; preserve features) |

Rules:

1. **MUST NOT** invent a fourth artifact type without glossary + this REQ update.  
2. **MUST** stay-honest: type 3 may exist on disk without product generation.  
3. CLI verb `nginx-conf` **MUST** regenerate type 1 + type 2 (with prior domain store); **MUST** root-gate per domain SSOT.  
4. Type 2 basenames **MUST** follow §2.1.1.

### 2.1.1 Per-domain conf naming convention (normative)

| Rule | Law |
|------|-----|
| **Pattern** | **`{{domain-name}}.conf`** |
| **`{{domain-name}}`** | Domain string from the product domain list / FQDN (e.g. `admin.example.com` → `admin.example.com.conf`) |
| **One per domain** | **Exactly one** conf file per `{{domain-name}}` under the active layout (`sites-available` + enablement **or** `conf.d`) |
| **Product writer** | `create_per_domain_server_blocks` (and peers) **MUST** write `${NGINX_CONF_ROOT}/sites-available/{{domain-name}}.conf` (or layout-equivalent with the **same** basename) |
| **Staging skill** | **`SK-CREATE-NGINX-PER-DOMAIN-CONF`** **MUST** default greenfield basename to `{{domain-name}}.conf`; when reusing live conf, keep the live primary basename only if a single legacy name already exists |
| **Forbidden new names** | `{{domain-name}}-v2.conf`, `{{domain-name}}.nginx.conf`, or a second file for the same domain while `{{domain-name}}.conf` is free |
| **Glossary** | Term **nginx-conf-per-domain-https** § Naming convention |

Ship-unit alignment (this product): writer uses `"${NGINX_CONF_ROOT}/sites-available/${domain}.conf"` — **`${domain}`** is the domain-name token.

### 2.2 Structural elements (type 2)

Each product-written per-domain HTTPS conf **MUST** (glossary element names in parentheses):

1. Use basename **`{{domain-name}}.conf`** (§2.1.1 · term **nginx-conf-per-domain-https**).  
2. **Include** type-1 map (**nginx-conf-include-statement**) of **nginx-conf-shared-cloudflare** (or product-documented wire).  
3. Contain one **nginx-conf-server-block** with **nginx-conf-listen-statement** on **443 ssl** (and IPv6 when product template does).  
4. Set **nginx-conf-server-name-statement** to **`{{domain-name}}`** (primary).  
5. Set **nginx-conf-root-statement** per §2.6 (default **`/var/www/{{domain-name}}`** → **nginx-domain-root** public path).  
6. Ensure **nginx-domain-root** ownership per §2.6 when product creates/fixes the directory.  
7. Set **nginx-conf-index-statement** as designed (default `index.html`).  
8. Set **nginx-conf-ssl-certificate-statement** paths at `/etc/letsencrypt/live/${main_domain}/…` (shared multi-SAN cert model).  
9. Nest the **location roles** in §2.3 (**nginx-conf-location-block** subclasses).  
10. Content locations typically use **nginx-conf-try-files-statement** and/or **nginx-conf-proxy-pass-statement** as product designs; CF-check may use **nginx-conf-return-statement**.

### 2.3 Location roles (type 2 HTTPS template)

Each type-2 server block **MUST** include:

| Role | Term | Match (product) | Law |
|------|------|-----------------|-----|
| Content | **nginx-conf-location-block-root** | `location /` | Serve site via `try_files` (or product proxy); **default** CF gate: empty `CF-Connecting-IP` → **403** when Cloudflare protection enabled |
| ACME | **nginx-conf-location-block-acme** | `/.well-known/acme-challenge/` | Dedicated root (e.g. `${NGINX_DOCROOT_BASE}/letsencrypt`); **MUST NOT** apply the content CF 403 gate |
| CF check | **nginx-conf-location-block-cloudflare-check** | `location = /cloudflare-check` | Open diagnostic `return 200` HTML; **MUST** bypass content CF gate |

### 2.4 Cloudflare open mode honesty

| Claim | Law |
|-------|-----|
| `--no-cloudflare` / interactive opt-out | Domain SSOT feature flag |
| Generated type-2 body without CF gate | **MUST** match generator code. If generator still emits the gate, product **MUST NOT** claim open conf until fixed (stay-honest gap). |

### 2.5 Deploy hygiene

1. **MUST** dated-backup site confs before rewrite (`backup_nginx_sites_configs` family).  
2. **MUST** `nginx -t` (or equivalent) before start/reload that applies conf (**RQ-DOMAIN** also requires this).  
3. **MUST** fail closed on test failure.

### 2.6 Document root path + ownership (normative defaults)

Paths named by type-2 **`root`** statements are **nginx-domain-root**. Defaults **MUST** follow glossary **nginx-domain-root** § Defaults unless product/operator override is explicit.

#### Path

| Rule | Law |
|------|-----|
| **Default** | **`/var/www/{{domain-name}}`** |
| **Base form** | `${NGINX_DOCROOT_BASE}/{{domain-name}}` with default base `/var/www` |
| **Override** | Allowed when product law, operator, or existing conf specifies another path (e.g. app tree) — document and do not silently rewrite to `/var/www/…` on preserve-first staging |

#### Ownership selection

| Situation | Type id | owner:group (default product) | Layout |
|-----------|---------|-------------------------------|--------|
| **Default** (no frequent-update or freeze need stated) | **service-lock** | **`www-data:www-data`** | Real dir at `/var/www/{{domain-name}}` |
| **Frequent update need** | **frequent-change** | **`{{user}}:www-data`** on **real** tree | Real: **`{{home}}/{{domain-name}}`**; soft link **`/var/www/{{domain-name}}` → `{{home}}/{{domain-name}}`**; conf `root` still **`/var/www/{{domain-name}}`** |
| **Security / freeze need** | **hard-lock** | **`root:root`** | Real dir at `/var/www/{{domain-name}}` (no home symlink required) |
| **Explicit override** | as specified | Product/operator table wins | Document |

#### Frequent-change symlink layout (normative when frequent-update applies)

| Element | Path | Notes |
|---------|------|--------|
| Real content | **`{{home}}/{{domain-name}}`** | Owned **`{{user}}:www-data`**; where updates happen |
| Public path / conf root | **`/var/www/{{domain-name}}`** | **Symlink** → real content; type-2 `root` directive |
| Soft link | same as public path | Soft link, not a second real tree |

When **`{{user}}` is an LPU** (or system user with F1–F7 leaf docs):

| Field | MUST document |
|-------|----------------|
| **F3** | **`{{home}}` only** (not bare domain path as “home”) |
| **F4 Symlink map** | **`/var/www/{{domain-name}}` → `{{home}}/{{domain-name}}`** |
| **F5 Affected folders** | **`/var/www/{{domain-name}}`** (required for this pattern); **may** list `{{home}}/{{domain-name}}` as subtree under home — **never** bare `{{home}}` in F5 |

Rules:

1. Product create of domain root dirs **SHOULD** `mkdir` default path and apply ownership per the table when the product owns that step.  
2. Product helper `fix_docroot_permissions` (recursive **www-data** on `${NGINX_DOCROOT_BASE}`) is **service-lock-oriented** — **MUST NOT** be described as implementing all three types on every tree (stay-honest: may overwrite frequent-change/hard-lock if run blindly; **MUST NOT** replace a frequent-change symlink layout with a www-data-owned real dir without explicit intent).  
3. **Frequent-change** **MUST** use a real **`{{user}}`** (not invent; not conf LPU `nginx-adm` unless that user truly deploys content).  
4. **Frequent-change** **MUST** use the symlink layout above unless product documents a different real-path design.  
5. Staging skill **`SK-CREATE-NGINX-PER-DOMAIN-CONF`** **MUST** default greenfield conf `root` to `/var/www/{{domain-name}}` and, when frequent-update is claimed, document real path + symlink recommendation; **MUST NOT** chown/symlink live trees without elev + user intent.  
6. LPU leaf terms **MUST** carry F4/F5 for this pattern via **`SK-CREATE-LEAST-PRIVILEGE-USER-TERMINOLOGY`**.

---

## 3. Implementation notes (certbot-nginx)

| Item | Value |
|------|--------|
| Writers | `create_cloudflare_map`, `create_per_domain_server_blocks`, `deploy_domain_nginx_configs` |
| Regen verb | `nginx-conf` (domain SSOT elev) |
| Conf root | `${NGINX_CONF_ROOT}` default `/etc/nginx` |
| Docroot base | `${NGINX_DOCROOT_BASE}` default `/var/www` |
| **Type 2 basename** | **`{{domain-name}}.conf`** (ship: `${domain}.conf`) |
| **Docroot path** | default **`/var/www/{{domain-name}}`** |
| **Docroot ownership** | default **www-data:www-data**; frequent → **`{{user}}:www-data`** + symlink layout; freeze → **root:root** |
| Glossary map | §2.0 |
| Staging skills | `SK-CREATE-NGINX-CLOUDFLARE-MAP-CONF` · `SK-CREATE-NGINX-PER-DOMAIN-CONF` · `SK-CREATE-NGINX-REDIRECT-CONF` |
| Checklist | **CL-NGINX-CONF-STRUCTURE** |
| Ship vs term gap | Type 3 redirect **not** generated; open-CF body may lag flag (domain + this REQ honesty) |

### 3.1 Coverage vs terminology (review snapshot)

| Term family | Covered by this REQ? | Notes |
|-------------|----------------------|--------|
| **nginx-conf** + 3 artifact subclasses | **Yes** §2.1 | Type 3 write = honesty gap |
| **nginx-conf-server-block** / **location-block** + 3 roles | **Yes** §2.2–2.3 | |
| **nginx-conf-*-statement** leaves | **Yes** §2.2 map | Not every directive needs its own MUST row |
| **nginx-domain-root** defaults + frequent-change layout | **Yes** §2.6 | |
| **system-user-home** / **affected-folder** F3–F5 | **Yes** §2.6 LPU | Leaf authoring elsewhere |
| **nginx-adm** / **nginx-sudoers** / **nginx-ctl** | **Pointer** | Domain SSOT owns create/sudoers; §2.5 uses config test |
| **nginx** (product surface) | **Pointer** | Context |

---

## 4. Protection Rule (Sacred)

**MUST NOT**:

1. Replace domain SSOT elev/cert sequence with this file alone.  
2. Claim type-3 redirect generation without a writer.  
3. Gate ACME location with CF 403.  
4. Treat `/cloudflare-check` as authenticated admin.  
5. Cite `template-nginx-conf-structure` from ship unit as behavioral authority (cite **this** REQ).  
6. Collapse location roles into artifact type IDs.  
7. Generate a **new** type-2 conf under any basename other than **`{{domain-name}}.conf`** when that name is free, or maintain **two** confs for one domain.  
8. Default a new domain root path away from **`/var/www/{{domain-name}}`** without documented override, or default ownership away from **www-data:www-data** without frequent-update / hard-lock / explicit override.  
9. Claim blanket recursive www-data chown implements hard-lock and frequent-change for every tree.  
10. For frequent-change, omit the **`/var/www/{{domain-name}}` → `{{home}}/{{domain-name}}`** symlink layout without documented alternate, or list bare **`{{home}}`** as an LPU **affected folder**.  
11. Document the public docroot symlink only in prose and skip **F4/F5** when `{{user}}` is an LPU leaf.

---

## 5. Related

| Artifact | Role |
|----------|------|
| **`RQ-DOMAIN-CERTBOT-NGINX`** | Domain verbs, elev, certs, backups, **nginx-adm** |
| **LM-NGINX-CONF-STRUCTURE** | Portable mold |
| **CL-NGINX-CONF-STRUCTURE** | Structure + naming + ownership audit |
| Terms | **nginx-conf** · **nginx-conf-*** · **nginx-domain-root** · **system-user-home** · **system-user-affected-folder** · **nginx-adm** · **nginx-sudoers** · **nginx-ctl** · **nginx** |
| Skills | **SK-CREATE-NGINX-*** staging trio · **SK-USE-NGINX-CERTBOT-DOMAIN-CLI** · **SK-CREATE-LEAST-PRIVILEGE-USER-TERMINOLOGY** |
| Ship unit | `./certbot-nginx` |

---

**Last Updated:** 2026-08-12  
**Owner:** certbot-nginx project maintainers  
**Version:** 1.2.0 — dual structure (portable mold + product law); terminology map; statement wiring; coverage review; git-surface scrub


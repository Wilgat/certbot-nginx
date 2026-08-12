**file**: docs/requirements/requirement-bootstrap-chain.md  
**Requirement-ID**: `RQ-BOOTSTRAP-CHAIN`  
**Status**: Active (Version 1.0.0)  
**Area**: architecture  
**Key**: `requirement-bootstrap-chain`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **bootstrap chain** of **certbot-nginx**: specialization lineage, hop roles, direction rules, and shared-defect ownership between ancestors and this leaf.

**Scope:** Declared hops; direction A→B only; inherit / retarget / domain per edge; ship-unit and channel separation.  
**Out of scope:** Domain feature tables (`requirement-domain-certbot-nginx.md`); Type 0 command catalogs (peer shell requirements).

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Direction (sacred)

1. Specialization direction **MUST** be **ancestor → descendant** only.  
2. Agents **MUST NOT** overwrite bootstrap **selfmanaged** with certbot-nginx’s body.  
3. Detected reverse parentage **MUST** be treated as a critical defect until corrected.  
4. After fixing a shared architecture defect on the ancestor, refresh this leaf **from** the fixed ancestor (down-chain), not the reverse.

### 2.2 Declared chain (SSOT)

The project **MUST** maintain an explicit hop table (Implementation Notes §3.1). Informal git history alone is **not** chain SSOT.

### 2.3 Per-edge obligations

| Obligation | Rule |
|------------|------|
| **Inherit** | Child keeps parent Type 0 structural contracts (install/lifecycle, entry under pipe, Type O empty argv, integrity companion pattern, centralized output) unless authorized product-type change |
| **Retarget** | Child owns its `APP_NAME`, version, and `SCRIPT_URL` / `REPO_*` defaults |
| **Domain** | Child may add domain surface; **MUST NOT** reverse-write domain onto parent |
| **Ship unit** | Parent and child remain distinct installable artifacts |

### 2.4 Shared vs domain-only defects

| Class | Ownership |
|-------|-----------|
| Shared architecture / install / lifecycle / integrity | Prefer ancestor **selfmanaged** when defect is inherited |
| Leaf identity / channel | Leaf only |
| Domain (Nginx, Certbot, Cloudflare, nginx-adm, domains/email/nginx-conf/setup) | Leaf only — **MUST NOT** push onto selfmanaged |
| “Fix ancestor by pasting leaf” | **Forbidden** |

### 2.5 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution:** Multi-hop parentage declared, not guessed.  
- **CIAO Principle 2 – Intentional:** Named hops and inherit/retarget/domain decisions.  
- **CIAO Principle 3 – Anti-fragile:** Fix shared defects on the responsible hop.  
- **CIAO Principle 5 – SSOT:** One hop table for this product.  
- **CIAO Principle 4 / 20 – Over-protect:** Reverse-copy ban is Protection Zone material.

---

## 3. Implementation Notes (this project — no-placeholder)

### 3.1 Hop table (certbot-nginx)

| Position | Product | Ship unit / reference | Role |
|----------|---------|----------------------|------|
| **Root / immediate origin (A)** | `selfmanaged` | Peer project `/var/www/grok.dr-sense.com/prjs/selfmanaged` and workspace reference copy `./selfmanaged` (must stay frozen Type 0 bootstrap) | Architecture + Type 0 online self-managed law source |
| **Leaf (B)** | `certbot-nginx` | `./certbot-nginx` + `certbot-nginx.sha256` | Specialized product: Type 0 + Nginx/Certbot domain |

**Edge A → B:**

| Concern | Decision |
|---------|----------|
| Inherit | Type O empty argv install-ensure; online install + self-update/self-uninstall/version-check; companion `.sha256`; pipe entry calls main; quiet/json modes |
| Retarget | `APP_NAME=certbot-nginx`; `REPO_USER=Wilgat`; `REPO_NAME=certbot-nginx`; `VERSION=1.16.0`; channel `https://raw.githubusercontent.com/Wilgat/certbot-nginx/main/certbot-nginx` |
| Domain | `setup`/`run`, `domains`, `email`, `nginx-conf`, nginx-adm, Cloudflare origin, Certbot standalone — **leaf only** |
| Archive of A | Peer git project + in-tree `./selfmanaged` byte-identical to peer at specialize time |

### 3.2 Specialize session (2026-08-12)

| Item | Value |
|------|--------|
| Direction | **selfmanaged → certbot-nginx** only |
| Reverse-copy | None planned; A frozen (`cmp` peer == local `./selfmanaged`) |
| Product law | Left genesis: class + shell Type 0 REQs retargeted + domain SSOT + this chain file |
| Dispatcher fix | Empty argv restored to Type O; domain setup explicit `setup`/`run`; foreign help DNA removed |

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Copy `./certbot-nginx` over `./selfmanaged` or the peer selfmanaged ship unit.  
2. Claim selfmanaged was “trimmed from certbot-nginx.”  
3. Merge channels so certbot-nginx defaults to cloudgen/selfmanaged raw URL (or reverse) without explicit user order.  
4. Delete this hop table while claiming specialized lineage honesty.

---

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry |
| `docs/requirements/requirement-domain-certbot-nginx.md` | Domain SSOT |
| `docs/requirements/requirement-class-software-dev.md` | Class |
| `./selfmanaged` | Bootstrap A reference ship unit (in-tree) |
| `./certbot-nginx` | Leaf ship unit |

**Last Updated**: 2026-08-12  
**Owner**: certbot-nginx project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).

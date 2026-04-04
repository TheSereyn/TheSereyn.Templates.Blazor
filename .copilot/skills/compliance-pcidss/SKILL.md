---
name: "compliance-pcidss"
description: "PCI DSS requirements for software development. Reference when the project handles payment card data."
---

# PCI DSS — Software Development Guidance

## What It Is

PCI DSS (Payment Card Industry Data Security Standard) is mandatory for any organisation that stores, processes, or transmits payment card data. Version 4.0.1 is the current standard (June 2024 errata update). PCI DSS is prescriptive — it contains specific technical requirements, not just principles.

## Scope Reduction

The most practical PCI DSS guidance is to eliminate scope. If your application never touches cardholder data, PCI DSS requirements are dramatically reduced. Implement tokenization to exchange card data for a surrogate value that has no exploitable value.

**Recommendations:**
- Use a PCI-compliant payment processor (e.g., Stripe, Adyen, Braintree) so card data never enters your systems
- Implement tokenization — the processor handles card data and returns a token your application stores instead
- Use hosted payment pages or iframes from the processor so cardholder data never touches your servers
- If you must handle card data directly, isolate the cardholder data environment (CDE) and minimise its footprint
- Document your scope with a data flow diagram showing where cardholder data enters, flows through, and is stored

Eliminating scope through tokenization and hosted payment fields is far simpler and cheaper than achieving full PCI DSS compliance for systems that handle raw card data.

## Key Requirements for Developers

### Requirement 6 — Develop Secure Systems and Software

This is the core requirement for development teams:

- **6.2.1** — Custom software developed securely using industry standards (OWASP, CERT, etc.)
- **6.2.2** — Developers trained in secure coding at least annually
- **6.2.3** — Code reviewed before release — peer review or automated tools
- **6.2.4** — Protection against common vulnerabilities:
  - Injection attacks (SQL, OS command, LDAP, XPath)
  - Buffer overflows
  - Insecure cryptographic storage
  - Insecure communications
  - Improper error handling (no stack traces to users)
  - Cross-site scripting (XSS)
  - Improper access control
  - Cross-site request forgery (CSRF)
  - Broken authentication and session management

### Requirement 3 — Protect Stored Account Data
- Never store sensitive authentication data after authorization (CVV, full track data, PIN)
- Mask PAN when displayed — show only first 6 and last 4 digits
- Render PAN unreadable wherever stored (encryption, hashing, truncation, tokenization)
- Protect and manage encryption keys with documented procedures

### Requirement 4 — Protect Data in Transit
- Use strong cryptography (TLS 1.2+) for any transmission of cardholder data
- Never send PAN via unencrypted messaging (email, SMS, chat)

### Requirement 7 — Restrict Access to System Components and Cardholder Data
- Implement role-based access control (RBAC) or attribute-based access control (ABAC) for all system components
- Enforce least privilege — grant only the minimum access necessary for job function
- Default deny — deny all access unless explicitly granted
- Review access rights periodically and revoke unnecessary permissions promptly
- Document access control policies and ensure they cover all system components in the CDE

### Requirement 8 — Identify Users and Authenticate Access
- Unique ID for every user with system access
- MFA for all access to the cardholder data environment
- Strong password requirements (12+ characters, complexity)
- Lock out after 10 failed attempts

### Requirement 10 — Log and Monitor Activity
- Log all access to cardholder data
- Log all actions by privileged users
- Log all authentication attempts (success and failure)
- Protect audit trails from modification
- Retain logs for at least 12 months (3 months immediately available)

### Requirement 11 — Test Security Regularly
- Run vulnerability scans at least quarterly
- Penetration test at least annually
- Implement intrusion detection / change detection on critical files

## Development Checklist

- [ ] No sensitive authentication data stored after authorization
- [ ] PAN masked in display, encrypted at rest
- [ ] TLS 1.2+ for all cardholder data transmission
- [ ] Input validation on all user-supplied data
- [ ] Parameterized queries — no dynamic SQL
- [ ] Output encoding to prevent XSS
- [ ] Anti-CSRF tokens on state-changing operations
- [ ] Error messages reveal no system details
- [ ] Comprehensive audit logging (access, auth, changes)
- [ ] Code review before every release
- [ ] Unique IDs and MFA for all system access

## Future-Dated Requirements (v4.0.1)

Several Requirements in PCI DSS v4.0.1 have a phased implementation timeline. Requirements marked as "future-dated" were best practices in v4.0 and became mandatory on 31 March 2025. Key examples include:

- **6.3.2** — Maintain an inventory of bespoke and custom software with component details
- **6.4.2** — Web applications facing the internet use an automated solution to detect and prevent web-based attacks (WAF)
- **5.4.1** — Automated mechanisms to detect and protect against phishing
- **8.4.2** — MFA for all access into the CDE (not just remote)
- **12.6.2** — Security awareness training updated to address current threats including phishing and social engineering

Review the full list of future-dated requirements in the PCI DSS v4.0.1 standard and ensure your implementation covers them.

## Authoritative Source

- [PCI DSS v4.0.1](https://www.pcisecuritystandards.org/document_library/) — Official standard (free registration required)
- [PCI DSS Quick Reference Guide](https://www.pcisecuritystandards.org/document_library/)

> **Important:** This skill covers development requirements only. PCI DSS compliance involves network security, physical security, policies, and regular assessments. Work with a Qualified Security Assessor (QSA) for full compliance.

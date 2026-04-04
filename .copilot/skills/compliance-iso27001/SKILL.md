---
name: "compliance-iso27001"
description: "ISO/IEC 27001:2022 software development requirements. Reference when the project must comply with ISO 27001 information security management."
---

# ISO/IEC 27001:2022 — Software Development Guidance

## What It Is

ISO/IEC 27001:2022 is the international standard for Information Security Management Systems (ISMS). The 2022 revision completely restructured Annex A from the previous 14 domains with 114 controls (2013 edition) into **4 themes with 93 controls**, and introduced 11 entirely new controls. This skill uses the current 2022 control numbering throughout.

## 2022 Annex A Themes

The four themes organise all 93 controls:

| Theme | Controls | Scope |
|-------|----------|-------|
| **A.5 Organisational controls** | 37 (A.5.1–A.5.37) | Policies, roles, asset management, access control, supplier relations, incident management, compliance |
| **A.6 People controls** | 8 (A.6.1–A.6.8) | Screening, employment terms, training, disciplinary, remote working, event reporting |
| **A.7 Physical controls** | 14 (A.7.1–A.7.14) | Perimeters, entry, offices, monitoring, environmental threats, equipment, media |
| **A.8 Technological controls** | 34 (A.8.1–A.8.34) | Endpoint devices, access, authentication, capacity, malware, vulnerabilities, configuration, backup, logging, networks, secure coding, testing |

## Key Controls for Software Development

### Organisational Controls (A.5)

- **A.5.1 Policies for information security** — Maintain documented secure development policies reviewed at planned intervals
- **A.5.7 Threat intelligence** *(new in 2022)* — Gather and analyse threat intelligence relevant to the application domain
- **A.5.8 Information security in project management** — Integrate security requirements into project planning and delivery
- **A.5.9 Inventory of information and associated assets** — Maintain an inventory of information assets the application handles
- **A.5.10 Acceptable use of information** — Define and enforce rules for handling classified information in code
- **A.5.12 Classification of information** — Classify data handled by the application (public, internal, confidential, restricted)
- **A.5.15 Access control** — Implement role-based or attribute-based access; enforce least privilege
- **A.5.16 Identity management** — Unique identifiers for all users and service accounts
- **A.5.17 Authentication information** — Enforce strong authentication; protect credentials
- **A.5.18 Access rights** — Provision, review, and revoke access rights; log all access control decisions
- **A.5.23 Information security for use of cloud services** *(new in 2022)* — Define and enforce security requirements for cloud service usage, including shared responsibility boundaries
- **A.5.26 Response to information security incidents** — Documented incident response procedures, tested regularly
- **A.5.30 ICT readiness for business continuity** *(new in 2022)* — Ensure ICT services can be recovered within required timeframes
- **A.5.36 Compliance with policies, rules and standards** — Ensure cryptographic controls and security decisions comply with applicable regulations

### People Controls (A.6)

- **A.6.3 Information security awareness, education and training** — Developers receive secure coding training
- **A.6.8 Information security event reporting** — All personnel must report security events through established channels

### Physical Controls (A.7)

- **A.7.4 Physical security monitoring** *(new in 2022)* — Monitor physical access to facilities containing development infrastructure
- **A.7.7 Clear desk and clear screen** — Lock workstations; no sensitive data visible on unattended screens

### Technological Controls (A.8)

- **A.8.1 User endpoint devices** — Secure developer workstations and mobile devices
- **A.8.2 Privileged access rights** — Restrict and monitor elevated access (admin, root, CI/CD service accounts)
- **A.8.3 Information access restriction** — Enforce access restrictions at the application and data layer
- **A.8.4 Access to source code** — Restrict source code access; manage read/write permissions
- **A.8.5 Secure authentication** — Implement MFA where appropriate; protect authentication mechanisms
- **A.8.6 Capacity management** — Plan for capacity and scaling to ensure availability
- **A.8.7 Protection against malware** — Integrate malware/dependency scanning into CI/CD
- **A.8.8 Management of technical vulnerabilities** — Vulnerability scanning, patching, and tracking (see `security-register` skill)
- **A.8.9 Configuration management** *(new in 2022)* — Define, document, implement, monitor, and review security configurations for hardware, software, services, and networks
- **A.8.10 Information deletion** *(new in 2022)* — Delete information when no longer required; implement automated data retention and cleanup
- **A.8.11 Data masking** *(new in 2022)* — Mask data in non-production environments; apply pseudonymisation where appropriate
- **A.8.12 Data leakage prevention** *(new in 2022)* — Implement controls to prevent unauthorised disclosure of sensitive data
- **A.8.13 Information backup** — Backup strategies for application data with tested restoration procedures
- **A.8.15 Logging** — Log security-relevant events (access, authentication, changes, errors)
- **A.8.16 Monitoring activities** *(new in 2022)* — Monitor networks, systems, and applications for anomalous behaviour; establish alerting
- **A.8.17 Clock synchronisation** — Synchronise clocks across systems for reliable log correlation
- **A.8.20 Networks security** — Segment networks; secure API endpoints
- **A.8.23 Web filtering** *(new in 2022)* — Manage access to external websites to reduce exposure to malicious content
- **A.8.25 Secure development life cycle** — Follow a documented SDLC with security gates
- **A.8.26 Application security requirements** — Define security requirements during design, not bolted on later
- **A.8.27 Secure system architecture and engineering principles** — Apply defence-in-depth, fail-secure, and least-privilege architectural patterns
- **A.8.28 Secure coding** *(new in 2022)* — Apply secure coding principles; use static analysis; validate inputs; handle errors safely
- **A.8.29 Security testing in development and acceptance** — Include SAST, DAST, and manual security testing in the pipeline
- **A.8.30 Outsourced development** — Apply security requirements to third-party development
- **A.8.31 Separation of development, test and production environments** — Strict environment separation with controlled promotion
- **A.8.32 Change management** — All changes reviewed, approved, and tested before deployment
- **A.8.33 Test information** — Protect test data; do not use production PHI/PII in test environments without masking

## New in 2022

These 11 controls were introduced in ISO 27001:2022 and have no direct equivalent in the 2013 edition:

| Control | Theme | Developer Relevance |
|---------|-------|---------------------|
| **A.5.7** Threat intelligence | Organisational | Feed threat intel into risk assessments and design decisions |
| **A.5.23** Cloud services security | Organisational | Document cloud shared-responsibility boundaries; enforce cloud security baselines |
| **A.5.30** ICT readiness for business continuity | Organisational | Define RTOs/RPOs; test recovery procedures for application services |
| **A.7.4** Physical security monitoring | Physical | Relevant for on-premises infrastructure hosting development systems |
| **A.8.9** Configuration management | Technological | Infrastructure-as-code, hardened baselines, drift detection |
| **A.8.10** Information deletion | Technological | Implement data retention policies and automated cleanup |
| **A.8.11** Data masking | Technological | Mask/pseudonymise data in non-production environments |
| **A.8.12** Data leakage prevention | Technological | DLP controls in CI/CD, code repositories, and runtime |
| **A.8.16** Monitoring activities | Technological | Application-level monitoring, anomaly detection, SIEM integration |
| **A.8.23** Web filtering | Technological | Restrict outbound connections; block known-malicious domains |
| **A.8.28** Secure coding | Technological | Secure coding standards, static analysis, input validation |

## ISMS Scope and Risk Assessment

### Defining ISMS Scope
- Identify the boundaries of the ISMS — which systems, services, teams, and locations are in scope
- For software projects, scope typically includes the application, its infrastructure, the development environment, CI/CD pipelines, and supporting services
- Document internal and external issues, and interested parties' requirements (Clauses 4.1–4.3)

### Risk Assessment Methodology
- Adopt a risk assessment methodology (e.g., ISO 27005, NIST SP 800-30, OCTAVE) and document it
- Identify risks to information assets in scope, assess likelihood and impact, and determine risk treatment (mitigate, accept, transfer, avoid)
- Map risk treatments to specific Annex A controls
- Maintain a risk register and review it at planned intervals

## Statement of Applicability (SoA)

The Statement of Applicability is a mandatory document that lists all 93 Annex A controls and states for each:
- Whether it is applicable or excluded
- Justification for inclusion or exclusion
- Implementation status

For software development projects, the SoA helps ensure no relevant control is overlooked. Produce the SoA early and update it as the project evolves.

## Development Checklist

- [ ] Information assets classified and handling rules applied in code
- [ ] Access control enforced at API and data layers (A.5.15, A.8.3)
- [ ] Source code access restricted and audited (A.8.4)
- [ ] All changes go through code review and change management (A.8.32)
- [ ] Security testing (SAST, DAST) included in CI/CD pipeline (A.8.29)
- [ ] Secure coding standards documented and enforced (A.8.28)
- [ ] Secrets managed via secret stores — never in source code (A.5.17)
- [ ] Audit logging captures security-relevant events (A.8.15)
- [ ] Monitoring and alerting configured for anomalous behaviour (A.8.16)
- [ ] Configuration management with drift detection (A.8.9)
- [ ] Data masking applied in non-production environments (A.8.11)
- [ ] Data leakage prevention controls in place (A.8.12)
- [ ] Data retention and deletion policies implemented (A.8.10)
- [ ] Vulnerability management process in place (A.8.8, see `security-register` skill)
- [ ] Development, test, and production environments separated (A.8.31)
- [ ] Cloud security requirements documented if applicable (A.5.23)
- [ ] Threat intelligence reviewed for application domain (A.5.7)
- [ ] ICT recovery and business continuity plan tested (A.5.30)
- [ ] Risk assessment completed with Statement of Applicability produced

## Authoritative Source

- [ISO/IEC 27001:2022](https://www.iso.org/standard/27001) — Purchase required for full standard
- [ISO/IEC 27002:2022](https://www.iso.org/standard/75652.html) — Implementation guidance for Annex A controls
- [ISO 27001 Overview (ISO)](https://www.iso.org/isoiec-27001-information-security.html)

> **Important:** This skill provides development-focused guidance only. Consult the full standard and your compliance/security team for certification requirements. ISO 27001 certification requires a broader ISMS covering governance, risk management, and operational procedures beyond software development.

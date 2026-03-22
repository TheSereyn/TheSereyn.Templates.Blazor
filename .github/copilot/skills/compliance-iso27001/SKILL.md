---
name: "compliance-iso27001"
description: "ISO 27001 software development requirements. Reference when the project must comply with ISO 27001 information security management."
---

# ISO 27001 — Software Development Guidance

## What It Is

ISO/IEC 27001 is the international standard for Information Security Management Systems (ISMS). It provides a framework for managing information security risks. Annex A controls directly affect how software is developed, deployed, and maintained.

## Key Controls for Software Development

### A.8 — Asset Management
- Classify information assets handled by the application (public, internal, confidential, restricted)
- Ensure data handling matches its classification throughout the code

### A.9 — Access Control
- Implement role-based or attribute-based access control
- Enforce least privilege — users and services get minimum necessary permissions
- Log all access control decisions (grants and denials)

### A.12 — Operations Security
- Separate development, testing, and production environments
- Implement change management — all changes reviewed and approved before deployment
- Protect logging and monitoring data from tampering

### A.14 — System Acquisition, Development, and Maintenance
- **A.14.2.1** Secure development policy — follow documented secure coding practices
- **A.14.2.5** Secure system engineering — security requirements in design, not bolted on
- **A.14.2.6** Secure development environment — isolated, access-controlled dev environments
- **A.14.2.8** System security testing — test security controls before release
- **A.14.2.9** System acceptance testing — verify security requirements are met

### A.16 — Incident Management
- Implement security event logging sufficient for incident investigation
- Have an incident response procedure documented and tested

### A.18 — Compliance
- Ensure cryptographic controls comply with applicable regulations
- Maintain records of security decisions and risk acceptances

## Development Checklist

- [ ] Information assets classified and handling rules applied in code
- [ ] Access control enforced at API and data layers
- [ ] All changes go through code review before merge
- [ ] Security testing included in CI/CD pipeline
- [ ] Secrets managed via environment variables or secret stores
- [ ] Audit logging captures security-relevant events
- [ ] Vulnerability management process in place (see `security-register` skill)
- [ ] Development environment access restricted and logged

## Authoritative Source

- [ISO/IEC 27001:2022](https://www.iso.org/standard/27001) — Purchase required for full standard
- [ISO 27001 Overview (ISO)](https://www.iso.org/isoiec-27001-information-security.html)

> **Important:** This skill provides development-focused guidance only. Consult the full standard and your compliance/security team for certification requirements. ISO 27001 certification requires a broader ISMS covering governance, risk management, and operational procedures beyond software development.

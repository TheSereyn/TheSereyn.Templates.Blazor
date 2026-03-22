---
name: "compliance-hipaa"
description: "HIPAA requirements for software development. Reference when the project handles protected health information (PHI)."
---

# HIPAA — Software Development Guidance

## What It Is

HIPAA (Health Insurance Portability and Accountability Act) is US federal law governing the privacy and security of Protected Health Information (PHI). The Security Rule and Privacy Rule set requirements for any "covered entity" or "business associate" that handles electronic PHI (ePHI). Violations carry significant civil and criminal penalties.

## What Is PHI?

PHI is any individually identifiable health information, including:
- Patient names, addresses, dates (birth, admission, discharge, death)
- Medical record numbers, health plan numbers
- Diagnoses, treatment information, lab results
- Any data that could identify a patient combined with health information

## Key Rules for Developers

### Security Rule — Technical Safeguards (§ 164.312)

| Safeguard | Implementation |
|-----------|---------------|
| **Access Control** (a)(1) | Unique user IDs, emergency access procedure, automatic logoff, encryption |
| **Audit Controls** (b) | Record and examine access to ePHI — who, what, when, where |
| **Integrity Controls** (c)(1) | Protect ePHI from improper alteration or destruction |
| **Transmission Security** (e)(1) | Encrypt ePHI in transit, integrity controls for transmitted data |
| **Authentication** (d) | Verify identity of any person/entity seeking access to ePHI |

### Security Rule — Administrative Safeguards
- Risk analysis required — document threats and vulnerabilities
- Workforce access management — minimum necessary access
- Security incident procedures — detect, respond, document
- Contingency plan — data backup, disaster recovery, emergency operations

### Privacy Rule — Minimum Necessary
- Access only the minimum PHI necessary for the task
- Role-based access controls aligned to job functions
- De-identify data when full PHI is not required

### Breach Notification Rule
- Notify affected individuals within 60 days
- Notify HHS — timing depends on number of individuals affected
- Notify media if breach affects 500+ individuals in a state
- Document breach risk assessment (was PHI actually compromised?)

## Development Checklist

- [ ] ePHI encrypted at rest (AES-256 or equivalent)
- [ ] ePHI encrypted in transit (TLS 1.2+)
- [ ] Role-based access control enforcing minimum necessary
- [ ] Unique user authentication — no shared credentials
- [ ] Automatic session timeout / logoff
- [ ] Comprehensive audit trail for all ePHI access and modifications
- [ ] Audit logs protected from tampering, retained per policy
- [ ] No PHI in application logs, error messages, or debug output
- [ ] Data backup and recovery procedures implemented and tested
- [ ] Breach detection mechanisms in place
- [ ] Business Associate Agreements (BAAs) with all third-party services that handle ePHI
- [ ] De-identification applied where full PHI is not needed

## Cloud Considerations

If using cloud services:
- Ensure the cloud provider offers a BAA (AWS, Azure, GCP all offer them)
- Use HIPAA-eligible services only — not all cloud services are covered
- Azure: Check [HIPAA compliance offerings](https://learn.microsoft.com/azure/compliance/offerings/offering-hipaa-us)
- Encrypt data with customer-managed keys where feasible

## Authoritative Source

- [HHS HIPAA Security Rule](https://www.hhs.gov/hipaa/for-professionals/security/index.html)
- [HHS HIPAA Privacy Rule](https://www.hhs.gov/hipaa/for-professionals/privacy/index.html)
- [NIST SP 800-66 (HIPAA Security Rule Implementation Guide)](https://csrc.nist.gov/publications/detail/sp/800-66/rev-2/final)

> **Important:** This skill provides development-focused guidance only. HIPAA compliance requires administrative, physical, and technical safeguards, plus organisational policies, training, and Business Associate Agreements. Work with your compliance and legal teams.

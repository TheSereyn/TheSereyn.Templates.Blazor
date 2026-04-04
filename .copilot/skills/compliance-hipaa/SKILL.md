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

### Physical Safeguards (§ 164.310)

Physical safeguards protect electronic information systems, buildings, and equipment from natural and environmental hazards and unauthorised intrusion.

#### Facility Access Controls (§ 164.310(a))
- Implement procedures to control physical access to facilities where ePHI is accessible
- Establish contingency operations procedures for facility access during emergencies
- Maintain facility security plans documenting physical access controls
- Validate access authorisation before granting physical access
- Document and maintain records of facility modifications that affect security (e.g., hardware, walls, doors, locks)

#### Workstation Use (§ 164.310(b))
- Define policies for proper workstation use and the physical environment
- Specify acceptable functions, manner of access, and physical surroundings for workstations accessing ePHI
- Position screens to prevent unauthorised viewing of ePHI

#### Workstation Security (§ 164.310(c))
- Implement physical safeguards restricting access to workstations that can access ePHI
- Secure workstations in controlled areas or use cable locks, secured rooms, or similar measures

#### Device and Media Controls (§ 164.310(d))
- **Disposal** — Implement policies for final disposal of ePHI and the hardware/media on which it is stored (e.g., degaussing, secure wiping, physical destruction)
- **Media re-use** — Remove ePHI from electronic media before re-use
- **Accountability** — Maintain records of hardware and electronic media movements, including responsible persons
- **Data backup and storage** — Create retrievable exact copies of ePHI before moving equipment

### Privacy Rule — Minimum Necessary
- Access only the minimum PHI necessary for the task
- Role-based access controls aligned to job functions
- De-identify data when full PHI is not required (see De-identification Methods below)

### De-identification Methods (§ 164.514)

HIPAA provides two methods for de-identifying PHI so that it is no longer subject to HIPAA protections:

#### Safe Harbor Method (§ 164.514(b)(2))
Remove **all 18 specified identifiers** from the data. This is the simpler method and does not require statistical expertise.

The 18 identifiers to remove:
1. Names
2. Geographic data smaller than a state
3. All dates (except year) directly related to an individual (birth, admission, discharge, death, and all ages over 89)
4. Phone numbers
5. Fax numbers
6. Email addresses
7. Social Security numbers
8. Medical record numbers
9. Health plan beneficiary numbers
10. Account numbers
11. Certificate/license numbers
12. Vehicle identifiers and serial numbers
13. Device identifiers and serial numbers
14. Web URLs
15. IP addresses
16. Biometric identifiers
17. Full-face photographs and comparable images
18. Any other unique identifying number, characteristic, or code

The covered entity must also have no actual knowledge that the remaining information could identify an individual.

#### Expert Determination Method (§ 164.514(b)(1))
A qualified statistical or scientific expert applies statistical and scientific principles and methods to determine that the risk of re-identification is very small. Requirements:
- The expert must have appropriate knowledge and experience
- The expert must apply generally accepted statistical and scientific principles
- The expert must determine that the risk is "very small" that the information could be used to identify an individual
- The methods and results of the analysis must be documented

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

---
name: "compliance-gdpr"
description: "GDPR requirements for software development. Reference when the project handles personal data of EU/EEA individuals."
---

# GDPR — Software Development Guidance

## What It Is

The General Data Protection Regulation (EU 2016/679) governs the processing of personal data of individuals in the EU/EEA. It applies to any organisation processing EU personal data, regardless of where the organisation is based. GDPR emphasises privacy by design and by default.

## Key Principles for Developers

### Article 5 — Data Processing Principles
- **Lawfulness** — Every data processing operation needs a legal basis
- **Purpose limitation** — Collect data only for specified, explicit purposes
- **Data minimisation** — Process only the data that is necessary
- **Accuracy** — Keep personal data accurate and up to date
- **Storage limitation** — Don't keep data longer than necessary
- **Integrity and confidentiality** — Protect data with appropriate security

### Article 25 — Data Protection by Design and by Default
- Build privacy into the system architecture from the start
- Default settings should be the most privacy-friendly option
- Only process data necessary for each specific purpose

## Requirements for Developers

### Consent and Legal Basis
- If using consent, implement clear opt-in (no pre-ticked boxes)
- Record consent: who, when, what they consented to, how
- Implement consent withdrawal — must be as easy as giving consent

### Data Subject Rights (Articles 15-22)
Build support for these rights into the system:

| Right | Implementation |
|-------|---------------|
| **Access** (Art. 15) | Export all personal data held about a user |
| **Rectification** (Art. 16) | Allow users to correct their data |
| **Erasure** (Art. 17) | "Right to be forgotten" — delete personal data on request |
| **Restriction** (Art. 18) | Restrict processing while disputes are resolved |
| **Data Portability** (Art. 20) | Export data in a structured, machine-readable format (JSON, CSV) |
| **Object** (Art. 21) | Allow users to object to specific processing |

### Data Protection Impact Assessment (DPIA)
Required for high-risk processing. Document:
- What data is processed and why
- Assessment of necessity and proportionality
- Risks to individuals and mitigation measures

### Breach Notification (Articles 33-34)
- Notify supervisory authority within 72 hours of becoming aware of a breach
- Notify affected individuals without undue delay if high risk
- Log all breaches, even those not requiring notification

### Article 22 — Automated Decision-Making

Individuals have the right not to be subject to decisions based solely on automated processing — including profiling — that produce legal or similarly significant effects. This is critical for AI/ML systems.

**Requirements:**
- Automated decisions with legal or significant effects must provide human review capability
- The data subject must be informed that automated decision-making is taking place
- Provide meaningful information about the logic involved and the significance of the decision
- Implement the ability for a data subject to request human intervention, express their point of view, and contest the decision
- Exceptions exist for contractual necessity, legal authorisation, or explicit consent — but safeguards must still be in place

**Checklist:**
- [ ] Identify all automated decision-making processes with legal or significant effects
- [ ] Implement human review / override capability for automated decisions
- [ ] Provide explainability — users can understand why a decision was made
- [ ] Document the logic, significance, and envisaged consequences of automated processing
- [ ] Implement a mechanism for data subjects to contest automated decisions

### Chapter V — International Data Transfers (Articles 44-49)

Personal data can only be transferred to countries outside the EU/EEA that provide adequate protection. Key mechanisms:

- **Adequacy decisions** — The European Commission has recognised certain countries as providing adequate protection (e.g., Japan, UK, South Korea)
- **Standard Contractual Clauses (SCCs)** — The 2021 version of SCCs is the primary mechanism for EU→US and other international transfers. Implement the appropriate module (controller-to-controller, controller-to-processor, etc.)
- **Binding Corporate Rules (BCRs)** — For intra-group transfers within multinational organisations
- **Specific derogations** — Explicit consent, contractual necessity, or important public interest (narrow exceptions)

**Note:** The Schrems II decision (2020) invalidated the EU-US Privacy Shield. While the EU-US Data Privacy Framework (2023) provides a new adequacy mechanism for certified US companies, organisations should verify their transfer mechanisms are current.

**Checklist for developers:**
- [ ] Identify where personal data is stored and processed (cloud regions, third-party services)
- [ ] Implement data residency controls where required (region-locked storage, processing restrictions)
- [ ] Ensure data transfer mechanisms (SCCs, adequacy decisions) are in place for cross-border flows
- [ ] Document all international data transfers in the record of processing activities
- [ ] Provide configuration options for data residency when deploying to multiple regions

### Article 8 — Children's Data

When offering information society services directly to children, consent is valid only if the child is at least 16 years old (member states may lower the threshold to 13). Below that age, parental or guardian consent is required.

**Requirements:**
- Implement age verification mechanisms for services directed at or likely to be accessed by children
- Obtain verifiable parental consent for users below the applicable age threshold
- Use clear, child-friendly language in privacy notices
- Apply enhanced data minimisation for children's data

**Checklist:**
- [ ] Implement age gate / verification if the service targets or is likely to attract children
- [ ] Obtain and record parental consent for users under the applicable age threshold
- [ ] Privacy notices written in language understandable to the target age group
- [ ] Enhanced data minimisation applied — collect only what is strictly necessary
- [ ] No profiling or automated decision-making directed at children without parental consent

## Development Checklist

- [ ] Personal data inventory — know what personal data the system processes
- [ ] Legal basis documented for each processing activity
- [ ] Data minimisation — only collect and store what's needed
- [ ] Consent mechanism with opt-in, recording, and withdrawal
- [ ] API/endpoints for data subject rights (export, delete, rectify)
- [ ] Data retention policies implemented with automated cleanup
- [ ] Encryption at rest and in transit for personal data
- [ ] Access controls — restrict who can view/process personal data
- [ ] Audit logging for access to personal data (without logging PII in logs)
- [ ] Pseudonymisation where feasible (use opaque IDs, not email/name)
- [ ] Breach detection and notification process documented

## Authoritative Source

- [GDPR Full Text](https://gdpr-info.eu/)
- [European Data Protection Board (EDPB) Guidelines](https://www.edpb.europa.eu/our-work-tools/our-documents/guidelines_en)
- [ICO Guide to GDPR (UK)](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/)

> **Important:** This skill provides development-focused guidance only. GDPR compliance requires organisational measures including Data Protection Officer appointment, privacy policies, data processing agreements, and records of processing activities. Consult your legal/privacy team.

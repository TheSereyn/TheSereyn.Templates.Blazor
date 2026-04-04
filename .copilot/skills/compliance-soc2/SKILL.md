---
name: "compliance-soc2"
description: "SOC 2 Trust Services Criteria for software development. Reference when the project must comply with SOC 2 requirements."
---

# SOC 2 — Software Development Guidance

## What It Is

SOC 2 (System and Organization Controls 2) is an auditing framework developed by the AICPA for service organisations. It evaluates controls based on five Trust Services Criteria: Security, Availability, Processing Integrity, Confidentiality, and Privacy. Most software projects focus on Security and Availability at minimum.

## Trust Services Criteria for Developers

### CC6 — Logical and Physical Access Controls
- Implement authentication and authorization for all system access
- Enforce MFA for administrative access
- Use unique identifiers for all users and services — no shared accounts
- Review and revoke access promptly when no longer needed
- Encrypt data in transit (TLS 1.2+) and at rest

### CC7 — System Operations
- Monitor system components for anomalies
- Implement alerting for security events and availability issues
- Maintain logging sufficient for incident investigation
- Detect and respond to unauthorized changes

### CC8 — Change Management
- All code changes require peer review before merge
- Maintain a change log / audit trail
- Test changes in a staging environment before production
- Separate duties — developers should not deploy their own changes to production without review

### CC9 — Risk Mitigation
- Assess and document risks for third-party integrations
- Vendor dependencies reviewed for security posture
- Business continuity plans for critical system components

### Availability Criteria (A1)
- Define and monitor SLAs/SLOs for the application
- Implement health checks and readiness probes
- Plan for capacity and scaling
- Document recovery time objectives (RTO) and recovery point objectives (RPO)

### Confidentiality Criteria (C1)
- Classify data by sensitivity level
- Encrypt confidential data at rest and in transit
- Restrict access to confidential data on a need-to-know basis
- Securely dispose of data when no longer needed

## Development Checklist

- [ ] Authentication and authorization on all endpoints
- [ ] MFA enforced for admin/privileged access
- [ ] All changes go through PR review with approval
- [ ] CI/CD pipeline includes automated testing and security scans
- [ ] Logging captures access, changes, and security events
- [ ] No PII, tokens, or secrets in logs
- [ ] Data encrypted in transit (TLS) and at rest
- [ ] Health check endpoints implemented
- [ ] Third-party dependencies reviewed and tracked
- [ ] Change management process documented

### Processing Integrity Criteria (PI1)

Processing Integrity addresses whether system processing is complete, valid, accurate, timely, and authorised.

- **PI1.1 — System processing is complete, valid, accurate, timely, and authorised**
  - Validate that processing produces expected outputs from given inputs
  - Implement checksums, reconciliation, and data integrity checks
  - Monitor for processing errors and anomalies
  - Document expected processing behaviour and test against it
- **PI1.2 — System inputs are complete and accurate**
  - Validate all inputs at system boundaries (API endpoints, file uploads, message queues)
  - Reject malformed or incomplete input with clear error messages
  - Log rejected inputs for audit and debugging
- **PI1.3 — System outputs are complete and accurate**
  - Verify output completeness — ensure all expected records/results are produced
  - Implement output reconciliation against input counts or expected totals
  - Protect output integrity during transmission and storage

### Privacy Criteria (P1)

Privacy criteria apply when the system processes personal information.

- **P1.0 — Privacy notice**
  - Provide clear, accessible privacy notices describing data practices
  - Update notices when processing activities change
- **P1.1 — Notice of collection, data use, retention, and disclosure**
  - Inform individuals at or before the point of data collection
  - Specify what personal information is collected, the purposes of processing, how long it is retained, and to whom it may be disclosed
  - Implement consent mechanisms where required
  - Enforce documented data retention schedules with automated cleanup

## Type I vs Type II Reports

| Aspect | Type I | Type II |
|--------|--------|---------|
| **Scope** | Design of controls at a specific point in time | Design AND operating effectiveness of controls over a period |
| **Duration** | Single date (snapshot) | Observation period, typically 6–12 months |
| **Auditor work** | Inspects control descriptions and assesses design suitability | Tests that controls actually operated effectively throughout the period |
| **Use case** | Initial assessment; demonstrates controls exist | Ongoing assurance; demonstrates controls work consistently |
| **Customer expectation** | Acceptable for early-stage companies or first SOC 2 | Preferred by enterprise customers and most procurement processes |

Most organisations start with a Type I report and progress to Type II within 6–12 months.

## Evidence Collection for Audits

SOC 2 auditors require evidence that controls are not just designed but operating. Collect and retain the following:

| Evidence Type | Examples | Retention |
|---------------|----------|-----------|
| **Access review logs** | Periodic access reviews showing who has access, approvals, and revocations | Duration of audit period + 1 year |
| **Deployment records** | CI/CD pipeline logs, deployment timestamps, approval records | Duration of audit period + 1 year |
| **Change approval records** | PR reviews, merge approvals, change tickets with approval chains | Duration of audit period + 1 year |
| **Monitoring alert logs** | Alert triggers, acknowledgements, and resolution records | Duration of audit period + 1 year |
| **Training completion records** | Security awareness training dates, attendee lists, completion certificates | Duration of audit period + 1 year |
| **Incident response records** | Incident tickets, response timelines, root cause analyses, post-mortems | Duration of audit period + 1 year |

**Tips for developers:**
- Automate evidence collection where possible (CI/CD logs, git audit trails, access logs)
- Ensure logs are tamper-resistant (append-only, centralised logging)
- Tag audit-relevant events in your logging system for easy retrieval
- Keep a calendar of periodic controls (quarterly access reviews, annual training) and set reminders

## Authoritative Source

- [AICPA SOC 2 Overview](https://www.aicpa-cima.com/topic/audit-assurance/audit-and-assurance-greater-than-soc-2)
- [Trust Services Criteria (2017, updated)](https://us.aicpa.org/interestareas/frc/assuranceadvisoryservices/trustservicescriteria)

> **Important:** This skill provides development-focused guidance only. SOC 2 compliance requires a comprehensive audit covering organisational policies, procedures, and controls beyond software. Work with your compliance team and auditors.

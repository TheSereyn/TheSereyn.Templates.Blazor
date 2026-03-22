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

## Authoritative Source

- [AICPA SOC 2 Overview](https://www.aicpa-cima.com/topic/audit-assurance/audit-and-assurance-greater-than-soc-2)
- [Trust Services Criteria (2017, updated)](https://us.aicpa.org/interestareas/frc/assuranceadvisoryservices/trustservicescriteria)

> **Important:** This skill provides development-focused guidance only. SOC 2 compliance requires a comprehensive audit covering organisational policies, procedures, and controls beyond software. Work with your compliance team and auditors.

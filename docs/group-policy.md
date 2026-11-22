# Group Policy

Four custom GPOs, each with one job. Account and audit policy apply domain-wide, drive mapping applies to company users, and software deployment applies to workstations only.

## GPO Summary

| GPO | Linked to | Applies to | Purpose |
|---|---|---|---|
| Account Policy | `lab.local` (domain root) | Domain accounts | Password and lockout rules |
| Audit Policy | `lab.local` (domain root) | All computers, including DCs | Security event logging |
| Drive Maps | `ZaidCo\Users` | Company users | Maps the shared department drive |
| Software Policy | `WorkStations` | Workstations only | Deploys 7-Zip |

Default Domain Policy is left unchanged. Account Policy is linked above it at the domain root so its settings win.

---

## Account Policy

Password settings follow NIST SP 800-63B revision 4: length matters more than complexity rules, and passwords don't expire unless there's a sign of compromise.

| Setting | Value | Why |
|---|---|---|
| Minimum password length | 15 characters | NIST rev 4 minimum for single-factor passwords |
| Complexity requirements | Disabled | NIST advises against composition rules; they push users to predictable patterns |
| Maximum password age | 0 (never expires) | NIST advises against forced periodic changes |
| Minimum password age | 1 day | Stops users cycling through history to reuse an old password |
| Password history | 24 | Prevents reuse of recent passwords |
| Relax minimum password length limits | Enabled | Required for minimums above 14 characters |
| Lockout threshold | 10 failed attempts | Stops brute force without locking users out over typos |
| Lockout duration | 15 minutes | |
| Reset lockout counter after | 15 minutes | |
| Allow administrator account lockout | Enabled | The built-in Administrator is the top brute-force target |

Password and lockout policy for domain accounts only takes effect from a GPO linked at the domain root, which is why this GPO lives there and not on an OU.

[Full report](gpo-reports/account-policy.html)

## Audit Policy

Uses Advanced Audit Configuration to log the events a security team would investigate.

| Category | What's logged |
|---|---|
| Account Logon | Credential validation, Kerberos authentication and service tickets |
| Account Management | User, computer, and security group changes |
| Detailed Tracking | Process creation, PnP device activity |
| DS Access | Directory service changes, failed directory access |
| Logon/Logoff | Logons, logoffs, lockouts, special (admin) logons, group membership |
| Object Access | File share access, removable storage |
| Policy Change | Audit, authentication, authorization, and firewall rule changes |
| Privilege Use | Sensitive privilege use |
| System | Security state changes, system integrity, IPsec driver |

Linked at the domain root so it also reaches the Domain Controllers OU, where credential validation and Kerberos events are generated.

[Full report](gpo-reports/audit-policy.html)

## Drive Maps

| Drive | Path | Applies to |
|---|---|---|
| `Z:` | `\\dc01\Departments` | All users in `ZaidCo\Users` |

Every user gets the same drive. NTFS permissions on each department folder decide what they can actually open, so access is still controlled by group membership (see the access matrix in the [build log](build_log.md)).

[Full report](gpo-reports/drive-maps.html)

## Software Policy

| Package | Deployment | Source |
|---|---|---|
| 7-Zip 21.07 (x64) | Assigned to computers | `\\dc01\Software\7z2107-x64.msi` |

Assigned in Computer Configuration, so it installs at workstation startup, before anyone signs in. Linked only to the `WorkStations` OU so it never installs on the domain controller.

[Full report](gpo-reports/software-policy.html)

---

## Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| Account lockout never triggered despite being configured | My policy GPO and Default Domain Policy were both linked at the domain root, and Default Domain Policy won the link order. `Get-ADDefaultDomainPasswordPolicy` showed a lockout threshold of 0 (lockout off) and Microsoft's default password settings. | Moved account settings into a dedicated Account Policy GPO linked above Default Domain Policy |
| One GPO held password, lockout, audit, and drive mapping settings under the name "LockoutPolicy" | Settings were added to whichever GPO was open | Split into single-purpose GPOs with descriptive names |
| 7-Zip GPO was also linked at the domain root, so it reached the DC | Duplicate link | Removed the root link; now linked to `WorkStations` only |

**Lesson:** a GPO being configured doesn't mean it's applied. Check the effective result (`gpresult`, `Get-ADDefaultDomainPasswordPolicy`), not the settings page.

## Lab vs. Production

- 7-Zip 21.07 is outdated. In production the package would be kept current and old versions superseded.
- One shared drive for everyone is simple to manage. Larger orgs often map per-department drives with item-level targeting.

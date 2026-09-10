# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 0.1.x   | ✅ Yes    |

---

## Reporting a Vulnerability

**Please do NOT report security vulnerabilities through public GitHub Issues.**

Security issues in a developer SDK can affect every application that uses it,
so we treat them with the highest priority and confidentiality.

### How to report

Open a [GitHub Security Advisory](https://github.com/pulse-dart/pulse/security/advisories/new)
on this repository. This channel is private and only visible to maintainers.

Please include:

1. **Description** — what the vulnerability is and its potential impact
2. **Steps to reproduce** — a minimal, reproducible example if possible
3. **Affected versions** — which package and version range is affected
4. **Suggested fix** — if you have one, we welcome it

We will acknowledge your report within **48 hours** and provide a detailed
response within **5 business days**, including a timeline for a fix.

---

## Scope

Vulnerabilities we consider in-scope:

- Privacy leakage — SDK collecting or transmitting data it should not
- PII exposure — sensitive user data appearing in event payloads
- Dependency vulnerabilities in `pulse_dev` or `pulse_dev_flutter`
- SDK behavior that could be exploited to crash or destabilize the host app

Out of scope:

- Vulnerabilities in user-provided transports or sanitizers
- Security issues in applications built on top of Pulse
- Theoretical vulnerabilities with no practical attack vector

---

## Disclosure Policy

Once a fix is available, we will:

1. Release a patched version
2. Publish a GitHub Security Advisory with full details
3. Credit the reporter (unless they prefer anonymity)
4. Update this policy if needed

We request **90 days** of embargo before public disclosure to allow users to
update to the patched version.

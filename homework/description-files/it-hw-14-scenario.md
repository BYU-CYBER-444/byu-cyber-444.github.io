---
title: "IT HW 14 - Valley Medical Group Environment Profile"
parent: Homework
nav_exclude: true
---

# Valley Medical Group - Environment Profile
{: .no_toc }

{: .note }
This is the reference scenario for [IT HW 14]({% link homework/it-hw-14.md %}). It gives you the specific facts about Valley Medical Group's facility, staffing, existing network, identity provider, budget, and expected usage your proposal needs to be written against. Don't invent facts that contradict this document, and don't leave obvious gaps unaddressed just because the profile doesn't spell out every detail - a real proposal author would ask follow-up questions or make (and state) a reasonable assumption.

---

## Practice Overview

Valley Medical Group is a single-facility, multi-specialty outpatient practice: 45 physicians, 120 clinical support staff (nurses, medical assistants), and 30 administrative/billing staff. All patient records live in "MedFlow," the practice's existing EHR system - MedFlow itself is a separate system and is **out of scope** for this pilot; do not propose integrating the AI assistant directly into MedFlow.

## IT Staffing

- **IT Director** (1) - reports to the CISO; standard purchase approval authority up to $15,000; anything above requires CFO sign-off.
- **Systems Administrators** (3) - generalist Windows/Linux/network admins, loaded rate **$65/hr**; no dedicated ML/AI engineer on staff. One sysadmin will own this system's setup and ongoing maintenance alongside their existing duties (~20% time allocation planned).
- **CISO** (1) - also serves as the practice's HIPAA Security Officer; final sign-off authority on this system's security architecture (Part 4) and AUP addendum (Part 5).

## Existing Network & Identity

- Managed switching already segmented into VLANs: **VLAN 10** (Clinical Workstations - EHR access), **VLAN 20** (Administrative), **VLAN 30** (Guest Wi-Fi, internet-only), **VLAN 40** (Server/Infrastructure - EHR server, file server, domain controllers). No AI-specific VLAN exists yet - defining one (or justifying reuse of an existing one) is part of your proposal.
- **Firewall:** a Palo Alto Networks NGFW HA pair at the network edge and between VLANs - your firewall rules in Part 4 should be written as PAN-OS-style security policy rules (source zone/interface, destination, service/port, action).
- **Identity provider:** Microsoft Entra ID (Azure AD) - already used for EHR and email SSO. Your authentication design in Part 4 should use this existing IdP rather than standing up a separate identity system.
- Internal DNS suffix: `valleymed.local`.

## Facility & Power Constraints

- On-site server room (not a full data center): **12U of a 42U rack** available for new equipment, existing 6kVA online double-conversion UPS with headroom for the new load, and **one dedicated 20A/208V circuit (~3.3kW usable)** allocated for this project. Your hardware spec in Part 3 must fit within this power and rack-space budget - state explicitly if your proposed server does not fit and what tradeoff that forces.

## Budget

- **Hardware budget ceiling: $30,000**, already approved by the CFO for this pilot - your Part 3/Part 6 figures should work within this ceiling, or explicitly flag if your recommended spec exceeds it and why that's still the right call.

## Pilot Scope & Expected Usage

- Piloting to **3 departments**: Family Medicine, Internal Medicine, and Urgent Care - approximately **40 clinical staff** (physicians + nurses) are eligible users.
- **Expected peak concurrent users: 8-10** (based on shift overlap across the 3 departments) - use this to size concurrent-request handling in Part 3 and network bandwidth requirements.
- **Expected query volume: ~450 queries/day average, ~700 queries/day on peak days** (Monday clinics) - use this figure for your Part 6 cloud-API cost comparison; don't invent a different volume.
- Typical prompt length is a draft clinical note, **150-400 words**, with occasional longer History & Physical (H&P) notes up to **~1,200 words** - relevant to the context-window adequacy question in Part 2.

## Compliance & Incident Response Context

- Existing audit log retention policy for clinical systems is **6 years** - your Part 4 audit log retention decision should match this unless you explicitly justify a deviation.
- The practice already has an incident response escalation chain for the EHR: **IT Director → CISO → COO → outside breach counsel**, notification within **1 hour** of a confirmed incident. Your Part 4 incident response plan should integrate with this existing chain, not invent a parallel one.

---

[← Back to IT HW 14]({% link homework/it-hw-14.md %})

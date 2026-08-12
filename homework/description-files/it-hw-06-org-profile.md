---
title: "IT HW 6 - Riverbend Community Bank Organizational & Vendor Profile"
parent: Homework
nav_exclude: true
---

# Riverbend Community Bank - Organizational & Vendor Profile
{: .no_toc }

{: .note }
This is the reference scenario for [IT HW 6]({% link homework/it-hw-06.md %}). It gives you the staffing, systems, data, and vendor relationships your three policies need to be written against. Don't invent a different employee count, server inventory, or vendor list - use these.

---

## Bank Overview

Riverbend Community Bank (RCB) is a single-branch community bank with a separate back-office/operations center: **40 branch staff** (tellers and personal bankers), **35 loan officers and underwriting staff**, and **30 operations/administrative staff** (105 total workforce members). RCB offers consumer and small-business deposit accounts, consumer loans, and small-business lending - it does not offer investment or brokerage services. All account, deposit, and loan data lives in **CoreLedger**, the bank's core banking platform.

## IT Staffing

- **IT Director** (1) - reports to the CISO; approves standard access requests and policy exceptions up to a routine risk level.
- **Systems Administrators** (3) - `jchen`, `mfoster`, `rpatel` - generalist Windows/Linux/network admins; the only staff with administrative access to servers and network infrastructure.
- **CISO** (1) - also serves as the bank's Information Security Officer for GLBA Safeguards Rule purposes; final sign-off authority on all three policies in this assignment.

## Systems & Data Inventory

**Servers (VLAN 40 - Server/Infrastructure):**

| Hostname | Role |
|---|---|
| `coreledger-web01`, `coreledger-web02` | CoreLedger core banking web/app tier |
| `coreledger-db01` | PostgreSQL 15 - CoreLedger's primary database (deposit accounts, loans, teller transactions) |
| `infra01` | Internal DNS, DHCP, and NTP |
| `backup01` | Nightly backup target + warm-standby PostgreSQL replica |
| `dc01` | Domain Controller, syncs to Microsoft Entra ID via Azure AD Connect |

**Cloud:** One AWS-hosted, non-sensitive system - a public-facing loan pre-qualification calculator (`riverbend-loancalc-web`/`riverbend-loancalc-db`). It collects only an income bracket and a requested loan amount to give a rough rate estimate - no SSN, no actual application, no account data - which is why this specific piece was approved for the cloud.

**Non-technical data on hand** (relevant to Document 2's classification tiers): deposit account and transaction records; loan applications and credit reports; wire transfer instructions; Bank Secrecy Act / Anti-Money Laundering Suspicious Activity Reports (SARs) - which federal law (31 U.S.C. §5318(g)(2)) makes it a crime to disclose to the subject of the report; employee personnel files and background check results; loan underwriting models and credit-scoring criteria; unpublished financial statements and Board meeting minutes; signed vendor contracts; internal training materials and department SOPs; de-identified loan-performance statistics; press releases, published rate sheets, and public website content.

## Network & Identity

- **VLANs:** 10 (Teller/Branch Workstations), 20 (Administrative/Back Office), 30 (Guest Wi-Fi, internet-only), 40 (Server/Infrastructure).
- **Firewall:** Palo Alto Networks NGFW pair (`edge-fw01`) at the network edge and between VLANs.
- **Identity provider:** on-prem Active Directory (`dc01`), synced to Microsoft Entra ID via Azure AD Connect - the same directory used for CoreLedger and email SSO.
- Internal DNS suffix: `riverbendbank.local`.

## Remote Work

Operations/back-office and loan underwriting staff may work remotely up to 2 days/week over VPN, using RCB-issued, MDM-enrolled laptops only. Teller and branch staff have no remote access to CoreLedger or any customer-facing system - all cash-handling and account work happens on-site at the branch.

## Current AI Tool Situation

Riverbend Community Bank has **not** deployed a sanctioned AI tool of its own. What already exists today is the more common, messier real-world problem: individual staff have started using public consumer AI chatbots (ChatGPT, Copilot, Gemini) on their own initiative to help draft customer correspondence, internal memos, and even loan-decision write-ups, with no policy governing it and no data-sharing agreement in place with any of those vendors. Document 1's AI-use section needs to address *this* situation - it should be written generally enough that it still applies once a sanctioned tool exists, rather than naming one that doesn't exist yet. It should also flag the specific risk of an unreviewed AI draft going out as a customer-facing credit decision, given RCB's obligations under the Equal Credit Opportunity Act (Regulation B) to provide legally sufficient reasons for an adverse action.

## Existing Vendor Relationships

Use these as concrete examples when writing Document 3 (Vendor & Third-Party Access Policy) - your policy should be a general process, but it needs to actually work for all of these:

| Vendor | Relationship | Access Needed |
|---|---|---|
| **LedgerStack Financial Systems** | Core banking software vendor | Remote support access to `coreledger-web01/02` and `coreledger-db01` for patching and troubleshooting; will handle customer NPI incidentally during support sessions |
| **Timpanogos IT Solutions** | Regional managed service provider (MSP) | Tier-1 helpdesk and endpoint management for staff workstations across all VLANs; does not normally touch core banking servers |
| **Continental Clearing Corp** | Correspondent bank / ACH & wire processor | Receives a daily batch feed of wire and ACH transaction instructions from `coreledger-db01` to execute interbank transfers |
| **Amazon Web Services (AWS)** | Cloud hosting | Hosts the loan pre-qualification calculator only; AWS support does not have standing access to RCB's on-prem environment |
| **SecureVault Cash Services** | Cash-in-transit and ATM servicing contractor | Physical access to the branch vault and ATM only - no logical/network access of any kind |

---

[← Back to IT HW 6]({% link homework/it-hw-06.md %})

# Acme Corp Acceptable Use Policy

**Version:** 1.1  
**Approved:** October 13, 2026  
**Approved by:** Acme Corp Information Security Committee

## Purpose

This policy establishes acceptable-use requirements for Acme Corp information, systems, accounts, facilities, and equipment. An Information Resource includes a company-managed account, device, network, application, service, record, or data. The policy assigns responsibilities and sets the minimum rules personnel must follow.

## Audience

This policy applies to all Acme Corp employees, temporary workers, contractors, consultants, vendors, and other authorized users, and to every person, device, service, or process that accesses an Acme Corp Information Resource. It also governs the isolated, non-production Security Validation Lab operated by IT Operations and Information Security for configuration validation and administrator training. Lab work must use synthetic data; production credentials and production data are prohibited in the lab.

## Contents

- [Acceptable Use](#acceptable-use)
- [Access Management](#access-management)
- [Authentication/Passwords](#authenticationpasswords)
- [Clear Desk/Clear Screen](#clear-deskclear-screen)
- [Data Security](#data-security)
- [Email and Electronic Communication](#email-and-electronic-communication)
- [Hardware and Software](#hardware-and-software)
- [Internet](#internet)
- [Mobile Devices and Bring Your Own Device (BYOD)](#mobile-devices-and-bring-your-own-device-byod)
- [Physical Security](#physical-security)
- [Privacy](#privacy)
- [Removable Media](#removable-media)
- [Security Training and Awareness](#security-training-and-awareness)
- [Social Media](#social-media)
- [VoiceMail](#voicemail)
- [Incidental Use](#incidental-use)

## Policy

### Acceptable Use

- Personnel must follow this policy and the Acme Corp standards it references whenever they use company Information Resources or conduct company work. Direct questions to the Acme Information Security Committee at security@acme.example.
- Personnel must report a suspected security incident or policy violation to security@acme.example or the Acme Service Desk at servicedesk@acme.example within 15 minutes of discovery. Reports must include the affected person or system, the time discovered, and the known facts. Do not investigate or delete evidence unless the Incident Handling Team directs you to do so.
- Technology incident: an event that interrupts or may interrupt the confidentiality, integrity, or availability of an Acme Corp Information Resource.
- Data incident: suspected loss, theft, unauthorized disclosure, alteration, or destruction of Acme Corp information.
- Unauthorized access incident: suspected access to an Acme Corp account, system, network, facility, or data without approval.
- Facility security incident: suspected damage to, or unauthorized entry into, a facility owned, leased, or managed by Acme Corp.
- Policy violation: an act or omission that does not meet this policy or a standard incorporated into it.
- Personnel must not intentionally:
- harass, threaten, impersonate, or abuse another person;
- disrupt or degrade an Information Resource beyond an approved work task;
- prevent an authorized user from accessing an Information Resource;
- use resources beyond an assigned allocation or without approval;
- circumvent an access control or other policy enforcement measure; or
- access, create, store, or transmit unlawful or sexually explicit content, or content that constitutes targeted harassment.
- Personnel may use security assessment software only when it appears in the Acme Approved Software Catalog and the Information Security Committee has approved the specific system and purpose in a change ticket. Password crackers, packet sniffers, and port scanners are prohibited on company systems unless that ticket explicitly authorizes the named tool, target, operator, and time window.
- Work product created within assigned duties or using Acme Corp Information Resources belongs to Acme Corp, subject to applicable law and written agreements.
- Personnel must use only the encryption methods and company-managed keys specified in the Acme Encryption Standard. The Information Security Committee designates two key custodians for each company-managed encryption key.
- Acme Corp Information Resources are for company business. Limited incidental personal use is allowed only under the Incidental Use section; use for personal financial gain is prohibited.
- Personnel must cooperate with authorized Acme Corp incident investigations and lawful government investigations. They must preserve relevant records and follow the Incident Handling Team’s instructions.
- Personnel must respect applicable copyright, patent, trademark, license, and other intellectual-property requirements when using company resources.

### Access Management

- Access to information must be limited to the access groups listed for that information in the Acme Information Classification and Handling Standard. A manager and the data owner must approve access before it is granted.
- Personnel may use only the account, network address, device, and host assigned to them or explicitly listed in an approved access ticket. Accessing data or programs without authorization is prohibited.
- Remote access to Acme Corp internal systems must use the Acme Secure Access VPN with multifactor authentication. Direct public access to internal systems is not authorized.
- Personnel must not disclose passwords, PINs, security tokens, multifactor codes, private keys, access cards, or other personal authentication factors. Acme support staff will never ask a user to disclose a password or multifactor code.
- Personnel must not share personal authentication information. Each user must use an individual account. A shared service credential is permitted only when an approved service-account record names its owner, authorized custodians, storage location, and rotation date; shared human login accounts are prohibited. Access to Security Validation Lab systems is limited to named, currently authorized personnel on the approved access roster. Access must be removed when authorization ends.
- On each Security Validation Lab system, the file `/etc/acme/roster.txt` (one username per line) is the authoritative access roster for that system; it differs from system to system. Every user on the roster must have exactly one individual account on that system, with a user ID of 1000 or greater, a working login shell (not `/sbin/nologin` or `/bin/false`), and a usable, unlocked password. Every other account with a user ID of 1000 or greater must be disabled by setting its login shell to `/sbin/nologin` and locking its password. Disabled accounts must be kept, not deleted, so their records are preserved. System accounts below user ID 1000 and the built-in `nobody` account are outside this requirement. A password set on a Security Validation Lab account must meet the Authentication/Passwords section.
- Personnel must return company-issued access cards, keys, and security tokens to the Service Desk on their last workday or when access ends, whichever occurs first.
- Personnel must report a lost or stolen access card, key, or security token to security@acme.example within 15 minutes of discovery.
- The Service Desk will record returned, lost, and stolen company-issued access items in the asset register. No fee is charged by this policy.

### Authentication/Passwords

- All personnel must protect personal authentication information. Acme Corp passwords must meet every requirement below; the identity system must enforce these rules for company accounts:
- Passwords must contain at least 14 characters. Passphrases are allowed; no upper/lowercase or symbol-composition rule applies.
- The identity system must reject passwords found on its configured common or compromised-password blocklist and passwords containing the account name or email local-part.
- The previous 24 passwords may not be reused. Passwords do not expire on a schedule; they must be changed promptly after suspected compromise or at the direction of the Incident Handling Team.
- A password used for an Acme Corp account must not be used for a personal account or another organization.
- Each user must use a unique password for each Acme Corp account. The Acme Vault password manager is the only approved password manager.
- Personnel must not disclose account passwords. Acme Corp support staff and contractors must not request them.
- A user who suspects a password is known to another person must change it immediately and report the event to security@acme.example.
- Personnel must not bypass password entry by storing plaintext credentials in scripts, source code, browser fields, or application configuration. Acme Vault may store and autofill passwords.
- Company-issued security tokens must be returned to the Service Desk when requested or when the user’s access ends.

### Clear Desk/Clear Screen

- Personnel must lock their workstation whenever they leave it unattended. Every company-managed workstation, including systems in the Security Validation Lab, must lock automatically after no more than five minutes of inactivity and require the user to authenticate to unlock.
- On Security Validation Lab workstations with a desktop, the screen must be set to go idle after exactly 300 seconds of inactivity, the screen lock must be enabled, and the lock must take effect immediately when the screen goes idle (no grace delay). These settings must be enforced for every user at the system level and locked so that a user cannot change them.
- Internal and Confidential paper records must be placed in a locked cabinet or a locked room when unattended. Restricted paper records must remain in the records room and in a locked cabinet.
- Personnel must secure personal valuables in a locked drawer or take them with them when leaving an assigned workspace.
- File cabinets containing Confidential or Restricted records must remain locked except while an authorized user is retrieving or returning a record.
- Keys, badges, and authentication tokens must remain with their assigned user or in an approved locked storage location.
- Company laptops must be physically secured when unattended. An encrypted laptop may be stored in a locked work area; an unencrypted laptop must be locked in a cabinet or secured with an approved cable.
- Passwords, multifactor codes, and recovery codes must not be written where another person can access them.
- Personnel must retrieve company documents from printers and fax machines immediately. Unattended print jobs containing Confidential or Restricted information must be reported to the data owner.

### Data Security

- Personnel may send Confidential or Restricted information over a public network only using Acme Secure Mail, Acme SecureShare, or another service named in the Acme Approved Services Register. The service must encrypt the content in transit and establish the recipient’s identity.
- Physical shipment of Confidential or Restricted records must use a tracked carrier and tamper-evident packaging. The Acme Information Classification and Handling Standard defines handling by class.
- Only services named in the Acme Approved Services Register may store, share, or transfer Internal, Confidential, or Restricted information.
- Personnel must classify, share, transfer, retain, and dispose of company information according to the Acme Information Classification and Handling Standard. The data owner approves access and any external disclosure.
- Personnel must not discuss Confidential or Restricted information where an unauthorized person can hear the conversation. Approved meeting rooms and Acme Secure Conference are authorized channels.
- A company employee or a carrier listed in the Acme Approved Carrier Register must transport physical Confidential or Restricted records.
- Electronic media containing Confidential or Restricted information must be sanitized or destroyed using the method assigned in the Acme Information Classification and Handling Standard. Contact the Service Desk for a tracked disposal request.

### Email and Electronic Communication

- Personnel must not automatically forward Acme Corp email to an external address. The mail administrator may configure an exception only for an approved business integration recorded in a change ticket.
- Electronic communications must use the sender’s assigned account and must not misrepresent the sender, another person, or Acme Corp.
- Each user is responsible for activity performed through their assigned account. Users must report suspected account misuse immediately.
- Accounts must not be shared. Calendar delegation is permitted only through the calendar application’s named-user delegation feature; sharing the account password is prohibited.
- Personnel must not use personal email to send or receive Internal, Confidential, or Restricted Acme Corp information.
- Limited personal use of company email is allowed only under the Incidental Use section. Personal use must not:
- solicit money, customers, or employees;
- campaign for a political candidate or party using company accounts (except an officially sponsored Acme Corp PAC message);
- make a statement on behalf of Acme Corp without written Communications approval;
- forward chain messages or bulk unsolicited messages;
- promote unlawful conduct or targeted harassment;
- violate applicable law or a company policy;
- disclose company or customer information without authorization; or
- interfere with work or create a direct cost to Acme Corp.
- Personnel may send Confidential or Restricted information only using Acme Secure Mail, Acme SecureShare, or another service in the Acme Approved Services Register.
- Before opening an unexpected attachment or following an unexpected link, personnel must verify the sender through a separate, known channel or report the message using the mail client’s Report Phishing control.
- Automatic replies must not disclose internal phone numbers, employee schedules, customer information, or non-public office locations. The approved out-of-office template contains only dates away and a Service Desk contact.

### Hardware and Software

- IT Management must approve hardware before it connects to an Acme Corp network. The approval record must identify the device owner, asset ID, and permitted network.
- Software on company equipment must appear in the Acme Approved Software Catalog and be installed through Acme IT or the approved software-management service. Only software approved for the assigned business purpose may be installed in the Security Validation Lab. Security assessment tools require prior written approval for the named system, tool, operator, purpose, and time period.
- Security Validation Lab Software Register. The following Linux software (named by RPM package) is prohibited on every Security Validation Lab system and must not be installed on any of them:
  - `nmap` (port scanner)
  - `john` (password cracker)
  - `hydra` (network password cracker)
  - `wireshark-cli` (packet sniffer)
  - `telnet-server` (cleartext remote-access service)
  - `transmission-cli` and `transmission-gtk` (peer-to-peer file sharing)
- The only approved web browser on Security Validation Lab Linux workstations is Mozilla Firefox (RPM package `firefox`), which must be installed. These browsers are prohibited and must not be installed: `chromium`, `google-chrome-stable`, `brave-browser`, `opera-stable`, `microsoft-edge-stable`, and `epiphany`.
- Personnel must keep company equipment physically secured while off site and must report loss or theft within 15 minutes of discovery.
- Personnel traveling to a destination listed on the Acme High-Risk Travel Register must receive written IT Management approval before taking company equipment.
- Personnel must not allow family members, visitors, or other unauthorized people to use Acme Corp Information Resources.

### Internet

- Personnel may use the Internet for company business. Limited personal browsing is permitted only as incidental use under the Incidental Use section. Personal social media, streaming entertainment, recreational games, sexually explicit material, and unauthorized access attempts are prohibited on company resources. Security Validation Lab workstations must use the company-managed browser approved for their assigned role. Access to personal social-media and entertainment-streaming services from those workstations is prohibited.
- Firefox on Security Validation Lab workstations must be managed through its enterprise policy file, `/etc/firefox/policies/policies.json`, which must be valid JSON and must block these three site patterns under `policies` > `WebsiteFilter` > `Block`: `*://*.facebook.com/*`, `*://*.tiktok.com/*`, and `*://*.netflix.com/*`.
- Personnel must not send Internal, Confidential, or Restricted information over the Internet unless an approved service encrypts the content in transit and verifies the recipient’s identity.
- Prohibited Internet use includes:
- streaming entertainment or recreational game services;
- personal social-media services;
- accessing or distributing unlawful or sexually explicit material;
- attempting to access a network, account, or computer without authorization; and
- any activity prohibited by this policy.
- The same rules apply when personnel use a company-owned device outside an Acme Corp facility.

### Mobile Devices and Bring Your Own Device (BYOD)

- Acme Corp does not permit personally owned devices to connect to the internal network or to store company information. Only company-owned, IT-managed mobile devices may access Acme Corp email or Information Resources.
- Company-owned mobile devices that access Acme Corp services must use a PIN or password of at least 6 digits/characters and lock after no more than 300 seconds of inactivity.
- Company mobile devices that store Confidential or Restricted information must use full-device encryption under the Acme Encryption Standard. Personal devices may not store company information.
- Loss or theft of a mobile device used for company information must be reported to security@acme.example within 15 minutes of discovery.
- IT-managed mobile devices must install critical security updates within 14 calendar days of release and other supported updates within 30 calendar days. Unsupported devices may not access company information.
- Personnel must use mobile devices lawfully and in accordance with this policy.
- Rooted or jailbroken devices may not access Acme Corp Information Resources.
- Acme Corp may remotely lock or erase a company-owned device that is lost, stolen, or involved in a confirmed security incident. IT records the action and its reason.
- The Security Team may temporarily collect a company-owned mobile device during a documented incident investigation.
- Acme Corp logs access to company-managed mobile services. Access to message content is governed by the Privacy section.
- IT supports company-owned mobile devices. Personal devices are not eligible for Acme Corp IT support.
- All mobile-device use must follow this policy. IT Management may revoke access after a documented violation.
- Personnel must not text or email while driving on company time or while using a company vehicle. Hands-free calling is permitted where law allows.

### Physical Security

- Recording equipment, including cameras and microphones, is prohibited in a secure area unless the facility owner has approved it in writing for a named business task.
- Personnel must display their Acme Corp photo ID while in an Acme Corp facility and must badge individually through access-controlled doors.
- Personnel must not tailgate, prop open a secured door, or lend a badge. Visitors must sign in and remain with an assigned host in access-controlled areas.
- Food and drink are prohibited in designated data-center rooms. In other work areas, personnel must keep food and drink away from equipment.

### Privacy

- Acme Corp systems and networks are company resources, not private communication channels. Acme IT may collect system, network, and account logs to operate and protect the service. Access to message or file content requires a documented business, security, legal, or HR purpose and approval from the system owner plus Legal or Human Resources.
- Acme Corp may review information stored on or transmitted through company systems for an approved business, security, legal, or HR purpose. The review must be logged with the requester, approver, scope, and date.
- Administrators may access information beyond a standard user’s permissions only to perform an assigned task. They must not inspect unrelated user content.

### Removable Media

- Removable media may be used for Acme Corp information only when a manager and IT approve the business case before use and the device is entered in the Removable Media Register.
- Only company-owned removable media listed in the Removable Media Register may be used. Personal and unknown-origin media are prohibited. Removable mass-storage media is not approved for use in the Security Validation Lab.
- On Security Validation Lab systems, the prohibition on removable mass storage must be enforced technically: the `usb-storage` kernel driver must be configured so that any attempt to load it fails (blocking only automatic loading is not sufficient), it must not be loaded, and no USB storage device may be present or mounted. On workstations with a desktop, the desktop's `automount` and `automount-open` settings must be false, enforced for every user at the system level and locked so that a user cannot change them.
- Personnel must not connect removable media until IT has recorded its owner, serial number, approval ticket, permitted data class, and return or destruction date.
- Confidential or Restricted information on approved removable media must be encrypted using the Acme Encryption Standard. Internal information may be stored only when the approval record permits it.
- Approved removable media must be kept in a locked cabinet when not in active use.
- Loss or theft of removable media must be reported to security@acme.example within 15 minutes of discovery.

### Security Training and Awareness

- New personnel must complete Acme Corp security-awareness training before account activation or within 30 calendar days after activation, whichever occurs first. Until completion, access is limited to the training system.
- Before account activation, each person must acknowledge the current Acme Corp information-security policies in the training portal.
- All personnel must complete annual security-awareness training by December 31 each calendar year.

### Social Media

- Personnel are responsible for content they publish online. Company information may not be published from a personal account.
- A public social-media account that represents Acme Corp or could reasonably appear official requires written Communications Director approval before creation.
- When personnel discuss Acme Corp matters in a personal capacity, they must identify themselves and include this disclaimer: “I am speaking for myself; my views do not represent Acme Corp.” They must not imply company endorsement.
- Personnel must not misrepresent their role or authority at Acme Corp.
- The required disclaimer must accompany every personal post that discusses Acme Corp, its products, customers, or business.
- Published content must comply with applicable law, including copyright, privacy, and financial-disclosure requirements.
- Acme Corp will not publish or endorse content that targets a person or group based on a legally protected characteristic.
- Personnel must not publish Confidential or Restricted information, internal communications, non-public financial or operational information, or customer personal information.
- Personnel authorized to post to Acme Corp social-media accounts must follow the Social Media Posting Procedure and its approval log.

### VoiceMail

- Personnel must not disclose Confidential or Restricted information in a voicemail greeting or message. A greeting may include the employee’s name, department, and Service Desk contact only.
- Personnel may access another user’s voicemail only when the account owner and system owner have approved delegation in writing.
- Voicemail containing Confidential or Restricted information must be deleted after it has been transferred to an approved record system.

### Incidental Use

- Acme Corp permits limited incidental personal use of company email, Internet access, printers, and copiers by employees and contractors with active accounts. Incidental use must meet all requirements below:
- Incidental use does not extend to family members, visitors, or other people without an Acme Corp account.
- Incidental use must not create a direct cost to Acme Corp, interfere with assigned work, or consume more than 30 minutes per workday.
- Incidental use must not contain solicitation, bulk messaging, prohibited content, or company/customer information sent to an unauthorized recipient.
- Personnel may store personal files on company systems only in the designated Personal folder, up to 100 MB per user. Personal email and voicemail must be deleted within 90 days.
- All information stored on Acme Corp Information Resources belongs to Acme Corp unless a written agreement states otherwise. Access and disclosure remain subject to the Privacy section and applicable law.

## References

- ISO 27002: 6, 7, 8, 9, 11, 12, 13, 16, 18
- NIST CSF: PR.AC, PR.AT, PR.DS, DE.CM, DE.DP, RS.CO
- Asset Management Policy
- Encryption Management Policy
- Encryption Standard
- Identity and Access Management Policy
- Incident Management Policy
- Information Classification and Management Policy
- Mobile Device Acknowledgement
- Personnel Security and Awareness Policy
- Physical Security Policy
- Social Media Management Procedure

## Waivers

A waiver request must identify the requirement, business reason, affected systems and users, proposed compensating controls, accountable owner, and requested end date. The Information Security Committee must approve the request in writing before the exception begins. A waiver expires no later than 90 calendar days after approval and must be renewed in writing.

## Enforcement

Personnel found to have violated this policy may be subject to disciplinary action, up to and including termination of employment, and related civil or criminal penalties.

Any vendor, consultant, or contractor found to have violated this policy may be subject to sanctions up to and including removal of access rights, termination of contract(s), and related civil or criminal penalties.

## Version History


| Version | Modified Date | Approved Date | Approved By | Reason/Comments |
| --- | --- | --- | --- | --- |
| 1.0 | October 12, 2026 | October 12, 2026 | Acme Corp Information Security Committee | Initial issue |
| 1.1 | October 13, 2026 | October 13, 2026 | Acme Corp Information Security Committee | Security Validation Lab: added the roster, software register, browser and site-filter, removable-media, and screen-lock specifics |

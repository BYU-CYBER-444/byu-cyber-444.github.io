---
title: "IT HW 8 - Meridian Financial Services Data Center Site Survey"
parent: Homework
nav_exclude: true
---

# Meridian Financial Services - Data Center Site Survey Findings
{: .no_toc }

{: .note }
This is the reference site survey for [IT HW 8]({% link homework/it-hw-08.md %}). You are an IT infrastructure consultant hired to assess Meridian Financial Services' primary data center. The facility hosts core banking applications, trading systems, and customer data for a mid-size regional bank (350 employees, $2.1B AUM). A regulatory audit has flagged concerns about availability and physical security. Use these findings directly - don't invent different specifications.

---

## Power Infrastructure

- Utility feed: single feed from local utility substation (15 MVA capacity)
- UPS: two APC Symmetra 80kVA units, configured A/B feeds to PDUs
- Transfer time between UPS and utility: 8ms (double conversion)
- Generator: one 200kW Caterpillar diesel generator with 72-hour fuel tank
- Generator auto-transfer: ATS with 12-second transfer time
- PDU configuration: two PDUs per rack row; single-corded servers (no dual PSUs)
- Measured power: IT equipment draw = 180kW; total facility power = 306kW

## Cooling Infrastructure

- CRAC units: 6 × 30-ton precision AC units (5 operational, 1 redundant)
- Airflow: cold aisle containment installed in rows 1-4; rows 5-8 have no containment
- Hot aisle: open, exhausting to raised floor plenum
- Average inlet temperature: 75°F (measured)

## Physical Security

- Perimeter: card-access double door at main entrance (mantrap)
- Camera coverage: lobby, main entrance, server room entrance - no cameras inside the server room
- Server room access: badge + PIN
- Visitor policy: visitors escorted by any employee with badge access (not specifically trained security/facilities staff)
- Rack security: racks without doors (open frame)
- Media destruction: shredder on-site; no dedicated media destruction chain-of-custody log

## Network Infrastructure

- ISP connections: primary fiber (1Gbps) from ISP-A; no secondary ISP
- BGP: not configured; single default route to ISP-A
- Internal switching: dual Cisco Nexus 5000 core switches, VSS configured
- Edge firewall: single Palo Alto PA-3250 (no HA configured)

## Out-of-Band Management

Every server in the rack has an IPMI/iDRAC card. The following excerpt is from Meridian's iDRAC configuration export:

```
iDRAC Network Settings:
  IP Address: 10.0.0.50 (same VLAN as production application servers)
  IPMI over LAN: Enabled
  Web interface: HTTPS, self-signed certificate (never replaced since factory install)
  Local users:
    root / calvin          <- factory default account, still active
    svc-monitor / Monitor123
  SNMP: v1 enabled, community string "public"
  Firmware version: 2.10.10.10 (released 4 years ago; current is 6.10.30.20)
```

## Staffing & Maintenance

- On-site facilities staff: a 2-person team, on-site 7 AM-7 PM weekdays only. No 24/7 on-site presence.
- After-hours coverage: facility alarms/monitoring page an on-call vendor contract with a 4-hour on-site response SLA.
- Spare parts: no spare CRAC compressor or major UPS module is kept on-site. Replacement parts ship under the vendor support contract - next-business-day for UPS components, 48-72 hours for CRAC compressor parts.

---

[← Back to IT HW 8]({% link homework/it-hw-08.md %})

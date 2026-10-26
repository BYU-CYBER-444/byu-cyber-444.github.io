---
title: "IT LAB 8 - Data Center Site Survey Exercise"
parent: Labs
nav_order: 8
---

# IT LAB 8 - Data Center Site Survey Exercise
{: .no_toc }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Break and repair a data center's power chain in openDCIM, and measure what each failure takes down
- Calculate UPS, generator, and PUE numbers from real telemetry instead of a spec sheet
- Find cooling hot spots in sensor data and put a number on fixing them
- Log in to a factory-default out-of-band management controller (BMC), see what an attacker could do, then lock it down and prove it

---

## Tools Required

- Your instructor has provisioned a Rocky Linux 9 VM for this lab, `lab08-dc` (2 vCPU, 2GB RAM). Deploy it yourself in Discord using `/deploy` and selecting `it-lab-08`. Your username is your Net ID and your password is the one emailed to you at the start of the semester. It's reachable at `172.19.x.27` (`x` = your subnet's third octet, same addressing scheme as your other lab VMs).
- It comes pre-loaded with everything this lab uses:
  - **openDCIM**, an open-source data center infrastructure management (DCIM) tool, already filled in with Meridian's racks, PDUs, power panels, and devices. Open `http://172.19.x.27/dcim/` in your browser and log in with your Net ID and the same password. If your browser can't reach the VM directly, tunnel to it: `ssh -L 8080:127.0.0.1:80 <netid>@172.19.x.27`, then open `http://localhost:8080/dcim/`.
  - Two telemetry files in `/opt/meridian/`: `telemetry_power.csv` and `telemetry_inlet.csv`.
  - A simulated **BMC** (the management controller inside a server), listening on UDP 623, plus `ipmitool` and the Net-SNMP tools (`snmpget`, `snmpwalk`).

{: .note }
Real out-of-band management hardware (an iDRAC or iLO card) isn't something most students have access to, so the BMC here is a simulator (OpenIPMI's `ipmi_sim`). It speaks the real IPMI protocol and `ipmitool` talks to it exactly as it would to a real card. Always add `-C 3` to your `ipmitool -I lanplus` commands; the simulator only supports cipher suite 3.

---

## Background

Uptime Institute **Tier III** means every power and cooling path can be maintained without downtime, with no single point of failure (SPOF). **PUE** (Power Usage Effectiveness) = total facility power / IT equipment power; enterprise average is about 1.58 and hyperscalers reach 1.1-1.2.

---

## Scenario: Meridian Financial Services Data Center

You are an infrastructure consultant assessing Meridian Financial Services' primary data center (core banking, trading systems, customer data) against Tier III. A regulator has flagged availability and physical security. Its facility specifications:

- **Power:** one utility feed (15 MVA); two 80kVA UPS units (A/B) feeding two PDUs per rack; 8ms UPS transfer; one 200kW diesel generator with a 72-hour tank (14.5 gal/h at 200kW) and a 12-second ATS transfer; **IT servers are single-corded** (one power supply each).
- **Cooling:** 6 × 30-ton CRAC units (5 running, 1 spare); cold-aisle containment on rows 1-4, none on rows 5-8; IT load 180kW, total facility load 306kW.
- **Physical:** mantrap at the entrance; cameras in the lobby, entrance, and server room doorway but **none inside the server room**; badge + PIN to the server room; visitors may be escorted by **any** badged employee; **open-frame racks**; a shredder with **no media destruction log**.
- **Network:** one ISP (no BGP), dual Nexus cores, one edge firewall with no HA.

Record everything below in one file on your VM, `it-lab08-report.md`: commands you ran, their output, and your short answers.

---

## Procedure

### Part 1 - Break the power chain (openDCIM)

openDCIM models Meridian's power as: **Utility Feed 1** (the source) feeding two panels, **UPS-A output** and **UPS-B output**, each feeding one PDU per rack (`R1-PDU-A`, `R1-PDU-B`, ... through row 8). Every device is plugged into a specific PDU outlet.

**1.1 Look around.** Search for `R1-CH1` (the *Search by Name* box) and open the device. Find its power connections and note which PDU it is plugged into, then open its cabinet, **R1**, and look at every device in it and which PDU each uses.

**1.2 Fail things on purpose.** Open **Reports → Simulated Power Outage Report**, pick *Meridian Primary DC*, and run it three times: once with panel **UPS-A output** checked, once with **UPS-B output**, and once with the source **Utility Feed 1** checked (tick *Only show down/unknown devices* if you like). Each run downloads a spreadsheet; open the **Affected Devices** sheet. A row highlighted red has lost every one of its power supplies.

For each of the three runs, record in your report: how many devices are fully down, and how many are on reduced redundancy (one of two supplies down).

**1.3 Find the weak devices.** Run **Reports → Diverse Power Exceptions Report**. Record which kinds of devices it lists and why.

**1.4 Interpret.** In three to five lines in your report: (a) roughly what share of the 180kW IT load does losing UPS-A take down? (device wattages are in each device's record); (b) which single failure takes down everything, and why can't a Tier III facility have it; (c) which Tier can Meridian honestly claim today, with at least three data points from above.

**1.5 Fix it.** Make the three blade chassis in rack R1 (`R1-CH1`, `R1-CH2`, `R1-CH3`) dual-corded: for each, edit the device, set *Power Connections* to **2**, click *Update*, then connect the new second power port to an unused outlet on the **other** side's PDU (a chassis on `R1-PDU-A` gets its second supply on `R1-PDU-B`, and vice versa). Re-run the outage report for UPS-A and for UPS-B and confirm none of the three chassis is fully down in either. Put a screenshot of the R1 rows from both runs in your report.

---

### Part 2 - UPS and generator math

Write a short script (Python or shell, 10-15 lines) on your VM that prints each of these from the facility numbers above. Save it as `~/power.py` (or `.sh`) and paste its output into your report.

- UPS capacity: 2 × 80kVA at 0.9 power factor, in kW. Is it enough for 180kW? What is available if one UPS fails (N+1)? What IT load can each UPS safely carry at 80%?
- Generator: the shortfall (in kW) against the 306kW facility load. Because cooling must keep running, the generator can only carry IT load at the facility's current PUE: what IT load is that (200kW / PUE)? What share of the real 180kW IT load must be shed?
- Fuel: the tank holds 72 hours × 14.5 gal/h. How many gallons, and how long does it last at 200kW?

Then list five loads you would shed first on a generator transfer, in order, and one line on why for the first and last.

---

### Part 3 - PUE and cooling from telemetry

`/opt/meridian/telemetry_power.csv` has 24 hourly readings (IT, cooling, other, and total kW). `/opt/meridian/telemetry_inlet.csv` has 24 inlet-temperature sensor readings, three per row. Use `awk`, `python3`, or a spreadsheet; show the commands.

```bash
head /opt/meridian/telemetry_power.csv
column -s, -t /opt/meridian/telemetry_inlet.csv | head
```

1. Compute the 24-hour average IT load, average total load, and PUE. Which hour has the worst PUE?
2. Compute the annual cost of running at your PUE instead of 1.4: `(PUE_actual - PUE_target) × IT_kW × 8760 × $0.12`.
3. ASHRAE's recommended inlet range is 64.4-80.6°F (allowable range for class A2 is 50-95°F). List every sensor above 80.6°F. Which rows are they in, and what do those rows have in common? Is any sensor outside the allowable range?
4. Containment on rows 5-8 should cut PUE by 0.15-0.25. Using your numbers from step 2, what is the annual saving at each end of that range? The curtains cost about $8,000 per row; how many months until they pay for themselves at each end?

---

### Part 4 - Physical security findings

From the facility specifications, write five findings, one line each: `finding | severity (Critical/High/Medium/Low) | fix`. Cover the missing cameras inside the server room, the escort policy, the open-frame racks, the media destruction log, and one more of your choosing. In openDCIM, open the R1 cabinet record and note what it says about the rack model and its lock.

---

### Part 5 - Out-of-band management: attack, then harden

Every server has a BMC: a small computer with its own network port that can power the server on and off even when the OS is dead. It's also one of the most commonly forgotten, under-hardened parts of a data center. Meridian's is still on factory settings. Work from a shell on `lab08-dc`.

**5.1 Recon.** What is listening, and who is allowed to reach it?

```bash
sudo ss -ulnp | grep -E ':(623|161)\b'
sudo firewall-cmd --list-all
```

**5.2 Attack.** Log in with the factory-default account and see what an attacker gets:

```bash
ipmitool -I lanplus -C 3 -H 127.0.0.1 -U root -P calvin user list 1
ipmitool -I lanplus -C 3 -H 127.0.0.1 -U root -P calvin chassis power status
ipmitool -I lanplus -C 3 -H 127.0.0.1 -U root -P calvin sel list
```

Try the other doors too:

```bash
ipmitool -I lanplus -C 3 -H 127.0.0.1 -U svc-monitor -P Monitor123 chassis power status
ipmitool -I lanplus -C 3 -H 127.0.0.1 -U '' -P '' chassis power status      # anonymous "null" user
snmpwalk -v1 -c public 127.0.0.1 system
```

Now do the damage an attacker could do: power the server off and back on (`chassis power off`, then `chassis power on`; this simulator doesn't bring a `power cycle` back up by itself), and look at the SEL (system event log) afterwards. In your report, list every way you got in, and write one sentence each on what an attacker could do with it.

**5.3 Harden.** Fix all of these, then re-run every command from 5.2:

1. **Credentials.** Create a named admin account of your own (users 1-4 are taken; use ID 5):

   ```bash
   A="ipmitool -I lanplus -C 3 -H 127.0.0.1"
   $A -U root -P calvin user set name 5 <your-admin-name>
   $A -U root -P calvin user set password 5 '<a-strong-password>'
   $A -U root -P calvin user priv 5 4 1
   $A -U root -P calvin user enable 5
   ```

   Then, logged in as your new account, disable `root` (ID 2), `svc-monitor` (ID 3), and the anonymous user (ID 1) with `user disable <id>`. **Leave user 4 (`ta`) alone**; it is how the TA checks your work.
2. **Network placement.** The BMC and SNMP ports are open to every source, as if the management controller sat on the production VLAN. Remove the plain `623/udp` and `161/udp` ports and allow them only from a management network, `10.99.0.0/24`, using firewalld rich rules (`firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.99.0.0/24" port port="623" protocol="udp" accept'`, then `--reload`).
3. **SNMP.** Remove the `rocommunity public` line from `/etc/snmp/snmpd.conf`, create an SNMPv3 user with authentication and encryption (`sudo systemctl stop snmpd`, `sudo net-snmp-create-v3-user -ro -A <auth-pass> -a SHA -X <priv-pass> -x AES meridian`, `sudo systemctl start snmpd`), and show it working with `snmpget -v3 -l authPriv -u meridian -a SHA -A <auth-pass> -x AES -X <priv-pass> 127.0.0.1 SNMPv2-MIB::sysDescr.0`.

**5.4 Prove it.** In your report, show that: `root/calvin`, `svc-monitor/Monitor123`, and the anonymous login now fail; your new account works; `snmpwalk -v1 -c public` and `-v2c` get no answer while your SNMPv3 query works; and `firewall-cmd --list-all` shows 623/udp and 161/udp only through your rich rules.

---

### Part 6 - One-page summary

At the end of `it-lab08-report.md`, in under 150 words: the tier Meridian can claim today, the top three risks (use your measurements: devices lost, kW short, °F over, how the BMC was compromised), and an overall readiness rating (Red/Yellow/Green).

---

## Deliverables

- `it-lab08-report.md` containing, in order: the Part 1 outage-run counts, diverse-power findings, interpretation, and screenshot of the fix; the Part 2 script output and shed list; the Part 3 commands and answers; the Part 4 findings; the Part 5 attack and proof-of-hardening output; the Part 6 summary
- `~/power.py` (or `.sh`) from Part 2

---

## Grading

Part 1's chassis fix and all of Part 5's hardening are checked directly on your VM; the rest is graded from your report.

| Item | Points |
|------|--------|
| Part 1 - outage runs, diverse-power findings, tier call | 10 |
| Part 1 - R1 chassis dual-corded (checked live) | 15 |
| Part 2 - UPS, generator, and fuel calculations (correct math required) | 15 |
| Part 3 - PUE, annual cost, hot-spot sensors, containment payback | 15 |
| Part 4 - five physical security findings | 10 |
| Part 5 - BMC hardening: default root, svc-monitor and anonymous logins refused, a named admin works, IPMI and SNMP ports restricted, SNMP v1/v2c `public` refused (checked live) | 30 |
| Part 6 - one-page summary | 5 |
| **Total** | **100** |

[← Back to Labs]({{ site.baseurl }}/labs/)

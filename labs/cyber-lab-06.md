---
title: "CYBER LAB 6 - OpenSCAP & DISA STIG Assessment"
parent: Labs
nav_order: 6
---

# CYBER LAB 6 - OpenSCAP & DISA STIG Assessment
{: .no_toc }

**Duration:** ~3.75 hours &nbsp;·&nbsp; **Week:** Week 6 &nbsp;·&nbsp; **Track:** Cyber
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Run a full OpenSCAP STIG scan and interpret findings by severity category
- Remediate all CAT I (HIGH) findings with verified, documented commands
- Create an OpenSCAP tailoring file to suppress operationally-inapplicable rules
- Import results into STIG Viewer and export a properly completed checklist (`.ckl`)
- Verify remediations do not break the running system by testing affected services post-remediation
- Design and implement a zoned `nftables` firewall ruleset enforcing network segmentation beyond a flat default-deny policy

---

## Tools Required

- Ubuntu 22.04 LTS VM
- OpenSCAP (`openscap-scanner`, `ssg-debderived`)
- SCAP Security Guide (SSG)
- STIG Viewer 2.x (download from public.cyber.mil)
- `scap-workbench` (optional, for tailoring file creation GUI)
- `nftables` (Part 6)

```bash
sudo apt install openscap-scanner ssg-debderived nftables -y
```

---

## Procedure

### Part 1 - Initial STIG Scan

Run the scan with the STIG profile and save results in multiple formats:

```bash
oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_stig \
  --results lab6-results.xml \
  --results-arf lab6-arf.xml \
  --report lab6-report.html \
  /usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml

echo "Scan complete. Exit code: $?"
```

The exit code will be non-zero (2 = findings present, 1 = error). Open `lab6-report.html` and record:
- Total rules evaluated
- Number of PASS / FAIL / NOT APPLICABLE / ERROR
- Count of HIGH (CAT I), MEDIUM (CAT II), LOW (CAT III) failures

List all HIGH severity failures - these become your mandatory remediation list.

### Part 2 - CAT I Remediation

For EACH CAT I finding:

1. Read the full rule description in the HTML report (or STIG Viewer)
2. Apply the specific remediation command(s) - document exactly what you ran
3. Test that the service or system function is still working after each remediation

Common CAT I findings and remediation approach (check your actual results - they vary):

**SSH Protocol 2 enforcement:**
```bash
grep -q "^Protocol" /etc/ssh/sshd_config || echo "Protocol 2" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl reload sshd && ssh -o StrictHostKeyChecking=no localhost 'echo SSH OK'
```

**Root SSH login disabled:**
```bash
sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl reload sshd
```

**AIDE (if flagged as not configured):**
```bash
sudo apt install aide -y && sudo aideinit && sudo cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db
```

For each remediation, document:
- Rule ID (STIG rule ID, format: `xccdf_org.ssgproject.content_rule_...`)
- Finding title
- Exact command(s) applied
- Service/function verification command and output

### Part 3 - Create a Tailoring File

Some STIG rules are inapplicable in your lab environment (e.g., rules requiring a GUI when you have a server install, or rules about specific hardware). Create an OpenSCAP tailoring file to suppress these rules rather than having them show as failures:

Create `lab6-tailoring.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<xccdf:Tailoring xmlns:xccdf="http://checklists.nist.gov/xccdf/1.2"
    id="xccdf_lab6_tailoring_default">
  <xccdf:benchmark href="/usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml"/>
  <xccdf:version time="2025-01-15T12:00:00">1</xccdf:version>
  <xccdf:Profile id="xccdf_lab6_profile_stig_tailored"
      extends="xccdf_org.ssgproject.content_profile_stig">
    <xccdf:title>STIG - Lab Tailored</xccdf:title>
    <xccdf:description>STIG profile with lab-inapplicable rules suppressed</xccdf:description>

    <!-- Suppress this rule if running server (no GUI) -->
    <!-- Replace RULE_ID with the actual rule ID from your scan results -->
    <xccdf:select idref="xccdf_org.ssgproject.content_rule_RULE_ID_HERE" selected="false"/>
  </xccdf:Profile>
</xccdf:Tailoring>
```

Identify at least 2 rules that are genuinely inapplicable to your headless server environment. Add them to the tailoring file with a comment explaining why each is suppressed.

Run the scan with the tailoring file:

```bash
oscap xccdf eval \
  --tailoring-file lab6-tailoring.xml \
  --profile xccdf_lab6_profile_stig_tailored \
  --results lab6-tailored-results.xml \
  --report lab6-tailored-report.html \
  /usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml
```

Compare the tailored scan score to the original - the "improvement" from tailoring is separate from actual remediation.

### Part 4 - Post-Remediation Verification Scan

Run a final scan to verify all CAT I items are resolved:

```bash
oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_stig \
  --results lab6-post-results.xml \
  --report lab6-post-report.html \
  /usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml
```

Build a remediation tracking table:

| Rule ID | Title | CAT | Pre-Status | Post-Status | Verified |
|---|---|---|---|---|---|
| rule_sshd_disable_root_login | SSH Root Login Disabled | I | FAIL | PASS |  |

All CAT I findings must show PASS. If any remain FAIL, document why and what the next step is.

### Part 5 - STIG Viewer Checklist Export

1. Download STIG Viewer 2.x from public.cyber.mil
2. Import your ARF results file (`lab6-arf.xml`): **File → Import XCCDF Results**
3. For each Open finding:
   - Set Status: **Open** / **Not a Finding** / **Not Applicable**
   - Add a Finding Detail comment explaining the current state
   - Add a Comments field for remediated items explaining what was done
4. Export the completed checklist: **File → Export → CKL file** → `lab6-completed.ckl`

### Part 6 - Network Segmentation with nftables

Week 2's firewall coverage was a flat default-deny ruleset - one policy for the whole host. Real network security design segments hosts into zones with different trust levels, not one blanket rule. Build a zoned ruleset for this VM, imagining it hosts a web application with a separate database backend:

```bash
sudo nft flush ruleset

sudo tee /etc/nftables.conf << 'EOF'
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        # Loopback and established connections always allowed
        iif lo accept
        ct state established,related accept
        ct state invalid drop

        # Management zone: SSH only from the admin subnet
        ip saddr 10.0.0.0/24 tcp dport 22 accept

        # Web zone: HTTP/HTTPS from anywhere
        tcp dport { 80, 443 } accept

        # Database zone: 5432 only from the app-tier subnet, never from the internet
        ip saddr 10.0.1.0/24 tcp dport 5432 accept

        # ICMP for diagnostics, rate-limited
        ip protocol icmp limit rate 5/second accept

        # Everything else is dropped by the chain policy - log it first
        log prefix "nft-dropped: " drop
    }
}
EOF

sudo nft -f /etc/nftables.conf
sudo systemctl enable nftables
```

**Test the zones actually hold:**

```bash
# From the admin subnet - should succeed
nc -zv <this-vm-ip> 22

# From outside the admin subnet (or use a second network namespace to simulate it) - should be dropped
sudo ip netns add outsider
# ... configure outsider netns on a different subnet, then:
sudo ip netns exec outsider nc -zv <this-vm-ip> 22   # should time out / be dropped

# Database port should never be reachable except from the app-tier subnet
nc -zv <this-vm-ip> 5432
```

Capture the ruleset (`sudo nft list ruleset`), the dropped-connection log entries (`journalctl -k | grep nft-dropped`), and the results of each test above (which succeeded, which were dropped).

{: .note }
This is the same "default-deny, explicit allow" principle from Week 2, applied per-zone instead of per-host - it's a small step from here to full VLAN-based segmentation, which is what the Graduate Extension below covers.

---

## Submission Requirements

- Initial scan HTML report (with CAT I findings highlighted)
- Remediation log: for each CAT I finding - Rule ID, description, exact commands, verification output
- `lab6-tailoring.xml` with explanation of each suppressed rule
- Post-remediation HTML report
- Before/after comparison table (all CAT I items should move to PASS)
- `lab6-completed.ckl` STIG Viewer export
- Written reflection (3-5 sentences): In a real DoD environment, the STIG findings must be documented in a POAM before an Authority to Operate (ATO) is granted. What is the difference between a technical STIG remediation and a formal POAM entry?
- `nft list ruleset` output, the dropped-connection log entries, and the zone test results (which connections succeeded vs. were dropped, and why)

---

##  Graduate Extension - Master's Students Only

{: .callout-grad }
> **Required for students enrolled in the graduate section (CS 544 / IT 544). Undergraduate students skip this section.**

### Automated STIG Remediation Playbook

Generate and run OpenSCAP's built-in Ansible remediation playbook, then validate and extend it:

```bash
# Generate Ansible remediation playbook from scan results
oscap xccdf generate fix \
  --fix-type ansible \
  --profile xccdf_org.ssgproject.content_profile_stig \
  --output lab6-remediation.yml \
  /usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml
```

1. Review `lab6-remediation.yml` - it will attempt to auto-remediate ALL STIG findings. Before running it:
   - Identify 3 tasks that could break your lab environment if run blindly (e.g., tasks that disable services you need)
   - Comment those tasks out and document why in the playbook as a comment
2. Run the playbook against your VM using `ansible-playbook lab6-remediation.yml --check` first (dry run), then `--diff` to preview changes, then apply
3. Run a final OpenSCAP scan after the playbook runs - record the score improvement
4. Document: Which CAT I or CAT II findings did the automated playbook successfully remediate that you had not done manually? Which ones did it fail or skip?

Submit the modified playbook, the dry-run output, and the final scan score.

### Network Segmentation: nftables Sets and VLAN Design

Extend Part 6's zoned ruleset using nftables **sets and maps** instead of hardcoded subnets, so the ruleset scales without editing rule logic every time a host is added:

```bash
sudo nft add set inet filter admin_hosts { type ipv4_addr\; }
sudo nft add element inet filter admin_hosts { 10.0.0.5, 10.0.0.6 }
sudo nft add rule inet filter input ip saddr @admin_hosts tcp dport 22 accept
```

Then design (diagram, not implement - VLAN hardware isn't available in the lab environment) a full VLAN-segmented network for a 3-tier application (web/app/database), with a separate management VLAN carrying only SSH/IPMI traffic (tying back to Week 5's out-of-band management work), inter-VLAN routing rules restricting each tier to only the ports the tier above/below it actually needs, and an explanation of what specific lateral-movement attack this segmentation prevents that a flat network wouldn't.

Submit your updated nftables set/map ruleset with test output, the VLAN design diagram, and your lateral-movement analysis.

---

[← Back to Labs]({{ site.baseurl }}/labs/)

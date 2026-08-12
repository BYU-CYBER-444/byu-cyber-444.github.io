---
title: "CYBER HW 8 - Sample CIS-CAT Report (Given)"
parent: Homework
nav_exclude: true
---

# Sample CIS Benchmark Assessment Report
{: .no_toc }

{: .note }
This is the reference report for [CYBER HW 8]({% link homework/cyber-hw-08.md %}). Use it as the source data for Parts 1 and 2 - you do not need to run CIS-CAT Pro or any scanner yourself to get a set of findings to analyze.

The report below is a CIS Ubuntu Linux 22.04 LTS Benchmark v2.0.0 (Level 1 - Server profile) assessment against a fictional host, `cyber-hw08-sample01`. It contains 48 controls (21 FAIL, 27 PASS) across all 7 benchmark sections, formatted the same way a real CIS-CAT Pro HTML report is: overall score, per-section score table, and a detailed results table with control ID, title, level, and result.

This data is synthetic - built to look and score like a real assessment, not copied from an actual CIS-CAT Pro run. The control IDs and titles correspond to real CIS Ubuntu 22.04 Benchmark recommendations, so your remediation research (Part 2) and any commands you write (Part 3) should reflect the actual, correct fix for that control on a real Ubuntu 22.04 system.

---

<style>
  .cis-sample-report { font-family: "Segoe UI", Arial, sans-serif; color: #1a1a1a; background: #fff; border: 1px solid #d7dee3; border-radius: 6px; overflow: hidden; margin: 24px 0; }
  .cis-sample-report .csr-header { background: #14324d; color: #fff; padding: 24px 32px; }
  .cis-sample-report .csr-header h2 { margin: 0 0 4px; font-size: 22px; color: #fff; border: none; padding: 0; }
  .cis-sample-report .csr-header .csr-sub { color: #b9c9d6; font-size: 13px; }
  .cis-sample-report .csr-meta { display: flex; flex-wrap: wrap; gap: 24px; padding: 20px 32px; background: #eef2f5; border-bottom: 1px solid #d7dee3; font-size: 13px; }
  .cis-sample-report .csr-meta div span.csr-label { display: block; color: #5a6672; font-size: 11px; text-transform: uppercase; letter-spacing: .04em; background: none; }
  .cis-sample-report .csr-meta div span.csr-val { font-weight: 600; font-size: 14px; background: none; }
  .cis-sample-report .csr-score-panel { display: flex; align-items: center; gap: 28px; padding: 24px 32px; border-bottom: 1px solid #d7dee3; flex-wrap: wrap; }
  .cis-sample-report .csr-gauge { width: 110px; height: 110px; border-radius: 50%; background: conic-gradient(#c0392b 0% 43.75%, #e0e0e0 43.75% 100%); display: flex; align-items: center; justify-content: center; position: relative; flex-shrink: 0; }
  .cis-sample-report .csr-gauge::before { content: ""; position: absolute; width: 82px; height: 82px; border-radius: 50%; background: #fff; }
  .cis-sample-report .csr-gauge span { position: relative; font-size: 22px; font-weight: 700; color: #14324d; }
  .cis-sample-report .csr-score-text h3 { margin: 0 0 6px; font-size: 18px; border: none; padding: 0; }
  .cis-sample-report .csr-score-text p { margin: 0; font-size: 13px; color: #444; }
  .cis-sample-report table { width: 100%; border-collapse: collapse; font-size: 13px; margin: 0; }
  .cis-sample-report th, .cis-sample-report td { padding: 8px 12px; text-align: left; border-bottom: 1px solid #e4e8eb; }
  .cis-sample-report th { background: #f0f3f5; color: #2c3a45; font-size: 11px; text-transform: uppercase; letter-spacing: .03em; }
  .cis-sample-report .csr-section-table, .cis-sample-report .csr-detail-table-wrap { margin: 20px 32px; }
  .cis-sample-report .csr-detail-table-wrap { border: 1px solid #e4e8eb; margin-bottom: 32px; }
  .cis-sample-report .csr-pass { color: #1e7e34; font-weight: 700; background: none; }
  .cis-sample-report .csr-fail { color: #c0392b; font-weight: 700; background: none; }
  .cis-sample-report .csr-lvl { display: inline-block; padding: 1px 7px; border-radius: 3px; background: #e5eaee; color: #2c3a45; font-size: 11px; }
  .cis-sample-report h4 { margin: 28px 32px 8px; font-size: 15px; color: #14324d; border-bottom: 2px solid #14324d; padding-bottom: 6px; }
  .cis-sample-report .csr-rownum { color: #888; font-size: 12px; background: none; }
  .cis-sample-report .csr-footer { padding: 16px 32px; font-size: 11px; color: #888; border-top: 1px solid #d7dee3; }
</style>

<div class="cis-sample-report" markdown="0">
  <div class="csr-header">
    <h2>CIS Benchmark Configuration Assessment Report</h2>
    <div class="csr-sub">Benchmark: CIS Ubuntu Linux 22.04 LTS Benchmark v2.0.0 &nbsp;|&nbsp; Profile: Level 1 - Server</div>
  </div>

  <div class="csr-meta">
    <div><span class="csr-label">Target Host</span><span class="csr-val">cyber-hw08-sample01</span></div>
    <div><span class="csr-label">IP Address</span><span class="csr-val">10.60.14.22</span></div>
    <div><span class="csr-label">OS</span><span class="csr-val">Ubuntu 22.04.3 LTS</span></div>
    <div><span class="csr-label">Scan Date</span><span class="csr-val">2026-07-14 09:41 UTC</span></div>
    <div><span class="csr-label">Report ID</span><span class="csr-val">cyber-hw08-sample01-baseline</span></div>
  </div>

  <div class="csr-score-panel">
    <div class="csr-gauge"><span>56.3%</span></div>
    <div class="csr-score-text">
      <h3>Overall Compliance Score: 27 / 48 controls passing</h3>
      <p>21 FAIL &nbsp;&middot;&nbsp; 27 PASS &nbsp;&middot;&nbsp; 0 NOT APPLICABLE &nbsp;&middot;&nbsp; 0 ERROR</p>
    </div>
  </div>

  <h4>Section Scores</h4>
  <table class="csr-section-table">
    <tr><th>Section</th><th>Controls</th><th>Pass</th><th>Fail</th><th>Score</th></tr>
    <tr><td>1 - Initial Setup</td><td>11</td><td>7</td><td>4</td><td>63.6%</td></tr>
    <tr><td>2 - Services</td><td>7</td><td>5</td><td>2</td><td>71.4%</td></tr>
    <tr><td>3 - Network</td><td>5</td><td>3</td><td>2</td><td>60.0%</td></tr>
    <tr><td>4 - Host Based Firewall</td><td>2</td><td>0</td><td>2</td><td>0.0%</td></tr>
    <tr><td>5 - Access, Authentication and Authorization</td><td>13</td><td>6</td><td>7</td><td>46.2%</td></tr>
    <tr><td>6 - Logging and Auditing</td><td>6</td><td>3</td><td>3</td><td>50.0%</td></tr>
    <tr><td>7 - System Maintenance</td><td>4</td><td>3</td><td>1</td><td>75.0%</td></tr>
  </table>

  <h4>Detailed Results</h4>
  <div class="csr-detail-table-wrap">
  <table class="csr-detail-table">
    <tr><th>#</th><th>Control ID</th><th>Title</th><th>Level</th><th>Result</th></tr>

    <tr><td class="csr-rownum">1</td><td>1.1.1.1</td><td>Ensure mounting of cramfs filesystems is disabled</td><td><span class="csr-lvl">L1</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">2</td><td>1.1.1.3</td><td>Ensure mounting of squashfs filesystems is disabled</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">3</td><td>1.1.1.6</td><td>Ensure mounting of usb-storage is disabled</td><td><span class="csr-lvl">L1</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">4</td><td>1.1.2.1</td><td>Ensure /tmp is a separate partition</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">5</td><td>1.1.2.3</td><td>Ensure nodev option set on /tmp partition</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">6</td><td>1.1.2.4</td><td>Ensure noexec option set on /tmp partition</td><td><span class="csr-lvl">L1</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">7</td><td>1.3.1.1</td><td>Ensure AIDE is installed</td><td><span class="csr-lvl">L1</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">8</td><td>1.4.1</td><td>Ensure permissions on bootloader config are configured</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">9</td><td>1.5.1</td><td>Ensure address space layout randomization (ASLR) is enabled</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">10</td><td>1.6.1.1</td><td>Ensure AppArmor is installed</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">11</td><td>1.7.1</td><td>Ensure message of the day is configured properly</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>

    <tr><td class="csr-rownum">12</td><td>2.1.1</td><td>Ensure autofs services are not in use</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">13</td><td>2.1.4</td><td>Ensure CUPS is not in use</td><td><span class="csr-lvl">L1</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">14</td><td>2.1.9</td><td>Ensure rsync service is not in use</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">15</td><td>2.1.16</td><td>Ensure telnet server is not installed</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">16</td><td>2.2.1</td><td>Ensure NIS Client is not installed</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">17</td><td>2.3.1</td><td>Ensure time synchronization is in use (chrony/systemd-timesyncd)</td><td><span class="csr-lvl">L1</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">18</td><td>2.4.1.1</td><td>Ensure cron daemon is enabled and running</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>

    <tr><td class="csr-rownum">19</td><td>3.1.1</td><td>Ensure IP forwarding is disabled</td><td><span class="csr-lvl">L1</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">20</td><td>3.2.1</td><td>Ensure packet redirect sending is disabled</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">21</td><td>3.3.1</td><td>Ensure source routed packets are not accepted</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">22</td><td>3.3.2</td><td>Ensure ICMP redirects are not accepted</td><td><span class="csr-lvl">L1</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">23</td><td>3.3.9</td><td>Ensure IPv6 router advertisements are not accepted</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>

    <tr><td class="csr-rownum">24</td><td>4.1.1</td><td>Ensure ufw is installed</td><td><span class="csr-lvl">L1</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">25</td><td>4.2.6</td><td>Ensure iptables default deny firewall policy</td><td><span class="csr-lvl">L1</span></td><td class="csr-fail">FAIL</td></tr>

    <tr><td class="csr-rownum">26</td><td>5.1.1</td><td>Ensure permissions on /etc/crontab are configured</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">27</td><td>5.2.1</td><td>Ensure permissions on /etc/ssh/sshd_config are configured</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">28</td><td>5.2.5</td><td>Ensure SSH MaxAuthTries is set to 4 or less</td><td><span class="csr-lvl">L1</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">29</td><td>5.2.10</td><td>Ensure SSH root login is disabled</td><td><span class="csr-lvl">L1</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">30</td><td>5.2.16</td><td>Ensure SSH Idle Timeout Interval is configured</td><td><span class="csr-lvl">L1</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">31</td><td>5.2.19</td><td>Ensure SSH warning banner is configured</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">32</td><td>5.3.1</td><td>Ensure password creation requirements are configured</td><td><span class="csr-lvl">L1</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">33</td><td>5.3.3</td><td>Ensure password reuse is limited</td><td><span class="csr-lvl">L1</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">34</td><td>5.4.1</td><td>Ensure password expiration is 365 days or less</td><td><span class="csr-lvl">L1</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">35</td><td>5.4.3</td><td>Ensure inactive password lock is 30 days or less</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">36</td><td>5.5.1.1</td><td>Ensure minimum password days is configured</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">37</td><td>5.6</td><td>Ensure root PATH integrity</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">38</td><td>5.7</td><td>Ensure access to the su command is restricted</td><td><span class="csr-lvl">L1</span></td><td class="csr-fail">FAIL</td></tr>

    <tr><td class="csr-rownum">39</td><td>6.1.1</td><td>Ensure auditd is installed</td><td><span class="csr-lvl">L2</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">40</td><td>6.1.2</td><td>Ensure auditd service is enabled and running</td><td><span class="csr-lvl">L2</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">41</td><td>6.2.1.1</td><td>Ensure changes to system administration scope (sudoers) is collected</td><td><span class="csr-lvl">L2</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">42</td><td>6.3.1</td><td>Ensure rsyslog is installed</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">43</td><td>6.3.3</td><td>Ensure rsyslog default file permissions configured</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">44</td><td>6.4</td><td>Ensure logrotate is configured</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>

    <tr><td class="csr-rownum">45</td><td>7.1.1</td><td>Ensure permissions on /etc/passwd are configured</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">46</td><td>7.1.2</td><td>Ensure permissions on /etc/shadow are configured</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
    <tr><td class="csr-rownum">47</td><td>7.1.9</td><td>Ensure no unowned files or directories exist</td><td><span class="csr-lvl">L1</span></td><td class="csr-fail">FAIL</td></tr>
    <tr><td class="csr-rownum">48</td><td>7.2.1</td><td>Ensure accounts in /etc/passwd use shadowed passwords</td><td><span class="csr-lvl">L1</span></td><td class="csr-pass">PASS</td></tr>
  </table>
  </div>

  <div class="csr-footer">Sample assessment report generated for CYBER 444 - CIS Benchmark Gap Analysis (HW 8). Synthetic data for coursework use only.</div>
</div>


---

[← Back to CYBER HW 8]({% link homework/cyber-hw-08.md %})

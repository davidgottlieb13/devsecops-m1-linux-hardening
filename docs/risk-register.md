# Risk register (Lynis findings after remediation)

| ID | Finding | Decision | Rationale / compensating control |
|---|---|---|---|
| AUTH-9230 | Password hashing rounds | Accept | Targets SHA-crypt rounds. Ubuntu 24.04 uses yescrypt (memory-hard). SSH is key-only. |
| BOOT-5122 | GRUB password | Accept | Console access in a VM is hypervisor access. Compensating control: host access control and disk encryption. |
| DEB-0810 | apt-listbugs | Accept | Uses the Debian bug tracker. Not meaningful on Ubuntu with unattended upgrades. |
| DEB-0811 | apt-listchanges | Accept | Interactive helper. Low value with automatic security updates. |
| FIRE-4513 | Unused iptables rules | Accept | UFW creates a standard chain set. Unused counters are normal. |
| LYNIS | Lynis release older than 4 months | Accept | Ubuntu-packaged version, kept identical across all runs for comparability. |
| NAME-4028 | DNS domain name | Accept | No domain in an isolated lab. |
| TOOL-5002 | Automation tooling | Accept | Target is managed from the Bastion. Ansible arrives in a later module. |
| BOOT-5264 | Service sandboxing | Defer | Candidate stretch: `systemd-analyze security` driven hardening. |
| HRDN-7230 | Malware scanner | Defer | Compensating controls: AIDE, auditd, default-deny firewall. |
| LOGG-2154 | External log host | Defer | Needs a separate collector. Future improvement. |
| FILE-6310 | Separate /home, /tmp, /var | OPEN | <FILL: outcome of the diagnostics> |
| FILE-7524, FINT-4402, KRNL-6000, SSH-7408 | See Lynis detail fields | OPEN | <FILL: fixed or accepted, with reason> |

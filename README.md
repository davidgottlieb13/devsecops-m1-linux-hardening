# DevSecOps Module 1: Hardening a Linux Server under VMware Workstation

> A lab project, built and tested in an isolated VMware environment. It demonstrates
> hardening practices and measured results. It is not a production or compliance certification.

## Summary

A two-VM lab (Bastion + Target) running Ubuntu Server 24.04 LTS, hardened in layers,
validated with scripted checks, and scored with Lynis.

**Lynis hardening index: 57 (fresh install) → 76 (hardened) → 81 (remediated)**
· warnings 2 → 0 · suggestions 47 → 34 → 27 

## Architecture

```
 Host: VMware Workstation + docs only (no Git, Ansible or keys on the host)

   VMnet8 (NAT) ──── internet
      │                   ┊ (Target NAT adapter connected only for short patch windows)
 ┌────┴─────┐        ┌────┴─────┐
 │ BASTION  │────────│  TARGET  │
 │ .10      │ VMnet2 │  .20     │   10.10.10.0/24, host-only,
 └──────────┘        └──────────┘   no host adapter, no DHCP
```

| | Bastion | Target |
|---|---|---|
| Role | Control node: keys, Git, tooling | Server being hardened |
| Resources | 2 vCPU / 2 GB / 25 GB | 2 vCPU / 2 GB / 30 GB |
| Listening services | none (NTP for Target only) | SSH from Bastion only |

## Threat model (short)

- **In scope:** network attackers on the lab LAN, brute force, a compromised user or service,
  privilege escalation, configuration drift and tampering, accidental secret leaks.
- **Out of scope:** physical access, hypervisor compromise, firmware and supply-chain
  attacks beyond checksum verification.

## What was hardened

| Layer | Controls | Config in repo |
|---|---|---|
| Network isolation | Dedicated host-only network, no host adapter, Target offline by default | docs/01 |
| Patching | Full upgrade, unattended security updates | `hardening/target/etc/apt/` |
| Access control | Locked root, RBAC via groups, exact-command sudo rules, no `NOPASSWD` | `etc/sudoers.d/` |
| SSH | Key-only, no root, `AllowGroups`, forwarding off, pinned modern crypto, fail2ban | `etc/ssh/`, `etc/fail2ban/` |
| Firewall | UFW default-deny in/out, SSH from Bastion only, Bastion blocked from host adapter | `ufw.sh` |
| System | sysctl, blocked kernel modules, mount options, AppArmor, pruned services | `etc/sysctl.d/`, `etc/modprobe.d/` |
| Auditing | auditd rules (immutable), persistent journald, internal NTP | `etc/audit/`, `etc/systemd/` |
| Integrity | AIDE baseline | docs/08 |
| Supply chain | Signed commits, fail-closed gitleaks hook, checksum-verified tools | `.githooks/` |

## Results

| Run | Hardening index | Warnings | Suggestions |
|---|---|---|---|
| Fresh install (clone of snapshot) | 57 | 2 | 47 |
| After hardening | 76 | 0 | 34 |
| After remediation | 81 | 0 | 27 |

Method: the same Lynis version for every run, with the baseline taken on a disposable clone.
The baseline already uses the custom partition layout, so the gain is measured against a
slightly better-than-default start. The index is a heuristic, not a compliance certificate.
Remaining findings are triaged in [docs/risk-register.md](docs/risk-register.md).

## Verify it yourself

```bash
scp scripts/verify-target.sh target:      # from the Bastion
ssh target './verify-target.sh'
```

## Repository layout

`docs/` step-by-step guides · `hardening/` configs mirroring real filesystem paths ·
`scripts/` verification and comparison · `evidence/` sanitized outputs ·
`.githooks/` secret-scanning pre-commit hook.

## Reproduce

Follow `docs/01` to `docs/08` in order. Needs VMware Workstation, about 4 GB RAM
for the two VMs, and a Ubuntu Server 24.04 LTS ISO (verify its checksum).

## Design decisions and trade-offs

- **Egress denied by default**: limits C2 and exfiltration. Cost: deliberate NAT windows for installs.
- **Bastion as internal NTP**: trustworthy log timestamps without internet on the Target.
- **No disk encryption in the lab**: avoids a console passphrase at every boot. Accepted and documented.
- **Audit rules immutable**: tampering requires a reboot. Cost: rule changes need one too.
- **Deploy key and a short-lived token** instead of an account-wide key.

## Lessons learned

- Verify **effective** configuration (`sshd -T`, `sysctl -n`), not files. A later file silently overrode a kernel setting.
- Prove the negatives: showing that a login is refused matters as much as showing one works.
- Local hooks can be bypassed. Real enforcement is server-side CI (next modules).


## Roadmap

Next: containers (Docker), configuration management (Ansible, which turns `hardening/` into roles),
Terraform, CI/CD with GitLab CI and Jenkins, then Kubernetes.

## License

MIT

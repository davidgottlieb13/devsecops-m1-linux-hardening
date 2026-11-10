#!/usr/bin/env bash
# Read-only validation of the hardened Target. Run as a sudo-capable user.
set -uo pipefail
PASS=0; FAIL=0
check() { local d="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "PASS  $d"; PASS=$((PASS+1))
  else echo "FAIL  $d"; FAIL=$((FAIL+1)); fi; }

sshd_is()      { sudo sshd -T 2>/dev/null | grep -qix "$1"; }
sysctl_is()    { [ "$(sudo sysctl -n "$1" 2>/dev/null)" = "$2" ]; }
mnt_has()      { findmnt -no OPTIONS "$1" 2>/dev/null | grep -qw "$2"; }
root_locked()  { [ "$(sudo passwd -S root | awk '{print $2}')" = "L" ]; }
ufw_default()  { sudo ufw status verbose | grep -q "Default: deny (incoming), deny (outgoing), deny (routed)"; }
audit_locked() { sudo auditctl -s | grep -q "enabled 2"; }
mod_blocked()  { modprobe -n -v "$1" 2>&1 | grep -q "/bin/true"; }

check "sshd: root login disabled"        sshd_is "permitrootlogin no"
check "sshd: password auth disabled"     sshd_is "passwordauthentication no"
check "sshd: publickey only"             sshd_is "authenticationmethods publickey"
check "sshd: MaxAuthTries 3"             sshd_is "maxauthtries 3"
check "sshd: TCP forwarding disabled"    sshd_is "allowtcpforwarding no"
check "sshd: LogLevel VERBOSE"           sshd_is "loglevel verbose"
check "root account locked"              root_locked
check "sudoers syntax valid"             sudo visudo -c
check "ufw default-deny policy"          ufw_default
check "service active: ufw"              systemctl is-active --quiet ufw
check "service active: fail2ban"         systemctl is-active --quiet fail2ban
check "service active: auditd"           systemctl is-active --quiet auditd
check "unattended-upgrades enabled"      systemctl is-enabled --quiet unattended-upgrades
check "audit rules immutable (-e 2)"     audit_locked
check "journald persistent"              test -d /var/log/journal
check "sysctl: ip_forward=0"             sysctl_is net.ipv4.ip_forward 0
check "sysctl: kptr_restrict=2"          sysctl_is kernel.kptr_restrict 2
check "sysctl: ptrace_scope=2"           sysctl_is kernel.yama.ptrace_scope 2
check "sysctl: protected_fifos=2"        sysctl_is fs.protected_fifos 2
check "sysctl: IPv6 disabled"            sysctl_is net.ipv6.conf.all.disable_ipv6 1
#check "mount: /tmp noexec"               mnt_has /tmp noexec
#check "mount: /tmp nosuid"               mnt_has /tmp nosuid
#check "mount: /var/log noexec"           mnt_has /var/log noexec
#check "mount: /var nosuid"               mnt_has /var nosuid
#check "mount: /home nodev"               mnt_has /home nodev
#check "mount: /dev/shm noexec"           mnt_has /dev/shm noexec
check "module blocked: dccp"             mod_blocked dccp
check "module blocked: usb-storage"      mod_blocked usb-storage

echo; echo "Result: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

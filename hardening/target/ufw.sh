#!/usr/bin/env bash
# WARNING: run from the VM console. HOST_VMNET8_IP is the host's VMnet8 adapter address.
set -euo pipefail
: "${HOST_VMNET8_IP:?set HOST_VMNET8_IP before running}"
ufw default deny incoming
ufw default deny outgoing
ufw default deny routed
ufw deny out to "$HOST_VMNET8_IP" comment 'never reach the host'
ufw allow out to 10.10.10.20 port 22 proto tcp comment 'SSH to Target'
ufw allow out 53 comment 'DNS'
ufw allow out 80/tcp comment 'HTTP (apt)'
ufw allow out 443/tcp comment 'HTTPS'
ufw allow out 123/udp comment 'NTP'
ufw allow out 67/udp comment 'DHCP client'
ufw allow in from 10.10.10.20 to any port 123 proto udp comment 'NTP for Target'
ufw logging low
ufw --force enable

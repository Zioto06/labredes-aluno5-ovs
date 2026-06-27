#!/usr/bin/env bash
set -euo pipefail

# Configuração dos links trunk do VM_SW1.
# ens8  = FIREWALL_1
# ens13 = TRUNK_INTER_SW
# ens5  = VM4_MIRROR / saída de espelhamento para VM4

BRIDGE="br-int"
VLANS="10,20,30,40,50,60"

echo "[VM_SW1] Configurando portas trunk..."

for IFACE in ens8 ens13 ens5; do
  echo "[VM_SW1] Configurando $IFACE como trunk..."

  sudo ip link set "$IFACE" up

  sudo ovs-vsctl --may-exist add-port "$BRIDGE" "$IFACE"

  # Remove configurações anteriores de access, caso existam
  sudo ovs-vsctl clear Port "$IFACE" tag || true
  sudo ovs-vsctl clear Port "$IFACE" vlan_mode || true

  # Define VLANs permitidas no trunk
  sudo ovs-vsctl set Port "$IFACE" trunks="$VLANS"
done

echo "[VM_SW1] Portas trunk configuradas com sucesso."

sudo ovs-vsctl show

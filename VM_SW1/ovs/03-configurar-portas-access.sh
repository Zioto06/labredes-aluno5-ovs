#!/usr/bin/env bash
set -euo pipefail

# Configuração das portas access do VM_SW1.
# Cada interface é associada a uma VLAN específica.

BRIDGE="br-int"

echo "[VM_SW1] Configurando portas access..."

config_access_port() {
  local iface="$1"
  local vlan="$2"
  local descricao="$3"

  echo "[VM_SW1] Configurando $iface como access VLAN $vlan ($descricao)..."

  sudo ip link set "$iface" up

  sudo ovs-vsctl --may-exist add-port "$BRIDGE" "$iface"

  # Remove configuração anterior de trunk, se existir
  sudo ovs-vsctl clear Port "$iface" trunks || true

  # Define a porta como access na VLAN informada
  sudo ovs-vsctl set Port "$iface" vlan_mode=access tag="$vlan"
}

config_access_port ens3  10 "VM9 - Autenticação"
config_access_port ens4  40 "VM3 - Descoberta de Hosts"
config_access_port ens6  50 "VM_DEV - Estação de Desenvolvimento"
config_access_port ens7  60 "VM_USER1 - Usuários"
config_access_port ens14 40 "VM4 - Gerência/Captura"

echo "[VM_SW1] Portas access configuradas com sucesso."

sudo ovs-vsctl show

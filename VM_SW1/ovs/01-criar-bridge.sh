#!/usr/bin/env bash
set -euo pipefail

# Criação da bridge principal do Open vSwitch no VM_SW1.
# A bridge br-int será responsável pela comutação L2 das VLANs.

echo "[VM_SW1] Criando bridge br-int..."

sudo systemctl enable openvswitch-switch
sudo systemctl start openvswitch-switch

sudo ovs-vsctl --may-exist add-br br-int

echo "[VM_SW1] Bridge br-int criada/verificada com sucesso."

sudo ovs-vsctl show

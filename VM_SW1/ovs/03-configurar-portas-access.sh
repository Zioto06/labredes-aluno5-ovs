#!/bin/bash

# Configuração das portas access do VM_SW1

# ens3 - VM9 - VLAN 10
sudo ip link set ens3 up
sudo ovs-vsctl --may-exist add-port br-int ens3
sudo ovs-vsctl clear Port ens3 trunks
sudo ovs-vsctl set Port ens3 vlan_mode=access tag=10

# ens4 - VM3 - VLAN 40
sudo ip link set ens4 up
sudo ovs-vsctl --may-exist add-port br-int ens4
sudo ovs-vsctl clear Port ens4 trunks
sudo ovs-vsctl set Port ens4 vlan_mode=access tag=40

# ens6 - VM_DEV - VLAN 50
sudo ip link set ens6 up
sudo ovs-vsctl --may-exist add-port br-int ens6
sudo ovs-vsctl clear Port ens6 trunks
sudo ovs-vsctl set Port ens6 vlan_mode=access tag=50

# ens7 - VM_USER1 - VLAN 60
sudo ip link set ens7 up
sudo ovs-vsctl --may-exist add-port br-int ens7
sudo ovs-vsctl clear Port ens7 trunks
sudo ovs-vsctl set Port ens7 vlan_mode=access tag=60

# ens14 - VM4 - VLAN 40
sudo ip link set ens14 up
sudo ovs-vsctl --may-exist add-port br-int ens14
sudo ovs-vsctl clear Port ens14 trunks
sudo ovs-vsctl set Port ens14 vlan_mode=access tag=40

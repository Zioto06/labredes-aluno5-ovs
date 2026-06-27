#!/bin/bash

# Configuração das portas access do VM_SW2

# ens3 - VM10 - VLAN 10
sudo ip link set ens3 up
sudo ovs-vsctl --may-exist add-port br-int ens3
sudo ovs-vsctl clear Port ens3 trunks
sudo ovs-vsctl set Port ens3 vlan_mode=access tag=10

# ens4 - VM6 - VLAN 20
sudo ip link set ens4 up
sudo ovs-vsctl --may-exist add-port br-int ens4
sudo ovs-vsctl clear Port ens4 trunks
sudo ovs-vsctl set Port ens4 vlan_mode=access tag=20

# ens5 - VM1 - VLAN 20
sudo ip link set ens5 up
sudo ovs-vsctl --may-exist add-port br-int ens5
sudo ovs-vsctl clear Port ens5 trunks
sudo ovs-vsctl set Port ens5 vlan_mode=access tag=20

# ens6 - VM2 - VLAN 30
sudo ip link set ens6 up
sudo ovs-vsctl --may-exist add-port br-int ens6
sudo ovs-vsctl clear Port ens6 trunks
sudo ovs-vsctl set Port ens6 vlan_mode=access tag=30

# ens8 - VM7 - VLAN 40
sudo ip link set ens8 up
sudo ovs-vsctl --may-exist add-port br-int ens8
sudo ovs-vsctl clear Port ens8 trunks
sudo ovs-vsctl set Port ens8 vlan_mode=access tag=40

# ens9 - VM_USER2 - VLAN 60
sudo ip link set ens9 up
sudo ovs-vsctl --may-exist add-port br-int ens9
sudo ovs-vsctl clear Port ens9 trunks
sudo ovs-vsctl set Port ens9 vlan_mode=access tag=60

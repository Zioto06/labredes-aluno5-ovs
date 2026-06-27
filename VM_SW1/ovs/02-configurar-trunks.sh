#!/bin/bash

# Configuração dos links trunk do VM_SW1
# ens8  = FIREWALL_1
# ens13 = TRUNK_INTER_SW
# ens5  = VM4_MIRROR

sudo ip link set ens8 up && sudo ovs-vsctl add-port br-int ens8 && sudo ovs-vsctl set port ens8 trunks=10,20,30,40,50,60

sudo ip link set ens13 up && sudo ovs-vsctl add-port br-int ens13 && sudo ovs-vsctl set port ens13 trunks=10,20,30,40,50,60

sudo ip link set ens5 up && sudo ovs-vsctl add-port br-int ens5 && sudo ovs-vsctl set port ens5 trunks=10,20,30,40,50,60

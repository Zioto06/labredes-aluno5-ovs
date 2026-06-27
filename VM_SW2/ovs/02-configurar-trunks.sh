#!/bin/bash

# Configuração dos links trunk do VM_SW2
# ens10 = FIREWALL_2
# ens15 = TRUNK_INTER_SW
# ens7  = VM4_MIRROR

sudo ip link set ens10 up && sudo ovs-vsctl add-port br-int ens10 && sudo ovs-vsctl set port ens10 trunks=10,20,30,40,50,60

sudo ip link set ens15 up && sudo ovs-vsctl add-port br-int ens15 && sudo ovs-vsctl set port ens15 trunks=10,20,30,40,50,60

sudo ip link set ens7 up && sudo ovs-vsctl add-port br-int ens7 && sudo ovs-vsctl set port ens7 trunks=10,20,30,40,50,60

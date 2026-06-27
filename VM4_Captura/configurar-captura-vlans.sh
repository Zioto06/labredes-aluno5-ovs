#!/bin/bash

# SCRIPT DE COMPATIBILIZAÇÃO LÓGICA E DECODIFICAÇÃO DE TRUNKS - VM4

# 1. RESET E LIMPEZA DE INTERFACES ANTERIORES
# Remove barramentos residuais em caso de reexecução para evitar colisão de hardware

for vlan in 10 20 30 50 60; do
 sudo ip link set ens3.$vlan down 2>/dev/null
 sudo ip link delete ens3.$vlan 2>/dev/null
 sudo ip link set ens7.$vlan down 2>/dev/null
 sudo ip link delete ens7.$vlan 2>/dev/null
done

# 2. ATIVAÇÃO DO MODO PROMÍSCUO NOS TRUNKS FÍSICOS
# Força o kernel a ignorar os filtros L2 tradicionais e aceitar os pacotes de monitoramento

sudo ip link set ens3 promisc on
sudo ip link set ens7 promisc on
sudo ip link set ens3 up
sudo ip link set ens7 up

# 3. CRIAÇÃO E ATIVAÇÃO DAS SUBINTERFACES DE TRUNK (VLAN TAGGING)
# Desdobra os troncos recebidos do VM_SW1 e VM_SW2 em interfaces virtuais tratadas por ID

for vlan in 10 20 30 50 60; do
 # Canal de Escuta analítica para o Switch 1 (via ens3)
 sudo ip link add link ens3 name ens3.$vlan type vlan id $vlan
 sudo ip link set ens3.$vlan up
 sudo ip link set ens3.$vlan promisc on

 # Canal de Escuta analítica para o Switch 2 (via ens7)
 sudo ip link add link ens7 name ens7.$vlan type vlan id $vlan
 sudo ip link set ens7.$vlan up
 sudo ip link set ens7.$vlan promisc on
done

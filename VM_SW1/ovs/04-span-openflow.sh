#!/bin/bash

# Configuração do espelhamento SPAN/OpenFlow no VM_SW1

# Passo 1: Limpeza do Banco de Dados de Mirrors
sudo ovs-vsctl clear Bridge br-int mirrors

# Passo 2: Limpeza da Tabela de Fluxos OpenFlow Anterior
sudo ovs-ofctl del-flows br-int "table=0"

# Passo 3: Criação do Espelhamento Adaptativo via Clone com modificação de MAC Destino para a ens5
sudo ovs-ofctl add-flow br-int "priority=100,actions=normal,clone(mod_dl_dst:fa:16:3e:77:99:5e,output:ens5)"

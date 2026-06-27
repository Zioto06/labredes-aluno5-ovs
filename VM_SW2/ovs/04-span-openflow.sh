#!/bin/bash

# Configuração do espelhamento SPAN/OpenFlow no VM_SW2

# Passo 1: Limpeza do Banco de Dados de Mirrors
sudo ovs-vsctl clear Bridge br-int mirrors

# Passo 2: Limpeza da Tabela de Fluxos OpenFlow Anterior
sudo ovs-ofctl del-flows br-int "table=0"

# Passo 3: Criação do Espelhamento via Clone apontando para a Porta Física 7 com o MAC correspondente
sudo ovs-ofctl add-flow br-int "priority=100,actions=normal,clone(mod_dl_dst:fa:16:3e:69:d6:31,output:7)"

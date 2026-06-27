# VM4_Captura — Configuração da VM4 para Recepção de Tráfego Espelhado

Esta pasta contém o script utilizado na VM4, responsável por receber o tráfego espelhado dos switches virtuais `VM_SW1` e `VM_SW2`.

A VM4 atua como ponto de captura e observabilidade. Ela recebe cópias dos pacotes encaminhadas pelos switches por meio de regras SPAN/OpenFlow e organiza esse tráfego em subinterfaces VLAN para permitir análise com ferramentas como `tcpdump`.

## Estrutura da pasta

```text
VM4_Captura/
├── README.md
└── configurar-captura-vlans.sh
```

## Descrição do arquivo

### `configurar-captura-vlans.sh`

Este script prepara a VM4 para receber tráfego espelhado vindo dos dois switches virtuais.

Ele realiza três etapas principais:

1. Remove subinterfaces VLAN antigas, caso existam;
2. Ativa o modo promíscuo nas interfaces físicas de recepção;
3. Cria subinterfaces VLAN para separar o tráfego recebido por VLAN.

## Interfaces utilizadas

| Interface | Origem do tráfego | Função                                |
| --------- | ----------------- | ------------------------------------- |
| `ens3`    | VM_SW1            | Receber tráfego espelhado do Switch 1 |
| `ens7`    | VM_SW2            | Receber tráfego espelhado do Switch 2 |

## VLANs configuradas

O script cria subinterfaces para as seguintes VLANs:

```text
10, 20, 30, 50, 60
```

Essas VLANs representam os principais segmentos de produção monitorados pela VM4.

A VLAN 40 não foi incluída nesse script porque está relacionada ao segmento de monitoramento/gerência e ao próprio ambiente de captura.

## Subinterfaces criadas

Para a interface `ens3`, são criadas:

```text
ens3.10
ens3.20
ens3.30
ens3.50
ens3.60
```

Para a interface `ens7`, são criadas:

```text
ens7.10
ens7.20
ens7.30
ens7.50
ens7.60
```

## Ordem de execução

Dentro da pasta `VM4_Captura`, execute:

```bash
sudo bash configurar-captura-vlans.sh
```

## O que o script faz

### 1. Limpeza de subinterfaces antigas

Antes de criar novas subinterfaces, o script tenta remover interfaces VLAN criadas anteriormente.

Isso evita erro caso o script seja executado mais de uma vez.

Exemplo:

```bash
sudo ip link set ens3.10 down 2>/dev/null
sudo ip link delete ens3.10 2>/dev/null
```

A mesma lógica é aplicada para as interfaces `ens3` e `ens7`.

---

### 2. Ativação do modo promíscuo

O modo promíscuo permite que a VM4 receba pacotes mesmo que eles não tenham sido originalmente destinados à interface de rede local.

Isso é necessário porque a VM4 recebe cópias de tráfego espelhado.

Comandos utilizados:

```bash
sudo ip link set ens3 promisc on
sudo ip link set ens7 promisc on
sudo ip link set ens3 up
sudo ip link set ens7 up
```

---

### 3. Criação das subinterfaces VLAN

O script cria subinterfaces VLAN para que o tráfego recebido possa ser separado por ID de VLAN.

Exemplo para a interface `ens3`:

```bash
sudo ip link add link ens3 name ens3.10 type vlan id 10
sudo ip link set ens3.10 up
sudo ip link set ens3.10 promisc on
```

Exemplo para a interface `ens7`:

```bash
sudo ip link add link ens7 name ens7.10 type vlan id 10
sudo ip link set ens7.10 up
sudo ip link set ens7.10 promisc on
```

## Comandos de verificação

Após executar o script, verifique se as subinterfaces foram criadas:

```bash
ip link show
```

Ou consulte uma interface específica:

```bash
ip -d link show ens3.50
ip -d link show ens7.50
```

## Exemplos de captura com tcpdump

Captura de tráfego recebido do VM_SW1 na VLAN 50:

```bash
sudo tcpdump -i ens3.50 -e -n
```

Captura de tráfego recebido do VM_SW2 na VLAN 50:

```bash
sudo tcpdump -i ens7.50 -e -n
```

Captura de tráfego recebido do VM_SW1 na VLAN 60:

```bash
sudo tcpdump -i ens3.60 -e -n
```

Captura de tráfego recebido do VM_SW2 na VLAN 60:

```bash
sudo tcpdump -i ens7.60 -e -n
```

## Observação

Este script deve ser executado depois que as regras de espelhamento SPAN/OpenFlow já tiverem sido aplicadas nos switches `VM_SW1` e `VM_SW2`.

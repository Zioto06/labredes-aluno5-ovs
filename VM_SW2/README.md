# VM_SW2 — Switch Virtual 2

Esta pasta contém os arquivos de configuração utilizados na instância `VM_SW2`, responsável por parte da comutação de Camada 2 da infraestrutura do trabalho.

O `VM_SW2` atua como switch virtual baseado em Open vSwitch, realizando a criação da bridge principal `br-int`, configuração de portas trunk, configuração de portas access e aplicação da regra de espelhamento de tráfego via OpenFlow para a VM4.

## Mapeamento de interfaces

A imagem abaixo apresenta o mapeamento das interfaces Linux do `VM_SW2`, seus respectivos endereços MAC e a rede correspondente no OpenStack.

![Mapeamento de interfaces da VM\_SW2](/docs/VM_SW2_interfaces.png)

## Estrutura da pasta

```text
VM_SW2/
├── README.md
├── netplan/
│   └── 99-cloud-init.yaml
└── ovs/
    ├── 01-criar-bridge.sh
    ├── 02-configurar-trunks.sh
    ├── 03-configurar-portas-access.sh
    └── 04-span-openflow.sh
```

## Descrição dos arquivos

### `netplan/99-cloud-init.yaml`

Arquivo de configuração persistente da interface de gerência do `VM_SW2`.

Este arquivo configura a interface `ens11`, vinculada à rede `labredes1`, com o endereço IP:

```text
192.168.10.105/24
```

Também define a rota padrão para o gateway:

```text
192.168.10.1
```

A interface `ens11` deve permanecer fora da bridge `br-int`, pois é utilizada para acesso administrativo e conexão SSH.

---

### `ovs/01-criar-bridge.sh`

Cria a bridge principal do Open vSwitch:

```text
br-int
```

A bridge `br-int` funciona como o barramento central de comutação do switch virtual. É nela que as interfaces de rede são adicionadas para operação em modo access ou trunk.

---

### `ovs/02-configurar-trunks.sh`

Configura as portas trunk do `VM_SW2`.

As interfaces configuradas neste arquivo são:

| Interface | Função                                 |
| --------- | -------------------------------------- |
| `ens10`   | Link para o firewall/roteador VM11     |
| `ens15`   | Link de backbone entre VM_SW1 e VM_SW2 |
| `ens7`    | Link de espelhamento para a VM4        |

As VLANs permitidas nos trunks são:

```text
10,20,30,40,50,60
```

Essas portas transportam múltiplas VLANs no mesmo enlace lógico.

---

### `ovs/03-configurar-portas-access.sh`

Configura as portas access do `VM_SW2`.

As portas access são utilizadas para conexão direta das máquinas virtuais aos seus respectivos segmentos de rede.

| Interface | Máquina / Função           | VLAN    |
| --------- | -------------------------- | ------- |
| `ens3`    | VM10 — Deploy Automatizado | VLAN 10 |
| `ens4`    | VM6 — Motor Analítico      | VLAN 20 |
| `ens5`    | VM1 — Servidor Central     | VLAN 20 |
| `ens6`    | VM2 — Dashboard WEB        | VLAN 30 |
| `ens8`    | VM7 — Sistema de Alertas   | VLAN 40 |
| `ens9`    | VM_USER2 — Usuários        | VLAN 60 |

Cada porta recebe uma única tag VLAN por meio do modo `access`.

---

### `ovs/04-span-openflow.sh`

Configura o espelhamento de tráfego do `VM_SW2` para a VM4 usando OpenFlow.

Este arquivo realiza três ações principais:

1. Limpa configurações antigas de mirror na bridge `br-int`;
2. Remove fluxos OpenFlow anteriores;
3. Cria uma regra de clonagem de tráfego para encaminhar uma cópia dos pacotes para a VM4.

A regra utilizada altera o MAC de destino do tráfego clonado para a interface receptora da VM4:

```text
fa:16:3e:69:d6:31
```

A saída do espelhamento é realizada pela porta OpenFlow:

```text
7
```

No trabalho, essa porta corresponde ao enlace físico-virtual de saída para a VM4.

## Ordem de execução

A execução deve ser feita dentro da pasta `VM_SW2/ovs`.

```bash
cd VM_SW2/ovs
```

Em seguida, executar os scripts na ordem abaixo:

```bash
sudo bash 01-criar-bridge.sh
sudo bash 02-configurar-trunks.sh
sudo bash 03-configurar-portas-access.sh
sudo bash 04-span-openflow.sh
```

## Aplicação do Netplan

Caso seja necessário aplicar a configuração de gerência persistente, copiar o arquivo para o diretório do Netplan:

```bash
sudo cp VM_SW2/netplan/99-cloud-init.yaml /etc/netplan/99-cloud-init.yaml
```

Depois aplicar a configuração:

```bash
sudo netplan apply
```

Em alguns casos, após alteração da configuração de rede, pode ser necessário reiniciar a instância:

```bash
sudo reboot
```

## Comandos de verificação

Após a execução dos scripts, alguns comandos úteis para verificar a configuração são:

```bash
sudo ovs-vsctl show
```

Verificar as portas trunk:

```bash
sudo ovs-vsctl list Port ens10
sudo ovs-vsctl list Port ens15
sudo ovs-vsctl list Port ens7
```

Verificar os fluxos OpenFlow:

```bash
sudo ovs-ofctl dump-flows br-int
```

Verificar estatísticas do backbone inter-switch:

```bash
ip -s link show ens15
```

## Observação

A interface `ens11` não deve ser adicionada à bridge `br-int`, pois é a interface de gerência da instância `VM_SW2`.

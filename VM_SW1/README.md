# VM_SW1 — Switch Virtual 1

Esta pasta contém os arquivos de configuração utilizados na instância `VM_SW1`, responsável por parte da comutação de Camada 2 da infraestrutura do trabalho.

O `VM_SW1` atua como switch virtual baseado em Open vSwitch, realizando a criação da bridge principal `br-int`, configuração de portas trunk, configuração de portas access e aplicação da regra de espelhamento de tráfego via OpenFlow para a VM4.

## Mapeamento de interfaces

A imagem abaixo apresenta o mapeamento das interfaces Linux do `VM_SW1`, seus respectivos endereços MAC e a rede correspondente no OpenStack.

![Mapeamento de interfaces da VM\_SW1](/docs/VM_SW1_interfaces.png)

## Estrutura da pasta

```text
VM_SW1/
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

Arquivo de configuração persistente da interface de gerência do `VM_SW1`.

Este arquivo configura a interface `ens9`, vinculada à rede `labredes1`, com o endereço IP:

```text
192.168.10.119/24
```

Também define a rota padrão para o gateway:

```text
192.168.10.1
```

A interface `ens9` deve permanecer fora da bridge `br-int`, pois é utilizada para acesso administrativo e conexão SSH.

---

### `ovs/01-criar-bridge.sh`

Cria a bridge principal do Open vSwitch:

```text
br-int
```

A bridge `br-int` funciona como o barramento central de comutação do switch virtual. É nela que as interfaces de rede são adicionadas para operação em modo access ou trunk.

---

### `ovs/02-configurar-trunks.sh`

Configura as portas trunk do `VM_SW1`.

As interfaces configuradas neste arquivo são:

| Interface | Função                                 |
| --------- | -------------------------------------- |
| `ens8`    | Link para o firewall/roteador VM11     |
| `ens13`   | Link de backbone entre VM_SW1 e VM_SW2 |
| `ens5`    | Link de espelhamento para a VM4        |

As VLANs permitidas nos trunks são:

```text
10,20,30,40,50,60
```

Essas portas transportam múltiplas VLANs no mesmo enlace lógico.

---

### `ovs/03-configurar-portas-access.sh`

Configura as portas access do `VM_SW1`.

As portas access são utilizadas para conexão direta das máquinas virtuais aos seus respectivos segmentos de rede.

| Interface | Máquina / Função                    | VLAN    |
| --------- | ----------------------------------- | ------- |
| `ens3`    | VM9 — Autenticação                  | VLAN 10 |
| `ens4`    | VM3 — Descoberta de Hosts           | VLAN 40 |
| `ens6`    | VM_DEV — Estação de Desenvolvimento | VLAN 50 |
| `ens7`    | VM_USER1 — Usuários                 | VLAN 60 |
| `ens14`   | VM4 — Gerência/Captura              | VLAN 40 |

Cada porta recebe uma única tag VLAN por meio do modo `access`.

---

### `ovs/04-span-openflow.sh`

Configura o espelhamento de tráfego do `VM_SW1` para a VM4 usando OpenFlow.

Este arquivo realiza três ações principais:

1. Limpa configurações antigas de mirror na bridge `br-int`;
2. Remove fluxos OpenFlow anteriores;
3. Cria uma regra de clonagem de tráfego para encaminhar uma cópia dos pacotes para a VM4.

A regra utilizada altera o MAC de destino do tráfego clonado para a interface receptora da VM4:

```text
fa:16:3e:77:99:5e
```

A saída do espelhamento é realizada pela interface:

```text
ens5
```

## Ordem de execução

A execução deve ser feita dentro da pasta `VM_SW1/ovs`.

```bash
cd VM_SW1/ovs
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
sudo cp VM_SW1/netplan/99-cloud-init.yaml /etc/netplan/99-cloud-init.yaml
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
sudo ovs-vsctl list Port ens8
sudo ovs-vsctl list Port ens13
sudo ovs-vsctl list Port ens5
```

Verificar os fluxos OpenFlow:

```bash
sudo ovs-ofctl dump-flows br-int
```

Verificar estatísticas do backbone inter-switch:

```bash
ip -s link show ens13
```

## Observação

A interface `ens9` não deve ser adicionada à bridge `br-int`, pois é a interface de gerência da instância `VM_SW1`.
